# Structural Loop Runner (Windows PowerShell) — 결정론적 루프 제어
# loop.sh와 동일 패턴: Ralph backpressure · frankbria dual-exit/circuit-breaker/rate · 객관 완료기준.
# 사용:  pwsh loop.ps1 -Init   |   pwsh loop.ps1 -Run [-MaxCallsPerHour 100] [-Cooldown 30] [-NoProgress 3] [-SameError 5] [-Agent '<명령>']
param(
  [switch]$Init, [switch]$Run,
  [int]$MaxCallsPerHour = 100, [int]$MaxCalls = 0, [int]$Cooldown = 30,
  [int]$NoProgress = 3, [int]$SameError = 5, [string]$Agent = ''
)
$ErrorActionPreference = 'Continue'
$Dir = '.harness-loop'
function Log($m) { Write-Host ("[loop {0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $m) }

if ($Init) {
  New-Item -ItemType Directory -Force -Path $Dir | Out-Null
  if (-not (Test-Path "$Dir\prompt.md")) { @'
# 루프 작업 지시 (payload — 매 이터 새 컨텍스트에 투입)
plan.md에서 가장 중요한 미완 [ ] 1건만 구현(이터당 하나). 끝나면 [x]로 갱신 → git commit →
모든 백로그 완료 시 .harness-loop/status.json 에 {"exit_signal": true}. 자기선언 금지 — gate.sh로 통과시킨다.
'@ | Set-Content "$Dir\prompt.md" -Encoding UTF8 }
  if (-not (Test-Path "$Dir\plan.md")) { "# 백로그 ([ ] 미완 / [x] 완료)`n- [ ] (작업을 1개씩 원자화해 나열)" | Set-Content "$Dir\plan.md" -Encoding UTF8 }
  if (-not (Test-Path "$Dir\gate.sh")) { "#!/usr/bin/env bash`nset -e`n# 결정론적 backpressure — exit 0 이어야 통과. 예: npm test; npx tsc --noEmit`necho '[gate] 미설정'; exit 1" | Set-Content "$Dir\gate.sh" -Encoding UTF8 }
  '{"iteration":0,"exit_signal":false,"breaker_state":"CLOSED","no_progress_count":0,"same_error_count":0}' | Set-Content "$Dir\status.json" -Encoding UTF8
  Set-Content "$Dir\progress.log" '' -Encoding UTF8
  Log "초기화 완료: $Dir. prompt.md·plan.md·gate.sh 작성 후  pwsh loop.ps1 -Run"
  exit 0
}
if (-not $Run) { Write-Host "사용: loop.ps1 -Init | -Run"; exit 1 }
if (-not (Test-Path $Dir)) { Write-Host "X $Dir 없음. 먼저 -Init."; exit 1 }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Write-Host "X git 필요"; exit 1 }
if (-not $Agent) { $Agent = 'claude -p "$(Get-Content -Raw .harness-loop/prompt.md)"' }

function Plan-Exhausted { -not (Select-String -Path "$Dir\plan.md" -Pattern '^\s*[-*] \[ \]' -Quiet) }
function Exit-Signal { (Test-Path "$Dir\status.json") -and (Select-String -Path "$Dir\status.json" -Pattern '"exit_signal"\s*:\s*true' -Quiet) }

$iter = 0; $np = 0; $se = 0; $lastErr = ''; $hourStart = Get-Date; $callsHour = 0
Log "시작 (max $MaxCallsPerHour/h, no-progress x$NoProgress, same-error x$SameError, cooldown ${Cooldown}m)"
while ($true) {
  if (((Get-Date) - $hourStart).TotalSeconds -ge 3600) { $hourStart = Get-Date; $callsHour = 0 }
  if ($callsHour -ge $MaxCallsPerHour) {
    $wait = [int](3600 - ((Get-Date) - $hourStart).TotalSeconds)
    Log "rate budget 도달 — ${wait}s 대기"; Start-Sleep -Seconds $wait; $hourStart = Get-Date; $callsHour = 0
  }
  $iter++; $callsHour++
  if ($MaxCalls -gt 0 -and $iter -gt $MaxCalls) { Log "누적 호출 상한($MaxCalls) — STOP"; break }

  $headBefore = (git rev-parse HEAD 2>$null); if (-not $headBefore) { $headBefore = 'none' }
  $treeBefore = (git status --porcelain 2>$null | Measure-Object).Count

  Log "Round $iter — agent 실행 (fresh context)"
  try { Invoke-Expression $Agent *>> "$Dir\progress.log" } catch { Log "agent 예외 — 계속" }

  $gateOut = & bash "$Dir/gate.sh" 2>&1; $gateExit = $LASTEXITCODE
  $errSig = ''
  if ($gateExit -ne 0) { $errSig = (($gateOut | Select-String -Pattern 'error|fail' | Select-Object -First 1) -replace '[^a-zA-Z0-9]','') ; if ($errSig.Length -gt 60) { $errSig = $errSig.Substring(0,60) } }

  $headAfter = (git rev-parse HEAD 2>$null); if (-not $headAfter) { $headAfter = 'none' }
  $treeAfter = (git status --porcelain 2>$null | Measure-Object).Count
  if ($headAfter -ne $headBefore -or $treeAfter -ne $treeBefore) { $np = 0 } else { $np++ }
  if ($errSig -and $errSig -eq $lastErr) { $se++ } else { $se = $(if ($errSig) { 1 } else { 0 }) }
  $lastErr = $errSig

  $bstate = $(if ($np -ge $NoProgress -or $se -ge $SameError) { 'OPEN' } else { 'CLOSED' })
  Add-Content "$Dir\progress.log" ("{`"iteration`":$iter,`"gate_exit`":$gateExit,`"no_progress_count`":$np,`"same_error_count`":$se,`"breaker_state`":`"$bstate`"}")
  Log "Round ${iter}: gate=$gateExit no_progress=$np same_error=$se"

  if ($np -ge $NoProgress -or $se -ge $SameError) {
    Log "! 정체 감지 (no_progress=$np / same_error=$se) -> breaker OPEN. cooldown ${Cooldown}m 후 1회 재시도."
    Start-Sleep -Seconds ($Cooldown*60); $np = 0; $se = 0; continue
  }
  if ((Plan-Exhausted) -and $gateExit -eq 0 -and (Exit-Signal)) { Log "OK COMPLETE — plan 소진 + gate 0 + exit_signal (3중 종료)"; break }
  if ((Plan-Exhausted) -and $gateExit -ne 0) { Log "plan 소진됐으나 gate 미통과 — 종료 보류(자기선언 차단)" }
}
Log "루프 종료. 감사로그: $Dir\progress.log"
