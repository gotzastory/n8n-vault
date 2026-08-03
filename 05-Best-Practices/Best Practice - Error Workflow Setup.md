---
tags: [n8n/best-practice]
type: best-practice
aliases: []
---

# Best Practice - Error Workflow Setup

> ขั้นตอนละเอียด + error data structure อยู่ที่ [[Pattern - Error Handling with Error Trigger]]

## Checklist ขั้นต่ำสำหรับทุก production workflow
- [ ] มี **Error Workflow** ตั้งใน Workflow Settings
- [ ] Error workflow แจ้งเตือนไปช่องทางที่คนเห็นจริง ([[Node - Slack]] / [[Node - Gmail]] / SMS)
- [ ] Node ที่เรียก external API เปิด **Retry On Fail** + ตั้ง Wait Between Tries
- [ ] Node ที่มี fallback ใช้ **On Error = Continue (using error output)** ไม่ใช่ `Continue` เฉยๆ
- [ ] Validation ที่ล้มเหลวใช้ **Stop And Error** node แทนปล่อยผ่าน
- [ ] เปิด save execution data (ไม่งั้น error workflow ไม่ได้ `execution.url` ไว้กดดู)

## หลักการออกแบบ
### 1. Error workflow ตัวเดียวใช้ร่วมกันได้
สร้าง `Error Handler` ตัวเดียว แล้วตั้งให้ทุก workflow ใช้ — แก้ที่เดียวมีผลทุกที่

### 2. รองรับ error 2 แบบใน error workflow เดียว
```
Error Trigger
  → IF: มี execution.id ไหม?
      ├─ มี  → error ระหว่างรัน (มี lastNodeExecuted, url)
      └─ ไม่มี → error ที่ trigger node (ใช้ข้อมูลจาก trigger{} แทน)
  → format message → แจ้งเตือน
```

### 3. แยกประเภท error → จัดการต่างกัน
| ประเภท | ตัวอย่าง | วิธี |
|---|---|---|
| **ชั่วคราว** | API timeout, rate limit, network | Retry + backoff |
| **ถาวร** | data ไม่ valid, credential ผิด, missing field | หยุด → ส่งเข้า review queue |

**อย่า retry ทุก error แบบมั่ว** — retry error ถาวรก็แค่พังซ้ำ + อาจสร้าง duplicate

### 4. เก็บ context ไว้ replay
บันทึกลง log table แทนพึ่งแค่ execution log:
```json
{ "workflow_id": "customer_sync", "status": "failed", "step": "api_call", "retry_count": 2, "error": "timeout" }
```
เก็บ failed job ไว้ replay ได้ อย่าปล่อยหาย

### 5. AI workflow เพิ่มเติม
เปิด **Enable Fallback Model** ใน [[Node - AI Agent]] เผื่อ model หลักล่ม

## ⚠️ กับดักที่เจอบ่อย
1. **Error Trigger ไม่ยิงตอนรัน manual** — ต้อง publish + ยิง Production URL. ทดสอบใน GUI จะเห็น error แค่บนหน้าจอ
2. **`Continue` (ไม่มี error output) = ฆาตกรเงียบ** — node ล้มแล้วไปต่อด้วย data เก่า ไม่มีสัญญาณอะไรเลย. อาการคือ "node รับ input แต่ไม่ output อะไร ไม่มี error" → หาสาเหตุยากมาก. ใช้ **Continue (using error output)** แล้วต่อ alert แทน
3. **Non-zero exit code ไม่ใช่ error ในสายตา n8n** — Execute Command / SSH node ต้องเช็ค `stderr` เองด้วย IF/Switch
4. Error workflow execution ไม่นับ quota — ใส่ logic ได้เต็มที่

## Related
- [[Pattern - Error Handling with Error Trigger]]
- [[Connection (Main vs Error Output)]]
- [[Best Practice - Idempotent Workflows]]
- [[Execution]]
