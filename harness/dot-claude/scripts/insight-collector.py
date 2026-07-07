#!/usr/bin/env python3
"""
Auto-Insight Memory Hook
========================
Stop/PreCompact 훅에서 호출되어 대화 내용에서 중요한 인사이트를 추출하고
프로젝트별 memory 파일에 자동 저장한다.

사용법:
  echo '<hook JSON>' | python3 insight-collector.py stop
  echo '<hook JSON>' | python3 insight-collector.py precompact
"""

import json
import os
import re
import sys
from datetime import date, datetime
from pathlib import Path

# ── 설정 ──

MODEL = "claude-sonnet-4-6"
MIN_MESSAGE_LENGTH = 200      # 이보다 짧은 응답은 스킵
DAILY_LIMIT = 10              # 하루 최대 저장 횟수
SIMILARITY_THRESHOLD = 0.5    # Jaccard 유사도 임계값
STATE_FILE = Path.home() / ".claude" / ".insight-state.json"
MEMORY_BASE = Path.home() / ".claude" / "projects"

EXTRACT_PROMPT = """대화 내용을 분석하여 **프로젝트에 특화된 실용적 인사이트**만 추출하세요.

## 추출 대상 카테고리

- **debugging**: 디버깅 과정에서 발견한 함정, 에러 원인, 해결법
- **pattern**: 이 프로젝트의 코딩 패턴, 컨벤션, 구조적 규칙
- **architecture**: 아키텍처 결정사항, 도메인 경계, 데이터 흐름
- **api-gotcha**: 외부 API/라이브러리의 비직관적 동작, 버전별 차이
- **user-preference**: 사용자가 선호하는 작업 방식, 도구, 스타일

## 규칙

- 사소하거나 일반적인 프로그래밍 지식은 **절대 포함하지 마세요**
- API 키, 비밀번호, 토큰 등 민감 정보는 **절대 포함하지 마세요**
- 이미 알려진 기존 인사이트와 중복되는 내용은 제외하세요
- 인사이트가 없으면 빈 배열 `[]`을 반환하세요
- 각 인사이트는 1-2문장으로 간결하게 작성하세요

## 기존 인사이트 (중복 방지용)

{existing_memory}

## 응답 형식

JSON 배열만 반환하세요 (다른 텍스트 없이):
```json
[
  {{
    "category": "api-gotcha",
    "title": "짧은 제목 (10자 이내)",
    "content": "구체적인 인사이트 내용 (1-2문장)"
  }}
]
```"""


# ── 유틸리티 ──

def get_project_key(cwd: str) -> str:
    """작업 디렉토리에서 프로젝트 키를 생성한다."""
    # Claude Code가 사용하는 형식: c--Users-jusan-Desktop-voiceNote
    normalized = cwd.replace("\\", "/")
    # Windows 드라이브 문자 제거 (C: → 빈문자열, /Users/... 유지)
    if len(normalized) >= 2 and normalized[1] == ":":
        normalized = normalized[2:]
    return "c-" + normalized.replace("/", "-")


def get_memory_dir(cwd: str) -> Path:
    """프로젝트별 메모리 디렉토리 경로를 반환한다."""
    project_key = get_project_key(cwd)
    mem_dir = MEMORY_BASE / project_key / "memory"
    mem_dir.mkdir(parents=True, exist_ok=True)
    return mem_dir


def load_existing_memory(mem_dir: Path) -> str:
    """기존 메모리 파일들의 내용을 로드한다."""
    contents = []
    for md_file in mem_dir.glob("*.md"):
        try:
            text = md_file.read_text(encoding="utf-8", errors="replace")
            contents.append(text)
        except Exception:
            continue
    return "\n".join(contents) if contents else "(없음)"


def tokenize(text: str) -> set:
    """텍스트를 단어 집합으로 변환한다."""
    words = re.findall(r"[a-zA-Z가-힣]+", text.lower())
    return set(w for w in words if len(w) > 2)


def jaccard_similarity(text1: str, text2: str) -> float:
    """두 텍스트의 Jaccard 유사도를 계산한다."""
    set1 = tokenize(text1)
    set2 = tokenize(text2)
    if not set1 or not set2:
        return 0.0
    intersection = set1 & set2
    union = set1 | set2
    return len(intersection) / len(union)


