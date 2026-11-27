---
tags: [n8n/troubleshoot]
type: troubleshoot
aliases: []
---

# Troubleshoot - Workflow Stuck in Queue

## Symptom
Execution ขึ้น **pending / waiting** ค้างไม่รัน หรือ log ขึ้น "Enqueued execution..." แล้วเงียบ สุดท้าย "Execution cancelled" / "Stopped inactive job"

## 1. ⭐ ไม่มี worker container จริง (เจอบ่อยสุด)
ตั้ง `EXECUTIONS_MODE=queue` บน main แล้วคิดว่าจบ — **ต้องมี container แยกที่รันด้วย `command: worker`**
```yaml
n8n-worker:
  image: docker.n8n.io/n8nio/n8n
  command: worker
  environment:
    - EXECUTIONS_MODE=queue
    - QUEUE_BULL_REDIS_HOST=redis
    - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}   # เหมือน main
    - DB_TYPE=postgresdb
    - DB_POSTGRESDB_HOST/...                      # เหมือน main
```
> `N8N_WORKERS_COUNT` บน main **ไม่ได้สร้าง worker ให้** — ต้องสร้าง container/process เอง

## 2. Worker เข้า Redis หรือ DB ไม่ได้
- อยู่คนละ network ใน docker-compose
- `QUEUE_BULL_REDIS_HOST` ชี้ผิด (ต้องเป็นชื่อ service ไม่ใช่ localhost)
- Redis ไม่ขึ้น / ไม่มี healthcheck ทำให้ worker start ก่อน Redis พร้อม

เช็ค: `docker logs <worker>` ดูว่ามี connection error ไหม + เปิด `QUEUE_HEALTH_CHECK_ACTIVE=true` แล้วยิง `/healthz/readiness`

## 3. `N8N_ENCRYPTION_KEY` ไม่ตรงกัน
worker หยิบ job ได้แต่รันไม่ได้เพราะ decrypt credential ไม่ผ่าน

## 4. ใช้ SQLite
**queue mode ไม่รองรับ SQLite** — ต้อง Postgres

## 5. Worker เต็ม concurrency
```
max parallel = จำนวน worker × concurrency
```
- default concurrency = 10
- **ตั้ง concurrency ต่ำแต่ worker เยอะ = database connection pool หมด** → n8n แนะนำ concurrency ≥ 5
- workflow ที่รันนานบล็อกคิว → ตั้ง **Timeout Workflow** ใน workflow settings

## 6. Redis latency
job ค้างคิวนาน/worker หยิบช้า ทั้งที่ทุกอย่างขึ้นปกติ → **monitor Redis latency ไม่ใช่แค่ CPU**. ย้าย Redis ให้ใกล้ worker

## 7. Stalled job
`QUEUE_WORKER_STALLED_INTERVAL` (30000ms) + `QUEUE_WORKER_MAX_STALLED_COUNT` (1) — worker ตายกลางทางแล้ว job ถูก re-process
→ ทำ workflow ให้ **idempotent** ([[Best Practice - Idempotent Workflows]])

## 8. Regular mode (ไม่ใช่ queue) ก็มีคิว
`N8N_CONCURRENCY_PRODUCTION_LIMIT` ทำให้ production execution เกิน limit เข้าคิว FIFO
- **retry execution ที่อยู่ในคิวไม่ได้**
- cancel/delete = ออกจากคิว
- ใช้กับ production execution เท่านั้น (ไม่รวม manual/sub-workflow/error/CLI)
- ดูจำนวน active execution + limit ได้ที่ด้านบนของ Executions tab

## Diagnostic checklist
```bash
docker ps                        # worker container ขึ้นไหม
docker logs <worker> --tail 100  # error อะไร
docker logs <n8n-main> | grep -i enqueue
redis-cli LLEN bull:jobs:wait    # คิวยาวแค่ไหน
```

## Related
- [[Queue Mode]]
- [[Deploy - Queue Mode with Redis]]
- [[Deploy - Scaling Workers]]
- [[Troubleshoot - Memory Issues on Self-Hosted]]
