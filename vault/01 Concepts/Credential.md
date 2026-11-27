---
tags: [n8n/concept]
type: concept
aliases: []
---

# Credential

## Definition
Credential = ข้อมูล auth ที่เก็บใน n8n ให้ [[Node]] เรียกใช้เชื่อมต่อ service ภายนอก (API key, username/password, private key). เก็บลง database **แบบเข้ารหัส** ด้วย encryption key ที่ n8n สุ่มสร้างตอน start ครั้งแรก (เก็บที่ `~/.n8n/config`) — หรือกำหนดเองผ่าน `N8N_ENCRYPTION_KEY`

## สร้าง credential
สร้างผ่านปุ่ม Create → Credential, หรือสร้างจาก dropdown credential ตอน config node เลย. ตั้งชื่อให้สื่อความหมาย (default = "node name account") — แนะนำใส่ app + type + purpose เพื่อ track ง่าย. n8n **test credential ให้อัตโนมัติ**ตอน save

## Credential type
- **Fixed credential** (default) — ทุกคนที่รัน workflow ใช้ credential เดียวกัน
- **End-user credential** (Enterprise, OAuth เท่านั้น) — แต่ละ user ต่อ account ตัวเองที่ runtime, เห็น/ใช้ได้เฉพาะเจ้าของ — เหมาะกับ workflow ที่ต้องแยกข้อมูลส่วนตัวต่อ user (เช่น อ่าน Gmail inbox ของแต่ละคน)

## Allowed HTTP Request Domains
Credential ส่วนใหญ่มี field นี้ — คุมว่า credential ใช้กับ URL ไหนได้บ้างเมื่อเลือกใน [[Node - HTTP Request]] (ไม่มีผลถ้าใช้ผ่าน node เฉพาะทางของตัวเอง): All / Specific Domains (comma-separated) / None — กัน credential รั่วไปยิง URL นอกเป้าหมาย

## แชร์และจัดการ
- แชร์ credential ให้ user/project อื่นได้ (Cloud ทุก plan, self-host Business/Enterprise) — คนที่ถูกแชร์ **ใช้ได้แต่ดู/แก้รายละเอียดไม่ได้**
- Enterprise: **External secret stores** (1Password, AWS Secrets Manager, Azure Key Vault, GCP Secrets Manager, HashiCorp Vault, Infisical) — เก็บ secret จริงนอก n8n, resolve ตอนใช้เท่านั้น (ใช้ได้เฉพาะ field แบบ Credentials ไม่ใช่ field expression ทั่วไป)
- **Encryption key rotation** — self-host เท่านั้น, หมุน data-encryption key โดยไม่กระทบ instance key หลัก, เป็น one-way migration ต้อง backup DB ก่อนเปิดใช้

## Related
- [[OAuth2 in n8n]]
- [[Environment Variables]]
- [[Best Practice - Credential Management]]

## Official Docs
- https://docs.n8n.io/build/understand-workflows/create-and-edit-credentials
- https://docs.n8n.io/administer/manage-credentials/share-credentials-securely
- https://docs.n8n.io/administer/manage-credentials/use-external-secret-stores
