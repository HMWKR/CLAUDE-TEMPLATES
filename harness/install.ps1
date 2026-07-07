# 하네스 설치 (Windows PowerShell)
# 사용: pwsh harness/install.ps1 [-Scope global|project] [-Project <경로>]
#                               [-Mode merge|replace] [-WithPlugins] [-WithMcp] [-NoSettings]
#   -NoSettings: settings.json 자동병합 생략(참고본만 제공). 기본은 자동 병합(mode 정책 따름).
#   미지정 + 대화형이면 범위/모드를 묻는다.
#     범위  글로벌 : ~/.claude (모든 프로젝트) -s user · 프로젝트: <proj>/.claude -s project
#     모드  replace: 기존 백업 후 교체 · merge: 덧씌움(비충돌만 추가, 충돌 보존 .harness-incoming + 리포트)
# 소스: CLAUDE.md·rules·settings = harness/dot-claude/ · skills·agents = plugins/jusan-harness/
param(
  [ValidateSet('global','project')] [string]$Scope,
  [string]$Project,
  [ValidateSet('merge','replace')] [string]$Mode,
  [switch]$WithPlugins,
  [switch]$WithMcp,
  [switch]$NoSettings
)
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Dot  = Join-Path $ScriptDir 'dot-claude'
$Plug = Join-Path (Split-Path -Parent $ScriptDir) 'plugins\jusan-harness'
if (-not ((Test-Path $Dot) -and (Test-Path $Plug))) { Write-Host "X 소스 없음. 레포 루트에서 실행하세요." -ForegroundColor Red; exit 1 }

# 범위 — -Project 경로가 있으면 scope=project 확정(플래그 병기·순서 무관, install.sh와 동작 통일)
if ($Project) { $Scope = 'project' }
$NonInteractive = [Console]::IsInputRedirected -or (-not [Environment]::UserInteractive)   # 파이프/리다이렉트/서비스 = 비대화형(sh의 [ -t 0 ]과 의미 정합)
if (-not $Scope) {
  if ($NonInteractive) { $Scope = 'global' }   # 비대화형: 글로벌 기본(파이프 stdin을 프롬프트 답으로 소비하지 않음)
  else {
    try {
      Write-Host "설치 범위:"; Write-Host "  1) 글로벌   — ~/.claude (모든 프로젝트)"; Write-Host "  2) 프로젝트 — 특정 .claude/ 만"
      $c = Read-Host "선택 [1/2] (기본 1)"; $Scope = if ($c -eq '2') { 'project' } else { 'global' }
    } catch { $Scope = 'global' }
  }
}
if ($Scope -eq 'project') {
  if (-not $Project) { if (-not $NonInteractive) { try { $Project = Read-Host "프로젝트 경로 (기본: 현재 $((Get-Location).Path))" } catch {} }; if (-not $Project) { $Project = (Get-Location).Path } }
  $ProjectRoot = (Resolve-Path $Project).Path
  $Dest = Join-Path $ProjectRoot '.claude'; $ClaudeMdDest = Join-Path $ProjectRoot 'CLAUDE.md'; $PluginScope = 'project'
} else {
  $Dest = if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $env:USERPROFILE '.claude' }
  $ClaudeMdDest = Join-Path $Dest 'CLAUDE.md'; $PluginScope = 'user'
}

