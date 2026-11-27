---
tags: [workflow, example, type/worked-build]
workflow_id: "REPLACE_ME"
status: example
case:
trust: example-data
---

# Workflow - Example Sample

> **Example data** — ไม่ใช่งานลูกค้าจริง ใช้สอนโครง note เท่านั้น

## TL;DR
- Trigger: Manual / Webhook (ตัวอย่าง)
- ทำอะไร: รับข้อความ → แปลง → เขียน Sheet
- MCP: แก้ผ่าน `get_workflow_details` หลังมี `workflow_id` จริง
- Pending: แทนที่ด้วยเคสของคุณ แล้วลบไฟล์นี้ได้

## Requirements
- Input: ข้อความจากฟอร์ม
- Output: แถวใหม่ใน Google Sheet
- Constraints: ห้ามเก็บ secret ใน note

## History
- (example) สร้างเป็น template สำหรับ public vault
