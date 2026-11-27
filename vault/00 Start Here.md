---
cssclasses: [vault-hub]
tags: [hub, start, type/hub]
---

# Start Here — n8n Vault

Vault คู่ **n8n MCP** บน instance ของ Got (`n8n-j4e3…` เป็นหลัก)  
โครงคล้าย LihFolk แบบย่อ: Home / Router / Symptoms / Worked Builds — ไม่ copy หมวด 60+

## กติกา
1. **Intent/history** = 1 ไฟล์ใน `08 Worked Builds/` (มี `workflow_id`) — เดี่ยววางราก 08; ชุด 2+ ใช้โฟลเดอร์เคส + `00 Case.md` (ดู [[CASE FOLDERS]])
2. **หาของเดิม = [[INDEX]] ก่อนเสมอ** — ตาม path ในตาราง ห้ามเดาโฟลเดอร์
3. **Nodes/config จริง** = n8n ผ่าน MCP — ห้าม dump full payload ลง vault
4. ห้ามเก็บ token / password / API secret — ใส่ได้แค่ชื่อ credential
5. ก่อนแก้: [[INDEX]] → TL;DR → `get_workflow_details` · หลัง verify: อัปเดต Status / History / Pending + แถว INDEX
6. ความรู้ทั่วไป → 01–07 · workflow notes → เฉพาะ `08` · ภาพระบบลูกค้ากว้าง → `10` · มติข้ามโปรเจกต์ → `09`
7. ไม่เก็บ workflow JSON ทั้งก้อน · ไม่ใส่เลขนำหน้าโฟลเดอร์เคส (`010` ❌)
8. **Source of truth (notes):** โฟลเดอร์นี้ · **Agent rules / hooks / skills:** parent `...\n8n-vault\` (`AGENTS.md`) — แบบ LihFolk
9. ขยะ/scratch ของโปรเจกต์อยู่ parent `_inbox/` ไม่ใช่ในคลังนี้

## Trust labels
- **n8n docs** — อ้างอิงทางการ
- **measured** — ทดสอบบน instance แล้ว
- **rule of thumb** — จากประสบการณ์
- **unverified** — ดู [[Open Questions - Whole Vault]]

## เส้นทาง
**สร้างใหม่** — [[ROUTER]] / Patterns → Mermaid → อนุมัติ → MCP create → note + INDEX  
**แก้ของเดิม** — [[INDEX]] → TL;DR + Pending → MCP details → อนุมัติถ้ากระทบพฤติกรรม → update → verify  
**ดีบัก** — [[SYMPTOMS]] → execution tools → แก้ผ่าน MCP → History  
**สูตรใช้ซ้ำ** — `07 Services` / `03 Patterns` / `09 Decisions`

## Agent
อ่าน [[AI Skills Start Here]] แล้วใช้ [[Skill - n8n Workflow Designer]]
