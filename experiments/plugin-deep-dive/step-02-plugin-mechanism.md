# Step 2: 플러그인이 기능을 추가하는 3가지 방법

## 핵심 질문

> Step 1에서 "플러그인은 MCP, Hook, Skill로 기능을 추가한다"고 했다.
> 이 3가지가 정확히 뭔지, 어떻게 다른지 알아보자.

## 비유로 이해하기

식당에 비유하면:

| 방법 | 식당 비유 | 하는 일 |
|------|----------|---------|
| **MCP 서버** | 새 주방 기기 추가 | Claude에게 **새로운 도구**를 줌 |
| **Hook** | 주문이 들어올 때마다 자동으로 하는 일 | **이벤트가 발생하면** 코드를 자동 실행 |
| **Skill** | 요리사에게 주는 레시피북 | Claude에게 **작업 지침서**를 줌 |

핵심 차이: MCP는 "뭘 할 수 있게 해주고", Hook은 "언제 할지 정하고", Skill은 "어떻게 할지 알려준다".

---

## 1. MCP 서버 — 새로운 도구 추가

### MCP가 뭔가?

**Model Context Protocol**의 약자. Claude에게 새 도구를 추가하는 표준 규격이다.

Step 1에서 봤듯이, Claude Code 기본 도구로는 "코드의 타입 정보"를 볼 수 없었다. MCP 서버가 이걸 해결한다.

### 실제 예시

```
기본 Claude Code:
  "이 함수의 리턴 타입이 뭐야?" → Grep으로 코드 텍스트만 검색 가능 😢

OMC MCP 서버 추가 후:
  "이 함수의 리턴 타입이 뭐야?" → lsp_hover 도구로 정확한 타입 정보 확인 ✅
```

### OMC가 추가하는 MCP 도구들

| MCP 서버 | 제공하는 도구 | 기본 도구로 못하던 것 |
|----------|-------------|-------------------|
| `t` (메인 서버) | `lsp_hover`, `lsp_goto_definition`, `ast_grep_search`, `notepad_write`, `project_memory_read` 등 | 타입 정보, 구조적 코드 검색, 메모, 프로젝트 기억 |
| `team` (팀 서버) | `omc_run_team_start`, `omc_run_team_wait` 등 | 여러 CLI 에이전트를 팀으로 운영 |

### MCP 서버의 등록 방식

플러그인이 `.mcp.json` 파일에 서버를 정의한다:

```json
{
  "mcpServers": {
    "t": {
      "command": "node",
      "args": ["${CLAUDE_PLUGIN_ROOT}/bridge/mcp-server.cjs"]
    }
  }
}
```

→ Claude Code가 이 파일을 읽고, node 프로세스를 띄워서, 그 안의 도구들을 Claude에게 제공한다.

### 핵심 정리

```
MCP 서버 = 별도 프로세스로 실행되는 도구 서버
  - Claude Code가 시작할 때 같이 띄워짐
  - 프로세스가 살아있는 동안 도구 사용 가능
  - 표준 프로토콜이라 누구나 만들 수 있음
```

---

## 2. Hook — 이벤트 기반 자동 실행

### Hook이 뭔가?

**특정 이벤트가 발생할 때 자동으로 실행되는 코드**다.

Step 1에서 "autopilot 같은 키워드를 인식할 수 없다"고 했다. Hook이 이걸 해결한다.

### 실제 예시

```
기본 Claude Code:
  사용자: "autopilot으로 해줘"
  Claude: "autopilot이 뭔지 모릅니다" 😢

OMC Hook 추가 후:
  사용자: "autopilot으로 해줘"
  → [UserPromptSubmit 이벤트 발생]
  → [keyword-detector.mjs 자동 실행]
  → ["autopilot" 키워드 감지!]
  → [autopilot 모드 활성화] ✅
```

### Hook 이벤트 종류

사용자의 행동마다 이벤트가 발생하고, Hook이 거기에 반응한다:

| 이벤트 | 언제 발생하나 | 어디에 활용되나 |
|--------|-------------|---------------|
| `SessionStart` | Claude Code 시작할 때 | 환경 초기화, 스킬 목록 주입 |
| `UserPromptSubmit` | 사용자가 메시지 보낼 때 | 키워드 감지, 스킬 매칭 |
| `PreToolUse` | 도구 실행 직전 | 권한 체크, 실행 조건 확인 |
| `PostToolUse` | 도구 실행 직후 | 결과 검증, 추가 컨텍스트 주입 |
| `Stop` | Claude가 응답 끝낼 때 | 작업 완료 여부 판단 |
| `SessionEnd` | 세션 종료할 때 | 상태 정리, 로그 저장 |

### Hook의 등록 방식

플러그인이 `hooks/hooks.json` 파일에 정의한다:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "node \"${CLAUDE_PLUGIN_ROOT}/scripts/keyword-detector.mjs\"",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

