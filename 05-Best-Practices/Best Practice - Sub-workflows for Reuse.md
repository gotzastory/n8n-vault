---
tags: [n8n/best-practice]
type: best-practice
aliases: []
---

# Best Practice - Sub-workflows for Reuse

## ปัญหาที่แก้
Logic เดิมซ้ำหลาย workflow (auth, validation, notification, error handling) → แก้ทีต้องไล่แก้ทุกที่

## เมื่อไหร่ควรแตกเป็น sub-workflow
✅ **ควร**:
- logic ใช้ร่วมกันตั้งแต่ 2 workflow ขึ้นไป
- workflow ใหญ่จนอ่านยาก / เจอ memory issue
- ต้องการ loop ซ้อน loop (ดู [[Pattern - Batch Processing with Split In Batches]])
- แยก responsibility ให้ชัด

❌ **ไม่ควร**:
- ใช้ที่เดียว ไม่ซ้ำ → ใช้ **Canvas Group** จัดระเบียบพอ
- nested ลึกหลายชั้น → debug ยากมาก

## กฎการออกแบบ
1. **1 sub-workflow = 1 responsibility** — อย่ายัดหลายหน้าที่
2. **นิยาม input/output ให้ชัด**: ใน Execute Sub-workflow Trigger เลือก **Define using fields below** (ดีกว่า "Accept all data" เพราะ parent จะเห็น field ที่ต้องกรอกอัตโนมัติ + type ชัด)
3. **Version ก่อนแก้ breaking change** — หลาย workflow พึ่งอยู่
4. **เขียนเอกสาร** ว่า sub-workflow นี้ทำอะไร รับอะไร คืนอะไร (Sticky Note ในนั้นเลย)
5. จำกัดว่าใครเรียกได้: Workflow Settings → **This workflow can be called by**

## ข้อดีเพิ่มเติม
- **Sub-workflow execution ไม่นับ quota** — นับแค่ parent (ดู [[Execution]])
- แก้ memory issue ของ workflow ใหญ่
- ห่อ node เสี่ยงไว้แล้วดัก error ทั้งก้อนด้วย **On Error = Continue (using error output)** บน Execute Sub-workflow node

## Data flow
```
Workflow A: Execute Sub-workflow node
   → ส่ง data เข้า Workflow B (Execute Sub-workflow Trigger)
   → node สุดท้ายของ B ส่ง data กลับมาที่ node ใน A
```

## Sub-workflow vs AI Agent Tool (สำหรับ AI)
| | Sub-workflow (Call n8n Workflow Tool) | AI Agent Tool node |
|---|---|---|
| execution | แยก | **เดียวกัน** |
| canvas | คนละหน้า | หน้าเดียว |
| debug | ต้องข้ามไปมา | ที่เดียว |
| เหมาะกับ | logic ใช้ซ้ำ / กิน RAM | multi-agent ที่อยากดูรวมที่เดียว |

**แนวทางที่ community แนะนำ**: เริ่มจากใส่ tool ทั้งหมดใน workflow เดียวก่อน (เร็ว, share context), พอเริ่มใช้ซ้ำ/กิน RAM ค่อยย้ายไป sub-workflow

**Pro tip**: รวมหลาย API call ไว้ใน sub-workflow tool เดียว แทนแยกเป็น tool ละ endpoint → agent จัดการ tool น้อยลง, ลำดับการเรียกนิ่งขึ้น, ประหยัด token

## ⚠️ ข้อจำกัด
- **Sub-workflow ที่มี error อยู่ในตัว → parent เรียกไม่ได้เลย**
- **Queue mode**: sub-workflow รันบน worker เดียวกับ parent เสมอ ไม่กระจายผ่าน Redis → อยากให้ distributed ต้องใช้ [[Node - Webhook]] + [[Node - HTTP Request]] แทน
- **Wait for Sub-Workflow Completion** รอได้ทีละตัว — fan-out หลายตัวแล้วรอให้ครบ ยังไม่มี native support
- Sub-workflow conversion (`Convert to sub-workflow`) ใช้ v1 execution ordering เสมอ + expression พวก `first()/last()/all()` อาจต้องเช็คซ้ำ

## Related
- [[Sub-workflow (Execute Workflow)]]
- [[Best Practice - Naming Convention for Nodes]]
- [[Best Practice - Version Control with git]]
- [[Pattern - AI Agent with Tools]]
