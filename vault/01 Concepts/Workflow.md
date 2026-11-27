---
tags: [n8n/concept]
type: concept
aliases: []
---
# Workflow

## Definition
Workflow = collection ของ [[Node|node]] ที่เชื่อมกันเพื่อ automate process หนึ่งอย่าง. วางบน canvas, save/retrieve/modify/execute ได้ตามต้องการ.

## Run ยังไง
- **Manual**: กด **Execute Workflow** — ใช้ตอน build/test, หรือ workflow ไม่มี trigger node
- **Automatic**: ต้อง publish workflow ก่อน (ปุ่ม **Publish**) แล้วรันเองตาม trigger condition — workflow ใหม่ default เป็น unpublished เสมอ

## Anatomy
- Trigger node (จุดเริ่ม) → connection → action/core node ต่อกันเป็นสาย
- **Five stages pattern** ที่นิยม: Trigger → Configuration → Data Retrieval → Data Processing → Action

## Workflow Settings สำคัญ
- **Execution order**: v1 (recommended, รันทีละ branch จนจบ) vs v0 (legacy, สลับ node ทีละ branch)
- **Error Workflow**: กำหนด workflow ที่จะ trigger เมื่อ workflow นี้ error
- **This workflow can be called by**: จำกัดว่า workflow ไหนเรียก sub-workflow นี้ได้
- **Timezone**: สำคัญกับ [[Node - Schedule Trigger]]
- **Save failed/successful/manual executions**, **Save execution progress**
- **Timeout Workflow**

## Related
- [[Node]]
- [[Execution]]
- [[Connection (Main vs Error Output)]]
- [[Trigger vs Action Node]]
- [[Sub-workflow (Execute Workflow)]]

## Official Docs
- https://docs.n8n.io/build/understand-workflows
- https://docs.n8n.io/build/understand-workflows/create-and-run-workflows
- https://docs.n8n.io/build/manage-workflows/configure-workflow-settings
