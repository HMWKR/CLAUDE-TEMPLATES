#!/usr/bin/env bash
# Structural Loop Runner — 결정론적 루프 제어 (control plane = 스크립트)
# 검증된 패턴 코드화: Ralph(while+disk-state+backpressure) · frankbria(dual-exit+circuit-breaker+rate)
#   · OpenHands(evidence-gate) · LoopTrap(객관 완료기준 바인딩) · mini-swe-agent(최소 골격).
# 사용:  bash loop.sh --init        # .harness-loop/ 스캐폴드
#        bash loop.sh --run [opts]   # 결정론적 반복 실행
# opts: --max-calls-per-hour N(기본100) --max-calls N(누적,기본0=무제한) --cooldown MIN(기본30)
#       --no-progress N(기본3) --same-error N(기본5) --agent "<명령>"(기본 claude -p)
set -uo pipefail

DIR=".harness-loop"
MAX_CPH=100; MAX_CALLS=0; COOLDOWN=30; NP_LIMIT=3; SE_LIMIT=5
AGENT_CMD=""   # 비면 기본: claude -p "<prompt.md>"
MODE=""
while [ $# -gt 0 ]; do case "$1" in
  --init) MODE=init; shift ;;
  --run) MODE=run; shift ;;
  --max-calls-per-hour) MAX_CPH="$2"; shift 2 ;;
  --max-calls) MAX_CALLS="$2"; shift 2 ;;
  --cooldown) COOLDOWN="$2"; shift 2 ;;
  --no-progress) NP_LIMIT="$2"; shift 2 ;;
  --same-error) SE_LIMIT="$2"; shift 2 ;;
  --agent) AGENT_CMD="$2"; shift 2 ;;
  *) echo "알 수 없는 옵션: $1"; exit 1 ;;
esac; done

log() { echo "[loop $(date +%H:%M:%S)] $*"; }

if [ "$MODE" = "init" ]; then
  mkdir -p "$DIR"
  [ -f "$DIR/prompt.md" ] || cat > "$DIR/prompt.md" <<'EOF'
# 루프 작업 지시 (payload — 매 이터 새 컨텍스트에 투입)
plan.md에서 **가장 중요한 미완 `[ ]` 1건만** 구현한다(이터당 정확히 하나).
끝나면: 해당 항목을 `[x]`로 갱신 → 변경을 git commit → 모든 백로그 완료 시
.harness-loop/status.json 에 {"exit_signal": true} 기록.
검증은 gate.sh가 한다 — "됐다"고 자기선언하지 말고 실제 코드를 통과시킨다.
EOF
  [ -f "$DIR/plan.md" ] || cat > "$DIR/plan.md" <<'EOF'
# 백로그 (디스크 메모리 — `[ ]` 미완 / `[x]` 완료)
- [ ] (여기에 작업을 1개씩 원자화해서 나열)
EOF
  [ -f "$DIR/gate.sh" ] || cat > "$DIR/gate.sh" <<'EOF'
#!/usr/bin/env bash
# 결정론적 backpressure — exit 0 이어야 이터 통과. 프로젝트에 맞게 수정.
set -e
# 예: npm test --silent ; npx tsc --noEmit ; npm run lint
echo "[gate] 검증 명령 미설정 — gate.sh를 프로젝트에 맞게 작성하세요"; exit 1
EOF
  chmod +x "$DIR/gate.sh" 2>/dev/null || true
  echo '{"iteration":0,"exit_signal":false,"breaker_state":"CLOSED","no_progress_count":0,"same_error_count":0}' > "$DIR/status.json"
  : > "$DIR/progress.log"
  log "초기화 완료: $DIR/{prompt.md,plan.md,gate.sh,status.json,progress.log}"
  log "다음: prompt.md·plan.md·gate.sh 작성 후  bash loop.sh --run"
  exit 0
fi

[ "$MODE" = "run" ] || { echo "사용: loop.sh --init | --run"; exit 1; }
[ -d "$DIR" ] || { echo "✗ $DIR 없음. 먼저 --init."; exit 1; }
command -v git >/dev/null || { echo "✗ git 필요(진척·정체 감지)"; exit 1; }
[ -z "$AGENT_CMD" ] && AGENT_CMD='claude -p "$(cat .harness-loop/prompt.md)"'

