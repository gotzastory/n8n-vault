---
tags: [n8n/concept]
type: concept
aliases: []
---

# n8n Expression - $node

## ⚠️ Legacy syntax — เลิกใช้แล้ว
`$node["Node Name"]` เป็น syntax เก่า (deprecated) — n8n เปลี่ยนมาใช้ `$('<node-name>')` แทนแล้ว. เจอ error แปลกๆ ตอนใช้ syntax เก่าปนใหม่ (เช่น "Info for expression missing from previous node") ให้เช็คจุดนี้ก่อน

## Syntax ปัจจุบันที่ใช้แทน
```
{{ $('Node Name').item.json.fieldName }}
{{ $('Node Name').item.json }}
{{ $('Node Name').first() }}
{{ $('Node Name').last() }}
{{ $('Node Name').all() }}
```

## Migration
เจอ `$node["xxx"]` หรือ `$node['xxx']` ที่ไหนใน workflow เก่า → แทนด้วย `$('xxx')` ทั้งหมด แล้วใช้ `.item` / `.first()` / `.last()` / `.all()` ต่อท้ายตามต้องการ ดูรายละเอียดที่ [[Expression Syntax]]

## Related
- [[Expression Syntax]]
- [[n8n Expression - $json]]

## Official Docs
- https://docs.n8n.io/build/work-with-data/transform-data/expression-reference/root
- https://docs.n8n.io/build/work-with-data/reference-data/reference-previous-nodes
