# n8n-vault

Project wrapper for Got’s n8n knowledge vault + agent tooling (same idea as LihFolk `v2-vault`).

## Two folders

| Open as | Path | For |
|---|---|---|
| **Cursor / Claude / agents** | this folder (`n8n-vault`) | `AGENTS.md`, hooks, `.agents/skills` |
| **Obsidian** | [`vault/`](vault/) | notes, INDEX, `08 Worked Builds` |

Agent rules: [`AGENTS.md`](AGENTS.md)  
Obsidian start: `vault/000 Home.md`

## Layout (clean)

```
n8n-vault/
  AGENTS.md
  README.md
  .agents/skills/n8n-workflow-designer/
  .cursor/hooks*          # path guard + session hint
  hooks/                  # Claude-style stub + shared script
  skills/                 # optional human-readable companions
  vault/              # Obsidian SoT
```

## Write rules (short)

- Workflow / case notes → **only** `vault/08 Worked Builds/`
- Live nodes/config → n8n MCP
- No project junk folders at root (`_inbox` removed)

## Hooks

Cursor `.cursor/hooks.json` warns if a workflow/case note is written outside `vault/08 Worked Builds/`.  
Disable with env `N8N_VAULT_HOOK=off`.
