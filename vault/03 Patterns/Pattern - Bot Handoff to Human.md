---
tags: [n8n/pattern]
type: pattern
source: my-workflow
verified: 2026-08-03
---

# Pattern - Bot Handoff to Human

> สกัดจาก [[System - HOSHI (Shirt Printing)]] — `HOSHI Submit Order (Sub)`

## Problem
Bot รับข้อมูลจนถึงจุดที่ **ต้องให้คนคุยต่อ** (ประเมินราคา, เจรจา, เคสซับซ้อน)
ถ้า bot ยังตอบอยู่ = ชนกับแอดมิน ลูกค้าสับสน

## หลักการ: flag เดียวคุมทุกอย่าง
```
Create Order สำเร็จ
    ↓
Set Handoff Flag  →  conversations.last_intent = "handoff"
    ↓
Notify Admin LINE  →  "⚠️ Bot ปิดการตอบแล้ว — แอดมินคุยต่อได้เลย"
    ↓
Return Result
```

ฝั่ง bot: **เช็ค `last_intent` ก่อนตอบทุกครั้ง** — เป็น `handoff` เมื่อไหร่ก็เงียบ

## Implementation
### 1. ตั้ง flag (upsert ไม่ใช่ insert)
```javascript
operation: upsert
matchingColumns: ["userId"]
value: {
  userId:      "={{ $('When called by another workflow').first().json.userId }}",
  last_intent: "handoff",
  updated_at:  "={{ $now.toISO() }}"
}
```
> upsert สำคัญ — user เดิมต้องอัปเดตแถวเดิม ไม่ใช่สร้างใหม่

### 2. แจ้ง admin พร้อม context ครบ
ข้อความที่ส่งให้แอดมินต้อง**อ่านแล้วคุยต่อได้เลย** ไม่ต้องไปเปิด DB:
```
🔔 ออเดอร์ใหม่ #<order_id>
👤 ลูกค้า: <userId>
📋 จำนวน: 1 ตัว
👕 เสื้อ: Cotton
🖨️ เทคนิค: DTG
📐 ขนาด: A4
📍 ตำแหน่ง: กลางหลัง
🔢 จุด: 1
📎 ไฟล์: มีแล้ว
⏰ Deadline: 23/05

⚠️ Bot ปิดการตอบแล้ว — แอดมินคุยต่อได้เลย
```
บรรทัดสุดท้ายบอกสถานะระบบให้แอดมินรู้ว่าเขาคุมอยู่แล้ว

### 3. sub-workflow คืน contract ชัดเจน
```javascript
{ success: true, order_id: …, status: 'รอประเมินราคา', message: 'Order created, admin notified, bot handoff' }
```
caller รู้ผลโดยไม่ต้องเดา

## ⚠️ สิ่งที่ต้องคิดต่อ (แต่มักลืม)
| ปัญหา | ทางแก้ |
|---|---|
| **ไม่มีทางปลด handoff** | ให้แอดมินพิมพ์คำสั่ง (เช่น `/resume`) หรือปุ่มใน LINE เพื่อ set `last_intent` กลับ |
| **handoff ค้างตลอดกาล** | ใส่ TTL — ถ้า `updated_at` เกิน N วันให้ bot กลับมาตอบ |
| **ลูกค้าถามเรื่องใหม่ที่ bot ตอบได้** | แยก scope: handoff เฉพาะ order นั้น ไม่ใช่ทั้ง conversation |
| **แอดมินไม่เห็นข้อความ** | ควรมี escalation ถ้าไม่มีใครตอบใน X นาที |

## Handoff อีกแบบ: ยังไม่ปิด bot แต่ขออนุมัติ
ถ้าแค่อยากให้คน **อนุมัติก่อนทำ** ไม่ใช่ปิด bot ถาวร → ใช้:
- [[Pattern - LINE Flex Postback for Staff Action]] (LINE)
- [[Node - Slack]] Send and Wait (Slack)
- Chat node `Send and Wait for Response` ([[Pattern - Chatbot Workflow]])
- human-in-the-loop review step ก่อน AI tool ทำงาน ([[Node - Tool (AI)]])

## Related
- [[System - HOSHI (Shirt Printing)]]
- [[Pattern - Chatbot Workflow]]
- [[Pattern - LINE Flex Postback for Staff Action]]
- [[Sub-workflow (Execute Workflow)]]
