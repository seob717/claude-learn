'use client';

import { useState, useEffect, type ReactNode } from 'react';
import Link from 'next/link';
import { type LevelMeta } from '@/lib/level-types';
import { isLevelComplete, toggleLevelComplete, setLastVisited } from '@/lib/progress';
import DocsLink from '@/components/DocsLink';

interface LevelPageProps {
  meta: LevelMeta;
  allLevels: LevelMeta[];
  children: ReactNode; // 서버에서 렌더링된 MDX 콘텐츠
}

/**
 * 개별 레벨 페이지 — 인터랙티브 래퍼 (완료 체크, 내비게이션)
 * MDX 렌더링은 서버 컴포넌트(page.tsx)에서 처리
 */
export default function LevelPage({ meta, allLevels, children }: LevelPageProps) {
  const [completed, setCompleted] = useState(false);

  useEffect(() => {
    setCompleted(isLevelComplete(meta.slug));
    setLastVisited(meta.slug);
  }, [meta.slug]);

  const handleToggleComplete = () => {
    const newState = toggleLevelComplete(meta.slug);
    setCompleted(newState);
  };

  const currentIndex = allLevels.findIndex(l => l.slug === meta.slug);
  const prevLevel = currentIndex > 0 ? allLevels[currentIndex - 1] : null;
  const nextLevel = currentIndex < allLevels.length - 1 ? allLevels[currentIndex + 1] : null;

  return (
    <div className="min-h-screen">
      {/* 상단 바 */}
      <header className="sticky top-0 z-10 border-b border-line bg-bg/80 backdrop-blur-sm">
        <div className="mx-auto flex max-w-4xl items-center justify-between px-6 py-3">
          <Link href="/" className="text-sm text-accent hover:underline">
            ← 대시보드
          </Link>
          <div className="flex items-center gap-3">
            <span className="text-sm text-muted">
              Level {meta.level} · {meta.category}
            </span>
            <button
              onClick={handleToggleComplete}
              className={`rounded-lg px-3 py-1.5 text-sm font-medium transition-all ${
                completed
                  ? 'bg-success text-white'
                  : 'border border-line text-muted hover:border-accent hover:text-accent'
              }`}
            >
              {completed ? '✓ 완료' : '완료로 표시'}
            </button>
          </div>
        </div>
      </header>

      {/* 콘텐츠 */}
      <main className="mx-auto max-w-4xl px-6 py-8">
        <div className="mb-6">
          <h1 className="mb-2 text-3xl font-bold text-fg">
            Level {meta.level}: {meta.title}
          </h1>
          <p className="text-lg text-muted">{meta.description}</p>
          <div className="mt-3 flex items-center gap-4 text-sm text-muted">
            <span>~{meta.estimatedMinutes}분</span>
            <span>업데이트: {meta.updatedAt}</span>
          </div>
        </div>

        {meta.docsUrl && (
          <DocsLink url={meta.docsUrl} note={meta.docsNote} />
        )}

        {meta.prerequisites.length > 0 && (
          <div className="mb-6 rounded-lg border border-warning/20 bg-warning/5 px-4 py-3">
            <span className="text-sm font-medium text-warning">선행 학습: </span>
            {meta.prerequisites.map((prereq, i) => {
              const prereqLevel = allLevels.find(l => l.slug === prereq);
              return (
                <span key={prereq}>
                  {i > 0 && ', '}
                  <Link href={`/levels/${prereq}`} className="text-sm text-accent hover:underline">
                    {prereqLevel ? `Level ${prereqLevel.level}: ${prereqLevel.title}` : prereq}
                  </Link>
                </span>
              );
            })}
          </div>
        )}

        {/* 서버에서 렌더링된 MDX 콘텐츠 */}
        {children}

        {/* 이전/다음 내비게이션 */}
        <nav className="mt-12 flex items-stretch gap-4 border-t border-line pt-8">
          {prevLevel ? (
            <Link
              href={`/levels/${prevLevel.slug}`}
              className="flex-1 rounded-xl border border-line p-4 transition-all hover:border-accent hover:bg-card"
            >
              <span className="text-xs text-muted">← 이전</span>
              <p className="mt-1 font-medium text-fg">Level {prevLevel.level}: {prevLevel.title}</p>
            </Link>
          ) : <div className="flex-1" />}

          {nextLevel ? (
            <Link
              href={`/levels/${nextLevel.slug}`}
              className="flex-1 rounded-xl border border-line p-4 text-right transition-all hover:border-accent hover:bg-card"
            >
              <span className="text-xs text-muted">다음 →</span>
              <p className="mt-1 font-medium text-fg">Level {nextLevel.level}: {nextLevel.title}</p>
            </Link>
          ) : <div className="flex-1" />}
        </nav>
      </main>
    </div>
  );
}
