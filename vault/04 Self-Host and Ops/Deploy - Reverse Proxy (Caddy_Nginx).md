---
tags: [n8n/deploy]
type: deploy
aliases: []
---

# Deploy - Reverse Proxy (Caddy/Nginx)

## ทำไมต้องมี
n8n รันบน port 5678 (http) — reverse proxy ทำ TLS termination + expose 443 ให้ internet. **ไม่มี HTTPS = trigger node ส่วนใหญ่ใช้ไม่ได้** (Telegram/Meta/WhatsApp บังคับ HTTPS)

## ⚠️ 3 อย่างที่ต้องทำเสมอ
n8n สร้าง webhook URL จาก `N8N_PROTOCOL` + `N8N_HOST` + `N8N_PORT` ซึ่ง**ผิด**เมื่ออยู่หลัง proxy (internal 5678 vs external 443):

1. **ตั้ง webhook URL เอง**:
   ```
   N8N_WEBHOOK_URL=https://n8n.example.com/
   N8N_EDITOR_BASE_URL=https://n8n.example.com/
   ```
   > `N8N_WEBHOOK_URL` มาแทน `WEBHOOK_URL` ที่ deprecated แล้ว (n8n log warning ถ้ายังใช้ตัวเก่า)

2. **`N8N_PROXY_HOPS=1`** (จำนวน proxy ที่คั่นอยู่)

3. **ส่ง header เหล่านี้จาก proxy ชั้นสุดท้าย**: `X-Forwarded-For`, `X-Forwarded-Host`, `X-Forwarded-Proto`

**`N8N_PORT` ต้องเป็น port ภายใน (5678) ไม่ใช่ 443** — proxy จัดการ 443 เอง

## Nginx
```nginx
map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}

server {
    listen 443 ssl;
    server_name n8n.example.com;
    # ssl_certificate / ssl_certificate_key ...

    client_max_body_size 50m;

    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;

        # WebSocket — จำเป็นสำหรับ editor UI ไม่งั้นขึ้น "Connection lost"
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;

        # ปิด buffering/cache สำหรับ streaming/WS
        chunked_transfer_encoding off;
        proxy_buffering off;
        proxy_cache off;

        proxy_read_timeout 600;
        proxy_send_timeout 600;
    }
}
```

## Caddy (ง่ายสุด — จัดการ cert อัตโนมัติ)
```
n8n.example.com {
    reverse_proxy n8n:5678
}
```
`n8n` = ชื่อ service ใน docker-compose

## SSL 2 ทาง
1. **Reverse proxy** (แนะนำ) — Caddy/Traefik/NLB จัดการ cert + renew ให้
2. **ส่ง cert เข้า n8n ตรงๆ**: `N8N_SSL_CERT` + `N8N_SSL_KEY` — ต้อง renew เอง

## เปิดเฉพาะ chat endpoint สู่ public (ซ่อน UI)
```
handle /webhook/chat/*      { reverse_proxy n8n:5678 }
handle /webhook-test/chat/* { reverse_proxy n8n:5678 }
handle                      { respond 403 }
```
ต้องรองรับ WebSocket upgrade ไม่งั้น chat หลุด/403

## อาการที่เจอบ่อย
| อาการ | สาเหตุ |
|---|---|
| **"Connection lost" ใน editor** | proxy ไม่ส่ง WebSocket upgrade header / เปิด buffering |
| Webhook URL เป็น `http://localhost:5678/...` | ไม่ได้ตั้ง `N8N_WEBHOOK_URL` (หรือตั้งแล้วไม่ restart) |
| Trigger บอก "An HTTPS URL must be provided" | เหมือนข้างบน — ตั้งแล้วต้อง restart n8n |
| IP whitelist ใน [[Node - Webhook]] ไม่ทำงาน | ไม่ได้ตั้ง `N8N_PROXY_HOPS` |

## Related
- [[Deploy - Docker Compose]]
- [[Node - Webhook]]
- [[Environment Variables]]
- [[Troubleshoot - Webhook Not Triggering]]
