---
tags: [n8n/node]
type: node
node-type: trigger
aliases: [Form Trigger, n8n Form]
---

# Node - Form Trigger

## What it does
เริ่ม workflow เมื่อผู้ใช้ส่งข้อมูลผ่าน n8n Form ใช้รับ text, number, date และไฟล์จากหน้าเว็บ โดยข้อมูลจะถูกส่งเป็น item เดียวที่มี field ของฟอร์มและ binary attachments

## Key parameters
- **Form Title / Form Description** — ข้อความบนหน้า form
- **Form Fields** — กำหนดชื่อและชนิดของ input
- **File field** — รับไฟล์เป็น binary; ใช้ `multipleFiles: true` เมื่อรับหลายไฟล์ใน submission เดียว
- **Required Field** — บังคับให้ผู้ส่งกรอกหรือแนบข้อมูล
- **Test URL / Production URL** — Test ใช้ระหว่างพัฒนา; Production ต้อง activate workflow

## Multi-file pattern
- Form field อาจถูกแปลงเป็น binary keys แบบ `Slip Images`, `Slip Images_1`, ...
- ต่อเข้า [[Node - Code]] เพื่อแยกเป็น 1 item ต่อ 1 ไฟล์ก่อนทำงาน downstream
- รักษา binary ตั้งแต่ Form → Normalize → upload; อย่าให้ branch ที่คืน JSON-only เป็นแหล่ง binary หลัก

## Connections in this workflow
`Intake Slip Form` แยกออกเป็น 2 สายแบบขนาน:

1. `→ Search Daily Folder → Daily Folder Exists? → ...` เพื่อเตรียมโฟลเดอร์รายวัน
2. `→ Normalize Slips → Merge Prepared Items` เพื่อแยกไฟล์เป็นราย item

สองสายถูกรวมที่ [[Node - Merge]] `Merge Prepared Items`

## Gotchas
- Manual execution ที่ไปถึง [[Node - Form Completion]] อาจค้างสถานะ `waiting` เพื่อรอ browser รับ response; ไม่ใช่ execution error
- Production form ใช้งานจริงได้เมื่อ activate workflow
- Form สาธารณะควรพิจารณา authentication หรือ hidden token หากต้องการป้องกัน spam
- ตรวจจำนวน binary และชื่อไฟล์หลัง Form ทุกครั้งใน workflow แบบหลายไฟล์

## Related
- [[Node - Code]]
- [[Node - Merge]]
- [[Binary Data]]
- [[Pattern - Multi-file Slip Intake Node Connections]]
- [[Workflow - Income Slip Intake LINE to Thunder]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.formtrigger
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.form
