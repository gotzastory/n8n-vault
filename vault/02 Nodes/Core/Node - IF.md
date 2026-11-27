---
tags: [n8n/node]
type: node
node-type: core
aliases: []
---

# Node - IF

## What it does
แยก workflow เป็น 2 ทาง (true/false) ตามเงื่อนไขเปรียบเทียบ. **item ที่ตรงเงื่อนไขไป output `true`, ที่เหลือไป `false`** — ประเมินทีละ item

## Key Parameters
- **Conditions**: เลือก data type + comparison operation จาก dropdown แล้วกรอกค่า
- **Combinator**: AND (ต้องตรงทุกเงื่อนไข) / OR (ตรงข้อใดข้อหนึ่ง)
- `typeValidation`: strict (default) vs loose — loose ให้ n8n พยายามแปลง type ให้

## Comparison ตาม data type
| Type | operation |
|---|---|
| String | exists, is empty, is equal to, contains, starts/ends with, matches regex (+ negation ทุกตัว) |
| Number | exists, is empty, is equal to, is greater/less than (or equal to) |
| Date & Time | exists, is empty, is equal to, is after/before (or equal to) |
| Boolean | exists, is empty, is true, is false, is equal to |

## Input / Output
- Input: items
- Output: 2 branch — `true` (index 0), `false` (index 1)

## Common Gotchas
- **String comparison ไม่ต้องใส่ quote** — พิมพ์ `YES` ไม่ใช่ `"YES"` ไม่งั้นไม่ match แล้วตกไป false หมด
- ค่าจริงมี space/case ต่างกันทำให้ match พลาด → normalize ก่อน: `{{ $json.status && $json.status.toLowerCase().trim() === 'active' }}`
- เปิด **Always Output Data** บน IF node อาจทำ infinite loop
- **v0 legacy execution order**: ถ้ามี [[Node - Merge]] ต่อท้าย IF ทั้งสอง branch จะรันหมดแม้ไม่มี data — n8n เอาพฤติกรรมนี้ออกแล้วใน v1

## Related
- ต้องการมากกว่า 2 output → ใช้ [[Node - Switch]]
- อยากกรอง item ทิ้งเฉยๆ (ไม่แยก branch) → ใช้ [[Node - Filter]]
- รวม branch กลับ → [[Node - Merge]]
- Concept: [[Connection (Main vs Error Output)]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.if
- https://docs.n8n.io/build/flow-logic/split-with-conditionals
