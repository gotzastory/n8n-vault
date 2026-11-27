---
type: decision
status: accepted
date: 2026-11-13
tags: [decision, maton, google-drive]
trust: measured
---

# Decision - Prefer Maton HTTP for Google Drive upload

## Context
Slip intake และงาน Drive บางตัวเคยใช้ Google Drive node โดยตรง แล้วย้ายไป Maton gateway (`docs.maton.ai`) ผ่าน HTTP Request

## Decision
สำหรับ **upload แล้วจัดโฟลเดอร์/ชื่อไฟล์** ใช้สองขั้น Maton:
1. Upload media
2. Move & Rename (addParents / ตั้งชื่อ)

แทนโหนด Google Drive `Upload file` เมื่อโปรเจกต์ใช้ Maton อยู่แล้ว

## Consequences
- Credential ที่เกี่ยวข้องเป็น Bearer/Maton ฝั่ง n8n — ไม่เก็บ secret ใน vault
- ต้องตรวจ output fields (`id`, `webViewLink`, …) ให้สาย Merge/Parse ต่อได้
- ตัวอย่างที่วัดแล้ว: [[Workflow - Slip Intake (BGwGhA8N15KGZxj4)]] · [[Workflow - Maton Google Drive Upload]]

## Not decided
- จะย้ายโหนด Drive อื่นทั้งหมดเป็น Maton หรือไม่ — ทีละ workflow ตามอนุมัติ
