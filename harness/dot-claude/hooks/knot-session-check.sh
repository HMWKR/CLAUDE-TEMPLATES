#!/bin/bash
# knot SessionStart 체크 — 미등록 프로젝트 / 적체 inbox를 LLM 컨텍스트에 알린다.
# 조용한 실패(vault 없거나 무관 디렉토리면 출력 없이 종료).
set -u

VAULT="${KNOT_VAULT:-$(cat "$HOME/.config/knot/vault" 2>/dev/null)}"
[ -n "$VAULT" ] && [ -d "$VAULT" ] || exit 0

CWD="$(pwd)"
# 발동 증명 로그 — 매 세션 시작 시 훅이 실제 실행됐음을 기록(검증용)
mkdir -p "$HOME/.config/knot" 2>/dev/null
printf '%s  fired  cwd=%s\n' "$(date '+%F %T')" "$CWD" >> "$HOME/.config/knot/hook-fired.log" 2>/dev/null
# vault 자신 / 홈 설정 디렉토리는 제외
case "$CWD" in
  "$VAULT"*|"$HOME/.claude"*|"$HOME/.config"*) exit 0 ;;
esac

SLUG="$(basename "$CWD" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9-' '-' | sed 's/--*/-/g; s/^-//; s/-$//')"
MSG=""

if [ -n "$SLUG" ] && [ ! -d "$VAULT/wiki/projects/$SLUG" ]; then
  MSG="이 프로젝트('$SLUG')는 knot 지식 vault에 미등록입니다. 사용자가 지식 축적을 원할 만한 실프로젝트면 'knot(Obsidian)에 연결할까요?'를 1회 제안하세요(knot-connect 스킬). 강요·반복 금지."
fi

INBOX=$(ls "$VAULT/inbox" 2>/dev/null | grep -v '^\.' | wc -l | tr -d ' ')
if [ "${INBOX:-0}" -gt 0 ]; then
  MSG="${MSG:+$MSG }knot inbox에 미처리 ${INBOX}건 — 'knot ingest'를 제안할 수 있습니다."
fi

[ -z "$MSG" ] && exit 0
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"knot: %s"}}\n' "$MSG"
exit 0
