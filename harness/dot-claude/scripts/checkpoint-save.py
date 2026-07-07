#!/usr/bin/env python3
"""
Checkpoint Save — 세션 간 작업 연속성 보장 스크립트

PreCompact/Stop 훅에서 호출되어 현재 작업 상태를 checkpoint.md에 저장.
다음 세션에서 "어디까지 했는지"를 즉시 파악할 수 있게 함.

사용법:
    python3 checkpoint-save.py precompact  # PreCompact 훅에서 호출
    python3 checkpoint-save.py stop        # Stop 훅에서 호출

출력 파일: {프로젝트루트}/checkpoint.md
"""

import json
import os
import re
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path


def _run_git(*args, timeout=3):
    """git 명령 실행. Windows cp949 인코딩 문제 방지를 위해 encoding='utf-8' 강제."""
    try:
        result = subprocess.run(
            ["git"] + list(args),
            capture_output=True, encoding="utf-8", errors="replace", timeout=timeout
        )
        return result
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return None


def get_project_root():
    """git 루트 또는 현재 디렉토리 반환."""
    result = _run_git("rev-parse", "--show-toplevel")
    if result and result.returncode == 0:
        return result.stdout.strip()
    return os.getcwd()


def get_git_diff_stat():
    """세션 중 변경된 파일 요약."""
    try:
        result = _run_git("diff", "--stat", "HEAD")
        staged = _run_git("diff", "--stat", "--cached")
        untracked = _run_git("ls-files", "--others", "--exclude-standard")

        parts = []
        if result and result.stdout and result.stdout.strip():
            parts.append(f"### 수정됨 (unstaged)\n```\n{result.stdout.strip()}\n```")
        if staged and staged.stdout and staged.stdout.strip():
            parts.append(f"### 스테이징됨\n```\n{staged.stdout.strip()}\n```")
        if untracked and untracked.stdout and untracked.stdout.strip():
            files = untracked.stdout.strip().split("\n")
            if len(files) > 10:
                files = files[:10] + [f"... 외 {len(files) - 10}개"]
            parts.append(f"### 새 파일 (untracked)\n```\n" + "\n".join(files) + "\n```")

        return "\n\n".join(parts) if parts else "변경 사항 없음"
    except Exception:
        return "git 정보 수집 실패"


def get_current_branch():
    """현재 브랜치명."""
    result = _run_git("branch", "--show-current")
    if result and result.stdout:
        return result.stdout.strip() or "HEAD detached"
    return "unknown"


def get_recent_commits(n=3):
    """최근 커밋 n개."""
    result = _run_git("log", f"-{n}", "--oneline", "--no-decorate")
    if result and result.stdout:
        return result.stdout.strip() or "커밋 없음"
    return "git log 실패"


def get_todo_state():
    """Claude Code TodoWrite 상태 파일에서 진행 중인 작업 추출."""
    claude_dir = Path.home() / ".claude" / "todos"
    if not claude_dir.exists():
        return None

    # 가장 최근 todo 파일 찾기
    todo_files = sorted(claude_dir.glob("*.json"), key=lambda f: f.stat().st_mtime, reverse=True)
    if not todo_files:
        return None

    try:
        data = json.loads(todo_files[0].read_text(encoding="utf-8"))
        if isinstance(data, list):
            items = data
        elif isinstance(data, dict) and "todos" in data:
            items = data["todos"]
        else:
            return None

        lines = []
        for item in items:
            status = item.get("status", "unknown")
            content = item.get("content", "")
            icon = {"completed": "[x]", "in_progress": "[~]", "pending": "[ ]"}.get(status, "[?]")
            lines.append(f"- {icon} {content}")
        return "\n".join(lines) if lines else None
    except (json.JSONDecodeError, KeyError, IndexError):
        return None


def get_active_plan_progress():
    """~/.claude/plans/에서 최근 수정된 활성 plan 파일의 체크마크 진행 상태 파싱."""
    plans_dir = Path.home() / ".claude" / "plans"
    if not plans_dir.exists():
        return None

    # .completed 제외, 최근 수정순 정렬
    plan_files = [
        f for f in plans_dir.glob("*.md")
        if ".completed" not in f.name
    ]
    if not plan_files:
        return None

    plan_files.sort(key=lambda f: f.stat().st_mtime, reverse=True)
    plan_file = plan_files[0]

    try:
        content = plan_file.read_text(encoding="utf-8")
    except OSError:
        return None

    checked = re.findall(r"- \[x\]\s+(.+)", content)
    unchecked = re.findall(r"- \[ \]\s+(.+)", content)
    total = len(checked) + len(unchecked)

    if total == 0:
        return None

    return {
        "plan_file": plan_file.name,
        "checked": checked,
        "unchecked": unchecked,
        "total": total,
        "done": len(checked),
    }


