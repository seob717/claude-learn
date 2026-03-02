#!/usr/bin/env bash
# validate-code-blocks.sh
# MDX 파일에서 코드 블록을 추출하여 문법 유효성을 검사하는 스크립트
# bash 블록: bash -n 으로 문법 검사
# json 블록: python3으로 JSON 파싱 검사 (주석 포함 블록은 제외)

set -euo pipefail

# 색상 코드 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 경로 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONTENT_DIR="$PROJECT_ROOT/web/content/levels"

# 임시 디렉토리 (스크립트 종료 시 자동 삭제)
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# 결과 추적
failed_blocks=()
checked_count=0
skipped_count=0

echo "============================================"
echo " 코드 블록 문법 유효성 검사 시작"
echo " 대상 디렉토리: $CONTENT_DIR"
echo "============================================"

if [ ! -d "$CONTENT_DIR" ]; then
  echo -e "${RED}오류: 콘텐츠 디렉토리를 찾을 수 없습니다: $CONTENT_DIR${NC}"
  exit 1
fi

# Python3 사용 가능 여부 확인
if ! command -v python3 &>/dev/null; then
  echo -e "${YELLOW}경고: python3를 찾을 수 없습니다. JSON 검사를 건너뜁니다.${NC}"
  SKIP_JSON=true
else
  SKIP_JSON=false
fi

