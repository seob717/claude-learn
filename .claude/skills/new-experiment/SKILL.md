---
name: new-experiment
description: experiments/ 디렉토리에 컨벤션에 맞는 실험 파일을 생성합니다
user-invocable: true
allowed-tools: Bash, Read, Write, Glob
argument-hint: <주제> <번호> [js|py|sh|md]
---
# 실험 파일 생성기

## 현재 실험 파일 목록
!`ls experiments/ 2>/dev/null | grep -v study-guide`

## 규칙
프로젝트의 `.claude/rules/experiments.md` 컨벤션을 따릅니다:
- 파일명: `[주제]-[번호].[확장자]` (예: `hooks-07.sh`)
- 상단에 목적 주석 필수
- 결과를 콘솔에 출력하도록 작성

## 인수 파싱
- `$ARGUMENTS`에서 주제, 번호, 확장자를 파싱하세요
- 확장자 기본값: `md`
- 예: `/new-experiment agents 13 md` → `experiments/agents-13.md`

## 파일 템플릿

**md 파일:**
```markdown
# [주제] 실험 — Level [번호]
> 목적: [주제]에 대한 학습과 실험
> 날짜: [오늘 날짜]

## 학습 내용
...

## 실습 결과
...
```

**js 파일:**
```javascript
// 목적: [주제] 학습 실험
// 날짜: [오늘 날짜]
// 실행: node experiments/[파일명]
...
```

**py 파일:**
```python
# 목적: [주제] 학습 실험
# 날짜: [오늘 날짜]
# 실행: python3 experiments/[파일명]
...
```

**sh 파일:**
```bash
#!/bin/bash
# 목적: [주제] 학습 실험
# 날짜: [오늘 날짜]
# 실행: bash experiments/[파일명]
...
```

파일 생성 후 경로를 알려주세요.
