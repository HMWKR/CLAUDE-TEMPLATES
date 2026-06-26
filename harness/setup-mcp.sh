#!/usr/bin/env bash
# 하네스 standalone MCP 재현 — 6종 (플러그인 제공 MCP는 플러그인 설치 시 자동)
# 사용: 아래 플레이스홀더를 본인 환경에 맞게 채운 뒤  bash harness/setup-mcp.sh [user|project]  (기본 user)
#   project 범위는 현재 디렉토리의 .mcp.json 에 기록되므로 대상 프로젝트에서 실행할 것.
# 토큰을 레포에 커밋하지 말 것. 필요 시 -e KEY=값 또는 /mcp OAuth 사용.
set -uo pipefail

SCOPE="${1:-user}"
case "$SCOPE" in user|project|local) ;; *) echo "✗ scope는 user|project|local: $SCOPE"; exit 1 ;; esac

command -v claude >/dev/null 2>&1 || { echo "✗ 'claude' CLI 없음. Claude Code 먼저 설치."; exit 1; }
echo "(등록 스코프: -s $SCOPE)"

# ── 머신 특화 경로 (본인 환경에 맞게 수정) ─────────────────────────
SERENA_BIN="${SERENA_BIN:-$HOME/.local/bin/serena}"        # Windows: C:/Users/<you>/.local/bin/serena.exe
VAULT_PATH="${KNOT_VAULT:-$HOME/knot-vault}"               # obsidian vault
# capcut/cantos는 선택. 경로 있을 때만 등록.
PYTHON_VENV="${PYTHON_VENV:-}"                             # 예: .../venv-capcut/bin/python
VECTCUTAPI="${VECTCUTAPI:-}"                               # 예: ~/tools/VectCutAPI
CANTOS_DIR="${CANTOS_DIR:-}"                               # 예: ~/.claude/mcp/cantos
# ────────────────────────────────────────────────────────────────

mcp() { echo "+ mcp add $1"; claude mcp add -s "$SCOPE" "$@" || echo "  ✗ 실패/스킵: $1"; }

# 항상 등록 (외부 경로 의존 없음)
mcp codex -- codex mcp-server
mcp playwright -- npx -y @playwright/mcp@latest

# 경로 의존 — 바이너리/디렉토리 있을 때만
[ -x "$SERENA_BIN" ] && mcp serena -- "$SERENA_BIN" start-mcp-server --context claude-code --project-from-cwd || echo "  (serena 스킵: $SERENA_BIN 없음 — uv tool install serena-agent)"
[ -d "$VAULT_PATH" ] && mcp obsidian -- npx -y obsidian-mcp "$VAULT_PATH" || echo "  (obsidian 스킵: vault $VAULT_PATH 없음)"
[ -n "$PYTHON_VENV" ] && [ -n "$VECTCUTAPI" ] && mcp capcut -- "$PYTHON_VENV" "$VECTCUTAPI/mcp_server.py" || echo "  (capcut 스킵: PYTHON_VENV/VECTCUTAPI 미설정)"
[ -n "$CANTOS_DIR" ] && mcp cantos -- node "$CANTOS_DIR/server.js" || echo "  (cantos 스킵: CANTOS_DIR 미설정)"

echo ""
echo "✓ 완료. 확인: claude mcp list"
echo "ℹ claude.ai 원격 커넥터(Notion/Gmail/Drive 등)는 /mcp 로 OAuth 인증."
