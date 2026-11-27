---
tags: [n8n/deploy]
type: deploy
aliases: []
---

# Deploy - Backup & Version Control of Workflows

## Source control (Git) — feature availability
- **Business / Enterprise plan เท่านั้น**
- ต้องเป็น instance owner/admin ถึงจะเปิดและ config ได้
- owner/admin: push + pull ได้ / **project admin: push ได้ แต่ pull ไม่ได้**

## Setup
1. สร้าง Git repo + branch ตามจำนวน environment
2. **Settings → Environments** → ใส่ Git repository URL
   - **SSH**: n8n รองรับ ED25519 (default) และ RSA → copy SSH key ไปสร้าง **deploy key** (ต้องให้ **write access**)
   - **HTTPS**: username + **Personal Access Token** (สิทธิ์: repo read/write, contents read/write สำหรับ GitHub)
3. เลือก branch ของ instance นี้
4. เปิด **Protected instance** บน production เพื่อกันคนแก้ resource ที่ source-controlled
5. ตั้งสีของ instance ให้แยกออกว่ากำลังอยู่ตัวไหน

## Branch pattern
| Pattern | ข้อดี | ข้อเสีย |
|---|---|---|
| **หลาย instance หลาย branch** | ต้องทำ PR ถึงจะขึ้น production = ปลอดภัยกว่า, รองรับเกิน 2 environment | ขั้นตอน copy งานเยอะกว่า |
| **หลาย instance branch เดียว** | push แล้ว environment อื่นเห็นทันที, ดีเวลาทดสอบ n8n version ใหม่ | push ผิดหลุดขึ้น production ได้ง่าย |

**คำแนะนำ: อย่า push และ pull ที่ instance เดียวกัน** — ให้งานไหลทางเดียว (dev → Git → production) ลดความเสี่ยง merge conflict + งานหาย

## Push / Pull / Commit
- **Push** = commit + push พร้อมกัน (เลือกได้ว่า workflow/data table ไหนบ้าง, filter ตาม new/modified/deleted). n8n push tag + credential/variable stub ให้อัตโนมัติ
- **Pull** = ดึงจาก Git มาลง instance — **ทับงาน local ที่ยังไม่ได้ push**
- n8n push **เวอร์ชันที่ save ล่าสุด ไม่ใช่เวอร์ชันที่ publish** → ต้องไป publish ที่ instance ปลายทางอีกที

## ⚠️ อะไร sync / ไม่ sync
| | Sync? |
|---|---|
| Workflow, tag | ✅ |
| **Credential value** | ❌ **ไม่ sync** — sync แค่ stub ต้องกรอกเองที่ instance ใหม่ |
| **Variable value** | ❌ sync แค่ stub |
| Data table **schema** | ✅ (n8n 2.x) |
| Data table **row data** | ❌ |

ต้องใช้ credential ต่างกันแต่ละ environment → ใช้ [[Credential|external secrets vault]]

## Merge behavior
- **Workflow**: n8n **ตรวจ conflict ไม่ได้** — Git เป็น source of truth. pull ทับ local, push ทับ Git → push ทันทีที่ทำงานเสร็จ แล้วค่อย pull
- **Credential/variable/tag**: n8n เลือกให้เอง ไม่มี conflict
  - pull: ไม่มี → สร้าง; มีแล้ว → ไม่อัปเดต ยกเว้นชื่อ credential เปลี่ยน (ใช้ของ Git) หรือชื่อ tag เปลี่ยน
- **Data table**: pull แล้ว column ที่ไม่มีใน Git **จะถูกลบพร้อมข้อมูล กู้ไม่ได้**. table ที่มีแค่ local จะโดนลบทั้งตาราง (interactive pull เตือนก่อน, force pull ผ่าน API ลบเลย)

## Workflow diff (Enterprise)
เทียบ workflow local vs Git แบบเห็นภาพก่อน push/pull — node เขียว = เพิ่ม (N), ส้ม = แก้ (M), แดง = ลบ (D). คลิก node ที่แก้เพื่อดู JSON diff

## Automate pull
เรียก API `/source-control/pull` หลัง merge → ทำ GitHub Action / GitLab CI ให้ production pull อัตโนมัติได้

## ทางเลือกอื่น (ไม่มี Business/Enterprise)
- Export/Import ผ่าน CLI: `n8n export:workflow` / `n8n import:workflow`
- Public API ดึง workflow JSON แล้ว commit เข้า Git เอง
- Export from File / copy-paste JSON ใน editor
- **Backup database + `.n8n` folder** (มี encryption key) — สำคัญที่สุด อย่าลืม

## Related
- [[Best Practice - Version Control with git]]
- [[Credential]]
- [[Deploy - Docker Compose]]
