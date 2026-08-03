---
tags: [n8n/pattern]
type: pattern
aliases: []
---

# Pattern - Error Handling with Error Trigger

## Problem
Workflow พังเงียบๆ ไม่มีใครรู้ → ต้องมีระบบแจ้งเตือน + กู้คืนเมื่อ execution ล้มเหลว

## 3 ชั้นของการจัดการ error
| ชั้น | เครื่องมือ | ใช้เมื่อ |
|---|---|---|
| **Node-level** | Settings → **On Error**: Stop Workflow / Continue / **Continue (using error output)** + **Retry On Fail** | จัดการ error เฉพาะจุด, fallback service |
| **Workflow-level** | **Error Workflow** ใน Workflow Settings | แจ้งเตือนรวมศูนย์ทุก workflow |
| **Manual** | **Stop And Error** node | บังคับให้ fail ตามเงื่อนไขที่เรากำหนดเอง (เช่น validation ไม่ผ่าน) |

## Workflow Shape (Error Workflow)
```
Error Trigger → [[Node - Slack]] / [[Node - Gmail]] แจ้งเตือน
              → บันทึกลง log database
```

## Setup
1. สร้าง workflow ใหม่ ขึ้นต้นด้วย **Error Trigger** ตั้งชื่อ เช่น `Error Handler` แล้ว save
2. ใน workflow ที่ต้องการ monitor: **Options → Settings → Error workflow** → เลือก `Error Handler` → Save
3. ใช้ error workflow เดียวกันกับหลาย workflow ได้

**ไม่ต้อง publish error workflow** — Error Trigger ทำงานเองอัตโนมัติ

## Error data ที่ได้รับ
```
workflow.id / workflow.name
execution.id / execution.url / execution.error / execution.lastNodeExecuted / execution.retryOf
```
ไม่ได้มาครบเสมอ:
- `execution.id` / `execution.url` — ต้อง save execution ลง DB ก่อน. **ไม่มีถ้า error เกิดที่ trigger node** (workflow ยังไม่ได้รัน)
- `execution.retryOf` — มีเฉพาะตอน retry
- **error ที่ trigger node** จะส่ง data คนละหน้าตา: ข้อมูลใน `execution{}` น้อยลง แต่มี `trigger{}` เพิ่มมา → error workflow ต้องเช็คทั้งสองแบบ

## ⚠️ Gotchas สำคัญ
- **Error Trigger ทำงานเฉพาะ production execution เท่านั้น** — รัน manual ใน GUI จะไม่ยิง error workflow (แสดง error ใน UI เฉยๆ). ต้อง publish + ยิงผ่าน Production URL
- Workflow ที่มี Error Trigger อยู่ในตัวเอง จะ**ใช้ตัวเองเป็น error workflow** โดย default — แต่ในทางปฏิบัติแยกเป็น workflow ต่างหากแล้วตั้งใน Settings ทำงานเสถียรกว่า
- **exit code ไม่ใช่ error**: Execute Command ที่คืน non-zero ไม่ทำให้ n8n error → ต้องเช็ค `stderr` เองด้วย [[Node - IF]] / [[Node - Switch]] แล้วต่อ Stop And Error
- **`Continue` ≠ `Continue (using error output)`**: `Continue` ไปต่อเงียบๆ ด้วย data เก่า ไม่มีสัญญาณอะไรเลย ← สาเหตุของ "node ไม่ output แต่ไม่มี error" ที่หาสาเหตุยากมาก
- Error workflow execution **ไม่นับ quota** (ดู [[Execution]])

## Production design (แนะนำ)
แยกประเภท error:
- **ชั่วคราว** (API timeout, rate limit, network) → Retry On Fail + backoff
- **ถาวร** (data ไม่ valid, credential ผิด) → หยุด + ส่งเข้า review queue

เก็บ context ของ failure ไว้ replay ได้ (`workflow_id`, `step`, `retry_count`, `error`) แทนเก็บแค่ใน execution log และทำ action สำคัญให้ **idempotent** กัน retry ซ้ำ

## Related Patterns
- [[Best Practice - Error Workflow Setup]]
- [[Best Practice - Idempotent Workflows]]
- [[Connection (Main vs Error Output)]]
- [[Troubleshoot - Webhook Not Triggering]]
