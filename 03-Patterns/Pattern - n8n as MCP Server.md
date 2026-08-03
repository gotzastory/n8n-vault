---
tags: [n8n/pattern]
type: pattern
source: my-workflow
verified: 2026-08-03
---

# Pattern - n8n as MCP Server

> สกัดจาก [[System - HOSHI (Shirt Printing)]] — workflow `MCP-HOSHI-Conversations`

## Problem
มี AI agent อยู่ที่อื่น (Claude Desktop, ChatGPT, agent ใน n8n อีกตัว) และอยากให้มัน **เข้าถึงข้อมูล/ทำ action** ผ่านระบบที่ n8n ต่ออยู่แล้ว โดยไม่ต้องเขียน API server เอง

## Workflow Shape
```
MCP Server Trigger  (@n8n/n8n-nodes-langchain.mcpTrigger)
   path: /hoshi-conversations
        ↑ ai_tool         ↑ ai_tool         ↑ ai_tool
   search_conversation  save_conversation  search_faq
   (airtableTool)       (airtableTool)     (dataTableTool)
```
**ไม่มี main connection เลย** — tool node ทุกตัวต่อเข้า trigger ด้วย connection type `ai_tool`
workflow นี้ไม่ "ไหล" จากซ้ายไปขวา แต่เป็น **ชุด tool ที่รอถูกเรียก**

## ตั้งชื่อ node = ชื่อ tool
ชื่อ node คือชื่อที่ agent ภายนอกเห็น → ตั้งเป็น **snake_case แบบ function name**:
- `search_conversation`
- `save_conversation`
- `search_faq`

(ไม่ใช่ "Airtable1", "Get row") — ดู [[Best Practice - Naming Convention for Nodes]]

## Parameter เติมด้วย `$fromAI()`
```javascript
$fromAI("userId", "LINE userId ของลูกค้า", "string")
$fromAI("current_step", "step 0-8", "number")
$fromAI("intake_data", "JSON string", "string")
```

**เทคนิค: ใส่ตัวเลือกที่เป็นไปได้ลงใน description**
```javascript
$fromAI("category", "หมวด FAQ พร้อม emoji เช่น 💰ราคา, 👕เสื้อ, 🖨️เทคนิคสกรีน, 🎨ออกแบบ, 📦การสั่งซื้อ, ⏰ระยะเวลา, 💳ชำระเงิน, 🚚จัดส่ง", "string")
```
→ LLM ส่งค่าตรง enum มากขึ้นมาก. **description เขียนภาษาไทยได้ ไม่มีปัญหา**

**ประกอบ query string เองก็ได้:**
```javascript
"={{ \"{userId}='\" + $fromAI(\"userId\", \"LINE userId ของลูกค้า\", \"string\") + \"'\" }}"
```
(Airtable `filterByFormula`)

## เลือก tool node ให้ตรงงาน
| ต้องการ | node |
|---|---|
| อ่าน/เขียน Airtable | `airtableTool` |
| อ่าน n8n Data Table | `dataTableTool` |
| เรียก workflow อื่นทั้งก้อน | **Call n8n Workflow Tool** |
| ยิง API ใดก็ได้ | HTTP Request Tool |
| Google Sheets / Slack / Gmail ฯลฯ | node ปกติในโหมด tool |

> Node ที่ลงท้าย `Tool` = เวอร์ชัน tool ของ node นั้น ต่อเข้า root AI node เท่านั้น

## MCP Server Trigger vs Sub-workflow tool
| | MCP Server Trigger | [[Sub-workflow (Execute Workflow)|Call n8n Workflow Tool]] |
|---|---|---|
| ใครเรียกได้ | **client ภายนอก** (Claude, ChatGPT, agent อื่น) | AI Agent ใน n8n เท่านั้น |
| protocol | MCP มาตรฐาน | ภายใน n8n |
| discovery | client เห็น tool list อัตโนมัติ | ต้อง config ที่ agent |
| เหมาะกับ | เปิดความสามารถให้ระบบภายนอก | จัดระเบียบภายใน workflow |

## ⚠️ ข้อสังเกต
- **workflow active แต่ `triggerCount: 0`** — MCP trigger ไม่ถูกนับเป็น production trigger เหมือน webhook/schedule
- `triggerInfo` ขึ้นว่า *"This workflow has no production triggers"* ทั้งที่ใช้งานได้จริง → **อย่าตกใจ**
- ต้องเปิด `availableInMCP: true` ใน workflow settings
- Instance ต้องเข้าถึงได้จาก client (public HTTPS ถ้า client อยู่นอกเครือข่าย)
- ยิ่งเปิด tool เยอะ agent ยิ่งสับสน — เปิดเท่าที่จำเป็น

## Housekeeping
Description ของ workflow นี้ใช้บันทึกการเปลี่ยนแปลง:
> *"Cleanup: ลบ MCP /hoshi-order ออก (ไม่ใช้แล้ว — Main Agent เรียก submit_order direct)"*

**ลบ tool ที่ไม่ใช้ออกจริงจัง** — tool ค้างทำให้ agent เรียกผิดและกิน token

## Related
- [[System - HOSHI (Shirt Printing)]]
- [[Node - Tool (AI)]]
- [[Node - AI Agent]]
- [[Sub-workflow (Execute Workflow)]]
