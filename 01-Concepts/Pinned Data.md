---
tags: [n8n/concept]
type: concept
aliases: []
---

# Pinned Data

## Definition
"Pin" data = save output ของ node ไว้ใช้ซ้ำแทนดึงข้อมูลใหม่ทุกครั้งที่ execute ระหว่าง dev — ประหยัดเวลา, ไม่กิน rate limit ของ external service, ทำให้ test ได้ผลลัพธ์เดิมทุกครั้ง (reproducible). **ใช้ได้เฉพาะตอน develop เท่านั้น — production execution ไม่สนใจ pinned data เลย**

## เงื่อนไข
- pin ได้เฉพาะ node ที่มี main output เดียว (error output ไม่นับ)
- **pin ไม่ได้ถ้า output เป็น [[Binary Data]]**

## วิธีใช้
1. รัน node ให้ได้ data ก่อน
2. กด **Pin data** ใน OUTPUT view — ปุ่มจะ disable และมี banner "This data is pinned"
3. Unpin ผ่าน banner เพื่อดึงข้อมูลสดใหม่

## แก้ pinned data ได้
เปลี่ยนค่าใน JSON view ตรงๆ เพื่อจำลอง edge case โดยไม่ต้องยิงจริงจาก external system — หรือ copy data จาก past execution มาวางแทนก็ได้

## รวมกับ Data Mocking
สร้าง mock data ด้วย [[Node - Code]] / [[Node - Set (Edit Fields)]] → edit ให้ตรง edge case → pin ไว้ใช้ซ้ำ = workflow เดียวกันมั่นใจได้ทุกรัน

## Gotcha
- Schedule Trigger เพิกเฉยต่อ pinned data (pin ใช้ได้เฉพาะ manual/development execution ไม่ใช่ตอน trigger จริงแม้ยังไม่ publish)
- อยากได้ pinned data หลายชุดสลับกันทดสอบ (test case) — n8n ยังไม่มี native feature, ต้อง manual edit ทุกครั้ง

## Related
- [[Execution]]
- [[Item (n8n Data Structure)]]
- [[Binary Data]]

## Official Docs
- https://docs.n8n.io/build/work-with-data/pin-and-mock-data
- https://docs.n8n.io/build/work-with-data/pin-and-mock-data#data-pinning
