---
tags: [n8n/node]
type: node
node-type: trigger
aliases: [Cron]
---

# Node - Schedule Trigger

## What it does
Trigger workflow ตามเวลา/รอบที่กำหนด — เทียบเท่า cron ใน Unix. **ต้อง save + publish workflow ถึงจะทำงาน**

## Trigger Interval
| Interval | พารามิเตอร์ |
|---|---|
| Seconds | Seconds Between Triggers |
| Minutes | Minutes Between Triggers |
| Hours | Hours Between Triggers + Trigger at Minute (0-59) |
| Days | Days Between Triggers + Trigger at Hour + Minute |
| Weeks | Weeks Between + Trigger on Weekdays + Hour + Minute |
| Months | Months Between + Trigger at Day of Month (1-31) + Hour + Minute |
| Custom (Cron) | Cron Expression |

เพิ่ม **Trigger Rule** ได้หลายอัน — **rule เป็นแบบบวกกัน (additive)** ไม่ใช่ AND!

## Cron expression
ใช้ [crontab.guru](https://crontab.guru) gen ได้. n8n รองรับ **6 ช่อง** — ช่องที่ 6 คือวินาที (optional):
```
(second) minute hour day-of-month month day-of-week
```
ตัวอย่าง:
| Cron | ความหมาย |
|---|---|
| `*/5 * * * *` | ทุก 5 นาที |
| `0 6 * * *` | 6:00 ทุกวัน |
| `0 9 * * 1-5` | 9:00 จันทร์-ศุกร์ |
| `0 9-17 * * *` | ทุกชั่วโมง 9:00-17:00 |
| `5,20,35,50 7-23 * * *` | นาทีที่ 5,20,35,50 ของทุกชั่วโมง 7:00-23:00 |
| `0 0 1 1,4,7,10 *` | เที่ยงคืน วันที่ 1 ของ ม.ค./เม.ย./ก.ค./ต.ค. |

## Timezone
ลำดับความสำคัญ: **workflow timezone** → **instance timezone**. Default self-host = `America/New_York`, Cloud = ตรวจจาก owner (fallback GMT). ตั้งได้ที่:
- Self-host: `GENERIC_TIMEZONE` ใน [[Environment Variables]]
- ต่อ workflow: three-dots menu → Settings → Timezone

## Common Gotchas
- **หลาย Trigger Rule = บวกกัน**: ตั้ง "ทุก 15 นาที" + "ทุกวัน 7:05" จะยิงทั้ง 6:45, 7:00, 7:05, 7:15... ไม่ใช่ 7:05 แล้วทุก 15 นาที → ใช้ cron แทน
- **`*/N` เป็นการหารรอบภายในหน่วยนั้น ไม่ใช่ทุกๆ N จริง**: `*/50 * * * *` ยิงนาทีที่ 0 และ 50 ของทุกชั่วโมง = ห่าง 50 นาทีแล้ว 10 นาที
- **แก้ interval หลัง publish แล้วไม่มีผลจนกว่าจะ unpublish + publish ใหม่** — schedule นับจากเวลาที่ publish
- Variable ใน cron expression evaluate แค่ตอน publish — แก้ค่า variable ทีหลังไม่มีผล
- interval แบบ hours/days ไม่ทำงานเป็นบางครั้ง (report บ่อยทั้ง Cloud/self-host) → ชุมชนแนะนำใช้ **Custom Cron** แทน เสถียรกว่า
- [[Pinned Data]] ไม่ทำงานกับ Schedule Trigger (development-only feature)
- นับ execution quota ทุกครั้งที่ fire ไม่ว่าผลเป็นยังไง (ดู [[Execution]])

## Related
- [[Trigger vs Action Node]]
- [[Workflow]] (workflow settings → timezone)
- [[Pattern - Polling API (Schedule Trigger)]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.scheduletrigger
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.scheduletrigger/common-issues
