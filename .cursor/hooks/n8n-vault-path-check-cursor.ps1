# Cursor adapter → shared hooks/scripts/n8n-vault-path-check.ps1
$ErrorActionPreference = 'Continue'
$Utf8 = New-Object System.Text.UTF8Encoding($false)
try { [Console]::InputEncoding = $Utf8; [Console]::OutputEncoding = $Utf8 } catch { }

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent (Split-Path -Parent $here)
$checker = Join-Path $projectRoot 'hooks\scripts\n8n-vault-path-check.ps1'
if (-not (Test-Path $checker)) { Write-Output '{}'; exit 0 }

$raw = [Console]::In.ReadToEnd()
if (-not $raw) { Write-Output '{}'; exit 0 }

$raw | & powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $checker
exit 0