def auto_update_plan_checkmarks():
    """git diff로 변경 파일을 수집하고, 활성 plan의 [ ] 체크마크를 [x]로 자동 업데이트."""
    plans_dir = Path.home() / ".claude" / "plans"
    if not plans_dir.exists():
        return

    # 변경 파일 수집 (unstaged + staged)
    changed_files = set()
    for args in [("diff", "--name-only", "HEAD"), ("diff", "--name-only", "--cached")]:
        result = _run_git(*args)
        if result and result.stdout:
            for line in result.stdout.strip().split("\n"):
                if line.strip():
                    changed_files.add(line.strip())
    # untracked 파일도 포함
    result = _run_git("ls-files", "--others", "--exclude-standard")
    if result and result.stdout:
        for line in result.stdout.strip().split("\n"):
            if line.strip():
                changed_files.add(line.strip())

    if not changed_files:
        return

    # 최근 활성 plan 파일 찾기
    plan_files = [
        f for f in plans_dir.glob("*.md")
        if ".completed" not in f.name
    ]
    if not plan_files:
        return

    plan_files.sort(key=lambda f: f.stat().st_mtime, reverse=True)
    plan_file = plan_files[0]

    try:
        content = plan_file.read_text(encoding="utf-8")
    except OSError:
        return

    updated = False
    for filepath in changed_files:
        # 파일명 또는 경로 부분 매칭
        basename = os.path.basename(filepath)
        pattern = re.compile(
            r"- \[ \]\s+(.*?" + re.escape(basename) + r".*)",
            re.IGNORECASE
        )
        new_content, count = pattern.subn(
            lambda m: m.group(0).replace("- [ ]", "- [x]", 1),
            content
        )
        if count > 0:
            content = new_content
            updated = True

    if updated:
        try:
            plan_file.write_text(content, encoding="utf-8")
            print(f"[checkpoint] plan 체크마크 자동 업데이트: {plan_file.name}")
        except OSError:
            pass


def save_checkpoint(trigger: str):
    """체크포인트 파일 생성/갱신."""
    # plan 체크마크 자동 업데이트 (먼저 실행)
    auto_update_plan_checkmarks()

    project_root = get_project_root()
    checkpoint_path = os.path.join(project_root, "checkpoint.md")
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    branch = get_current_branch()
    diff_stat = get_git_diff_stat()
    recent = get_recent_commits(3)
    todo = get_todo_state()
    plan_progress = get_active_plan_progress()

    trigger_label = {"precompact": "컨텍스트 압축 전", "stop": "세션 종료"}.get(trigger, trigger)

    content = f"""# Checkpoint — 작업 상태 스냅샷

> 자동 생성됨 | {now} | 트리거: {trigger_label}
> **다음 세션에서 이 파일을 읽고 작업을 이어가세요.**

## 브랜치: `{branch}`

## 최근 커밋
```
{recent}
```

## 변경 사항
{diff_stat}
"""

    if todo:
        content += f"""
## 작업 목록 (TodoWrite)
{todo}
"""

    if plan_progress:
        done = plan_progress["done"]
        total = plan_progress["total"]
        pct = int(done / total * 100) if total > 0 else 0
        remaining = "\n".join(f"  - [ ] {f}" for f in plan_progress["unchecked"][:10])
        content += f"""
## 플랜 진행 상황
- **파일**: `{plan_progress["plan_file"]}`
- **진행**: {done}/{total} ({pct}%)
- **남은 항목**:
{remaining}
"""

    content += """
---
*이 파일은 PreCompact/Stop 훅에 의해 자동 갱신됩니다. `.gitignore`에 추가를 권장합니다.*
"""

    try:
        with open(checkpoint_path, "w", encoding="utf-8") as f:
            f.write(content)
        # .gitignore에 checkpoint.md가 없으면 추가
        gitignore_path = os.path.join(project_root, ".gitignore")
        _ensure_gitignore(gitignore_path, "checkpoint.md")
        print(f"[checkpoint] {trigger_label} 저장 완료: {checkpoint_path}")
    except OSError as e:
        print(f"[checkpoint] 저장 실패: {e}", file=sys.stderr)


def _ensure_gitignore(gitignore_path: str, entry: str):
    """gitignore에 항목이 없으면 추가."""
    try:
        if os.path.exists(gitignore_path):
            existing = Path(gitignore_path).read_text(encoding="utf-8")
            if entry in existing.splitlines():
                return
            with open(gitignore_path, "a", encoding="utf-8") as f:
                f.write(f"\n{entry}\n")
        # .gitignore가 없으면 생성하지 않음 (프로젝트 구조 변경 최소화)
    except OSError:
        pass


def main():
    if len(sys.argv) < 2:
        print("사용법: python3 checkpoint-save.py [precompact|stop]", file=sys.stderr)
        sys.exit(1)

    trigger = sys.argv[1].lower()
    if trigger not in ("precompact", "stop"):
        print(f"[checkpoint] 알 수 없는 트리거: {trigger}", file=sys.stderr)
        sys.exit(1)

    save_checkpoint(trigger)


if __name__ == "__main__":
    main()
