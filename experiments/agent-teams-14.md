# Agent Teams 실험 — Level 14
> 목적: 여러 Claude 인스턴스가 협업하는 Agent Teams 구조 학습
> 날짜: 2026-03-02

## 핵심 개념

### Agent Teams란?
여러 Claude Code 인스턴스가 공유 태스크 리스트로 협업하는 시스템.
리더가 작업을 분배하고, 팀원들이 독립적으로 수행한 뒤 결과를 종합한다.

### 왜 필요한가?
- 하나의 Claude는 컨텍스트 윈도우가 한정됨
- 큰 작업을 분할 → 각 팀원이 독립 컨텍스트로 집중
- 병렬 실행 → 시간 단축

## 구조

```
Lead Agent (리더: 태스크 생성/분배/종합)
├── Teammate 1 (독립 컨텍스트, 독립 실행)
├── Teammate 2 (독립 컨텍스트, 독립 실행)
└── Teammate 3 (독립 컨텍스트, 독립 실행)
    └── 공유 태스크 리스트 + 메시징으로 소통
```

## 활성화
```bash
# 아직 실험적 기능이므로 환경 변수 필요
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

## 생명주기

| 단계 | API | 설명 |
|------|-----|------|
| 1 | `TeamCreate` | 팀 생성 |
| 2 | `TaskCreate × N` | 태스크 여러 개 생성 |
| 3 | `Task(team, name)` | 팀원 생성 & 작업 시작 |
| 4 | (팀원 독립 작업) | 각자 태스크 수행 |
| 5 | `SendMessage` | 리더↔팀원 소통 |
| 6 | `TaskUpdate` | 완료 보고 |
| 7 | `TeamDelete` | 팀 해체 |

## 표시 모드

| 모드 | 설명 | 장점 |
|------|------|------|
| `in-process` | 메인 터미널 안에서 표시 | 추가 설정 불필요 |
| `tmux` | 분할 패널에서 각 팀원 표시 | 실시간 모니터링 |
| `auto` | 환경에 따라 자동 | 편의성 |

## 관련 Hook 이벤트 (Level 7 연결)

| 이벤트 | 발생 시점 | 활용 예 |
|--------|-----------|---------|
| `TeammateIdle` | 팀원 유휴 | 새 태스크 할당 |
| `TaskCompleted` | 태스크 완료 | 알림, 다음 단계 트리거 |
| `SubagentStart` | 서브에이전트 시작 | 로깅 |
| `SubagentStop` | 서브에이전트 종료 | 결과 수집 |

## 실전 팀 구성 패턴

### 기능 개발
```
analyst → planner → executor × N → test-engineer → verifier
(분석)    (계획)    (구현, 병렬)    (테스트)        (검증)
```

### 버그 수사
```
explore + debugger → executor → test-engineer → verifier
(탐색 + 진단)       (수정)     (회귀 테스트)    (검증)
```

### 코드 리뷰 (병렬)
```
quality-reviewer ─┐
security-reviewer ─┼→ 종합 리뷰 결과
code-reviewer ────┘
```

## Level 12~14 연결

| Level | 기능 | Teams에서의 역할 |
|-------|------|-------------------|
| L7 Hooks | 이벤트 자동화 | TeammateIdle, TaskCompleted 처리 |
| L11 Worktree | 격리 작업 공간 | 팀원마다 독립 worktree |
| L13 에이전트 | 전문가 역할 | 팀원에게 전문 역할 부여 |
| L14 Teams | 협업 시스템 | 전체 오케스트레이션 |

## 서브에이전트 격리 (Worktree)

에이전트 또는 Task 호출 시 `isolation: worktree`로 격리 실행 가능:
```yaml
isolation: worktree
```
→ 각 팀원이 독립된 파일 시스템에서 작업하므로 충돌 방지

## 주의사항
- 아직 실험적 기능 (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 필수)
- 팀원 수가 많으면 비용 증가 (각 팀원이 독립 컨텍스트 소비)
- 태스크 분할이 핵심 — 너무 작으면 오버헤드, 너무 크면 병렬화 효과 감소
