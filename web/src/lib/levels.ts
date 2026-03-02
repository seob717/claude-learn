// 서버 전용 — fs를 사용하는 MDX 로딩 함수
import fs from 'fs';
import path from 'path';
import matter from 'gray-matter';

// 클라이언트에서도 쓸 수 있는 타입/유틸을 재내보내기
export { type LevelMeta, type LevelData, isNew, CATEGORY_ORDER, CATEGORY_COLORS } from './level-types';
import type { LevelMeta, LevelData } from './level-types';

const CONTENT_DIR = path.join(process.cwd(), 'content', 'levels');

/**
 * 모든 레벨의 메타데이터를 가져온다 (레벨 번호 순 정렬)
 */
export function getAllLevels(): LevelMeta[] {
  const files = fs.readdirSync(CONTENT_DIR).filter(f => f.endsWith('.mdx'));

  return files
    .map(filename => {
      const filePath = path.join(CONTENT_DIR, filename);
      const fileContent = fs.readFileSync(filePath, 'utf-8');
      const { data } = matter(fileContent);
      return data as LevelMeta;
    })
    .sort((a, b) => a.level - b.level);
}

/**
 * 특정 슬러그의 레벨 데이터를 가져온다 (메타 + 본문)
 */
export function getLevelBySlug(slug: string): LevelData | null {
  const files = fs.readdirSync(CONTENT_DIR).filter(f => f.endsWith('.mdx'));

  for (const filename of files) {
    const filePath = path.join(CONTENT_DIR, filename);
    const fileContent = fs.readFileSync(filePath, 'utf-8');
    const { data, content } = matter(fileContent);

    if (data.slug === slug) {
      return {
        meta: data as LevelMeta,
        content,
      };
    }
  }

  return null;
}

/**
 * 모든 레벨 슬러그 목록 (정적 경로 생성용)
 */
export function getAllLevelSlugs(): string[] {
  return getAllLevels().map(level => level.slug);
}
