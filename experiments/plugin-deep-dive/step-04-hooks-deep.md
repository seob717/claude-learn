# Step 4: Hook 시스템 심화 — 이벤트, 타입, 실행 흐름

## 핵심 질문

> Step 3에서 "OMC는 9개 이벤트 × 36개 모듈, Superpowers는 1개"라고 했다.
> 그렇다면 Hook은 실제로 어떻게 등록되고, 어떤 데이터를 받고, 어떤 효과를 내는가?

## Hook 통신 원리 — 3줄 요약

```
Claude Code 이벤트 발생
  → stdin으로 JSON 데이터를 Hook 스크립트에 전달
  → Hook이 stdout으로 JSON 응답 반환
  → Claude Code가 응답을 해석하여 효과 적용
```

Hook은 **별도 프로세스**로 실행된다. Claude Code와의 통신은 오직 **stdin/stdout JSON**뿐이다.

---

## hooks.json — Hook 등록 파일

모든 플러그인은 `hooks/hooks.json`에 Hook을 등록한다. Claude Code가 시작할 때 이 파일을 읽고 이벤트 리스너로 연결한다.

### Superpowers의 hooks.json (전체)

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "'${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd' session-start",
            "async": false
          }
        ]
      }
    ]
  }
}
```

→ 이벤트 1개, Hook 1개. 세션이 시작될 때 스킬 목록을 주입하는 게 전부다.

### OMC의 hooks.json (요약)

```json
{
  "hooks": {
    "SessionStart": [
      { "matcher": "*", "hooks": [{ "command": "session-start.mjs" }] },
      { "matcher": "*", "hooks": [{ "command": "project-memory-session.mjs" }] },
      { "matcher": "init", "hooks": [{ "command": "setup-init.mjs", "timeout": 30000 }] },
      { "matcher": "maintenance", "hooks": [{ "command": "setup-maintenance.mjs", "timeout": 60000 }] }
    ],
    "UserPromptSubmit": [
      { "matcher": "*", "hooks": [{ "command": "keyword-detector.mjs", "timeout": 5000 }] },
      { "matcher": "*", "hooks": [{ "command": "skill-injector.mjs", "timeout": 3000 }] }
    ],
    "PreToolUse": [
      { "matcher": "*", "hooks": [{ "command": "pre-tool-enforcer.mjs" }] },
      { "matcher": "ExitPlanMode", "hooks": [{ "command": "context-safety.mjs" }] }
    ],
    "PostToolUse": [
      { "matcher": "*", "hooks": [{ "command": "post-tool-verifier.mjs" }] },
      { "matcher": "*", "hooks": [{ "command": "project-memory-posttool.mjs" }] }
    ],
    "PostToolUseFailure": [
      { "matcher": "*", "hooks": [{ "command": "post-tool-use-failure.mjs" }] }
    ],
    "SubagentStart": [
      { "matcher": "*", "hooks": [{ "command": "subagent-tracker.mjs start" }] }
    ],
    "SubagentStop": [
      { "matcher": "*", "hooks": [{ "command": "subagent-tracker.mjs stop" }] },
      { "matcher": "*", "hooks": [{ "command": "verify-deliverables.mjs" }] }
    ],
    "PreCompact": [
      { "matcher": "*", "hooks": [{ "command": "pre-compact.mjs", "timeout": 10000 }] },
      { "matcher": "*", "hooks": [{ "command": "project-memory-precompact.mjs" }] }
    ],
    "Stop": [
      { "matcher": "*", "hooks": [{ "command": "context-guard-stop.mjs" }] },
      { "matcher": "*", "hooks": [{ "command": "persistent-mode.cjs", "timeout": 10000 }] },
      { "matcher": "*", "hooks": [{ "command": "code-simplifier.mjs" }] }
    ],
    "SessionEnd": [
      { "matcher": "*", "hooks": [{ "command": "session-end.mjs", "timeout": 10000 }] }
    ]
  }
}
```

→ 이벤트 10개, Hook 21개. 세션의 전체 생명주기를 감시한다.

---

## Matcher — 언제 발동하는가

`matcher`는 Claude Code가 Hook을 실행할지 결정하는 필터다.

| Matcher | 의미 | 예시 |
|---------|------|------|
| `"*"` | 항상 실행 | 대부분의 OMC Hook |
| `"startup\|resume\|clear"` | OR 패턴 매칭 | Superpowers: 세션 시작 유형 필터 |
| `"Bash"` | 특정 도구명 매칭 | OMC: Bash 권한 요청에만 |
| `"ExitPlanMode"` | 특정 도구명 매칭 | OMC: 플랜 모드 종료 시에만 |
| `"init"` | 특정 컨텍스트 매칭 | OMC: 초기 설정 시에만 |

```
핵심: Matcher는 Claude Code의 라우팅 레이어다.
플러그인이 필터링 코드를 직접 짤 필요 없이,
hooks.json에 패턴만 쓰면 Claude Code가 알아서 필터링해준다.
```

---

## stdin/stdout 데이터 흐름

### Hook이 받는 데이터 (stdin)

Claude Code가 Hook 프로세스의 stdin에 보내는 JSON:

```json
{
  "session_id": "abc123",
  "cwd": "/Users/me/project",
  "tool_name": "Bash",
  "tool_input": { "command": "npm test" },
  "tool_response": "Tests passed",
  "prompt": "테스트 실행해줘",
  "hook_event_name": "PostToolUse"
}
```

→ 이벤트에 따라 다른 필드가 채워진다. 예: `UserPromptSubmit`에는 `prompt`, `PostToolUse`에는 `tool_name`과 `tool_response`.

### Hook이 보내는 응답 (stdout)

Hook이 stdout으로 출력하는 JSON은 3가지 패턴이 있다:

**패턴 1: 컨텍스트 주입** — Claude에게 텍스트를 전달

```json
{
  "continue": true,
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "당신은 superpowers를 갖고 있습니다..."
  }
}
```

→ `additionalContext`의 내용이 `<system-reminder>` 태그로 Claude의 컨텍스트에 주입된다.

**패턴 2: 차단 (Block)** — Claude의 행동을 막음

```json
{
  "decision": "block",
  "reason": "[RALPH LOOP - ITERATION 3/100] 아직 끝나지 않았습니다. 계속하세요."
}
```

→ Stop Hook에서 사용. Claude가 멈추려 할 때 "아직 안 됐어, 계속해" 신호를 보낸다.

**패턴 3: 무시** — 아무 효과 없이 통과

```json
{
  "continue": true,
  "suppressOutput": true
}
```

→ Hook이 실행됐지만 Claude에게 보여줄 건 없을 때.

---

## 실행 러너 — 스크립트를 어떻게 실행하는가

### Superpowers: Bash 셸 (run-hook.cmd)

```
Claude Code
  → run-hook.cmd 실행
  → OS 감지 (Windows: Git Bash 탐색 / Unix: 직접 bash)
  → session-start 스크립트 실행
  → SKILL.md 파일 읽기 → JSON 출력
