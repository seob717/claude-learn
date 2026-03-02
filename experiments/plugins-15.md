# 플러그인 생태계 실험 — Level 15
> 목적: 플러그인 구조, 설치/관리, 마켓플레이스 이해
> 날짜: 2026-03-02

## 핵심 개념

### 플러그인이란?
에이전트, 스킬, Hook, MCP 서버, LSP 서버를 하나로 묶은 **배포 가능한 패키지**.
npm 패키지처럼 다른 사람이 만든 Claude Code 확장을 설치해서 사용한다.

### Level 13과의 관계
```
Level 13: 개별 부품을 직접 만듦 (agents/, skills/)
Level 15: 부품 세트를 패키지로 묶어 공유/설치 (plugins)
```

유일한 차이 = `plugin.json`이 추가되어 배포 가능해짐.

## 플러그인 디렉토리 구조

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          ← 필수! 메타데이터
├── .mcp.json                ← MCP 서버 설정 (선택)
├── commands/                ← 사용자 호출 슬래시 커맨드 (선택)
│   └── my-command.md
├── skills/                  ← Claude 자동 사용 스킬 (선택)
│   └── my-skill/
│       └── SKILL.md
├── agents/                  ← 전문 에이전트 (선택)
│   └── my-agent.md
├── LICENSE
└── README.md
```

### plugin.json 형식
```json
{
  "name": "플러그인-이름",
  "description": "플러그인 설명",
  "author": {
    "name": "작성자",
    "email": "email@example.com"
  }
}
```

## Command vs Skill (플러그인 내부)

| | Command | Skill |
|---|---|---|
| 누가 호출? | 사용자 (`/명령어`) | Claude가 자동 판단 |
| 위치 | `commands/*.md` | `skills/*/SKILL.md` |
| 트리거 | 사용자가 직접 입력 | description의 키워드 매칭 |
| 용도 | 명시적 작업 수행 | 맥락에 맞는 가이드 제공 |

## 플러그인 관리

```bash
# 설치
claude plugin install <url-or-name>

# 목록
claude plugin list

# 제거
claude plugin remove <name>

# settings.json에서 활성화/비활성화
"enabledPlugins": {
  "이름@출처": true
}
```

## 플러그인 출처 (소스)

| 출처 | 형식 | 예시 |
|------|------|------|
| 공식 마켓플레이스 | `이름@claude-plugins-official` | `superpowers@claude-plugins-official` |
| GitHub 리포 | `이름@github-url` | `oh-my-claudecode@omc` |
| NPM 패키지 | npm 설치 후 경로 | |
| 로컬 | 직접 디렉토리 | 개발/테스트용 |

## 현재 설치된 플러그인

```json
"enabledPlugins": {
  "oh-my-claudecode@omc": true,
  "superpowers@claude-plugins-official": true
}
```

### oh-my-claudecode (OMC)
- 출처: 커뮤니티 (외부 Git)
- 제공: 멀티에이전트 오케스트레이션, 30+ 스킬, Hooks, MCP 도구
- 주요 기능: autopilot, ralph, ultrawork, team, pipeline 등

### superpowers
- 출처: 공식 마켓플레이스
- 제공: 워크플로 스킬 (brainstorming, TDD, debugging, plan 등)
- 주요 기능: 작업 전 체계적 프로세스 강제

## 마켓플레이스 플러그인 카테고리 (41개)

### 외부 서비스 연동
github, slack, linear, asana, stripe, supabase, firebase, gitlab, greptile

### 개발 도구
playwright (브라우저 자동화), context7 (문서 검색), serena

### 언어별 LSP (코드 인텔리전스)
typescript, pyright, rust-analyzer, gopls, kotlin, swift,
clangd, csharp, lua, php, jdtls(Java)

### 워크플로 자동화
commit-commands, code-review, pr-review-toolkit,
feature-dev, frontend-design

### 유틸리티
code-simplifier, claude-code-setup, claude-md-management,
skill-creator, plugin-dev

### 출력 스타일
explanatory-output-style, learning-output-style

## Level 13~15 연결 정리

```
Level 13: 에이전트/스킬    → 개별 부품을 직접 만듦
Level 14: Agent Teams     → 부품(에이전트)들이 협업
Level 15: 플러그인        → 부품 세트를 패키지로 공유
```

## Skill 작성 베스트 프랙티스 (공식 가이드)

1. **명확한 목적**: 스킬이 무엇을 돕는지 명시
2. **트리거 조건**: description에 구체적인 키워드/문구 포함
3. **구조화된 가이드**: 정보를 논리적으로 구성
4. **실행 가능한 지시**: 구체적인 단계 제공
5. **참조 자료**: 복잡한 스킬은 references/ 하위에 보조 파일
6. **영역 집중**: 하나의 도메인에 집중, 다른 스킬과 겹치지 않게