def is_duplicate(new_insight: str, existing_memory: str) -> bool:
    """새 인사이트가 기존 메모리와 중복인지 확인한다."""
    for line in existing_memory.split("\n"):
        line = line.strip()
        if len(line) < 10:
            continue
        if jaccard_similarity(new_insight, line) > SIMILARITY_THRESHOLD:
            return True
    return False


# ── 트랜스크립트 파싱 (Stop/PreCompact 공용) ──

def parse_transcript(transcript_path: str, max_lines: int = 50, max_messages: int = 20) -> str:
    """JSONL 트랜스크립트 파일에서 최근 대화 내용을 추출한다.

    Args:
        transcript_path: JSONL 파일 경로
        max_lines: 파일 끝에서 읽을 최대 줄 수
        max_messages: 추출할 최대 메시지 수

    Returns:
        "[role] text" 형식의 대화 문자열. 실패 시 빈 문자열.
    """
    if not transcript_path or not os.path.exists(transcript_path):
        return ""

    try:
        lines = Path(transcript_path).read_text(encoding="utf-8").splitlines()
        recent = lines[-max_lines:] if len(lines) > max_lines else lines
        messages = []
        for line in recent:
            try:
                msg = json.loads(line)
                role = msg.get("role", "")
                text = ""
                if isinstance(msg.get("content"), str):
                    text = msg["content"]
                elif isinstance(msg.get("content"), list):
                    text = " ".join(
                        c.get("text", "") for c in msg["content"]
                        if isinstance(c, dict) and c.get("type") == "text"
                    )
                if role in ("assistant", "user") and text:
                    messages.append(f"[{role}] {text[:500]}")
            except Exception:
                continue
        return "\n".join(messages[-max_messages:])
    except Exception:
        return ""


# ── 상태 관리 ──

def load_state() -> dict:
    """일일 상태를 로드한다."""
    if STATE_FILE.exists():
        try:
            data = json.loads(STATE_FILE.read_text(encoding="utf-8"))
            if data.get("date") == str(date.today()):
                return data
        except Exception:
            pass
    return {"date": str(date.today()), "count": 0, "lastInsights": []}


def save_state(state: dict):
    """일일 상태를 저장한다."""
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(json.dumps(state, ensure_ascii=False, indent=2), encoding="utf-8")


# ── API 호출 ──

def find_api_key(cwd: str) -> str:
    """ANTHROPIC_API_KEY를 환경변수 → cwd/.env.local → cwd/.env 순서로 탐색한다."""
    api_key = os.environ.get("ANTHROPIC_API_KEY", "")
    if api_key:
        return api_key

    # 훅이 전달한 cwd 기반으로 .env.local / .env 탐색
    for env_file in [".env.local", ".env"]:
        env_path = Path(cwd) / env_file
        if env_path.exists():
            try:
                for line in env_path.read_text(encoding="utf-8").splitlines():
                    if line.startswith("ANTHROPIC_API_KEY="):
                        api_key = line.split("=", 1)[1].strip().strip('"').strip("'")
                        if api_key:
                            return api_key
            except Exception:
                continue

    return ""


def extract_insights(content: str, existing_memory: str, api_key: str) -> list:
    """Sonnet API를 호출하여 인사이트를 추출한다."""
    try:
        import anthropic
    except ImportError:
        return []

    if not api_key:
        return []

    client = anthropic.Anthropic(api_key=api_key)

    prompt = EXTRACT_PROMPT.format(existing_memory=existing_memory[:2000])

    try:
        # Windows 서로게이트 문자 제거
        clean_prompt = prompt.encode("utf-8", errors="replace").decode("utf-8")
        clean_content = content[:4000].encode("utf-8", errors="replace").decode("utf-8")

        response = client.messages.create(
            model=MODEL,
            max_tokens=1024,
            messages=[
                {"role": "user", "content": f"{clean_prompt}\n\n## 분석할 대화 내용\n\n{clean_content}"}
            ],
        )
        text = response.content[0].text.strip()

        # JSON 블록 추출
        json_match = re.search(r"\[[\s\S]*\]", text)
        if json_match:
            return json.loads(json_match.group())
        return []
    except Exception as e:
        print(f"[insight-collector] API error: {e}", file=sys.stderr)
        return []


