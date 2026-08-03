---
tags: [n8n/node]
type: node
node-type: trigger
aliases: []
---

# Node - Webhook

## What it does
Trigger node — สร้าง URL รับ HTTP request จากบริการภายนอก แล้ว start workflow ด้วย data ที่ได้รับ. ใช้แทน app-trigger node เฉพาะทางเวลาบริการนั้นไม่มี trigger node ให้.

## Key Parameters
- **HTTP Method**: DELETE / GET / HEAD / PATCH / POST / PUT (default รับแค่ 1 method — เปิด **Allow Multiple HTTP Methods** ใน Settings ถ้าต้องรับหลายแบบ, node จะมี output แยกตาม method)
- **Path**: default random string, กำหนดเองได้ รองรับ route param เช่น `/:variable/path/:variable2`
- **Authentication**: None / Basic auth / Header auth / JWT auth
- **Respond**: Immediately | When Last Node Finishes | Using 'Respond to Webhook' Node | Streaming response (ต้องมี node รองรับ streaming เช่น [[Node - AI Agent]])
- **Response Code**: กำหนด HTTP status code
- **Response Data** (เมื่อ Respond = When Last Node Finishes): All Entries / First Entry JSON / First Entry Binary / No Response Body

## Node Options (Add Option)
- **Allowed Origins (CORS)** — default `*`
- **Binary Property** — เปิดรับ binary data (ต้องเป็น POST/PATCH/PUT)
- **IP(s) Whitelist** — จำกัด caller, นอก list โดน 403
- **Raw Body** — รับ data แบบ raw (JSON/XML)
- **Ignore Bots** — เมิน request จาก crawler/link-previewer

## Input / Output
- Input: ไม่มี (เป็น trigger)
- Output: JSON body/headers/query ของ request ที่เข้ามา — max payload 16MB (self-host ปรับได้ผ่าน env `N8N_PAYLOAD_SIZE_MAX`)

## Test URL vs Production URL
| ประเภท | Trigger ยังไง | ระยะเวลาฟัง | เห็น data ใน editor? |
|---|---|---|---|
| Test | Listen for test event | 120 วิ | เห็น |
| Production | Publish workflow | จนกว่าจะ unpublish | ไม่เห็น (ดูย้อนหลังใน Executions tab) |

## Common Gotchas
- ลืมสลับจาก Test URL ไป Production URL ตอน deploy จริง
- รัน n8n หลัง reverse proxy แล้ว IP whitelist ใช้ไม่ได้ → ต้องตั้ง `N8N_PROXY_HOPS` ให้ตรงจำนวน proxy hop
- ต้องการ response เป็น string ธรรมดา → ต้องต่อ [[Node - Set (Edit Fields)]] ก่อน แล้วตั้ง Response Data = First Entry JSON + Property Name ให้ตรงชื่อ field
- ตั้งแต่ n8n 1.103.0 HTML response ถูกห่อ `<iframe>` sandbox อัตโนมัติ (เพื่อความปลอดภัย) — auth header, relative URL, localStorage ใช้ไม่ได้ในนั้นแล้ว

## Related
- Pairs with: [[Node - HTTP Request]] (ยิงเข้า webhook เพื่อทดสอบ), Respond to Webhook node
- Used with: [[Node - Set (Edit Fields)]]
- Part of pattern: [[Pattern - Webhook to Database]]
- Concept: [[Environment Variables]], [[Credential]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.webhook
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.webhook/common-issues
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.respondtowebhook
