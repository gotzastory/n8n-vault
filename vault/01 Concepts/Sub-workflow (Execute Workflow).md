---
tags: [n8n/concept]
type: concept
aliases: []
---

# Sub-workflow (Execute Workflow)

## Definition
เรียก workflow หนึ่งจากอีก workflow — ทำ modular/microservice-style automation ได้. ใช้ **Execute Sub-workflow** node (parent) คู่กับ **Execute Sub-workflow Trigger** node (ใน sub-workflow, ชื่อเดิม "When Executed by Another Workflow").

## Execute Sub-workflow — Source options
- **Database**: เลือกจาก list หรือใส่ Workflow ID
- **Local File**: path ไฟล์ JSON
- **Parameter**: วาง workflow JSON ตรงๆ
- **URL**: โหลดจาก URL

## Mode
- **Run once with all items** — ส่งทุก item เข้า sub-workflow execution เดียว (array)
- **Run once for each item** — รัน sub-workflow แยกทีละ item

## Node option
- **Wait for Sub-Workflow Completion** — เปิด = parent รอ sub-workflow จบก่อนไปต่อ, ปิด = ยิงแล้วไปต่อเลย

## Sub-workflow Trigger — Input data mode
- **Define using fields below** — parent จะเห็น field ที่ต้องกรอกอัตโนมัติ
- **Define using JSON example**
- **Accept all data** — ไม่บังคับ input, sub-workflow ต้องจัดการ inconsistency เอง

## Data ไหลยังไง
Workflow A (Execute Sub-workflow) → ส่งเข้า Workflow B's Trigger → node สุดท้ายของ B ส่ง data กลับ A

## ทำไมต้องใช้
- แก้ปัญหา [[Node - Code|node]]/logic ซ้ำกันหลาย workflow (auth, validation, notification) — แก้จุดเดียวจบ
- Sub-workflow execution **ไม่นับ execution quota** (แค่ parent เท่านั้นที่นับ) — ดู [[Execution]]
- ช่วยเลี่ยง memory issue เมื่อ workflow ใหญ่เกิน

## Gotcha
- Sub-workflow มี error อยู่ในตัว → parent trigger มันไม่ได้เลย
- Queue mode: Execute Sub-workflow / Workflow Tool รันบน worker เดียวกับ parent เสมอ (ไม่กระจายงานผ่าน Redis) ถ้าต้องการ distributed ต้องเปลี่ยนไปใช้ [[Node - Webhook]] + [[Node - HTTP Request]] แทน
- ต้องการรอ sub-workflow หลายตัวพร้อมกันจบ (fan-out/fan-in) — ยังไม่มี native support ตรงๆ ต้องออกแบบ pattern เอง (เช่น webhook + wait-for-all loop)

## Related
- [[Workflow]]
- [[Execution]]
- [[Queue Mode]]
- [[Connection (Main vs Error Output)]]
- [[Best Practice - Sub-workflows for Reuse]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.executeworkflow
- https://docs.n8n.io/build/flow-logic/break-workflows-into-smaller-parts
- https://docs.n8n.io/build/flow-logic/convert-to-sub-workflows
