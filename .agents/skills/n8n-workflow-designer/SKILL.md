---
name: n8n_workflow_designer
description: Use when designing n8n workflows; get approval first. MCP-first with vault INDEX/TL;DR.
---

# n8n Workflow Designer

Use this skill whenever the user describes an n8n workflow or asks to automate two or more services.

## Vault + MCP (always)

Project root (AGENTS + hooks): `C:\Users\thana\Desktop\Project\n8n\n8n-vault`. Knowledge vault SoT: `...\n8n-vault\vault`. Worked Builds = `vault/08 Worked Builds/` only (never write case notes on the parent).

| Layer | Truth for | How |
|---|---|---|
| n8n MCP | nodes, connections, credentials, active, executions | `get_workflow_details`, validate, create/update, execute |
| Vault note | why, constraints, pending, related ids, history | `08 Worked Builds/` (flat or under a case folder) |
| INDEX / ROUTER / SYMPTOMS | fast lookup | grep before broad `search_workflows` |

**Edit existing:** `INDEX`/`ROUTER` → follow the `note` path exactly → read TL;DR + Pending only → `get_workflow_details` → approve if behavior changes → validate/update → verify → update Status/TL;DR/History/Pending + INDEX row. Do **not** dump full node payloads into Markdown. Do **not** invent case folders when looking up.

**Debug:** `SYMPTOMS` → `search_workflow_executions` / `get_workflow_execution` → fix via MCP → History.

**Case folders (see vault `CASE FOLDERS.md`):** solo workflow → flat `08 Worked Builds/Workflow - <name>.md`. Named case or 2+ related workflows → `08 Worked Builds/<Case Name>/` + `00 Case.md` hub (no numeric prefixes like `010`). If unsure which case, ask once or keep flat. Path in INDEX always wins.

**Assets:** save diagrams under `_assets/<workflow-slug>/` or `_assets/<case-slug>/` (compat junction `assets/` may exist).

## Operating protocol

1. Parse requirements before designing:
   - Trigger: schedule/cron, webhook, form, email, service event
   - Services and APIs involved
   - Logic: conditions, loops, branches, merges, retries, error handling
   - Inputs/outputs and success criteria
   - Credentials, environment, timezone, frequency, volume, and constraints
2. If sufficiently clear, make reasonable assumptions and state them. Ask only for missing information that blocks design.
3. Research official n8n knowledge sources using `search_n8n_knowledge_sources` for unfamiliar services/patterns. Run independent searches in parallel where possible. Confirm exact node names, operations, authentication, and version gotchas.
4. Design with real n8n node names. Cover all IF/Switch branches and include an error path for external API calls.
5. Generate a `flowchart TD` Mermaid diagram using `NodeID["n8n Node Name\\nbrief description"]`. Label both outcomes of every IF/Switch. Use subgraphs for 3+ phases.
6. Include these five class definitions and assignments:
   ```mermaid
   classDef trigger fill:#f0a500,stroke:#c97d00,color:#000
   classDef action fill:#4a90d9,stroke:#2c6fad,color:#fff
   classDef logic fill:#7c4dff,stroke:#5c35cc,color:#fff
   classDef output fill:#00897b,stroke:#006b5e,color:#fff
   classDef error fill:#e53935,stroke:#b71c1c,color:#fff
   ```
7. Validate/render the final Mermaid source with `validate_and_render_mermaid_diagram` before presenting.
8. Present title, trigger, assumptions, rendered diagram and image when available, concise Quick Build Reference table, and open questions/blockers.
9. For Telegram requests for a visual flowchart, send the rendered Mermaid image as an attachment/photo, not only source/link. Use the renderer's returned path or URL; include Mermaid source when useful.
10. Before approval, show the design but do not create or modify the permanent workflow Markdown record.
11. Do not build or persist the final workflow record until the user explicitly approves (e.g. “โอเค”, “อนุมัติ”, “approved”).
12. After approval, create/update the workflow note from `_templates/Template - n8n Workflow.md` under `08 Worked Builds/` (or `08 Worked Builds/<Case Name>/` when a case applies). Set frontmatter `case` when nested. If this is the second workflow in a case, create `00 Case.md` from `_templates/Template - Case Hub.md` and ask before moving an older flat note. Include TL;DR, Mermaid, requirements, build status, test result, history. Save image under `_assets/<workflow-slug>/mermaid-flowchart.png` when available. Add/update the INDEX row (`workflow_id`, `case`, full `note` path). Never commit/push unless explicitly asked; check diff and avoid secrets.
13. After approval, build using n8n MCP only. Do not create or import workflow JSON. Follow the MCP lifecycle, in this order:
   a. Grep vault `INDEX.md` / `ROUTER.md` first; then `search_workflows` if needed — reuse or update instead of duplicating.
   b. `list_credentials` and map each service to an exact credential name. Use `newCredential('<exact name>')`; never invent IDs. Stop and ask if a required credential is missing.
   c. Check every Google Sheet the workflow reads or writes: read the header row (`queue!A1:Z1`) and add missing columns before building. Append new headers at the end and never delete existing ones.
   d. `get_workflow_best_practices` for the technique, `search_nodes` for node names, `get_node_types` with resource/operation discriminators for exact params (Google Sheets requires resource+operation, e.g. `sheet` + `appendOrUpdate`).
   e. `get_workflow_sdk_reference` (section `all` is large; save it to a file and grep the sections you need).
   f. `validate_workflow`. Accept warnings only when explained; `INVALID_EXPRESSION_PATH` on `$json.error` in an error branch is expected.
   g. `create_workflow_from_code`, then `get_workflow_details` to read back connections and error branches. Confirm the loop closes back to its splitter.
   h. Keep the workflow inactive until the user approves a test. Report the ID and URL. Update vault note + INDEX with `workflow_id`.
14. Before any build/edit, read the existing Markdown knowledge file if one exists (TL;DR + Pending first). Treat it as source of truth for prior requirements, decisions, known issues, and pending changes — not as a copy of live node JSON.
15. Never store tokens, passwords, private keys, API secrets, or connection UUIDs in vault notes. Credential **names** only.

## Build pitfalls

- **Timezone:** a Schedule Trigger without an explicit timezone runs on the instance default, which may not match the user's zone. Set the timezone on the trigger or in workflow settings for every scheduled workflow, then read it back to confirm. Ask the user for the zone if it was not stated.
- **Facebook video upload** needs `hostUrl: graph-video.facebook.com` and `sendBinaryData`. Comments use `graph.facebook.com` with `edge: comments`.
- **Canvas grouping:** if validation says the top level is over 7 boxes, group linear ranges with `.group(...)` or explain why not. Do not ignore the warning silently.
- **Provider restriction:** never pick an AI credential or model from OpenRouter, even if the user's clarify answer names it. Re-ask with the remaining choices.
- **Verify before claiming success:** "built" means validated and read back. "Tested" needs a real run that the user has approved, because test runs post or write real data.
- **Mermaid render:** call `validate_and_render_mermaid_diagram` with `useUrlShortener: false` to keep links stable in the record.

## Quality checklist

- Every node uses a real n8n node name.
- All IF/Switch branches are labeled.
- `classDef` declarations and `class` assignments are present.
- Error path exists when external APIs are involved.
- Assumptions are explicit.
- Mermaid is validated/rendered.
- Requirements are persisted only after explicit approval.
- INDEX row exists whenever `workflow_id` is known (path matches file; `case` column filled or `*(flat)*`).
- Case folder rules followed: no numeric case prefixes; INDEX is the only lookup.
