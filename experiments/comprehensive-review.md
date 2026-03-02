# 심화 복습: 종합 실습 — Level 1~15 총정리
> 목적: 전체 Level을 하나의 그림으로 연결하고 실전 활용 패턴 정리
> 날짜: 2026-03-02

## 1. 전체 아키텍처 맵

```
사용자
  │
  ▼
┌─────────────────────────────────────────────────┐
│  Claude Code CLI                                │
│                                                 │
│  [설정] L2 지시사항 + L3 설정 계층               │
│    → 매 세션 시작 시 자동 로드                    │
│                                                 │
│  [인터페이스] L1 CLI + L4 커맨드 + L5 단축키      │
│    + L10 SDK + L12 IDE                          │
│    → 사용자가 Claude에 접근하는 모든 경로          │
│                                                 │
│  [두뇌] L6 모델 제어                             │
│    → 작업 복잡도에 맞는 모델/노력 수준 선택        │
│                                                 │
│  [행동] L7 Hooks + L8 MCP                       │
│    → 자동화와 외부 서비스 연동                    │
│                                                 │
│  [협업] L13 에이전트/스킬 + L14 Teams            │
│    → 전문가 역할 정의 + 팀 협업                   │
│                                                 │
│  [격리] L9 세션 + L11 Worktree                   │
│    → 작업 공간 관리와 컨텍스트 보존               │
│                                                 │
│  [확장] L15 플러그인                             │
│    → 위 모든 것을 패키지로 묶어 공유               │
└─────────────────────────────────────────────────┘
```

## 2. 연결 관계 — "이것은 저것과 함께 쓴다"

### 설정 + 보안
| 조합 | 효과 |
|------|------|
| L2 CLAUDE.md + L3 permissions deny | "이 파일 절대 읽지 마" 강제 |
| L3 권한 모드 + L7 PermissionRequest Hook | 자동 승인/차단 정책 |
| L2 rules/*.md paths + L13 에이전트 allowed-tools | 모듈별 + 역할별 이중 제한 |

### 자동화 파이프라인
| 조합 | 효과 |
|------|------|
| L7 PostToolUse Hook + L8 MCP | 파일 저장 → 자동 린트 → Slack 알림 |
| L7 Stop Hook + L10 SDK -p | Claude 완료 → 다음 파이프라인 단계 트리거 |
| L7 Notification Hook + L12 IDE | Claude 입력 대기 → IDE에서 알림 |

### 협업 + 격리
| 조합 | 효과 |
|------|------|
| L11 Worktree + L14 Teams | 팀원마다 독립 파일시스템 |
| L13 에이전트 + L14 Teams | 전문 역할 팀원 구성 |
| L9 세션 resume + L14 Teams | 팀 작업 중단 후 재개 |

### 확장 생태계
| 조합 | 효과 |
|------|------|
| L15 플러그인 = L13 + L7 + L8 묶음 | 다른 사람 작업 재사용 |
| L13 스킬 동적 컨텍스트 + L8 MCP | 스킬에서 외부 데이터 참조 |
| L15 LSP 플러그인 + L12 IDE | 언어별 코드 인텔리전스 |

## 3. 실전 시나리오별 활용 조합

### 시나리오 A: 혼자 프로젝트 시작
```
1. L2  CLAUDE.md 작성 (프로젝트 규칙)
2. L3  settings.json 권한 설정
3. L7  PostToolUse Hook (자동 포매팅)
4. L8  MCP 서버 추가 (GitHub, context7)
5. L13 자주 쓰는 스킬 만들기 (/deploy, /test)
6. L9  세션 이름 지어두기 → 다음에 resume
```

### 시나리오 B: 팀 프로젝트 세팅
```
1. L2  CLAUDE.md (팀 공유) + CLAUDE.local.md (개인)
2. L2  .claude/rules/*.md (모듈별 규칙)
3. L3  .claude/settings.json (팀 권한) + settings.local.json (개인)
4. L8  .mcp.json (팀 MCP 서버)
5. L13 .claude/agents/ (공유 에이전트)
6. L7  Hooks (팀 공통 자동화)
7. .gitignore → local 파일들 제외
```

### 시나리오 C: 대규모 기능 구현
```
1. L11 Worktree로 격리 → claude -w feature-auth
2. L14 Agent Teams 활성화
3. L6  리더는 opus, 팀원은 sonnet
4. L13 역할별 에이전트 (reviewer, tester)
5. L9  진행 중 /compact로 컨텍스트 관리
6. L7  TaskCompleted Hook → 알림
7. 완료 후 merge → worktree 정리
```

### 시나리오 D: CI/CD 파이프라인
```
1. L10 SDK -p 플래그로 비대화형 실행
2. L3  --allowedTools로 허용 도구 제한
3. L10 --max-budget-usd로 비용 한도
4. L10 --output-format json으로 구조화 출력
5. L7  Hook으로 결과 후처리
6. L8  MCP로 외부 서비스(GitHub, Slack) 알림
```

### 시나리오 E: 코드 리뷰 자동화
```
1. L13 reviewer 에이전트 (allowed-tools: Read 전용)
2. L13 review 스킬 (체크리스트 워크플로)
3. L7  PreToolUse Hook (위험 명령어 차단)
4. L8  GitHub MCP (PR 코멘트 자동 작성)
5. L10 SDK로 CI에서 자동 실행
```

## 4. 파일 구조 최종 참조

```
~/.claude/                          # 전역 (모든 프로젝트)
├── CLAUDE.md                       # L2: 전역 개인 지시사항
├── settings.json                   # L3: 전역 설정 + enabledPlugins
├── keybindings.json                # L5: 키바인딩
├── rules/*.md                      # L2: 전역 규칙
├── skills/*/SKILL.md               # L13: 개인 스킬
├── plugins/                        # L15: 설치된 플러그인
│   └── marketplaces/
│       └── claude-plugins-official/
└── projects/<name>/memory/         # L9: 자동 메모리

