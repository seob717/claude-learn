'use client';

interface ProgressTrackerProps {
  completed: number;
  total: number;
}

/**
 * 진행률 표시 컴포넌트
 */
export default function ProgressTracker({ completed, total }: ProgressTrackerProps) {
  const percent = total > 0 ? Math.round((completed / total) * 100) : 0;

  return (
    <div className="rounded-xl border border-line bg-card p-6">
      <div className="mb-2 flex items-center justify-between">
        <h2 className="text-lg font-bold text-fg">학습 진행률</h2>
        <span className="text-2xl font-bold text-accent">{percent}%</span>
      </div>

      <div className="mb-2 text-sm text-muted">
        {completed} / {total} 레벨 완료
      </div>

      <div className="h-3 overflow-hidden rounded-full bg-fg/10">
        <div
          className="h-full rounded-full bg-gradient-to-r from-accent to-success transition-all duration-500"
          style={{ width: `${percent}%` }}
        />
      </div>

      {percent === 100 && (
        <p className="mt-3 text-sm font-medium text-success">
          모든 레벨을 완료했습니다!
        </p>
      )}
    </div>
  );
}
