#!/usr/bin/env bash
# Structural Loop Runner — 무비용 회귀 테스트 ($0: LLM 호출 없음, 결정론적 doer/no-op 에이전트).
# 검증: (1) happy path → 3중조건 COMPLETE  (2) failure path → 서킷브레이커 OPEN + 조기완료 차단.
# 사용:  bash plugins/jusan-harness/loop-runner/test-loop.sh
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNNER="$HERE/loop.sh"
PASS=0; FAIL=0
report() { if [ "$1" -eq 0 ]; then echo "  ✓ $2"; PASS=$((PASS+1)); else echo "  ✗ $2"; FAIL=$((FAIL+1)); fi; }
command -v git >/dev/null || { echo "git 필요"; exit 1; }

echo "== Test 1: happy path (결정론적 doer, \$0) =="
T1=$(mktemp -d)
(
  cd "$T1"; git init -q; git config user.email t@t; git config user.name t
  bash "$RUNNER" --init >/dev/null
  printf '# plan\n- [ ] a.txt\n- [ ] b.txt\n' > .harness-loop/plan.md
  printf '#!/usr/bin/env bash\nset -e\ngrep -qx A a.txt\ngrep -qx B b.txt\n' > .harness-loop/gate.sh
  cat > doer.sh <<'D'
p=.harness-loop/plan.md; l=$(grep -nE '^- \[ \]' "$p"|head -1); [ -z "$l" ]&&exit 0; n=${l%%:*}
case "$l" in *a.txt*) echo A>a.txt; git add a.txt;; *b.txt*) echo B>b.txt; git add b.txt;; esac
sed -i "${n}s/\[ \]/[x]/" "$p"; git add "$p"; git commit -qm x
grep -qE '^- \[ \]' "$p" || echo '{"exit_signal":true}'>.harness-loop/status.json
D
  out=$(timeout 90 bash "$RUNNER" --run --agent "bash $T1/doer.sh" --max-calls 6 2>&1)
  echo "$out" | grep -q 'COMPLETE' \
    && [ "$(grep -cE '^- \[ \]' .harness-loop/plan.md)" -eq 0 ] \
    && [ -f a.txt ] && [ -f b.txt ]
)
report $? "happy path → COMPLETE · plan 소진 · 두 파일 생성"
rm -rf "$T1"

echo "== Test 2: failure path → 서킷브레이커 OPEN, 조기완료 차단 =="
T2=$(mktemp -d)
(
  cd "$T2"; git init -q; git config user.email t@t; git config user.name t
  bash "$RUNNER" --init >/dev/null
  printf '# plan\n- [ ] never.txt\n' > .harness-loop/plan.md
  printf '#!/usr/bin/env bash\ntest -f never.txt\n' > .harness-loop/gate.sh
  out=$(timeout 60 bash "$RUNNER" --run --agent "true" --cooldown 0 --no-progress 3 --max-calls 3 2>&1)
  echo "$out" | grep -q 'breaker OPEN' \
    && ! echo "$out" | grep -q 'COMPLETE' \
    && [ "$(grep -cE '^- \[ \]' .harness-loop/plan.md)" -eq 1 ] \
    && [ ! -f never.txt ]
)
report $? "failure → breaker OPEN · COMPLETE 없음 · plan 미완 유지"
rm -rf "$T2"

echo ""
echo "결과: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
