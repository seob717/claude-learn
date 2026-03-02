'use client';

import { useState } from 'react';

interface CodeBlockProps {
  children: string;
  className?: string;
}

/**
 * 코드 블록 컴포넌트 — 복사 버튼 포함
 */
export default function CodeBlock({ children, className }: CodeBlockProps) {
  const [copied, setCopied] = useState(false);
  // className 예: "hljs language-bash" → "bash" 추출
  const language = className?.match(/language-(\S+)/)?.[1] || '';

  const handleCopy = async () => {
    await navigator.clipboard.writeText(children);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="group relative mb-4 overflow-hidden rounded-xl border border-white/[0.08]">
      {/* 헤더 바: 언어 라벨 + 복사 버튼 */}
      <div className="flex items-center justify-between bg-[#181825] px-4 py-1.5">
        <span className="text-xs font-medium text-white/40">
          {language || 'code'}
        </span>
        <button
          onClick={handleCopy}
          className="rounded px-2 py-0.5 text-xs text-white/40 transition-colors hover:bg-white/10 hover:text-white/70"
        >
          {copied ? '복사됨!' : '복사'}
        </button>
      </div>
      {/* 코드 본문 */}
      <pre className={className}>
        <code>{children}</code>
      </pre>
    </div>
  );
}
