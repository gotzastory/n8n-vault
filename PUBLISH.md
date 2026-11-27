# แจก vault ผ่าน GitHub โดยซ่อนงานจริง

โมเดลที่เลือก: **โครงเปล่า + กติกา/template** (งานลูกค้าอยู่แค่เครื่อง / private backup)

## สิ่งที่ขึ้นสาธารณะได้
- `AGENTS.md` · hooks · skill designer
- `vault/` หมวด 00–07, 09, templates, Home/ROUTER/SYMPTOMS/CASE FOLDERS
- `08` / `10` แบบ skeleton + ตัวอย่างสมมติเท่านั้น
- `INDEX.example.md` (ไม่ใช่ INDEX จริง)

## สิ่งที่ซ่อน (ดู `.gitignore`)
- `vault/08 Worked Builds/**` ยกเว้น README + Example
- `vault/10 Client Systems/**` ยกเว้น README
- `vault/_assets/**`
- `vault/INDEX.md`

## ขั้นตอนแนะนำ
1. เก็บของจริงไว้เครื่องนี้ (หรือ remote **private** แยก)
2. Commit โครงสาธารณะตาม `.gitignore`
3. ก่อนตั้ง repo เป็น **Public**: ลบประวัติเก่าที่มีงานลูกค้าออกจาก GitHub  
   ตอนนี้ `origin` (`gotzastory/n8n-knowledge`) ยังมีอย่างน้อย:
   - `07-My-Workflows/` (Baan Horm, HOSHI, Customs, LINE Finance, TikTok…)
   - `08-Workflows/Workflow - LINE OA CRM Sandbox Flow.md`
4. วิธีสะอาด: สร้าง orphan branch ใหม่แล้ว force-push **หลัง Got อนุมัติ** — หรือสร้าง repo ใหม่แล้ว archive ของเก่าเป็น private
5. อย่า force-push จนกว่าจะยืนยันว่าไม่มีคน clone ที่ต้องพึ่งประวัติเก่า

## Backup งานจริง
อย่าพึ่งแค่ repo สาธารณะ — ใช้ private repo / Drive / disk สำหรับ `08` + `10` + `INDEX.md` + `_assets`
