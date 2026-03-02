import { getAllLevels, CATEGORY_ORDER, CATEGORY_COLORS } from '@/lib/levels';
import Dashboard from './Dashboard';

// 대시보드 페이지 — 서버 컴포넌트에서 데이터 로드
export default function Home() {
  const levels = getAllLevels();

  return <Dashboard levels={levels} categoryOrder={[...CATEGORY_ORDER]} categoryColors={CATEGORY_COLORS} />;
}
