---
tags: [n8n/pattern]
type: pattern
aliases: []
---

# Pattern - Batch Processing with Split In Batches

## Problem
ต้องประมวลผล item จำนวนมากทีละชุด — เพื่อกัน rate limit, เพื่อบังคับลำดับ, หรือเพราะ node ปลายทางไม่ loop ให้เอง

## ⚠️ ส่วนใหญ่ไม่ต้องใช้
n8n loop ทุก item ให้อัตโนมัติอยู่แล้ว. ใช้ pattern นี้เฉพาะเมื่อ:
- ต้อง throttle กัน rate limit
- node ปลายทางไม่ iterate เอง (RSS Read, MongoDB insert, Redis Info, [[Node - Code]] แบบ Run Once for All Items, Execute Workflow)
- ต้องดึง API แบบไม่รู้จำนวนหน้าล่วงหน้า

## Workflow Shape
```
input → [[Node - Split In Batches]] (Batch Size = N)
          ├─ output "loop" → process → Wait (optional) ──┐
          │                                              │
          │        ┌─────────────────────────────────────┘
          │        └──> ต่อกลับเข้า Split In Batches   ← **สำคัญที่สุด**
          └─ output "done" → [[Node - Aggregate]] → ต่อ
```

## Rules ที่พลาดกันบ่อยที่สุด
1. **ต้องต่อ output ของ node สุดท้ายกลับเข้า Loop node** ไม่งั้นรันแค่ batch แรกแล้วหยุด — สาเหตุอันดับ 1
2. ทุก branch ที่แตกออกจาก loop ต้องวนกลับเข้า loop ให้หมด
3. **ห้ามเปิด Always Output Data** บน Loop node
4. ต่อ output `done` เข้า [[Node - Aggregate]] ถ้าอยากได้ผลรวมทั้งหมด — [[Node - NoOp]] ให้ไม่ได้
5. node ใน loop ที่**เพิ่มจำนวน item** (เช่น insert node คืนหลาย row) ทำให้ item count เพี้ยนและ loop พัง → ปิดท้าย loop ด้วย NoOp เปล่าๆ

## Nested loop = ปัญหา
Loop Over Items เก็บ state ภายใน → loop ซ้อนใน workflow เดียวกันทำงานถูกแค่รอบแรกของ loop นอก

**ทางแก้เรียงตามที่แนะนำ**:
1. แยก loop ในเป็น [[Sub-workflow (Execute Workflow)|sub-workflow]] ← สะอาดสุด
2. Flatten data ก่อน แล้วใช้ loop เดียว
3. (advanced) option **Reset** แบบ expression: `{{ $prevNode.name === 'ชื่อ node ที่ป้อน item เข้ามา' }}` — reset เมื่อ item ชุดใหม่มาถึง แต่ไม่ reset ตอน loop วนเอง

## Expression ที่ใช้บ่อย
```
{{ $("Loop Over Items").context["noItemsLeft"] }}      // หมดหรือยัง
{{ $("Loop Over Items").context["currentRunIndex"] }}  // รอบที่เท่าไหร่
```

## Related Patterns
- [[Pattern - Rate Limiting API Calls]]
- [[Pattern - Polling API (Schedule Trigger)]]
- [[Node - Split In Batches]]
- [[Node - Aggregate]]
