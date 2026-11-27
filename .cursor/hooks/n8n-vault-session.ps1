# sessionStart: remind agents of the two-layer layout (fail-open)
$ErrorActionPreference = 'Continue'
$msg = @'
n8n-vault layout (like LihFolk v2-vault): this folder = AGENTS/hooks/skills. Obsidian knowledge SoT = vault/. Workflow/case notes ONLY under vault/08 Worked Builds/. Lookup INDEX first; MCP for live nodes. Read AGENTS.md.
'@
@{ additional_context = $msg } | ConvertTo-Json -Compress
exit 0