# ── 메모리 저장 ──

def save_insights(insights: list, mem_dir: Path, existing_memory: str):
    """추출된 인사이트를 auto-insights.md 파일에 저장한다.

    MEMORY.md는 수동 관리 파일이므로 건드리지 않는다.
    카테고리별 오버플로 파일 생성 시 auto-insights.md에 링크를 추가한다.
    """
    insights_file = mem_dir / "auto-insights.md"
    saved = []

    for insight in insights:
        category = insight.get("category", "general")
        title = insight.get("title", "")
        content = insight.get("content", "")

        if not content:
            continue

        full_text = f"{title}: {content}"

        # 중복 확인
        if is_duplicate(full_text, existing_memory):
            continue

        # auto-insights.md 줄 수 확인
        insight_lines = []
        if insights_file.exists():
            insight_lines = insights_file.read_text(encoding="utf-8").splitlines()

        if len(insight_lines) > 180:
            # 카테고리별 파일에 저장
            cat_file = mem_dir / f"{category}.md"
            entry = f"\n## {title} ({date.today()})\n\n{content}\n"
            if cat_file.exists():
                existing = cat_file.read_text(encoding="utf-8")
                cat_file.write_text(existing + entry, encoding="utf-8")
            else:
                header = f"# {category} 인사이트\n"
                cat_file.write_text(header + entry, encoding="utf-8")
                # auto-insights.md에 카테고리 파일 링크 추가
                link_entry = f"\n> 추가 인사이트: [{category}.md]({category}.md)\n"
                if insights_file.exists():
                    existing = insights_file.read_text(encoding="utf-8")
                    insights_file.write_text(existing + link_entry, encoding="utf-8")
        else:
            # auto-insights.md에 추가
            entry = f"\n## {title} ({date.today()})\n\n- **[{category}]** {content}\n"
            if insights_file.exists():
                existing = insights_file.read_text(encoding="utf-8")
                insights_file.write_text(existing + entry, encoding="utf-8")
            else:
                insights_file.write_text(f"# Auto-collected Insights\n\n> 이 파일은 insight-collector 훅이 자동 생성합니다. 수동 편집하지 마세요.\n{entry}", encoding="utf-8")

        saved.append(full_text)
        # 기존 메모리에 추가 (이후 중복 체크용)
        existing_memory += f"\n{full_text}"

    return saved


# ── 메인 ──

def main():
    if len(sys.argv) < 2:
        sys.exit(0)

    event_type = sys.argv[1]  # "stop" or "precompact"

    # stdin에서 훅 JSON 읽기
    try:
        hook_input = json.loads(sys.stdin.read())
    except Exception:
        sys.exit(0)

    cwd = hook_input.get("cwd", os.getcwd())

    # 일일 제한 체크
    state = load_state()
    if state["count"] >= DAILY_LIMIT:
        sys.exit(0)

    # 트랜스크립트에서 대화 내용 추출 (Stop/PreCompact 공용)
    transcript_path = hook_input.get("transcript_path", "")
    content = parse_transcript(transcript_path)

    if not content or len(content) < MIN_MESSAGE_LENGTH:
        sys.exit(0)

    # API 키 탐색 (cwd 기반)
    api_key = find_api_key(cwd)
    if not api_key:
        sys.exit(0)

    # 기존 메모리 로드
    mem_dir = get_memory_dir(cwd)
    existing_memory = load_existing_memory(mem_dir)

    # 인사이트 추출
    insights = extract_insights(content, existing_memory, api_key)
    if not insights:
        sys.exit(0)

    # 저장
    saved = save_insights(insights, mem_dir, existing_memory)

    if saved:
        state["count"] += len(saved)
        state["lastInsights"] = (state.get("lastInsights", []) + saved)[-10:]
        save_state(state)
        print(f"[insight-collector] {len(saved)}개 인사이트 저장됨", file=sys.stderr)

    sys.exit(0)


if __name__ == "__main__":
    main()