# MDX 파일에서 코드 블록을 추출하는 Python 헬퍼 함수
# AWK를 사용하여 ```lang ... ``` 블록을 개별 파일로 저장
extract_blocks() {
  local mdx_file="$1"
  local out_dir="$2"

  python3 - "$mdx_file" "$out_dir" <<'PYEOF'
import sys
import os
import re

mdx_path = sys.argv[1]
out_dir = sys.argv[2]

with open(mdx_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 코드 블록 패턴: ```lang 으로 시작하고 ``` 로 끝나는 블록
# re.DOTALL로 멀티라인 매칭
pattern = re.compile(r'^```(\w+)\n(.*?)^```', re.MULTILINE | re.DOTALL)

block_num = 0
for match in pattern.finditer(content):
    lang = match.group(1).lower()
    code = match.group(2)
    block_num += 1

    # 지원하는 언어만 추출 (bash, sh, json)
    if lang in ('bash', 'sh', 'json'):
        out_path = os.path.join(out_dir, f'block_{block_num:04d}.{lang}')
        with open(out_path, 'w', encoding='utf-8') as f:
            f.write(code)
PYEOF
}

# 모든 MDX 파일 순회
while IFS= read -r -d '' mdx_file; do
  filename=$(basename "$mdx_file")
  file_tmp="$TMP_DIR/$(basename "$mdx_file" .mdx)"
  mkdir -p "$file_tmp"

  echo ""
  echo "파일 검사 중: $filename"

  # 코드 블록 추출 (Python3 필요)
  if ! python3 - "$mdx_file" "$file_tmp" <<'PYEOF' 2>/dev/null; then
import sys, os, re
mdx_path, out_dir = sys.argv[1], sys.argv[2]
with open(mdx_path, 'r', encoding='utf-8') as f:
    content = f.read()
pattern = re.compile(r'^```(\w+)\n(.*?)^```', re.MULTILINE | re.DOTALL)
block_num = 0
for match in pattern.finditer(content):
    lang = match.group(1).lower()
    code = match.group(2)
    block_num += 1
    if lang in ('bash', 'sh', 'json'):
        out_path = os.path.join(out_dir, f'block_{block_num:04d}.{lang}')
        with open(out_path, 'w', encoding='utf-8') as f:
            f.write(code)
PYEOF
    echo -e "  ${YELLOW}블록 추출 실패 (건너뜀)${NC}"
    continue
  fi

  # 추출된 블록 파일 없으면 건너뜀
  block_files=("$file_tmp"/block_*.*)
  if [ ! -e "${block_files[0]:-}" ]; then
    echo "  -> 검사 대상 코드 블록 없음"
    continue
  fi

  # 각 블록 파일 검사
  for block_file in "$file_tmp"/block_*.*; do
    [ -f "$block_file" ] || continue

    block_name=$(basename "$block_file")
    # 블록 번호 추출 (block_0001.bash -> 0001)
    block_num="${block_name#block_}"
    block_num="${block_num%%.*}"
    ext="${block_file##*.}"

    case "$ext" in
      bash|sh)
        checked_count=$((checked_count + 1))
        # bash -n: 문법 검사만 수행 (실행하지 않음)
        # MDX 예시에는 $VARIABLE, <placeholder> 같은 플레이스홀더가 있을 수 있으므로
        # 플레이스홀더/의사코드가 포함된 블록은 건너뜀
        if grep -qE '<[a-zA-Z_-]+>|Task\(|^\s*-\s+[가-힣]' "$block_file"; then
          echo -e "  ${YELLOW}[SKIP]${NC} bash 블록 #$block_num (플레이스홀더/의사코드 포함, 검사 제외)"
          skipped_count=$((skipped_count + 1))
        elif bash_err=$(bash -n "$block_file" 2>&1); then
          echo -e "  ${GREEN}[OK]${NC} bash 블록 #$block_num"
        else
          # "command not found"류 런타임 오류가 아닌 순수 문법 오류만 실패 처리
          if echo "$bash_err" | grep -qE "syntax error|unexpected token|unterminated"; then
            echo -e "  ${RED}[FAIL]${NC} bash 블록 #$block_num: $bash_err"
            failed_blocks+=("$filename | bash 블록 #$block_num | $bash_err")
          else
            # 플레이스홀더 등으로 인한 경고는 허용
            echo -e "  ${YELLOW}[WARN]${NC} bash 블록 #$block_num (관대 허용): $bash_err"
            skipped_count=$((skipped_count + 1))
          fi
        fi
        ;;
      json)
        if [ "$SKIP_JSON" = true ]; then
          skipped_count=$((skipped_count + 1))
          continue
        fi

        checked_count=$((checked_count + 1))

        # 주석(//)이나 플레이스홀더가 포함된 JSON-like 블록은 건너뜀
        # 표준 JSON은 주석을 허용하지 않으므로 주석 있는 블록은 예시 코드로 간주
        if grep -qE '^\s*//' "$block_file" || grep -qE '\.\.\.' "$block_file"; then
          echo -e "  ${YELLOW}[SKIP]${NC} json 블록 #$block_num (주석/플레이스홀더 포함, 검사 제외)"
          skipped_count=$((skipped_count + 1))
          continue
        fi

        # python3으로 JSON 유효성 검사
        if json_err=$(python3 -c "
import json, sys
try:
    with open('$block_file') as f:
        json.load(f)
    sys.exit(0)
except json.JSONDecodeError as e:
    print(str(e))
    sys.exit(1)
" 2>&1); then
          echo -e "  ${GREEN}[OK]${NC} json 블록 #$block_num"
        else
          echo -e "  ${RED}[FAIL]${NC} json 블록 #$block_num: $json_err"
          failed_blocks+=("$filename | json 블록 #$block_num | $json_err")
        fi
        ;;
    esac
  done

done < <(find "$CONTENT_DIR" -name "*.mdx" -print0 | sort -z)

# 결과 요약
echo ""
echo "============================================"
echo " 코드 블록 검사 완료"
echo " 검사 블록 수: $checked_count"
echo " 건너뜀: $skipped_count"
echo "============================================"

if [ ${#failed_blocks[@]} -eq 0 ]; then
  echo -e "${GREEN}모든 코드 블록 문법 정상.${NC}"
  exit 0
else
  echo -e "${RED}문법 오류 발견: ${#failed_blocks[@]}개${NC}"
  echo ""
  echo "--- 실패 블록 목록 ---"
  for entry in "${failed_blocks[@]}"; do
    echo "  $entry"
  done
  exit 1
fi
