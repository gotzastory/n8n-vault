---
tags: [n8n/troubleshoot]
type: troubleshoot
aliases: []
---

# Troubleshoot - Credential Auth Failed

## Google (Gmail / Sheets / Drive)
### `401 unauthorized_client`
```
401 - {"error":"unauthorized_client","error_description":"Client is unauthorized to retrieve access tokens using this method, or client not authorized for any of the scopes requested."}
```
| Credential type | แก้ |
|---|---|
| **OAuth2** | ยังไม่ enable API ที่ใช้ใน **APIs & Services > Library** (เช่น Gmail API) |
| **Service Account** | 1. เปิด **domain-wide delegation** 2. เพิ่ม API นั้นเข้าไปใน config domain-wide delegation ด้วย |

### `Forbidden - perhaps check your credentials?` ตรง dropdown
ใช้ Service Account แต่ไม่ได้เปิด **Impersonate a User**

### `Bad request - please check your parameters`
ID (Message/Thread/Label/Sheet) ไม่มีจริง → ลอง **Get** operation ยืนยันก่อน

## Notion
### `404 object_not_found: Could not find page with ID`
1. **สับสน Database ID กับ Database Page ID** — Database ID = ทั้งฐานข้อมูล, Database Page ID = 1 หน้า/1 แถว
2. **ยังไม่ได้ share integration เข้ากับ database/page นั้น** ใน Notion (Connections → เพิ่ม integration)
3. n8n 2.31+ (Notion node v3): **database-page query/create ใช้ Database ID ไม่ได้แล้ว ต้องเลือก Data Source**

## Slack
| อาการ | สาเหตุ |
|---|---|
| Slack Trigger ใช้ไม่ได้ | **OAuth2 ใช้กับ Trigger ไม่ได้** — ต้องใช้ API access token (Bot User OAuth Token) |
| operation บางตัว fail | **scope ไม่พอ** — ดูตาราง resource→API method ใน docs แล้วเพิ่ม scope ใน Slack app |
| Approval button กดแล้ว workflow ไม่เดินต่อ | ไม่ได้ใส่ **Signature Secret** ใน credential |
| output ไม่มี email ของผู้อนุมัติ | ขาด scope `users:read.email` — credential OAuth2 เก่าต้อง **reconnect** เพื่อรับ scope ใหม่ |

## OAuth2 ทั่วไป
- **Redirect URL ไม่ตรงเป๊ะ**: copy **OAuth Redirect URL** จาก n8n ไปวางในฝั่ง service — ต้องเหมือนกันทุกตัวอักษร
- **self-host ต้องสร้าง OAuth app เอง** (Cloud บาง service กด Connect ได้เลย)
- n8n **จัดการ token refresh ให้เอง** — ไม่ต้องยิงขอ token ก่อนด้วย [[Node - HTTP Request]]. บาง service (เช่น Zoho) refresh ไม่สำเร็จ ต้อง handle เอง

## Self-host: credential หายหลัง restart
**ไม่ได้ mount volume `/home/node/.n8n`** → encryption key หายทุกครั้งที่ restart
```yaml
volumes:
  - n8n_data:/home/node/.n8n
```

## Queue mode: worker เข้า credential ไม่ได้
`N8N_ENCRYPTION_KEY` **ต้องเหมือนกันทุก instance** (main + worker + webhook)

## HTTP Request node
- **Allowed HTTP Request Domains** ของ credential อาจบล็อกอยู่ (ตั้งเป็น None หรือ domain ที่ไม่ตรง)
- ใช้ **Predefined Credential Type** ได้เลยถ้า n8n รองรับ service นั้น — ไม่ต้อง config generic เอง

## Postgres/database
- SQL ใช้ **single quote** — `'value'` ไม่ใช่ `"value"` (double quote = identifier → `column "x" does not exist`)

## Related
- [[Credential]]
- [[OAuth2 in n8n]]
- [[Best Practice - Credential Management]]
- [[Node - Gmail]], [[Node - Notion]], [[Node - Slack]]
