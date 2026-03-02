# Claude Code 업데이트 학습 (2026-02-27 → 2026-03-02)

> 기존 학습(Level 1~15)을 기반으로, 5일간의 변경 사항을 체계적으로 학습

---

## 학습 진행 체크리스트

- [x] Step 1: HTTP Hook — 외부 서비스 연동의 새로운 방법
- [x] Step 2: 계정 환경 변수 — Hook에서 "누가" 실행했는지 알기
- [x] Step 3: 슬래시 커맨드 변경점 — `/clear`, `/copy`, `/simplify`
- [x] Step 4: MCP 서버 제어 — 원격 MCP 비활성화
- [x] Step 5: 세션 관리 개선 — 부분 요약 기능
- [x] Step 6: Worktree 설정 공유 + `--add-dir` 스킬 로드
- [x] Step 7: CLI 보안 스캔
- [x] Step 8: 학습 가이드 최신화 + 복습

---

## Step 1: HTTP Hook — 외부 서비스 연동의 새로운 방법

### 연결 포인트
Level 7에서 Hook 타입 3가지(command, prompt, agent)를 배웠다.
여기에 **4번째 타입 `http`**가 추가됐다.

### 왜 필요한가?
기존 command Hook으로 외부 서비스에 알림을 보내려면 이렇게 해야 했다:
```json
{
  "type": "command",
  "command": "curl -X POST https://hooks.slack.com/... -d '{\"text\": \"완료\"}'"
}
```
→ curl 설치 필요, 에러 처리 어려움, 보안 문제(API 키 노출 위험)

HTTP Hook은 이걸 네이티브로 해결한다:
```json
{
  "type": "http",
  "url": "https://hooks.slack.com/services/XXX",
  "method": "POST",
  "headers": {
    "Authorization": "Bearer ${WEBHOOK_TOKEN}"
  },
  "timeout": 5000
}
```

### 핵심 개념: allowedDomains (보안)
HTTP Hook은 아무 URL이나 호출할 수 없다. 반드시 허용 도메인을 명시해야 한다:
```json
{
  "hooks": {
    "allowedDomains": ["hooks.slack.com", "my-server.example.com"],
    "Stop": [
      {
        "hooks": [
          {
            "type": "http",
            "url": "https://hooks.slack.com/services/XXX"
          }
        ]
      }
    ]
  }
}
```
→ `allowedDomains`에 없는 도메인은 차단됨. 와일드카드 불가.

### 실습
`experiments/update-2026-03-02/http-hook-01.json` 으로 예시 설정 파일을 만들어본다.

### 이해 확인
- command Hook 대비 HTTP Hook의 장점은?
- allowedDomains가 왜 필요한가?
- 어떤 이벤트에 HTTP Hook을 걸면 유용할까?

---

## Step 2: 계정 환경 변수 — Hook에서 "누가" 실행했는지 알기

### 연결 포인트
Level 3에서 환경 변수(`ANTHROPIC_API_KEY`, `ANTHROPIC_MODEL` 등)를 배웠다.
새로 3개가 추가됐다.

### 새 환경 변수

| 변수 | 용도 | 활용 예시 |
|------|------|-----------|
| `CLAUDE_CODE_ACCOUNT_UUID` | 로그인 계정 UUID | Hook에서 사용자별 로깅 |
| `CLAUDE_CODE_USER_EMAIL` | 로그인 이메일 | 알림에 "누가" 실행했는지 포함 |
| `CLAUDE_CODE_ORGANIZATION_UUID` | 소속 조직 UUID | 조직별 정책 분기 |

### 왜 필요한가?
팀 환경에서 여러 사람이 Claude Code를 쓸 때, Hook이나 스크립트에서
"이 작업을 누가 실행했는지" 알 수 있어야 한다.

예: Step 1의 HTTP Hook과 결합
```json
{
  "type": "command",
  "command": "echo '{\"user\": \"'$CLAUDE_CODE_USER_EMAIL'\", \"event\": \"deploy\"}' | curl -X POST -d @- https://my-server.example.com/log"
}
```

### 실습
현재 세션에서 이 환경 변수들이 설정되어 있는지 확인해본다.

### 이해 확인
- 이 변수들은 어디서 자동 설정되는가?
- Step 1의 HTTP Hook에서 이 변수를 어떻게 활용할 수 있는가?

---

## Step 3: 슬래시 커맨드 변경점

### 연결 포인트
Level 4에서 전체 슬래시 커맨드 목록을 배웠다.

