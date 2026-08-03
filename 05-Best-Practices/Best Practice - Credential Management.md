---
tags: [n8n/best-practice]
type: best-practice
aliases: []
---

# Best Practice - Credential Management

## หลักพื้นฐาน
1. **เก็บ API key ใน Credential เสมอ** ไม่ใช่ hardcode ใน node parameter หรือ [[Node - Set (Edit Fields)]] — n8n เข้ารหัสให้ และ**ไม่ปรากฏใน workflow JSON** ตอน export
2. **ตั้งชื่อสื่อความหมาย**: app + type + purpose เช่น `Gmail OAuth2 - Support Inbox` แทน default "Gmail account"
3. **จำกัด domain**: field **Allowed HTTP Request Domains** คุมว่า credential ใช้กับ URL ไหนได้เมื่อเลือกใน [[Node - HTTP Request]] — ตั้ง Specific Domains แทน All กัน credential รั่วไปยิง URL อื่น

## Central vs Individual credential (องค์กร)
**Hybrid approach** ที่ใช้กันจริง:
| ประเภท | ใช้กับ |
|---|---|
| **Central service account** | งานที่ทำในนามบริษัท — โพสต์ Slack channel กลาง, อัปเดต Google Calendar ส่วนกลาง |
| **Individual credential** | งานที่ต้องใช้ context ส่วนตัว — อ่านเมลตัวเอง, task ส่วนตัว |

Best practice:
- **Least privilege** — service account ให้สิทธิ์เท่าที่จำเป็น
- **Audit logging** — log การใช้ credential
- **Rotation policy** — หมุน token เป็นรอบ
- **Break-glass procedure** — มีขั้นตอนกู้คืนฉุกเฉิน

## ทำงานให้ลูกค้า (agency/freelance)
**ใช้ credential ของลูกค้าเสมอ ตั้งแต่ตอน dev** ไม่ใช่ของตัวเอง:
- ตอนส่งมอบ/โอน instance ไม่ต้องมานั่งรื้อ
- ไม่มีปัญหา data leakage ข้ามลูกค้า
- compliance ชัดเจน

> บทเรียนจริงจากชุมชน: ใช้ key ตัวเองตอน test แล้วตอน handover กลายเป็นเรื่องยุ่งมาก

## Feature ตามระดับ plan
| Feature | Plan |
|---|---|
| Credential sharing (user/project) | Cloud ทุก plan, self-host Business/Enterprise |
| **End-user credential** (แต่ละคนใช้ account ตัวเอง, OAuth เท่านั้น) | Enterprise (preview) |
| **External secrets** (1Password, AWS/Azure/GCP Secrets Manager, HashiCorp Vault, Infisical) | Enterprise |
| **Credential overwrites** (ตั้ง client ID/secret กลาง ซ่อนจาก user) | self-host |
| **Encryption key rotation** | self-host |

คนที่ถูกแชร์ credential **ใช้ได้แต่ดู/แก้ค่าไม่ได้**

## Self-host security
```
N8N_ENCRYPTION_KEY=<กำหนดเอง>      # ← ต้องเหมือนกันทุก instance ใน queue mode
```
- ไม่ตั้งเอง = n8n สุ่มให้ตอน start ครั้งแรก เก็บที่ `~/.n8n/config` → **backup โฟลเดอร์นี้เสมอ ไม่งั้นกู้ credential ไม่ได้**
- **Credential overwrites**: ใช้ REST endpoint (`CREDENTIALS_OVERWRITE_ENDPOINT` + auth token) ดีกว่า `CREDENTIALS_OVERWRITE_DATA` เพราะ env var ไม่ถูกป้องกัน ข้อมูลรั่วถึง user ได้
- `N8N_ENV_FEAT_ENCRYPTION_KEY_ROTATION` — **one-way migration** ต้อง full DB backup ก่อน, ปิดกลับหรือ downgrade version = data ที่เข้ารหัสใหม่อ่านไม่ได้ถาวร

## Environment ต่างกัน
credential **ไม่ sync ผ่าน Git source control** (sync แค่ stub) → environment ใหม่ต้องกรอกเอง. ถ้าต้องการ credential ต่างกันต่อ environment ให้ใช้ **external secrets vault** (scope per project ได้)

## Related
- [[Credential]]
- [[OAuth2 in n8n]]
- [[Deploy - Backup & Version Control of Workflows]]
- [[Environment Variables]]
