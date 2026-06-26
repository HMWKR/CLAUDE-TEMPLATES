#!/usr/bin/env bash
# 하네스 플러그인 재현 — 마켓플레이스 13종 + 활성 플러그인 26종
# 사용: bash harness/setup-plugins.sh
# 멱등: 이미 추가/설치된 항목은 CLI가 스킵하거나 무해하게 실패한다.
set -uo pipefail

command -v claude >/dev/null 2>&1 || { echo "✗ 'claude' CLI를 찾을 수 없습니다. Claude Code를 먼저 설치하세요."; exit 1; }

add() { echo "+ marketplace add $1"; claude plugin marketplace add "$1" || echo "  (이미 추가됨/스킵)"; }
ins() { echo "+ install $1"; claude plugin install "$1" -s user || echo "  ✗ 실패/스킵: $1"; }

echo "===== 1/2 마켓플레이스 (13) ====="
add anthropics/claude-plugins-official
add openai/codex-plugin-cc
add accesslint/claude-marketplace
add multica-ai/andrej-karpathy-skills
add bradautomates/claude-video
add Lum1104/Understand-Anything
add rohitg00/agentmemory
add obra/superpowers-marketplace
add Yeachan-Heo/oh-my-claudecode
add netwaif/multi-agent-starter
add fivetaku/fablize
add fivetaku/gptaku_plugins
add popup-studio-ai/bkit-claude-code

echo ""
echo "===== 2/2 활성 플러그인 (26) ====="
ins commit-commands@claude-plugins-official
ins pr-review-toolkit@claude-plugins-official
ins code-review@claude-plugins-official
ins code-simplifier@claude-plugins-official
ins feature-dev@claude-plugins-official
ins frontend-design@claude-plugins-official
ins security-guidance@claude-plugins-official
ins hookify@claude-plugins-official
ins learning-output-style@claude-plugins-official
ins plugin-dev@claude-plugins-official
ins slack@claude-plugins-official
ins supabase@claude-plugins-official
ins stripe@claude-plugins-official
ins context7@claude-plugins-official
ins vercel@claude-plugins-official
ins superpowers@claude-plugins-official
ins codex@openai-codex
ins accesslint@accesslint
ins andrej-karpathy-skills@karpathy-skills
ins watch@claude-video
ins understand-anything@understand-anything
ins agentmemory@agentmemory
ins oh-my-claudecode@omc
ins fablize@fablize
ins insane-search@gptaku-plugins
ins bkit@bkit-marketplace

echo ""
echo "✓ 완료. 확인: claude plugin list"
echo "⚠ insane-search는 Python dep 수동 설치 필요: python3 -m pip install curl_cffi beautifulsoup4 pyyaml"
echo "⚠ Claude Code 재시작 후 전 기능 적용."
