---
tags: [n8n/best-practice]
type: best-practice
aliases: []
---

# Best Practice - Idempotent Workflows

## Idempotent คืออะไร
รัน workflow เดิมด้วย input เดิมกี่ครั้งก็ได้ผลลัพธ์เดียวกัน — ไม่สร้าง record ซ้ำ ไม่ส่งเมลซ้ำ

## ทำไมสำคัญมากใน n8n
- **Retry On Fail** รันซ้ำอัตโนมัติ
- **Retry execution** จาก UI ใช้ data เดิม
- **Webhook ยิงซ้ำ**: service ภายนอกยิงซ้ำเมื่อไม่ได้รับ 200 ทันเวลา
- **Queue mode**: execution ย้าย worker / stalled job ถูก re-process (`QUEUE_WORKER_MAX_STALLED_COUNT`)
- **Multi-worker race condition**

ไม่ idempotent + retry = ลูกค้าได้เมล 3 ฉบับ / order ถูก charge ซ้ำ

## เทคนิคทำให้ idempotent
### 1. Upsert แทน Insert
| Node | ใช้ |
|---|---|
| [[Node - Postgres]] | **Insert or Update** (จับคู่ unique column) แทน Insert |
| [[Node - Google Sheets]] | **Append or Update Row** + **Column to Match On** แทน Append |
| [[Node - Notion]] | ไม่มี upsert — ต้องดึงมาเทียบเองแล้วแยก Create/Update |

+ ตั้ง **unique constraint ที่ database จริงๆ** ไม่ใช่พึ่ง `ON CONFLICT` อย่างเดียว (Postgres node option **Skip on Conflict** ช่วยข้ามแทน error)

### 2. Deduplication key
ใช้ id จากต้นทาง (order_id, message_id, event_id) เป็น key — อย่า generate id ใหม่ทุกรอบ (`uuid()`, `Date.now()`) เพราะรันซ้ำได้ id ใหม่ = ซ้ำ

### 3. Remove Duplicates node
กรอง item ที่เคยเห็นใน execution ก่อนหน้า — ใช้เมื่อ event ยิงหลายรอบแต่อยากประมวลผลครั้งเดียว

### 4. เก็บ state กลาง (multi-worker)
อย่าพึ่ง in-memory state — เก็บที่ Redis/Postgres:
```json
{ "job_id": "123", "status": "processing", "current_step": 4 }
```
+ ใช้ **DB lock / unique constraint** กัน 2 worker ทำงานเดียวกัน

### 5. แยก "รับ" ออกจาก "ประมวลผล"
```
Webhook → เขียนเข้า queue/table (status=pending)   ← เร็ว ไม่พลาด
Schedule → ดึง pending มาทีละ batch → ประมวลผล → update status=completed
```
Pattern นี้แก้ได้ทั้ง idempotency, rate limit, และ traffic spike (ดู [[Pattern - Rate Limiting API Calls]])

### 6. ตรวจก่อนทำ action ที่ irreversible
ก่อนส่งเมล/โอนเงิน/สร้าง ticket → เช็คก่อนว่ามี record `sent` แล้วหรือยัง

## ⚠️ กับดัก
- **Retry แบบไม่คิด** = สร้าง duplicate. retry เฉพาะ error ชั่วคราว (timeout, 429, network) ไม่ retry error ถาวร
- Loop ที่ item count เพี้ยน (node ใน loop คืนหลาย row) ทำให้รอบซ้ำ — ดู [[Pattern - Batch Processing with Split In Batches]]
- [[Node - Google Sheets]] append ภายใต้ concurrency สูง **ตกหล่นเงียบๆ** → pre-populate + update แทน

## Checklist
- [ ] ทุก write operation เป็น upsert หรือมี unique constraint
- [ ] dedup key มาจากต้นทาง ไม่ใช่ generate ใหม่
- [ ] action ที่ irreversible มีการเช็ค state ก่อน
- [ ] retry เฉพาะ error ชั่วคราว
- [ ] state เก็บกลาง ไม่ใช่ in-memory (ถ้า multi-worker)

## Related
- [[Pattern - Error Handling with Error Trigger]]
- [[Pattern - Webhook to Database]]
- [[Deploy - Scaling Workers]]
- [[Node - Postgres]]
