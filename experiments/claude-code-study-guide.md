# Claude Code 완전 학습 가이드

> 기초부터 2026-03-02 기준 최신 기능까지
> 세션이 끊어져도 체크박스로 진행 상황 추적 가능

---

## 학습 진행 체크리스트

- [x] Level 1: 기본 개념과 설치
- [x] Level 2: CLAUDE.md 계층 구조
- [x] Level 3: 설정 (settings.json)
- [x] Level 4: 슬래시 커맨드
- [x] Level 5: 키보드 단축키
- [x] Level 6: 모델 선택과 성능 제어
- [x] Level 7: Hooks 시스템
- [x] Level 8: MCP 서버
- [x] Level 9: 세션 관리와 컨텍스트
- [x] Level 10: SDK / Headless 모드
- [x] Level 11: Git Worktree
- [x] Level 12: IDE 연동
- [x] Level 13: 커스텀 에이전트와 스킬
- [x] Level 14: Agent Teams
- [x] Level 15: 플러그인 생태계
- [x] Level 16: 종합 복습
- [x] Level 17: Sandbox 고급 활용
- [x] Level 18: 고급 CLI 옵션
- [x] Level 19: 대규모 코드베이스 전략
- [ ] Level 20: 프롬프트 엔지니어링
- [ ] Level 21: 비용 최적화
- [ ] Level 22: 보안 베스트 프랙티스
- [ ] Level 23: 비코딩 활용

---

## Level 1: 기본 개념과 설치 [완료]

### Claude Code란?
Anthropic이 만든 에이전틱 코딩 도구. 코드 읽기, 편집, 명령어 실행, 개발 도구 연동을 자동으로 수행한다.

### 작동 원리 (에이전틱 루프)
```
사용자 프롬프트 → 도구 선택 → 도구 실행 → 결과 관찰 → 다음 액션 결정 → ... → 완료
```
사용 가능한 도구: Bash, Read, Edit, Write, Grep, Glob, WebFetch, WebSearch, Task 등

### 설치
```bash
# macOS / Linux / WSL
curl -fsSL https://claude.ai/install.sh | bash

# Homebrew
brew install --cask claude-code

# 업데이트
claude update
```

### 기본 사용법
```bash
claude                         # 대화형 세션 시작
claude "이 프로젝트 설명해줘"    # 초기 프롬프트와 함께 시작
claude -p "query"              # 비대화형(headless) 모드 — 답변 후 종료
claude -c                      # 가장 최근 대화 이어하기
claude --resume auth-refactor  # 이름으로 세션 재개
```

### 빠른 접두사
| 접두사 | 동작 |
|--------|------|
| `!` | bash 명령어 직접 실행 (예: `!ls -la`) |
| `@` | 파일 경로 자동완성 |
| `/` | 슬래시 커맨드/스킬 메뉴 |

---

## Level 2: CLAUDE.md 계층 구조 [완료]

### CLAUDE.md가 뭔가?
Claude에게 주는 영구 지시사항 파일. 매 세션 시작 시 자동으로 읽힌다.

### 계층 구조 (우선순위 높은 순)

| 순위 | 파일 | 범위 | git 커밋 여부 |
|------|------|------|---------------|
| 1 | 관리 정책 CLAUDE.md | 조직 전체 (IT 배포) | N/A |
| 2 | `./CLAUDE.md` 또는 `./.claude/CLAUDE.md` | 프로젝트 팀 공유 | O |
| 3 | `./.claude/rules/*.md` | 프로젝트 모듈별 규칙 | O |
| 4 | `~/.claude/CLAUDE.md` | 개인, 모든 프로젝트 | X |
| 5 | `./CLAUDE.local.md` | 개인, 현재 프로젝트만 | X (gitignore) |
| 6 | `~/.claude/projects/<project>/memory/` | 자동 메모리 | X |

### 모듈 규칙 (paths 프론트매터)
특정 파일 패턴에만 적용되는 규칙을 만들 수 있다:
```markdown
---
paths:
  - "src/api/**/*.ts"
---
# API 규칙
모든 API 엔드포인트에 입력 검증 필수.
```
→ `src/api/` 하위의 .ts 파일을 Claude가 읽을 때만 이 규칙이 로드된다.

### Import 문법
다른 파일 내용을 CLAUDE.md에 포함시킬 수 있다:
```markdown
프로젝트 개요는 @README 참조
npm 명령어는 @package.json 참조
Git 워크플로 @docs/git-instructions.md
```

### 실습에서 만든 구조
```
프로젝트/
├── CLAUDE.md                  ← 팀 공유
├── CLAUDE.local.md            ← 개인 전용 (gitignore)
├── .claude/
│   ├── settings.local.json    ← 개인 설정
│   └── rules/
│       ├── code-style.md      ← 전체 적용
│       └── experiments.md     ← experiments/** 에만 적용
└── .gitignore                 ← local 파일들 제외
```

---

## Level 3: 설정 (settings.json)

### 설정 파일 우선순위 (높은 순)
1. **관리 설정** (managed-settings.json) — 조직 강제, 재정의 불가
2. **CLI 인수** — `--model opus` 같은 실행 시 옵션
3. **프로젝트 로컬** — `.claude/settings.local.json` (개인, gitignore)
4. **프로젝트 공유** — `.claude/settings.json` (팀 공유, git 커밋)
5. **사용자** — `~/.claude/settings.json` (전역 개인 설정)