### 변경 사항 3가지

**1) `/clear` — 캐시된 스킬도 리셋**
기존: 대화 초기화(세션은 유지)
변경: 캐시된 스킬도 함께 리셋됨
→ 스킬 파일을 수정한 뒤 반영이 안 될 때 `/clear` 하면 해결

**2) `/copy` — 코드 블록 선택 피커**
기존: 마지막 응답 전체를 클립보드에 복사
변경: 응답 안의 특정 코드 블록을 골라서 복사 가능
→ 긴 응답에서 원하는 코드만 뽑을 때 유용

**3) `/simplify` — 새 커맨드 추가**
최근 변경한 코드를 자동으로 간결하게 리팩토링
→ 복잡해진 코드를 정리할 때 `/simplify` 한 번이면 됨

### 실습
각 커맨드를 실제로 사용해본다.

### 이해 확인
- `/clear`와 `/compact`의 차이는? (Level 4 복습)
- `/simplify`는 어떤 상황에서 쓰면 좋을까?

---

## Step 4: MCP 서버 제어 — 원격 MCP 비활성화

### 연결 포인트
Level 8에서 MCP 서버의 범위(local, project, user)를 배웠다.

### 새 기능
Claude.ai가 자동으로 제공하는 원격 MCP 서버(Notion, Linear 등)를 끌 수 있다:
```bash
export ENABLE_CLAUDEAI_MCP_SERVERS=false
```

### 왜 필요한가?
- 보안: 외부 서비스 연결을 차단하고 싶을 때
- 성능: 불필요한 MCP 서버 로딩을 줄일 때
- 제어: 로컬 MCP 서버만 사용하고 싶을 때

### 이해 확인
- 이 설정은 `.mcp.json`에 직접 추가한 서버에도 영향을 주는가?
- 어떤 환경에서 이 설정을 쓰면 좋을까?

---

## Step 5: 세션 관리 개선 — 부분 요약

### 연결 포인트
Level 9에서 자동 압축과 `/compact`를 배웠다.

### 새 기능: "Summarize from here"
긴 대화에서 특정 메시지 시점부터만 요약할 수 있다:
- 대화 중 원하는 메시지에서 "Summarize from here" 선택
- 해당 시점 이후의 대화만 요약
- 이전 맥락은 그대로 유지

### 기존 방식과 비교

| 방식 | 동작 | 용도 |
|------|------|------|
| 자동 압축 | 전체 대화 요약 | 컨텍스트 가득 찼을 때 |
| `/compact` | 전체 대화 요약 (수동) | 원하는 시점에 압축 |
| `/compact [지시]` | 특정 주제 포커스 요약 | 관련 없는 내용 제거 |
| Summarize from here | 특정 시점 이후만 요약 | 앞부분은 보존하고 싶을 때 |

### 이해 확인
- `/compact API 관련 유지`와 "Summarize from here"는 어떻게 다른가?

---

## Step 6: Worktree 설정 공유 + --add-dir 스킬 로드

### 연결 포인트
Level 11(Worktree)과 Level 13(스킬)의 확장.

### 6-1: Worktree 간 설정 공유
같은 저장소의 worktree들은 설정과 메모리를 공유한다:
- `.claude/settings.json`, `.claude/rules/`, `CLAUDE.md` → 메인 저장소 참조
- 자동 메모리도 동일 프로젝트로 인식

→ worktree마다 설정을 따로 만들 필요 없음

### 6-2: --add-dir 스킬 자동 로드
`claude --add-dir ../other-project`로 추가한 디렉토리에
`.claude/skills/`가 있으면 해당 스킬도 자동 로드된다.

→ 여러 프로젝트의 스킬을 한 세션에서 사용 가능

### 이해 확인
- Worktree에서 `CLAUDE.local.md`도 공유되는가?
- `--add-dir`로 추가한 디렉토리의 에이전트도 로드되는가?

---

## Step 7: CLI 보안 스캔

### 새 CLI 옵션
```bash
claude security scan
```
프로젝트의 보안 취약점을 스캔한다.

### 실습
현재 프로젝트에서 실행해본다.

---

## Step 8: 학습 가이드 최신화 + 복습

Step 1~7 학습 완료 후:
1. `experiments/claude-code-study-guide.md`에 변경 사항 반영
2. 각 Level에 새 내용이 올바른 위치에 들어갔는지 확인
3. 전체 구조 검증
