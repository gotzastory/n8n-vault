# Hooks (n8n-vault parent)

Mirrors LihFolk: tooling hooks live on the **project root**, not inside the Obsidian vault.

## Cursor

Configured in `.cursor/hooks.json`.

`n8n-vault-path-check.ps1` runs after file edits. If the file looks like a workflow/case note (`Workflow - *.md`, `00 Case.md`, or path contains `Worked Builds`) and is **not** under `vault/08 Worked Builds/`, it injects a warning for the agent.

Fail-open: script errors never block the edit.

Disable: set env `N8N_VAULT_HOOK=off`.

## Claude Code style

`hooks.json` here is a thin stub pointing at the same PowerShell check. Expand later (e.g. remind to update INDEX after MCP `create_workflow`).
