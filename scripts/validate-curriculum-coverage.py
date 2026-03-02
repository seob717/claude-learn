#!/usr/bin/env python3
# validate-curriculum-coverage.py
# roadmap-topics.json의 토픽들이 MDX 파일에 얼마나 커버되었는지 검사하는 스크립트
# - coveredBy 매핑 + 실제 MDX 파일 내용 검색 두 가지 방법으로 커버리지 확인
# - 커버리지 90% 미만이면 종료 코드 1 반환

import json
import os
import re
import sys
from pathlib import Path

# 경로 설정 (스크립트 위치 기준으로 프로젝트 루트 탐색)
SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent
TOPICS_JSON = SCRIPT_DIR / "roadmap-topics.json"
LEVELS_DIR = PROJECT_ROOT / "web" / "content" / "levels"

# 색상 코드 (터미널 출력 가독성)
RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[0;34m"
NC = "\033[0m"  # 색상 초기화


def load_topics(json_path: Path) -> list[dict]:
    """roadmap-topics.json에서 토픽 목록을 로드합니다."""
    if not json_path.exists():
        print(f"{RED}오류: {json_path} 파일을 찾을 수 없습니다.{NC}")
        sys.exit(1)
    with open(json_path, encoding="utf-8") as f:
        data = json.load(f)
    return data.get("topics", [])


def load_mdx_files(levels_dir: Path) -> dict[str, dict]:
    """
    MDX 파일들을 로드하여 파일명 -> {title, tags, content} 형태의 딕셔너리로 반환합니다.
    frontmatter의 title, tags와 본문 내용을 추출합니다.
    """
    mdx_data = {}

    if not levels_dir.exists():
        print(f"{YELLOW}경고: {levels_dir} 디렉토리가 없습니다.{NC}")
        return mdx_data

    for mdx_file in sorted(levels_dir.glob("*.mdx")):
        filename = mdx_file.name
        content = mdx_file.read_text(encoding="utf-8")

        # frontmatter 파싱 (--- 로 감싸진 YAML 헤더)
        title = ""
        tags = []
        frontmatter_match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
        if frontmatter_match:
            fm_text = frontmatter_match.group(1)
            # title 추출
            title_match = re.search(r"^title:\s*['\"]?(.+?)['\"]?\s*$", fm_text, re.MULTILINE)
            if title_match:
                title = title_match.group(1).strip()
            # tags 추출 (배열 형태: ["tag1", "tag2"] 또는 [tag1, tag2])
            tags_match = re.search(r"^tags:\s*\[(.+?)\]", fm_text, re.MULTILINE)
            if tags_match:
                tags_raw = tags_match.group(1)
                tags = [t.strip().strip("'\"") for t in tags_raw.split(",")]

        mdx_data[filename] = {
            "title": title,
            "tags": tags,
            "content": content.lower(),  # 대소문자 무관 매칭을 위해 소문자화
        }

    return mdx_data


def check_topic_coverage(topic: dict, mdx_data: dict[str, dict]) -> str:
    """
    토픽이 MDX 파일에 커버되었는지 확인합니다.
    두 가지 방법으로 확인:
    1. JSON에 명시된 coveredBy 파일이 실제로 존재하는지
    2. 토픽 name 키워드가 MDX 파일 내용에 포함되어 있는지

    반환값: "full" | "partial" | "none"
    """
    covered_by = topic.get("coveredBy", [])
    topic_name = topic.get("name", "").lower()
    declared_coverage = topic.get("coverage", "none")

    # coveredBy에 명시된 파일들이 실제로 존재하는지 확인
    existing_files = [f for f in covered_by if f in mdx_data]

    if not existing_files:
        # 명시된 파일이 없으면 키워드 검색으로 폴백
        # 토픽 이름의 핵심 키워드를 MDX 본문에서 검색
        keywords = [w for w in topic_name.split() if len(w) > 3]
        if not keywords:
            return "none"

        # 키워드가 어느 MDX 파일에라도 포함되어 있으면 partial로 인정
        for _filename, data in mdx_data.items():
            matched_keywords = sum(1 for kw in keywords if kw in data["content"])
            if matched_keywords >= max(1, len(keywords) // 2):
                return "partial"
        return "none"

    # coveredBy 파일이 존재하면 실제 내용에서 토픽 관련 키워드 확인
    content_match_count = 0
    for filename in existing_files:
        data = mdx_data[filename]
        # 토픽 이름의 핵심 단어가 내용에 있는지 확인
        keywords = [w for w in topic_name.split() if len(w) > 3]
        if not keywords:
            content_match_count += 1
            continue
        matched = sum(1 for kw in keywords if kw in data["content"])
        if matched >= max(1, len(keywords) // 2):
            content_match_count += 1

    # JSON에서 선언된 커버리지와 실제 파일 존재 여부를 종합 판단
    if existing_files and content_match_count > 0:
        return declared_coverage  # JSON 선언값 신뢰
    elif existing_files:
        return "partial"  # 파일은 있지만 내용 매칭 미흡
    else:
        return "none"


def main():
    print("=" * 50)
    print(" 커리큘럼 커버리지 검사 시작")
    print(f" 토픽 파일: {TOPICS_JSON}")
    print(f" MDX 디렉토리: {LEVELS_DIR}")
    print("=" * 50)

    # 데이터 로드
    topics = load_topics(TOPICS_JSON)
    mdx_data = load_mdx_files(LEVELS_DIR)

    print(f"\n로드된 토픽 수: {len(topics)}")
    print(f"로드된 MDX 파일 수: {len(mdx_data)}")
    print()

    # 카테고리별 통계
    category_stats: dict[str, dict] = {}
    # 전체 커버리지 집계
    full_count = 0
    partial_count = 0
    none_count = 0
    none_topics = []

    print("--- 토픽별 커버리지 ---")
    for topic in topics:
        actual_coverage = check_topic_coverage(topic, mdx_data)
        category = topic.get("category", "Unknown")

        # 카테고리별 통계 초기화
        if category not in category_stats:
            category_stats[category] = {"full": 0, "partial": 0, "none": 0}

        # 커버리지 집계
        if actual_coverage == "full":
            full_count += 1
            category_stats[category]["full"] += 1
            status_str = f"{GREEN}[FULL]   {NC}"
        elif actual_coverage == "partial":
            partial_count += 1
            category_stats[category]["partial"] += 1
            status_str = f"{YELLOW}[PARTIAL]{NC}"
        else:
            none_count += 1
            category_stats[category]["none"] += 1
            status_str = f"{RED}[NONE]   {NC}"
            none_topics.append(topic)

        # coveredBy 파일 중 실제 존재하는 파일 표시
        covered_by = topic.get("coveredBy", [])
        existing = [f for f in covered_by if f in mdx_data]
        missing = [f for f in covered_by if f not in mdx_data]
        files_str = ", ".join(existing) if existing else "없음"
        missing_str = f" {RED}(미존재: {', '.join(missing)}){NC}" if missing else ""

        print(f"  {status_str} [{topic['category']:20s}] {topic['name']}")
        print(f"           파일: {files_str}{missing_str}")

    # 전체 커버리지 계산
    total = len(topics)
    # full은 1.0점, partial은 0.5점으로 계산
    coverage_score = (full_count + partial_count * 0.5) / total * 100 if total > 0 else 0

    print()
    print("=" * 50)
    print(" 카테고리별 요약")
    print("=" * 50)
    for cat, stats in sorted(category_stats.items()):
        cat_total = stats["full"] + stats["partial"] + stats["none"]
        print(f"  {cat:30s}: Full={stats['full']}, Partial={stats['partial']}, None={stats['none']} (총 {cat_total})")

    print()
    print("=" * 50)
    print(" 전체 커버리지 요약")
    print("=" * 50)
    print(f"  전체 토픽 수  : {total}")
    print(f"  {GREEN}완전 커버 (full)  : {full_count}{NC}")
    print(f"  {YELLOW}부분 커버 (partial): {partial_count}{NC}")
    print(f"  {RED}미커버 (none)     : {none_count}{NC}")
    print(f"  커버리지 점수 : {coverage_score:.1f}% (full=1.0, partial=0.5 가중치)")

    # 미커버 토픽 경고
    if none_topics:
        print()
        print(f"{RED}경고: 커버되지 않은 토픽 {len(none_topics)}개 발견{NC}")
        for t in none_topics:
            missing_files = [f for f in t.get("coveredBy", []) if f not in mdx_data]
            if missing_files:
                print(f"  - [{t['category']}] {t['name']} (미존재 파일: {', '.join(missing_files)})")
            else:
                print(f"  - [{t['category']}] {t['name']}")

    print()

    # 커버리지 90% 미만이면 실패 종료
    THRESHOLD = 90.0
    if coverage_score < THRESHOLD:
        print(f"{RED}실패: 커버리지 {coverage_score:.1f}%가 기준치 {THRESHOLD}% 미만입니다.{NC}")
        sys.exit(1)
    else:
        print(f"{GREEN}통과: 커버리지 {coverage_score:.1f}%가 기준치 {THRESHOLD}% 이상입니다.{NC}")
        sys.exit(0)


if __name__ == "__main__":
    main()
