# Step 3: 플러그인 파일 구조 — 어디에 뭐가 있나

## 핵심 질문

> Step 2에서 "MCP, Hook, Skill 3가지 방법으로 기능을 추가한다"고 했다.
> 그러면 실제 플러그인 폴더 안에는 파일이 어떻게 배치되어 있을까?

## 플러그인이 설치되는 위치

모든 플러그인은 이 경로에 저장된다:

```
~/.claude/plugins/cache/<소스>/<플러그인명>/<버전>/
```

현재 설치된 두 플러그인:

| 플러그인 | 경로 |
|----------|------|
| **Superpowers** | `~/.claude/plugins/cache/claude-plugins-official/superpowers/4.3.1/` |
| **OMC** | `~/.claude/plugins/cache/omc/oh-my-claudecode/4.5.1/` |

→ `settings.json`의 `enabledPlugins`에 등록되면 Claude Code가 시작할 때 자동으로 로드한다.

---

## Superpowers — 단순한 구조부터

### 전체 디렉토리

```
superpowers/4.3.1/
├── .claude-plugin/
│   └── plugin.json          ← 플러그인 메타데이터 (이름, 버전, 설명)
├── hooks/
│   ├── hooks.json           ← Hook 등록 (딱 1개: SessionStart)
│   ├── run-hook.cmd          ← Hook 실행 스크립트
│   └── session-start/        ← 세션 시작 시 초기화 로직
├── skills/                   ← 스킬 14개
│   ├── brainstorming/SKILL.md
│   ├── test-driven-development/SKILL.md
│   ├── systematic-debugging/SKILL.md
│   ├── verification-before-completion/SKILL.md
│   ├── writing-plans/SKILL.md
│   ├── executing-plans/SKILL.md
│   ├── ... (14개)
│   └── using-superpowers/SKILL.md   ← 진입점 스킬
├── agents/
│   └── code-reviewer.md     ← 에이전트 1개
├── commands/                 ← 커맨드 3개
│   ├── brainstorm.md
│   ├── write-plan.md
│   └── execute-plan.md
├── lib/
│   └── skills-core.js       ← 스킬 로딩 유틸리티
└── tests/                    ← 테스트 42개
```

### 규모

| 항목 | 수량 |
|------|------|
| 전체 파일 | ~131개 |
| 스킬 | 14개 |
| 에이전트 | 1개 |
| Hook 이벤트 | 1개 (SessionStart) |
| MCP 서버 | 0개 |

### 핵심 포인트

```
Superpowers = 스킬 라이브러리
  - 거의 전부 마크다운 문서 (SKILL.md)
  - Hook은 세션 시작 시 스킬 목록 주입용 1개만
  - MCP 서버 없음 → 새 도구를 추가하지 않음
  - Claude의 "작업 방식"을 바꾸는 데 집중
```

---

## OMC — 복잡한 구조

### 전체 디렉토리

```
oh-my-claudecode/4.5.1/
├── .claude-plugin/
│   ├── plugin.json          ← 플러그인 메타데이터 + MCP 서버 등록
│   └── marketplace.json
├── src/                      ← TypeScript 소스 (365개 파일, 5.7MB)
│   ├── agents/               ← 에이전트 정의 (18파일)
│   │   ├── definitions.ts    ← 에이전트 레지스트리
│   │   ├── executor.ts
│   │   ├── architect.ts
│   │   ├── debugger.ts
│   │   └── ...
│   ├── hooks/                ← Hook 구현 (36개 모듈, 150+ 파일)
│   │   ├── keyword-detector/ ← 키워드 감지
│   │   ├── autopilot/        ← 자율 실행 상태 머신
│   │   ├── persistent-mode/  ← ralph/ultrawork
│   │   ├── team-pipeline/    ← 멀티에이전트 팀
│   │   ├── learner/          ← 자동 학습
│   │   ├── project-memory/   ← 프로젝트 기억
│   │   └── ...
│   ├── tools/                ← MCP 도구 구현 (30+ 파일)
│   │   ├── lsp-tools.ts      ← LSP 연동
│   │   ├── ast-tools.ts      ← AST 검색/치환
│   │   ├── notepad-tools.ts  ← 메모장
│   │   ├── state-tools.ts    ← 상태 관리
│   │   └── python-repl/      ← Python REPL
│   ├── mcp/                  ← MCP 서버 (14파일)
│   │   ├── omc-tools-server.ts
│   │   └── team-server.ts
│   ├── features/             ← 핵심 기능 (18+ 모듈)
│   │   ├── model-routing/    ← 모델 라우팅
│   │   ├── delegation-routing/
│   │   └── state-manager/
│   └── skills/               ← 스킬 (38개 디렉토리)
├── bridge/                   ← MCP 서버 브릿지 (실행 진입점)
│   ├── mcp-server.cjs        ← 메인 MCP 서버
│   ├── team-mcp.cjs          ← 팀 MCP 서버
│   └── runtime-cli.cjs       ← CLI 워커 런타임
├── hooks/
│   └── hooks.json            ← Hook 이벤트 등록
├── dist/                     ← 컴파일된 JS 출력
└── templates/                ← Hook/규칙 템플릿
```

