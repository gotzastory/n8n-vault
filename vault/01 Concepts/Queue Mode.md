---
tags: [n8n/concept]
type: concept
aliases: []
---

# Queue Mode

## Definition
โหมด self-host ที่ scale ได้ดีสุด — แยก main instance (รับ trigger/webhook) ออกจาก worker instance (รันจริง) ผ่าน Redis เป็น message broker.

## Flow การทำงาน
1. Main instance รับ timer/webhook → สร้าง execution ID (ยังไม่รัน)
2. ส่ง execution ID เข้า Redis queue
3. Worker ตัวว่างดึงจาก Redis → โหลด workflow info จาก database ด้วย execution ID
4. Worker รันจบ → เขียนผลลง database + แจ้ง Redis ว่าจบ
5. Redis แจ้ง main instance กลับ

## ต้องมี
- `EXECUTIONS_MODE=queue` (main + worker ทุกตัว)
- Redis (`QUEUE_BULL_REDIS_HOST/PORT`) — เป็น message broker เท่านั้น
- Database เป็น **Postgres** (ไม่แนะนำ SQLite กับ queue mode)
- `N8N_ENCRYPTION_KEY` ต้อง**เหมือนกันทุก instance** (main+worker) ไม่งั้น worker เข้า credential ไม่ได้

## Binary data ข้อจำกัด
Queue mode **ไม่รองรับ** binary data mode = filesystem — ต้องใช้ S3 external storage หรือ mode = database แทน ([[Binary Data]])

## Webhook processor (scale เพิ่ม)
แยก process รับ webhook ออกจาก main อีกชั้น — route `/webhook/*` และ `/webhook-waiting/*` ไปที่ webhook processor pool ผ่าน load balancer, path อื่นไปที่ main. ไม่แนะนำเอา main เข้า load balancer pool (จะทำ UI ช้า)

## Gotcha
- [[Sub-workflow (Execute Workflow)|Sub-workflow]]/Workflow Tool รันบน worker เดียวกับ parent เสมอ ไม่กระจายผ่าน Redis — ถ้าต้องการ distributed ใช้ [[Node - Webhook]] แทน
- Redis latency สูง = job ค้างคิวนาน, worker หยิบงานช้า — ย้าย Redis ให้ใกล้ worker
- Worker memory ต่ำ = GC ถี่ = execution ล้มเหลวแบบสุ่มภายใต้โหลดสูง

## Related
- [[Execution]]
- [[Sub-workflow (Execute Workflow)]]
- [[Deploy - Queue Mode with Redis]]
- [[Deploy - Scaling Workers]]

## Official Docs
- https://docs.n8n.io/deploy/host-n8n/configure-n8n/scaling/enable-queue-mode
- https://docs.n8n.io/deploy/host-n8n/configure-n8n/basic-configuration/use-environment-variables/queue-mode
