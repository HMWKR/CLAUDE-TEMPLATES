#!/usr/bin/env bash
# 하네스 설치 (Mac/Linux/Git-Bash)
# 사용: bash harness/install.sh [--scope global|project] [--project <경로>]
#                              [--mode merge|replace] [--with-plugins] [--with-mcp]
#   미지정 + 대화형이면 범위/모드를 묻는다.
#     범위  글로벌  : ~/.claude (모든 프로젝트) · 플러그인/MCP -s user
#           프로젝트: <프로젝트>/.claude (해당 프로젝트만) · -s project
#     모드  replace : 기존 하네스 백업 후 우리 것으로 교체
#           merge   : 기존 위에 덧씌움 — 비충돌만 추가, 충돌은 보존(.harness-incoming) + 리포트
# 소스: 글로벌 CLAUDE.md·rules·settings = harness/dot-claude/ · skills·agents = plugins/jusan-harness/
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOT="$SCRIPT_DIR/dot-claude"                 # CLAUDE.md, rules, settings.reference.json
PLUG="$SCRIPT_DIR/../plugins/jusan-harness"  # skills, agents (플러그인 정본)

SCOPE=""; PROJECT_ROOT=""; MODE=""; WITH_PLUGINS=0; WITH_MCP=0
while [ $# -gt 0 ]; do
  case "$1" in
    --scope) SCOPE="${2:-}"; shift 2 ;;
    --project) PROJECT_ROOT="${2:-}"; SCOPE="project"; shift 2 ;;
    --mode) MODE="${2:-}"; shift 2 ;;
    --with-plugins) WITH_PLUGINS=1; shift ;;
    --with-mcp) WITH_MCP=1; shift ;;
    *) echo "알 수 없는 옵션: $1"; exit 1 ;;
  esac
done

[ -d "$DOT" ] && [ -d "$PLUG" ] || { echo "✗ 소스 없음($DOT / $PLUG). 레포 루트에서 실행하세요."; exit 1; }

# ── 범위 ────────────────────────────────────────────────────────
if [ -z "$SCOPE" ]; then
  if [ -t 0 ]; then
    echo "설치 범위:"
    echo "  1) 글로벌   — ~/.claude (이 머신의 모든 프로젝트)"
    echo "  2) 프로젝트 — 특정 프로젝트의 .claude/ 에만"
    read -rp "선택 [1/2] (기본 1): " _c; case "$_c" in 2) SCOPE=project ;; *) SCOPE=global ;; esac
  else SCOPE=global; fi
fi
if [ "$SCOPE" = "project" ]; then
  if [ -z "$PROJECT_ROOT" ]; then
    [ -t 0 ] && read -rp "프로젝트 경로 (기본: 현재 $(pwd)): " PROJECT_ROOT
    PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
  fi
  PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
  DEST="$PROJECT_ROOT/.claude"; CLAUDE_MD_DEST="$PROJECT_ROOT/CLAUDE.md"; PLUGIN_SCOPE="project"
elif [ "$SCOPE" = "global" ]; then
  DEST="${CLAUDE_HOME:-$HOME/.claude}"; CLAUDE_MD_DEST="$DEST/CLAUDE.md"; PLUGIN_SCOPE="user"
else echo "✗ 잘못된 scope: $SCOPE"; exit 1; fi

# ── 모드 ────────────────────────────────────────────────────────
HAS_EXISTING=0; { [ -f "$CLAUDE_MD_DEST" ] || [ -d "$DEST/rules" ] || [ -d "$DEST/skills" ]; } && HAS_EXISTING=1
if [ -z "$MODE" ]; then
  if [ "$HAS_EXISTING" = "0" ]; then MODE="replace"   # 기존 하네스 없으면 교체=깨끗한 신규설치
  elif [ -t 0 ]; then
    echo ""; echo "기존 하네스가 감지되었습니다 ($DEST). 설치 모드:"
    echo "  1) merge   — 기존 위에 덧씌움(비충돌만 추가, 충돌은 보존+리포트→advisor 분석 권장)"
    echo "  2) replace — 기존을 백업 후 우리 하네스로 교체"
    read -rp "선택 [1/2] (기본 1=merge): " _m; case "$_m" in 2) MODE=replace ;; *) MODE=merge ;; esac
  else MODE=merge; fi   # 비대화형 + 기존 존재 → 안전하게 merge(비파괴)
fi
case "$MODE" in merge|replace) ;; *) echo "✗ 잘못된 mode: $MODE"; exit 1 ;; esac

TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="$DEST/_harness-backup-$TS"
REPORT="$DEST/harness-merge-report-$TS.txt"
mkdir -p "$DEST"

