---
tags: [n8n/pattern]
type: pattern
aliases: []
---

# Pattern - Polling API (Schedule Trigger)

## Problem
Service ที่ต้องการ monitor **ไม่มี webhook** และ **ไม่มี Trigger node** ใน n8n → ต้องเช็คเองเป็นรอบๆ ว่ามีข้อมูลใหม่ไหม

## Workflow Shape
```
[[Node - Schedule Trigger]] → [[Node - HTTP Request]] (ดึงข้อมูล)
   → [[Node - Code]] เทียบกับ static data ของรอบก่อน
   → [[Node - IF]] เปลี่ยนแปลงไหม
       ├─ true  → ประมวลผลต่อ + update static data
       └─ false → [[Node - NoOp]]
```

## หัวใจ: `$getWorkflowStaticData()`
เก็บ state ข้ามรอบการรัน — Code node เทียบ data ที่ดึงมาใหม่กับของรอบก่อน ถ้าต่างค่อยส่งต่อ แล้วอัปเดต static data

**ข้อจำกัด**: static data **ไม่ persist ตอน test** — ต้อง publish workflow + ให้ trigger จริงยิงถึงจะ save

## Nodes Used
- [[Node - Schedule Trigger]] — แนะนำใช้ **Custom (Cron)** เสถียรกว่า interval แบบ dropdown
- [[Node - HTTP Request]] — เปิด **Pagination** ถ้า API แบ่งหน้า
- [[Node - Code]] — เทียบ + จัดการ static data
- [[Node - IF]] / Remove Duplicates node

## Polling vs Webhook
| | Webhook | Polling |
|---|---|---|
| ใครเริ่ม | service ยิงมาหา n8n | n8n ไปถามเอง |
| latency | realtime | ตามรอบ |
| execution quota | นับทุก request | **นับเฉพาะตอนเจอ data ใหม่** (สำหรับ polling node ที่มีในตัว) |

> [[Node - Schedule Trigger]] **นับ execution ทุกครั้งที่ fire** ไม่ว่าจะเจอข้อมูลใหม่หรือไม่ — ต่างจาก polling node สำเร็จรูป (Gmail Trigger, Google Drive Trigger) ที่นับเฉพาะตอนเจอ data

## Gotchas
- **Trigger Rule หลายอันบวกกัน** ไม่ใช่ AND — ตั้ง "ทุก 15 นาที" + "7:05 ทุกวัน" = ยิงทั้งสองแบบ
- แก้ interval หลัง publish ต้อง unpublish + publish ใหม่ถึงมีผล
- ตั้ง timezone ให้ถูก (`GENERIC_TIMEZONE` หรือ workflow settings) ไม่งั้นรันผิดเวลา
- [[Pinned Data]] ไม่ทำงานกับ Schedule Trigger
- ระวังยิงถี่เกินจน rate limit → ดู [[Pattern - Rate Limiting API Calls]]

## Related Patterns
- [[Pattern - Rate Limiting API Calls]]
- [[Pattern - Webhook to Database]]
- [[Pattern - Batch Processing with Split In Batches]]
