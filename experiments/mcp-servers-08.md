# Level 8: MCP 서버 실습 노트

> 목적: MCP(Model Context Protocol) 서버의 개념과 실제 동작을 이해한다

---

## 핵심 개념

### MCP란?
Claude Code에 **외부 도구**를 연결하는 개방형 프로토콜.
Hook이 "이벤트 시 실행"이라면, MCP는 "새 도구 추가"이다.

### 전송 방식 3가지

| 방식 | 설명 | 사용 사례 |
|------|------|-----------|
| `stdio` | 로컬 프로세스 실행 | npx로 패키지 실행 |
| `http` (권장) | 원격 HTTP 서버 | SaaS 서비스 연동 |
| `sse` (레거시) | Server-Sent Events | 구버전 호환 |

### 범위 (Scope)

| 범위 | 저장 위치 | 공유 | 사용 사례 |
|------|-----------|------|-----------|
| `local` (기본) | `~/.claude.json` 프로젝트별 | X | 개인 API 키가 필요한 서버 |
| `project` | `.mcp.json` | O (git) | 팀 전체가 쓰는 서버 |
| `user` | `~/.claude.json` 전역 | X | 모든 프로젝트에서 쓰는 서버 |

→ Level 3에서 배운 settings.json 범위와 같은 패턴!

---

## 실습 결과

### 1. 현재 설정된 MCP 서버

```
context7       stdio   → 라이브러리 문서 실시간 검색
figma          http    → Figma 디자인 파일 연동
figma-desktop  http    → Figma 데스크톱 앱 연동
playwright     stdio   → 브라우저 자동화 (열기, 클릭, 스크린샷)
```

추가로 GitHub, Filesystem MCP 서버도 설정되어 있어 총 6개 이상의 외부 도구 세트 사용 가능.

### 2. Context7 MCP 실습

**도구 호출 흐름:**
```
resolve-library-id("react") → 라이브러리 ID 획득 (/websites/react_dev)
         ↓
query-docs(libraryId, "useEffect cleanup") → 공식 문서에서 코드 예시 반환
```

결과: React 공식 문서에서 useEffect cleanup 패턴 5개를 실시간으로 가져옴.
→ 웹 검색 없이 **정확한 공식 문서** 기반 답변이 가능해진다.

### 3. Playwright MCP 실습

**도구 호출 흐름:**
```
browser_navigate("https://example.com") → 페이지 열기 + 스냅샷 반환
browser_snapshot() → 페이지 접근성 트리 (클릭 가능한 요소 ref 포함)
browser_click(ref="e6") → 요소 클릭
browser_close() → 브라우저 닫기
```

결과: example.com을 열어서 제목("Example Domain")과 링크를 읽음.
→ 웹 UI 테스트, 스크래핑, 폼 자동 제출 등에 활용 가능.

---

## MCP CLI 명령어 정리

```bash
# 서버 추가
claude mcp add --transport http <이름> <URL>
claude mcp add --transport stdio <이름> -- <명령어>
claude mcp add --transport stdio --env API_KEY=xxx <이름> -- npx -y <패키지>

# 관리
claude mcp list                  # 목록
claude mcp get <이름>            # 상세 정보
claude mcp remove <이름>         # 제거

# 범위 지정
claude mcp add -s project ...    # .mcp.json에 저장 (팀 공유)
claude mcp add -s user ...       # ~/.claude.json 전역

# Claude Desktop에서 가져오기
claude mcp add-from-claude-desktop

# 세션 내
/mcp                             # MCP 서버 상태 확인, OAuth 인증
```

## 프로젝트 공유 MCP 설정 예시 (.mcp.json)

```json
{
  "mcpServers": {
    "database": {
      "command": "npx",
      "args": ["-y", "@bytebase/dbhub", "--dsn", "${DB_CONNECTION_STRING}"],
      "env": {}
    }
  }
}
```
→ `${VAR}` 문법으로 환경 변수 참조 가능. API 키를 직접 넣지 않아도 된다.

---

## 이전 레벨과의 연결

| 레벨 | 연결점 |
|------|--------|
| Level 2 (CLAUDE.md) | MCP 도구도 CLAUDE.md에서 사용 지침 작성 가능 |
| Level 3 (settings.json) | `enabledMcpjsonServers`로 .mcp.json 서버 활성화 제어 |
| Level 7 (Hooks) | `"matcher": "mcp__github__*"` 처럼 MCP 도구에 Hook 걸기 |

---

## 기억할 것

1. **MCP = Claude에 도구를 플러그인하는 표준 규격**
2. **stdio = 로컬 실행, http = 원격 서비스** (대부분 이 둘만 씀)
3. **범위**: local(개인), project(.mcp.json, 팀 공유), user(전역)
4. **도구가 많아지면** Tool Search가 자동 활성화되어 필요한 도구만 로딩
5. **Hook의 matcher에 MCP 도구 이름 사용 가능** → MCP + Hook 조합 가능
