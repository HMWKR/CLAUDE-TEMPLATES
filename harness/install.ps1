# 하네스 설치 (Windows PowerShell)
# 사용: pwsh harness/install.ps1 [-Scope global|project] [-Project <경로>]
#                               [-Mode merge|replace] [-WithPlugins] [-WithMcp]
#   미지정 + 대화형이면 범위/모드를 묻는다.
#     범위  글로벌 : ~/.claude (모든 프로젝트) -s user · 프로젝트: <proj>/.claude -s project
#     모드  replace: 기존 백업 후 교체 · merge: 덧씌움(비충돌만 추가, 충돌 보존 .harness-incoming + 리포트)
# 소스: CLAUDE.md·rules·settings = harness/dot-claude/ · skills·agents = plugins/jusan-harness/
param(
  [ValidateSet('global','project')] [string]$Scope,
  [string]$Project,
  [ValidateSet('merge','replace')] [string]$Mode,
  [switch]$WithPlugins,
  [switch]$WithMcp
)
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Dot  = Join-Path $ScriptDir 'dot-claude'
$Plug = Join-Path (Split-Path -Parent $ScriptDir) 'plugins\jusan-harness'
if (-not ((Test-Path $Dot) -and (Test-Path $Plug))) { Write-Host "X 소스 없음. 레포 루트에서 실행하세요." -ForegroundColor Red; exit 1 }

# 범위
if (-not $Scope) {
  if ($Project) { $Scope = 'project' }
  else {
    try {
      Write-Host "설치 범위:"; Write-Host "  1) 글로벌   — ~/.claude (모든 프로젝트)"; Write-Host "  2) 프로젝트 — 특정 .claude/ 만"
      $c = Read-Host "선택 [1/2] (기본 1)"; $Scope = if ($c -eq '2') { 'project' } else { 'global' }
    } catch { $Scope = 'global' }
  }
}
if ($Scope -eq 'project') {
  if (-not $Project) { try { $Project = Read-Host "프로젝트 경로 (기본: 현재 $((Get-Location).Path))" } catch {}; if (-not $Project) { $Project = (Get-Location).Path } }
  $ProjectRoot = (Resolve-Path $Project).Path
  $Dest = Join-Path $ProjectRoot '.claude'; $ClaudeMdDest = Join-Path $ProjectRoot 'CLAUDE.md'; $PluginScope = 'project'
} else {
  $Dest = if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $env:USERPROFILE '.claude' }
  $ClaudeMdDest = Join-Path $Dest 'CLAUDE.md'; $PluginScope = 'user'
}

# 모드
$HasExisting = (Test-Path $ClaudeMdDest) -or (Test-Path (Join-Path $Dest 'rules')) -or (Test-Path (Join-Path $Dest 'skills'))
if (-not $Mode) {
  if (-not $HasExisting) { $Mode = 'replace' }
  else {
    try {
      Write-Host "`n기존 하네스 감지됨 ($Dest). 설치 모드:"
      Write-Host "  1) merge   — 기존 위에 덧씌움(비충돌만 추가, 충돌 보존+리포트->advisor 권장)"
      Write-Host "  2) replace — 기존 백업 후 우리 하네스로 교체"
      $m = Read-Host "선택 [1/2] (기본 1=merge)"; $Mode = if ($m -eq '2') { 'replace' } else { 'merge' }
    } catch { $Mode = 'merge' }
  }
}

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
  if ($Mode -eq 'replace') { New-Item -ItemType Directory -Force -Path $Backup | Out-Null; Copy-Item $ClaudeMdDest (Join-Path $Backup 'CLAUDE.md') -Force; Copy-Item (Join-Path $Dot 'CLAUDE.md') $ClaudeMdDest -Force; Write-Host "OK CLAUDE.md 교체(백업)" }
  else { Copy-Item (Join-Path $Dot 'CLAUDE.md') "$ClaudeMdDest.harness-incoming" -Force; Write-Host "! CLAUDE.md 충돌 - 보존(.harness-incoming)" -ForegroundColor Yellow; Add-Content $Report "CONFLICT CLAUDE.md ($ClaudeMdDest)"; $script:Conflicts++ }
}

function Put-Tree([string]$src, [string]$name) {
  $dest = Join-Path $Dest $name
  if ($Mode -eq 'replace') {
    if (Test-Path $dest) { New-Item -ItemType Directory -Force -Path $Backup | Out-Null; Copy-Item $dest (Join-Path $Backup $name) -Recurse -Force; Remove-Item $dest -Recurse -Force }
    Copy-Item $src $dest -Recurse -Force; Write-Host "OK $name 교체 설치" -ForegroundColor Green; return
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

Copy-Item (Join-Path $Dot 'settings.reference.json') (Join-Path $Dest 'settings.reference.json') -Force
Write-Host "OK settings.reference.json 제공(수동 병합)" -ForegroundColor Green
if ($Scope -eq 'project') { Write-Host "  i 프로젝트 범위: rules/는 자동주입 안 됨(보존). CLAUDE.md/skills/agents는 프로젝트 로드." -ForegroundColor Cyan }

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

Write-Host "`n다음: 1) 충돌시 advisor  2) setup-plugins.ps1 $PluginScope  3) setup-mcp.ps1 $PluginScope  4) settings 병합  5) 재시작"
