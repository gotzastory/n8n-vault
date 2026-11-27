---
tags: [n8n/node]
type: node
node-type: action
aliases: []
---

# Node - Notion

## Operations (v3, n8n 2.31+)
| Resource | Operations |
|---|---|
| **Block** | Append After, Get Many, Get Markdown |
| **Data Source** | Get, Search |
| **Database** | Get |
| **Database Page** | Create, Get, Get Many, Update |
| **Page** | Create, Archive, Search, Get Markdown, Update Markdown |
| **User** | Get, Get Many |

## ⚠️ Breaking change ใน n8n 2.31 (Notion node v3)
ย้ายไป Notion API `2026-03-11`:
- **database query → data source** — Database ID ใช้กับ database-page query/create **ไม่ได้แล้ว ต้องเลือก Data Source แทน**
- เพิ่ม: Data Source resource, markdown get/update, JSON block support, file download สำหรับ database page, reorderable block builder
- Notion Trigger รองรับ data source ด้วย

## Database ID vs Database Page ID (สับสนบ่อยสุด)
- **Database ID** = ID ของทั้งฐานข้อมูล (เหมือน ID ของ sheet ทั้งใบ)
- **Database Page ID** = ID ของ 1 หน้า/1 แถวในฐานข้อมูล (เหมือน ID ของ row)

ใส่สลับกัน → `404 object_not_found: Could not find page with ID: ...`

## Notion Trigger
Events: **Page added to database**, **Page updated in database** (polling)

## Common Issues
- **Relation property ไม่แสดง**: node รองรับเฉพาะ **two-way relation** — ต้องเปิด "Show on [related database]" ใน Notion ก่อน. ถ้าเป็น one-way ต้องใช้ [[Node - HTTP Request]] ยิง `PATCH https://api.notion.com/v1/pages/<page_id>` เอง
- **Toggle heading สร้างตรงๆ ไม่ได้** — ต้องสร้าง heading ปกติก่อน แล้วใช้ HTTP Request `PATCH` เซ็ต `heading_1.is_toggleable = true`
- **File & media property**: Notion เปลี่ยน validation แล้ว — ส่ง URL ที่ host บน Notion CDN เข้า field แบบ `external` ไม่ได้ (`A file with type external cannot contain a Notion hosted file url`). ต้อง re-host ไฟล์ที่อื่น (S3/R2) หรือใช้ Notion file upload API ตรงๆ
- **ไม่มี upsert operation** — ต้องดึงทั้งหมดมา merge เองใน workflow แล้วแยก Create/Update
- **AI tool ไม่รองรับ relation field** — ต้องสลับไปใช้ HTTP Request node แทน
- Property value ต้องตรง type ของ Notion เป๊ะ เช่น title = `{"title":[{"text":{"content":"..."}}]}`, number = `{"number":100}`
- **Integration ต้องถูก share เข้ากับ database/page นั้นๆ** ใน Notion ก่อน ไม่งั้น 404 ตลอด

## Related
- [[Credential]]
- [[Node - HTTP Request]] (workaround ทุกเคสข้างบน)
- [[Node - Tool (AI)]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.notion
- https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.notion/common-issues
- https://docs.n8n.io/integrations/builtin/trigger-nodes/n8n-nodes-base.notiontrigger