# ── 심층 분석 + 모드 추천 (설치 시작 전) ──────────────────────────
$HasExisting = (Test-Path $ClaudeMdDest) -or (Test-Path (Join-Path $Dest 'rules')) -or (Test-Path (Join-Path $Dest 'skills')) -or (Test-Path (Join-Path $Dest 'agents')) -or (Test-Path (Join-Path $Dest 'commands')) -or (Test-Path (Join-Path $Dest 'settings.json'))
$script:Reco = 'replace'
function Analyze-Existing {   # 대상 머신의 기존 하네스를 스캔하고 모드를 추천한다
  Write-Host ""
  Write-Host "===== 기존 하네스 심층 분석 ($Dest) =====" -ForegroundColor Cyan
  $cl = '없음'; $st = '없음'; $nrules = 0; $nskills = 0; $nagents = 0
  if (Test-Path $ClaudeMdDest) {
    $nlines = @(Get-Content $ClaudeMdDest).Count   # 빈 줄 포함 총 줄수(wc -l 정합; Measure-Object -Line은 빈 줄 미집계)
    if (-not $nlines) { $nlines = 0 }
    $cl = "있음(${nlines}줄)"
  }
  $rulesDir = Join-Path $Dest 'rules'
  if (Test-Path $rulesDir) { $nrules = (Get-ChildItem $rulesDir -Filter '*.md' -File -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count }
  $skillsDir = Join-Path $Dest 'skills'
  if (Test-Path $skillsDir) { $nskills = (Get-ChildItem $skillsDir -Directory -ErrorAction SilentlyContinue | Measure-Object).Count }
  $agentsDir = Join-Path $Dest 'agents'
  if (Test-Path $agentsDir) { $nagents = (Get-ChildItem $agentsDir -Filter '*.md' -File -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count }
  if (Test-Path (Join-Path $Dest 'settings.json')) { $st = '있음' }
  Write-Host "  CLAUDE.md: $cl · rules: $nrules · skills: $nskills · agents: $nagents · settings.json: $st"
  if (-not $HasExisting) {
    $script:Reco = 'replace'
    Write-Host "  -> 추천: [완전 치환] — 기존 하네스 없음/최소 -> 깨끗한 신규 설치." -ForegroundColor Cyan
  } elseif (Test-Path (Join-Path $Dest '.harness-source')) {
    $prevMode = ((Get-Content (Join-Path $Dest '.harness-source') -ErrorAction SilentlyContinue | Where-Object { $_ -match '^mode=' } | Select-Object -First 1) -replace '^mode=','').Trim()
    if ($prevMode -eq 'merge') {
      $script:Reco = 'merge'   # 이전 설치가 merge = 커스텀+우리것 혼합 환경 -> 커스텀 보존 위해 merge 유지(replace면 커스텀이 활성에서 밀림)
      Write-Host "  -> 추천: [개선(merge)] — 내 하네스를 merge로 올린 이력(혼합 환경) 감지 -> 커스텀 보존 위해 merge 유지. (전면 교체 원하면 [완전 치환] — 기존 타임스탬프 백업)" -ForegroundColor Cyan
    } else {
      $script:Reco = 'replace'
      Write-Host "  -> 추천: [완전 치환=업그레이드] — 내 깃허브 하네스 이전 설치(replace) 감지 -> 최신본으로 클린 업그레이드(기존 백업)." -ForegroundColor Cyan
    }
  } else {
    $script:Reco = 'merge'
    Write-Host "  -> 추천: [개선(merge)] — 외부/커스텀 하네스 감지(우리 설치 마커 없음) -> 보존하며 우리 것 덧씌움, 충돌은 Claude Code에서 'harness-merge-advisor'로 심층 분석 권장." -ForegroundColor Cyan
    Write-Host "    (기존을 전부 밀고 내 깃허브 하네스로 완전 교체하려면 [완전 치환] — 기존은 타임스탬프 백업됨)" -ForegroundColor Cyan
  }
}
if (-not $Mode) {
  Analyze-Existing
  if ($NonInteractive) { $Mode = $script:Reco }   # 비대화형(파이프/리다이렉트/서비스): 추천 채택 — [Console]::IsInputRedirected 기준(UserInteractive는 파이프에서도 true라 부적합)
  else {
    try {
      Write-Host ""; Write-Host "설치 모드 [추천: $($script:Reco)]:"
      Write-Host "  1) 개선(merge)     — 기존 하네스 유지, 우리 것 덧씌움(충돌 보존->advisor)"
      Write-Host "  2) 완전치환(replace) — 기존 하네스 백업 후 내 깃허브 하네스로 전면 교체"
      $m = Read-Host "선택 [1/2] (엔터=추천 $($script:Reco))"
      # 빈 입력=추천, 1/merge=merge, 2/replace=replace, 그 외 무효 입력은 안전하게 merge(비파괴) — 문자 'merge' 입력이 replace로 뒤집히지 않게
      $Mode = switch -Regex ($m) {
        '^\s*$'            { $script:Reco; break }
        '^(1|merge|m)$'    { 'merge'; break }
        '^(2|replace|r)$'  { 'replace'; break }
        default            { Write-Host "  (알 수 없는 입력 '$m' — 안전하게 merge 채택)" -ForegroundColor Yellow; 'merge' }
      }
    } catch { $Mode = $script:Reco }
  }
}
if ($Mode -ne 'merge' -and $Mode -ne 'replace') { Write-Host "X 잘못된 mode: $Mode" -ForegroundColor Red; exit 1 }

$Ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$Backup = Join-Path $Dest "_harness-backup-$Ts"
$Report = Join-Path $Dest "harness-merge-report-$Ts.txt"
New-Item -ItemType Directory -Force -Path $Dest | Out-Null

Write-Host ""
Write-Host "===== 하네스 설치 (scope=$Scope, mode=$Mode) =====" -ForegroundColor Cyan
Write-Host "대상: $Dest"; if ($Scope -eq 'project') { Write-Host "CLAUDE.md: $ClaudeMdDest" }
Write-Host "플러그인/MCP 스코프: -s $PluginScope`n"

$script:Added = 0; $script:Ident = 0; $script:Conflicts = 0
function Same($a, $b) { (Get-FileHash $a).Hash -eq (Get-FileHash $b).Hash }

function Place-ClaudeMd {
  if (-not (Test-Path $ClaudeMdDest)) { Copy-Item (Join-Path $Dot 'CLAUDE.md') $ClaudeMdDest; Write-Host "OK CLAUDE.md 신규"; $script:Added++; return }
  if (Same (Join-Path $Dot 'CLAUDE.md') $ClaudeMdDest) { Write-Host "= CLAUDE.md 동일(스킵)"; $script:Ident++; return }
  if ($Mode -eq 'replace') { New-Item -ItemType Directory -Force -Path $Backup | Out-Null; Copy-Item $ClaudeMdDest (Join-Path $Backup 'CLAUDE.md') -Force; Copy-Item (Join-Path $Dot 'CLAUDE.md') $ClaudeMdDest -Force; Remove-Item "$ClaudeMdDest.harness-incoming" -Force -ErrorAction SilentlyContinue; Write-Host "OK CLAUDE.md 교체(백업, 스테일 incoming 정리)" }
  else { Copy-Item (Join-Path $Dot 'CLAUDE.md') "$ClaudeMdDest.harness-incoming" -Force; Write-Host "! CLAUDE.md 충돌 - 보존(.harness-incoming)" -ForegroundColor Yellow; Add-Content $Report "CONFLICT CLAUDE.md ($ClaudeMdDest)"; $script:Conflicts++ }
}

function Put-Tree([string]$src, [string]$name) {
  $dest = Join-Path $Dest $name
  if ($Mode -eq 'replace') {
    if (Test-Path $dest) { New-Item -ItemType Directory -Force -Path $Backup | Out-Null; Copy-Item $dest (Join-Path $Backup $name) -Recurse -Force; Remove-Item $dest -Recurse -Force }
    Copy-Item $src $dest -Recurse -Force; $n = (Get-ChildItem $dest -Recurse -File | Measure-Object).Count; $script:Added += $n; Write-Host "OK $name 교체 설치 ($n 파일)" -ForegroundColor Green; return
  }
  $srcFull = (Resolve-Path $src).Path
  Get-ChildItem $src -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($srcFull.Length).TrimStart([char]92, [char]47)
    $tf = Join-Path $dest $rel
    if (-not (Test-Path $tf)) { New-Item -ItemType Directory -Force -Path (Split-Path $tf) | Out-Null; Copy-Item $_.FullName $tf; $script:Added++ }
    elseif (Same $_.FullName $tf) { $script:Ident++ }
    else { Copy-Item $_.FullName "$tf.harness-incoming" -Force; Add-Content $Report "CONFLICT $name/$rel"; $script:Conflicts++ }
  }
  Write-Host "OK $name merge 완료" -ForegroundColor Green
}

Place-ClaudeMd
Put-Tree (Join-Path $Dot 'rules') 'rules'
Put-Tree (Join-Path $Plug 'agents') 'agents'
Put-Tree (Join-Path $Plug 'skills') 'skills'
# 현행 하네스 정의(2026-07-07): L0 어댑터·훅 스크립트·오케스트레이션 워크플로·커맨드·검증템플릿.
# 훅(settings)이 ~/.claude/scripts/* 를 참조하고 L0가 adapters/ 프로파일을 필요로 하므로 필수 복사.
foreach ($d in @('adapters','scripts','workflows','commands','verification-templates','hooks')) {
  $srcDir = Join-Path $Dot $d
  if (Test-Path $srcDir) { Put-Tree $srcDir $d }
}

# settings 자동 병합 — merge-settings.py 정본 정책(replace=reference우선 / merge=사용자우선, 리스트 union). 백업+검증+실패 시 롤백.
Copy-Item (Join-Path $Dot 'settings.reference.json') (Join-Path $Dest 'settings.reference.json') -Force
$settingsTgt = Join-Path $Dest 'settings.json'
$py = Get-Command python3 -ErrorAction SilentlyContinue
if (-not $py) { $py = Get-Command python -ErrorAction SilentlyContinue }
if ($NoSettings) {
  Write-Host "OK settings.reference.json 제공(-NoSettings: 자동병합 생략 -> 수동 병합)" -ForegroundColor Green
} elseif (-not $py) {
  Write-Host "! python 없음 -> settings 자동병합 생략. settings.reference.json 수동 병합 필요" -ForegroundColor Yellow
} else {
  $had = Test-Path $settingsTgt
  if ($had) { New-Item -ItemType Directory -Force -Path $Backup | Out-Null; Copy-Item $settingsTgt (Join-Path $Backup 'settings.json') -Force }
  $tmp = "$settingsTgt.merge-tmp"
  # PS5.1 함정 회피: EAP=Stop 상태에서 네이티브 stderr(merge 성공 메시지)가 NativeCommandError로 throw됨 → 임시 Continue + 전 스트림 폐기
  $prevEAP = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
  & $py.Source (Join-Path $Dot 'scripts\merge-settings.py') (Join-Path $Dot 'settings.reference.json') $settingsTgt $Mode $tmp *>$null
  $mergeExit = $LASTEXITCODE
  $ErrorActionPreference = $prevEAP
  if (($mergeExit -eq 0) -and (Test-Path $tmp)) {
    Move-Item $tmp $settingsTgt -Force
    if ($had) { Write-Host "OK settings.json 자동 병합(mode=$Mode, 기존 백업)" -ForegroundColor Green } else { Write-Host "OK settings.json 신규 생성(reference)" -ForegroundColor Green }
  } else {
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
    Write-Host "! settings 병합 실패 -> 기존 settings.json 유지, 수동 병합 필요" -ForegroundColor Yellow
  }
}
# 재설치/업그레이드 감지용 source marker — 다음 실행 심층분석이 이전 설치(및 그 mode)를 인식해 적절한 모드를 추천
$MarkerPath = Join-Path $Dest '.harness-source'
if (Test-Path $MarkerPath) { New-Item -ItemType Directory -Force -Path $Backup | Out-Null; Copy-Item $MarkerPath (Join-Path $Backup '.harness-source') -Force }   # 이전 마커 이력 백업(설치 시각·mode 보존)
Set-Content -Path $MarkerPath -Value "source=HMWKR/CLAUDE-TEMPLATES`ninstalled=$Ts`nmode=$Mode`nscope=$Scope" -Encoding ascii   # ASCII(BOM 없음) — bash head -1/grep 교차 호환
if ($Scope -eq 'project') {
  Write-Host "  i 프로젝트 범위: rules/는 자동주입 안 됨(보존). CLAUDE.md/skills/agents는 프로젝트 로드." -ForegroundColor Cyan
  Write-Host "  i git 추적 프로젝트면 .gitignore 추가 권장: .claude/_harness-backup-*/ .claude/.harness-source *.harness-incoming harness-merge-report-*.txt" -ForegroundColor Cyan
}

Write-Host "`n===== 요약: 추가 $($script:Added) · 동일 $($script:Ident) · 충돌 $($script:Conflicts) =====" -ForegroundColor Cyan
if ($script:Conflicts -gt 0) {
  Write-Host "! 충돌 $($script:Conflicts)건 - 기존 안 덮음. 우리 버전 *.harness-incoming 으로 배치." -ForegroundColor Yellow
  Write-Host "  리포트: $Report"
  Write-Host "  -> Claude Code에서 'harness-merge-advisor' 스킬(또는 '하네스 충돌 분석해줘')로 심층 분석·제안 권장." -ForegroundColor Cyan
}

function Invoke-Setup([string]$name) {
  $s = Join-Path $ScriptDir $name
  if ($Scope -eq 'project') { Push-Location $ProjectRoot; try { & $s $PluginScope } finally { Pop-Location } } else { & $s $PluginScope }
}
if ($WithPlugins) { Write-Host "`n-> 플러그인 설치..."; Invoke-Setup 'setup-plugins.ps1' }
if ($WithMcp)     { Write-Host "`n-> MCP 설치...";     Invoke-Setup 'setup-mcp.ps1' }

Write-Host "`n다음: 1) 충돌시 advisor  2) setup-plugins.ps1 $PluginScope  3) setup-mcp.ps1 $PluginScope  4) 재시작 (settings는 자동 병합됨 — -NoSettings로 수동 전환 가능)"
