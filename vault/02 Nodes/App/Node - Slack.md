---
tags: [n8n/node]
type: node
node-type: action
aliases: []
---

# Node - Slack

## Operations
| Resource | Operations |
|---|---|
| **Message** | Send, **Send and Wait for Response**, Update, Delete, Search, Get Permalink |
| **Channel** | Create, Get, Get Many, History, Replies, Invite, Join, Leave, Kick, Member, Open, Close, Rename, Archive, Unarchive, Set Purpose, Set Topic |
| **File** | Get, Get Many, Upload |
| **Reaction** | Add, Get, Remove |
| **User** | Get, Get Many, Get Profile, Get Status, Update Profile |
| **User Group** | Create, Update, Enable, Disable, Get Many |
| **Star** | Add, Delete, Get Many |

## Credential: เลือกให้ถูก
| วิธี | Slack node | Slack Trigger |
|---|---|---|
| **OAuth2** | ✅ แนะนำ | ❌ ใช้ไม่ได้ |
| **API access token** (Bot User OAuth Token) | ใช้ได้แต่ไม่แนะนำ | ✅ **บังคับ** |

สร้าง Slack app แนะนำใช้ **From a manifest** (JSON) — ตั้ง scope + redirect URL ครบในขั้นเดียว. Scope ต้องตรงกับ operation ที่จะใช้ (ตาราง mapping resource→Slack API method อยู่ใน docs)

## Slack Trigger
Events: Any Event, App Home Opened, Bot/App Mention, File Made Public, File Shared, New Message Posted to Channel, New Public Channel Created, New User, Reaction Added

- **Watch Whole Workspace**: ⚠️ กิน 1 execution ต่อทุก event ในทุก channel ที่ bot อยู่ — ระวัง
- **Channel to Watch**: From list / By ID / By URL
- Options: Resolve IDs, Usernames to ignore, **Emoji Names to Filter** (comma-separated ไม่ใส่ colon เช่น `thumbsup, eyes`)
- **Slack ให้ตั้ง Request URL ได้ URL เดียวต่อ app** — ทดสอบด้วย Test URL ก่อน แล้วค่อยเปลี่ยนเป็น Production URL
- ควรใส่ **Signature Secret** (จาก Settings > Basic Information) เพื่อ verify request

## Approvals in Slack (preview)
Operation **Send and Wait for Response** + **Response Type = Approval** → กดอนุมัติได้ในSlack เลย ไม่เปิด browser

ต้องมี:
- n8n เข้าถึงได้จาก internet ผ่าน HTTPS (localhost ใช้ไม่ได้ — Slack ต้อง callback กลับ)
- **Signature Secret** ใน credential (ไม่มี = ปุ่มขึ้นแต่กดแล้ว workflow ไม่เดินต่อ)
- scope `users:read` + `users:read.email` (ขาด = output ไม่มี email). credential OAuth2 เก่าต้อง reconnect เพื่อรับ scope ใหม่

ต่างจาก link button แบบเดิม: จำกัดผู้อนุมัติได้จริง + output บอกว่าใครกด (ID/name/username/email) + verify ว่ามาจาก Slack จริง

## Gotcha
- **Markdown**: เปิด option Markdown เพื่อจัดรูปแบบข้อความ (`*bold*`, `> quote`, `:emoji:`)
- Node นี้ใช้เป็น human-in-the-loop step ให้ [[Node - AI Agent]] ได้
- operation ที่ไม่มี → [[Node - HTTP Request]] + Predefined Credential Type = Slack

## Related
- [[Credential]], [[OAuth2 in n8n]]
- [[Node - AI Agent]], [[Node - Tool (AI)]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.slack
- https://docs.n8n.io/integrations/builtin/credentials/slack
- https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.slack/approvals
