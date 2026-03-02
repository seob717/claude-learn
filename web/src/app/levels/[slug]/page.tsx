import { notFound } from 'next/navigation';
import { MDXRemote } from 'next-mdx-remote/rsc';
import { getAllLevelSlugs, getLevelBySlug, getAllLevels } from '@/lib/levels';
import { mdxComponents } from '@/components/MdxComponents';
import LevelPage from './LevelPage';
import remarkGfm from 'remark-gfm';
import rehypeHighlight from 'rehype-highlight';

// 정적 경로 생성
export function generateStaticParams() {
  return getAllLevelSlugs().map(slug => ({ slug }));
}

// 동적 메타데이터
export function generateMetadata({ params }: { params: Promise<{ slug: string }> }) {
  return params.then(({ slug }) => {
    const level = getLevelBySlug(slug);
    if (!level) return { title: '페이지를 찾을 수 없습니다' };

    return {
      title: `Level ${level.meta.level}: ${level.meta.title} — Claude Code 학습`,
      description: level.meta.description,
    };
  });
}

// 레벨 상세 페이지 — 서버 컴포넌트에서 MDX 렌더링
export default async function Page({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const level = getLevelBySlug(slug);

  if (!level) {
    notFound();
  }

  const allLevels = getAllLevels();

  // MDX를 서버에서 렌더링하여 클라이언트 컴포넌트에 전달
  const mdxContent = (
    <article className="mdx-content">
      <MDXRemote
        source={level.content}
        components={mdxComponents}
        options={{
          mdxOptions: {
            remarkPlugins: [remarkGfm],
            rehypePlugins: [rehypeHighlight],
          },
        }}
      />
    </article>
  );

  return (
    <LevelPage meta={level.meta} allLevels={allLevels}>
      {mdxContent}
    </LevelPage>
  );
}
