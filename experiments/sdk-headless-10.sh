#!/bin/bash
# 목적: Level 10 - SDK / Headless 모드 실습
# 사용법: 별도 터미널에서 실행하세요 (Claude Code 세션 밖에서!)
#   chmod +x experiments/sdk-headless-10.sh
#   ./experiments/sdk-headless-10.sh

echo "============================================"
echo "Level 10: SDK / Headless 모드 실습"
echo "============================================"
echo ""

# ============================================
# 실습 1: 기본 headless (-p)
# ============================================
echo "--- 실습 1: 기본 headless ---"
echo "명령어: claude -p \"이 프로젝트의 파일 구조를 요약해줘\" --max-turns 3"
echo ""
echo "실행하시겠습니까? (y/n)"
read -r answer
if [ "$answer" = "y" ]; then
  claude -p "이 프로젝트의 experiments/ 디렉토리에 어떤 파일들이 있는지 한줄씩 요약해줘" --max-turns 3
fi
echo ""

# ============================================
# 실습 2: JSON 출력
# ============================================
echo "--- 실습 2: JSON 출력 ---"
echo "명령어: claude -p \"1+1은?\" --output-format json --max-turns 1"
echo ""
echo "실행하시겠습니까? (y/n)"
read -r answer
if [ "$answer" = "y" ]; then
  # JSON 출력: session_id, result, cost 등 메타데이터 포함
  claude -p "1+1은 몇이야? 숫자만 답해줘" --output-format json --max-turns 1
fi
echo ""

# ============================================
# 실습 3: 도구 제한 (--allowedTools)
# ============================================
echo "--- 실습 3: 도구 제한 ---"
echo "명령어: claude -p \"...\" --allowedTools \"Read,Glob\" --max-turns 3"
echo "→ Read와 Glob만 허용, Bash/Edit 등은 차단"
echo ""
echo "실행하시겠습니까? (y/n)"
read -r answer
if [ "$answer" = "y" ]; then
  claude -p "experiments/ 폴더의 파일 목록을 알려줘" \
    --allowedTools "Read,Glob" \
    --max-turns 3
fi
echo ""

# ============================================
# 실습 4: 파이프 입력 (stdin)
# ============================================
echo "--- 실습 4: 파이프 입력 ---"
echo "명령어: cat CLAUDE.md | claude -p \"이 파일을 한줄로 요약해줘\""
echo ""
echo "실행하시겠습니까? (y/n)"
read -r answer
if [ "$answer" = "y" ]; then
  cat CLAUDE.md | claude -p "이 내용을 한줄로 요약해줘" --max-turns 1
fi
echo ""

# ============================================
# 실습 5: 세션 이어하기 (--resume)
# ============================================
echo "--- 실습 5: 세션 이어하기 ---"
echo "1단계: 첫 질문 → session_id 획득"
echo "2단계: 같은 세션에서 후속 질문"
echo ""
echo "실행하시겠습니까? (y/n)"
read -r answer
if [ "$answer" = "y" ]; then
  echo "1단계: 첫 질문..."
  # JSON에서 session_id 추출
  result=$(claude -p "내 이름은 '테스터'야. 기억해줘." --output-format json --max-turns 1)
  session_id=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null)

  if [ -n "$session_id" ]; then
    echo "session_id: $session_id"
    echo ""
    echo "2단계: 같은 세션에서 후속 질문..."
    # 이전 세션의 컨텍스트가 유지됨
    claude -p "내 이름이 뭐라고 했지?" --resume "$session_id" --max-turns 1
  else
    echo "session_id 추출 실패. 결과: $result"
  fi
fi
echo ""

# ============================================
# 실습 6: 예산 제한 (--max-budget-usd)
# ============================================
echo "--- 실습 6: 예산/턴 제한 ---"
echo "명령어: claude -p \"...\" --max-turns 2 --max-budget-usd 0.50"
echo "→ 최대 2턴, 0.5달러 초과 시 자동 중단"
echo ""
echo "실행하시겠습니까? (y/n)"
read -r answer
if [ "$answer" = "y" ]; then
  claude -p "간단한 Python fizzbuzz 함수를 작성해줘" \
    --max-turns 2 \
    --max-budget-usd 0.50 \
    --allowedTools "Read"
fi
echo ""

echo "============================================"
echo "실습 완료!"
echo ""
echo "핵심 정리:"
echo "  -p            : 비대화형 (답변 후 종료)"
echo "  --output-format json : 메타데이터 포함 JSON"
echo "  --allowedTools : 도구 제한 (보안)"
echo "  --resume       : 이전 세션 이어하기"
echo "  --max-turns    : 턴 제한"
echo "  --max-budget-usd : 비용 제한"
echo "  파이프 |       : stdin으로 데이터 전달"
echo "============================================"
