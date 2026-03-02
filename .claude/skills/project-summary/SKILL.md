---
name: project-summary
description: 프로젝트 현재 상태를 한눈에 요약합니다
user-invocable: true
allowed-tools: Bash, Read, Grep, Glob
argument-hint: [상세도: brief|full]
---
# 프로젝트 요약 스킬

현재 프로젝트의 상태를 요약해주세요.

## 수집할 정보
1. **Git 상태**: 현재 브랜치, 최근 커밋 3개, 변경된 파일 수
2. **파일 구조**: 주요 디렉토리와 파일 수
3. **TODO 항목**: 코드 내 TODO/FIXME 주석 목록

## 동적 컨텍스트
- 현재 브랜치: !`git branch --show-current`
- 최근 커밋: !`git log --oneline -3 2>/dev/null || echo "(커밋 없음)"`
- 변경 파일: !`git status --short 2>/dev/null | head -10`

## 상세도
- `$ARGUMENTS`가 "full"이면: 파일별 상세 분석 포함
- `$ARGUMENTS`가 "brief"이거나 비어있으면: 핵심 요약만

## 출력 형식
```markdown
## 프로젝트 요약
- 브랜치: ...
- 최근 활동: ...
- 파일 현황: ...
- 주의 사항: ...
```

한국어로 출력하세요.
