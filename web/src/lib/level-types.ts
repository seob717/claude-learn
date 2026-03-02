// 클라이언트/서버 공용 타입과 유틸리티

export interface LevelMeta {
  title: string;
  level: number;
  slug: string;
  category: '기초' | '제어' | '확장' | '고급' | '심화';
  description: string;
  createdAt: string;
  updatedAt: string;
  docsUrl?: string;
  docsNote?: string;
  prerequisites: string[];
  estimatedMinutes: number;
  tags: string[];
}

export interface LevelData {
  meta: LevelMeta;
  content: string;
}

/**
 * updatedAt이 7일 이내인지 판별 (NEW 배지용)
 */
export function isNew(updatedAt: string): boolean {
  const updated = new Date(updatedAt);
  const now = new Date();
  const diffDays = (now.getTime() - updated.getTime()) / (1000 * 60 * 60 * 24);
  return diffDays <= 7;
}

// 카테고리 순서 정의
export const CATEGORY_ORDER = ['기초', '제어', '확장', '고급', '심화'] as const;

// 카테고리별 색상 (Tailwind v4 테마 색상 사용)
export const CATEGORY_COLORS: Record<string, string> = {
  '기초': 'bg-emerald-500/10 text-emerald-600 border-emerald-500/20 dark:text-emerald-400',
  '제어': 'bg-blue-500/10 text-blue-600 border-blue-500/20 dark:text-blue-400',
  '확장': 'bg-purple-500/10 text-purple-600 border-purple-500/20 dark:text-purple-400',
  '고급': 'bg-orange-500/10 text-orange-600 border-orange-500/20 dark:text-orange-400',
  '심화': 'bg-rose-500/10 text-rose-600 border-rose-500/20 dark:text-rose-400',
};
