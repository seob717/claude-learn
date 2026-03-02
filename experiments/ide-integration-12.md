# Level 12: IDE 연동 실습 노트

> 목적: IDE(WebStorm, VS Code)에서 Claude Code를 사용하는 방법과 CLI와의 관계를 이해한다

---

## 핵심 개념

### IDE 플러그인 = CLI의 GUI 래퍼

```
IDE 플러그인 ◄── SSE/WebSocket ──► Claude Code CLI (백그라운드)
   (GUI)         (실시간 통신)        (실제 실행)
     │                                    │
     └────── 같은 설정 파일 공유 ──────────┘
```

플러그인이 별도 AI 엔진을 가진 게 아니라, **CLI를 띄워서 통신하는 구조**.

### 공유되는 것 vs 다른 것

| 공유 (같은 파일) | CLI 전용 | IDE 전용 |
|-----------------|----------|----------|
| CLAUDE.md | 터미널 기반 UI | GUI 패널 |
| .claude/rules/ | `\ + Enter` 멀티라인 | 자유 멀티라인 |
| .claude/settings.json | diff가 텍스트 출력 | 인라인 diff (수락/거부) |
| .mcp.json | `/compact` 직접 입력 | UI 버튼 |
| auto memory | `@파일` 자동완성 | `@파일#라인` + 진단 공유 |

---

## 실습 결과

### 1. WebStorm 플러그인 확인

설치 확인:
```
WebStorm 2025.1 → claude-code-jetbrains-plugin ✓
WebStorm 2025.2 → claude-code-jetbrains-plugin ✓
WebStorm 2025.3 → claude-code-jetbrains-plugin ✓ (0.1.14-beta)
```

기술 스택: Kotlin + Ktor (SSE/WebSocket으로 CLI와 통신)

### 2. WebStorm 단축키

| 단축키 | 동작 |
|--------|------|
| `Cmd+Esc` | Claude Code 패널 열기/닫기 |
| `Cmd+Option+K` | 현재 파일/선택 영역 참조 삽입 |
| 패널 내 `@` | 파일 참조 + 라인 범위 (`@file.ts#5-10`) |

### 3. VS Code 확장 단축키

| 단축키 | 동작 |
|--------|------|
| `Cmd+Esc` | Claude ↔ 에디터 포커스 전환 |
| `Cmd+Shift+Esc` | 새 대화 탭 |
| `Cmd+N` | 새 대화 (Claude 포커스 시) |
| `Option+K` | 선택 영역 @-멘션 삽입 |

### 4. VS Code vs JetBrains 차이

| 기능 | VS Code | JetBrains |
|------|---------|-----------|
| diff 표시 | 인라인 diff | IDE 네이티브 diff 뷰어 |
| 진단 공유 | X | O (린트, 타입 오류 자동 전달) |
| 브라우저 연동 | `@browser` (Chrome) | X |
| 복수 대화 | 탭/창 지원 | 지원 |

---

## IDE에서 시도해볼 것

1. **`Cmd+Esc`** — WebStorm에서 Claude 패널 열기
2. **코드 선택 후 `Cmd+Option+K`** — 선택 영역을 Claude에 참조로 전달
3. **`@` 입력** — 파일 자동완성, `#라인` 범위 지정
4. **수정 제안 → diff 뷰어** — IDE 네이티브 diff로 수락/거부

---

## 이전 레벨과의 연결

| 레벨 | 연결점 |
|------|--------|
| Level 2 (CLAUDE.md) | IDE에서도 동일하게 로드 — 설정은 한 번만 |
| Level 3 (settings.json) | IDE와 CLI가 같은 settings.json 사용 |
| Level 5 (단축키) | CLI와 IDE 단축키가 다름. IDE는 Cmd 기반 |
| Level 8 (MCP) | IDE에서도 MCP 도구 사용 가능 |

---

## 기억할 것

1. **IDE 플러그인 = CLI의 GUI 래퍼** (별도 엔진 아님)
2. **설정 파일은 100% 공유** — CLI에서 설정하면 IDE에도 적용
3. **JetBrains의 장점: 진단 공유** — 린트, 타입 오류를 Claude에 자동 전달
4. **VS Code의 장점: @browser** — Chrome 연동으로 웹 페이지 컨텍스트 공유
5. **Cmd+Esc** — 가장 중요한 단축키 (패널 토글)
