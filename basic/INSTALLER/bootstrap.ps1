Param()

$KitDir = Resolve-Path (Join-Path $PSScriptRoot "..")
$InstallerDir = Join-Path $KitDir "INSTALLER"

$DefaultWs = $env:OPENCLAW_WORKSPACE_DIR
if ([string]::IsNullOrEmpty($DefaultWs)) {
  $DefaultWs = Join-Path $HOME ".openclaw\workspace"
}

Write-Host "OpenClaw Basic bootstrap" -ForegroundColor Cyan
Write-Host ""
Write-Host "Workspace root (default): $DefaultWs"
$resp = Read-Host "Use this workspace root? [Y/n]"
if ([string]::IsNullOrEmpty($resp)) { $resp = "Y" }
if ($resp -match "^[Nn]$") {
  $DefaultWs = Read-Host "Enter workspace root path"
}

$env:OPENCLAW_WORKSPACE_DIR = $DefaultWs
Write-Host "Using workspace: $($env:OPENCLAW_WORKSPACE_DIR)"

New-Item -ItemType Directory -Force -Path (Join-Path $env:OPENCLAW_WORKSPACE_DIR "memory") | Out-Null

$MemPath = Join-Path $env:OPENCLAW_WORKSPACE_DIR "MEMORY.md"
if (-not (Test-Path $MemPath)) {
@"
# MEMORY

## Non-authoritative notice
Unless explicitly labeled as [DECISION] with Status: ACTIVE, content here is treated as context and thinking, not authoritative intent.
"@ | Out-File -Encoding utf8 $MemPath
}

$Day = Get-Date -Format "yyyy-MM-dd"
$Daily = Join-Path (Join-Path $env:OPENCLAW_WORKSPACE_DIR "memory") "$Day.md"
New-Item -ItemType File -Force -Path $Daily | Out-Null

Write-Host ""
Write-Host "Telemetry is local-only and OFF by default."
$tresp = Read-Host "Enable local-only telemetry? [y/N]"
if ([string]::IsNullOrEmpty($tresp)) { $tresp = "N" }
if ($tresp -match "^[Yy]$") {
  $env:OPENCLAW_TELEMETRY_ENABLED = "1"
  New-Item -ItemType Directory -Force -Path (Join-Path $env:OPENCLAW_WORKSPACE_DIR "telemetry") | Out-Null
  @"
enabled: true
scope: local_only
date: "$Day"
kit: "OpenClaw Basic"
"@ | Out-File -Encoding utf8 (Join-Path (Join-Path $env:OPENCLAW_WORKSPACE_DIR "telemetry") "CONSENT.yaml")
} else {
  $env:OPENCLAW_TELEMETRY_ENABLED = "0"
}

Write-Host ""
Write-Host "Running health check..."
$HealthCheck = Join-Path $InstallerDir "health-check.sh"
if (Get-Command bash -ErrorAction SilentlyContinue) {
  bash $HealthCheck
} else {
  Write-Host "[WARN] bash not available (install WSL or Git Bash for full health check)."
  Write-Host "[INFO] Performing basic file checks..."
  $reqFiles = @("AGENTS.md","SOUL.md","USER.md","TOOLS.md","MEMORY.md","GLOBAL-STATE-SCHEMA.md","GLOBAL-STATE.yaml","HEARTBEAT.md","SECURITY.md","CORE-SEMANTICS.md")
  foreach ($f in $reqFiles) {
    $fp = Join-Path $env:OPENCLAW_WORKSPACE_DIR $f
    if (-not (Test-Path $fp)) {
      Write-Host "[WARN] Missing core file: $fp"
    }
  }
  if (Test-Path (Join-Path $env:OPENCLAW_WORKSPACE_DIR "memory")) {
    Write-Host "[OK] Memory folder exists"
  } else {
    Write-Host "[WARN] Memory folder missing"
  }
}

$KitVersion = Get-Content (Join-Path $KitDir "VERSION") -ErrorAction SilentlyContinue
if ([string]::IsNullOrEmpty($KitVersion)) { $KitVersion = "unknown" }

if ($env:OPENCLAW_TELEMETRY_ENABLED -eq "1") {
  python3 (Join-Path (Join-Path $KitDir "TOOLS") "telemetry.py") install_completed --workspace "$env:OPENCLAW_WORKSPACE_DIR" --kit_version "$KitVersion" 2>$null
}

Write-Host ""
Write-Host "Bootstrap complete."
Write-Host ""
Write-Host "IMPORTANT - Apply the recommended config:"
Write-Host "  1. Review:  type $KitDir\openclaw.recommended.jsonc"
Write-Host "  2. Copy the compaction + memoryFlush block into ~\.openclaw\openclaw.json"
Write-Host "  3. Restart: openclaw gateway restart"
Write-Host ""
Write-Host "This prevents memory loss during long sessions."
Write-Host "Then start a new chat - BOOTSTRAP.md will run automatically on first session."
