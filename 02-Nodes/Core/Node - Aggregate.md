---
tags: [n8n/node]
type: node
node-type: core
aliases: []
---

# Node - Aggregate

## What it does
เอา item หลายตัวมารวมเป็น **item เดียว** — ตรงข้ามกับ Split Out node

```
// input: 5 items
[{"data":"1"},{"data":"2"},{"data":"3"},{"data":"4"},{"data":"5"}]

// output: 1 item
[{"data":["1","2","3","4","5"]}]
```

## Aggregate mode
### Individual Fields
- **Input Field Name**: ชื่อ field ที่จะรวม
- **Rename Field** → **Output Field Name**: ตั้งชื่อใหม่ใน output (**บังคับ**ถ้ารวมหลาย field)

### All Item Data
- **Put Output in Field**: ชื่อ field ที่เก็บผลลัพธ์
- **Include**: All fields / Specified Fields (comma-separated) / All Fields Except

## Node options
- **Merge Lists**: field ที่รวมเป็น list อยู่แล้ว → ให้ออกเป็น flat list เดียว ไม่ใช่ list ของ list
- **Include Binaries**: พก [[Binary Data]] ไปด้วย
- **Keep Missing And Null Values**: ใส่ null ใน output list เมื่อ input ไม่มีค่า (ปิด = ข้ามไปเลย)
- **Disable Dot Notation**

## Aggregate vs Summarize vs Split Out vs Merge
| Node | ทำอะไร |
|---|---|
| **Aggregate** | หลาย item → 1 item (list) |
| **Split Out** | 1 item ที่มี array → หลาย item |
| **Summarize** | คำนวณสรุปแบบ pivot table (Sum, Count, Avg, Min, Max, Concatenate) + Split By (group by) |
| [[Node - Merge]] | รวม data จากคนละ stream/branch |

**นับ/คำนวณ → ใช้ Summarize, ไม่ใช่ Aggregate**

## Use case ที่เจอบ่อย
- ต่อที่ output **`done`** ของ [[Node - Split In Batches]] เพื่อรวมผลทุกรอบก่อนส่งเข้า [[Node - AI Agent]] — ถ้าใช้ [[Node - NoOp]] จะได้ทีละตัว
- ต้อง POST array ทั้งก้อนใน body เดียวผ่าน [[Node - HTTP Request]] — ไม่งั้น n8n จะยิงทีละ item

## Related
- [[Node - Split In Batches]]
- [[Node - Merge]]
- [[Item (n8n Data Structure)]]
- [[Node - HTTP Request]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.aggregate
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.summarize
