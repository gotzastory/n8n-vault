---
tags: [n8n/concept]
type: concept
aliases: []
---

# Trigger vs Action Node

## Definition
- **Trigger node**: เริ่ม workflow ตอบสนอง event/condition. Workflow มี trigger หลายตัวได้ แต่แต่ละ execution จะมีแค่ตัวเดียวที่ทำงานจริง (ตัวที่ตรง event)
- **Action node**: งานเฉพาะทาง manipulate data / เรียก external system / trigger event ในระบบอื่น ต้องต่อกันเป็น chain

## ประเภทของ Trigger
| ประเภท | ทำงานยังไง | ตัวอย่าง |
|---|---|---|
| Webhook | ฟัง event realtime ผ่าน webhook | [[Node - Webhook]], Telegram Trigger |
| Polling | เช็ค data ใหม่เป็นช่วงๆ (สำหรับ service ที่ไม่มี webhook) | Airtable Trigger, Gmail Trigger, Google Sheet Trigger |
| Others | realtime แบบไม่ใช่ HTTP/polling | [[Node - Schedule Trigger]], MQTT/AMQP Trigger, IMAP Trigger |

## Tool node vs Action node (สำคัญตอนทำ AI workflow)
- Tool sub-node = ต่อเข้ากับ [[Node - AI Agent]] ให้ LLM เรียกใช้เอง
- Action node = ใช้เดี่ยวๆ ในสาย workflow ปกติ ต่อกันเอง
- โหนดเดียวกัน (เช่น Gmail) มักมีทั้ง 2 แบบให้เลือก — เลือกผิดจะพังพฤติกรรมที่คาดหวัง

## Gotcha
- ทุก production workflow ต้องมี trigger node อย่างน้อย 1 ตัว (ไม่งั้น publish ไม่ได้/ต้องรัน manual ตลอด)
- workflow ไม่มี node เชื่อมกับ trigger เลย → partial execution error "destination node is not connected to any trigger"

## Related
- [[Node]]
- [[Node - Schedule Trigger]]
- [[Node - Webhook]]
- [[Node - AI Agent]]

## Official Docs
- https://docs.n8n.io/connect/create-nodes/plan-your-node/choose-a-node-type
- https://docs.n8n.io/integrations/builtin/trigger-nodes
