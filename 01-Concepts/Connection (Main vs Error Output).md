---
tags: [n8n/concept]
type: concept
aliases: []
---

# Connection (Main vs Error Output)

## Definition
Connection = เส้นเชื่อม node ต่อ node ส่ง data จาก output ของ node หนึ่งเข้า input ของอีก node. สร้างโดยลาก dot ท้าย node ไป input ของ node ถัดไป.

## Main output vs Error output
- **Main** = output ปกติของ node
- **Error output** เปิดใช้ผ่าน node Settings → **On Error: Continue (using error output)** — node จะมี output แยกเป็น 2 เส้น: success ไปทางหนึ่ง, error routing ไปอีกทาง (ไปแจ้งเตือน/log/fallback logic ได้)

## On Error options (ต่อ node)
| ตัวเลือก | พฤติกรรม |
|---|---|
| Stop Workflow (default) | หยุดทั้ง workflow ทันทีที่ error |
| Continue | ไปต่อ node ถัดไปโดยใช้ data ล่าสุดที่ valid — **เงียบ ไม่มีสัญญาณว่ามี error เกิด** |
| Continue (using error output) | ส่ง error ไปยัง output แยก ต่อ logic รับมือ error ได้ (แจ้งเตือน Slack/email, fallback service) |

## Pattern ที่ใช้บ่อย
- ต่อ error output ไปหา node แจ้งเตือน แทนปล่อยให้ error เงียบหาย
- Fallback service: HTTP node หลักถ้า error → error output ไป HTTP node สำรอง
- ห่อ node เสี่ยง (เช่น SSH) เป็น [[Sub-workflow (Execute Workflow)|sub-workflow]] แล้วตั้ง Execute Sub-workflow node's On Error = Continue (using error output) เพื่อดัก error จาก sub-workflow ทั้งก้อน

## Related
- [[Node]]
- [[Sub-workflow (Execute Workflow)]]
- [[Best Practice - Error Workflow Setup]]

## Official Docs
- https://docs.n8n.io/build/understand-workflows/workflow-components/connect-nodes-together
- https://docs.n8n.io/build/understand-workflows/workflow-components/work-with-nodes#node-settings
