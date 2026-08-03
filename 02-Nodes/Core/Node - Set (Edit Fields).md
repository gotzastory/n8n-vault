---
tags: [n8n/node]
type: node
node-type: core
aliases: [Set node, Edit Fields]
---

# Node - Set (Edit Fields)

## What it does
ตั้งค่า/เขียนทับ data ใน workflow. สำคัญมากเวลาต้องเตรียม data ให้ตรง schema ก่อนส่งเข้า Google Sheets/database

## Key Parameters
- **Mode**: **Manual Mapping** (GUI ลากวาง) หรือ **JSON Output** (เขียน JSON เอง)
- **Fields to Set**: ลากค่าจาก INPUT panel มาวาง — n8n ตั้งชื่อ field ให้ + gen expression ให้อัตโนมัติ. ไม่อยากใช้ expression ให้กด toggle **Fixed**
- **Keep Only Set Fields**: ทิ้ง input data ที่ไม่ได้ใช้
- **Include in Output**: เลือกว่าจะพก input field ไหนไปด้วย

## Node options
- **Include Binary Data** — ต้องเปิดถ้าจะให้ [[Binary Data]] ผ่านไปได้
- **Ignore Type Conversion Errors** (Manual Mapping เท่านั้น)
- **Support Dot Notation** — default เปิด: ชื่อ field `number.one` = สร้าง object ซ้อน `{number: {one: ...}}`. ปิดถ้าอยากได้ field ชื่อ `"number.one"` ตรงๆ

## Best practice
อย่ายัด expression ซับซ้อนกระจายหลาย node — **ใช้ Edit Fields เตรียม data ให้เรียบร้อยก่อน** แล้วส่งต่อไป node ถัดไป ทำให้ workflow อ่านง่าย/แก้ง่าย

Cast data type ให้ตรงตั้งแต่ต้นทาง (string `"100"` → number `100`) กัน database ปฏิเสธ record ปลายทาง

## Common Gotchas
- Default Edit Fields **เก็บเฉพาะ field ที่ map ไว้** — field อื่นหายหมด ถ้าไม่เปิด "Include Other Input Fields"
- **Include Binary Data** ไม่โผล่ในบาง version/mode — ต้องสลับ mode เป็น JSON หรือเปิด "Include Other Input Fields"
- ต่อจาก [[Node - Merge]] แบบ Append แล้วอ่านค่าไม่เจอ → เพราะ append ให้ item แยกกัน ต้องใช้ Combine mode แทน

## Related
- [[Node - Code]] (dataset ซับซ้อนกว่า)
- [[Expression Syntax]]
- [[Pinned Data]] (Edit Fields ใช้ mock data ได้)
- Rename Keys node (แค่เปลี่ยนชื่อ field)

## Official Docs
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.set
- https://docs.n8n.io/build/work-with-data/transform-data/expressions-for-data-transformation
