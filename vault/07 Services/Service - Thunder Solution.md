---
type: service
status: reference
tags: [n8n/service, thunder, slip-verification]
---

# Service - Thunder Solution

## Purpose

API ตรวจสอบสลิปธนาคาร (Bank slip verification) สำหรับธนาคารไทย ใช้ตรวจสลิปโอนเงินที่ส่งผ่าน LINE OA โดย **verify ด้วยรูปภาพ** แล้วนำผล (`data.rawSlip`) ไปใช้ต่อ

ใช้ใน workflow: [[Workflow - Income Slip Intake LINE to Thunder]]

## n8n Nodes

- เรียกผ่าน **HTTP Request** node ไปที่ v2 REST API (วิธีที่ใช้ใน workflow นี้)
- หรือใช้ community node `n8n-nodes-thunder` (ใช้ **v1** — ระวัง response ต่างจาก v2)

## Authentication

- Method: `Authorization: Bearer <API_KEY>` (ใน header)
- API Key: รูปแบบ UUID v4 เช่น `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
- Credential n8n: `httpHeaderAuth` (ตั้งชื่อ "Thunder API") — เก็บ key ใน n8n credential, **ห้าม hardcode ใน node หรือเก็บใน note**
- แหล่งรับ key: [Thunder Developer Portal](https://developer.thunder.in.th/)

## Operations Used

ใช้ endpoint หลัก: `POST https://api.thunder.in.th/v2/verify/bank` (verify by image)

| Parameter | ประเภท | จำเป็น | หมายเหตุ |
|---|---|---|---|
| `image` | File | ใช่ | ไฟล์รูปสลิป (multipart) |
| `checkDuplicate` | boolean | ไม่ | ตรวจสลิปซ้ำ |
| `remark` | string | ไม่ | หมายเหตุ 1-255 ตัวอักษร |
| `matchAccount` | boolean | ไม่ | จับคู่ผู้รับกับบัญชีที่ลงทะเบียน |
| `matchAmount` | number | ไม่ | จำนวนเงินที่คาดหวัง |

ข้อกำหนดรูปภาพ: ≤ 4 MB, รูปแบบ JPEG/PNG/GIF/WebP

## Response

```ts
{
  success: true,
  data: {
    rawSlip: {
      transRef: string,
      amount: { amount: number, ... },
      sender: { account: { name: { th, en } }, bank: { name } },
      receiver: { account: { account } | proxy: { account }, bank: { name } }
    },
    isDuplicate, matchedAccount, amountInSlip, ...
  }
}
```

> `data.rawSlip` ตรงกับ node `Parse Slip` ใน workflow

## Gotchas

- **v1 ≠ v2**: community node `n8n-nodes-thunder` ใช้ v1 (`/v1/verify`, output เป็น `data.receiver/amount/...` ไม่ใช่ `data.rawSlip`); v2 ตอบ `data.rawSlip` จึงเข้ากับ `Parse Slip` เดิม
- **Duplicate = HTTP 409** error `{ success:false, error:{ code:"duplicate_slip" } }` (ไม่ใช่ success + `isDuplicate`)
- field สำหรับ upload รูปภาพคือ **`image`** (ไม่ใช่ `file`)
- **บัญชีผู้รับประเภท BILLERID (PromptPay บริษัท) ถูก mask**: response ให้ `receiver.account.proxy.account = "XXXXXXXXXXX8809"` (แสดง 4 ตัวท้าย) — **ไม่มีเลขบัญชีจริง** และ proxy ซ้อนอยู่ใน `receiver.account` ไม่ใช่ `receiver.proxy`; เวลาทำ allow-list ต้องเช็คจาก proxy suffix หรือชื่อบัญชีแทนเลขบัญชี (พิสูจน์จาก execution จริง 2026-09-09)
- การ validate: `mermaid MCP` / `n8n-kapa` ใช้ค้นข้อมูลทางการ

## Related Workflows

- [[Workflow - Income Slip Intake LINE to Thunder]]
- [[Node - Line Messaging]]

## Official / Reference

- https://document.thunder.in.th/th/v2/verify/bank/image
- https://document.thunder.in.th/th/guide/authentication
- https://document.thunder.in.th/th/reference/error-codes

> ห้ามเก็บ API Key / Bearer token ในไฟล์นี้
> อ้างอิง node type definitions จาก n8n MCP ก่อนสร้างหรือแก้ไข workflow
