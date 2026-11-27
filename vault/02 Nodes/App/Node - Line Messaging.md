---
tags: [n8n/node, line-oa]
type: node
node-type: action
aliases: [Line Messaging]
---

# Node - Line Messaging

## Node type

`@aotoki/n8n-nodes-line-messaging.lineMessaging`

Community node สำหรับ LINE Messaging API

## Operations

| Operation | ใช้สำหรับ |
|---|---|
| `reply` | ตอบข้อความด้วย reply token |
| `send` | ส่งข้อความใหม่ไปยัง user |
| `getProfile` | ดึงข้อมูลโปรไฟล์ user |
| `multicast` | ส่งข้อความไปหลาย user |
| `showLoadingAnimation` | แสดง loading animation |

## Standard convention

สำหรับทุก workflow ที่เกี่ยวข้องกับ LINE OA ให้ใช้ **Line Messaging** node นี้เป็นค่าเริ่มต้น แทน HTTP Request หรือ built-in `n8n-nodes-base.line` เมื่อ operation ที่ต้องการรองรับอยู่แล้ว

Credential type: `lineMessagingApi`

## Reply message

- Operation: `reply`
- Reply Token: ใช้ `replyToken` จาก LINE webhook event
- Messages รองรับ `textV2` และ `flex`
- Carousel ใช้ Flex message โดยกำหนด `flexJson`
- Rich Menu actions ต้องตั้งค่าระดับ LINE OA เพิ่มเติม; node นี้ใช้ส่งข้อความหรือรองรับ postback flow

## Gotchas

- `replyToken` ใช้ได้กับการตอบ event ที่ได้รับ และไม่ควรเก็บไว้ใช้ภายหลัง
- ต้องตั้งค่า credential ก่อนทดสอบจริง
- ตรวจสอบชนิดข้อความและ JSON ของ Flex ให้ตรง LINE Messaging API
- ควรแยก Sandbox/Production credential หรือ environment ให้ชัดเจน
- ก่อน Production ควรตรวจสอบ LINE webhook signature ด้วย Channel Secret

## Related

- [[Workflow - LINE OA CRM Sandbox Flow]]
- [[Node - Webhook]]
- [[Node - Set (Edit Fields)]]
- [[Node - Switch]]
- [[Pattern - Chatbot Workflow]]
- [[Credential]]

## Official / Reference

- https://developers.line.biz/en/reference/messaging-api/
- `@aotoki/n8n-nodes-line-messaging.lineMessaging`
- Credential type: `lineMessagingApi`

> ห้ามเก็บ Channel Access Token, Channel Secret หรือ credential value ในไฟล์นี้
> อ้างอิง node type definitions จาก n8n MCP ก่อนสร้างหรือแก้ไข workflow

Last updated: 2026-08-02
- ดูเพิ่ม: [[Node - Line Messaging Data]] (ดึง content ของข้อความเป็น binary)
