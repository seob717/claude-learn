'use client';

import { useState, useEffect } from 'react';
import { type LevelMeta } from '@/lib/level-types';
import { getProgress, toggleLevelComplete } from '@/lib/progress';
import LevelCard from '@/components/LevelCard';
import ProgressTracker from '@/components/ProgressTracker';

interface DashboardProps {
  levels: LevelMeta[];
  categoryOrder: string[];
  categoryColors: Record<string, string>;
}

/**
 * 대시보드 클라이언트 컴포넌트
 */
export default function Dashboard({ levels, categoryOrder, categoryColors }: DashboardProps) {
  const [completedSlugs, setCompletedSlugs] = useState<string[]>([]);

  useEffect(() => {
    setCompletedSlugs(getProgress().completedLevels);
  }, []);

  const handleToggle = (slug: string) => {
    toggleLevelComplete(slug);
    setCompletedSlugs(getProgress().completedLevels);
  };

  const grouped: Record<string, LevelMeta[]> = {};
  for (const level of levels) {
    if (!grouped[level.category]) {
      grouped[level.category] = [];
    }
    grouped[level.category].push(level);
  }

  return (
    <div className="min-h-screen">
      <header className="border-b border-line bg-card">
        <div className="mx-auto max-w-6xl px-6 py-8">
          <h1 className="mb-2 text-3xl font-bold text-fg">Claude Code 학습 가이드</h1>
          <p className="text-muted">
            기초부터 고급까지, Claude Code를 체계적으로 배우는 한국어 학습 플랫폼
          </p>
        </div>
      </header>

      <main className="mx-auto max-w-6xl px-6 py-8">
        <div className="mb-8">
          <ProgressTracker completed={completedSlugs.length} total={levels.length} />
        </div>

        {categoryOrder.map(category => {
          const categoryLevels = grouped[category];
          if (!categoryLevels) return null;

          return (
            <section key={category} className="mb-10">
              <div className="mb-4 flex items-center gap-3">
                <h2 className="text-xl font-bold text-fg">{category}</h2>
                <span className={`rounded-full border px-2.5 py-0.5 text-xs ${categoryColors[category] || ''}`}>
                  {categoryLevels.length}개
                </span>
              </div>

              <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                {categoryLevels.map(level => (
                  <LevelCard
                    key={level.slug}
                    level={level}
                    isCompleted={completedSlugs.includes(level.slug)}
                    onToggleComplete={handleToggle}
                  />
                ))}
              </div>
            </section>
          );
        })}
      </main>

      <footer className="border-t border-line py-6 text-center text-sm text-muted">
        <p>
          출처:{' '}
          <a href="https://code.claude.com/docs" className="text-accent hover:underline" target="_blank" rel="noopener noreferrer">
            Claude Code 공식 문서
          </a>
          {' · '}
          <a href="https://github.com/anthropics/claude-code" className="text-accent hover:underline" target="_blank" rel="noopener noreferrer">
            GitHub
          </a>
        </p>
      </footer>
    </div>
  );
}
