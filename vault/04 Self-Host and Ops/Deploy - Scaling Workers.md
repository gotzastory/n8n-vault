---
tags: [n8n/deploy]
type: deploy
aliases: []
---

# Deploy - Scaling Workers

## Performance baseline
n8n รองรับได้ถึง **~220 workflow execution/วินาที ต่อ 1 instance** (ตัวเลขทางการ) — เกินกว่านั้นต้อง scale out

ปัจจัยที่มีผล: ชนิดของ workflow, resource ที่ให้, การตั้ง scaling option, ชนิด disk (SSD), DB connection pool

## Concurrency
### Regular mode
default **ไม่จำกัด** production execution พร้อมกัน → เยอะเกินทำ event loop ตัน
```
N8N_CONCURRENCY_PRODUCTION_LIMIT=20
```
- ใช้กับ **production execution เท่านั้น** (จาก webhook/trigger) — ไม่รวม manual, sub-workflow, error execution, CLI
- เกิน limit เข้าคิว FIFO
- **retry execution ที่อยู่ในคิวไม่ได้**; cancel/delete = ออกจากคิว
- restart แล้ว n8n resume คิวขึ้นมาเท่า limit ที่เหลือ re-enqueue

### Queue mode
```
command: worker --concurrency=5
```
default `10`. `N8N_CONCURRENCY_PRODUCTION_LIMIT` คุมทั้งสองโหมด (ถ้าตั้งค่าอื่นนอกจาก `-1` จะ override `--concurrency`)

**n8n แนะนำ concurrency ≥ 5 ต่อ worker** — ตั้งต่ำแต่ worker เยอะจะ**ทำ DB connection pool หมด** → ช้า/พัง

## สูตรคำนวณ
```
max parallel execution = จำนวน worker × concurrency ต่อ worker
```
เช่น 10 worker × concurrency 6 = 60 execution พร้อมกัน, ที่เหลือรอคิว

## Sizing แนะนำ
| ระดับ | CPU | RAM | Storage |
|---|---|---|---|
| ทดสอบ/โหลดต่ำ | 1 vCPU | 2-4 GB | 1-4 GB SSD |
| production เล็ก | 2 vCPU | 4-8 GB | 20-40 GB SSD |
| production กลาง | 4 vCPU | 8-16 GB | 40-80 GB SSD |
| production ใหญ่ | 8+ vCPU | 16+ GB | 80+ GB SSD + แยก main/worker/webhook |

## Best practice (production ใหญ่)
- **ปิด webhook บน main** แล้วใช้ webhook instance แยก (จำนวนตาม load)
- **auto-scale worker ตามความยาวคิว Redis** — คิวยาวเกิน threshold → เพิ่ม worker (ตั้ง max ไว้ด้วย กัน spawn 100 ตัวตอนระบบมีปัญหา)
- **worker เล็กหลายตัว** ดีกว่า worker ใหญ่ตัวเดียว (แต่ concurrency ≥ 5)
- ตั้ง **workflow timeout** กัน workflow ยาวบล็อกคิว
- monitor: **queue depth**, worker CPU/memory, execution duration, **Redis latency**
- จัดการ execution data (prune) ไม่งั้น DB บวม
- มี backup ที่ทดสอบกู้ได้จริง

## ปัญหาที่เจอตอน scale
| ปัญหา | แก้ |
|---|---|
| คิวโตเร็วกว่าประมวลผล | เพิ่ม worker |
| worker CPU/memory เต็ม | เพิ่ม resource หรือเพิ่ม worker |
| workflow ยาวบล็อกคิว | ตั้ง timeout |
| **binary data ทำ memory ระเบิด** | เพิ่ม RAM + disk เร็ว + **S3 external storage** + worker หลายตัว |
| execution ล้มสุ่มตอนโหลดสูง | memory ต่ำ → GC ถี่ |

## Distributed state (multi-worker)
**อย่าพึ่ง in-memory state** — execution ย้าย worker ได้ตลอด
- เก็บ state กลางที่ Redis/Postgres (`job_id`, `status`, `current_step`)
- ใช้ DB lock / unique constraint กัน duplicate ตอน retry
- ใช้ queue สำหรับงานที่ต้องเรียงลำดับ
- แตก workflow ยาวเป็น stage สั้นๆ event-driven แทน execution ก้อนเดียว
- ทำ action สำคัญให้ **idempotent** ([[Best Practice - Idempotent Workflows]])

## Key takeaway จาก benchmark ทางการ
1. **Queue mode ไม่ใช่ตัวเลือก** — เป็นก้าวแรกของ scalability จริง, ช่วยแม้บน hardware เล็ก
2. **Hardware มีผลมาก** — เครื่องแรงขึ้นเท่าตัว throughput เกินเท่าตัว, latency ครึ่งเดียว, failure rate เหลือ 0
3. **Binary data ทำพังทุกอย่าง** ถ้าไม่เตรียม — ต้อง RAM มาก, disk เร็ว, shared storage (S3), worker parallel

Benchmark เอง: [n8n benchmark framework](https://github.com/n8n-io/n8n/tree/master/packages/%40n8n/benchmark)

## Related
- [[Queue Mode]]
- [[Deploy - Queue Mode with Redis]]
- [[Binary Data]]
- [[Troubleshoot - Memory Issues on Self-Hosted]]
