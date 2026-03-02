#!/usr/bin/env bash
# check-claude-releases.sh
# Claude Code GitHub 릴리즈 API를 확인하여 새 버전이 나왔는지 체크하는 스크립트
# 결과를 "changed" 또는 "unchanged"로 출력합니다

set -euo pipefail

# 마지막으로 확인한 버전을 저장하는 파일 경로
VERSION_FILE="/tmp/claude-code-last-version.txt"

# GitHub API 엔드포인트 (anthropics/claude-code 저장소의 최신 릴리즈)
GITHUB_API_URL="https://api.github.com/repos/anthropics/claude-code/releases/latest"

# GitHub API에서 최신 릴리즈 정보를 가져옵니다
# curl: HTTP 요청 도구, -s: silent 모드(진행 표시 숨김), -f: HTTP 오류 시 실패
# User-Agent 헤더는 GitHub API 요청 시 필수입니다
echo "GitHub API에서 최신 Claude Code 버전 확인 중..." >&2
RESPONSE=$(curl -sf \
  -H "Accept: application/vnd.github.v3+json" \
  -H "User-Agent: claude-learn-checker" \
  "$GITHUB_API_URL")

# jq를 사용해 JSON 응답에서 tag_name 필드(버전 태그)를 추출합니다
# jq: JSON 파싱 도구, -r: raw output(따옴표 없이 출력)
LATEST_VERSION=$(echo "$RESPONSE" | jq -r '.tag_name')

# API 응답이 정상적인지 확인합니다
if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" = "null" ]; then
  echo "오류: GitHub API에서 버전 정보를 가져올 수 없습니다" >&2
  exit 1
fi

echo "최신 버전: $LATEST_VERSION" >&2

# 이전에 저장된 버전 파일이 존재하는지 확인합니다
if [ -f "$VERSION_FILE" ]; then
  # 저장된 마지막 버전을 읽어옵니다
  LAST_VERSION=$(cat "$VERSION_FILE")
  echo "마지막 확인 버전: $LAST_VERSION" >&2

  # 최신 버전과 저장된 버전을 비교합니다
  if [ "$LATEST_VERSION" = "$LAST_VERSION" ]; then
    # 버전이 동일하면 변경 없음
    echo "버전 변경 없음: $LATEST_VERSION" >&2
    echo "unchanged"
  else
    # 버전이 다르면 변경됨 - 새 버전을 파일에 저장합니다
    echo "새 버전 감지: $LAST_VERSION -> $LATEST_VERSION" >&2
    echo "$LATEST_VERSION" > "$VERSION_FILE"
    echo "changed"
  fi
else
  # 버전 파일이 없으면 최초 실행으로 간주하고 현재 버전을 저장합니다
  echo "최초 실행: 현재 버전을 기준으로 저장합니다" >&2
  echo "$LATEST_VERSION" > "$VERSION_FILE"
  # 최초 실행은 비교 대상이 없으므로 변경 없음으로 처리합니다
  echo "unchanged"
fi
