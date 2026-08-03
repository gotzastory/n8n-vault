---
tags: [n8n/node]
type: node
node-type: core
aliases: [No Operation do nothing]
---

# Node - NoOp

## What it does
ชื่อเต็ม **No Operation, do nothing** — ไม่ทำอะไรเลย. มีไว้เพื่อทำให้ workflow อ่านง่ายขึ้น บอกสายตาว่า data flow จบตรงนี้

## ใช้ทำอะไรจริงบ้าง
- ปิดท้าย branch `false` ของ [[Node - IF]] ให้ชัดว่าตั้งใจไม่ทำอะไร (ไม่ใส่ก็ได้ ไม่กระทบการทำงาน)
- **รวมหลาย path เข้าด้วยกัน**เมื่อไม่อยากใช้ [[Node - Merge]] หรือ [[Node - Aggregate]]
- ปิดท้าย loop ของ [[Node - Split In Batches]] ให้ item count ไม่เพี้ยน (node ก่อนหน้าที่เพิ่ม item ทำ loop พังได้)
- ต่อท้ายแต่ละ output ของ [[Node - Switch]] แทนการเปิด "Always Output Data" (ซึ่งมี bug)
- n8n ใส่ NoOp ชื่อ **"Replace Me"** ให้อัตโนมัติเมื่อเพิ่ม Loop Over Items node

## Input / Output
input → output เหมือนเดิมไม่เปลี่ยนแปลง

## Gotcha
ต่อที่ output `done` ของ Loop Over Items แล้วอยากได้ผลรวมทั้งหมด — **NoOp ให้ไม่ได้** ต้องใช้ [[Node - Aggregate]] แทน

## Related
- [[Node - Split In Batches]]
- [[Node - Switch]]
- [[Node - Aggregate]]
- Debug Helper node (มี category "Do Nothing" ด้วย แต่ทำ throw error / gen random data ได้ด้วย)

## Official Docs
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.noop
