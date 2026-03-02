# 커스텀 에이전트와 스킬 실험 — Level 13
> 목적: 커스텀 에이전트와 스킬의 생성, 구조, 활용법 학습
> 날짜: 2026-03-02

## 핵심 개념

### 에이전트 = "누가" (역할 정의)
- 위치: `.claude/agents/*.md`
- 호출: `claude --agent 이름` 또는 세션 내 `/agents`
- 특정 역할의 Claude 인스턴스를 만듦
- 도구 제한, 모델 선택, 권한 모드 설정 가능

### 스킬 = "어떻게" (절차 정의)
- 위치: `.claude/skills/*/SKILL.md`
- 호출: `/스킬이름 [인수]`
- 재사용 가능한 워크플로를 슬래시 커맨드로 등록
- 동적 컨텍스트, 인수 치환 지원

## 만든 에이전트

### 1. reviewer (코드 리뷰어)
```
위치: .claude/agents/reviewer.md
모델: sonnet (비용 효율)
도구: Read, Grep, Glob (읽기 전용)
권한: plan 모드 (실행 불가, 분석만)
```

**설계 의도:**
- `allowed-tools`에서 Edit, Bash를 제외 → 코드 수정 불가능하게 제한
- `permission-mode: plan` → 이중 안전장치
- 보안, 성능, 스타일, 에러 처리 4가지 관점 검토

## 만든 스킬

### 1. project-summary (프로젝트 요약)
```
위치: .claude/skills/project-summary/SKILL.md
호출: /project-summary [brief|full]
도구: Bash, Read, Grep, Glob
```

**핵심 기법:**
- `!`backtick`` 동적 컨텍스트 → git 상태가 스킬 로드 시 자동 주입
- `$ARGUMENTS` 치환 → 상세도 레벨 전달
- `argument-hint` → 사용자에게 인수 형식 안내

### 2. new-experiment (실험 파일 생성기)
```
위치: .claude/skills/new-experiment/SKILL.md
호출: /new-experiment <주제> <번호> [확장자]
도구: Bash, Read, Write, Glob
```

**핵심 기법:**
- 기존 파일 목록을 동적 컨텍스트로 주입 → 중복 방지
- 프로젝트 규칙(.claude/rules/experiments.md) 참조 → 컨벤션 자동 준수
- 확장자별 템플릿 → 반복 작업 표준화

## 프론트매터 주요 옵션 정리

### 에이전트 전용
| 키 | 설명 | 예시 |
|----|------|------|
| `model` | 사용 모델 | `sonnet`, `haiku`, `opus` |
| `allowed-tools` | 허용 도구 목록 | `Read, Grep, Glob` |
| `permission-mode` | 권한 모드 | `plan`, `default` |

### 스킬 전용
| 키 | 설명 | 예시 |
|----|------|------|
| `user-invocable` | 슬래시 커맨드 등록 | `true` |
| `argument-hint` | 인수 힌트 | `<환경>` |
| `context` | 실행 컨텍스트 | `fork` (격리 실행) |
| `agent` | 실행할 에이전트 | `reviewer` |

### 공통
| 키 | 설명 |
|----|------|
| `name` | 이름 |
| `description` | 설명 |
| `allowed-tools` | 허용 도구 |
| `model` | 모델 |

## 동적 컨텍스트 문법

| 문법 | 설명 | 예시 |
|------|------|------|
| `` !`명령어` `` | 쉘 명령어 실행 결과 주입 | `` !`git branch --show-current` `` |
| `$ARGUMENTS` | 전체 인수 문자열 | `/skill foo bar` → `"foo bar"` |
| `$ARGUMENTS[0]` | 첫 번째 인수 | → `"foo"` |
| `$0`, `$1` | 위치 인수 | |
| `${CLAUDE_SESSION_ID}` | 환경 변수 | 세션 ID 등 |

## 에이전트 vs 스킬 선택 기준

| 상황 | 선택 | 이유 |
|------|------|------|
| 역할 제한이 필요 | 에이전트 | 도구/권한을 제한 |
| 반복 워크플로 | 스킬 | 절차를 레시피화 |
| 전문가 페르소나 | 에이전트 | 시스템 프롬프트 커스텀 |
| 사용자가 직접 호출 | 스킬 | `/명령어`로 접근 |
| 역할 + 절차 조합 | 둘 다 | 스킬의 `agent:` 프론트매터 |

## 파일 구조 (Level 13 완료 후)
```
.claude/
├── agents/
│   └── reviewer.md              ← 코드 리뷰 에이전트
├── skills/
│   ├── project-summary/
│   │   └── SKILL.md             ← 프로젝트 요약 스킬
│   └── new-experiment/
│       └── SKILL.md             ← 실험 파일 생성 스킬
├── rules/
│   ├── code-style.md
│   └── experiments.md
├── settings.json
└── settings.local.json
```
