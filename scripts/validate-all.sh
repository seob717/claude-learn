#!/usr/bin/env bash
# validate-all.sh
# 마스터 검증 러너: 모든 검증 스크립트를 순차 실행하고 종합 결과를 출력합니다.
# CI 환경에서 사용하거나 로컬에서 한 번에 검증할 때 사용합니다.
# 각 스크립트는 독립적으로도 실행 가능합니다.

set -uo pipefail
# 주의: set -e 는 의도적으로 제외 - 개별 스크립트 실패를 수집해야 하므로

# 색상 코드 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# 스크립트 디렉토리 (이 파일이 있는 위치)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 실행할 검증 스크립트 목록 (순서대로 실행)
SCRIPTS=(
  "validate-links.sh:URL 링크 유효성 검사"
  "validate-code-blocks.sh:코드 블록 문법 검사"
  "validate-curriculum-coverage.py:커리큘럼 커버리지 검사"
)

# 결과 추적
pass_count=0
fail_count=0
declare -A results  # 스크립트명 -> 결과 (pass/fail)
declare -A exit_codes

# 헬퍼: 구분선 출력
divider() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

# 헬퍼: 스크립트 실행기
# 인자: <스크립트 파일명> <설명>
run_script() {
  local script_file="$1"
  local description="$2"
  local script_path="$SCRIPT_DIR/$script_file"
  local exit_code=0

  echo -e "${BOLD}>> $description${NC}"
  echo -e "   스크립트: $script_file"
  echo ""

  # 파일 존재 여부 확인
  if [ ! -f "$script_path" ]; then
    echo -e "${RED}오류: 스크립트를 찾을 수 없습니다: $script_path${NC}"
    results["$script_file"]="fail"
    exit_codes["$script_file"]=127
    fail_count=$((fail_count + 1))
    return 1
  fi

  # 실행 권한 확인 및 부여
  if [ ! -x "$script_path" ]; then
    echo -e "${YELLOW}경고: 실행 권한 없음. 자동으로 부여합니다: $script_file${NC}"
    chmod +x "$script_path"
  fi

  # Python 스크립트는 python3로 실행, Shell 스크립트는 bash로 실행
  if [[ "$script_file" == *.py ]]; then
    python3 "$script_path" || exit_code=$?
  else
    bash "$script_path" || exit_code=$?
  fi

  exit_codes["$script_file"]=$exit_code

  if [ $exit_code -eq 0 ]; then
    results["$script_file"]="pass"
    pass_count=$((pass_count + 1))
    echo ""
    echo -e "${GREEN}[통과] $description${NC}"
  else
    results["$script_file"]="fail"
    fail_count=$((fail_count + 1))
    echo ""
    echo -e "${RED}[실패] $description (종료 코드: $exit_code)${NC}"
  fi

  return $exit_code
}

# ─── 메인 실행 ───────────────────────────────────────────────

echo ""
echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║      전체 콘텐츠 검증 시작               ║${NC}"
echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""
echo "  실행 시각: $(date '+%Y-%m-%d %H:%M:%S')"
echo "  스크립트 디렉토리: $SCRIPT_DIR"
echo "  총 검증 항목: ${#SCRIPTS[@]}개"

# 각 스크립트를 순차 실행
for entry in "${SCRIPTS[@]}"; do
  # "파일명:설명" 형식을 파싱
  script_file="${entry%%:*}"
  description="${entry#*:}"

  divider
  run_script "$script_file" "$description" || true  # 실패해도 다음 스크립트 계속 실행
done

# ─── 최종 요약 ───────────────────────────────────────────────
divider
echo -e "${BOLD}══════════════════════════════════════════════════${NC}"
echo -e "${BOLD} 전체 검증 결과 요약${NC}"
echo -e "${BOLD}══════════════════════════════════════════════════${NC}"
echo ""

for entry in "${SCRIPTS[@]}"; do
  script_file="${entry%%:*}"
  description="${entry#*:}"
  result="${results[$script_file]:-unknown}"
  code="${exit_codes[$script_file]:-?}"

  if [ "$result" = "pass" ]; then
    echo -e "  ${GREEN}[통과]${NC} $description"
  else
    echo -e "  ${RED}[실패]${NC} $description (종료 코드: $code)"
  fi
done

echo ""
echo -e "  총 통과: ${GREEN}${pass_count}${NC} / 총 실패: ${RED}${fail_count}${NC} / 총 항목: ${#SCRIPTS[@]}"
echo ""

# 하나라도 실패하면 종료 코드 1 (CI 실패 신호)
if [ $fail_count -gt 0 ]; then
  echo -e "${RED}결과: 검증 실패 ($fail_count개 항목 실패)${NC}"
  echo ""
  exit 1
else
  echo -e "${GREEN}결과: 모든 검증 통과${NC}"
  echo ""
  exit 0
fi
