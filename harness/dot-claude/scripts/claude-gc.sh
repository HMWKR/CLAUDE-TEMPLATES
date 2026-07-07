#!/bin/bash
set -e
# claude-gc.sh — ~/.claude/ 디렉토리 자동 정리 (Windows/Linux 호환)
#
# 사용법: bash ~/.claude/scripts/claude-gc.sh [--dry-run]
#
# 정리 대상:
# 1. debug/ — 7일 이전 파일 삭제
# 2. plans/ — completed 30일 이전 삭제, stale 7일 이전 삭제 (최근 3개 보호)
# 3. __pycache__/ — 정리
# 4. MCP cache/ — 14일 이전 파일 삭제
# 5. .task-state.md — 7일 이전 삭제
# 6. history.jsonl — 90일 이전 항목 truncation

DRY_RUN=false
if [ "$1" = "--dry-run" ]; then
  DRY_RUN=true
  echo "[DRY RUN] 실제 삭제하지 않습니다."
fi

CLAUDE_DIR="$HOME/.claude"
GC_MARKER="$CLAUDE_DIR/.gc-last-run"

echo ""
echo "=== Claude GC 실행 ==="
echo ""

# 1. debug/ 정리 (7일 이전)
DEBUG_DIR="$CLAUDE_DIR/debug"
if [ -d "$DEBUG_DIR" ]; then
  old_count=$(find "$DEBUG_DIR" -name "*.txt" -mtime +7 2>/dev/null | wc -l | tr -d ' ')
  total_count=$(find "$DEBUG_DIR" -name "*.txt" 2>/dev/null | wc -l | tr -d ' ')
  echo "debug/: 총 ${total_count}개, 7일 이전 ${old_count}개"
  if [ "$DRY_RUN" = false ] && [ "$old_count" -gt 0 ]; then
    find "$DEBUG_DIR" -name "*.txt" -mtime +7 -delete 2>/dev/null
    echo "  → ${old_count}개 삭제됨"
  fi
fi

# 2. plans/ 정리 (completed 30일 + stale 7일, 최근 3개 보호)
PLANS_DIR="$CLAUDE_DIR/plans"
if [ -d "$PLANS_DIR" ]; then
  completed=$(find "$PLANS_DIR" -name "*.completed*" -mtime +30 2>/dev/null | wc -l | tr -d ' ')
  total=$(find "$PLANS_DIR" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  echo "plans/: 총 ${total}개, 30일+ completed ${completed}개"

  if [ "$DRY_RUN" = false ]; then
    # completed 30일 이전 삭제
    if [ "$completed" -gt 0 ]; then
      find "$PLANS_DIR" -name "*.completed*" -mtime +30 -delete 2>/dev/null
      echo "  → completed ${completed}개 삭제됨"
    fi

    # stale 7일 이전 삭제 (최근 3개 보호) — Windows 호환 방식
    stale_count=0
    # ls -t로 시간순 정렬 후 최근 3개 제외, 7일+ 된 것만 삭제
    ls -t "$PLANS_DIR"/*.md 2>/dev/null | grep -v ".completed" | tail -n +4 | while read -r f; do
      if find "$f" -mtime +7 -print 2>/dev/null | grep -q .; then
        rm -f "$f"
        stale_count=$((stale_count + 1))
      fi
    done
    echo "  → stale 플랜 정리됨 (최근 3개 보호)"
  fi
fi

# 3. __pycache__/ 정리
for pycache_dir in "$CLAUDE_DIR/scripts/__pycache__" "$CLAUDE_DIR/skills"/*/__pycache__; do
  if [ -d "$pycache_dir" ]; then
    echo "__pycache__/: $pycache_dir"
    if [ "$DRY_RUN" = false ]; then
      rm -rf "$pycache_dir"
      echo "  → 삭제됨"
    fi
  fi
done

# 4. MCP 캐시 정리 (14일 이전)
MCP_CACHE_DIR="$CLAUDE_DIR/plugins/cache"
if [ -d "$MCP_CACHE_DIR" ]; then
  mcp_old=$(find "$MCP_CACHE_DIR" -type f -mtime +14 2>/dev/null | wc -l | tr -d ' ')
  mcp_total=$(find "$MCP_CACHE_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')
  echo "MCP cache/: 총 ${mcp_total}개, 14일 이전 ${mcp_old}개"
  if [ "$DRY_RUN" = false ] && [ "$mcp_old" -gt 0 ]; then
    find "$MCP_CACHE_DIR" -type f -mtime +14 -delete 2>/dev/null
    echo "  → ${mcp_old}개 삭제됨"
  fi
fi

# 5. .task-state.md 정리 (7일 이전)
task_states=$(find "$CLAUDE_DIR" -name ".task-state.md" -mtime +7 2>/dev/null | wc -l | tr -d ' ')
if [ "$task_states" -gt 0 ]; then
  echo ".task-state.md: 7일 이전 ${task_states}개"
  if [ "$DRY_RUN" = false ]; then
    find "$CLAUDE_DIR" -name ".task-state.md" -mtime +7 -delete 2>/dev/null
    echo "  → 삭제됨"
  fi
fi

# 6. history.jsonl truncation (90일 기준, 최근 1000줄 보존)
HISTORY="$CLAUDE_DIR/history.jsonl"
if [ -f "$HISTORY" ]; then
  lines=$(wc -l < "$HISTORY" | tr -d ' ')
  echo "history.jsonl: ${lines}줄"
  if [ "$lines" -gt 1000 ] && [ "$DRY_RUN" = false ]; then
    tail -1000 "$HISTORY" > "$HISTORY.tmp" && mv "$HISTORY.tmp" "$HISTORY"
    new_lines=$(wc -l < "$HISTORY" | tr -d ' ')
    echo "  → ${lines} → ${new_lines}줄로 truncation"
  fi
fi

# GC 완료 마커 (재부팅 안전 — /tmp 대신 ~/.claude/)
date +%s > "$GC_MARKER" 2>/dev/null

echo ""
echo "=== GC 완료 ==="
