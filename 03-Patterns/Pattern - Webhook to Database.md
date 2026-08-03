---
tags: [n8n/pattern]
type: pattern
aliases: []
---

# Pattern - Webhook to Database

## Problem
รับ event จากระบบภายนอก (form submit, payment, SIEM alert) แล้วเก็บลง database ทันที + ตอบกลับผู้ส่ง

## Workflow Shape
```
[[Node - Webhook]]  →  validate  →  [[Node - Set (Edit Fields)]]  →  [[Node - Postgres]]
                                                                    ↓
                                                        Respond to Webhook
```

## Nodes Used
- [[Node - Webhook]] — Authentication (Basic/Header/JWT), HTTP Method, Path
- [[Node - IF]] / [[Node - Filter]] — validate payload
- [[Node - Set (Edit Fields)]] — cast type ให้ตรง schema database (string `"100"` → number `100`)
- [[Node - Postgres]] — Insert หรือ **Insert or Update** (upsert กัน duplicate)
- Respond to Webhook — เมื่อ Webhook node ตั้ง **Respond = Using 'Respond to Webhook' Node**

## Gotchas
- **Manual vs production execution ต่าง**: manual n8n buffer request ทั้งก้อนก่อน parse; production อาจส่ง data ไปก่อน parse เสร็จ + จัดการ binary/raw body ต่างกัน → field หายบางตัว. แก้: log `{{ $json }}` เต็มใน production, เช็ค option **Raw Body**, ใส่ defensive check (`?.`, fallback)
- payload จริงจากผู้ใช้จริงมักไม่มี optional field / encoding ต่าง — อย่าเชื่อว่า field มีอยู่เพราะ manual test เคยมี
- **Concurrency สูงทำ data หาย** ถ้าปลายทางคือ [[Node - Google Sheets]] append (ดู note นั้น) — database จริงปลอดภัยกว่ามาก
- ทำให้ **idempotent**: ใช้ Insert or Update จับคู่ unique column แทน Insert เปล่าๆ กัน retry แล้วซ้ำ (ดู [[Best Practice - Idempotent Workflows]])
- Webhook นับ execution ทุก request แม้ body ว่าง — ดู [[Execution]]
- ถ้ารับไฟล์: เปิด option **Raw Body** แล้วต่อ Extract From File

## Buffer pattern (traffic สูง)
Webhook → RabbitMQ/queue → workflow อีกตัวดึงจากคิวมาประมวลผลตามจังหวะที่ระบบรับไหว — คนละเรื่องกับ [[Queue Mode]] ของ n8n (นั่นคุม concurrency ระดับ execution)

## Related Patterns
- [[Pattern - Rate Limiting API Calls]]
- [[Pattern - Error Handling with Error Trigger]]
- [[Best Practice - Idempotent Workflows]]
