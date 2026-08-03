---
tags: [n8n/pattern]
type: pattern
aliases: []
---

# Pattern - Chatbot Workflow

## Problem
สร้างหน้าคุยกับผู้ใช้ที่จำบริบทได้ ต่อกับ tool/ข้อมูลจริง

## Workflow Shape
```
Chat Trigger → [[Node - AI Agent]]
                 ├─ [[Node - Chat Model]]
                 ├─ Window Buffer Memory  ← ทำให้จำบทสนทนาได้
                 └─ Tools ([[Node - Tool (AI)]])
```
Chat Trigger ส่งค่า `output` หรือ `text` ของ node สุดท้ายกลับให้ผู้ใช้อัตโนมัติ

## Chat Trigger — parameters
- **Make Chat Publicly Available**: ปิดไว้ตอน build, เปิดตอน publish
  - **Mode**: **Hosted Chat** (ใช้หน้า chat ของ n8n, ตั้งค่าผ่าน node option ได้เลย — แนะนำ) / **Embedded Chat** (ทำ UI เอง หรือใช้ [@n8n/chat widget](https://www.npmjs.com/package/@n8n/chat) แล้วยิงเข้า **Chat URL**)
  - **Authentication**: None / Basic Auth / n8n User Auth
- **Initial Message(s)** (เฉพาะ Hosted)
- **Make Available in n8n Chat** — เผยแพร่เข้า Chat Hub (+ Agent Name/Description)

## Node options สำคัญ
- **Load Previous Session**: ต้องต่อ **memory sub-node ตัวเดียวกัน**ทั้ง Chat Trigger และ Agent (single source of truth)
- **Response Mode**:
  - *When Last Node Finishes* — คืน output ของ node สุดท้าย
  - *Using Response Nodes* — คุมคำตอบเองผ่าน **Chat node** หรือ Respond to Webhook
  - *Streaming response* — ตอบแบบ realtime (ต้องมี node ที่รองรับ streaming เช่น AI Agent)
- **Allowed Origin (CORS)**, **Input Placeholder / Title / Subtitle**, **Require Button Click to Start Chat**

## Chat node (human-in-the-loop ในบทสนทนา)
ต้องตั้ง Chat Trigger → **Response Mode = Using Response Nodes** ก่อน
- **Send Message** — ส่งแล้วไปต่อทันที
- **Send and Wait for Response** — หยุดรอผู้ใช้ตอบ แล้วค่อยเดินต่อ (หลาย turn ใน execution เดียว)
- Option **Add Memory Input Connection** — commit ข้อความจาก Chat node เข้า memory เดียวกับ agent เพื่อเก็บ history ครบ
- **ไม่รองรับ Embedded mode** — ใน Embedded ให้ใช้ Respond to Webhook แทน

## Memory
- 1 AI Agent ต่อ **memory sub-node ได้ 1 ตัว** — อยากผสมหลายแบบ ให้ใช้ memory sub-node กับ conversation history และต่อ vector store เป็น **tool** แทน
- Window Buffer Memory: เก็บ N ข้อความล่าสุด (5-20 ตามความเหมาะสม — ยาวไป = แพงไป). Session ID ใช้จาก Chat Trigger
- Postgres/Redis Chat Memory: persist ข้ามการรีสตาร์ท
- **Chat Memory Manager** node: เช็คขนาด memory / ล้าง entry เฉพาะจุด

## ⚠️ Execution quota
**ทุกข้อความ = 1 execution** — คุย 10 ข้อความ = 10 executions ([[Execution]])

## Multi-agent sequential
ต่อ AI Agent เรียงกันตรงๆ **ไม่ได้** — จะยิงต่อเนื่องทันทีทั้งหมด ไม่รอผู้ใช้ตอบ. ทางแก้:
1. **Supervisor agent** ตัวเดียว แล้วต่อ agent อื่นเป็น tool (AI Agent Tool / sub-workflow)
2. เก็บ **state/stage ของ session** ลง database แล้วใช้ [[Node - Switch]] route ตาม stage

## Related Patterns
- [[Pattern - AI Agent with Tools]]
- [[Pattern - RAG Pipeline in n8n]]
- [[Node - AI Agent]]
