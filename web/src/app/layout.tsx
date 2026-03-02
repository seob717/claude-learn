import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Claude Code 학습 가이드",
  description: "기초부터 고급까지, Claude Code를 체계적으로 배우는 한국어 학습 플랫폼",
};

// 루트 레이아웃 — 한국어 설정, 전역 스타일 적용
export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ko">
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
}
