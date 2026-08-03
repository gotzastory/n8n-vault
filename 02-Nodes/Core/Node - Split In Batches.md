---
tags: [n8n/node]
type: node
node-type: core
aliases: [Loop Over Items]
---

# Node - Split In Batches

## What it does
ชื่อปัจจุบัน **Loop Over Items**. เก็บ input เดิมไว้ แล้วปล่อยออกทีละ batch ทาง output **`loop`**. พอหมดทุก item จะรวมผลทั้งหมดปล่อยออกทาง output **`done`**

## เมื่อไหร่ถึงต้องใช้
n8n loop ให้เองอยู่แล้วโดยธรรมชาติ — **ส่วนใหญ่ไม่ต้องใช้ node นี้**. ใช้เมื่อ:
- ต้องการ throttle/batch เพื่อกัน rate limit (ดู [[Pattern - Rate Limiting API Calls]])
- node ที่ไม่ loop ให้เอง (RSS Read, Redis Info, MongoDB insert/update, [[Node - Code]] แบบ Run Once for All Items, Execute Workflow, [[Node - HTTP Request]] pagination)
- ต้องการประมวลผลทีละตัวจริงๆ → ตั้ง **Batch Size = 1**

## Key Parameters
- **Batch Size**: จำนวน item ต่อรอบ

## Node options
- **Reset**: เปิดเมื่อต้องการให้ node มอง input ใหม่เป็นชุดใหม่ (ไม่ใช่ต่อจากชุดเดิม). ใช้กับ pattern ดึง API แบบไม่รู้จำนวนหน้าล่วงหน้า + [[Node - IF]] เช็คเงื่อนไขหยุด
  - **ต้องมีเงื่อนไขหยุดที่ valid เสมอ** ไม่งั้น infinite loop
  - ปรับเป็น Expression ได้ เช่น `{{ $prevNode.name === 'get_products' }}`

## Expression ที่ใช้บ่อย
```
{{ $("Loop Over Items").context["noItemsLeft"] }}     // boolean: หมดแล้วหรือยัง
{{ $("Loop Over Items").context["currentRunIndex"] }} // รอบปัจจุบัน
```

## Common Gotchas
- **ลืมต่อ output ของ node สุดท้ายกลับเข้า Loop node** = รันแค่ batch แรกแล้วหยุด — สาเหตุ #1
- **Nested loop ใช้ไม่ได้ดี**: Loop Over Items เก็บ state ภายใน → loop ซ้อนใน workflow เดียวกันจะทำงานถูกแค่รอบแรกของ loop นอก. แก้: แยก loop ในเป็น [[Sub-workflow (Execute Workflow)|sub-workflow]] หรือ flatten data ก่อน หรือใช้ option Reset แบบ expression
- **ห้ามเปิด Always Output Data** บน Loop node — ทำ branch ทำงานผิด
- node ใน loop เพิ่มจำนวน item (เช่น insert node คืนหลาย row) ทำให้ item count ไม่ตรงและ loop พัง → ปิดท้าย loop ด้วย [[Node - NoOp]] เปล่าๆ
- อยากรวมผลทั้งหมดหลัง loop จบ → ต่อ [[Node - Aggregate]] ที่ output `done` (ไม่ใช่ NoOp)

## Related
- [[Node - Aggregate]] (รวมผลหลัง loop)
- [[Node - IF]] (เงื่อนไขหยุด)
- [[Node - NoOp]]
- [[Pattern - Batch Processing with Split In Batches]]
- [[Sub-workflow (Execute Workflow)]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.splitinbatches
- https://docs.n8n.io/build/flow-logic/loop
