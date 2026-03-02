'use client';

import Link from 'next/link';
import { type LevelMeta, isNew, CATEGORY_COLORS } from '@/lib/level-types';

interface LevelCardProps {
  level: LevelMeta;
  isCompleted: boolean;
  onToggleComplete: (slug: string) => void;
}

/**
 * 레벨 카드 컴포넌트 — 대시보드 그리드에 표시
 */
export default function LevelCard({ level, isCompleted, onToggleComplete }: LevelCardProps) {
  const showNew = isNew(level.updatedAt);
  const categoryColor = CATEGORY_COLORS[level.category] || '';

  return (
    <div className="group relative rounded-xl border border-line bg-card p-5 transition-all hover:bg-card-hover hover:shadow-lg hover:shadow-accent/5">
      {/* 상단: 레벨 번호 + 배지 */}
      <div className="mb-3 flex items-center justify-between">
        <span className="text-sm font-medium text-muted">
          Level {level.level}
        </span>
        <div className="flex items-center gap-2">
          {showNew && (
            <span className="rounded-full bg-accent px-2 py-0.5 text-xs font-bold text-white">
              NEW
            </span>
          )}
          <span className={`rounded-full border px-2 py-0.5 text-xs ${categoryColor}`}>
            {level.category}
          </span>
        </div>
      </div>

      {/* 제목 */}
      <Link href={`/levels/${level.slug}`} className="block">
        <h3 className="mb-2 text-lg font-bold text-fg group-hover:text-accent transition-colors">
          {level.title}
        </h3>
      </Link>

      {/* 설명 */}
      <p className="mb-4 text-sm text-muted line-clamp-2">
        {level.description}
      </p>

      {/* 하단: 시간 + 완료 체크 */}
      <div className="flex items-center justify-between">
        <span className="text-xs text-muted">
          ~{level.estimatedMinutes}분
        </span>
        <button
          onClick={(e) => {
            e.preventDefault();
            onToggleComplete(level.slug);
          }}
          className={`flex h-6 w-6 items-center justify-center rounded-md border transition-all ${
            isCompleted
              ? 'border-success bg-success text-white'
              : 'border-line hover:border-accent'
          }`}
          title={isCompleted ? '완료 취소' : '완료로 표시'}
        >
          {isCompleted && (
            <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={3}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
            </svg>
          )}
        </button>
      </div>

      {/* 태그 */}
      <div className="mt-3 flex flex-wrap gap-1">
        {level.tags.slice(0, 3).map(tag => (
          <span key={tag} className="rounded bg-fg/5 px-1.5 py-0.5 text-xs text-muted">
            {tag}
          </span>
        ))}
      </div>
    </div>
  );
}
