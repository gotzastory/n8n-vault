---
tags: [n8n/concept]
type: concept
aliases: []
---

# Item (n8n Data Structure)

## Definition
ทุก data ที่ไหลระหว่าง node ใน n8n คือ **array ของ item** เสมอ แต่ละ item = object ที่มี key `json` (required) และ `binary` (optional):

```json
[
  {
    "json": { "apple": "beets", "carrot": { "dill": 1 } },
    "binary": {
      "apple-picture": {
        "data": "....",
        "mimeType": "image/png",
        "fileExtension": "png",
        "fileName": "example.png"
      }
    }
  }
]
```

## Node ประมวลผลทีละ item อัตโนมัติ
node รับ array ของ item → loop ประมวลผลทีละตัวเองให้ตามที่ config ไว้ — ไม่ต้องเขียน loop เอง (ยกเว้นใช้ [[Node - Code]])

## Code/Function node พิเศษ
ตั้งแต่ n8n 0.166.0: [[Node - Code]] เติม key `json` ให้อัตโนมัติถ้าลืมใส่ และห่อ array (`[]`) ให้เองถ้าลืม — แต่ถ้าสร้าง custom node เองต้องใส่ `json` key ให้ครบเสมอ

## Data mapping
ลาก field จาก INPUT panel วางลง parameter → n8n gen expression ให้อัตโนมัติ เช่น `{{ $json.fruit }}` — เวลา node loop item แต่ละตัว ค่านี้จะเปลี่ยนไปตาม item ปัจจุบัน

## View data
Node details view มี 3 มุมมอง: **Schema** (โครงจาก item แรกเท่านั้น), **Table**, **JSON** (เห็น dataset เต็ม)

## Related
- [[Expression Syntax]]
- [[Binary Data]]
- [[n8n Expression - $json]]
- [[Node - Code]]

## Official Docs
- https://docs.n8n.io/build/work-with-data/understand-n8ns-data-structure
- https://docs.n8n.io/build/work-with-data/overview
