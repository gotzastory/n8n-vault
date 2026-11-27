---
tags: [n8n/pattern]
type: pattern
source: my-workflow
verified: 2026-08-03
---

# Pattern - Async API Polling with Wait Loop

> สกัดจาก [[WF - TikTok AI Video]] — ใช้ซ้ำ 4 รอบใน workflow เดียว

## Problem
API สร้างรูป/วิดีโอ/รายงาน คืน **job id** ทันทีแล้วให้ไปถามสถานะเอง (async job) — n8n ไม่มี node สำเร็จรูปสำหรับรอ

## Workflow Shape
```
[[Node - HTTP Request]] POST /generate   [retryOnFail]
   ↓
Wait (30s)  ←─────────────┐
   ↓                      │
HTTP GET /status  [retryOnFail]
   ↓                      │
[[Node - Switch]] status? │
   ├─ [0] done  → ไปต่อ   │
   └─ [1] pending ────────┘   ← ต่อกลับเข้า Wait
```

## ตั้งเวลารออย่างไร
อย่าใช้ค่าเดียวทุกที่ — ให้พอๆ กับเวลาที่งานใช้จริง:
| งาน | เวลารอที่ใช้จริง |
|---|---|
| generate image | 30s |
| extract image | 5s |
| generate video | นานกว่า |
| merge video | นานกว่า |

รอสั้นเกิน = ยิง API ถี่โดยเปล่าประโยชน์ (+เสี่ยง rate limit)
รอนานเกิน = งานเสร็จแล้วแต่ยังไม่รู้

## ต้องมี: `retryOnFail` บน HTTP node ทุกตัว
pipeline ที่กินเวลา 10+ นาที ล้มกลางทางแล้วเริ่มใหม่แพงมาก — network สะดุดชั่วคราวไม่ควรทำทั้ง pipeline ตาย

## ⚠️ กับดักใหญ่: loop ไม่มีทางออก
Pattern นี้ **ไม่มี max attempt** = ถ้า API ค้างสถานะ `processing` ถาวร → **วนตลอดกาล** กิน execution + memory

### วิธีกัน
1. **นับรอบด้วย `$runIndex`**:
   ```javascript
   // ใน IF node
   {{ $runIndex >= 20 }}   // เกิน 20 รอบ = ยอมแพ้
   ```
2. **ตั้ง Timeout Workflow** ใน Workflow Settings — hard stop
3. เพิ่ม branch ที่ 3 ใน Switch: `failed` → แจ้งเตือน + หยุด
4. เช็ค `EXECUTIONS_TIMEOUT` ระดับ instance ([[Environment Variables]])

## ทางเลือกอื่น
| วิธี | เหมาะเมื่อ |
|---|---|
| **Wait + loop** (pattern นี้) | API ไม่มี webhook, งานเสร็จภายในไม่กี่นาที |
| **Wait node แบบ "On Webhook Call"** | API รองรับ callback — ใช้ `$execution.resumeUrl` ส่งให้ API แล้วรอ (ประหยัดกว่ามาก) |
| **แยกเป็น 2 workflow** | job นานเป็นชั่วโมง — workflow 1 ยิงงาน, workflow 2 รับ callback/poll ตาม schedule |

> **ถ้า API รองรับ callback ให้ใช้ `$execution.resumeUrl` เสมอ** — ดีกว่า polling ทุกทาง

## Related
- [[WF - TikTok AI Video]]
- [[Node - HTTP Request]]
- [[Pattern - Rate Limiting API Calls]]
- [[Node - Switch]]
- [[Execution]]
