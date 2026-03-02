#!/usr/bin/env bash
# validate-links.sh
# MDX 파일에서 URL을 추출하여 HTTP 상태코드를 검사하는 스크립트
# 깨진 링크(4xx/5xx)를 감지하고 리포트를 출력합니다.

set -euo pipefail

# 색상 코드 정의 (터미널 출력 가독성 향상)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 색상 초기화

# 스크립트 위치를 기준으로 프로젝트 루트 계산
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONTENT_DIR="$PROJECT_ROOT/web/content/levels"

# curl 요청 타임아웃 (초)
TIMEOUT=10

# 결과 추적 변수
broken_links=()
checked_count=0

echo "============================================"
echo " URL 링크 유효성 검사 시작"
echo " 대상 디렉토리: $CONTENT_DIR"
echo "============================================"

# MDX 파일이 존재하지 않으면 종료
if [ ! -d "$CONTENT_DIR" ]; then
  echo -e "${RED}오류: 콘텐츠 디렉토리를 찾을 수 없습니다: $CONTENT_DIR${NC}"
  exit 1
fi

# 모든 MDX 파일 순회
while IFS= read -r -d '' mdx_file; do
  filename=$(basename "$mdx_file")
  echo ""
  echo "파일 검사 중: $filename"

  # grep으로 URL 추출 (http/https로 시작하는 URL)
  # 마크다운 괄호, 따옴표, 공백, 꺾쇠괄호 앞에서 종료
  urls=$(grep -oE 'https?://[^)"'"'"'[:space:]>]+' "$mdx_file" 2>/dev/null | sort -u || true)

  if [ -z "$urls" ]; then
    echo "  -> URL 없음 (건너뜀)"
    continue
  fi

  # 각 URL에 대해 HTTP 상태코드 확인
  while IFS= read -r url; do
    # 빈 URL 건너뜀
    [ -z "$url" ] && continue

    # curl로 HTTP 상태코드만 가져오기 (-sI: silent + HEAD 요청, -L: 리다이렉트 따라감)
    http_code=$(curl -sI -o /dev/null -w "%{http_code}" \
      --max-time "$TIMEOUT" \
      --connect-timeout "$TIMEOUT" \
      -L \
      "$url" 2>/dev/null || echo "000")

    checked_count=$((checked_count + 1))

    # 상태코드 판별
    if [[ "$http_code" =~ ^[23] ]]; then
      # 2xx(성공) 또는 3xx(리다이렉트)는 정상
      echo -e "  ${GREEN}[OK $http_code]${NC} $url"
    elif [ "$http_code" = "000" ]; then
      # 연결 실패 (타임아웃, DNS 오류 등)
      echo -e "  ${YELLOW}[TIMEOUT]${NC} $url"
      broken_links+=("$filename | TIMEOUT | $url")
    else
      # 4xx/5xx 오류
      echo -e "  ${RED}[BROKEN $http_code]${NC} $url"
      broken_links+=("$filename | $http_code | $url")
    fi
  done <<< "$urls"

done < <(find "$CONTENT_DIR" -name "*.mdx" -print0 | sort -z)

# 결과 요약 출력
echo ""
echo "============================================"
echo " 링크 검사 완료"
echo " 총 검사 URL 수: $checked_count"
echo "============================================"

if [ ${#broken_links[@]} -eq 0 ]; then
  echo -e "${GREEN}깨진 링크 없음. 모든 URL 정상.${NC}"
  exit 0
else
  echo -e "${RED}깨진 링크 발견: ${#broken_links[@]}개${NC}"
  echo ""
  echo "--- 깨진 링크 목록 ---"
  for entry in "${broken_links[@]}"; do
    echo "  $entry"
  done
  # 깨진 링크가 있으면 종료 코드 1 반환 (CI 실패 신호)
  exit 1
fi
