'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { type LevelMeta, CATEGORY_ORDER, CATEGORY_COLORS } from '@/lib/level-types';

interface NavigationProps {
  levels: LevelMeta[];
  completedSlugs: string[];
}

/**
 * 사이드바 내비게이션 — 카테고리별 레벨 목록
 */
export default function Navigation({ levels, completedSlugs }: NavigationProps) {
  const pathname = usePathname();

  const grouped: Record<string, LevelMeta[]> = {};
  for (const level of levels) {
    if (!grouped[level.category]) {
      grouped[level.category] = [];
    }
    grouped[level.category].push(level);
  }

  return (
    <nav className="flex flex-col gap-1 p-4">
      <Link
        href="/"
        className={`mb-4 rounded-lg px-3 py-2 text-sm font-bold transition-colors ${
          pathname === '/' ? 'bg-accent/10 text-accent' : 'text-fg hover:bg-fg/5'
        }`}
      >
        Claude Code 학습 가이드
      </Link>

      {CATEGORY_ORDER.map(category => {
        const categoryLevels = grouped[category];
        if (!categoryLevels) return null;

        return (
          <div key={category} className="mb-2">
            <div className={`mb-1 rounded px-2 py-1 text-xs font-semibold ${CATEGORY_COLORS[category] || ''}`}>
              {category}
            </div>
            {categoryLevels.map(level => {
              const isActive = pathname === `/levels/${level.slug}`;
              const isComplete = completedSlugs.includes(level.slug);

              return (
                <Link
                  key={level.slug}
                  href={`/levels/${level.slug}`}
                  className={`flex items-center gap-2 rounded-lg px-3 py-1.5 text-sm transition-colors ${
                    isActive
                      ? 'bg-accent/10 text-accent font-medium'
                      : 'text-muted hover:bg-fg/5 hover:text-fg'
                  }`}
                >
                  <span className={`flex h-4 w-4 shrink-0 items-center justify-center rounded text-xs ${
                    isComplete ? 'bg-success text-white' : 'border border-line'
                  }`}>
                    {isComplete && '✓'}
                  </span>
                  <span className="truncate">
                    {level.level}. {level.title}
                  </span>
                </Link>
              );
            })}
          </div>
        );
      })}
    </nav>
  );
}
