interface DocsLinkProps {
  url: string;
  note?: string;
}

/**
 * 공식 문서 바로가기 링크 컴포넌트
 */
export default function DocsLink({ url, note }: DocsLinkProps) {
  return (
    <a
      href={url}
      target="_blank"
      rel="noopener noreferrer"
      className="mb-6 flex items-center gap-3 rounded-lg border border-accent/20 bg-accent/5 px-4 py-3 text-sm transition-all hover:border-accent/40 hover:bg-accent/10"
    >
      <svg className="h-5 w-5 shrink-0 text-accent" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
      </svg>
      <div className="flex-1">
        <span className="font-medium text-accent">공식 문서 바로가기</span>
        {note && <span className="ml-2 text-muted"> — {note}</span>}
      </div>
      <svg className="h-4 w-4 shrink-0 text-accent/60" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
      </svg>
    </a>
  );
}
