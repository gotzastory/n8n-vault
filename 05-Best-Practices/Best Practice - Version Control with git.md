---
tags: [n8n/best-practice]
type: best-practice
aliases: []
---

# Best Practice - Version Control with git

> Setup + merge behavior ละเอียดอยู่ที่ [[Deploy - Backup & Version Control of Workflows]]

## กฎเหล็ก
### 1. งานไหลทางเดียว
```
dev instance → push → Git → pull → production instance
```
**อย่า push และ pull ที่ instance เดียวกัน** — n8n เตือนเองในเอกสาร เพราะเสี่ยง merge conflict และงานหาย

### 2. push ทันทีที่ทำเสร็จ
n8n **ตรวจ conflict ของ workflow ไม่ได้** — Git เป็น source of truth:
- pull ทับ local
- push ทับ Git

ทำเสร็จแล้ว push เลย จากนั้นค่อยปลอดภัยที่จะ pull

### 3. เลือก workflow ที่ push
อย่ากด push ทั้งหมดทุกครั้ง — เลือกเฉพาะที่ตั้งใจ (filter ตาม new/modified/deleted ได้)

### 4. อย่าแก้ไฟล์ใน Git repo ด้วยมือ
n8n จัดการ format เอง — แก้เองเสี่ยงพัง

### 5. ตั้ง production เป็น Protected instance
กันคนแก้ resource ที่ source-controlled บน production โดยตรง

## เลือก branch pattern
| ต้องการ | เลือก |
|---|---|
| ปลอดภัยสูงสุด, ต้องผ่าน PR ก่อนขึ้น production, มีเกิน 2 environment | **หลาย instance หลาย branch** |
| อยากให้ push แล้วเห็นทันที, ทดสอบ n8n version ใหม่ | **หลาย instance branch เดียว** |

**เตือน**: branch เดียว + auto-pull ด้วย GitHub Action = push ผิดหลุดขึ้น production ทันที → ถ้าจะ auto-pull ควรใช้ pattern หลาย branch

## ระวัง
- n8n push **เวอร์ชันที่ save ไม่ใช่เวอร์ชันที่ publish** → ต้อง publish ที่ปลายทางแยก
- **Credential/variable value ไม่ sync** — sync แค่ stub
- **Data table row data ไม่ sync** (schema sync)
- **pull ลบ column ที่ไม่มีใน Git พร้อมข้อมูล กู้ไม่ได้** — force pull ผ่าน API ลบโดยไม่ถาม
- เปลี่ยนชื่อ tag ระวัง — tag name unique อาจชนกันตอน pull

## ทางเลือกถ้าไม่มี Business/Enterprise
Git source control ใน n8n เป็น **Business/Enterprise เท่านั้น**. ทางอื่น:
- CLI: `n8n export:workflow --all --output=...` แล้ว commit เอง
- Public API ดึง workflow JSON → commit
- Import/Export from File ในหน้า editor
- **สำคัญสุด: backup database + โฟลเดอร์ `.n8n`** (มี encryption key อยู่ในนั้น)

## Workflow diff (Enterprise)
เทียบก่อน push/pull ได้ — เขียว=เพิ่ม(N), ส้ม=แก้(M), แดง=ลบ(D), คลิก node ดู JSON diff. ใช้ตรวจก่อนขึ้น production

## Versioning sub-workflow
sub-workflow ที่หลาย workflow ใช้ร่วมกัน → **version ก่อนแก้ breaking change** และเขียนเอกสารกำกับ (ดู [[Best Practice - Sub-workflows for Reuse]])

## Related
- [[Deploy - Backup & Version Control of Workflows]]
- [[Best Practice - Credential Management]]
- [[Best Practice - Sub-workflows for Reuse]]
