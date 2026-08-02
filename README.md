# n8n Knowledge Base

Obsidian Vault สำหรับเก็บความรู้ การออกแบบ และประวัติการ Build n8n workflows

## โครงสร้าง

- `00-MOC/` — Maps of Content
- `01-Concepts/` — แนวคิดหลักของ n8n
- `02-Nodes/` — Nodes และ operations
- `03-Patterns/` — รูปแบบ workflow ที่ใช้ซ้ำ
- `04-Self-Host/` — การติดตั้งและดูแลระบบ
- `05-Best-Practices/` — แนวทางปฏิบัติ
- `06-Troubleshooting/` — ปัญหาและวิธีแก้
- `07-Services/` — บริการภายนอก
- `08-Workflows/` — Requirements, diagrams, build records และ history
- `09-Decisions/` — การตัดสินใจเชิงออกแบบ
- `99-Templates/` — Templates สำหรับสร้าง note ใหม่

## กติกา

- ใช้ 1 workflow ต่อ 1 ไฟล์ใน `08-Workflows/`
- ใช้ Wikilinks เช่น `[[Node - Webhook]]` และ `[[Pattern - Error Handling with Error Trigger]]`
- ห้ามเก็บ token, password, private key หรือ credential secret
- อ่านไฟล์ workflow เดิมก่อน Build/Edit และอัปเดตหลังการเปลี่ยนแปลงที่อนุมัติ
- ตรวจ `git diff` ก่อน commit/push

## Naming

- Workflow: `Workflow - <ชื่อ>.md`
- Service: `<Service>.md`
- Decision: `Decision - <หัวข้อ>.md`

## Lifecycle

`requirement → Mermaid → approval → n8n MCP build → verification → Markdown update`

จะไม่เก็บ n8n workflow JSON ใน vault และจะใช้ไฟล์ใน `08-Workflows/` เป็น source of truth ของแต่ละ workflow

เริ่มต้นที่ [[MOC - n8n Knowledge Base]] หรือ [[MOC - Workflows]]

## Git

Repository นี้ใช้ร่วมกันระหว่าง Hermes บน VPS และ Obsidian บนเครื่อง Local ควร sync ก่อนแก้ไข และตรวจ conflict ก่อน push

## Status

โครงสร้างพร้อมสำหรับ workflow แรก
