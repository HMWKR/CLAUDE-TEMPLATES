# 글로벌/프로젝트 하네스 설치 (Windows PowerShell) — harness/dot-claude → 대상
# 사용: pwsh harness/install.ps1 [-Scope global|project] [-Project <경로>] [-WithPlugins] [-WithMcp]
#   범위 미지정 + 대화형이면 시작 시 묻는다.
#     글로벌  : ~/.claude (이 머신의 모든 프로젝트) · 플러그인/MCP -s user
#     프로젝트: <프로젝트>/.claude (해당 프로젝트만) · 플러그인/MCP -s project
param(
  [ValidateSet('global','project')] [string]$Scope,
  [string]$Project,
  [switch]$WithPlugins,
  [switch]$WithMcp
)
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Src = Join-Path $ScriptDir 'dot-claude'
if (-not (Test-Path $Src)) { Write-Host "X $Src 없음. 레포 루트에서 실행하세요." -ForegroundColor Red; exit 1 }

# 범위 결정
if (-not $Scope) {
  if ($Project) { $Scope = 'project' }
  else {
    try {
      Write-Host "설치 범위를 선택하세요:"
      Write-Host "  1) 글로벌   — ~/.claude (이 머신의 모든 프로젝트에 적용)"
      Write-Host "  2) 프로젝트 — 특정 프로젝트의 .claude/ 에만 적용"
      $c = Read-Host "선택 [1/2] (기본 1)"
      $Scope = if ($c -eq '2') { 'project' } else { 'global' }
    } catch { $Scope = 'global' }   # 비대화형 기본
  }
}

if ($Scope -eq 'project') {
  if (-not $Project) {
    try { $Project = Read-Host "프로젝트 경로 (기본: 현재 $((Get-Location).Path))" } catch {}
    if (-not $Project) { $Project = (Get-Location).Path }
  }
  $ProjectRoot = (Resolve-Path $Project).Path
  $Dest = Join-Path $ProjectRoot '.claude'
  $ClaudeMdDest = Join-Path $ProjectRoot 'CLAUDE.md'
  $PluginScope = 'project'
} else {
  $Dest = if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $env:USERPROFILE '.claude' }
  $ClaudeMdDest = Join-Path $Dest 'CLAUDE.md'
  $PluginScope = 'user'
}

$Ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$Backup = Join-Path $Dest "_harness-backup-$Ts"
New-Item -ItemType Directory -Force -Path $Dest | Out-Null

Write-Host ""
Write-Host "===== 하네스 설치 ($Scope) =====" -ForegroundColor Cyan
Write-Host "원본: $Src"
Write-Host "대상: $Dest"
if ($Scope -eq 'project') { Write-Host "CLAUDE.md: $ClaudeMdDest (프로젝트 루트)" }
Write-Host "백업: $Backup (기존본 보존)"
Write-Host "플러그인/MCP 스코프: -s $PluginScope`n"

function Copy-Tree([string]$name) {
  $d = Join-Path $Dest $name
  if (Test-Path $d) {
    New-Item -ItemType Directory -Force -Path $Backup | Out-Null
    Copy-Item $d (Join-Path $Backup $name) -Recurse -Force
    Write-Host "  백업: $name"
    Remove-Item $d -Recurse -Force
  }
  Copy-Item (Join-Path $Src $name) $d -Recurse -Force
  Write-Host "OK 설치: $name" -ForegroundColor Green
}

# CLAUDE.md (범위별 위치)
if (Test-Path $ClaudeMdDest) {
  New-Item -ItemType Directory -Force -Path $Backup | Out-Null
  Copy-Item $ClaudeMdDest (Join-Path $Backup 'CLAUDE.md') -Force; Write-Host "  백업: CLAUDE.md"
}
Copy-Item (Join-Path $Src 'CLAUDE.md') $ClaudeMdDest -Force; Write-Host "OK 설치: CLAUDE.md -> $ClaudeMdDest" -ForegroundColor Green

Copy-Tree 'rules'
Copy-Tree 'agents'
Copy-Tree 'skills'

Copy-Item (Join-Path $Src 'settings.reference.json') (Join-Path $Dest 'settings.reference.json') -Force
Write-Host "OK 참조 제공: settings.reference.json (직접 병합. 자동 적용 안 함)" -ForegroundColor Green
if ($Scope -eq 'project') { Write-Host "  i 프로젝트 범위: rules/는 자동주입 안 됨(보존 목적). CLAUDE.md/skills/agents는 프로젝트 로드됨." -ForegroundColor Cyan }

Write-Host "`nOK 파일 설치 완료 ($Scope)." -ForegroundColor Green

function Invoke-Setup([string]$name) {
  $script = Join-Path $ScriptDir $name
  if ($Scope -eq 'project') { Push-Location $ProjectRoot; try { & $script $PluginScope } finally { Pop-Location } }
  else { & $script $PluginScope }
}
if ($WithPlugins) { Write-Host "`n-> 플러그인 설치 (-s $PluginScope)..."; Invoke-Setup 'setup-plugins.ps1' }
if ($WithMcp)     { Write-Host "`n-> MCP 설치 (-s $PluginScope)...";     Invoke-Setup 'setup-mcp.ps1' }

Write-Host "`n다음 단계:"
Write-Host "  1. 플러그인:  pwsh harness/setup-plugins.ps1 $PluginScope   (프로젝트면 해당 폴더에서)"
Write-Host "  2. MCP:       harness/setup-mcp.ps1 의 경로 채운 뒤:  pwsh harness/setup-mcp.ps1 $PluginScope"
Write-Host "  3. settings:  $Dest\settings.reference.json 을 settings.json 에 병합"
Write-Host "  4. Claude Code 재시작"
