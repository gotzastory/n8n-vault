---
tags: [n8n/node]
type: node
node-type: core
aliases: []
---

# Node - HTTP Request

## What it does
ยิง HTTP request ไปหา REST API ใดก็ได้ — node อเนกประสงค์ที่สุดใน n8n. ใช้เมื่อไม่มี node เฉพาะของ service นั้น. ต่อเป็น **tool** ให้ [[Node - AI Agent]] ได้ด้วย

**ทางลัด**: กด **Import cURL command** วาง curl จาก API doc แล้ว n8n กรอก field ให้ครบเลย

## Key Parameters
- **Method**: DELETE / GET / HEAD / OPTIONS / PATCH / POST / PUT
- **URL**: endpoint
- **Authentication**:
  - **Predefined Credential Type** (แนะนำ) — ใช้ credential ของ service ที่ n8n รองรับอยู่แล้ว เช่น Asana credential ยิง Asana API endpoint ที่ node ปกติไม่มี
  - **Generic**: Basic auth / Custom auth / Digest auth / Header auth / Bearer / OAuth1 / OAuth2 / Query auth
- **Send Query Parameters**: Using Fields Below (name/value) หรือ Using JSON
- **Send Headers**: เช่นเดียวกัน

## Node Options สำคัญ
### Pagination
- **Update a Parameter in Each Request** — ใช้ `{{ $pageCount + 1 }}` เป็นค่า query/body param ชื่อ `page` (`$pageCount` เริ่มที่ 0)
- **Response Contains Next URL** — ใช้ `{{ $response.body["next-page"] }}`
- **Complete Pagination When**: `{{ !$response.body['odata.nextLink'] }}`
- ตัวแปรเฉพาะ node นี้: `$pageCount`, `$request`, `$response` (`.body`, `.headers`, `.statusCode`)

### Batching (กัน rate limit)
- **Items per Batch** + **Batch Interval (ms)** — เทียบเท่าใช้ [[Node - Split In Batches]] + Wait node แต่ในตัวเดียว

### Response
- **Include Response Headers and Status** — default คืนแค่ body
- **Never Error** — success แม้ status ไม่ใช่ 2xx
- **Response Format**: Autodetect / File (ระบุ Put Output in Field) / JSON / Text

### อื่นๆ
- **Array Format in Query Parameters**: No Brackets (`foo=bar&foo=qux`) / Brackets Only (`foo[]=`) / Brackets with Indices (`foo[0]=`)
- **Ignore SSL Issues**, **Redirects** (+ Max Redirects), **Lowercase Headers**

## Common Gotchas
- **HTTP Request ไม่ loop ให้อัตโนมัติสำหรับ pagination** — ต้องเปิด option Pagination เอง
- เปิด pagination แล้ว output เป็น item รวมทุกหน้าแล้ว → Code node ถัดไปต้องใช้ `$input.all()` ไม่ใช่ `$input.first().json.value`
- Pagination ทำงานอยู่ node จะหมุนนาน (ดึงทีละ 10 จาก 2000+ record) — ไม่ได้ค้าง
- rate limit 429 "The service is receiving too many requests from you" → ใช้ Batching หรือ **Retry On Fail** + Wait Between Tries
- Credential มี **Allowed HTTP Request Domains** จำกัดว่ายิง domain ไหนได้ (ดู [[Credential]])

## Related
- [[Node - Webhook]] (ฝั่งรับ)
- [[Node - Split In Batches]], [[Pattern - Rate Limiting API Calls]]
- [[Credential]], [[OAuth2 in n8n]]
- [[Node - Code]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.httprequest
- https://docs.n8n.io/build/code-in-n8n/cookbook/http-request-node/pagination
- https://docs.n8n.io/integrations/builtin/handle-rate-limits
