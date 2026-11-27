---
type: n8n-node
package: "@aotoki/n8n-nodes-line-messaging"
node_type: "@aotoki/n8n-nodes-line-messaging.lineMessagingData"
tags: [n8n/node, line, community-node, binary]
---

# Node - Line Messaging Data

- Display name: **Line Messaging Data** (community node, typeVersion 1)
- Node type: `@aotoki/n8n-nodes-line-messaging.lineMessagingData`
- Credential: `lineMessagingApi` (ใช้ตัวเดียวกับ Line Messaging / Trigger ของ OA นั้น ๆ)
- ดูเพิ่ม: [[Node - Line Messaging]]

## Operations
- `getContent` — ดึง content (รูป/วิดีโอ/เสียง/ไฟล์) ที่ผู้ใช้ส่งมา ด้วย messageId → binary
  - `messageId` (required), `binaryPropertyName` (default `data`)
  - `additionalOptions`: `checkTranscoding` (default false, สำหรับไฟล์ใหญ่/วิดีโอ), `retryCount` (3), `retryInterval` วินาที (3)
- `__CUSTOM_API_CALL__`

## Gotchas
- credential ต้องเป็น OA เดียวกับที่รับ webhook — messageId ของ OA หนึ่งดึงด้วย token ของอีก OA ไม่ได้
- ใช้แทน HTTP Request ไป `https://api-data.line.me/v2/bot/message/{id}/content` + Bearer ได้ ไม่ต้องสร้าง httpBearerAuth แยก
- ส่ง binary `data` ต่อเข้า Google Drive upload (`inputDataFieldName: data`) ได้ตรง ๆ

## Used in
- [[Workflow - LINE Image Intake to Google Drive]] (KV1ZI0abRxMOhjcj)