iter=0; np=0; se=0; last_err=""; hour_start=$(date +%s); calls_hour=0
plan_exhausted() { ! grep -qE '^\s*[-*] \[ \]' "$DIR/plan.md"; }
exit_signal()    { grep -qE '"exit_signal"\s*:\s*true' "$DIR/status.json" 2>/dev/null; }

log "시작 (max ${MAX_CPH}/h, no-progress×${NP_LIMIT}, same-error×${SE_LIMIT}, cooldown ${COOLDOWN}m)"
while true; do
  # ── Budget: 시간당 호출 상한 (frankbria rate-limit) ──
  now=$(date +%s)
  [ $((now - hour_start)) -ge 3600 ] && { hour_start=$now; calls_hour=0; }
  if [ "$calls_hour" -ge "$MAX_CPH" ]; then
    wait=$((3600 - (now - hour_start)))
    log "rate budget 도달(${MAX_CPH}/h) — ${wait}s 대기"; sleep "$wait"; hour_start=$(date +%s); calls_hour=0
  fi

  iter=$((iter+1)); calls_hour=$((calls_hour+1))
  [ "$MAX_CALLS" -gt 0 ] && [ "$iter" -gt "$MAX_CALLS" ] && { log "누적 호출 상한(${MAX_CALLS}) — STOP"; break; }

  head_before=$(git rev-parse HEAD 2>/dev/null || echo none)
  tree_before=$(git status --porcelain 2>/dev/null | wc -l)

  # ── Agent: fresh-context 1 이터 (Ralph) ──
  log "Round $iter — agent 실행 (fresh context)"
  eval "$AGENT_CMD" >>"$DIR/progress.log" 2>&1 || log "agent 비정상 종료(코드 $?) — 계속"

  # ── Deterministic backpressure gate (Ralph/OpenHands) ──
  gate_out=$(bash "$DIR/gate.sh" 2>&1); gate_exit=$?
  err_sig=""
  [ "$gate_exit" -ne 0 ] && err_sig=$(printf '%s' "$gate_out" | grep -iE 'error|fail' | head -1 | tr -dc '[:alnum:]' | cut -c1-60)

  # ── 진척·정체 산출 (frankbria circuit-breaker) ──
  head_after=$(git rev-parse HEAD 2>/dev/null || echo none)
  tree_after=$(git status --porcelain 2>/dev/null | wc -l)
  if [ "$head_after" != "$head_before" ] || [ "$tree_after" != "$tree_before" ]; then np=0; else np=$((np+1)); fi
  if [ -n "$err_sig" ] && [ "$err_sig" = "$last_err" ]; then se=$((se+1)); else se=$([ -n "$err_sig" ] && echo 1 || echo 0); fi
  last_err="$err_sig"

  printf '{"iteration":%d,"gate_exit":%d,"no_progress_count":%d,"same_error_count":%d,"breaker_state":"%s"}\n' \
    "$iter" "$gate_exit" "$np" "$se" "$([ $np -ge $NP_LIMIT ] || [ $se -ge $SE_LIMIT ] && echo OPEN || echo CLOSED)" >> "$DIR/progress.log"
  log "Round $iter: gate=$gate_exit no_progress=$np same_error=$se"

  # ── Circuit breaker (frankbria 3/5/cooldown) ──
  if [ "$np" -ge "$NP_LIMIT" ] || [ "$se" -ge "$SE_LIMIT" ]; then
    log "⚠ 정체 감지 (no_progress=$np / same_error=$se) → breaker OPEN. cooldown ${COOLDOWN}m 후 1회 재시도 or 인간 개입."
    log "   진척 없으면 STOP. (cooldown 동안 plan.md/gate.sh 점검 권장)"
    sleep $((COOLDOWN*60)); np=0; se=0   # HALF_OPEN: 카운터 리셋 후 1회 더
    continue
  fi

  # ── Dual-condition exit (frankbria) + 객관 완료기준 (LoopTrap) ──
  if plan_exhausted && [ "$gate_exit" -eq 0 ] && exit_signal; then
    log "✓ COMPLETE — plan 소진 + gate exit 0 + exit_signal. (3중 결정론적 종료)"; break
  fi
  plan_exhausted && [ "$gate_exit" -ne 0 ] && log "plan 소진됐으나 gate 미통과 — 종료 보류(자기선언 종료 차단)"
done
log "루프 종료. 감사로그: $DIR/progress.log"
