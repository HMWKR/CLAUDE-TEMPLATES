#!/usr/bin/env bash
# 하네스 설치 (Mac/Linux/Git-Bash)
# 사용: bash harness/install.sh [--scope global|project] [--project <경로>]
#                              [--mode merge|replace] [--with-plugins] [--with-mcp] [--no-settings]
#   --no-settings: settings.json 자동병합 생략(참고본만 제공). 기본은 자동 병합(mode 정책 따름).
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

SCOPE=""; PROJECT_ROOT=""; MODE=""; WITH_PLUGINS=0; WITH_MCP=0; NO_SETTINGS=0
while [ $# -gt 0 ]; do
  case "$1" in
    --scope) SCOPE="${2:-}"; shift 2 ;;
    --project) PROJECT_ROOT="${2:-}"; SCOPE="project"; shift 2 ;;
    --mode) MODE="${2:-}"; shift 2 ;;
    --with-plugins) WITH_PLUGINS=1; shift ;;
    --with-mcp) WITH_MCP=1; shift ;;
    --no-settings) NO_SETTINGS=1; shift ;;
    *) echo "알 수 없는 옵션: $1"; exit 1 ;;
  esac
done
# --project 경로가 주어지면 scope=project 확정(플래그 순서·--scope 병기와 무관 — install.ps1과 동작 통일)
[ -n "$PROJECT_ROOT" ] && SCOPE="project"

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

# ── 심층 분석 + 모드 추천 (설치 시작 전) ──────────────────────────
HAS_EXISTING=0; { [ -f "$CLAUDE_MD_DEST" ] || [ -d "$DEST/rules" ] || [ -d "$DEST/skills" ] || [ -d "$DEST/agents" ] || [ -d "$DEST/commands" ] || [ -f "$DEST/settings.json" ]; } && HAS_EXISTING=1
RECO="replace"
analyze_existing() {   # 대상 머신의 기존 하네스를 스캔하고 모드를 추천한다
  echo ""; echo "===== 기존 하네스 심층 분석 ($DEST) ====="
  local nrules=0 nskills=0 nagents=0 cl="없음" st="없음"
  [ -f "$CLAUDE_MD_DEST" ] && cl="있음($(wc -l < "$CLAUDE_MD_DEST" | tr -d ' ')줄)"
  [ -d "$DEST/rules" ]  && nrules=$(find "$DEST/rules" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
  [ -d "$DEST/skills" ] && nskills=$(find "$DEST/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
  [ -d "$DEST/agents" ] && nagents=$(find "$DEST/agents" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
  [ -f "$DEST/settings.json" ] && st="있음"
  echo "  CLAUDE.md: $cl · rules: $nrules · skills: $nskills · agents: $nagents · settings.json: $st"
  if [ "$HAS_EXISTING" = "0" ]; then
    RECO="replace"
    echo "  → 추천: [완전 치환] — 기존 하네스 없음/최소 → 깨끗한 신규 설치."
  elif [ -f "$DEST/.harness-source" ]; then
    local prevmode; prevmode=$(grep -m1 '^mode=' "$DEST/.harness-source" 2>/dev/null | cut -d= -f2)
    if [ "$prevmode" = "merge" ]; then
      RECO="merge"   # 이전 설치가 merge = 커스텀+우리것 혼합 환경 → 커스텀 보존 위해 merge 유지(replace면 커스텀이 활성에서 밀림)
      echo "  → 추천: [개선(merge)] — 내 하네스를 merge로 올린 이력(혼합 환경) 감지 → 커스텀 보존 위해 merge 유지. (전면 교체 원하면 [완전 치환] — 기존 타임스탬프 백업)"
    else
      RECO="replace"
      echo "  → 추천: [완전 치환=업그레이드] — 내 깃허브 하네스 이전 설치(replace) 감지($(head -1 "$DEST/.harness-source" 2>/dev/null)) → 최신본으로 클린 업그레이드(기존 백업)."
    fi
  else
    RECO="merge"
    echo "  → 추천: [개선(merge)] — 외부/커스텀 하네스 감지(우리 설치 마커 없음) → 보존하며 우리 것 덧씌움, 충돌은 Claude Code에서 'harness-merge-advisor'로 심층 분석 권장."
    echo "    (기존을 전부 밀고 내 깃허브 하네스로 완전 교체하려면 [완전 치환] — 기존은 타임스탬프 백업됨)"
  fi
}
if [ -z "$MODE" ]; then
  analyze_existing
  if [ ! -t 0 ]; then MODE="$RECO"   # 비대화형: 추천 채택(없음→replace, 있음→merge=비파괴)
  else
    echo ""; echo "설치 모드 [추천: $RECO]:"
    echo "  1) 개선(merge)     — 기존 하네스 유지, 우리 것 덧씌움(충돌 보존→advisor)"
    echo "  2) 완전치환(replace) — 기존 하네스 백업 후 내 깃허브 하네스로 전면 교체"
    read -rp "선택 [1/2] (엔터=추천 $RECO): " _m
    # 빈 입력=추천, 1/merge=merge, 2/replace=replace, 그 외 무효 입력은 안전하게 merge(비파괴) — 문자 'merge' 입력이 replace로 뒤집히지 않게
    case "$_m" in
      "") MODE="$RECO" ;;
      1|merge|m|M) MODE=merge ;;
      2|replace|r|R) MODE=replace ;;
      *) echo "  (알 수 없는 입력 '$_m' — 안전하게 merge 채택)"; MODE=merge ;;
    esac
  fi
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
  if [ "$MODE" = "replace" ]; then mkdir -p "$BACKUP"; cp "$CLAUDE_MD_DEST" "$BACKUP/CLAUDE.md"; cp "$DOT/CLAUDE.md" "$CLAUDE_MD_DEST"; rm -f "$CLAUDE_MD_DEST.harness-incoming"; echo "✓ CLAUDE.md 교체(기존 백업, 스테일 incoming 정리)"
  else cp "$DOT/CLAUDE.md" "$CLAUDE_MD_DEST.harness-incoming"; echo "⚠ CLAUDE.md 충돌 — 덮지 않음, 우리 버전: CLAUDE.md.harness-incoming"; echo "CONFLICT CLAUDE.md  ($CLAUDE_MD_DEST)" >> "$REPORT"; CONFLICTS=$((CONFLICTS+1)); fi
}

