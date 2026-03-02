#!/bin/bash
# 목적: Level 11 - Git Worktree 실습
# 사용법: 별도 터미널에서 실행하세요 (Claude Code 세션 밖에서!)
#   chmod +x experiments/git-worktree-11.sh
#   ./experiments/git-worktree-11.sh

echo "============================================"
echo "Level 11: Git Worktree 실습"
echo "============================================"
echo ""

# ============================================
# 실습 1: 순수 git worktree (Claude 없이)
# ============================================
echo "--- 실습 1: git worktree 기본 명령어 ---"
echo ""

# 현재 worktree 목록
echo "[현재 worktree 목록]"
git worktree list
echo ""

echo "worktree를 생성하시겠습니까? (y/n)"
read -r answer
if [ "$answer" = "y" ]; then
  # 새 브랜치 + worktree 생성
  git worktree add .claude/worktrees/test-worktree -b worktree-test-branch 2>/dev/null

  echo ""
  echo "[생성 후 worktree 목록]"
  git worktree list
  echo ""

  echo "[worktree 디렉토리 내용]"
  ls .claude/worktrees/test-worktree/ 2>/dev/null
  echo ""

  # 정리
  echo "테스트 worktree를 삭제하시겠습니까? (y/n)"
  read -r answer2
  if [ "$answer2" = "y" ]; then
    git worktree remove .claude/worktrees/test-worktree 2>/dev/null
    git branch -d worktree-test-branch 2>/dev/null
    echo "삭제 완료!"
    git worktree list
  fi
fi
echo ""

# ============================================
# 실습 2: Claude Code + Worktree
# ============================================
echo "--- 실습 2: Claude Code + Worktree ---"
echo ""
echo "Claude Code에서 worktree를 사용하는 방법:"
echo ""
echo "  # 이름 지정"
echo "  claude --worktree feature-auth"
echo "  claude -w bugfix-123"
echo ""
echo "  # 자동 이름 (랜덤)"
echo "  claude --worktree"
echo ""
echo "  # worktree + tmux (백그라운드)"
echo "  claude --worktree feature --tmux"
echo ""
echo "  # headless + worktree (자동화)"
echo "  claude -p '테스트 실행' --worktree test-run --max-turns 5"
echo ""

echo "Claude worktree를 생성하시겠습니까? (y/n)"
read -r answer
if [ "$answer" = "y" ]; then
  echo ""
  echo "실행: claude --worktree level11-test"
  echo "→ .claude/worktrees/level11-test/ 에 격리 환경 생성"
  echo "→ worktree-level11-test 브랜치에서 작업"
  echo "→ 종료 시 변경 없으면 자동 삭제"
  echo ""
  claude --worktree level11-test
fi
echo ""

# ============================================
# 실습 3: 병렬 작업 시나리오
# ============================================
echo "--- 실습 3: 병렬 작업 패턴 ---"
echo ""
echo "실전에서 이렇게 활용합니다:"
echo ""
echo "  # 터미널 1: 기능 개발"
echo "  claude -w feature-auth"
echo ""
echo "  # 터미널 2: 동시에 버그 수정"
echo "  claude -w bugfix-login"
echo ""
echo "  # 터미널 3: 동시에 테스트 작성"
echo "  claude -w add-tests"
echo ""
echo "  → 3개의 독립된 브랜치에서 동시 작업!"
echo "  → 서로의 파일 변경이 간섭하지 않음"
echo ""

echo "============================================"
echo "핵심 정리:"
echo "  --worktree, -w  : 격리된 작업 공간 생성"
echo "  위치            : .claude/worktrees/<이름>/"
echo "  브랜치          : worktree-<이름>"
echo "  정리            : 변경 없으면 자동 삭제"
echo "  조합            : -p + -w = 격리된 자동화"
echo "  병렬            : 터미널 여러 개로 동시 작업"
echo "============================================"
