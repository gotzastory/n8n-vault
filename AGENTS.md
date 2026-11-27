# AGENTS.md: using the n8n vault with any AI coding agent

Open **this folder** (`n8n-vault`) as the project / workspace root for Cursor, Claude Code, OpenBot skills, and hooks.  
Open **`vault/`** as the Obsidian vault (knowledge only).

Same layout as LihFolk `v2-vault` → `LihFolk Vault V2/`.

## Where things live

| Path | Role |
|---|---|
| `AGENTS.md` (here) | Agent rules for the whole project |
| `hooks/` · `.cursor/hooks*` | Path / policy hooks |
| `.agents/skills/` | Reusable n8n skills (SoT for agents; not inside Obsidian vault) |
| `skills/` | Optional human-readable skill companions copied from vault |
| **`vault/`** | Obsidian knowledge SoT — notes, INDEX, Worked Builds |
| `vault/08 Worked Builds/` | **Only** place for workflow / case notes |

**Never write workflow or case notes outside `vault/08 Worked Builds/`.**  
Parent folder = tooling. Inner vault = notes.

## One call first (existing workflow)

1. Grep `vault/INDEX.md` for the name or `workflow_id`.
2. Open the `note` path column exactly (under `vault/…`). Read TL;DR + Pending only.
3. Load live config with n8n MCP `get_workflow_details` — do not treat the note as a full node dump.
4. After an approved build/edit: update Status / History / Pending + the INDEX row in the same turn.

No INDEX hit? Grep `vault/ROUTER.md` / `vault/SYMPTOMS.md`, then MCP `search_workflows`.

## New workflow / new case

1. Follow skill `.agents/skills/n8n-workflow-designer/SKILL.md` (or vault companion `vault/Skill - n8n Workflow Designer.md`).
2. Design → show draft → **wait for explicit approval** (โอเค / อนุมัติ / approved) before MCP create/update.
3. After approval + build:
   - Solo → `vault/08 Worked Builds/Workflow - <name>.md`
   - Named case or 2+ related → `vault/08 Worked Builds/<Case Name>/` + `00 Case.md` (no numeric prefixes like `010`)
4. Add/update `vault/INDEX.md` with `workflow_id`, `case`, and full note path from vault root.
5. Case rules: `vault/CASE FOLDERS.md`. If unsure which case → ask once or keep flat. **Never invent a case folder.**

## MCP vs vault

- **MCP** = nodes, connections, credentials, active, executions (truth for config)
- **Vault note** = why, constraints, pending, related ids, history (truth for intent)
- Never store tokens, passwords, API secrets, or connection UUIDs in Markdown (credential **names** OK)

## Entry notes (inside the Obsidian vault)

- `vault/000 Home.md`
- `vault/00 Start Here.md`
- `vault/INDEX.md`
- `vault/ROUTER.md`
- `vault/SYMPTOMS.md`
- `vault/CASE FOLDERS.md`

## Trust labels

Prefer **n8n docs** and **measured**; verify **unverified**; never invent node names or credential ids.
