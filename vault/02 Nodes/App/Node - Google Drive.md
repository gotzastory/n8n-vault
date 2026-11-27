---
tags: [n8n/node, google-drive]
type: node
node-type: action
aliases: [Google Drive]
---

# Node - Google Drive

## What it does
เชื่อม n8n กับ Google Drive เพื่อค้นหาโฟลเดอร์/ไฟล์ สร้างโฟลเดอร์ และอัปโหลดไฟล์ โดยใช้ OAuth credential ของ Google Drive

## Operations used in this workflow
| Node instance | Operation | หน้าที่ |
|---|---|---|
| `Search Daily Folder` | Search file/folder ด้วย query | ค้นหาโฟลเดอร์ชื่อ `YYYY-MM-DD` ใต้ parent ที่กำหนด |
| `Create folder` | Create folder | สร้างโฟลเดอร์รายวันเมื่อค้นไม่พบ |
| `Upload file` | Upload file | อัปโหลดรูปสลิปทุกผลการตรวจเข้าโฟลเดอร์รายวัน |
| `Search files and folders` | Search file/folder ด้วย query | ค้นหา monthly spreadsheet ก่อนเขียนข้อมูล |

## Daily-folder connection pattern
```text
Intake Slip Form
→ Search Daily Folder
→ Daily Folder Exists?
   ├─ true  → Use Existing Daily Folder
   └─ false → Create folder
→ Merge Daily Folder
→ Merge Prepared Items
→ Attach Daily Folder
→ Upload file
```

`Attach Daily Folder` ต้องเติม `dailyFolderId` ให้ทุก slip item ก่อนเข้า `Upload file`

## Upload pattern
- `Upload file.name` ใช้ `sourceFile` ของแต่ละ item
- `Upload file.folderId` ใช้ `dailyFolderId` แบบ expression
- อัปโหลดก่อนจัดประเภทผล เพื่อให้จริง/ปลอม/ซ้ำ/ไม่ใช่บัญชีมี link สำหรับ audit ได้ทั้งหมด
- หลัง upload ใช้ [[Node - Merge]] `Merge Upload & Verify` รวม metadata จาก Drive กับผล Thunder ตามตำแหน่ง

## Search monthly spreadsheet
- จำกัด query ด้วยชื่อไฟล์, เดือนภาษาไทยย่อ, ปี พ.ศ., parent folder และ `trashed = false`
- ผลลัพธ์ถูกส่งไป [[Node - Code]] `Build Sheet Rows`
- ตรวจว่า Search ได้อย่างน้อยหนึ่ง item ก่อนให้ [[Node - Google Sheets]] append

## Gotchas
- Search ที่ไม่พบต้องเปิด `Always Output Data` เพื่อให้ branch สร้าง folder เดินต่อได้
- native Drive node คืน metadata เช่น `id`, `name`, `webViewLink`; ไม่ได้การันตีว่าจะส่ง binary เดิมต่อ
- อย่าอ่าน binary จาก branch folder; ให้ normalize binary จาก Form ก่อน แล้ว merge metadata ทีหลัง
- การค้นหา/สร้างโฟลเดอร์พร้อมกันหลาย execution ในวันเดียวกันอาจเกิด race และสร้างชื่อซ้ำได้
- ห้ามเก็บ Drive ID, credential ID หรือ secret ลง knowledge note

## Related
- [[Node - Form Trigger]]
- [[Node - Code]]
- [[Node - Merge]]
- [[Node - Google Sheets]]
- [[Pattern - Multi-file Slip Intake Node Connections]]
- [[Workflow - Income Slip Intake LINE to Thunder]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.googledrive
