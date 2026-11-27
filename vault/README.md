# n8n Vault

> **Source of truth:** `C:\Users\thana\Desktop\Project\n8n\n8n-vault\vault`  
> โครงแบบ LihFolk ย่อ · คู่ n8n MCP

เริ่มที่ [[000 Home]] · [[00 Start Here]] · [[INDEX]] · [[ROUTER]] · [[SYMPTOMS]]

## โครงสร้าง

| path | ใช้ทำอะไร |
|---|---|
| `000 Home` / `00 Start Here` | ทางเข้า |
| `INDEX` / `ROUTER` / `SYMPTOMS` | lookup คน + agent |
| `01 Concepts` … `06 Troubleshooting` | ความรู้ทั่วไป |
| `07 Services` | บริการภายนอก |
| `08 Worked Builds` | 1 workflow ต่อ 1 ไฟล์ (+ `workflow_id`) |
| `09 Decisions` | การตัดสินใจข้ามโปรเจกต์ |
| `10 Client Systems` | ระบบลูกค้า |
| `_templates` `_assets` `_tools` | ระบบในคลัง |
| `assets` | junction → `_assets` |
| parent `../` | `AGENTS.md` · hooks · `.agents/skills/n8n-workflow-designer` |

## กติกาหลัก
- MCP = nodes/config/execution · vault = ทำไม / ข้อห้าม / pending / related
- ห้าม secret ในไฟล์
- ก่อนแก้: INDEX → TL;DR → `get_workflow_details`
- หลัง verify: อัปเดต note สั้น + แถว INDEX

## Lifecycle
`requirement → Mermaid → approval → n8n MCP build → verification → Markdown + INDEX update`
