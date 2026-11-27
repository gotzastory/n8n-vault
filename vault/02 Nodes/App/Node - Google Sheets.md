---
tags: [n8n/node]
type: node
node-type: action
aliases: []
---

# Node - Google Sheets

## Operations
| Resource | Operations |
|---|---|
| **Document** | Create, Delete (spreadsheet ทั้งไฟล์) |
| **Sheet Within Document** | **Append or Update Row**, **Append Row**, **Update Row**, **Get Row(s)**, Clear, Create, Delete, Delete Rows or Columns |

## Append vs Append or Update vs Update
| Operation | พฤติกรรม |
|---|---|
| **Append Row** | เพิ่มแถวใหม่ท้ายข้อมูลเสมอ |
| **Update Row** | อัปเดตแถวที่มีอยู่**เท่านั้น** — ไม่เจอ = ไม่ทำอะไร |
| **Append or Update Row** | เจอ = update, ไม่เจอ = append (upsert) — ต้องตั้ง **Column to Match On** |

> อยากเก็บ history ไม่ให้ทับ: อย่าใช้ Clear + Write ใหม่ ให้ใช้ **Append or Update** + Column to Match On แทน

## Mapping Column Mode
- **Map Each Column Manually** — เลือกค่าให้ทีละ column
- **Map Automatically** — n8n จับคู่ field ชื่อตรงกับ column อัตโนมัติ (ต้องชื่อตรงเป๊ะ — ใช้ [[Node - Set (Edit Fields)]] ปรับก่อนถ้าจำเป็น)
- **Nothing** — ไม่ map

## Options
- **Cell Format**: *Let Google Sheets format* (default) vs *Let n8n format* (cell ใหม่ใช้ data type ตาม input ของ n8n)
- **Data Location on Sheet**: **Header Row** / **First Data Row** (ระบุ index)
- **Handling extra fields in input** (ใช้กับ Map Automatically): **Insert in New Column(s)** (default) / Ignore Them / Error
- **Use Append**: เปิด = ใช้ Google append endpoint ตรงๆ เร็วกว่า/API call น้อยกว่า **แต่ถ้าข้อมูลเดิมมีช่องว่างคั่น อาจเขียนผิดตำแหน่ง**. default n8n จะเติมแถวเปล่าก่อนแล้วค่อยเขียน (ช้ากว่าแต่ตำแหน่งแม่นกว่า)

## ระบุ Document / Sheet
- Document: From list / By URL / **By ID** — `spreadsheetId` อยู่ใน URL: `docs.google.com/spreadsheets/d/{spreadsheetId}/edit#gid=0`
- Sheet: From list / By URL / By ID / **By Name** — `sheetId` คือค่าหลัง `#gid=`

## Gotcha
- **Update Row ทำได้ทีละแถว** — อัปเดตหลายแถวพร้อมกันไม่ได้ (โดยเฉพาะเวลาใช้เป็น AI tool). workaround: ใช้ **AI Agent Tool + Batch Processing** ให้ agent เรียกทีละชุด
- **Append Row ตกหล่นภายใต้ concurrency สูง** (webhook ~100 requests พร้อมกัน → ได้แถวไม่ครบ ทั้งที่ execution สำเร็จหมด). workaround: pre-populate แถวด้วย unique id ก่อน แล้วใช้ **Update** จับคู่แทน append
- CSV/data ที่ column ไม่คงที่: ใช้ Append Row + Map Automatically + Handling extra fields = Insert in New Column(s) → sheet เปล่าจะได้ header จากชื่อ field รอบแรกเลย

## Related
- [[Node - Set (Edit Fields)]]
- [[Credential]], [[OAuth2 in n8n]]
- [[Node - Split In Batches]] (กัน rate limit)

## Official Docs
- https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.googlesheets
- https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.googlesheets/sheet-operations
