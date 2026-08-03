---
tags: [n8n/node]
type: node
node-type: core
aliases: []
---

# Node - Code

## What it does
เขียน JavaScript หรือ Python รันเป็น step หนึ่งใน workflow — ใช้เมื่อ [[Expression Syntax|expression]] ไม่พอ (restructure array/object, aggregate, custom algorithm). แทนที่ Function/Function Item node ตั้งแต่ n8n 0.198.0 (ของเก่าถูกลบใน v3.0)

## Mode
- **Run Once for All Items** (default) — code รันครั้งเดียว ไม่ว่ามี input กี่ item. เข้าถึงทุก item ผ่าน `$input.all()`
- **Run Once for Each Item** — รันซ้ำต่อ item, ใช้ `$json` ได้ตรงๆ

## JavaScript
- รองรับ Promise (return promise ได้เลย), `console.log` (ดูใน browser console)
- **Cloud**: import npm module ภายนอกไม่ได้ — มีให้แค่ `crypto` (Node.js) กับ `moment`
- **Self-host**: เปิด `NODE_FUNCTION_ALLOW_BUILTIN` / `NODE_FUNCTION_ALLOW_EXTERNAL` ใน [[Environment Variables]] เพื่อ import module เพิ่มได้

## Python (Native, ตั้งแต่ 1.111.0 / stable ใน v2)
ต่างจาก Pyodide เดิม:
- รองรับแค่ `_items` (all-items mode) และ `_item` (per-item mode) — **ไม่มี** built-in variable อื่นของ n8n
- **ใช้ bracket notation เท่านั้น**: `item["json"]["my_field"]` ไม่ใช่ `item.json.myField`
- deny insecure built-ins by default
- Cloud: import library ใดไม่ได้เลย (แม้ standard library)

## Return format
ต้องคืน array ของ item ที่มี key `json`:
```javascript
return [{ json: { totalBooked, bookedSum } }];
```
ตั้งแต่ 0.166.0 Code node เติม `json` key + ห่อ array ให้อัตโนมัติถ้าลืม (ดู [[Item (n8n Data Structure)]])

## Common Gotchas
- **เปิด "Execute Once" ใน Settings แล้วจะได้ item แรกตัวเดียว** — คนละอย่างกับ mode "Run Once for All Items" ทำ debug งงบ่อยมาก (พฤติกรรมเปลี่ยนใน v2)
- ต่อ 2 input เข้า Code node เดียว → **รัน 2 รอบแยกกัน** ไม่ได้รวมให้. ต้องการรวมต้องใช้ [[Node - Merge]] ก่อน
- [[Binary Data]]: ใช้ `this.helpers.getBinaryDataBuffer(itemIndex, propertyName)` เท่านั้น (ไม่รองรับใน Python)
- Code node ที่ไม่ preserve pairing ทำให้ `.item` พังใน node ถัดไป — ดู [[Expression Syntax]]
- `$getWorkflowStaticData()` ไม่ persist ตอน test — ต้อง publish + trigger จริงถึงจะ save

## Related
- [[Expression Syntax]]
- [[Item (n8n Data Structure)]]
- [[Node - Set (Edit Fields)]]
- [[Binary Data]]
- [[Node - Split In Batches]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.code
- https://docs.n8n.io/build/code-in-n8n/use-built-in-shortcuts
- https://docs.n8n.io/build/code-in-n8n/cookbook/code-node
