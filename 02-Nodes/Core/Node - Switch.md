---
tags: [n8n/node]
type: node
node-type: core
aliases: []
---

# Node - Switch

## What it does
Route workflow แบบหลายทาง — เหมือน [[Node - IF]] แต่มี output ได้ไม่จำกัด

## Mode
### Rules
สร้าง **Routing Rule** ต่อ 1 output. เลือก data type + comparison เหมือน IF node. เปิด **Rename Output** เพื่อตั้งชื่อ output ให้อ่านง่าย

**Rule options:**
- **Fallback Output**: item ที่ไม่ตรงกฎไหนเลยไปไหน — None (ทิ้ง, default) / Extra Output (output แยก) / Output 0
- **Ignore Case**: ไม่สนตัวพิมพ์เล็กใหญ่
- **Less Strict Type Validation**: ให้ n8n แปลง type ให้
- **Send data to all matching outputs**: เปิด = ส่งไปทุก output ที่ตรง, ปิด = ส่งเฉพาะ output แรกที่ตรง

### Expression
- **Number of Outputs**: จำนวน output
- **Output Index**: expression ที่ return เป็น**ตัวเลข** index ของ output

## Input / Output
- Input: items
- Output: ตามจำนวน rule (+ fallback ถ้าตั้ง Extra Output)

## Common Gotchas
- **ห้ามเปิด "Always Output Data"** — bug ที่ทราบแล้ว: จะดัน empty item ออกทาง output แรกเสมอแทน output ที่ไม่ match จริง ([GitHub #17504](https://github.com/n8n-io/n8n/issues/17504)) — ใช้ [[Node - NoOp]] ต่อท้ายแต่ละ output แทน
- ค่าที่มี space เกิน/case ต่างทำให้ตกไป fallback เสมอ → copy ค่าจริงมาวาง หรือเปิด Ignore Case
- item หายกลางทางหลัง Switch มักไม่ใช่ Switch เอง แต่เป็น node ถัดไปที่ไม่ output อะไร → ไล่ดูจำนวน run ของแต่ละ node

## Related
- [[Node - IF]] (2 output)
- [[Node - Filter]]
- [[Node - Merge]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.switch
- https://docs.n8n.io/build/flow-logic/split-with-conditionals
