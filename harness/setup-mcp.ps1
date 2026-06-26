# 하네스 standalone MCP 재현 — 6종 (플러그인 제공 MCP는 플러그인 설치 시 자동)
# 사용: 아래 플레이스홀더를 본인 환경에 맞게 채운 뒤  pwsh harness/setup-mcp.ps1 [user|project]  (기본 user)
#   project 범위는 현재 디렉토리의 .mcp.json 에 기록되므로 대상 프로젝트에서 실행할 것.
# 토큰을 레포에 커밋하지 말 것. 필요 시 -e KEY=값 또는 /mcp OAuth 사용.
param([ValidateSet('user','project','local')] [string]$Scope = 'user')

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
  Write-Host "X 'claude' CLI 없음. Claude Code 먼저 설치." -ForegroundColor Red; exit 1
}
Write-Host "(등록 스코프: -s $Scope)" -ForegroundColor DarkGray

# ── 머신 특화 경로 (본인 환경에 맞게 수정) ─────────────────────────
$SerenaBin = if ($env:SERENA_BIN) { $env:SERENA_BIN } else { "$env:USERPROFILE\.local\bin\serena.exe" }
$VaultPath = if ($env:KNOT_VAULT) { $env:KNOT_VAULT } else { "$env:USERPROFILE\knot-vault" }
$PythonVenv = $env:PYTHON_VENV   # 예: C:\...\venv-capcut\Scripts\python.exe
$VectCutApi = $env:VECTCUTAPI    # 예: C:\Users\<you>\tools\VectCutAPI
$CantosDir  = $env:CANTOS_DIR    # 예: C:\Users\<you>\.claude\mcp\cantos
# ────────────────────────────────────────────────────────────────

function Add-Mcp([string]$name, [string[]]$rest) {
  Write-Host "+ mcp add $name"
  try { claude mcp add -s $Scope $name -- @rest } catch { Write-Host "  X 실패/스킵: $name" -ForegroundColor Yellow }
}

# 항상 등록 (외부 경로 의존 없음)
Add-Mcp 'codex' @('codex','mcp-server')
Add-Mcp 'playwright' @('npx','-y','@playwright/mcp@latest')

# 경로 의존 — 있을 때만
if (Test-Path $SerenaBin) { Add-Mcp 'serena' @($SerenaBin,'start-mcp-server','--context','claude-code','--project-from-cwd') }
else { Write-Host "  (serena 스킵: $SerenaBin 없음 — uv tool install serena-agent)" -ForegroundColor DarkGray }

if (Test-Path $VaultPath) { Add-Mcp 'obsidian' @('npx','-y','obsidian-mcp',$VaultPath) }
else { Write-Host "  (obsidian 스킵: vault $VaultPath 없음)" -ForegroundColor DarkGray }

if ($PythonVenv -and $VectCutApi) { Add-Mcp 'capcut' @($PythonVenv,"$VectCutApi\mcp_server.py") }
else { Write-Host "  (capcut 스킵: PYTHON_VENV/VECTCUTAPI 미설정)" -ForegroundColor DarkGray }

if ($CantosDir) { Add-Mcp 'cantos' @('node',"$CantosDir\server.js") }
else { Write-Host "  (cantos 스킵: CANTOS_DIR 미설정)" -ForegroundColor DarkGray }

Write-Host ""
Write-Host "OK 완료. 확인: claude mcp list" -ForegroundColor Green
Write-Host "i claude.ai 원격 커넥터(Notion/Gmail/Drive 등)는 /mcp 로 OAuth 인증." -ForegroundColor Cyan
