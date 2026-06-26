#!/usr/bin/env bash
# 글로벌/프로젝트 하네스 설치 (Mac/Linux/Git-Bash) — harness/dot-claude → 대상
# 사용: bash harness/install.sh [--scope global|project] [--project <경로>] [--with-plugins] [--with-mcp]
#   범위 미지정 + 터미널이면 시작 시 대화형으로 묻는다.
#     글로벌  : ~/.claude (이 머신의 모든 프로젝트) · 플러그인/MCP -s user
#     프로젝트: <프로젝트>/.claude (해당 프로젝트만) · 플러그인/MCP -s project
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/dot-claude"

SCOPE=""; PROJECT_ROOT=""; WITH_PLUGINS=0; WITH_MCP=0
while [ $# -gt 0 ]; do
  case "$1" in
    --scope) SCOPE="${2:-}"; shift 2 ;;
    --project) PROJECT_ROOT="${2:-}"; SCOPE="project"; shift 2 ;;
    --with-plugins) WITH_PLUGINS=1; shift ;;
    --with-mcp) WITH_MCP=1; shift ;;
    *) echo "알 수 없는 옵션: $1"; exit 1 ;;
  esac
done

[ -d "$SRC" ] || { echo "✗ $SRC 없음. 레포 루트에서 실행하세요."; exit 1; }

# ── 범위 결정 (미지정 + 대화형이면 묻는다) ──────────────────────────
if [ -z "$SCOPE" ]; then
  if [ -t 0 ]; then
    echo "설치 범위를 선택하세요:"
    echo "  1) 글로벌   — ~/.claude (이 머신의 모든 프로젝트에 적용)"
    echo "  2) 프로젝트 — 특정 프로젝트의 .claude/ 에만 적용"
    read -rp "선택 [1/2] (기본 1): " _c
    case "$_c" in 2) SCOPE="project" ;; *) SCOPE="global" ;; esac
  else
    SCOPE="global"   # 비대화형 기본
  fi
fi

if [ "$SCOPE" = "project" ]; then
  if [ -z "$PROJECT_ROOT" ]; then
    if [ -t 0 ]; then
      read -rp "프로젝트 경로 (기본: 현재 디렉토리 $(pwd)): " PROJECT_ROOT
    fi
    PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
  fi
  PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"   # 절대경로화
  DEST="$PROJECT_ROOT/.claude"
  CLAUDE_MD_DEST="$PROJECT_ROOT/CLAUDE.md"
  PLUGIN_SCOPE="project"
elif [ "$SCOPE" = "global" ]; then
  DEST="${CLAUDE_HOME:-$HOME/.claude}"
  CLAUDE_MD_DEST="$DEST/CLAUDE.md"
  PLUGIN_SCOPE="user"
else
  echo "✗ 잘못된 scope: $SCOPE (global|project)"; exit 1
fi

TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="$DEST/_harness-backup-$TS"
mkdir -p "$DEST"

echo ""
echo "===== 하네스 설치 ($SCOPE) ====="
echo "원본: $SRC"
echo "대상: $DEST"
[ "$SCOPE" = "project" ] && echo "CLAUDE.md: $CLAUDE_MD_DEST (프로젝트 루트)"
echo "백업: $BACKUP (기존본 보존)"
echo "플러그인/MCP 스코프: -s $PLUGIN_SCOPE"
echo ""

copy_dir() {  # $1 = rules|agents|skills
  local name="$1"
  if [ -e "$DEST/$name" ]; then
    mkdir -p "$BACKUP"; cp -r "$DEST/$name" "$BACKUP/$name"; echo "  백업: $name"
  fi
  rm -rf "$DEST/$name"
  cp -r "$SRC/$name" "$DEST/$name"
  echo "✓ 설치: $name ($(ls "$DEST/$name" | wc -l) 항목)"
}

# CLAUDE.md (범위별 위치)
if [ -f "$CLAUDE_MD_DEST" ]; then mkdir -p "$BACKUP"; cp "$CLAUDE_MD_DEST" "$BACKUP/CLAUDE.md"; echo "  백업: CLAUDE.md"; fi
cp "$SRC/CLAUDE.md" "$CLAUDE_MD_DEST"; echo "✓ 설치: CLAUDE.md → $CLAUDE_MD_DEST"

copy_dir rules
copy_dir agents
copy_dir skills

cp "$SRC/settings.reference.json" "$DEST/settings.reference.json"
echo "✓ 참조 제공: settings.reference.json (직접 병합. 자동 적용 안 함)"
[ "$SCOPE" = "project" ] && echo "  ℹ 프로젝트 범위: rules/는 글로벌처럼 자동주입되지 않는다(보존 목적). CLAUDE.md·skills·agents는 프로젝트 로드됨."

echo ""
echo "✓ 파일 설치 완료 ($SCOPE)."

# 옵션: 플러그인/MCP — 프로젝트 범위면 해당 프로젝트 디렉토리에서 실행
run_setup() {  # $1 = setup-plugins.sh|setup-mcp.sh
  if [ "$SCOPE" = "project" ]; then ( cd "$PROJECT_ROOT" && bash "$SCRIPT_DIR/$1" "$PLUGIN_SCOPE" )
  else bash "$SCRIPT_DIR/$1" "$PLUGIN_SCOPE"; fi
}
[ "$WITH_PLUGINS" = "1" ] && { echo ""; echo "→ 플러그인 설치 (-s $PLUGIN_SCOPE)..."; run_setup setup-plugins.sh; }
[ "$WITH_MCP" = "1" ]     && { echo ""; echo "→ MCP 설치 (-s $PLUGIN_SCOPE)...";     run_setup setup-mcp.sh; }

echo ""
echo "다음 단계:"
echo "  1. 플러그인:  bash harness/setup-plugins.sh $PLUGIN_SCOPE   (프로젝트면 해당 폴더에서)"
echo "  2. MCP:       harness/setup-mcp.sh 의 경로 채운 뒤:  bash harness/setup-mcp.sh $PLUGIN_SCOPE"
echo "  3. settings:  $DEST/settings.reference.json 을 settings.json 에 병합"
echo "  4. Claude Code 재시작"
