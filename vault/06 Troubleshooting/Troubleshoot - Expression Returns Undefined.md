---
tags: [n8n/troubleshoot]
type: troubleshoot
aliases: []
---

# Troubleshoot - Expression Returns Undefined

## Symptom
Expression แสดง `undefined` / `[object Object]` / ค่าว่าง หรือขึ้น error เกี่ยวกับ item linking

## 1. `undefined` เฉยๆ
### เช็ค path ให้ตรงจริง
รัน node ต้นทางก่อน แล้วดู **JSON view** ว่าค่าอยู่ตรงไหนจริงๆ:
```
{{ $json.id }}              ← อาจจะจริงๆ อยู่ที่
{{ $json.data.id }}
{{ $json.results[0].id }}
{{ $json.body.city }}       ← webhook payload อยู่ใต้ body
```
webhook: query param อยู่ใต้ `query`, path param อยู่ใต้ `params`, body อยู่ใต้ `body`

### field ชื่อมี dot/อักขระพิเศษ
```
{{ $json['odata.nextLink'] }}     ✅ bracket notation
{{ $json.odata.nextLink }}        ❌ n8n มองเป็น nested
```

### schema drift
source เปลี่ยนชื่อ field → n8n โชว์ expression เป็นสีแดง undefined ให้เห็นทันที ตรวจแล้วแก้ก่อน deploy

## 2. Error: "Info for expression missing from previous node"
`.item` ต้องใช้ **item linking** — มี node กลางทางที่ไม่คืน pairing info
- **[[Node - Code]]**: ต้อง preserve `pairedItem` เอง
- **community/custom node**: ผู้สร้าง node ต้องแก้

**แก้เร็ว**: เลี่ยง `.item` → ใช้ `.first()` / `.last()` / `.all()[index]`

## 3. Error: "Multiple matching items for expression"
เกิดหลัง node ที่รวมหลาย item เป็นตัวเดียว ([[Node - Merge]], [[Node - Aggregate]], Summarize) — n8n ไม่รู้ว่าจะใช้ item ไหน

**แก้**:
- ใช้ `.first()` / `.last()` / `.all()[i]` แทน `.item`
- หรืออ้าง node อื่นที่มีข้อมูลเดียวกันแต่ไม่มีปัญหา multiple match

## 4. ใช้ syntax เก่า `$node["..."]`
**deprecated แล้ว** — เปลี่ยนเป็น:
```
{{ $('Node Name').item.json.field }}
```
ปนกันเก่า/ใหม่ทำให้เกิด error แปลกๆ ที่หาสาเหตุยาก — ดู [[n8n Expression - $node]]

## 5. `[object Object]`
พยายามแสดง object ทั้งก้อนเป็น string:
```
{{ $('Telegram').item.binary.data }}          ❌ คืน object
{{ $('Telegram').item.binary.data.fileName }} ✅
```
binary property เป็น object ที่มี `fileName`, `mimeType`, `fileExtension`, `id` — ดู [[Binary Data]]

## 6. ค่าดูเหมือนถูกแต่ไม่ match ใน [[Node - IF]]
มี space เกิน / case ต่าง / เป็น `null`:
```
{{ $json.status && $json.status.toLowerCase().trim() === 'active' }}
```
+ String comparison ใน IF node **ไม่ต้องใส่ quote** ในช่อง value

## 7. Sub-node resolve เป็น item แรกเสมอ
[[Node - Chat Model]], [[Node - Tool (AI)]] และ sub-node ทั้งหมด: `{{ $json.name }}` คืนชื่อ**แรก**เสมอ ไม่ loop ตาม item

## 8. `$json` ว่างใน [[Node - Code]]
`$json` ใช้ได้เมื่อ mode = **Run Once for Each Item**. mode "Run Once for All Items" ต้องใช้ `$input.all()`

## เครื่องมือช่วย
- ลาก field จาก INPUT panel แทนพิมพ์เอง — n8n gen expression ให้ถูก
- พิมพ์ `.` แล้วรอ autocomplete
- ใช้ `$ifEmpty(value, fallback)` / optional chaining `?.` กัน undefined ล่ม

## Related
- [[Expression Syntax]]
- [[n8n Expression - $json]]
- [[Item (n8n Data Structure)]]
- [[Node - Merge]]
