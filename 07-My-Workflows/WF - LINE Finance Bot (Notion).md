---
tags: [n8n/my-workflow]
type: workflow
verified: 2026-08-03
---

# WF - LINE Finance Bot (Notion)

บันทึกรายรับ-รายจ่ายผ่าน LINE → Notion **59 nodes** — workflow ที่ซับซ้อนที่สุดในระบบ (รองจาก TikTok)
เปิด `saveDataSuccessExecution: all` (เก็บ execution สำเร็จไว้ debug)

## Flow
```
LINE Trigger ─┬─→ showLoadingAnimation (ตอบทันทีให้ user รู้ว่ากำลังทำงาน)
              └─→ Parse LINE Event → Switch "Route Message Type" (6 ทาง)
                    ├─ image     → Download → [OCR branch]
                    ├─ สรุปเดือน  → Get Monthly Expenses/Income → Flex
                    ├─ ยกเลิก     → Clear Session
                    ├─ งบ         → Get Expenses For Budget → Flex
                    ├─ text      → Get User Session → [text branch]
                    └─ postback  → Route Postback Action
```

### OCR branch (รูปใบเสร็จ)
```
Download LINE Content ─┬─→ Upload to ImgBB (HTTP) → Parse Response ─┐
                       └─→ AI Extract OCR Data ───────────────────┐ │
                                                                   ↓ ↓
                                                    Merge (mode=combine)
                                                              ↓
                                                    Merge OCR Result (Code)
                                                              ↓
                                                    Save Session After OCR
                                                              ↓
                                                    ถามว่ารายรับหรือรายจ่าย
```
**แตกขนานแล้ว Merge** — upload รูปกับ OCR ทำพร้อมกัน ไม่ต้องรอกัน
ทั้ง ImgBB node และ Parse ตั้ง **`onError=continueRegularOutput`** → อัปโหลดรูปพัง OCR ยังไปต่อได้

### Text branch — state machine ผ่าน Data Table
```
Get User Session (alwaysOutputData) → Merge Text With Session
  → Parse Quick Save Text → IF Is Quick Save?
      ├─ ใช่   → AI Prepare Save Data (ข้าม step)
      └─ ไม่ใช่ → IF Quick Save Invalid? → Reply help / Route Text Step
                    Route Text Step (3 ทาง)
                      ├─ step: ถามประเภท → AI Classify Transaction Type
                      ├─ step: ถามรายละเอียด → AI Prepare Save Data
                      └─ idle → Reply Idle Help
```
**`alwaysOutputData` บน Get User Session** สำคัญมาก — user ใหม่ยังไม่มี session ต้องได้ empty item ไม่ใช่หยุด workflow

### Save
```
Validate Category ID → IF Income Or Expense?
  ├─ Expense → IF Has Receipt URL?
  │              ├─ มี   → Save Expense With Receipt (Notion)
  │              └─ ไม่มี → Save Expense To Notion
  └─ Income  → Save Income To Notion
       ↓
Build Flex Confirmation (Code) → Reply Flex → Clear Session After Save
```

## 🔥 เทคนิคที่น่าสนใจที่สุด: ใช้ 2 model แยกหน้าที่
```
OpenRouter Chat Model  → AI Extract OCR Data          (งานหนัก: อ่านรูป)
Ollama Chat Model      → AI Extract OCR Data Parser   (local, ฟรี)
                       → AI Classify Transaction Type + Parser
                       → AI Prepare Save Data + Parser
```
**Ollama (local) รับงานเบา + งาน output parser ทั้งหมด / OpenRouter (เสียเงิน) รับเฉพาะ OCR**
→ ลดค่า token อย่างมีนัยสำคัญ. **Structured Output Parser ทั้ง 3 ตัวใช้ Ollama** — parser ไม่ต้องฉลาด แค่จัดรูปแบบ

## AI ทั้ง 3 ตัวใช้ Structured Output Parser
`AI Extract OCR Data` · `AI Classify Transaction Type` · `AI Prepare Save Data` — ทุกตัวบังคับ JSON schema
→ ผลลัพธ์คงที่ ไม่ต้องมานั่ง parse ข้อความอิสระ (ดู [[Node - Basic LLM Chain]])

## Node ที่ใช้
| จำนวน | node |
|---|---|
| 12 | LINE Messaging (reply Flex เยอะมาก) |
| 9 | Code (สร้าง Flex JSON เป็นหลัก) |
| 8 | Notion (databasePage) |
| 6 | IF · 5 Data Table · 3 Switch |
| 3 | AI Agent + 3 Structured Output Parser |
| 1 | Merge (combine) · HTTP Request (ImgBB) |

## 💡 บทเรียน
1. **`showLoadingAnimation` ยิงขนานกับ main flow** ตั้งแต่ trigger — UX ดีขึ้นมาก ผู้ใช้รู้ว่าบอทกำลังคิด
2. **Data Table = session store ที่ดีสำหรับ chatbot** — เบากว่า Postgres, จัดการใน n8n เอง
3. **Quick Save path** — คนใช้จริงไม่อยากตอบทีละ step มี shortcut ให้พิมพ์รวดเดียวแล้วข้าม flow
4. **Flex Message สร้างจาก Code node** ไม่ใช่พิมพ์ JSON ใน parameter → generate ตาม data ได้
5. **`Clear Session After Save`** ต่อท้าย reply ไม่ใช่ก่อน — reply สำเร็จค่อยล้าง session

## ⚠️ ข้อสังเกต
- `Get Monthly Income` ตั้ง `alwaysOutputData` แต่ `Get Monthly Expenses` ไม่ได้ตั้ง → เดือนที่ไม่มีรายจ่ายเลยอาจทำ flow หยุด
- ไม่มี Error Workflow
- ImgBB เป็น service ฟรีภายนอก — รูปใบเสร็จเก็บที่นั่น ควรพิจารณาเรื่อง data retention

## Related
- [[Node - Vector Store]] (ทางเลือกถ้าข้อมูลโตขึ้น)
- [[Node - Merge]] (mode combine)
- [[Node - Notion]]
- [[Pattern - Bot Handoff to Human]]
- [[MOC - My Workflows]]
