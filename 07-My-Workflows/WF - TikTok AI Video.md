---
tags: [n8n/my-workflow]
type: workflow
verified: 2026-08-03
---

# WF - TikTok AI Video

สร้างวิดีโอ TikTok ด้วย AI + ปักตะกร้า — **61 nodes** ใหญ่สุดในระบบ
ต่อกับ **Chrome Extension** (webhook path ตรงกับ `DEFAULT_ENDPOINTS` keys ของ extension)

## Flow หลัก
```
Webhook  → Route by Action (Switch 6 ทาง) → CRUD บน Data Table
Webhook1 → Get Products from DB
Webhook2 → Get UGC from DB

[pipeline สร้างวิดีโอ]
Get row(s) → Analyze image (OpenAI vision)
  → AI Write TikTok Script (GPT-4o-mini + Structured Output Parser)
  → phaya.io Generate Model Image → [polling] → Update row
  → GenVideo → [polling] → Get row → merge video → [polling] → Update row → Done
```

## 🔥 Pattern เด่น: Async API polling ด้วย Wait + IF loop
API ของ phaya.io คืน job id แล้วต้องถามสถานะเอง — pattern นี้ซ้ำ **4 รอบ**ใน workflow:
```
Generate Model Image (POST)  [retryOnFail]
  → Wait 30s
  → Check Image Status       [retryOnFail]
  → Switch "Image Status?"
      ├─ [0] สำเร็จ → ไปต่อ
      └─ [1] ยังไม่เสร็จ → วนกลับ Wait 30s   ← self-loop
```
เหมือนกันกับ video: `GenVideo → Wait1 → check video status → IF → Get row → GenVideo` (วนกลับ)

**ทุก HTTP node ตั้ง `retryOnFail`** — network พังชั่วคราวไม่ทำ pipeline ยาวๆ ตาย

ดู [[Pattern - Async API Polling with Wait Loop]]

## Wait time ที่ใช้จริง
| ขั้นตอน | รอ |
|---|---|
| Generate Model Image | **30s** |
| Extract Image | **5s** |
| Video generation | Wait / Wait1 (ไม่ระบุ default) |
| Merge video | Wait3 |

> เวลารอไม่เท่ากันตามน้ำหนักงาน — ปรับจากประสบการณ์จริง ไม่ใช่ค่าเดียวใช้หมด

## Data Table เป็น job queue
16 node ที่แตะ Data Table — ทำหน้าที่เป็น **state machine ของ job**:
```
Route by Action → Update row(s)        (แก้ status)
                → Get row(s)           (ดึงงานถัดไป)
                → Upload Item          (เพิ่มงาน)
                → DB Insert — Posted   (บันทึกที่โพสต์แล้ว)
                → Get row(s)4          (query)
                → DB Delete — Remove   (ลบ)
```
+ `Update row(s)1/2/3/4` กระจายตามจุด checkpoint ของ pipeline
→ **Chrome Extension เรียก webhook แล้วอ่าน status จาก Data Table** = ทำ UI ได้โดยไม่ต้องมี backend แยก

## AI ในระบบ
| Node | ใช้ทำ |
|---|---|
| `Analyze image` (OpenAI, resource=image) | อ่านรูปสินค้า → `$json.content` |
| `AI Write TikTok Script` (Agent + GPT-4o-mini) | เขียนสคริปต์ |
| `Script JSON Parser` (Structured Output Parser) | บังคับ output เป็น JSON schema |

Description ของ workflow บอกไว้: *"AI Agent prompt ใช้ `$json.content` จาก Analyze image node"*

## 💡 บทเรียน
1. **Sticky Note 7 อัน** — workflow 61 node ถ้าไม่มีโน้ตอ่านไม่รู้เรื่อง (ดู [[Best Practice - Naming Convention for Nodes]])
2. **`retryOnFail` บน HTTP node ทุกตัวที่เรียก external API** — pipeline ยาว 10+ นาที ล้มกลางทางแล้วเริ่มใหม่แพง
3. **แยก webhook ตาม action** (3 ตัว) แทนใช้ตัวเดียวแล้ว route — ฝั่ง Chrome Extension เรียกตรงจุด
4. **Data Table แทน external queue** สำหรับงาน async ที่ไม่ซับซ้อนมาก

## ⚠️ ข้อสังเกต (จุดที่ควรปรับ)
- **ชื่อ node ซ้ำเป็นตัวเลข**: `Get row(s)`, `Get row(s)1-4`, `Update row(s)`, `Update row(s)1-4`, `If`, `If1-5`, `Wait`, `Wait1`, `Wait3` → expression ที่อ้างชื่อพวกนี้อ่านไม่รู้เรื่องเลย และแก้ผิดตัวง่ายมาก
  → ควรตั้งชื่อตามหน้าที่: `Get Pending Job`, `Mark Image Ready`, `Wait for Video Render`
- **`phaya.io — Generate Model Image` มี 4 ตัว** (ไม่มี suffix, 1, 2, 4) — ไม่มี 3 → น่าจะเคยลบทิ้ง เหลือช่องว่าง
- **polling ไม่มี max attempt** — API ค้างสถานะ "processing" ถาวร = วนไม่จบ ควรมีตัวนับรอบ + timeout (ดู [[Pattern - Async API Polling with Wait Loop]])
- ไม่มี Error Workflow

## Related
- [[Pattern - Async API Polling with Wait Loop]]
- [[Node - HTTP Request]]
- [[Best Practice - Naming Convention for Nodes]]
- [[MOC - My Workflows]]
