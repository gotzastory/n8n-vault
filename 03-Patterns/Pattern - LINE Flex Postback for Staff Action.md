---
tags: [n8n/pattern]
type: pattern
source: my-workflow
verified: 2026-08-03
---

# Pattern - LINE Flex Postback for Staff Action

> สกัดจาก [[System - Baan Horm & AtSign (Spa Booking)]] — Workflow C ส่ง, Workflow D&G รับ

## Problem
ต้องการให้พนักงาน **อนุมัติ/ตอบสนอง** งานที่เข้ามา โดยไม่ต้องเปิด dashboard ไม่ต้อง login
→ ส่งการ์ดพร้อมปุ่มเข้ากลุ่ม LINE แล้วให้กดตอบได้เลย

เป็น human-in-the-loop เวอร์ชันที่พนักงานไทยใช้จริง (เทียบกับ [[Node - Slack]] approval ที่ทีมสากลใช้)

## สถาปัตยกรรม — 2 workflow แยกกัน
```
[Workflow ส่ง]  event → บันทึก DB → LINE Flex + ปุ่ม postback → กลุ่มพนักงาน
                                                                    ↓ (พนักงานกด)
[Workflow รับ]  LINE Trigger → IF Is Postback? → Parse → Lookup → Switch → update DB → แจ้งลูกค้า
```
> ต้องแยก 2 workflow เพราะ **postback เข้ามาเป็น event ใหม่** ไม่ใช่ response ของ execution เดิม

## ฝั่งส่ง: Flex bubble + postback button
```json
"footer": {
  "contents": [{
    "type": "button", "style": "primary", "color": "#06C755",
    "action": {
      "type": "postback",
      "label": "✅ รับได้",
      "data": "action=1&bookingId={{ $json.booking_id }}"     ← key
    }
  }, …]
}
```
**`data` = query string ที่ encode action + reference id** — นี่คือทั้งหมดที่ workflow ปลายทางจะได้รับ

ตัวอย่างชุดปุ่มที่ใช้จริง (4 ปุ่ม 2 แถว):
| ปุ่ม | สี | data |
|---|---|---|
| ✅ รับได้ | `#06C755` | `action=1&bookingId=…` |
| ❌ ไม่ว่าง | `#E53935` | `action=2&bookingId=…` |
| 📅 เวลาอื่น | `#FF9800` | `action=3&bookingId=…` |
| ❓ ขอข้อมูล | `#1E88E5` | `action=4&bookingId=…` |

## ฝั่งรับ: pipeline 5 ขั้น
```
1. IF Is Postback?          ← แยก postback ออกจากข้อความปกติ
2. Parse Postback Data      ← แตก query string เป็น action + bookingId
3. Lookup Booking by ID     ← ดึงข้อมูลเต็มจาก DB (postback มีแค่ id)
4. Require Valid Booking    ← Code node throw ถ้าไม่เจอ
5. Switch by action code    ← 4 ทาง แต่ละทางเซ็ตข้อความต่างกัน
      ↓
   update DB → sync ที่อื่น → Switch route แจ้งลูกค้าตามช่องทางเดิม
```

### ทำไมต้อง Lookup ใหม่
postback `data` มีขนาดจำกัดและอยู่ในมือ client — **อย่าใส่ข้อมูลธุรกิจลงไป ใส่แค่ id** แล้วดึงของจริงจาก DB
→ ป้องกัน data เก่า/ถูกแก้ และการ์ดที่ค้างใน chat นานๆ ยังใช้ได้

### Require Valid Booking
```javascript
// Code node ที่ throw ถ้า lookup ไม่เจอ
```
กัน flow เดินต่อด้วย `undefined` — ดีกว่าปล่อยไป update DB ด้วย id ที่ไม่มีจริง

## Bonus: ช่องทางเดียวกันรับได้ 2 แบบ
Workflow D&G ใช้ `IF Is Postback?` แยกเป็น 2 สาย:
- **postback** → จัดการ booking ตามปุ่ม
- **ไม่ใช่ postback** (พนักงานพิมพ์เอง) → Parse Walk-in → บันทึกลูกค้า walk-in

→ กลุ่ม LINE เดียวทำได้ทั้งอนุมัติงานและบันทึก walk-in

## 💡 บทเรียน
1. **ปุ่มต้องมีสีต่างกันชัด** — พนักงานกดเร็ว สีคือ affordance หลัก
2. **1 ปุ่ม = 1 action code** ไม่ใช่ข้อความอิสระ → Switch จับได้แน่นอน ไม่ต้อง NLP
3. **การ์ดค้างใน chat กดซ้ำได้** → ต้องทำ update ให้ [[Best Practice - Idempotent Workflows|idempotent]] (set status เป็นค่าคงที่ ไม่ใช่ increment)
4. **แจ้งลูกค้ากลับช่องทางเดิม** — เก็บ `source_channel` ตั้งแต่ต้นทางแล้ว Switch ตอนท้าย

## เทียบกับ approval ของ Slack
| | LINE Flex postback | [[Node - Slack]] Send and Wait |
|---|---|---|
| execution | **2 workflow แยก** | execution เดียวหยุดรอ |
| ต้องมี | community node LINE | Signature Secret + public HTTPS |
| จำกัดผู้กด | ทำเองใน workflow | ตั้ง approver list ได้ |
| เหมาะกับ | ทีมไทย, ปุ่มหลายแบบ | ทีมที่ใช้ Slack อยู่แล้ว |

## Related
- [[System - Baan Horm & AtSign (Spa Booking)]]
- [[Pattern - Bot Handoff to Human]]
- [[Node - Switch]]
- [[Best Practice - Idempotent Workflows]]