echo ""
echo "===== 하네스 설치 (scope=$SCOPE, mode=$MODE) ====="
echo "대상: $DEST"; [ "$SCOPE" = "project" ] && echo "CLAUDE.md: $CLAUDE_MD_DEST"
echo "플러그인/MCP 스코프: -s $PLUGIN_SCOPE"
echo ""

ADDED=0; CONFLICTS=0; IDENT=0

place_claude_md() {
  if [ ! -f "$CLAUDE_MD_DEST" ]; then cp "$DOT/CLAUDE.md" "$CLAUDE_MD_DEST"; echo "✓ CLAUDE.md 신규 설치"; ADDED=$((ADDED+1)); return; fi
  if cmp -s "$DOT/CLAUDE.md" "$CLAUDE_MD_DEST"; then echo "= CLAUDE.md 동일(스킵)"; IDENT=$((IDENT+1)); return; fi
  if [ "$MODE" = "replace" ]; then mkdir -p "$BACKUP"; cp "$CLAUDE_MD_DEST" "$BACKUP/CLAUDE.md"; cp "$DOT/CLAUDE.md" "$CLAUDE_MD_DEST"; echo "✓ CLAUDE.md 교체(기존 백업)"
  else cp "$DOT/CLAUDE.md" "$CLAUDE_MD_DEST.harness-incoming"; echo "⚠ CLAUDE.md 충돌 — 덮지 않음, 우리 버전: CLAUDE.md.harness-incoming"; echo "CONFLICT CLAUDE.md  ($CLAUDE_MD_DEST)" >> "$REPORT"; CONFLICTS=$((CONFLICTS+1)); fi
}

put_tree() {  # $1=src dir  $2=하위명(rules/agents/skills)
  local src="$1" name="$2" dest="$DEST/$2"
  if [ "$MODE" = "replace" ]; then
    [ -e "$dest" ] && { mkdir -p "$BACKUP"; cp -r "$dest" "$BACKUP/$name"; rm -rf "$dest"; }
    cp -r "$src" "$dest"; echo "✓ $name 교체 설치 ($(find "$dest" -type f | wc -l) 파일)"; return
  fi
  # merge
  mkdir -p "$dest"
  while IFS= read -r f; do
    local rel="${f#$src/}" tf="$dest/${f#$src/}"
    if [ ! -e "$tf" ]; then mkdir -p "$(dirname "$tf")"; cp "$f" "$tf"; ADDED=$((ADDED+1))
    elif cmp -s "$f" "$tf"; then IDENT=$((IDENT+1))
    else cp "$f" "$tf.harness-incoming"; echo "CONFLICT $name/$rel" >> "$REPORT"; CONFLICTS=$((CONFLICTS+1)); fi
  done < <(find "$src" -type f)
  echo "✓ $name merge 완료"
}

place_claude_md
put_tree "$DOT/rules" rules
put_tree "$PLUG/agents" agents
put_tree "$PLUG/skills" skills

cp "$DOT/settings.reference.json" "$DEST/settings.reference.json"
echo "✓ settings.reference.json 제공(수동 병합)"
[ "$SCOPE" = "project" ] && echo "  ℹ 프로젝트 범위: rules/는 자동주입 안 됨(보존). CLAUDE.md·skills·agents는 프로젝트 로드."

echo ""
echo "===== 요약: 추가 $ADDED · 동일 $IDENT · 충돌 $CONFLICTS ====="
if [ "$CONFLICTS" -gt 0 ]; then
  echo "⚠ 충돌 $CONFLICTS건 — 기존을 덮지 않았습니다. 우리 버전은 *.harness-incoming 으로 나란히 배치."
  echo "  리포트: $REPORT"
  echo "  👉 Claude Code에서 'harness-merge-advisor' 스킬(또는 \"하네스 충돌 분석해줘\")로 심층 분석·제안·병합 진행 권장."
fi

run_setup() { if [ "$SCOPE" = "project" ]; then ( cd "$PROJECT_ROOT" && bash "$SCRIPT_DIR/$1" "$PLUGIN_SCOPE" ); else bash "$SCRIPT_DIR/$1" "$PLUGIN_SCOPE"; fi; }
[ "$WITH_PLUGINS" = "1" ] && { echo ""; echo "→ 플러그인 설치..."; run_setup setup-plugins.sh; }
[ "$WITH_MCP" = "1" ]     && { echo ""; echo "→ MCP 설치...";     run_setup setup-mcp.sh; }

echo ""
echo "다음 단계: 1) 충돌 있으면 advisor 분석  2) 플러그인 setup-plugins.sh $PLUGIN_SCOPE  3) MCP setup-mcp.sh $PLUGIN_SCOPE  4) settings 병합  5) 재시작"
