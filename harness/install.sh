#!/usr/bin/env bash
# 글로벌 하네스 설치 (Mac/Linux/Git-Bash) — harness/dot-claude → ~/.claude
# 사용: bash harness/install.sh [--with-plugins] [--with-mcp]
#   기본: 글로벌 파일(CLAUDE.md·rules·agents·skills)만 복사 (기존본 타임스탬프 백업)
#   --with-plugins : 이어서 setup-plugins.sh 실행
#   --with-mcp     : 이어서 setup-mcp.sh 실행
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/dot-claude"
DEST="${CLAUDE_HOME:-$HOME/.claude}"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="$DEST/_harness-backup-$TS"

[ -d "$SRC" ] || { echo "✗ $SRC 없음. 레포 루트에서 실행하세요."; exit 1; }
mkdir -p "$DEST"

echo "===== 글로벌 하네스 설치 ====="
echo "원본: $SRC"
echo "대상: $DEST"
echo "백업: $BACKUP (기존본 보존)"
echo ""

copy_dir() {  # $1 = 하위 폴더명 (rules/agents/skills)
  local name="$1"
  if [ -e "$DEST/$name" ]; then
    mkdir -p "$BACKUP"; cp -r "$DEST/$name" "$BACKUP/$name"
    echo "  백업: $name → $BACKUP/$name"
  fi
  rm -rf "$DEST/$name"
  cp -r "$SRC/$name" "$DEST/$name"
  echo "✓ 설치: $name ($(ls "$DEST/$name" | wc -l) 항목)"
}

# CLAUDE.md (백업 후 교체)
if [ -f "$DEST/CLAUDE.md" ]; then mkdir -p "$BACKUP"; cp "$DEST/CLAUDE.md" "$BACKUP/CLAUDE.md"; echo "  백업: CLAUDE.md"; fi
cp "$SRC/CLAUDE.md" "$DEST/CLAUDE.md"; echo "✓ 설치: CLAUDE.md"

copy_dir rules
copy_dir agents
copy_dir skills

# settings 는 머신 특화(경로·훅·additionalDirectories) — 자동 덮어쓰지 않고 참조본만 제공
cp "$SRC/settings.reference.json" "$DEST/settings.reference.json"
echo "✓ 참조 제공: settings.reference.json (직접 settings.json에 병합. 자동 적용 안 함)"

echo ""
echo "✓ 글로벌 파일 설치 완료."

# 옵션: 플러그인/MCP
for arg in "$@"; do
  case "$arg" in
    --with-plugins) echo ""; echo "→ 플러그인 설치..."; bash "$SCRIPT_DIR/setup-plugins.sh" ;;
    --with-mcp)     echo ""; echo "→ MCP 설치...";     bash "$SCRIPT_DIR/setup-mcp.sh" ;;
  esac
done

echo ""
echo "다음 단계:"
echo "  1. 플러그인:  bash harness/setup-plugins.sh   (또는 install.sh --with-plugins)"
echo "  2. MCP:       harness/setup-mcp.sh 의 경로 채운 뒤 실행"
echo "  3. settings:  harness/dot-claude/settings.reference.json 을 ~/.claude/settings.json 에 병합"
echo "  4. Claude Code 재시작"
