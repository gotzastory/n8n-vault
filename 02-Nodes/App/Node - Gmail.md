---
tags: [n8n/node]
type: node
node-type: action
aliases: []
---

# Node - Gmail

## What it does
จัดการ Gmail — draft, message, label, thread. ใช้เป็น **AI tool** ได้ (ดู [[Node - Tool (AI)]]) และเป็น **human-in-the-loop** step ให้ AI agent ขออนุมัติได้

## Operations
| Resource | Operations |
|---|---|
| **Draft** | Create, Delete, Get, Get Many |
| **Label** | Create, Delete, Get, Get Many |
| **Message** | Send, Reply, Get, Get Many, Delete, Add/Remove Label, Mark as Read/Unread |
| **Thread** | Get, Get Many, Reply, Delete, Trash, Untrash, Add/Remove Label |

## Send options สำคัญ
- **Append n8n attribution** — default **เปิด** ทำให้ท้ายเมลมี `This email was sent automatically with n8n` → ปิดเองใน Options
- **Attachments** — ระบุ **Attachment Field Name (in Input)** ชื่อ field ที่มีไฟล์ (หลายไฟล์ใช้ comma-separated)
- BCC / CC / Sender Name / Send Replies To / Reply to Sender Only

## Gmail Trigger (node แยก)
- Event: **Message Received** (polling ตาม Poll Time)
- **Max Emails per Poll**: default 10, max 50 — เกินกว่านั้นเข้าคิวรอบถัดไป
- Filters: Include Spam and Trash, Label Names/IDs, **Search** (ใช้ syntax Gmail เช่น `from:`), Read Status, Sender
- **Simplify** (default เปิด) — คืนแค่ ID, label, header (From/To/CC/BCC/Subject)
- นับ execution เฉพาะตอนเจอ mail ใหม่ (polling node — ดู [[Execution]])

## Common Issues
| Error | สาเหตุ/วิธีแก้ |
|---|---|
| `Forbidden - perhaps check your credentials?` ตรง dropdown Label | ใช้ Google Service Account แต่ไม่ได้เปิด **Impersonate a User** |
| `401 unauthorized_client` | OAuth2: ยังไม่ enable Gmail API ใน APIs & Services > Library / Service Account: ต้อง enable domain-wide delegation + เพิ่ม Gmail API เข้าไปด้วย |
| `Bad request - please check your parameters` | Message/Thread/Label ID ไม่มีจริง → ลอง Get operation ยืนยันก่อน |

## Gotcha
- **Delete message = ลบถาวรกู้ไม่ได้** — ถ้าอยากกู้ได้ให้ใช้ Thread > **Trash** แทน
- Operation ที่ node ไม่รองรับ → ใช้ [[Node - HTTP Request]] + Predefined Credential Type = Gmail

## Related
- [[Credential]], [[OAuth2 in n8n]]
- [[Node - Tool (AI)]]
- [[Node - HTTP Request]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.gmail
- https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.gmail/common-issues
- https://docs.n8n.io/integrations/builtin/trigger-nodes/n8n-nodes-base.gmailtrigger
