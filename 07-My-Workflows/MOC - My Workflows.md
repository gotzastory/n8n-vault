---
tags: [moc, n8n/my-workflow]
type: moc
verified: 2026-08-03
instance: n8n-q642.srv1194412.hstgr.cloud
---

# MOC — My Workflows

> Note ในโฟลเดอร์นี้มาจาก **instance จริง** ผ่าน mcp n8n (`search_workflows` + `get_workflow_details`)
> ไม่ใช่ตัวอย่างจาก docs — เป็นระบบที่รันอยู่จริง

## สรุปภาพรวม
| | |
|---|---|
| Workflow ทั้งหมด | **89** |
| Active (published) | **10** |
| Instance | self-hosted, Hostinger (`srv1194412.hstgr.cloud`) |
| ตรวจสอบเมื่อ | 2026-08-03 |

## ระบบที่รันอยู่

### 🧖 Spa & Nail (Baan Horm + AtSign)
ระบบจอง multi-channel — **Supabase = source of truth**
- [[System - Baan Horm & AtSign (Spa Booking)]] ← เริ่มที่นี่
- Workflow A: CHATBOT WA · B: FB & IG Chatbot · C: Booking Form → LINE Staff · D&G: Flex Postback · J: Review Request

### 👕 HOSHI (เสื้อสกรีน)
Chatbot รับออเดอร์ — **Airtable = data store**, n8n เป็น **MCP server**
- [[System - HOSHI (Shirt Printing)]]

### 💰 LINE Finance Bot
บันทึกรายรับรายจ่ายผ่าน LINE → Notion (59 nodes)
- [[WF - LINE Finance Bot (Notion)]]

### 📦 Customs Document Automation
BL + Invoice + Packing List → Google Sheets ใบขน
- [[WF - Customs Doc to Sheet]]

### 🎬 TikTok AI Video
สร้างวิดีโอ AI + ปักตะกร้า (61 nodes)
- [[WF - TikTok AI Video]]

## Pattern ที่สกัดได้จากระบบจริง
Pattern เหล่านี้**ไม่มีใน n8n docs** — มาจากการแก้ปัญหาจริงใน workflow ข้างบน:
- [[Pattern - Async API Polling with Wait Loop]] — เรียก API ที่คืน job id แล้วต้องรอผล
- [[Pattern - Multi-Document Session Accumulation]] — สะสมเอกสารหลายไฟล์ข้าม execution
- [[Pattern - LINE Flex Postback for Staff Action]] — ให้พนักงานกดปุ่มใน LINE สั่งงาน
- [[Pattern - n8n as MCP Server]] — เปิด workflow เป็น MCP tool ให้ agent อื่นเรียก
- [[Pattern - Bot Handoff to Human]] — ปิด bot ให้คนคุยต่อ

## Stack ที่ใช้จริง (นับจาก node ใน active workflows)
| หมวด | ที่ใช้ |
|---|---|
| **Messaging** | LINE (`@aotoki/n8n-nodes-line-messaging`), WhatsApp, Facebook Graph API, Instagram (`@mookielianhd/n8n-nodes-instagram`) |
| **Data store** | Supabase, Airtable, **n8n Data Table**, Notion, Google Sheets |
| **AI** | OpenRouter, OpenAI, **Ollama (local)**, Google Gemini |
| **Utility** | Code, IF, Switch, Set, Merge, Wait, HTTP Request |

> **Community node 2 ตัวที่ระบบพึ่งพา** — ไม่ใช่ built-in ต้องระวังตอน upgrade n8n:
> `@aotoki/n8n-nodes-line-messaging`, `@mookielianhd/n8n-nodes-instagram`

## Related
- [[MOC - n8n Knowledge Base]]
- [[MOC - Workflow Patterns]]
