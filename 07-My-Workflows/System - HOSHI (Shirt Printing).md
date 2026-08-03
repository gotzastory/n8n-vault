---
tags: [n8n/my-workflow]
type: system
verified: 2026-08-03
---

# System - HOSHI (Shirt Printing)

Chatbot รับออเดอร์เสื้อสกรีนผ่าน LINE/FB — **Airtable base "งาน Hoshi"** เป็น data store

## จุดเด่น: n8n เป็น MCP Server
`MCP-HOSHI-Conversations` ใช้ **MCP Server Trigger** (`@n8n/n8n-nodes-langchain.mcpTrigger`) path `/hoshi-conversations`
→ เปิด 3 tool ให้ AI agent ภายนอกเรียก:

| Tool | Node type | ทำอะไร |
|---|---|---|
| `search_conversation` | `airtableTool` (search) | หา conversation จาก LINE userId |
| `save_conversation` | `airtableTool` (**upsert**) | บันทึก state การคุย |
| `search_faq` | `dataTableTool` (get) | ค้น FAQ จาก n8n Data Table |

ดู [[Pattern - n8n as MCP Server]]

## `$fromAI()` ใช้จริงยังไง
ทุก parameter ของ tool ให้ LLM เติมเอง — **description เขียนเป็นภาษาไทย** ก็ทำงานได้:
```javascript
$fromAI("userId", "LINE userId ของลูกค้า", "string")
$fromAI("current_step", "step 0-8", "number")
$fromAI("intake_data", "JSON string", "string")
$fromAI("last_intent", "intent ล่าสุด", "string")

// ใน Airtable filterByFormula — ประกอบ string เอง
"={{ \"{userId}='\" + $fromAI(\"userId\", \"LINE userId ของลูกค้า\", \"string\") + \"'\" }}"

// FAQ category — description ใส่ตัวเลือกพร้อม emoji ให้ LLM เลือกถูก
$fromAI("category", "หมวด FAQ พร้อม emoji เช่น 💰ราคา, 👕เสื้อ, 🖨️เทคนิคสกรีน, 🎨ออกแบบ, 📦การสั่งซื้อ, ⏰ระยะเวลา, 💳ชำระเงิน, 🚚จัดส่ง", "string")
```
> **บทเรียน**: ใส่ตัวเลือกที่เป็นไปได้ลงใน `description` ทำให้ LLM ส่งค่าตรง enum มากขึ้น — ดีกว่าปล่อยให้เดา

## Airtable schema
### `conversations` (tbl4n20…)
`userId` (match key) · `channel` (line/fb) · `current_step` (0-8) · `intake_data` (JSON string) · `last_intent` · `updated_at`

### `orders` (tblBEUY…)
`order_id` · `userId` · `channel` · `intake_data` · `status` · `created_at` (readOnly)

**`status` เป็น enum 8 ค่า** — เห็น pipeline ธุรกิจทั้งหมดในนี้:
```
รอประเมินราคา → รับงานแล้ว → กำลังออกแบบ → รอยืนยันแบบ
→ กำลังผลิต → งานเสร็จ → จัดส่งแล้ว → ปิดงาน
```

## `HOSHI Submit Order (Sub)` — sub-workflow
`Execute Workflow Trigger` (inputSource = **jsonExample**) → Create Order → Set Handoff Flag → Build Admin Message → Notify Admin LINE → Return Result

### Input schema กำหนดด้วย JSON example
```json
{"userId":"U…","channel":"line","intake_data":"{\"qty\":1,\"shirt_type\":\"Cotton\",\"technique\":\"DTG\",\"size\":\"A4\",\"position\":\"กลางหลัง\",\"points\":1,\"has_file\":\"มีแล้ว\",\"deadline\":\"23/05\"}"}
```
> `intake_data` เป็น **JSON string ซ้อนใน JSON** — parse ด้วย IIFE + try/catch ใน Set node

### Bot handoff (สำคัญ)
```
Create Order สำเร็จ → Set Handoff Flag: last_intent = "handoff"
                    → bot เช็ค flag นี้แล้วหยุดตอบ
                    → แจ้ง admin: "⚠️ Bot ปิดการตอบแล้ว — แอดมินคุยต่อได้เลย"
```
ดู [[Pattern - Bot Handoff to Human]]

### Return Result — sub-workflow ควรคืน contract ชัดเจน
```javascript
{ success: true, order_id: …, status: 'รอประเมินราคา', message: 'Order created, admin notified, bot handoff' }
```

## 💡 บทเรียน
1. **IIFE ใน Set node** สำหรับ logic ที่ซับซ้อนกว่า expression เดียว แต่ยังไม่คุ้มเปิด Code node:
   ```javascript
   {{ (() => { const intake = (() => { try { return JSON.parse(x); } catch(e) { return {}; } })(); return '...'; })() }}
   ```
2. **fallback chain กับ Airtable response**: `$('Create Order').first().json.fields?.order_id || $('Create Order').first().json.id` — Airtable คืนโครงต่างกันแล้วแต่ config
3. **`availableInMCP: true`** ในทุก workflow settings — เปิดให้ MCP client เรียกได้
4. Description ของ workflow ใช้บันทึก changelog จริง: *"Cleanup: ลบ MCP /hoshi-order ออก (ไม่ใช้แล้ว — Main Agent เรียก submit_order direct)"* ← **ใช้ field description เป็น commit log ได้ดีมาก**

## ⚠️ ข้อสังเกต
- `MCP-HOSHI-Conversations` และ `HOSHI Submit Order (Sub)` **active แต่ `triggerCount: 0`** — MCP trigger / Execute Workflow trigger ไม่นับเป็น production trigger
- ไม่เจอ workflow "Main Agent" ที่เรียก tool พวกนี้ในรายการ active → อาจอยู่นอก n8n (Claude/ChatGPT ที่ต่อ MCP) หรือ inactive อยู่

## Related
- [[Pattern - n8n as MCP Server]]
- [[Pattern - Bot Handoff to Human]]
- [[Node - Tool (AI)]] (`$fromAI`)
- [[Sub-workflow (Execute Workflow)]]
- [[MOC - My Workflows]]