→ "사용자가 메시지 보낼 때마다(`UserPromptSubmit`), `keyword-detector.mjs`를 실행해라"

### 핵심 정리

```
Hook = 이벤트 → 자동 실행 코드
  - 이벤트 종류마다 다른 Hook 등록 가능
  - 스크립트 실행 결과를 Claude 컨텍스트에 주입 가능
  - 타임아웃이 있음 (보통 3~10초)
```

---

## 3. Skill — 작업 지침서

### Skill이 뭔가?

**Claude에게 "이렇게 작업해라"라고 알려주는 마크다운 문서**다.

Step 1에서 "Claude는 시키는 대로만 한다"고 했다. Skill이 "어떻게 시킬지"를 자동으로 주입한다.

### 실제 예시

```
기본 Claude Code:
  사용자: "이 버그 수정해줘"
  Claude: 바로 코드 수정 시작 (테스트 없이) 😢

TDD Skill 추가 후:
  사용자: "이 버그 수정해줘"
  → [Skill이 컨텍스트에 주입됨: "테스트 먼저 작성하라"]
  Claude: 1) 실패하는 테스트 작성 → 2) 코드 수정 → 3) 테스트 통과 확인 ✅
```

### Skill 파일의 구조

스킬은 그냥 **마크다운 파일 + YAML 헤더**다:

```markdown
---
name: test-driven-development
description: 기능 구현이나 버그 수정 전에 사용
---

# Test-Driven Development (TDD)

## 핵심 원칙
테스트를 먼저 작성하라. 실패하는 것을 확인하라.
최소한의 코드로 통과시켜라.

## 단계
1. RED: 실패하는 테스트 작성
2. GREEN: 최소 코드로 통과
3. REFACTOR: 코드 정리
```

### Skill은 어떻게 Claude에게 전달되나?

1. 사용자가 메시지를 보냄
2. `UserPromptSubmit` Hook이 발동
3. `skill-injector.mjs`가 실행됨
4. 사용자 메시지와 매칭되는 Skill을 찾음
5. Skill 내용을 `<system-reminder>` 태그로 Claude 컨텍스트에 주입

→ Claude 입장에서는 **시스템 지시에 추가 규칙이 생긴 것**과 같다.

### 두 플러그인의 Skill 비교

| | OMC 스킬 (32개) | Superpowers 스킬 (16개) |
|---|---|---|
| **성격** | 실행 모드 (autopilot, ralph, team 등) | 작업 규율 (TDD, 디버깅, 코드 리뷰 등) |
| **예시** | "autopilot으로 빌드해줘" → 자율 실행 모드 | "버그 수정해줘" → 체계적 디버깅 프로세스 |
| **주 용도** | 에이전트 오케스트레이션 | 개발 모범 사례 강제 |

---

## 3가지의 관계

```
사용자 메시지 입력
       │
       ▼
    [Hook] ← 이벤트 감지, 키워드 매칭, 스킬 주입
       │
       ├──→ Skill 주입 ← Claude에게 "이렇게 해라" 지시
       │
       ▼
    Claude가 작업 수행
       │
       ├──→ 기본 도구 사용 (Read, Write, Bash...)
       └──→ [MCP 도구] 사용 (lsp_hover, ast_grep...)
```

**Hook이 Skill을 주입**하고, Claude가 Skill의 지시에 따라 **MCP 도구를 포함한 도구들을 사용**한다.
세 가지는 독립적이지만 함께 동작할 때 시너지가 난다.

---

## Step 1 → Step 2 연결

| Step 1에서 배운 것 | Step 2에서 알게 된 것 |
|-------------------|---------------------|
| 기본 도구는 9개 | MCP로 도구를 무한히 확장 가능 |
| LSP 정보를 볼 수 없다 | MCP 서버가 LSP 도구를 제공한다 |
| 키워드 인식이 안 된다 | Hook이 이벤트마다 자동 실행으로 감지한다 |
| Claude는 시키는 대로만 한다 | Skill이 "어떻게 시킬지"를 자동 주입한다 |

---

## 확인 질문

1. MCP, Hook, Skill 중 "새로운 도구"를 추가하는 건 뭔가?
2. "사용자가 메시지를 보낼 때마다 실행되는 코드"는 어떤 메커니즘인가?
3. Skill은 실행 파일인가, 문서인가?
4. Hook과 Skill의 관계를 한 문장으로 설명하면?

→ 답:
1. MCP 서버
2. Hook (UserPromptSubmit 이벤트)
3. 문서 (마크다운 파일). 실행되는 게 아니라 컨텍스트에 주입됨
4. Hook이 Skill을 Claude의 컨텍스트에 주입한다

---

다음 단계: **Step 3 — 플러그인 파일 구조 — 어디에 뭐가 있나**
