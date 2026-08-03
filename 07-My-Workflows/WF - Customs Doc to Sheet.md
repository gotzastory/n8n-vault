---
tags: [n8n/my-workflow]
type: workflow
verified: 2026-08-03
aliases: [ใบขนขาเข้า, BL Invoice Packing List]
---

# WF - Customs Doc to Sheet

รับ **B/L + Invoice + Packing List** ทีละไฟล์ทาง LINE → AI จำแนก+สกัด → สะสมจนครบ 3 → กรอกลง Google Sheets ใบขนสินค้า

## Flow
```
LINE Trigger (message) → Get Document Content
  → IF Is Image Message?
      ├─ image → Gemini "Classify & Extract (Image)"   [resource=image, operation=analyze]
      └─ PDF   → Gemini "Classify & Extract (PDF)"     [resource=document]
  → Parse Extracted JSON
  → Get Shipment Session (Data Table, alwaysOutputData)
  → Merge Into Session (Code)   ← หัวใจ
  → Save Shipment Session (Data Table upsert)
  → IF Shipment Complete?
      ├─ ครบ 3   → Build Sheet Payload → HTTP batchUpdate → Share → LINE ส่งลิงก์
      └─ ยังไม่ครบ → Build Waiting Message → LINE บอกว่ารออะไรอีก
```

## 🔥 เทคนิคเด่น 1: prompt เดียวทำทั้งจำแนกและสกัด
Gemini prompt เดียวคืน JSON ที่มี **`doc_type`** บอกว่าเป็นเอกสารอะไร + fields ทั้งหมด
→ ไม่ต้องมี classifier แยก ประหยัด 1 call

```
"doc_type": "bl หรือ invoice หรือ packing_list หรือ unknown"
"direction": "import หรือ export - ให้ดูว่าที่อยู่ผู้รับสินค้า(Consignee)อยู่ในไทยหรือไม่
              ถ้าใช่ = import, ถ้าที่อยู่ผู้ส่งสินค้า(Shipper/Exporter)อยู่ในไทยแทน = export"
```
**ให้ AI ตัดสิน import/export จาก logic ทางธุรกิจ** ไม่ใช่ให้คนเลือก

Prompt ยังสั่งงานที่ต้องใช้ความรู้เพิ่ม:
- `"item_desc_th": "(แปลเป็นไทย)"` — แปลในตัว
- `"hs_code": "(เดา HS Code 8 หลักจากชื่อสินค้า)"` — **ยอมรับว่าเดา** แล้วเตือน user ทีหลัง
- `"trade_value": "(CIF ถ้า import, FOB ถ้า export)"` — เลือก field ตาม direction

### ⚠️ ปิดท้ายด้วย disclaimer
```
"⚠️ กรุณาตรวจสอบ HS Code, มูลค่า CIF, และรหัสประเทศก่อนยื่นจริง"
```
**เอกสารราชการ = ต้องมี human check** — ออกแบบให้ AI ช่วยร่าง ไม่ใช่ยื่นแทน