put_tree() {  # $1=src dir  $2=하위명(rules/agents/skills)
  local src="$1" name="$2" dest="$DEST/$2"
  if [ "$MODE" = "replace" ]; then
    [ -e "$dest" ] && { mkdir -p "$BACKUP"; cp -r "$dest" "$BACKUP/$name"; rm -rf "$dest"; }
    cp -r "$src" "$dest"; local _n; _n=$(find "$dest" -type f | wc -l | tr -d ' '); ADDED=$((ADDED+_n)); echo "✓ $name 교체 설치 ($_n 파일)"; return
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
# 현행 하네스 정의(2026-07-07): L0 어댑터·훅 스크립트·오케스트레이션 워크플로·커맨드·검증템플릿.
# 훅(settings)이 ~/.claude/scripts/* 를 참조하고 L0가 adapters/ 프로파일을 필요로 하므로 필수 복사.
for _d in adapters scripts workflows commands verification-templates hooks; do
  [ -d "$DOT/$_d" ] && put_tree "$DOT/$_d" "$_d"
done

# settings 자동 병합 — merge-settings.py 정본 정책(replace=reference우선 / merge=사용자우선, 리스트 union). 백업+검증+실패 시 롤백.
cp "$DOT/settings.reference.json" "$DEST/settings.reference.json"   # 참고본은 항상 제공
_settings_tgt="$DEST/settings.json"
if [ "$NO_SETTINGS" = "1" ]; then
  echo "✓ settings.reference.json 제공(--no-settings: 자동병합 생략 → 수동 병합)"
elif ! command -v python3 >/dev/null 2>&1; then
  echo "⚠ python3 없음 → settings 자동병합 생략. settings.reference.json 수동 병합 필요"
else
  _had=0; [ -f "$_settings_tgt" ] && { _had=1; mkdir -p "$BACKUP"; cp "$_settings_tgt" "$BACKUP/settings.json"; }
  _settings_tmp="$_settings_tgt.merge-tmp"
  if python3 "$DOT/scripts/merge-settings.py" "$DOT/settings.reference.json" "$_settings_tgt" "$MODE" "$_settings_tmp" 2>/dev/null; then
    mv "$_settings_tmp" "$_settings_tgt"
    [ "$_had" = 1 ] && echo "✓ settings.json 자동 병합(mode=$MODE, 기존 백업)" || echo "✓ settings.json 신규 생성(reference)"
  else
    rm -f "$_settings_tmp"; echo "⚠ settings 병합 실패 → 기존 settings.json 유지, settings.reference.json 수동 병합 필요"
  fi
fi
# 재설치/업그레이드 감지용 source marker — 다음 실행의 심층분석이 이전 설치(및 그 mode)를 인식해 적절한 모드를 추천
[ -f "$DEST/.harness-source" ] && { mkdir -p "$BACKUP"; cp "$DEST/.harness-source" "$BACKUP/.harness-source"; }   # 이전 마커 이력 백업(설치 시각·mode 보존)
printf 'source=HMWKR/CLAUDE-TEMPLATES\ninstalled=%s\nmode=%s\nscope=%s\n' "$TS" "$MODE" "$SCOPE" > "$DEST/.harness-source"
if [ "$SCOPE" = "project" ]; then
  echo "  ℹ 프로젝트 범위: rules/는 자동주입 안 됨(보존). CLAUDE.md·skills·agents는 프로젝트 로드."
  echo "  ℹ git 추적 프로젝트면 .gitignore 추가 권장: .claude/_harness-backup-*/ .claude/.harness-source *.harness-incoming harness-merge-report-*.txt"
fi

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
echo "다음 단계: 1) 충돌 있으면 advisor 분석  2) 플러그인 setup-plugins.sh $PLUGIN_SCOPE  3) MCP setup-mcp.sh $PLUGIN_SCOPE  4) 재시작 (settings는 자동 병합됨 — --no-settings로 수동 전환 가능)"
