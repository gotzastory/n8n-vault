---
tags: [moc, n8n/workflow]
type: moc
---

# MOC — Workflows

Lookup เร็ว: [[INDEX]] · [[ROUTER]] · [[000 Home]]

## Built (มีใน INDEX)
ดูตาราง [[INDEX]] — อย่ารายการซ้ำยาวที่นี่

## Client systems
- โฟลเดอร์ `10 Client Systems/`

## Lifecycle
`requirement → Mermaid → approval → n8n MCP build → verification → Markdown + INDEX update`

## Template
- [[Template - n8n Workflow]] ใน `_templates/`

## Rules
- One workflow per Markdown file in `08 Worked Builds/`
- MCP = config จริง · vault = intent/history
- Read existing note + `get_workflow_details` before edits
- Never store secrets or full workflow JSON in this vault
