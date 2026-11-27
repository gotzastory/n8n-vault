---
tags: [n8n/concept]
type: concept
aliases: []
---

# Expression Syntax

## Definition
Expression = small JS-like code ใส่ตรง node parameter ผ่าน `{{ ... }}`. ดึงค่าจาก node ก่อนหน้า, workflow metadata, env var แบบ dynamic.

## Common referencing methods
- `$json` — shorthand `$input.item.json`, ดึง JSON ของ item ปัจจุบัน
- `$json.fieldName` — ดึง field เดียว
- `$binary` — shorthand `$input.item.binary`
- `$('<node-name>').item.json` — ดึงจาก [[linked item]] ของ node ก่อนหน้า (ใช้ item linking หาว่าใช้ item ไหน)
- `$('<node-name>').first() / .last() / .all()` — ดึง item แรก/ท้าย/ทั้งหมดของ node ที่ระบุ โดยไม่พึ่ง item linking (กันปัญหา "Multiple matching items")
- `$input.item / $input.first() / $input.last() / $input.all()` — ทำงานกับ input ของ node ปัจจุบันเอง

## Helper functions
- `$if(condition, valueIfTrue, valueIfFalse)`
- `$ifEmpty(value, valueIfEmpty)` — empty = `""`, `[]`, `{}`, `null`, `undefined`
- `$jmespath(obj, expression)` — query JSON ซับซ้อนด้วย JMESPath
- `$now`, `$today`, `$now.toFormat("yyyy-MM-dd")`
- `$fromAI(key, description?, type?, defaultValue?)` — ให้ LLM (AI Agent) เป็นคนเติมค่า parameter นี้แทน

## Expression vs Code node vs AI Transform
| ใช้เมื่อ | เครื่องมือ |
|---|---|
| set ค่า field เดียวจาก data ที่มีอยู่ | Expression |
| เขียน JS/Python เต็มรูปแบบ, restructure data, loop | [[Node - Code]] |
| generate transform code จาก natural language | AI Transform node (cloud only) |

**Best practice**: อย่ายัด expression ซับซ้อนกระจายหลาย node — ใช้ [[Node - Set (Edit Fields)]] เตรียม data ก่อนส่งต่อ

## Gotcha — Item linking error
`.item` fail ถ้า thread ขาด (เช่นหลัง Code node ที่ไม่ preserve pairing) หรือชี้ item หลายตัวพร้อมกัน (หลัง Merge/Aggregate/Summarize) → error "Multiple matching items for expression" หรือ "Info for expressions missing from previous node". แก้โดยใช้ `.first()/.last()/.all()[index]` แทน `.item`.

## Example
```
{{ $json.body.city }}
{{ $('Webhook').item.json.headers.authorization }}
{{ $('First HTTP').item.json.results[0].id }}
```

## Related
- [[n8n Expression - $json]]
- [[n8n Expression - $node]]
- [[Item (n8n Data Structure)]]
- [[Node - Code]]
- [[Node - Set (Edit Fields)]]

## Official Docs
- https://docs.n8n.io/build/work-with-data/reference-data/reference-previous-nodes
- https://docs.n8n.io/build/work-with-data/transform-data/expression-reference
- https://docs.n8n.io/build/work-with-data/reference-data/link-data-items/item-linking-errors
