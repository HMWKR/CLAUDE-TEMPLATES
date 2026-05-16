# ============================================================
# install-aidlc-baseline.ps1
#
# Purpose:
#   Hybrid deployment - copies master skill from claude-templates
#   to global ~/.claude/skills/aidlc-baseline/ so any project
#   can invoke the AI-DLC baseline lifecycle skill.
#
# Usage:
#   cd C:\Users\jusan\Desktop\claude-templates
#   .\scripts\install-aidlc-baseline.ps1
#
# Behavior:
#   1. Backup existing global copy with timestamp
#   2. Copy master to global recursively
#   3. Verify file count + SHA256 hash equality
#
# Compat: Windows PowerShell 5.1+
# ============================================================

$ErrorActionPreference = 'Stop'

# --- 1. Path setup ---
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$masterPath = Join-Path $repoRoot '.claude\skills\aidlc-baseline'
$globalSkillsRoot = Join-Path $env:USERPROFILE '.claude\skills'
$globalPath = Join-Path $globalSkillsRoot 'aidlc-baseline'

Write-Host "=== aidlc-baseline install ===" -ForegroundColor Cyan
Write-Host "Master :  $masterPath"
Write-Host "Global :  $globalPath"
Write-Host ""

# --- 2. Master copy existence check ---
if (-not (Test-Path $masterPath)) {
    Write-Host "ERROR: master copy not found - $masterPath" -ForegroundColor Red
    exit 1
}
$masterSkillMd = Join-Path $masterPath 'SKILL.md'
if (-not (Test-Path $masterSkillMd)) {
    Write-Host "ERROR: SKILL.md missing - $masterSkillMd" -ForegroundColor Red
    exit 1
}

# --- 3. Ensure global skills root ---
if (-not (Test-Path $globalSkillsRoot)) {
    New-Item -ItemType Directory -Path $globalSkillsRoot -Force | Out-Null
    Write-Host "Created global skills root: $globalSkillsRoot"
}

# --- 4. Backup existing global copy ---
# IMPORTANT: backup is moved OUT of ~/.claude/skills/ to prevent the skill
# registry from picking up the backup directory as a duplicate skill.
# (Each backup with a SKILL.md inside ~/.claude/skills/ would otherwise be
# registered as another skill with identical description, polluting the registry.)
$backupRoot = Join-Path $env:USERPROFILE '.claude\skills-backups'
if (Test-Path $globalPath) {
    if (-not (Test-Path $backupRoot)) {
        New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    }
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupTarget = Join-Path $backupRoot "aidlc-baseline-$timestamp"
    Write-Host "Existing global copy found - moving OUT of skills root to skills-backups/" -ForegroundColor Yellow
    Write-Host "  -> $backupTarget"
    Move-Item -Path $globalPath -Destination $backupTarget
}

# --- 5. Recursive copy ---
Write-Host ""
Write-Host "Copying master -> global ..." -ForegroundColor Cyan
Copy-Item -Path $masterPath -Destination $globalPath -Recurse -Force

# --- 6. File count verification ---
$masterFileCount = (Get-ChildItem -Path $masterPath -Recurse -File | Measure-Object).Count
$globalFileCount = (Get-ChildItem -Path $globalPath -Recurse -File | Measure-Object).Count

Write-Host ""
Write-Host "=== Verification ===" -ForegroundColor Cyan
Write-Host "Master file count : $masterFileCount"
Write-Host "Global file count : $globalFileCount"

if ($masterFileCount -ne $globalFileCount) {
    Write-Host "FAIL: file count mismatch" -ForegroundColor Red
    exit 1
}

# --- 7. SHA256 hash verification (all files) ---
Write-Host ""
Write-Host "Verifying SHA256 hashes ..." -ForegroundColor Cyan
$mismatch = 0
Get-ChildItem -Path $masterPath -Recurse -File | ForEach-Object {
    $relPath = $_.FullName.Substring($masterPath.Length + 1)
    $globalFile = Join-Path $globalPath $relPath
    if (-not (Test-Path $globalFile)) {
        Write-Host "MISSING: $relPath" -ForegroundColor Red
        $mismatch++
        return
    }
    $masterHash = (Get-FileHash -Path $_.FullName -Algorithm SHA256).Hash
    $globalHash = (Get-FileHash -Path $globalFile -Algorithm SHA256).Hash
    if ($masterHash -ne $globalHash) {
        Write-Host "HASH MISMATCH: $relPath" -ForegroundColor Red
        $mismatch++
    }
}

if ($mismatch -gt 0) {
    Write-Host ""
    Write-Host "FAIL: $mismatch files failed verification" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Install Complete ===" -ForegroundColor Green
Write-Host "Skill activated at: $globalPath"
Write-Host ""
Write-Host "Now callable from any project with triggers like:"
Write-Host "  - 'AI-DLC workflow', 'aidlc baseline'"
Write-Host "  - 'inception phase', 'construction phase'"
Write-Host "  - 'workspace detection', 'requirements analysis'"
Write-Host ""
Write-Host "RealizeSoft layer skill (skill 2) to be authored separately."
