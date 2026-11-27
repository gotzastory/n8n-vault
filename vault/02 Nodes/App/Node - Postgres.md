---
tags: [n8n/node]
type: node
node-type: action
aliases: []
---

# Node - Postgres

## Operations
- **Execute Query** — รัน SQL เอง
- **Select** — เลือกแถวผ่าน UI (Column/Operator/Value + Combine Conditions AND/OR + Sort + Return All/Limit)
- **Insert**
- **Insert or Update** — upsert
- **Update**
- **Delete** — Command: **Truncate** (ลบ data เก็บโครงสร้าง, +Restart Sequences) / **Delete** (ตามเงื่อนไข, ไม่ใส่เงื่อนไข = ลบหมด) / **Drop** (ลบทั้ง data + โครงสร้างถาวร)

## Query Parameters (ป้องกัน SQL injection)
ใช้ placeholder `$1`, `$2` ใน query แล้วใส่ค่าใน option **Query Parameters** (comma-separated)

**Trick: `IN` group แบบ dynamic**
```sql
SELECT color FROM shirts WHERE shirt_size IN ({{ $json.sizes.map((i, pos) => "$" + (pos+1)).join(', ') }});
```
Query Parameters: `{{ $json.sizes }}` → n8n สร้าง placeholder ตามจำนวน item ให้เอง

## Options ร่วมทุก operation
- **Query Batching**: **Single Query** (query เดียวสำหรับทุก item) / **Independently** (1 query ต่อ item) / **Transaction** (ทุก query ใน transaction เดียว — fail = rollback หมด)
- **Output Large-Format Numbers As**: Numbers / **Text** ← ต้องใช้ Text ถ้าตัวเลขยาวเกิน 16 หลัก ไม่งั้นค่าเพี้ยน
- **Replace Empty Strings with NULL** — มีประโยชน์กับ data ที่ export มาจาก spreadsheet
- **Connection Timeout**, **Delay Closing Idle Connection**, **Output Columns**
- **Skip on Conflict** (เฉพาะ Insert) — ข้ามแทน error เมื่อชน unique constraint

## Mapping Column Mode
- **Map Each Column Manually**
- **Map Automatically** — ชื่อ field ต้องตรงกับชื่อ column เป๊ะ (ใช้ [[Node - Set (Edit Fields)]] ปรับก่อน)

## Timestamp & timezone
- เก็บ/ส่งเป็น **UTC** เสมอ
- ตั้ง timezone: `GENERIC_TIMEZONE` ([[Environment Variables]]) หรือ workflow settings
- ใช้ **ISO 8601** — n8n ส่ง date ระหว่าง node เป็น string และ parse ด้วย Luxon. cast ได้ด้วย Date & Time node format `yyyy-MM-dd'T'HH:mm:ss`

## Gotcha
- **Select operation ไม่รองรับ filter แบบ optional** — field ที่ตั้งไว้ต้องมีค่าเสมอ ไม่งั้น return null. ต้องการ optional filter → ใช้ **Execute Query** สร้าง query แบบ dynamic แทน
- **SQL ใช้ single quote** — `'history'` ไม่ใช่ `"history"` (double quote = identifier ใน Postgres → error `column "history" does not exist`)
- **Postgres node insert/update รันครั้งเดียวต่อ operation** (ไม่ loop ทีละ item อัตโนมัติ) — ดู [[Node - Split In Batches]] node exceptions
- กัน duplicate → ใช้ **Insert or Update** จับคู่ด้วย unique column แทนเช็คเองด้วย IF

## Related
- [[Node - Set (Edit Fields)]]
- [[Node - Split In Batches]]
- [[Credential]]
- [[Pattern - Webhook to Database]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.postgres
- https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.postgres/common-issues