## 🔥 เทคนิคเด่น 2: Parse JSON จาก LLM ที่ทนทาน
```javascript
let raw = item.content || item.text || '';
if (typeof raw === 'object') { raw = raw?.parts?.map((p) => p.text).join('\n') || JSON.stringify(raw); }
raw = String(raw).replace(/```json/gi, '').replace(/```/g, '').trim();
try {
  const match = raw.match(/\{[\s\S]*\}/);      // ← ดึงเฉพาะก้อน {...}
  data = JSON.parse(match ? match[0] : raw);
} catch (e) {
  data = { doc_type: 'unknown', parseError: e.message };
}
```
รับมือ 4 กรณี: response เป็น object, มี markdown fence, มีข้อความนำหน้า/ตามหลัง, parse ไม่ได้เลย
**ไม่ throw** — คืน `doc_type: 'unknown'` แล้วให้ flow จัดการต่อ

## 🔥 เทคนิคเด่น 3: Session accumulation ข้าม execution
แต่ละไฟล์ที่ส่งมา = **1 execution แยกกัน** — ใช้ Data Table `import_shipment_sessions_v2` เก็บ state ต่อ `userId`:
```javascript
const existing = existingRows[0] || {};
const session = {
  userId, replyToken,
  hasBl: existing.hasBl || false,
  hasInvoice: existing.hasInvoice || false,
  hasPacking: existing.hasPacking || false,
  blData: existing.blData || '', ...
};
// lock direction on the first document that determines it; ignore later disagreements
if (!session.direction && extracted.direction) { session.direction = extracted.direction; }

if (docType === 'bl') { session.hasBl = true; session.blData = JSON.stringify(extracted); }
…
session.isComplete = session.hasBl && session.hasInvoice && session.hasPacking;
```
**`direction` ล็อกจากเอกสารแรกที่ระบุได้** — เอกสารหลังเถียงก็ไม่สน (AI อาจตอบไม่ตรงกันระหว่างไฟล์)

ดู [[Pattern - Multi-Document Session Accumulation]]

## 🔥 เทคนิคเด่น 4: เขียน Sheets ผ่าน HTTP Request ไม่ใช่ Google Sheets node
```
POST https://sheets.googleapis.com/v4/spreadsheets/{id}/values:batchUpdate
authentication: predefinedCredentialType
nodeCredentialType: googleSheetsOAuth2Api      ← ใช้ credential เดิม!
```
**เพราะต้องเขียนลง cell เจาะจง** (`B5`, `B10`, `A27:N27`) ในหลาย range พร้อมกัน — Google Sheets node ทำ append/update แถวได้ แต่ไม่รองรับ batchUpdate แบบระบุ range เอง

Payload สร้างจาก Code node — map แบบ import/export ต่างกัน:
```javascript
// Import: B10=Shipper name, B11=Shipper addr, B12=Importer name, B13=TaxID, B14=Importer addr
// Export: B10=Exporter name, B11=TaxID, B12=Exporter addr, B13=Consignee name, B14=Consignee addr
const singleFields = isExport ? {...} : {...};
const data = Object.entries(singleFields).map(([cell, value]) => ({
  range: sheetTab + '!' + cell, values: [[String(value)]]
}));
data.push({ range: sheetTab + '!A27:N27', values: [itemRow.map(String)] });
```
+ helper `pick()` เลือกค่าแรกที่ไม่ว่างจากหลาย source (BL/Invoice/Packing มีข้อมูลทับซ้อนกัน):
```javascript
const pick = (...vals) => vals.find((v) => v !== undefined && v !== null && v !== '') || '';
pick(pack.package_qty, bl.package_qty)      // Packing List แม่นกว่า → เอาก่อน
pick(inv.party_b_tax_id, bl.party_b_tax_id) // Invoice มี Tax ID ชัดกว่า
```

## 💡 บทเรียน
1. **1 prompt ทำหลายงาน** (จำแนก + สกัด + แปล + เดา HS code) ประหยัดกว่าแยก call
2. **Data Table เก็บ session ที่ต้องข้าม execution** — ไม่ต้องพึ่ง external DB
3. **`replyToken` ต้องเก็บใน session ด้วย** — ตอบกลับ LINE ต้องใช้ token ของ message ล่าสุด
4. **HTTP Request + predefinedCredentialType** = ใช้ credential ที่มีอยู่ยิง API ที่ node ทำไม่ได้ (ดู [[Node - HTTP Request]])
5. **Share Spreadsheet เป็น `anyone/reader`** ก่อนส่งลิงก์ — user เปิดได้โดยไม่ต้องขอสิทธิ์

## ⚠️ ข้อสังเกต
- Spreadsheet ID **hard-code ใน Code node 2 ที่** (Build Sheet Payload + Build Done Message) → แก้ต้องแก้ 2 จุด
- ทุก shipment เขียนทับ **template เดิมใบเดียว** — ไม่ได้ copy ใหม่ต่อ shipment → ข้อมูลเก่าหาย
- ไม่มี logic เคลียร์ session หลังจบ → ส่งเอกสารชุดใหม่ต้องมี hasBl/hasInvoice/hasPacking ค้างจากรอบเก่า
- `unknown` doc_type ไม่ถูก handle เป็นพิเศษ — จะวนอยู่ที่ waiting message

## Related
- [[Pattern - Multi-Document Session Accumulation]]
- [[Node - HTTP Request]]
- [[Node - Code]]
- [[Binary Data]]
- [[MOC - My Workflows]]
