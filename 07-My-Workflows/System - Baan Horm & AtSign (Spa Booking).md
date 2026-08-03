---
tags: [n8n/my-workflow]
type: system
verified: 2026-08-03
aliases: [Workflow A, Workflow B, Workflow C, Workflow D&G, Workflow J]
---

# System - Baan Horm & AtSign (Spa Booking)

ระบบจองคิว 2 ร้าน — **Baan Horm Thai Massage & Hair Spa** (นวด/สปา) และ **AtSign Nail Salon & Spa** (เล็บ)
แยกร้านด้วย regex บนชื่อบริการ: `/nail|gel|manicure|pedicure|acrylic|เล็บ|เจล|ต่อเล็บ/`

## สถาปัตยกรรม
```
ลูกค้า ──┬── WhatsApp ──→ [A] AI Booking Agent ──┐
         ├── FB / IG ────→ [B] AI Booking Agent ──┤
         └── Website form → [C] Normalize+Validate┤
                                                   ↓
                                          Supabase `bookings`
                                                   ↓
                                    LINE Flex → กลุ่มพนักงาน
                                                   ↓
                              [D&G] พนักงานกดปุ่ม postback
                                    ↓                    ↓
                        update Supabase          Google Sheets
                                    ↓              (Customers)
                        แจ้งลูกค้ากลับช่องทางเดิม

[J] ทุกชั่วโมง → หา booking ที่จบไปแล้ว 1 ชม. → ขอรีวิว
```

**หลักการ: Supabase = source of truth** (ทุก workflow เขียน/อ่านที่นี่), Google Sheets = mirror สำหรับดูเฉยๆ

## Supabase `bookings` — schema ที่ใช้จริง
| column | ค่า/หมายเหตุ |
|---|---|
| `booking_id` | `BK-YYYYMMDD-HHmmss` (gen ใน Set node) |
| `source_channel` | Website / WhatsApp / Facebook / Instagram |
| `customer_name` / `customer_phone` | |
| `customer_wa_id` / `customer_fb_id` / `customer_ig_id` | id ตามช่องทาง — ใช้ตอนส่งกลับ |
| `service_name` / `service_category` | |
| `booking_date` | **`YYYY-MM-DD` บังคับ** (validate ด้วย regex) |
| `booking_time` | **`HH:mm` บังคับ** |
| `guests` | clamp 1-20 |
| `language` | Thai / English → เลือกภาษาข้อความ |
| `status` | New → Confirmed / Not Available / Reschedule / Need More Info → Completed |
| `follow_up_status` | Pending |
| `review_status` | **Not Requested → Requested** (กันส่งซ้ำ) |
| `payment_status` | Unpaid |

## Workflow แต่ละตัว

### [A] CHATBOT WA — 25 nodes
`WhatsApp Trigger` → Normalize → Validate Event → AI Booking Agent → ...
- **AI Agent**: OpenRouter model + Simple Memory + **Google Sheets tool (knowledge base)**
- เก็บครบแล้ว → Supabase (booking + session) → LINE แจ้งพนักงาน → ตอบลูกค้า
- ยังไม่ครบ → ถามต่อ + ส่ง PDF เมนู (สปา/เล็บ) + ส่ง location ตามร้าน
- ⚠️ **`triggerInfo` บอกว่าไม่มี production trigger** ทั้งที่ active — เพราะ WhatsApp Trigger ไม่ถูกนับเป็น trigger ประเภทที่ MCP รู้จัก

### [B] FB & IG Chatbot — 22 nodes
2 webhook แยก (`baan-horm-fb`, `baan-horm-ig`) + **Echo Challenge** สำหรับ verify webhook ของ Meta
- Normalize FB/IG → Build Context → AI Agent (OpenAI) → Switch route ตอบกลับตามช่องทาง
- FB/IG send node ตั้ง **`onError=continueRegularOutput` + `executeOnce`** — ส่งไม่ได้ก็ไม่ให้ workflow ตาย

