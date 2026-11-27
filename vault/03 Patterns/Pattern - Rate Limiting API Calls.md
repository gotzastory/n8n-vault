---
tags: [n8n/pattern]
type: pattern
aliases: []
---

# Pattern - Rate Limiting API Calls

## Problem
API จำกัดจำนวน request ต่อหน่วยเวลา → ยิงรัวเกินไปได้ **429 "The service is receiving too many requests from you"**

## 3 วิธี เรียงตามความง่าย
### 1. HTTP Request node — Batching option (ง่ายสุด)
[[Node - HTTP Request]] → Add Option → **Batching**
- **Items per Batch**: จำนวน item ต่อ request
- **Batch Interval (ms)**: หน่วงระหว่างชุด (API อนุญาต 1 req/วินาที → ใส่ `1000`)

เทียบเท่าใช้ Loop Over Items + Wait แต่อยู่ใน node เดียว

### 2. Retry On Fail (node ใดก็ได้)
Node Settings → เปิด **Retry On Fail** → ตั้ง **Wait Between Tries (ms)** ให้มากกว่า rate limit
→ เหมาะกับ error ชั่วคราว แต่**ไม่ได้ป้องกันล่วงหน้า** แค่ลองใหม่

### 3. Loop Over Items + Wait (คุมได้ละเอียดสุด)
```
data → [[Node - Split In Batches]] → API node → Wait node ──┐
              ↑                                              │
              └──────────────────────────────────────────────┘
```
ใช้เมื่อ node ปลายทางไม่ใช่ HTTP Request (เช่น OpenAI node, [[Node - Google Sheets]])

## AI/LLM node
- [[Node - AI Agent]] มี option **Batch Processing**: Batch Size + Delay Between Batches
- AI Agent Tool node ก็มีเหมือนกัน — ใช้ตอนให้ agent เรียก tool หลายรอบ (เช่น update Google Sheets ทีละแถวหลายๆ แถว)

## Gotchas
- **Pagination ≠ rate limiting** — pagination คือดึงข้อมูลให้ครบทุกหน้า, rate limiting คือคุมความถี่. ใช้คู่กันได้
- Batching เปิดแล้ว node จะหมุนนานขึ้นมาก (ดึง 2000 record ทีละ 10 = 200 รอบ) — ไม่ได้ค้าง
- Rate limit ของแต่ละ service อ่านจาก API doc ของ service นั้น
- ระบบ traffic สูงจริงๆ: ใช้ external queue (RabbitMQ) รับ burst แล้วค่อยดึงมาประมวลผลตามจังหวะ — คนละชั้นกับ [[Queue Mode]] ที่คุม concurrency ของ execution

## Related Patterns
- [[Pattern - Batch Processing with Split In Batches]]
- [[Pattern - Polling API (Schedule Trigger)]]
- [[Node - HTTP Request]]
- [[Pattern - Error Handling with Error Trigger]]
