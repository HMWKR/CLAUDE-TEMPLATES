# 하네스 플러그인 재현 — 마켓플레이스 13종 + 활성 플러그인 26종
# 사용: pwsh harness/setup-plugins.ps1  (또는 Windows PowerShell)
# 멱등: 이미 추가/설치된 항목은 CLI가 스킵하거나 무해하게 실패한다.

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
  Write-Host "X 'claude' CLI를 찾을 수 없습니다. Claude Code를 먼저 설치하세요." -ForegroundColor Red
  exit 1
}

function Add-Market($src) {
  Write-Host "+ marketplace add $src"
  try { claude plugin marketplace add $src } catch { Write-Host "  (이미 추가됨/스킵)" -ForegroundColor DarkGray }
}
function Install-Plugin($p) {
  Write-Host "+ install $p"
  try { claude plugin install $p -s user } catch { Write-Host "  X 실패/스킵: $p" -ForegroundColor Yellow }
}

Write-Host "===== 1/2 마켓플레이스 (13) =====" -ForegroundColor Cyan
@(
  'anthropics/claude-plugins-official','openai/codex-plugin-cc','accesslint/claude-marketplace',
  'multica-ai/andrej-karpathy-skills','bradautomates/claude-video','Lum1104/Understand-Anything',
  'rohitg00/agentmemory','obra/superpowers-marketplace','Yeachan-Heo/oh-my-claudecode',
  'netwaif/multi-agent-starter','fivetaku/fablize','fivetaku/gptaku_plugins','popup-studio-ai/bkit-claude-code'
) | ForEach-Object { Add-Market $_ }

Write-Host ""
Write-Host "===== 2/2 활성 플러그인 (26) =====" -ForegroundColor Cyan
@(
  'commit-commands@claude-plugins-official','pr-review-toolkit@claude-plugins-official',
  'code-review@claude-plugins-official','code-simplifier@claude-plugins-official',
  'feature-dev@claude-plugins-official','frontend-design@claude-plugins-official',
  'security-guidance@claude-plugins-official','hookify@claude-plugins-official',
  'learning-output-style@claude-plugins-official','plugin-dev@claude-plugins-official',
  'slack@claude-plugins-official','supabase@claude-plugins-official','stripe@claude-plugins-official',
  'context7@claude-plugins-official','vercel@claude-plugins-official','superpowers@claude-plugins-official',
  'codex@openai-codex','accesslint@accesslint','andrej-karpathy-skills@karpathy-skills',
  'watch@claude-video','understand-anything@understand-anything','agentmemory@agentmemory',
  'oh-my-claudecode@omc','fablize@fablize','insane-search@gptaku-plugins','bkit@bkit-marketplace'
) | ForEach-Object { Install-Plugin $_ }

Write-Host ""
Write-Host "OK 완료. 확인: claude plugin list" -ForegroundColor Green
Write-Host "! insane-search는 Python dep 수동 설치 필요: python -m pip install curl_cffi beautifulsoup4 pyyaml" -ForegroundColor Yellow
Write-Host "! Claude Code 재시작 후 전 기능 적용." -ForegroundColor Yellow
