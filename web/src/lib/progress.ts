'use client';

// localStorage 키
const STORAGE_KEY = 'claude-learn-progress';

export interface Progress {
  completedLevels: string[]; // 완료된 레벨 슬러그 배열
  lastVisited?: string;       // 마지막 방문 슬러그
}

/**
 * 저장된 진행 상태를 읽는다
 */
export function getProgress(): Progress {
  if (typeof window === 'undefined') {
    return { completedLevels: [] };
  }

  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored) {
      return JSON.parse(stored);
    }
  } catch {
    // localStorage 접근 실패 시 기본값 반환
  }

  return { completedLevels: [] };
}

/**
 * 진행 상태를 저장한다
 */
function saveProgress(progress: Progress): void {
  if (typeof window === 'undefined') return;

  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(progress));
  } catch {
    // localStorage 접근 실패 무시
  }
}

/**
 * 레벨 완료 상태를 토글한다
 */
export function toggleLevelComplete(slug: string): boolean {
  const progress = getProgress();
  const index = progress.completedLevels.indexOf(slug);

  if (index === -1) {
    progress.completedLevels.push(slug);
  } else {
    progress.completedLevels.splice(index, 1);
  }

  saveProgress(progress);
  return index === -1; // true면 완료로 변경, false면 미완료로 변경
}

/**
 * 특정 레벨이 완료되었는지 확인
 */
export function isLevelComplete(slug: string): boolean {
  return getProgress().completedLevels.includes(slug);
}

/**
 * 마지막 방문 레벨을 기록한다
 */
export function setLastVisited(slug: string): void {
  const progress = getProgress();
  progress.lastVisited = slug;
  saveProgress(progress);
}

/**
 * 전체 진행률 (퍼센트)
 */
export function getProgressPercent(totalLevels: number): number {
  const { completedLevels } = getProgress();
  if (totalLevels === 0) return 0;
  return Math.round((completedLevels.length / totalLevels) * 100);
}
