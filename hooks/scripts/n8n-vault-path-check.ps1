# Warn when workflow/case notes are written outside vault/08 Worked Builds.
# Fail-open. Shared by Cursor (.cursor/hooks) and Claude-style hooks/.
$ErrorActionPreference = 'Continue'
$Utf8 = New-Object System.Text.UTF8Encoding($false)
try { [Console]::InputEncoding = $Utf8; [Console]::OutputEncoding = $Utf8 } catch { }

if ($env:N8N_VAULT_HOOK -eq 'off') {
	Write-Output '{}'
	exit 0
}

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# hooks/scripts -> hooks -> project root
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $here)
$AllowedRel = 'vault\08 Worked Builds'
$AllowedAbs = Join-Path $ProjectRoot $AllowedRel

try {
	$raw = [Console]::In.ReadToEnd()
	if (-not $raw -or $raw.Trim() -eq '') { Write-Output '{}'; exit 0 }
	$j = $raw | ConvertFrom-Json
} catch {
	Write-Output '{}'
	exit 0
}

function Get-Prop($obj, [string[]]$names) {
	foreach ($n in $names) {
		if ($null -eq $obj) { continue }
		$p = $obj.PSObject.Properties[$n]
		if ($null -ne $p -and $null -ne $p.Value -and [string]$p.Value -ne '') { return [string]$p.Value }
	}
	return ''
}

$path = Get-Prop $j @('file_path', 'path', 'filePath')
if ($path -eq '') {
	foreach ($nestName in @('tool_input', 'input', 'arguments', 'data')) {
		$nest = $j.PSObject.Properties[$nestName]
		if ($null -eq $nest -or $null -eq $nest.Value) { continue }
		$path = Get-Prop $nest.Value @('file_path', 'path', 'filePath', 'target_file', 'targetFile')
		if ($path -ne '') { break }
	}
}

if ($path -eq '') { Write-Output '{}'; exit 0 }

$name = [System.IO.Path]::GetFileName($path)
$isWorkflowNote = ($name -like 'Workflow - *.md') -or ($name -eq '00 Case.md') -or ($path -match 'Worked Builds')
if (-not $isWorkflowNote) { Write-Output '{}'; exit 0 }
if ($path -notmatch '\.md$') { Write-Output '{}'; exit 0 }

try {
	$full = [System.IO.Path]::GetFullPath($path)
	$allowedFull = [System.IO.Path]::GetFullPath($AllowedAbs)
} catch {
	Write-Output '{}'
	exit 0
}

if ($full.StartsWith($allowedFull, [System.StringComparison]::OrdinalIgnoreCase)) {
	Write-Output '{}'
	exit 0
}

$msg = @"
n8n-vault hook: workflow/case notes belong only under vault/08 Worked Builds/ (LihFolk-style: tooling at parent, knowledge in vault subfolder). Got path: $path — move/write under: $AllowedAbs
"@

# Cursor + Claude adapters both understand additional_context / agent_message
$result = [ordered]@{
	additional_context = $msg
	agent_message      = $msg
}
$result | ConvertTo-Json -Compress
exit 0
