---
cssclasses: [vault-hub]
tags: [hub, ai, skills, type/hub]
---

# AI Skills Start Here

Skill สำหรับ agent อยู่ที่ **parent** `n8n-vault/` (ไม่เก็บโฟลเดอร์ `.agents` ในคลังนี้)

## ที่ติดตั้งแล้ว
| Skill note | โฟลเดอร์จริง (relative จาก parent) | ใช้เมื่อ |
|---|---|---|
| [[Skill - n8n Workflow Designer]] | `.agents/skills/n8n-workflow-designer/` | ออกแบบ / สร้าง / แก้ workflow บน n8n |

## กติกาสั้น
1. Agent อ่าน `name` + `description` ของ skill ก่อน
2. งานตรงคำอธิบาย → โหลด `SKILL.md` เต็มจาก parent
3. ความจริงของ nodes อยู่ที่ **n8n MCP** · vault เก็บทำไม / ข้อห้าม / pending
4. ลูปมาตรฐาน: [[INDEX]] → TL;DR → `get_workflow_details` → อนุมัติ → MCP update → อัปเดต note สั้น

## ติดตั้งที่อื่น
คัดลอกโฟลเดอร์ skill จาก `n8n-vault/.agents/skills/` ไป `~/.claude/skills/` หรือโปรเจกต์อื่น — อย่า copy เฉพาะไฟล์โดยไม่มีโฟลเดอร์ห่อ
