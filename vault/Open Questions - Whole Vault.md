---
tags: [open-questions, unverified]
---

# Open Questions — Whole Vault

ข้อค้าง / unverified — อย่าเดาใน build จนกว่า Got ตอบหรือวัดบน instance แล้ว

## Sync / ที่อยู่ vault
- [x] Source of truth: `C:\Users\thana\Desktop\Project\n8n\n8n-vault\vault` (renamed from n8n_vault, 2026-11-27)
- [x] โครง LihFolk-slim + ย้ายจาก parent `n8n-vault/`
- [x] คลังเหลือแต่ความรู้ — skill/hooks อยู่ parent (2026-11-27)
- [ ] จะ sync OpenBot mirror หรือลบ mirror เก่า?

## Workflow IDs / instances
- [ ] VVS Batch Advertising Images Phaya — ยังไม่มี `workflow_id`
- [ ] JERA New Patient Sync ชี้ instance `n8n-q642…` vs `n8n-j4e3…`
- [ ] LINE Group OCR draft values รอ confirm production

## Hygiene
- [ ] ตัด credential id / Maton-Connection ออกจาก note เก่าทีละไฟล์ตอนแตะแก้
- [ ] ไฟล์ใน `10 Client Systems/` เชื่อม workflow_id บน instance ปัจจุบันไหม?
- [x] กวาด parent: ลบ `_inbox` / `.draft` / `.claude` + skill กองเก่า — เหลือแค่ `n8n-workflow-designer` (2026-11-27)
- [x] `.gitignore` + `PUBLISH.md` + ตัวอย่าง 08 สาธารณะ (งานจริง ignore)
- [ ] ลบ `07-My-Workflows` / CRM note ออกจาก GitHub history ก่อนตั้ง Public
