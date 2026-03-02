#!/bin/bash
# 목적: Level 7 - Hooks 시스템 실습. 직접 실행하는 파일이 아니라 설정 예시 모음입니다.
# 실제 설정은 .claude/settings.json 또는 ~/.claude/settings.json에 넣어야 합니다.

# ============================================
# 실습 1: 자동 포매팅 Hook (가장 실용적)
# ============================================
# Write/Edit 후 자동으로 prettier 실행
cat << 'HOOK1'
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $TOOL_INPUT_FILE_PATH 2>/dev/null || true",
            "timeout": 10000
          }
        ]
      }
    ]
  }
}
HOOK1

# ============================================
# 실습 2: 완료 알림 소리 Hook
# ============================================
# Claude 응답이 끝나면 macOS 소리 재생
cat << 'HOOK2'
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "afplay /System/Library/Sounds/Glass.aiff &"
          }
        ]
      }
    ]
  }
}
HOOK2

# ============================================
# 실습 3: 위험 명령어 차단 Hook
# ============================================
# git push --force 차단
cat << 'HOOK3'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "if echo $TOOL_INPUT | jq -r '.command' | grep -q 'push.*--force\\|push.*-f'; then echo 'Force push blocked!' && exit 2; fi"
          }
        ]
      }
    ]
  }
}
HOOK3

# ============================================
# 실습 4: macOS 알림 Hook
# ============================================
# Claude가 입력을 기다릴 때 macOS 알림
cat << 'HOOK4'
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude가 입력을 기다립니다\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  }
}
HOOK4

echo "이 파일은 설정 예시 모음입니다. 직접 실행하지 마세요."
echo "원하는 hook을 .claude/settings.json에 복사해서 사용하세요."
