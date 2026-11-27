---
tags: [n8n/pattern]
type: pattern
source: my-workflow
verified: 2026-08-03
---

# Pattern - Multi-Document Session Accumulation

> สกัดจาก [[WF - Customs Doc to Sheet]]

## Problem
ผู้ใช้ส่งไฟล์/ข้อมูลมา **ทีละชิ้น หลาย message** แต่ต้องรอครบทุกชิ้นก่อนถึงประมวลผลได้
แต่ละ message = **1 execution แยกกัน** → n8n ไม่จำอะไรข้าม execution

ตัวอย่าง: ต้องได้ B/L + Invoice + Packing List ครบ 3 ใบถึงจะกรอกใบขนได้

## Workflow Shape
```
Trigger (แต่ละไฟล์) → สกัดข้อมูล (AI/parse)
   ↓
Get Session   [alwaysOutputData]   ← ดึง state เดิมของ user
   ↓
Merge Into Session (Code)          ← หัวใจ: รวมของใหม่เข้าของเก่า
   ↓
Save Session (upsert by userId)
   ↓
IF isComplete?
   ├─ ครบ → ประมวลผลจริง
   └─ ยังไม่ครบ → ตอบว่าเหลืออะไรอีก
```

## โค้ด Merge (แก่นของ pattern)
```javascript
const extracted = $('Parse Extracted JSON').first().json;
const existingRows = $('Get Session').all().map((i) => i.json);
const existing = existingRows[0] || {};        // ← ไม่มีก็ใช้ object ว่าง

const session = {
  userId,
  hasBl:      existing.hasBl      || false,    // ← สืบทอดค่าเดิม
  hasInvoice: existing.hasInvoice || false,
  hasPacking: existing.hasPacking || false,
  blData:      existing.blData      || '',
  invoiceData: existing.invoiceData || '',
  packingData: existing.packingData || '',
};

// เขียนทับเฉพาะชิ้นที่เพิ่งได้มา
if (docType === 'bl')                { session.hasBl = true;      session.blData = JSON.stringify(extracted); }
else if (docType === 'invoice')      { session.hasInvoice = true; session.invoiceData = JSON.stringify(extracted); }
else if (docType === 'packing_list') { session.hasPacking = true; session.packingData = JSON.stringify(extracted); }

session.isComplete = session.hasBl && session.hasInvoice && session.hasPacking;
return [{ json: session }];
```

## 4 จุดที่ต้องทำให้ถูก
### 1. `alwaysOutputData` บน node ที่ดึง session
user ใหม่ยังไม่มีแถว → ถ้าไม่เปิด workflow จะ**หยุดเงียบ**ตรงนั้น ไม่ไปต่อ

### 2. Upsert ไม่ใช่ insert
```
operation: upsert
filters: userId = {{ $json.userId }}
```
ไม่งั้นได้แถวใหม่ทุกครั้ง แล้ว `existingRows[0]` หยิบแถวผิด

### 3. ล็อกค่าที่ต้องคงที่จากชิ้นแรก
```javascript
// lock direction on the first document that determines it; ignore later disagreements
if (!session.direction && extracted.direction) { session.direction = extracted.direction; }
```
AI อ่านเอกสารคนละใบอาจสรุปไม่ตรงกัน — **เชื่อใบแรกที่ตอบได้ แล้วไม่ให้ใบหลังแก้**

### 4. เก็บ `replyToken` / context ของ message ล่าสุดไว้ใน session
LINE `replyToken` ใช้ได้ครั้งเดียวและหมดอายุเร็ว — ต้องเก็บของ message ล่าสุดเสมอ ไม่ใช่ของชิ้นแรก

## เก็บ state ที่ไหนดี
| ที่เก็บ | เหมาะเมื่อ |
|---|---|
| **n8n Data Table** | session ระยะสั้น อยู่ในระบบ n8n ล้วน (ที่ใช้ในเคสนี้) |
| **Supabase/Postgres** | ต้อง query ซับซ้อน / แชร์กับระบบอื่น |
| **Airtable** | ต้องให้คนเข้าไปดู/แก้ด้วยมือ |
| `$getWorkflowStaticData()` | ข้อมูลเล็กมาก + ไม่ต้องแยกตาม user (ดู [[Pattern - Polling API (Schedule Trigger)]]) |

## ⚠️ สิ่งที่มักลืม
- **ไม่มี logic เคลียร์ session หลังจบ** → ชุดถัดไปเจอ flag ค้างจากรอบเก่า ต้อง reset หลัง `isComplete`
- **ไม่มี TTL** → session ที่ไม่เคยครบค้างในตารางตลอดไป
- **race condition**: user ส่ง 3 ไฟล์รัวๆ พร้อมกัน → 3 execution อ่าน session เดียวกันตอนยังว่าง แล้วเขียนทับกัน
  → กันด้วย [[Node - Split In Batches|คิว]] หรือ unique constraint ที่ระดับ DB

## Related
- [[WF - Customs Doc to Sheet]]
- [[Best Practice - Idempotent Workflows]]
- [[Pattern - Chatbot Workflow]]
- [[Node - Code]]