### 규모

| 항목 | 수량 |
|------|------|
| 전체 파일 | ~3,479개 |
| 스킬 | 38개 |
| 에이전트 | 22개+ |
| Hook 이벤트 | 9개 타입 (36개 구현 모듈) |
| MCP 서버 | 2개 (`t`, `team`) |
| MCP 도구 | 30개+ |
| TypeScript 소스 | 365개 (5.7MB) |

### OMC의 6개 핵심 디렉토리

```
src/agents/     → "누가" 일하는가  (executor, architect, debugger...)
src/hooks/      → "언제" 발동하는가 (키워드 감지, 상태 추적...)
src/tools/      → "무엇을" 할 수 있는가 (LSP, AST, 메모...)
src/skills/     → "어떻게" 작업하는가 (autopilot, ralph, team...)
src/mcp/        → "도구를 어떻게" 전달하는가 (MCP 프로토콜)
src/features/   → "내부 로직" (모델 라우팅, 위임 규칙, 상태 관리)
```

---

## 나란히 비교

### 구조 비교

| | Superpowers | OMC |
|---|---|---|
| **정체** | 스킬 라이브러리 | 오케스트레이션 플랫폼 |
| **파일 수** | 131 | 3,479 (26배) |
| **언어** | JS + 마크다운 | TypeScript + 마크다운 |
| **빌드** | 없음 (직접 실행) | 있음 (src → dist 컴파일) |
| **스킬** | 14 | 38 (2.7배) |
| **에이전트** | 1 | 22+ (22배) |
| **Hook** | 1 이벤트 | 9 이벤트, 36 모듈 |
| **MCP** | 없음 | 2개 서버, 30+ 도구 |

### 역할 비교

```
Superpowers가 하는 일:
  "버그 수정해줘" → TDD 스킬 주입 → Claude가 테스트 먼저 작성
  → Claude의 "행동 습관"을 바꿈

OMC가 하는 일:
  "autopilot으로 빌드해줘" → 키워드 감지 → 상태 머신 시작
  → 에이전트 라우팅 → 도구 확장 → 팀 협업
  → Claude의 "능력과 작동 구조"를 바꿈
```

### 한 줄 요약

| 플러그인 | 한 줄 설명 |
|----------|-----------|
| **Superpowers** | Claude에게 **레시피북**을 준다 (작업 방법론) |
| **OMC** | Claude에게 **주방 전체**를 업그레이드한다 (도구+인력+자동화) |

---

## 중요 파일 3개씩

### Superpowers

| 파일 | 역할 | 왜 중요한가 |
|------|------|------------|
| `.claude-plugin/plugin.json` | 플러그인 등록 정보 | Claude Code가 이걸 읽고 플러그인을 인식 |
| `hooks/hooks.json` | Hook 등록 | SessionStart에 스킬 로더를 연결 |
| `skills/*/SKILL.md` | 스킬 본체 | 실제 Claude에게 주입되는 지시서 |

### OMC

| 파일 | 역할 | 왜 중요한가 |
|------|------|------------|
| `bridge/mcp-server.cjs` | MCP 서버 진입점 | 30+ 도구를 Claude에게 제공하는 게이트웨이 |
| `src/agents/definitions.ts` | 에이전트 레지스트리 | 22개 에이전트의 모델/역할 매핑 |
| `src/hooks/keyword-detector/` | 키워드 감지기 | 사용자 입력에서 스킬 트리거를 찾아내는 핵심 |

---

## Step 2 → Step 3 연결

| Step 2에서 배운 것 | Step 3에서 알게 된 것 |
|-------------------|---------------------|
| MCP로 도구를 추가한다 | OMC는 `src/tools/`에 30+ 도구, `bridge/`로 전달 |
| Hook으로 이벤트에 반응한다 | OMC는 9개 이벤트 × 36개 모듈, Superpowers는 1개 |
| Skill은 마크다운 문서다 | 둘 다 `skills/*/SKILL.md` 구조로 동일 |
| 3가지가 함께 동작한다 | OMC는 3가지를 모두 대규모로 활용, Superpowers는 Skill에 집중 |

---

## 확인 질문

1. 플러그인은 어느 경로에 설치되나?
2. Superpowers가 MCP 서버를 사용하지 않는 이유는?
3. OMC의 `bridge/mcp-server.cjs`는 무슨 역할을 하나?
4. 두 플러그인의 `skills/` 디렉토리 구조는 같은가, 다른가?
5. OMC의 `src/` 디렉토리 6개 핵심 폴더를 나열하면?

→ 답:
1. `~/.claude/plugins/cache/<소스>/<이름>/<버전>/`
2. 새 도구가 필요 없고, 기존 도구로 작업 방법론만 바꾸면 되니까
3. `src/tools/`의 30+ 도구를 MCP 프로토콜로 Claude에게 전달하는 게이트웨이
4. 같다. 둘 다 `skills/<이름>/SKILL.md` 구조
5. agents, hooks, tools, skills, mcp, features

---

다음 단계: **Step 4 — Hook 시스템 심화 — 이벤트, 타입, 실행 흐름**
