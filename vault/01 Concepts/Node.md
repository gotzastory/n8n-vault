---
tags: [n8n/concept]
type: concept
aliases: []
---

# Node

## Definition
Node = building block ของ [[Workflow]] — entry point ดึงข้อมูล, ฟังก์ชันประมวลผลข้อมูล, หรือ exit ส่งข้อมูลออก. filter/recompose/เปลี่ยนข้อมูลได้.

## Operation 2 แบบ
- **Trigger** — เริ่ม workflow ตาม event/condition, มี icon สายฟ้า. workflow production ต้องมีอย่างน้อย 1 trigger
- **Action** — งานเฉพาะทาง เช่น manipulate data, เรียก external system

## หมวดของ node
| หมวด | ลักษณะ |
|---|---|
| Core nodes | เป็นได้ทั้ง action/trigger, ให้ logic/scheduling/generic API call (เช่น IF, Code, HTTP Request) |
| Cluster nodes | กลุ่ม node ทำงานร่วมกัน มี root node + sub-node ขยายความสามารถ (เช่น [[Node - AI Agent]] + tool sub-node) |
| Community nodes | บุคคลที่สามสร้างเอง, ติดตั้งเพิ่มได้ |
| Credential-only nodes | ไม่มี node แยก แต่ตั้ง credential ใช้กับ [[Node - HTTP Request]] ได้ |

## Node Settings (tab Settings ของแต่ละ node)
- **Always Output Data** — คืน empty item แม้ node ไม่มีผลลัพธ์ (ระวัง infinite loop ถ้าใช้กับ [[Node - IF]])
- **Execute Once** — รันครั้งเดียวด้วย item แรกที่รับมา
- **Retry On Fail** — รันซ้ำจนสำเร็จเมื่อ error
- **On Error**: Stop Workflow / Continue / Continue (using error output)

## Related
- [[Trigger vs Action Node]]
- [[Connection (Main vs Error Output)]]
- [[Workflow]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/node-types
- https://docs.n8n.io/build/understand-workflows/workflow-components/work-with-nodes
