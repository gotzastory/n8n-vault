---
tags: [n8n/node]
type: node
node-type: core
aliases: []
---

# Node - Filter

## What it does
กรอง item ตามเงื่อนไข — item ที่ผ่านไปต่อ, item ที่ไม่ผ่าน**ถูกทิ้งไปเลย** (ไม่มี output ที่สอง แบบ [[Node - IF]])

## Key Parameters
- **Conditions**: เหมือน IF node — เลือก data type + comparison
- **Combinator**: AND / OR — **ผสม AND กับ OR ในตัวเดียวไม่ได้**

## Node options
- **Ignore Case**
- **Less Strict Type Validation** — เปิดเมื่อเจอ error "wrong type:"

## Comparison ตาม data type
| Type | operation |
|---|---|
| String | exists, is empty, is equal to, contains, starts/ends with, matches regex |
| Number | exists, is empty, is equal to, greater/less than (or equal) |
| Date & Time | exists, is empty, is equal to, is after/before (or equal) |
| Boolean | exists, is empty, is true, is false, is equal to |
| **Array** | exists, is empty, contains, length equal/not equal/greater/less than |
| **Object** | exists, does not exist, is empty, is not empty |

> Array/Object comparison มีเฉพาะใน Filter (IF node ไม่มีในเอกสาร)

## เลือกใช้อะไรดี
| ต้องการ | ใช้ |
|---|---|
| ทิ้ง item ทั้งตัวตามเงื่อนไข | **Filter** |
| แยก branch true/false ทำงานคนละอย่าง | [[Node - IF]] |
| ลบ field ออกจาก item (เก็บ item ไว้) | [[Node - Set (Edit Fields)]] |
| กรอง element ใน array ภายใน item | `.filter()` ใน expression / [[Node - Code]] |
| ทิ้ง item ที่เคยเจอใน execution ก่อนหน้า | Remove Duplicates node |

## Related
- [[Node - IF]]
- [[Node - Switch]]
- [[Node - Set (Edit Fields)]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.filter
- https://docs.n8n.io/build/work-with-data/filter-out-unwanted-data
