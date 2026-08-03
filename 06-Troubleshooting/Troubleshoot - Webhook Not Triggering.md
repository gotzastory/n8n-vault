---
tags: [n8n/troubleshoot]
type: troubleshoot
aliases: []
---

# Troubleshoot - Webhook Not Triggering

## Symptom
ยิง request ไปที่ webhook URL แล้วไม่มีอะไรเกิดขึ้น — ไม่มี execution, ไม่มี error, เงียบสนิท

## ไล่เช็คตามลำดับ (เรียงจากที่เจอบ่อยสุด)

### 1. Test URL vs Production URL ⭐ สาเหตุอันดับ 1
| URL | ทำงานเมื่อ | ฟังนานแค่ไหน |
|---|---|---|
| `/webhook-test/...` | กด **Listen for test event** เท่านั้น | **120 วินาที** |
| `/webhook/...` | **publish workflow แล้ว** | จนกว่าจะ unpublish |

- ใช้ test URL แต่ไม่ได้กด listen → เงียบ
- ใช้ production URL แต่ workflow ยัง**ไม่ได้ publish** → เงียบ
- **save ≠ publish** — ต้องกด Publish

### 2. HTTP Method ไม่ตรง
service ส่ง POST แต่ node ตั้ง GET → ไม่ trigger. เช็ค API doc ของ service ต้นทาง
> ต้องรับหลาย method: Settings → **Allow Multiple HTTP Methods**

### 3. Self-host: webhook URL ผิด
n8n สร้าง URL จาก `N8N_PROTOCOL` + `N8N_HOST` + `N8N_PORT` → **หลัง reverse proxy จะได้ URL ผิด**
```
N8N_WEBHOOK_URL=https://n8n.example.com/     # ไม่มี port, ปิดท้ายด้วย /
N8N_HOST=n8n.example.com
N8N_PROTOCOL=https
N8N_PROXY_HOPS=1
```
**แก้แล้วต้อง restart n8n** ถึงจะ regenerate URL ใหม่

อาการที่บ่งชี้: webhook URL ที่โชว์ใน node เป็น `http://localhost:5678/...` หรือ `https://domain:5678/...` (มี port)

> service ภายนอกหลายเจ้า (Shopify, Telegram, Meta) **ไม่ยอมรับ URL ที่มี port** และ**บังคับ HTTPS**

### 4. Reverse proxy / firewall
- proxy forward request ถูกทางไหม
- ส่ง `X-Forwarded-Proto` / `X-Forwarded-Host` ครบไหม
- port ขาเข้าเปิดไหม
- **Cloudflare proxy (orange cloud)** อาจบล็อก — ทดสอบด้วย [webhook.site](https://webhook.site) เทียบว่า service ต้นทางยิงออกได้จริง

### 5. Path มีปัญหา
เปลี่ยน method/path แล้วลืมอัปเดตฝั่ง service — หรือใส่คำใน path ที่ชนกับ route ของ n8n

### 6. "Received request for unknown webhook ... is not registered"
webhook หลุด registration (มักหลัง restart server ทั้งที่ workflow publish อยู่)
→ **unpublish แล้ว publish ใหม่** (bug ที่มีรายงานเป็นระยะ)

### 7. Node version เก่า
n8n node มี version — Webhook node version เก่า (เช่น 2 แทน 2.1) ทำให้ไม่ทำงาน. เจอบ่อยกับ workflow ที่ AI/MCP generate มา → เช็ค version ที่ท้าย Settings pane แล้วอัปเดต node

### 8. `N8N_HOST=0.0.0.0`
`0.0.0.0` = listen ทุก interface (ดีสำหรับ Docker) แต่ n8n เอาไปสร้าง URL ด้วย → ควรตั้งเป็น hostname/domain จริง

## Trigger ทำงานแต่ node ถัดไปไม่ทำงาน
**"Listen for test event" รันแค่ Webhook node ตัวเดียว** ไม่ใช่ทั้ง workflow → กด **Execute workflow** แทน

## IP whitelist ไม่ทำงาน
ตั้ง `N8N_PROXY_HOPS` = จำนวน reverse proxy ที่คั่นอยู่

## วิธี test
```bash
curl -X POST https://your-n8n.url/webhook/path \
  -H "Content-Type: application/json" \
  -d '{"test": 1}'
```
หรือใช้ [[Node - HTTP Request]] ใน workflow อีกตัวยิงเข้ามา

## Related
- [[Node - Webhook]]
- [[Deploy - Reverse Proxy (Caddy_Nginx)]]
- [[Environment Variables]]
