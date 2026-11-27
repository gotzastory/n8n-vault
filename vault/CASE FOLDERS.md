---
tags: [rules, worked-builds, case, type/hub]
---

# กติกา Case Folders ใน `08 Worked Builds`

เป้าหมาย: จุดเดียวที่ `08` · จัดตามเคสงาน · **agent ไม่หลง** เพราะ lookup หลักยังเป็น [[INDEX]]

> **สองชั้นแบบ LihFolk:** เปิด Cursor ที่ parent `n8n-vault/` (มี `AGENTS.md` + hooks) · เปิด Obsidian ที่โฟลเดอร์นี้ · **note เคส/workflow เขียนแค่** `08 Worked Builds/` ใต้คลังนี้เท่านั้น — ห้ามวางที่ parent

> ยังไม่ย้ายไฟล์เดิม — กติกานี้ใช้กับงานใหม่ก่อน จนกว่า Got จะอนุมัติ migrate

## สิ่งที่ agent ต้องจำ (สั้น)

1. **หา workflow = อ่าน [[INDEX]] ก่อนเสมอ** → ตาม path ในคอลัมน์ `note` → อ่าน TL;DR
2. โฟลเดอร์เคส = จัดกลุ่มให้คน/งานชุดเดียวกัน **ไม่ใช่** ทางเข้าหลักของ agent
3. ไม่ต้องเดาโฟลเดอร์จากชื่อ — path ใน INDEX คือคำตอบ
4. MCP = ของจริงใน n8n · note = ทำไม / ข้อห้าม / pending / related

## เมื่อไหร่สร้างโฟลเดอร์เคส

| สถานการณ์ | ทำอะไร |
|---|---|
| workflow เดี่ยว ยังไม่เกี่ยวชุดอื่น | วางแบนที่ราก `08 Worked Builds/Workflow - ….md` |
| มี **2+ workflow** ในเคสเดียวกัน หรือ Got ตั้งชื่อเคสชัด (เช่น chatbot คลินิก) | สร้างโฟลเดอร์เคส + `00 Case.md` |
| ไม่แน่ใจว่าเป็นเคสไหน | ถาม Got 1 ข้อ หรือวางแบนก่อน — **ห้ามเดาโฟลเดอร์ใหม่** |

## โครงมาตรฐาน

```
08 Worked Builds/
  <Case Name>/                 ← ชื่อเคส อ่านรู้เรื่อง ไม่ใส่เลข 01/010
    00 Case.md                 ← hub เคส (เป้าหมาย, related ids, pending ชุด)
    Workflow - ….md            ← 1 workflow = 1 ไฟล์ (เหมือนเดิม)
  Workflow - Orphan.md         ← เดี่ยว ยังไม่มีเคส → อยู่ราก 08 ได้
```

Asset: `_assets/<case-slug>/` หรือ `_assets/<workflow-slug>/` — อย่าใส่รูปใน note เป็น binary

## ตั้งชื่อ

- โฟลเดอร์เคส: ภาษาไทยหรืออังกฤษก็ได้ **ห้ามเลขนำหน้า** (`010 Clinic` ❌ · `Chatbot Clinic` ✅ · `Shopee Affiliate` ✅)
- ไฟล์ workflow: `Workflow - <ชื่อสั้น>.md` คงเดิม
- Case hub: ชื่อไฟล์คงที่ `00 Case.md` ในทุกโฟลเดอร์เคส (wikilink แยกด้วย path / ชื่อเคสในหัวข้อ)

## Frontmatter

**Workflow note** — เพิ่มฟิลด์:

```yaml
case: Shopee Affiliate   # ว่างได้ถ้าอยู่ราก 08
```

**Case hub** — ดู `_templates/Template - Case Hub.md`

## INDEX (ชั้นสำคัญสุด)

ตารางยังแบน 1 แถวต่อ `workflow_id` — เพิ่มคอลัมน์ `case` ได้

| workflow_id | name | case | status | note |
|---|---|---|---|---|
| `abc…` | Form to Jobs | Shopee Affiliate | … | `08 Worked Builds/Shopee Affiliate/Workflow - ….md` |

- path ใน `note` ต้องตรงไฟล์จริงเสมอหลังย้าย
- agent **ห้าม** สแกนโฟลเดอร์ทั้ง 08 แทน INDEX

## ลูปทำงาน (ไม่เปลี่ยน)

```
INDEX → TL;DR note → (ถ้ามีเคส อ่าน 00 Case.md เมื่อต้องการบริบทชุด)
→ get_workflow_details → อนุมัติถ้ากระทบพฤติกรรม → MCP update
→ อัปเดต History/Pending + แถว INDEX
```

หลังสร้าง workflow ใหม่ที่อยู่ในเคส:
1. เขียน note ใต้โฟลเดอร์เคส (หรือราก 08 ถ้ายังไม่มีเคส)
2. ถ้าเป็น workflow ที่ 2 ของเคส → สร้างโฟลเดอร์ + `00 Case.md` แล้วย้ายตัวแรกเข้าไป (ถาม Got ถ้าย้ายของเก่า)
3. อัปเดต INDEX ในเทิร์นเดียวกัน

## สิ่งที่ห้าม

- สร้างโฟลเดอร์เลข `01` `08` `010` ซ้อนใน Worked Builds
- แยกเคสไป `10 Client Systems` แล้วทิ้ง 08 ว่าง — `10` เก็บภาพระบบลูกค้ากว้าง; **workflow notes อยู่ 08 เท่านั้น**
- dump node JSON ทั้งก้อนลง Case หรือ Workflow note
- เก็บ secret / connection UUID

## ตัวอย่าง grouping ในอนาคต (ยังไม่ย้าย)

| case | workflows ที่น่าเข้าชุด |
|---|---|
| Shopee Affiliate | Form→Jobs · fal Video · Facebook Auto-Post |
| Slip & Income | Slip Intake · Income Form→Thunder · Daily Reconcile |
| LINE OCR | Image Intake · OCR Intake · OCR Process · (เกี่ยว CRM แยกถาม) |
| Maton Samples | Drive Upload · Sheets Read |
| *(ราก 08)* | JERA Sync · Hotel Lead · VVS · LINE OA CRM — จนกว่าจะมีคู่ |

## Related
- [[000 Home]] · [[00 Start Here]] · [[INDEX]] · [[Skill - n8n Workflow Designer]]
- Template: `_templates/Template - Case Hub.md` · `_templates/Template - n8n Workflow.md`
