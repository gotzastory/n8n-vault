---
tags: [n8n/concept]
type: concept
aliases: []
---

# Execution

## Definition
Execution = การรัน [[Workflow]] หนึ่งครั้ง.

## Execution mode
- **Manual** — กด Execute Workflow ใน editor, ไม่นับ execution quota, รองรับ partial execution + [[Pinned Data]]
- **Production** — trigger อัตโนมัติจาก trigger/schedule/webhook, workflow ต้อง publish แล้ว, นับ quota (paid plan)

## นับ quota ยังไง (production เท่านั้น)
| Trigger type | นับยังไง |
|---|---|
| Schedule Trigger | นับทุกครั้งที่ fire ไม่ว่าผลลัพธ์จะเป็นยังไง |
| Polling node | นับเฉพาะตอนเจอ data ใหม่ |
| Webhook Trigger | นับทุก request ที่เข้ามาแม้ body ว่าง, ยกเว้น malformed request ที่ fail ก่อนเริ่ม workflow |

ไม่นับ: manual execution, [[Sub-workflow (Execute Workflow)|sub-workflow]] execution (นับแค่ parent), error-workflow execution, poll ที่ไม่เจอข้อมูล

## Partial Execution
เลือก node → Execute step → รันเฉพาะ node นั้น + node ก่อนหน้าที่จำเป็น. ต้องมี trigger ต่ออยู่ในสาย ไม่งั้น error "destination node is not connected to any trigger".

## Debug
- **Retry with currently saved workflow** — รันใหม่ด้วย data เดิมแต่ workflow เวอร์ชันล่าสุด
- **Retry with original workflow** — รันซ้ำแบบเดิมทุกอย่าง
- Execution list กรองได้ตาม status (Failed/Running/Success/Waiting), เวลาเริ่ม, custom data

## Related
- [[Workflow]]
- [[Pinned Data]]
- [[Queue Mode]]
- [[Sub-workflow (Execute Workflow)]]

## Official Docs
- https://docs.n8n.io/build/understand-workflows/understand-executions
- https://docs.n8n.io/build/understand-workflows/understand-executions/types-of-executions