### [C] Booking Form → LINE Staff — 6 nodes (เล็กสุด สะอาดสุด)
`POST /webhook/baan-horm-form` → Normalize → Validate → Supabase → LINE Flex → Respond 200
- **Normalize ใช้ `??` chain รับหลาย field name**:
  `{{ $json.body.name ?? $json.name ?? $json.body.customer_name ?? $json.customer_name ?? "" }}`
  → รองรับ form หลายเวอร์ชันโดยไม่ต้องแก้ workflow
- **Validate Code node throw error ถ้าไม่ผ่าน** → execution fail ชัดเจน ไม่เขียนข้อมูลเสีย

### [D&G] Flex Postback → Update Status + Walk-in — 26 nodes
`LINE Staff Reply Trigger` → IF `Is Postback?`
- **postback** → Parse → Lookup booking → Require Valid Booking → Switch 4 ทาง (Confirmed / Not Available / Reschedule / Need More Info) → update Supabase → **upsert Google Sheets Customers** → Switch route แจ้งลูกค้าตามช่องทาง (WA/FB/IG/Website fallback→WA)
- **ไม่ใช่ postback** → Parse Walk-in (พนักงานพิมพ์ลูกค้า walk-in) → IF valid → Supabase + Sheets → ตอบยืนยัน/error

### [J] Review Request — 10 nodes
`Schedule Trigger ทุกชั่วโมง` → Compute Review Window → Supabase getAll → Filter Eligible → Build Message → Switch channel → ส่ง → **Mark review_status=Requested**

**เงื่อนไข eligible (ใน Code node):**
```javascript
status === 'Confirmed' || status === 'Completed'
review_status === 'Not Requested'
booking_date === todayBkk
booking_time <= cutoffTime      // now - 1 ชม.
sendTo ต้องมีค่า
```
- **timezone hard-code `Asia/Bangkok`**: `$now.setZone('Asia/Bangkok')`
- `Get Pending Reviews` ตั้ง **`executeOnce`** — ดึงครั้งเดียวไม่ซ้ำต่อ item
- link รีวิว Google แยกตามร้าน (`g.page/r/...`)

## 💡 บทเรียนจากระบบนี้
1. **Normalize node เป็นด่านแรกเสมอ** — รับ payload หลายหน้าตาแล้วแปลงเป็น schema เดียว ทำให้ node ถัดไปไม่ต้องรู้ว่ามาจากช่องทางไหน
2. **Validate ด้วย Code node ที่ `throw`** ดีกว่า IF เงียบๆ — error ขึ้น execution list ให้เห็น
3. **`review_status` เป็น flag กันส่งซ้ำ** = [[Best Practice - Idempotent Workflows|idempotency]] ที่ทำได้จริง
4. **`source_channel` ตัดสินใจปลายทาง** — เก็บตั้งแต่ต้นทางแล้วใช้ route ตอนท้าย
5. **AI Agent ใช้ Google Sheets เป็น knowledge base tool** แทนทำ vector store — เหมาะกับข้อมูลที่แก้บ่อยและมีไม่เยอะ
6. **Website ไม่มี id ให้ตอบกลับ → fallback ไป WhatsApp** ด้วยเบอร์ที่กรอกในฟอร์ม

## ⚠️ จุดที่ควรปรับ
- **ไม่มี Error Workflow** ตั้งใน settings ของทุกตัว → ดู [[Best Practice - Error Workflow Setup]]
- `Sync Booking to Supabase` เป็น **insert ธรรมดา ไม่ใช่ upsert** → ยิงซ้ำ = booking ซ้ำ
- Workflow C: `price` ถูก map เข้า Supabase แต่ **Normalize ไม่ได้ set field นี้** → ได้ `undefined`
- Workflow A ต่อ `Reply Ask More via WhatsApp` ออก 4 เส้นขนาน (Spa/Nail menu + 2 location) — ทุกเส้นรันหมดแล้วค่อยให้ IF กรอง แทนที่จะ Switch ทางเดียว

## Related
- [[Pattern - LINE Flex Postback for Staff Action]]
- [[Pattern - Bot Handoff to Human]]
- [[Pattern - AI Agent with Tools]]
- [[Node - Webhook]], [[Node - Switch]], [[Node - Code]]
- [[MOC - My Workflows]]
