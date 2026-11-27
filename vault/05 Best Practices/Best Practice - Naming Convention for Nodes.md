---
tags: [n8n/best-practice]
type: best-practice
aliases: []
---

# Best Practice - Naming Convention for Nodes

## หลักการ
**เปลี่ยนชื่อ node ทุกตัวให้บอกหน้าที่** อย่าปล่อยชื่อ default (`HTTP Request1`, `Edit Fields2`) — เพราะ:
- expression อ้างชื่อ node: `$('ชื่อ node').item.json.x` → ชื่อสื่อความหมาย = อ่าน expression รู้เรื่อง
- เปิด workflow ตัวเองย้อนหลัง 3 เดือนแล้วยังเข้าใจ
- ทีมคนอื่นอ่านได้

## แนวทางตั้งชื่อ
| แทนที่ | ด้วย |
|---|---|
| `HTTP Request` | `Fetch Order from API` |
| `Edit Fields1` | `Map to Sheet Columns` |
| `IF` | `Is Payment Successful?` |
| `Code` | `Sum Order Totals` |
| `Postgres` | `Insert Order Row` |

- ใช้ **verb + object**: `Fetch...`, `Insert...`, `Validate...`, `Notify...`
- IF/Switch ตั้งเป็น**คำถาม**: `Is Urgent?`, `Which Region?` — อ่านแล้วรู้ว่า branch ไหนคืออะไร
- Switch: เปิด **Rename Output** ตั้งชื่อ output แต่ละทางด้วย

## ⚠️ เปลี่ยนชื่อ node = expression พัง
Expression ที่อ้างชื่อเก่าจะหาไม่เจอ → **ตั้งชื่อให้ดีตั้งแต่แรก** ก่อนต่อ node อื่น. ถ้าจำเป็นต้องเปลี่ยน ต้องไล่แก้ทุก expression ที่อ้างถึง

## Terminology ทางการของ n8n (ใช้ตรงกันเวลาคุย/เขียนเอกสาร)
| ใช้ | อย่าใช้ |
|---|---|
| **workflow** | flow, automation, scenario, pipeline, zap |
| **node** | step, block, module |
| **execution** | run (นาม), job, invocation |
| **publish / unpublish** | activate, deactivate, enable, disable, deploy |
| **pin data** | mock data, freeze data, sample data |
| **sub-workflow** | subworkflow, subflow, child workflow |
| **app node / core node / cluster node / root node / sub-node** | integration node, system node, parent/child node |
| **community node** | custom node, plugin, add-on |
| **canvas** / **sticky note** | editor board / comment, annotation |
| **self-hosted** / **n8n Cloud** | on-prem / SaaS |
| **n8n** (พิมพ์เล็กเสมอ) | N8N, N8n |

## จัดระเบียบ workflow ใหญ่
1. **Canvas Groups** (n8n 2.28+): เลือก node ที่เกี่ยวข้อง → `Ctrl/Cmd + G` → ตั้งชื่อ → collapse ได้
   - trigger อยู่นอกกลุ่มเสมอ, node ต้องต่อกันเป็นสายเดียว, AI node ต้องมี sub-node อยู่ในกลุ่มเดียวกัน
   - group save กับ workflow (ทุกคนเห็นเหมือนกัน) แต่ collapse/expand เป็น preference ส่วนตัวใน browser
   - ungroup: `Ctrl/Cmd + Shift + G`
2. **Sticky Note** อธิบายส่วนที่ซับซ้อน (สี: เหลือง=ข้อมูล, เขียว=วิธีรัน, ส้ม=ต้องแก้ก่อนใช้, ฟ้า=จุดสำคัญ)
3. **แตกเป็น sub-workflow** เมื่อโตเกิน — ดู [[Best Practice - Sub-workflows for Reuse]]
4. **Node Notes** (Settings → Notes + Display note in flow) เขียนอธิบายติดกับ node

## Credential naming
n8n ตั้งชื่อ default เป็น "*node name* account" — เปลี่ยนให้บอก **app + type + purpose** เช่น `Gmail OAuth2 - Support Inbox` (ดู [[Best Practice - Credential Management]])

## Related
- [[Best Practice - Sub-workflows for Reuse]]
- [[Expression Syntax]]
- [[Node - Switch]]
