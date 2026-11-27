---
tags: [n8n/concept]
type: concept
aliases: []
---

# Binary Data

## Definition
Binary data = ข้อมูลไฟล์ทุกชนิด (รูป, PDF, doc) ที่ generate/process ระหว่าง execution. เก็บใน item ภายใต้ key `binary` แยกจาก `json` — ดู [[Item (n8n Data Structure)]]. แต่ละ binary property เป็น `BinaryFile` object: `data` (base64, required), `mimeType`, `fileExtension`, `fileName`

## Node หลักที่ใช้จัดการ
- **Convert to File** — JSON → binary file
- **Extract From File** — binary → JSON (รองรับ CSV, HTML, JSON, ICS, ODS, PDF, RTF, Text, XLS/XLSX, Base64)
- **Read/Write Files from Disk** — อ่าน/เขียนไฟล์บนเครื่องที่รัน n8n
- HTML/XML node สำหรับ format เฉพาะ

## เข้าถึงใน expression/Code
- `.item.binary` คืน object ของ binary property ทั้งหมด (ไม่ใช่ค่าเดียว เพราะ item มีได้หลาย property)
- Code node: ใช้ `this.helpers.getBinaryDataBuffer(itemIndex, binaryPropertyName)` เท่านั้น — อย่า access buffer ตรงๆ แบบเก่า (`items[0].binary.data.data`)

## Binary data ไม่ไหลอัตโนมัติ
**Insight สำคัญ**: binary data ไม่ได้ผ่านทุก node อัตโนมัติเหมือน json — ต้อง preserve เองทุก step (เช่น [[Node - Merge]] เพื่อรวม branch, หรือ Code node คืน `{json, binary}` ตรงๆ) ไม่งั้นเจอ error "No binary data exists on item!"

## Self-host configuration
- Default: เก็บใน memory → ไฟล์ใหญ่ทำ crash ได้
- `N8N_DEFAULT_BINARY_DATA_MODE=filesystem` — เก็บลง disk แทน (แนะนำ production)
- Queue mode ไม่รองรับ filesystem mode → ใช้ `database` หรือ S3/Azure external storage แทน (ดู [[Queue Mode]])
- ปิดการอ่าน/เขียนไฟล์ทั้งหมดได้ผ่าน `NODES_EXCLUDE` (security)

## Related
- [[Item (n8n Data Structure)]]
- [[Node - Merge]]
- [[Node - Code]]
- [[Queue Mode]]

## Official Docs
- https://docs.n8n.io/build/work-with-data/handle-special-data-types/work-with-files-and-images
- https://docs.n8n.io/deploy/host-n8n/configure-n8n/basic-configuration/use-environment-variables/binary-data
- https://docs.n8n.io/build/code-in-n8n/cookbook/code-node/get-the-binary-data-buffer