```

**특이점:** `.cmd` 확장자를 쓰는 이유 → Windows Batch와 Unix Bash를 동시에 지원하는 **폴리글랏 스크립트**. `.sh`를 쓰면 Claude Code가 Windows에서 자동으로 `bash`를 앞에 붙여 문제가 생긴다.

### OMC: Node.js (run.cjs)

```
Claude Code
  → node run.cjs <target.mjs> [args]
  → target 파일 경로 해석 (3단계 폴백):
      1. 경로 그대로 사용 (파일 존재 확인)
      2. realpath로 심볼릭 링크 추적
      3. 플러그인 캐시에서 최신 버전 탐색
  → spawnSync(process.execPath, [resolved_path, ...args])
  → 자식 프로세스 종료 코드 전파
```

**핵심 설계:**
- `process.execPath`를 사용 → nvm/fnm 환경에서도 올바른 Node.js를 찾음
- 3단계 폴백 → 플러그인 업데이트 후 이전 세션의 경로가 바뀌어도 동작
- 에러 시 항상 exit 0 → Claude Code를 절대 차단하지 않음

---

## 핵심 Hook 해부 — 각 Hook이 하는 일

### 1. keyword-detector.mjs (UserPromptSubmit)

OMC의 심장. 사용자 프롬프트에서 키워드를 감지하여 스킬을 발동한다.

```
사용자 입력: "autopilot으로 로그인 기능 만들어줘"