프로젝트/                            # 프로젝트별
├── CLAUDE.md                       # L2: 팀 공유 지시사항
├── CLAUDE.local.md                 # L2: 개인 프로젝트 지시 (gitignore)
├── .mcp.json                       # L8: 팀 MCP 설정
├── .claude/
│   ├── settings.json               # L3: 팀 공유 설정
│   ├── settings.local.json         # L3: 개인 설정 (gitignore)
│   ├── rules/*.md                  # L2: 모듈별 규칙
│   ├── agents/*.md                 # L13: 커스텀 에이전트
│   ├── skills/*/SKILL.md           # L13: 프로젝트 스킬
│   └── worktrees/                  # L11: Worktree 작업 공간
└── .gitignore                      # local 파일들 제외
```

## 5. 빠른 의사결정 트리

### "어떤 모델 쓸까?" (L6)
```
간단한 질문/조회 → haiku
일반 구현/리뷰   → sonnet
복잡한 설계/분석 → opus
대규모 코드베이스 → sonnet[1m] 또는 opus[1m]
빠른 응답 필요   → /fast
```

### "자동화 어떻게?" (L7 + L8)
```
파일 저장 시 포맷팅 → PostToolUse Hook + prettier
위험 명령어 차단    → PreToolUse Hook (exit 2)
외부 서비스 알림    → Notification Hook
외부 API 호출      → MCP 서버
```

### "여러 작업 동시에?" (L11 + L13 + L14)
```
독립적 2~3개 작업 → 서브에이전트 (Task) 병렬
대규모 병렬 작업   → Agent Teams
파일 충돌 우려     → Worktree 격리
```

### "재사용하고 싶다" (L13 + L15)
```
나만 쓸 역할      → .claude/agents/ 에이전트
나만 쓸 절차      → .claude/skills/ 스킬
팀이 쓸 역할+절차 → .claude/ (git 커밋)
누구나 쓸 패키지  → 플러그인으로 배포
```

## 6. 학습 전체 흐름 회고

```
[기초]
L1  기본 개념과 설치        → Claude Code가 뭔지, 어떻게 시작하는지
L2  CLAUDE.md 계층 구조     → "무엇을 해라" 지시사항 관리
L3  설정 (settings.json)   → "어떻게 동작해라" 설정 관리
L4  슬래시 커맨드           → 세션 내 빠른 조작
L5  키보드 단축키           → 손이 기억하는 효율

[제어]
L6  모델 선택과 성능 제어    → 작업에 맞는 두뇌 선택
L7  Hooks 시스템            → 이벤트 기반 자동화
L8  MCP 서버                → 외부 세계와 연결
L9  세션 관리와 컨텍스트     → 작업 연속성 보장

[확장]
L10 SDK / Headless 모드     → 프로그래밍으로 Claude 제어
L11 Git Worktree            → 격리된 작업 공간
L12 IDE 연동                → 에디터에서 바로 사용

[고급]
L13 커스텀 에이전트와 스킬   → 전문가 역할 + 워크플로
L14 Agent Teams             → 여러 Claude 협업
L15 플러그인 생태계          → 패키지로 공유/재사용
```
