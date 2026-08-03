---
tags: [n8n/deploy]
type: deploy
aliases: []
---

# Deploy - Docker Compose

## ข้อควรรู้ก่อน
Self-host ต้องมีความรู้: ตั้ง/config server+container, จัดการ resource+scaling, security, config n8n. n8n แนะนำสำหรับ expert user — พลาดแล้วเสี่ยง data loss / security / downtime

**v3.0 (ต.ค. 2026)**: self-host **บังคับใช้ Docker** — `npm` / `npx n8n` จะไม่รองรับแล้ว

## ขั้นตอนหลัก
1. ติดตั้ง Docker Engine + Docker Compose
2. **DNS**: สร้าง A record ของ subdomain (เช่น `n8n`) ชี้ไป IP server
3. เปิด port 80 + 443 บน firewall
4. สร้าง `.env` เก็บ config
5. สร้างโฟลเดอร์ `local-files` สำหรับแชร์ไฟล์ระหว่าง container กับ host (ใช้กับ Read/Write Files from Disk node) — สร้างเองด้วยมือเพื่อให้ ownership/permission ถูก
6. `docker compose up -d`

Config สำเร็จรูปหลายสถาปัตยกรรม: [n8n-hosting repo](https://github.com/n8n-io/n8n-hosting)

## Volume ที่ต้อง mount (สำคัญมาก)
```yaml
volumes:
  - n8n_data:/home/node/.n8n     # ← ไม่ mount = credential หายทุกครั้งที่ restart
  - ./local-files:/files
```
แม้ใช้ Postgres แล้วก็**ยังต้อง mount `.n8n`** เพราะเก็บ encryption key, instance log, source control asset

## โครงพื้นฐาน (n8n + Postgres)
```yaml
services:
  postgres:
    image: postgres:16
    environment:
      - POSTGRES_USER / POSTGRES_PASSWORD / POSTGRES_DB
    volumes:
      - db_storage:/var/lib/postgresql/data
    healthcheck:
      test: ['CMD-SHELL', 'pg_isready -h localhost -U ${POSTGRES_USER} -d ${POSTGRES_DB}']

  n8n:
    image: docker.n8n.io/n8nio/n8n
    restart: always
    ports: ["5678:5678"]
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE / USER / PASSWORD
      - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
      - N8N_HOST=n8n.example.com
      - N8N_PROTOCOL=https
      - N8N_WEBHOOK_URL=https://n8n.example.com/
      - N8N_EDITOR_BASE_URL=https://n8n.example.com/
      - GENERIC_TIMEZONE=Asia/Bangkok
      - TZ=Asia/Bangkok
    volumes:
      - n8n_data:/home/node/.n8n
    depends_on:
      postgres: { condition: service_healthy }
```

## Env ที่ควรใส่เพิ่มใน production
```
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
N8N_DEFAULT_BINARY_DATA_MODE=filesystem
EXECUTIONS_DATA_PRUNE=true
EXECUTIONS_DATA_MAX_AGE=336
N8N_PROXY_HOPS=1                      # ถ้าอยู่หลัง reverse proxy
NODES_EXCLUDE=["n8n-nodes-base.executeCommand","n8n-nodes-base.ssh"]
N8N_DIAGNOSTICS_ENABLED=false
```

## Healthcheck
```yaml
healthcheck:
  test: ["CMD","wget","--spider","-q","http://localhost:5678/healthz"]
  interval: 30s
```

## Version
n8n ออก minor version เกือบทุกสัปดาห์. tag `stable` = production, `beta` = ล่าสุดแต่อาจไม่นิ่ง. **pin version ไว้** อย่าใช้ `latest` บน production

## Related
- [[Deploy - Reverse Proxy (Caddy_Nginx)]]
- [[Deploy - Queue Mode with Redis]]
- [[Deploy - Environment Variables Reference]]
- [[Environment Variables]]
