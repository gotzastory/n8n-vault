---
tags: [n8n/node]
type: node
node-type: core
aliases: []
---

# Node - Merge

## What it does
รวม data จากหลาย stream — **รอจนทุก input พร้อมก่อน** ถึงจะ output

## Mode
### Append
เก็บ data ทุก input ต่อกันเป็นแถวเรียงกัน. ตั้ง **Number of Inputs** ได้ (n8n ≥1.49.0 รองรับมากกว่า 2 input; เวอร์ชันเก่ารองรับแค่ 2)

### Combine
รวม data จาก 2 input เข้าเป็น item เดียวกัน — เลือก **Combine By**:

| Combine By | ทำอะไร |
|---|---|
| Matching Fields | เทียบตามค่าใน field ที่ระบุ (แบบ SQL join) |
| Position | จับคู่ตามลำดับ index (0↔0, 1↔1) |
| All Possible Combinations | ทุก combination ที่เป็นไปได้ |

**Output Type** (สำหรับ Matching Fields):
- **Keep Matches** = inner join (default)
- **Keep Non-Matches** = เอาเฉพาะที่ไม่ match
- **Keep Everything** = outer join
- **Enrich Input 1** = left join
- **Enrich Input 2** = right join

### SQL Query
เขียน SQL รวม data ตรงๆ (n8n ≥1.49.0)

## Combine mode options
- **Clash Handling**: field ชื่อซ้ำกันจะเอาของ input ไหน — default ให้ **Input 2 ชนะ**. เลือก "Always Add Input Number to Field Names" เพื่อเก็บทั้งคู่ได้
  - **Deep Merge** (merge ทุกชั้นรวม nested) vs **Shallow Merge** (แค่ชั้นบนสุด)
- **Fuzzy Compare**: มอง `"3"` กับ `3` เป็นค่าเดียวกัน
- **Multiple Matches**: Include All Matches / Include First Match Only
- **Include Any Unpaired Items**: เก็บ item ที่ไม่มีคู่ไว้ด้วย (Position mode)
- **Disable Dot Notation**

## Common Gotchas
- **Append vs Combine เลือกผิดคือสาเหตุปัญหาอันดับ 1**: input เป็น list คนละเรื่อง → Append; เป็น record เดียวกันคนละ branch → Combine
- Combine by Position จับคู่ตาม**ลำดับ** ไม่ใช่ค่าจริง — ลำดับเปลี่ยน = จับคู่ผิด. ต้องการจับคู่ตาม id ให้ใช้ Matching Fields
- Append แล้วได้ item แยกกันหลายตัว ไม่ใช่ item เดียวที่มีทุก field — ต้องการรวมเป็น item เดียวต้องใช้ Combine
- Merge ทำ [[n8n Expression - $json|item linking]] พัง → `.item` error "Multiple matching items" → ใช้ `.first()/.last()/.all()[i]` แทน
- `$prevNode` ใน Merge node ชี้ไปที่ **input connector แรก** เสมอ
- Binary data ไม่ผ่าน Merge เอง — ดู [[Binary Data]]

## Related
- [[Node - IF]], [[Node - Switch]] (แยก branch ก่อน merge)
- [[Node - Aggregate]] (รวม item เป็น list)
- [[Binary Data]]
- Compare Datasets node (เทียบก่อน merge, output ได้ถึง 4 stream)

## Official Docs
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.merge
- https://docs.n8n.io/build/flow-logic/merge-data