### 설정 파일 기본 구조
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "opus",
  "permissions": {
    "allow": ["Bash(npm run lint)", "Bash(npm run test *)"],
    "ask": ["Bash(git push *)"],
    "deny": ["Bash(curl *)", "Read(./.env)"],
    "additionalDirectories": ["../docs/"],
    "defaultMode": "acceptEdits"
  },
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1"
  },
  "hooks": { },
  "statusLine": { "type": "command", "command": "..." },
  "enabledPlugins": { "plugin@marketplace": true },
  "enabledMcpjsonServers": ["github", "filesystem"]
}
```

### 권한 모드 4가지

| 모드 | 동작 | 전환 |
|------|------|------|
| `default` | 매 동작마다 확인 | 기본값 |
| `plan` | 읽기 전용 탐색, 실행 전 계획 제시 | `/plan` |
| `acceptEdits` | 파일 편집 자동 승인, 나머지는 확인 | `Shift+Tab` |
| `bypassPermissions` | 모든 권한 검사 건너뛰기 | `--dangerously-skip-permissions` |

세션 중 `Shift+Tab`으로 순환 전환 가능.

### 권한 규칙 문법
```
Tool                     → 해당 도구의 모든 사용
Tool(specifier)          → 특정 조건만
Tool(pattern*)           → 와일드카드
```

**평가 순서: deny > ask > allow** (첫 매치가 적용됨)

예시:
| 규칙 | 의미 |
|------|------|
| `Bash(npm run *)` | npm run으로 시작하는 명령어 |
| `Read(./.env)` | .env 파일 읽기 |
| `Edit(./src/**)` | src/ 하위 편집 |
| `WebFetch(domain:example.com)` | 특정 도메인만 |
| `Task(Explore)` | 특정 서브에이전트 |

### 주요 설정 키

| 키 | 설명 | 예시 |
|----|------|------|
| `model` | 기본 모델 | `"opus"` |
| `availableModels` | 사용 가능 모델 제한 | `["sonnet", "haiku"]` |
| `language` | 응답 언어 | `"ko"` |
| `effortLevel` | 추론 깊이 | `"low"` / `"medium"` / `"high"` |
| `fastMode` | 빠른 모드 | `true` |
| `autoMemoryEnabled` | 자동 메모리 | `true` |
| `cleanupPeriodDays` | 세션 정리 주기 | `30` |

### 실습: 프로젝트 공유 설정 만들기
```bash
# .claude/settings.json (팀이 공유하는 설정)
cat > .claude/settings.json << 'EOF'
{
  "permissions": {
    "allow": ["Bash(node *)", "Bash(python3 *)"],
    "deny": ["Bash(rm -rf *)"]
  }
}
EOF
```

### 주요 환경 변수

| 변수 | 용도 |
|------|------|
| `ANTHROPIC_API_KEY` | API 키 (직접 API 사용 시) |
| `ANTHROPIC_MODEL` | 기본 모델 |
| `CLAUDE_CODE_EFFORT_LEVEL` | low / medium / high |
| `MAX_THINKING_TOKENS` | 확장 사고 토큰 예산 |
| `BASH_DEFAULT_TIMEOUT_MS` | Bash 타임아웃 |
| `MCP_TIMEOUT` | MCP 서버 시작 타임아웃 |
| `CLAUDE_CODE_ACCOUNT_UUID` | 현재 로그인 계정 UUID (Hook/스크립트에서 참조) |
| `CLAUDE_CODE_USER_EMAIL` | 현재 로그인 사용자 이메일 |
| `CLAUDE_CODE_ORGANIZATION_UUID` | 소속 조직 UUID |

---

## Level 4: 슬래시 커맨드

### 전체 내장 커맨드 목록

**정보 확인:**
| 커맨드 | 용도 |
|--------|------|
| `/cost` | 토큰 사용량 통계 |
| `/context` | 컨텍스트 사용량 시각화 (컬러 그리드) |
| `/status` | 버전, 모델, 계정, 연결 상태 |
| `/usage` | 플랜 사용 한도, 레이트 리밋 |
| `/stats` | 일일 사용량, 세션 히스토리, 연속 사용일 |

**세션 관리:**
| 커맨드 | 용도 |
|--------|------|
| `/clear` | 대화 초기화 (세션은 유지, 캐시된 스킬도 리셋) |
| `/compact [지시]` | 컨텍스트 압축 (선택적 포커스) |
| `/resume [세션]` | 이전 세션 재개 (대화형 피커) |
| `/rename [이름]` | 현재 세션 이름 지정 |
| `/rewind` | 대화/코드를 이전 시점으로 되감기 |
| `/copy` | 마지막 응답 클립보드 복사 (코드 블록 선택 피커 지원) |
| `/export [파일]` | 대화를 파일로 내보내기 |
| `/tasks` | 백그라운드 작업 관리 |

**설정 변경:**
| 커맨드 | 용도 |
|--------|------|
| `/model` | 모델 선택 (좌우 화살표로 노력 수준 조절) |
| `/permissions` | 권한 확인/수정 |
| `/config` | 설정 UI 열기 |
| `/memory` | CLAUDE.md 메모리 편집 |
| `/vim` | vim 스타일 편집 토글 |
| `/theme` | 컬러 테마 변경 |
| `/keybindings` | 키바인딩 설정 |
| `/statusline` | 상태바 설정 |

**특수 기능:**
| 커맨드 | 용도 |
|--------|------|
| `/plan` | 플랜 모드 진입 (읽기 전용 탐색 → 계획 제시) |
| `/fast` | 빠른 모드 토글 (2.5배 속도, 같은 모델) |
| `/init` | 프로젝트 CLAUDE.md 초기화 |
| `/doctor` | 설치 상태 진단 |
| `/mcp` | MCP 서버 연결 관리, OAuth 인증 |
| `/debug [설명]` | 현재 세션 트러블슈팅 |
| `/teleport` | claude.ai 원격 세션을 로컬로 가져오기 |
| `/desktop` | CLI 세션을 데스크톱 앱으로 핸드오프 |
| `/hooks` | Hook 설정 관리 |
| `/agents` | 서브에이전트 관리 |
| `/todos` | TODO 항목 목록 |
| `/simplify` | 최근 변경 코드를 간결하게 리팩토링 |

### 실습: 주요 커맨드 체험
```bash
# 세션 안에서 직접 입력해보세요:
/status          # 현재 환경 정보 확인
/cost            # 토큰 사용량 확인
/context         # 컨텍스트 시각화
/model           # 모델 선택 (←→ 로 노력 수준 조절)
/compact         # 컨텍스트 압축해보기
/mcp             # MCP 서버 상태 확인
```

---

## Level 5: 키보드 단축키

### 필수 단축키

**세션 제어:**
| 단축키 | 동작 |
|--------|------|
| `Ctrl+C` | 현재 입력/생성 취소 |
| `Ctrl+D` | Claude Code 종료 |
| `Ctrl+F` | 백그라운드 에이전트 전부 중단 (두 번 누르기) |
| `Shift+Tab` | 권한 모드 순환 전환 |
| `Esc Esc` | 되감기 또는 요약 |

**입력 편집:**
| 단축키 | 동작 |
|--------|------|
| `\` + `Enter` | 멀티라인 입력 (가장 확실한 방법) |
| `Option+Enter` | 멀티라인 (macOS) |
| `Ctrl+J` | 멀티라인 (제어 시퀀스) |
| `Ctrl+G` | 외부 텍스트 에디터에서 편집 |
| `Ctrl+K` | 커서부터 줄 끝까지 삭제 |
| `Ctrl+U` | 전체 줄 삭제 |
| `Ctrl+Y` | 삭제한 텍스트 붙여넣기 |
| `Alt+B` / `Alt+F` | 단어 단위 이동 |

**모드 전환:**
| 단축키 | 동작 |
|--------|------|
| `Alt+P` / `Option+P` | 모델 전환 |
| `Alt+T` / `Option+T` | 확장 사고(Extended Thinking) 토글 |
| `Ctrl+V` | 클립보드 이미지 붙여넣기 |
| `Ctrl+O` | 상세 출력(verbose) 토글 |
| `Ctrl+R` | 명령어 히스토리 역검색 |
| `Ctrl+T` | 태스크 리스트 토글 |
| `Ctrl+B` | 실행 중인 작업을 백그라운드로 |
| `Ctrl+L` | 터미널 화면 지우기 |

### 커스텀 키바인딩
`~/.claude/keybindings.json`에서 설정:
```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "ctrl+e": "chat:externalEditor",
        "ctrl+u": null
      }
    }
  ]
}
```

**키 표기법:** `ctrl+k`, `shift+tab`, `meta+p`, `ctrl+shift+c`
**코드 바인딩:** `ctrl+k ctrl+s` (순차 키 조합)
**예약 키 (변경 불가):** `Ctrl+C`, `Ctrl+D`

변경 후 재시작 없이 자동 반영됨.

---

## Level 6: 모델 선택과 성능 제어

### 사용 가능한 모델 별칭

| 별칭 | 모델 | 특징 |
|------|------|------|
| `opus` | Opus 4.6 | 최고 성능, 복잡한 작업 |
| `sonnet` | Sonnet 4.6 | 균형 잡힌 성능/비용 |
| `haiku` | Haiku 4.5 | 빠르고 저렴 |
| `default` | 계정 타입에 따라 다름 | Max/Team Premium → Opus |
| `sonnet[1m]` | Sonnet + 1M 컨텍스트 | 대규모 코드베이스 |
| `opus[1m]` | Opus + 1M 컨텍스트 | 최대 성능 + 최대 컨텍스트 |
| `opusplan` | Opus(계획) + Sonnet(실행) | 하이브리드 전략 |

### 모델 설정 방법 (우선순위 순)
```bash
# 1. 세션 중 변경
/model opus          # 슬래시 커맨드 (←→ 로 노력 수준 조절)

# 2. 시작 시 지정
claude --model opus

# 3. 환경 변수
export ANTHROPIC_MODEL=opus

# 4. settings.json
{ "model": "opus" }
```

### 노력 수준 (Effort Level)
Opus 4.6의 추론 깊이를 조절한다:
- **low**: 빠르고 간단한 응답
- **medium**: 적당한 추론
- **high** (기본): 깊은 사고

```bash
claude --effort medium
# 또는 환경 변수
export CLAUDE_CODE_EFFORT_LEVEL=medium
```

### Fast Mode
같은 Opus 4.6 모델이지만 2.5배 빠른 출력. 토큰당 비용 더 높음.
```bash
/fast              # 세션 중 토글
# 활성화 시 번개 아이콘 표시
# 레이트 리밋 시 자동으로 일반 모드 폴백
```

### 1M 토큰 컨텍스트
Opus/Sonnet에서 최대 100만 토큰 컨텍스트 윈도우 사용 가능:
```bash
/model sonnet[1m]   # 또는 opus[1m]
# 200K까지는 일반 요금, 이후 장문 요금 적용
```
비활성화: `CLAUDE_CODE_DISABLE_1M_CONTEXT=1`

---

## Level 7: Hooks 시스템

### Hooks란?
Claude Code 생명주기의 특정 시점에 자동 실행되는 사용자 정의 핸들러.

### 전체 이벤트 목록

| 이벤트 | 발생 시점 | 차단 가능? |
|--------|-----------|-----------|
| `SessionStart` | 세션 시작 | Yes (exit 2) |
| `UserPromptSubmit` | 프롬프트 제출 | Yes (exit 2) |
| `PreToolUse` | 도구 실행 전 | Yes (exit 2로 도구 차단) |
| `PermissionRequest` | 도구 권한 요청 | Yes (exit 2로 자동 승인) |
| `PostToolUse` | 도구 실행 후 | Yes |
| `PostToolUseFailure` | 도구 실패 후 | Yes |
| `Notification` | Claude 입력 대기 | No |
| `SubagentStart` | 서브에이전트 시작 | No |
| `SubagentStop` | 서브에이전트 완료 | No |
| `Stop` | Claude 응답 완료 | Yes (exit 2로 계속 실행 강제) |
| `TeammateIdle` | 팀원 유휴 상태 | Yes |
| `TaskCompleted` | 태스크 완료 | Yes |
| `ConfigChange` | 설정 변경 | Yes |
| `WorktreeCreate` | Worktree 생성 | No |
| `WorktreeRemove` | Worktree 제거 | No |
| `PreCompact` | 컨텍스트 압축 전 | No |
| `SessionEnd` | 세션 종료 | No |

### Exit 코드 의미
- **0**: 성공, 정상 진행
- **1**: 오류 (로그에 기록, 차단하지 않음)
- **2**: 차단 (이벤트에 따라 다른 효과)

### Hook 타입 4가지

**1) Command Hook (쉘 명령어):**
```json
{
  "type": "command",
  "command": "npx prettier --write $TOOL_INPUT_FILE_PATH",
  "timeout": 30000
}
```

**2) Prompt Hook (LLM 평가):**
```json
{
  "type": "prompt",
  "prompt": "이 코드 변경이 보안 취약점을 만드는지 평가해주세요"
}
```

**3) Agent Hook (서브에이전트 생성):**
```json
{
  "type": "agent",
  "prompt": "변경된 파일에 대해 린트 검사를 수행해주세요"
}
```

**4) HTTP Hook (외부 웹훅 호출):**
```json
{
  "type": "http",
  "url": "https://my-server.example.com/webhook",
  "method": "POST",
  "headers": {
    "Authorization": "Bearer ${WEBHOOK_TOKEN}"
  },
  "timeout": 5000
}
```
→ 외부 서비스에 이벤트를 전달할 때 사용 (Slack 알림, CI 트리거 등).
→ command Hook의 curl 방식 대비: 네이티브 처리, 환경 변수 자동 치환, curl 미설치 환경 대응.

**보안 설정 — allowedDomains:**
HTTP Hook은 반드시 허용 도메인을 명시해야 한다:
```json
{
  "hooks": {
    "allowedDomains": ["my-server.example.com", "hooks.slack.com"],
    "PostToolUse": [
      {
        "hooks": [{ "type": "http", "url": "https://my-server.example.com/webhook" }]
      }
    ]
  }
}
```
→ `allowedDomains`에 없는 도메인으로의 HTTP Hook은 차단됨. 보안을 위해 와일드카드 불가.

### 설정 구조
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $TOOL_INPUT_FILE_PATH",
            "timeout": 30000
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "afplay /System/Library/Sounds/Glass.aiff &"
          }
        ]
      }
    ]
  }
}
```

### Matcher
- `"Write|Edit"` → Write 또는 Edit 도구에만 적용
- `"Bash"` → Bash 도구에만 적용
- `"mcp__github__*"` → GitHub MCP 도구 전체
- `""` (빈 문자열) → 모든 것에 매칭

### 비동기 Hook
```json
{
  "type": "command",
  "command": "/path/to/script.sh",
  "async": true,
  "timeout": 10
}
```

### Hook 입력 (stdin으로 JSON 수신)
```json
{
  "session_id": "...",
  "cwd": "/path/to/project",
  "tool_name": "Write",
  "tool_input": { "file_path": "..." },
  "tool_response": "...",
  "hook_event_name": "PostToolUse"
}
```

### 실습 예시: 자동 포매팅 Hook
`.claude/settings.json`에 추가:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $TOOL_INPUT_FILE_PATH 2>/dev/null || true",
            "timeout": 10000
          }
        ]
      }
    ]
  }
}
```

### 실습 예시: macOS 알림 Hook
```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude가 입력을 기다립니다\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  }
}
```

### 실습 예시: 커밋 메시지 검증 Hook
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "echo $TOOL_INPUT | jq -r '.command' | grep -q '^git commit' && echo $TOOL_INPUT | jq -r '.command' | grep -qE '^git commit -m .{10,}' || (echo 'Commit message too short' && exit 2)"
          }
        ]
      }
    ]
  }
}
```

---

## Level 8: MCP 서버

### MCP (Model Context Protocol)란?
AI 도구를 외부 데이터 소스에 연결하는 개방형 표준 프로토콜.
Claude Code가 GitHub, 파일 시스템, DB 등 외부 서비스의 도구를 사용할 수 있게 해준다.

### 전송 방식 3가지

| 방식 | 설명 | 예시 |
|------|------|------|
| `http` (권장) | 원격 HTTP 서버 | `https://mcp.notion.com/mcp` |
| `sse` (레거시) | Server-Sent Events | `https://mcp.asana.com/sse` |
| `stdio` | 로컬 프로세스 | `npx -y @modelcontextprotocol/server-github` |

### CLI로 MCP 서버 관리
```bash
# 추가
claude mcp add --transport http notion https://mcp.notion.com/mcp
claude mcp add --transport stdio github -- npx -y @modelcontextprotocol/server-github
claude mcp add --transport stdio --env API_KEY=xxx airtable -- npx -y airtable-mcp

# 목록 / 상세 / 제거
claude mcp list
claude mcp get github
claude mcp remove github

# Claude Desktop에서 가져오기
claude mcp add-from-claude-desktop
```

### 범위 (Scope)

| 범위 | 저장 위치 | 공유 여부 |
|------|-----------|-----------|
| `local` (기본) | `~/.claude.json` 프로젝트별 | X |
| `project` | `.mcp.json` 프로젝트 루트 | O (git 커밋) |
| `user` | `~/.claude.json` 전역 | X |

### 프로젝트 공유 설정 (.mcp.json)
```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    },
    "database": {
      "command": "npx",
      "args": ["-y", "@bytebase/dbhub", "--dsn", "postgresql://localhost:5432/mydb"],
      "env": {}
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-filesystem", "/Users/me/project"]
    }
  }
}
```

환경 변수 확장 지원: `${VAR}`, `${VAR:-default}`

### MCP Tool Search
MCP 도구가 많아지면 자동으로 on-demand 로딩 모드 활성화:
```bash
ENABLE_TOOL_SEARCH=auto:5 claude   # 5% 임계값
ENABLE_TOOL_SEARCH=false claude    # 비활성화
```

### Claude Code를 MCP 서버로 사용
```bash
claude mcp serve   # 다른 AI 도구가 Claude Code를 도구로 사용할 수 있음
```

### Claude.ai MCP 서버 비활성화
Claude.ai가 자동으로 제공하는 원격 MCP 서버(Notion, Linear 등)를 끄려면:
```bash
export ENABLE_CLAUDEAI_MCP_SERVERS=false
```
→ 로컬 MCP 서버만 사용하고 싶거나 보안상 외부 연결을 차단할 때 유용.
→ 직접 추가한 MCP 서버(local/project/user)에는 영향 없음.

### 세션 내 관리
```
/mcp               # MCP 서버 상태 확인, OAuth 인증
```

### 실습: MCP 서버 추가해보기
```bash
# Context7 (문서 검색) — 이미 설정됨
claude mcp add --transport stdio context7 -- npx -y @anthropic/context7-mcp

# Playwright (브라우저 자동화)
claude mcp add --transport stdio playwright -- npx -y @anthropic/mcp-server-playwright

# 설정 확인
claude mcp list
```

---

## Level 9: 세션 관리와 컨텍스트

### 세션 생명주기
```
시작 → 대화 → (컨텍스트 가득) → 자동 압축 → 계속 대화 → 종료
                                                    ↓
                                              나중에 /resume으로 재개
```

### 세션 관리 커맨드

| 방법 | 용도 |
|------|------|
| `claude -c` | 가장 최근 세션 이어하기 |
| `claude -r session-name` | 이름으로 세션 재개 |
| `claude --from-pr 123` | PR에 연결된 세션 재개 |
| `/resume` | 대화형 세션 피커 (P: 미리보기, R: 이름변경, B: 브랜치 필터) |
| `/rename auth-refactor` | 현재 세션 이름 지정 |
| `/clear` | 대화 초기화 (세션은 유지) |
| `/export` | 대화 내보내기 |

### 컨텍스트 관리

**자동 압축 (Auto-compaction):**
컨텍스트가 가득 차면 자동으로 이전 대화를 요약해서 공간 확보.
핵심 정보는 보존된다.

**수동 압축:**
```
/compact                    # 기본 압축
/compact API 관련 내용 유지   # 특정 주제 포커스 압축
```

**컨텍스트 시각화:**
```
/context     # 컬러 그리드로 사용량 표시
```

### 자동 메모리 (Auto Memory)
Claude가 프로젝트 패턴, 디버깅 인사이트, 아키텍처를 자동 저장:
```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # 인덱스 (처음 200줄 자동 로드)
├── debugging.md       # 주제별 파일
└── api-conventions.md # 주제별 파일
```

관리: `/memory`로 토글, 설정에서 `autoMemoryEnabled`

### 부분 요약 (Summarize from here)
긴 대화에서 특정 메시지부터 요약할 수 있다:
- 대화 중 원하는 시점의 메시지에서 "Summarize from here" 선택
- 해당 시점 이후의 대화만 요약하여 컨텍스트 절약
- 이전 맥락(설계 결정 등)은 원본 그대로 보존됨

### 체크포인트
Claude가 파일 변경 시 git 체크포인트를 자동 생성.
`Esc Esc`로 이전 시점으로 되감기 가능 (대화 + 코드 모두).

### Prompt Suggestions
응답 후 회색으로 제안 프롬프트가 나타남:
- `Tab`: 수락
- `Enter`: 수락 + 바로 제출
- 프롬프트 캐시를 재활용하므로 비용 최소

---

## Level 10: SDK / Headless 모드

### 비대화형 실행 (-p 플래그)
```bash
# 기본
claude -p "auth.py의 버그를 찾아서 수정해줘"

# 도구 허용 지정
claude -p "테스트 실행하고 실패 수정" --allowedTools "Bash,Read,Edit"

# JSON 출력
claude -p "이 프로젝트 요약" --output-format json

# 스키마 준수 JSON 출력
claude -p "함수 이름 추출" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}}}'

# 스트리밍
claude -p "재귀 설명" --output-format stream-json --verbose

# 세션 이어하기
session_id=$(claude -p "리뷰 시작" --output-format json | jq -r '.session_id')
claude -p "리뷰 계속" --resume "$session_id"
```

### 시스템 프롬프트 커스텀
```bash
# 기본 프롬프트에 추가 (권장)
claude --append-system-prompt "항상 TypeScript 사용"

# 전체 교체
claude --system-prompt "너는 Python 전문가야"

# 파일에서 로드
claude -p --system-prompt-file ./custom-prompt.txt "질문"
```

### 예산/턴 제한
```bash
claude -p --max-budget-usd 5.00 "복잡한 작업"
claude -p --max-turns 3 "간단한 작업"
```

### 실습: 파이프라인으로 활용
```bash
# 코드 리뷰 자동화
cat src/main.js | claude -p "이 코드를 리뷰해줘" --output-format json

# 여러 파일 일괄 처리
for f in src/*.js; do
  claude -p "이 파일의 TODO를 찾아줘: $(cat $f)" --max-turns 1
done

# CI/CD 파이프라인
claude -p "테스트 실행하고 결과 요약" \
  --allowedTools "Bash(npm test *),Read" \
  --output-format json \
  --max-budget-usd 1.00
```

---

## Level 11: Git Worktree

### Worktree란?
하나의 git 저장소에서 여러 브랜치를 동시에 작업할 수 있는 격리된 작업 공간.
Claude 세션마다 독립된 파일 시스템을 제공한다.

### 사용법
```bash
claude --worktree feature-auth    # 이름 지정
claude -w bugfix-123              # 축약
claude --worktree                 # 자동 이름 생성
```

### 위치와 브랜치
- 생성 위치: `<repo>/.claude/worktrees/<name>`
- 브랜치명: `worktree-<name>`
- 기본 원격 브랜치에서 분기

### 정리
- **변경 없음**: 종료 시 worktree와 브랜치 자동 삭제
- **변경 있음**: keep/remove 선택 프롬프트

### Worktree 간 설정 공유
같은 저장소에서 생성된 worktree들은 프로젝트 설정과 메모리를 공유한다:
- `.claude/settings.json`, `.claude/rules/`, CLAUDE.md → 메인 저장소 것을 참조
- 자동 메모리(`~/.claude/projects/`)도 동일 프로젝트로 인식되어 공유됨
- 단, `CLAUDE.local.md`는 경로 기반이므로 worktree에 별도 생성 필요

### 서브에이전트 Worktree
에이전트 정의에서 격리 실행 가능:
```yaml
isolation: worktree
```
→ 각 서브에이전트가 독립 worktree에서 작업

### tmux와 함께 사용
```bash
claude --worktree feature --tmux   # worktree + tmux 세션 생성
```

---

## Level 12: IDE 연동

### VS Code 확장

**설치:** Extensions에서 "Claude Code" 검색

**주요 단축키:**
| 단축키 | 동작 |
|--------|------|
| `Cmd+Esc` | Claude ↔ 에디터 포커스 전환 |
| `Cmd+Shift+Esc` | 새 대화 탭 |
| `Cmd+N` | 새 대화 (Claude 포커스 시) |
| `Option+K` | 현재 선택 영역 @-멘션 삽입 |

**기능:**
- 인라인 diff (수락/거부)
- `@`-멘션 파일 참조 + 라인 범위 (`@file.ts#5-10`)
- 복수 대화 탭/창
- 플랜 모드, 자동 승인 모드
- Chrome 브라우저 연동 (`@browser`)

### JetBrains 플러그인

**지원 IDE:** IntelliJ, PyCharm, WebStorm, GoLand, PhpStorm, Android Studio

**설치:** JetBrains Marketplace에서 "Claude Code" 검색

**주요 단축키:**
| 단축키 | 동작 |
|--------|------|
| `Cmd+Esc` | Claude Code 열기 |
| `Cmd+Option+K` | 파일 레퍼런스 삽입 |

**기능:**
- IDE 네이티브 diff 뷰어
- 선택 영역 컨텍스트 공유
- 진단 정보(린트, 구문 오류) 공유

---

## Level 13: 커스텀 에이전트와 스킬

### 커스텀 에이전트
`.claude/agents/`에 전용 에이전트를 정의할 수 있다:

```markdown
<!-- .claude/agents/reviewer.md -->
---
name: reviewer
description: 코드 리뷰 전문 에이전트
model: sonnet
allowed-tools: Read, Grep, Glob
permission-mode: plan
---
당신은 코드 리뷰 전문가입니다.
보안 취약점, 성능 이슈, 코드 스타일 위반을 찾아주세요.
```

**관리:** `/agents`로 생성, 편집, 목록 확인

**사용:**
```bash
claude --agent reviewer "src/ 디렉토리를 리뷰해줘"
```

### 스킬 (커스텀 슬래시 커맨드)
`~/.claude/skills/` (개인) 또는 `.claude/skills/` (프로젝트)에 정의:

```markdown
<!-- .claude/skills/deploy/SKILL.md -->
---
name: deploy
description: 프로덕션 배포 수행
user-invocable: true
allowed-tools: Bash, Read
argument-hint: <environment>
---
$ARGUMENTS 환경으로 배포를 수행합니다:
1. 테스트 실행
2. 빌드
3. 배포
```

→ `/deploy production`으로 호출 가능

**프론트매터 옵션:**
| 키 | 설명 |
|----|------|
| `name` | 스킬 이름 |
| `description` | 설명 |
| `user-invocable` | 사용자가 직접 호출 가능 |
| `allowed-tools` | 허용 도구 |
| `model` | 사용할 모델 |
| `context` | `fork`면 서브에이전트에서 실행 |
| `agent` | 실행할 에이전트 |
| `argument-hint` | 인수 힌트 표시 |

**`--add-dir`와 스킬 자동 로드:**
`claude --add-dir ../other-project`로 추가한 디렉토리에 `.claude/skills/`가 있으면 해당 스킬도 자동으로 로드된다. 여러 프로젝트의 스킬을 한 세션에서 사용 가능.

**동적 컨텍스트:**
```markdown
현재 브랜치: !`git branch --show-current`
최근 커밋: !`git log --oneline -5`
```
→ `!`backtick`` 안의 명령어가 실행되어 결과가 주입됨

**문자열 치환:** `$ARGUMENTS`, `$ARGUMENTS[0]`, `$0`, `${CLAUDE_SESSION_ID}`

---

## Level 14: Agent Teams

### 개요
여러 Claude Code 인스턴스가 공유 태스크 리스트로 협업하는 시스템.

**활성화:**
```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

### 구조
```
Lead Agent (리더)
├── Teammate 1 (실행자)
├── Teammate 2 (실행자)
└── Teammate 3 (실행자)
    └── 공유 태스크 리스트
```

- 리더가 태스크를 생성하고 팀원에게 분배
- 팀원은 독립적인 컨텍스트 윈도우를 가짐
- 공유 태스크 리스트와 메시징으로 소통

### 표시 모드
| 모드 | 설명 |
|------|------|
| `in-process` | 메인 프로세스 내에서 표시 |
| `tmux` | tmux 분할 패널에서 표시 |
| `auto` | 환경에 따라 자동 선택 |

### 관련 Hook 이벤트
- `TeammateIdle`: 팀원 유휴 시
- `TaskCompleted`: 태스크 완료 시

---

## Level 15: 플러그인 생태계

### 플러그인이란?
스킬, 에이전트, Hook, MCP 서버, LSP 서버를 하나로 묶은 패키지.

### 관리
```bash
# VS Code에서
/plugins           # 플러그인 매니저

# CLI에서
claude plugin list
claude plugin install <url-or-name>
```

### 플러그인 소스
- GitHub 리포지토리
- Git URL
- NPM 패키지
- 공식 Anthropic 마켓플레이스

### 현재 설정된 플러그인
```json
{
  "enabledPlugins": {
    "oh-my-claudecode@omc": true,      // 멀티에이전트 오케스트레이션
    "superpowers@claude-plugins-official": true  // 워크플로 스킬 모음
  }
}
```

---

## 심화 복습: 종합 실습

### 실습 1: 완전한 프로젝트 셋업
```
1. git init
2. CLAUDE.md 작성 (프로젝트 규칙)
3. .claude/rules/ 에 모듈별 규칙
4. .claude/settings.json 에 팀 권한
5. .mcp.json 에 MCP 서버
6. .claude/agents/ 에 커스텀 에이전트
7. .claude/skills/ 에 커스텀 스킬
8. hooks 설정 (자동 포매팅, 알림)
9. .gitignore (local 파일 제외)
```

### 실습 2: Headless 파이프라인
```bash
# 코드 분석 → 리뷰 → 수정 → 테스트 파이프라인
claude -p "코드 분석" --output-format json | \
  claude -p "리뷰 결과 기반으로 수정" --allowedTools "Edit" | \
  claude -p "테스트 실행" --allowedTools "Bash(npm test)"
```

### 실습 3: Agent Teams로 병렬 작업
```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
claude --worktree feature-x
# 세션 내에서 여러 팀원에게 독립 태스크 분배
```

### 실습 4: Hook 고급 활용
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "prompt",
        "prompt": "이 bash 명령어가 위험한지 평가해주세요. 파일 삭제나 시스템 변경이 있으면 차단하세요."
      }]
    }]
  }
}
```

---

## Level 20: 프롬프트 엔지니어링

### 효과적인 프롬프트 패턴
- **구체적 지시**: "이 코드 고쳐줘" → "auth.ts의 validateToken 함수에서 만료 검증 로직 버그를 수정해줘"
- **맥락 제공**: `@파일명`으로 관련 파일 참조, 관련 코드 직접 포함
- **단계적 분해**: 큰 작업을 3~5단계로 나누어 요청
- **출력 형식 지정**: "JSON으로", "마크다운 테이블로" 등 원하는 형식 명시

### Claude Code 워크플로
```
탐색 → 계획 → 실행 → 검증
1. /plan 모드로 코드베이스 파악
2. 변경 계획 수립 및 검토
3. 실행 모드로 전환하여 구현
4. 테스트와 리뷰로 결과 검증
```

### 안티패턴
- 너무 모호한 지시 ("이거 좀 나아지게 해줘")
- 한 번에 10개 이상 수정 요청
- 맥락 없이 "버그 수정해줘"
- CLAUDE.md에 넣을 규칙을 매번 반복 입력

---

## Level 21: 비용 최적화

### 비용 모니터링
```bash
/cost        # 토큰 사용량 확인
/context     # 컨텍스트 사용량 시각화
```

### 비용 절약 핵심 전략
1. 적절한 모델 선택: 단순=Haiku, 일반=Sonnet, 복잡=Opus
2. effortLevel 조절: `--effort low` (단순), `medium` (일반), `high` (복잡)
3. 컨텍스트 관리: 70% 초과 시 `/compact`, 새 주제면 새 세션
4. 불필요한 파일 읽기 방지: `--tools "Read,Glob,Grep"`으로 제한
5. Extended Thinking 선택적 사용: 단순 작업에는 비활성화
6. `--max-budget-usd`로 예산 제한
7. `--max-turns`로 턴 수 제한
8. 서브에이전트 활용: 독립적 작업은 병렬 서브에이전트로 분산
9. Hook으로 불필요한 작업 차단
10. CLAUDE.md 간결하게 유지 (100줄 이하)

---

## Level 22: 보안 베스트 프랙티스

### 권한 모드 보안 수준
| 모드 | 보안 수준 | 적합한 상황 |
|------|-----------|------------|
| `default` | 최고 | 민감한 프로덕션 코드 |
| `plan` | 높음 | 탐색 및 계획 단계 |
| `acceptEdits` | 중간 | 일반 개발 |
| `bypassPermissions` | 없음 | 절대 프로덕션에서 사용 금지 |

### 보안 체크리스트
```
□ deny 규칙으로 .env, credentials 파일 접근 차단
□ Bash 도구에 패턴 제한 적용
□ WebFetch 허용 도메인 제한
□ PreToolUse Hook으로 위험 명령 감지
□ CI/CD에서 --max-budget-usd 설정
□ API 키는 환경변수로만 전달
□ managed-settings.json으로 팀 권한 강제
□ Sandbox 활성화 고려
□ 감사 로그 Hook 설정
□ 정기적인 권한 규칙 리뷰
```

---

## Level 23: 비코딩 활용

### 주요 활용 영역
- **문서화**: README, API 문서, CHANGELOG, 기술 블로그 초안
- **데이터 분석**: CSV/JSON 데이터, 서버 로그, 패턴 추출
- **프로젝트 관리**: PR 설명 작성, 이슈 분류, 마이그레이션 계획
- **학습**: 새 코드베이스 파악, 기술 개념 설명, 아키텍처 이해
- **시스템 관리**: Docker/K8s 설정, CI/CD 파이프라인, 쉘 스크립트
- **커뮤니케이션**: 기술 제안서, 회의록 정리, 이메일 작성

### 실습 프롬프트 예시
```bash
# README 자동 생성
claude -p "이 프로젝트의 README.md를 작성해줘. 설치, 사용법, API 참조 포함"

# 로그 분석
claude -p "server.log에서 에러 패턴을 분석하고 가장 빈번한 에러 Top 5를 알려줘"

# PR 설명 작성
claude -p "현재 브랜치의 변경사항으로 PR 설명을 작성해줘"
```

---

## 빠른 참조 카드

### 필수 CLI 옵션
```bash
claude                          # 대화형 시작
claude -p "query"               # 비대화형
claude -c                       # 최근 세션 이어하기
claude -r name                  # 이름으로 세션 재개
claude -w name                  # worktree 격리 세션
claude --model opus             # 모델 지정
claude --effort low             # 노력 수준
claude --permission-mode plan   # 권한 모드
claude mcp list                 # MCP 서버 목록
claude agents                   # 에이전트 목록
claude doctor                   # 설치 진단
claude security scan            # 보안 취약점 스캔
```

### 필수 슬래시 커맨드
```
/model    /fast     /plan      /compact
/cost     /context  /status    /resume
/mcp      /memory   /rewind    /clear
```

### 필수 단축키
```
Ctrl+C      취소          Shift+Tab   권한 모드 순환
Ctrl+D      종료          Alt+P       모델 전환
Esc Esc     되감기        Alt+T       확장 사고 토글
\+Enter     멀티라인      Ctrl+T      태스크 리스트
```

### 프롬프트 팁
```
구체적으로 지시      → "auth.ts의 validateToken 함수 수정"이 "버그 고쳐줘"보다 좋음
맥락 제공           → @파일명 또는 관련 코드 직접 포함
단계적 분해         → 큰 작업을 3~5단계로 나누어 요청
출력 형식 명시      → "JSON으로", "테이블로" 등 지정
CLAUDE.md 활용     → 반복 지시 대신 규칙 파일에 고정
/plan 먼저         → 탐색 → 계획 → 실행 → 검증 순서로
```

### 비용 최적화 팁
```
/cost 확인          → 토큰 사용량 모니터링
모델 선택           → 단순=Haiku, 일반=Sonnet, 복잡=Opus
--effort low        → 단순 수정에는 낮은 노력 수준
/compact            → 컨텍스트 70% 초과 시 압축
--max-budget-usd    → 예산 상한 설정
--max-turns         → 턴 수 제한
새 세션             → 주제 전환 시 새 세션 시작
```

### 파일 구조 참조
```
~/.claude/
├── CLAUDE.md              # 전역 개인 지시사항
├── settings.json          # 전역 개인 설정
├── keybindings.json       # 키바인딩
├── rules/*.md             # 전역 개인 규칙
├── skills/*/SKILL.md      # 개인 스킬
└── projects/<name>/memory/ # 자동 메모리

프로젝트/
├── CLAUDE.md              # 팀 공유 지시사항
├── CLAUDE.local.md        # 개인 프로젝트 지시사항
├── .mcp.json              # 팀 공유 MCP 설정
├── .claude/
│   ├── settings.json      # 팀 공유 설정
│   ├── settings.local.json # 개인 프로젝트 설정
│   ├── rules/*.md         # 팀 공유 규칙
│   ├── agents/*.md        # 커스텀 에이전트
│   └── skills/*/SKILL.md  # 프로젝트 스킬
└── .gitignore             # CLAUDE.local.md, settings.local.json 제외
```

---

## roadmap.sh 커버리지 매핑

> [roadmap.sh/r/claude-code](https://roadmap.sh/r/claude-code) 로드맵 토픽과 우리 커리큘럼의 대응 관계

| roadmap.sh 토픽 | 대응 레벨 | 커버리지 |
|-----------------|-----------|---------|
| What is vibe coding? | Level 1 | ✅ Full |
| What is a code agent? | Level 1 | ✅ Full |
| Install Claude Code | Level 1 | ✅ Full |
| Configure Claude Code | Level 2, 3 | ✅ Full |
| CLAUDE.md Files | Level 2 | ✅ Full |
| settings.json | Level 3 | ✅ Full |
| Permission Modes | Level 3, 22 | ✅ Full |
| Slash Commands | Level 4 | ✅ Full |
| Keyboard Shortcuts | Level 5 | ✅ Full |
| Model Selection | Level 6 | ✅ Full |
| Hooks | Level 7 | ✅ Full |
| MCP Servers | Level 8 | ✅ Full |
| Context Management | Level 9 | ✅ Full |
| SDK / Headless Mode | Level 10 | ✅ Full |
| Output Styles | Level 10 | ✅ Full |
| Git Worktree | Level 11 | ✅ Full |
| IDE Integration | Level 12 | ✅ Full |
| Custom Agents & Skills | Level 13 | ✅ Full |
| Agent Teams | Level 14 | ✅ Full |
| Multiple Claude | Level 14 | ✅ Full |
| Claude Cowork | Level 14 | ✅ Full |
| Plugins | Level 15 | ✅ Full |
| Sandbox | Level 17 | ✅ Full |
| Advanced CLI | Level 18 | ✅ Full |
| Plan Mode | Level 18 | ✅ Full |
| Large Codebase | Level 19 | ✅ Full |
| Scaling Claude | Level 19 | ✅ Full |
| Prompting Best Practices | Level 20 | ✅ Full |
| Claude Workflow | Level 20 | ✅ Full |
| Understand Pricing | Level 21 | ✅ Full |
| Reduce Token Usage | Level 21 | ✅ Full |
| Manage Context Window | Level 9, 21 | ✅ Full |
| Thinking Mode | Level 21 | ✅ Full |
| Use /compact | Level 19, 21 | ✅ Full |
| Subagents and Hooks | Level 7, 21 | ✅ Full |
| Security Best Practices | Level 22 | ✅ Full |
| Non-coding Tasks | Level 23 | ✅ Full |

**커버리지: 37/37 토픽 (100%)**

---

> **출처:**
> - [Claude Code 공식 문서](https://code.claude.com/docs)
> - [Claude Code GitHub](https://github.com/anthropics/claude-code)
> - [Claude Code Changelog](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)
