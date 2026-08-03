---
tags: [n8n/deploy]
type: deploy
aliases: []
---

# Deploy - Queue Mode with Redis

> Concept เต็มอยู่ที่ [[Queue Mode]] — note นี้เน้นขั้นตอน deploy

## Component ที่ต้องมี
| Component | หน้าที่ | resource ที่ต้องเน้น |
|---|---|---|
| **Postgres** | เก็บ workflow/execution | storage (SSD) |
| **Redis** | message broker คิว execution | memory + **latency ต่ำ** |
| **main** | รับ trigger/webhook, สร้าง execution | memory น้อยได้ |
| **worker** (n ตัว) | รัน workflow จริง | **CPU + memory มากสุด** |
| **webhook processor** (optional) | รับ webhook แยกจาก main | น้อยสุด |

## Env ที่ต้องตั้ง
### ทุก instance (main + worker + webhook)
```
EXECUTIONS_MODE=queue
N8N_ENCRYPTION_KEY=<ค่าเดียวกันทุกตัว>   # ← ไม่ตรง = worker อ่าน credential ไม่ได้
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST / PORT / DATABASE / USER / PASSWORD
QUEUE_BULL_REDIS_HOST=redis
QUEUE_BULL_REDIS_PORT=6379
```
optional: `QUEUE_BULL_REDIS_USERNAME/PASSWORD/DB/TLS`, `QUEUE_BULL_REDIS_TIMEOUT_THRESHOLD` (default 10000ms), `N8N_GRACEFUL_SHUTDOWN_TIMEOUT` (default 30s), `QUEUE_HEALTH_CHECK_ACTIVE=true`

### เพิ่มเติม
- `OFFLOAD_MANUAL_EXECUTIONS_TO_WORKERS=true` — ให้ manual execution รันบน worker ด้วย
- `N8N_MULTI_MAIN_SETUP_ENABLED=true` — multi-main (ต้องมี license)

## รัน worker / webhook
```bash
# Docker
docker run ... n8nio/n8n worker
docker run ... n8nio/n8n webhook

# compose
command: worker
command: worker --concurrency=5
```

Worker เปิด endpoint: `/healthz`, `/healthz/readiness` (ต้องเปิด `QUEUE_HEALTH_CHECK_ACTIVE`), `/metrics`, credential overwrite endpoint

## ⚠️ ข้อจำกัดสำคัญ
- **Postgres เท่านั้น** — SQLite + queue mode ไม่รองรับ
- **filesystem binary data mode ใช้ไม่ได้** → ต้อง `database` หรือ S3/Azure external storage ([[Binary Data]])
- **Cloud ยังไม่เปิด queue mode** — self-host เท่านั้น

## Webhook processor + load balancer
route ผ่าน load balancer:
- `/webhook/*` → webhook pool
- `/webhook-waiting/*` → webhook pool (human-in-the-loop send-and-wait)
- `/webhook-test/*` และ path อื่นทั้งหมด → **main**

**อย่าเอา main เข้า load balancer pool** — โดน load หนักแล้ว UI ช้า
ปิด webhook บน main ได้ด้วย `endpoints.disableProductionWebhooksOnMainProcess=true`

## Troubleshooting
| อาการ | สาเหตุ |
|---|---|
| job ค้างคิว ไม่มี worker หยิบ | ไม่ได้สร้าง worker container จริง (ตั้งแค่ env บน main) |
| execution ล้มเหลวสุ่มๆ ตอนโหลดสูง | worker memory ต่ำ → GC ถี่ → เพิ่ม memory/worker |
| หน่วงเวลาระหว่าง trigger กับ worker หยิบงาน | Redis latency → ย้าย Redis ให้ใกล้ worker + monitor latency ไม่ใช่แค่ CPU |
| worker เข้า credential ไม่ได้ | `N8N_ENCRYPTION_KEY` ไม่ตรงกัน |

## Related
- [[Queue Mode]]
- [[Deploy - Scaling Workers]]
- [[Deploy - Docker Compose]]
- [[Binary Data]]
