---
tags: [n8n/concept]
type: concept
aliases: []
---

# n8n Expression - $json

## Definition
`$json` = shorthand ของ `$input.item.json` — คืน JSON data ของ **item ปัจจุบัน** ที่ node กำลังประมวลผลอยู่ (ทำงานถูกต้องเมื่อ node รันแบบ "run once for each item")

## ตัวอย่าง
```
{{ $json.city }}
{{ $json.body.city }}     // จาก webhook payload
{{ $json.fieldName }}
```

## ใช้ยังไง
- ลาก field จาก INPUT panel มาวางในพารามิเตอร์ → n8n gen `{{ $json.xxx }}` ให้อัตโนมัติ
- ใช้ได้ทั้งใน expression field และใน [[Node - Code]] (JS: `$json`, Python: `_json`)

## ต่างจาก $input
- `$json` = current item's json เท่านั้น
- `$input.item` / `$input.all()` / `$input.first()` / `$input.last()` = ยืดหยุ่นกว่า เข้าถึง item อื่นในชุดเดียวกันได้

## ต่างจากดึงจาก node อื่น
`$json` ดึงจาก input ของ**node ปัจจุบัน**เท่านั้น — จะดึงจาก node ก่อนหน้าที่ไม่ใช่ node ติดกัน ต้องใช้ `$('<node-name>').item.json` แทน (ดู [[Expression Syntax]])

## Related
- [[Expression Syntax]]
- [[Item (n8n Data Structure)]]
- [[n8n Expression - $node]]

## Official Docs
- https://docs.n8n.io/build/work-with-data/transform-data/expression-reference/root#dollarjson
- https://docs.n8n.io/build/work-with-data/reference-data/reference-previous-nodes