[1단계] 정제 — 오탐 방지
  - XML 태그 제거 (예시 코드 속 키워드 무시)
  - URL 제거 (https://autopilot.example.com 무시)
  - 파일 경로 제거 (/path/to/autopilot.ts 무시)
  - 마크다운 코드 블록 제거

[2단계] 키워드 매칭 — 우선순위 순서로 탐색
  cancel     : cancelomc|stopomc
  ralph      : ralph|don't stop|must complete|until done
  autopilot  : autopilot|auto-pilot|build me a|i want a/an
  ultrapilot : ultrapilot|ultra-pilot|parallel build
  ultrawork  : ultrawork|ulw|uw
  team       : team (단, my/the/our team은 제외)
  pipeline   : pipeline|chain agents
  ccg        : ccg|claude-codex-gemini
  tdd        : tdd|test first|red green
  ...

[3단계] 충돌 해결
  - cancel은 배타적 (다른 모드 모두 해제)
  - team은 autopilot/ultrapilot보다 우선
  - ralph + team은 공존 가능

[4단계] 상태 파일 기록
  → {project}/.omc/state/sessions/{sessionId}/autopilot-state.json
  → { "active": true, "started_at": "...", "original_prompt": "..." }

[5단계] 출력
  → "[MAGIC KEYWORD: AUTOPILOT]\n스킬을 호출하세요: oh-my-claudecode:autopilot"
```

**왜 정제가 필요한가?** — 사용자가 `"autopilot 문서를 읽어줘"`라고 하면 코드 예시 속 단어가 오탐될 수 있다. URL, 경로, 코드 블록을 먼저 제거해야 의도한 키워드만 잡힌다.

### 2. persistent-mode.cjs (Stop)

Claude가 멈추려 할 때 "계속해"를 강제하는 핵심 Hook.

```
Claude 응답 완료 → Stop 이벤트 발생

[1단계] 안전 검사
  - context_limit 멈춤인가? → 통과 (차단하면 무한루프)
  - 사용자 중단(Ctrl+C)인가? → 통과
  - 상태가 2시간 이상 오래됐나? → 통과 (방치된 상태 무시)
  - 세션 ID가 일치하는가? → 불일치면 통과

[2단계] 활성 모드 확인 (우선순위 순)
  1. Ralph   (최대 100회)
  2. Autopilot (최대 20회)
  3. Team    (최대 20회)
  4. Ultrawork (최대 50회)
  ...

[3단계] 활성 모드 발견 시
  → reinforcement_count 증가
  → decision: "block" 반환
  → "[RALPH LOOP - ITERATION 7/100] 계속 작업하세요."

[4단계] 활성 모드 없음
  → 통과 (Claude 정상 멈춤)
  → session-idle 알림 발송 (60초 쿨다운)
```

**왜 안전 검사가 중요한가?** — context_limit 멈춤을 차단하면 컨텍스트 압축도 못 하고 무한루프에 빠진다. 실제로 issue #213에서 이 버그가 발견되어 안전 검사가 추가됐다.

### 3. pre-tool-enforcer.mjs (PreToolUse)

모든 도구 실행 전에 컨텍스트 힌트를 주입한다.

```
도구별 메시지:
  Bash   → "독립적인 작업은 병렬로 실행하세요. 긴 작업은 run_in_background 사용."
  Read   → "여러 파일은 병렬로 읽어서 분석 속도를 높이세요."
  Edit   → "변경 후 동작을 확인하세요. 완료 전에 테스트하세요."
  Grep   → "여러 패턴은 병렬 검색으로 조합하세요."
  Task   → "에이전트 생성: {타입} ({모델}) | 활성 에이전트: N개"
```

→ 이 Hook 때문에 OMC가 활성화된 Claude는 도구 사용 전마다 `<system-reminder>` 메시지를 받는다.
→ 우리 세션에서 보이는 `"Read multiple files in parallel..."` 같은 메시지가 바로 이 Hook의 출력이다.

### 4. post-tool-verifier.mjs (PostToolUse)

모든 도구 실행 후 결과를 분석하고 피드백한다.

```
기능 목록:
  - 세션 통계 기록 (도구별 호출 횟수)
  - Bash 히스토리 저장 (~/.bash_history)
  - <remember> 태그 파싱 → 메모장에 저장
  - 실패 패턴 감지 → 안내 메시지
  - 과도한 Read (10회+) → "Grep 사용을 고려하세요"
  - Grep 결과 없음 → "패턴 구문을 확인하세요"
```

### 5. session-start.mjs (SessionStart)

세션 시작 시 상태 복원과 환경 점검을 수행한다.

```
[1] 버전 불일치 감지 → 업데이트 안내
[2] npm 레지스트리에서 최신 버전 확인 (24시간 캐시)
[3] HUD(상태바) 설치 여부 확인
[4] Ultrawork 상태 복원 → "[ULTRAWORK MODE RESTORED]"
[5] Ralph 상태 복원 → "[RALPH LOOP RESTORED] iteration 5/100"
[6] 미완료 TODO 주입
[7] 메모장 Priority Context 주입
[8] 오래된 플러그인 캐시 정리 (최근 2버전만 유지)
```

→ `claude -c`로 세션을 재개하면 이전 모드(ralph, ultrawork 등)가 자동 복원되는 이유가 여기 있다.

---

## 전체 실행 흐름 — 하나의 세션에서

```
[세션 시작]
  SessionStart → Superpowers: 스킬 목록 주입
              → OMC: 상태 복원, 프로젝트 메모리, 환경 점검

[사용자 입력: "ralph로 인증 시스템 만들어줘"]
  UserPromptSubmit → keyword-detector: "ralph" 감지
                       → state 기록: ralph-state.json { active: true }
                       → 출력: "[MAGIC KEYWORD: RALPH]"
                  → skill-injector: 학습된 스킬 검색 (해당 없으면 패스)

[도구 실행: Read auth.ts]
  PreToolUse → pre-tool-enforcer: "여러 파일 병렬로 읽으세요"
  PostToolUse → post-tool-verifier: 통계 기록, 결과 피드백

[도구 실행: Edit auth.ts]
  PreToolUse → pre-tool-enforcer: "변경 후 동작 확인하세요"
  PostToolUse → post-tool-verifier: "코드 수정됨. 테스트 필요."

[도구 실행: Bash npm test]
  PreToolUse → pre-tool-enforcer: "병렬 실행 가능하면 병렬로"
  PostToolUse → post-tool-verifier: 성공/실패 분석

[Claude가 멈추려 함]
  Stop → context-guard: 컨텍스트 사용률 확인 (75% 미만이면 통과)
      → persistent-mode: ralph-state 확인
           → active! reinforcement_count: 0 → 1
           → decision: "block"
           → "[RALPH LOOP - ITERATION 1/100] 계속 작업하세요."
  → Claude 다시 작업 시작

  ... (반복) ...

[Claude가 다시 멈추려 함 — 작업 완료]
  Stop → persistent-mode: ralph-state 확인
           → active, 하지만 Claude가 cancel 스킬 호출
           → state 비활성화
  → Claude 정상 종료

[세션 종료]
  SessionEnd → session-end: 상태 아카이브, 알림
```

---

## 비교 요약

### 이벤트 커버리지

| 이벤트 | Superpowers | OMC | 차이 |
|--------|:-----------:|:---:|------|
| SessionStart | 1 | 4 | OMC: 상태 복원 + 메모리 + 설정 |
| UserPromptSubmit | - | 2 | OMC: 키워드 감지 + 스킬 주입 |
| PreToolUse | - | 2 | OMC: 도구별 힌트 + 안전 검사 |
| PostToolUse | - | 2 | OMC: 통계 + 피드백 |
| PostToolUseFailure | - | 1 | OMC: 반복 실패 추적 |
| SubagentStart | - | 1 | OMC: 에이전트 추적 |
| SubagentStop | - | 2 | OMC: 추적 + 산출물 검증 |
| PreCompact | - | 2 | OMC: 컨텍스트 보존 |
| Stop | - | 3 | OMC: 컨텍스트 가드 + 지속 모드 |
| SessionEnd | - | 1 | OMC: 정리 + 알림 |
| **합계** | **1** | **21** | **21배 차이** |

### 설계 철학

| | Superpowers | OMC |
|---|---|---|
| **언어** | Bash 셸 | Node.js |
| **상태 관리** | 없음 (무상태) | 세션별 JSON 파일 |
| **에러 처리** | `set -euo pipefail` | 항상 exit 0 (Claude 차단 방지) |
| **응답 패턴** | 컨텍스트 주입만 | 주입 + 차단 + 무시 |
| **타임아웃** | 미설정 (기본값) | Hook별 3초~60초 |
| **크로스플랫폼** | 폴리글랏 Batch+Bash | Node.js (OS 독립) |

### 한 줄 정리

```
Superpowers Hook = 세션 시작 시 레시피북을 펼쳐놓는 것
OMC Hook        = 모든 순간을 감시하고 개입하는 자동화 시스템
```

---

## Step 3 → Step 4 연결

| Step 3에서 배운 것 | Step 4에서 알게 된 것 |
|-------------------|---------------------|
| OMC의 `hooks/hooks.json`이 등록 파일 | 10개 이벤트 × 21개 Hook이 구체적으로 뭘 하는지 |
| Superpowers의 Hook은 1개 | 그 1개가 스킬 목록 주입을 위한 것 |
| `src/hooks/`에 36개 모듈이 있다 | 핵심 모듈 5개의 동작 원리를 파악 |
| 두 플러그인의 규모 차이 26배 | Hook이 규모 차이의 핵심 원인 — OMC는 전체 생명주기를 제어 |

---

## 확인 질문

1. Hook이 Claude Code와 통신하는 방식 2가지는?
2. `additionalContext`로 주입된 텍스트는 Claude에게 어떤 형태로 보이는가?
3. `decision: "block"`은 어떤 이벤트에서 쓰이며, 어떤 효과를 내는가?
4. keyword-detector가 프롬프트를 정제하는 이유는?
5. persistent-mode가 context_limit 멈춤을 차단하지 않는 이유는?

→ 답:
1. stdin으로 JSON 데이터를 받고, stdout으로 JSON 응답을 보낸다
2. `<system-reminder>` 태그로 시스템 수준 메시지로 주입됨
3. Stop(+PreToolUse)에서 사용. Claude의 멈춤(또는 도구 실행)을 차단하고 계속 작업하게 함
4. URL, 코드 블록, 파일 경로 속 키워드가 오탐되는 걸 방지하기 위해
5. 차단하면 컨텍스트 압축도 못 해서 무한루프에 빠지기 때문 (issue #213)

---

다음 단계: **Step 5 — Superpowers 해부 — 단순한 구조로 원리 이해**
