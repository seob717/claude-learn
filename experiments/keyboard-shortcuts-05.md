# 키보드 단축키 실습 가이드
# 목적: Level 5 - Claude Code 키보드 단축키를 체험하고 근육 기억으로 만든다

---

## 핵심 3단계: 생존 → 효율 → 고급

### 1단계: 생존 단축키 (반드시 외우기)

| 단축키 | 동작 | 언제 쓰나 |
|--------|------|----------|
| `Ctrl+C` | 현재 생성/입력 취소 | Claude가 엉뚱한 방향으로 갈 때 |
| `Ctrl+D` | Claude Code 종료 | 세션 끝낼 때 |
| `Esc Esc` | 되감기/요약 | 실수를 되돌리고 싶을 때 |
| `Shift+Tab` | 권한 모드 순환 | default → plan → acceptEdits 전환 |

→ 이 4개만 알아도 기본 조작 가능

### 2단계: 효율 단축키 (생산성 향상)

| 단축키 | 동작 | 왜 유용한가 |
|--------|------|------------|
| `\` + `Enter` | 멀티라인 입력 | 긴 프롬프트를 여러 줄로 작성 |
| `Ctrl+G` | 외부 에디터에서 편집 | 아주 긴 프롬프트 작성 시 vim/nano 사용 |
| `Ctrl+R` | 명령어 히스토리 검색 | 이전에 입력한 프롬프트 재사용 |
| `Ctrl+K` | 커서~줄 끝 삭제 | 입력 수정 시 |
| `Ctrl+U` | 전체 줄 삭제 | 입력 다시 작성 시 |

→ 특히 `\+Enter` 멀티라인은 매일 쓰게 됨

### 3단계: 고급 단축키 (파워 유저)

| 단축키 | 동작 | 연결되는 개념 |
|--------|------|-------------|
| `Alt+P` / `Option+P` | 모델 전환 | Level 6: /model과 같은 기능 |
| `Alt+T` / `Option+T` | 확장 사고 토글 | Extended Thinking on/off |
| `Ctrl+V` | 이미지 붙여넣기 | 스크린샷으로 버그 설명 |
| `Ctrl+B` | 작업을 백그라운드로 | 긴 작업 중 다른 입력 가능 |
| `Ctrl+T` | 태스크 리스트 토글 | Level 14: Agent Teams에서 활용 |
| `Ctrl+O` | 상세 출력 토글 | 디버깅 시 도구 호출 상세 확인 |

---

## 실습: 직접 해보기

### 실습 1: 멀티라인 입력
아래처럼 입력해보세요 (\ 후 Enter로 줄바꿈):
```
이 프로젝트에서\
1. 파일 목록을 보여주고\
2. 각 파일의 역할을 설명해줘
```

### 실습 2: 권한 모드 순환
1. `Shift+Tab` 누르기 → 상태바에서 모드 변경 확인
2. 다시 `Shift+Tab` → 다음 모드로 전환
3. 원하는 모드에서 멈추기

### 실습 3: 되감기
1. Claude에게 아무 작업 요청
2. 결과가 마음에 안 들면 `Esc Esc` 두 번 누르기
3. 대화와 코드가 이전 상태로 복원되는 것 확인

### 실습 4: 히스토리 검색
1. `Ctrl+R` 누르기
2. 이전에 입력한 프롬프트 키워드 타이핑
3. 원하는 프롬프트 찾아서 Enter

---

## 커스텀 키바인딩 (Level 3 설정과 연결)

`~/.claude/keybindings.json`에서 원하는 대로 변경 가능:

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "ctrl+e": "chat:externalEditor",
        "ctrl+u": null
      }
    }
  ]
}
```

### 키 표기법
- 단일: `ctrl+k`, `shift+tab`, `meta+p`
- 코드 (순차 조합): `ctrl+k ctrl+s` (Ctrl+K 누른 후 Ctrl+S)
- 비활성화: `null` 값으로 설정

### 변경 불가 키 (예약됨)
- `Ctrl+C` — 취소 (항상 작동해야 하므로)
- `Ctrl+D` — 종료 (항상 작동해야 하므로)

변경 후 재시작 없이 즉시 반영됨.

---

## 현실적 호환성 정리

### 어디서든 확실히 되는 것
```
Ctrl+C 취소 | Ctrl+D 종료 | Esc×2 되감기 | Shift+Tab 모드전환
\+Enter 멀티라인 | Ctrl+R 히스토리 | Ctrl+U 줄삭제 | Ctrl+K 줄끝삭제
```

### 터미널 설정에 따라 다른 것
```
Option+P 모델전환     → iTerm2: Option as Meta 설정 필요, 기본 Terminal 안 됨
Option+T 확장사고     → 위와 동일
Shift+Enter 줄바꿈   → iTerm2/Warp는 됨, 기본 Terminal은 그냥 Enter(제출)
Ctrl+G 외부에디터     → $EDITOR 환경변수 설정 필요
Ctrl+V 이미지        → 터미널의 이미지 붙여넣기 지원 필요
```

### 줄바꿈 방법 비교 (중요!)
```
\+Enter       → 어디서든 됨 (가장 안전)
Option+Enter  → macOS 대부분 터미널에서 됨
Shift+Enter   → iTerm2/Warp만 됨 (기본 Terminal은 제출됨!)
Ctrl+J        → 대부분 터미널에서 됨
```
