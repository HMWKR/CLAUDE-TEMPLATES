# 글로벌 하네스 설치 (Windows PowerShell) — harness/dot-claude → ~/.claude
# 사용: pwsh harness/install.ps1 [-WithPlugins] [-WithMcp]
#   기본: 글로벌 파일(CLAUDE.md·rules·agents·skills)만 복사 (기존본 타임스탬프 백업)
param([switch]$WithPlugins, [switch]$WithMcp)
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Src  = Join-Path $ScriptDir 'dot-claude'
$Dest = if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $env:USERPROFILE '.claude' }
$Ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$Backup = Join-Path $Dest "_harness-backup-$Ts"

if (-not (Test-Path $Src)) { Write-Host "X $Src 없음. 레포 루트에서 실행하세요." -ForegroundColor Red; exit 1 }
New-Item -ItemType Directory -Force -Path $Dest | Out-Null

Write-Host "===== 글로벌 하네스 설치 =====" -ForegroundColor Cyan
Write-Host "원본: $Src"
Write-Host "대상: $Dest"
Write-Host "백업: $Backup (기존본 보존)`n"

function Copy-Tree([string]$name) {
  $d = Join-Path $Dest $name
  if (Test-Path $d) {
    New-Item -ItemType Directory -Force -Path $Backup | Out-Null
    Copy-Item $d (Join-Path $Backup $name) -Recurse -Force
    Write-Host "  백업: $name"
  }
  if (Test-Path $d) { Remove-Item $d -Recurse -Force }
  Copy-Item (Join-Path $Src $name) $d -Recurse -Force
  Write-Host "OK 설치: $name" -ForegroundColor Green
}

# CLAUDE.md
$claudeMd = Join-Path $Dest 'CLAUDE.md'
if (Test-Path $claudeMd) {
  New-Item -ItemType Directory -Force -Path $Backup | Out-Null
  Copy-Item $claudeMd (Join-Path $Backup 'CLAUDE.md') -Force; Write-Host "  백업: CLAUDE.md"
}
Copy-Item (Join-Path $Src 'CLAUDE.md') $claudeMd -Force; Write-Host "OK 설치: CLAUDE.md" -ForegroundColor Green

Copy-Tree 'rules'
Copy-Tree 'agents'
Copy-Tree 'skills'

# settings 는 머신 특화 — 참조본만
Copy-Item (Join-Path $Src 'settings.reference.json') (Join-Path $Dest 'settings.reference.json') -Force
Write-Host "OK 참조 제공: settings.reference.json (직접 병합. 자동 적용 안 함)" -ForegroundColor Green

Write-Host "`nOK 글로벌 파일 설치 완료." -ForegroundColor Green

if ($WithPlugins) { Write-Host "`n-> 플러그인 설치..."; & (Join-Path $ScriptDir 'setup-plugins.ps1') }
if ($WithMcp)     { Write-Host "`n-> MCP 설치...";     & (Join-Path $ScriptDir 'setup-mcp.ps1') }

Write-Host "`n다음 단계:"
Write-Host "  1. 플러그인:  pwsh harness/setup-plugins.ps1   (또는 install.ps1 -WithPlugins)"
Write-Host "  2. MCP:       harness/setup-mcp.ps1 의 경로 채운 뒤 실행"
Write-Host "  3. settings:  harness/dot-claude/settings.reference.json 을 ~/.claude/settings.json 에 병합"
Write-Host "  4. Claude Code 재시작"
