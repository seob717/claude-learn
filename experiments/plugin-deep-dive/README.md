# Claude Code 플러그인 심화 학습

OMC(oh-my-claudecode)와 Superpowers 플러그인의 구조를 단계별로 이해하는 학습 가이드.

## 학습 순서

각 단계를 순서대로 진행하세요. Claude에게 다음 단계를 요청하면 됩니다.

| 단계 | 파일 | 주제 | 상태 |
|------|------|------|------|
| 1 | step-01-baseline.md | Claude Code 기본 도구 — 플러그인 없이 뭘 할 수 있나 | 완료 |
| 2 | step-02-plugin-mechanism.md | 플러그인이 기능을 추가하는 3가지 방법 (Hook, MCP, Skill) | 완료 |
| 3 | step-03-plugin-structure.md | 플러그인 파일 구조 — 어디에 뭐가 있나 | 완료 |
| 4 | step-04-hooks-deep.md | Hook 시스템 심화 — 이벤트, 타입, 실행 흐름 | 완료 |
| 5 | step-05-superpowers-anatomy.md | Superpowers 해부 — 단순한 구조로 원리 이해 | 대기 |
| 6 | step-06-superpowers-skills.md | Superpowers 스킬 15개 — 워크플로우와 의존관계 | 대기 |
| 7 | step-07-omc-overview.md | OMC 전체 구조 — 28에이전트, 32스킬, 37훅 | 대기 |
| 8 | step-08-omc-mcp.md | OMC MCP 서버 — 도구 확장 방식 | 대기 |
| 9 | step-09-omc-agents.md | OMC 에이전트 시스템 — 모델 라우팅과 전문화 | 대기 |
| 10 | step-10-omc-hooks.md | OMC Hook 시스템 — 키워드 감지, 상태 관리 | 대기 |
| 11 | step-11-omc-team.md | OMC Team 파이프라인 — 멀티에이전트 협업 | 대기 |
| 12 | step-12-omc-skills.md | OMC 스킬 — autopilot, ralph, ultrawork 등 | 대기 |
| 13 | step-13-interaction.md | 두 플러그인의 상호작용 — 어떻게 함께 동작하나 | 대기 |
| 14 | step-14-custom-plugin.md | 직접 만들어보기 — 간단한 플러그인 작성 실습 | 대기 |

## 사용법

```
# 컨텍스트를 비운 후 다음 단계 요청:
"experiments/plugin-deep-dive/ 에서 다음 단계 진행해줘"

# 특정 단계로 이동:
"experiments/plugin-deep-dive/ step 5부터 진행해줘"
```
