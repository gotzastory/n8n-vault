---
tags: [n8n/node]
type: node
node-type: ai
aliases: []
---

# Node - Basic LLM Chain

## What it does
Root node ที่คุยกับ LLM ตรงๆ — ตั้ง prompt + optional output parser. **ไม่มี memory, ไม่มี tool**

## Chain vs Agent
| | Chain | Agent |
|---|---|---|
| ลำดับการทำงาน | กำหนดตายตัว | LLM ตัดสินใจเอง |
| Memory | **ไม่รองรับ** (chain ทุกตัวใน n8n) | รองรับ |
| Tool | ไม่มี | มี |
| ค่าใช้จ่าย/ความคาดเดาได้ | ถูกกว่า, predictable | แพงกว่า, ยืดหยุ่นกว่า |

> ต้องการบทสนทนาต่อเนื่อง (จำ context เก่า) → ต้องใช้ [[Node - AI Agent]] เท่านั้น

## Chain node ทั้ง 3 ตัวใน n8n
- **Basic LLM Chain** — คุยกับ LLM เปล่าๆ
- **Question and Answer Chain** — ต่อ vector store ผ่าน retriever หรือ Workflow Retriever (สำหรับถามตอบเอกสาร)
- **Summarization Chain** — สรุปข้อความ

## Key Parameters
- **Prompt**:
  - *Take from previous node automatically* — คาด field ชื่อ `chatInput` จาก node ก่อนหน้า
  - *Define below* — พิมพ์ text/expression เอง
- **Require Specific Output Format** → ต่อ output parser: Structured / Item List / Auto-fixing

## Chat Messages (เมื่อต่อ chat model)
เลือก Type:
- **System** — กำหนดบทบาท/น้ำเสียง เช่น `Always respond talking like a pirate`
- **User** — ตัวอย่าง input. รองรับ 3 แบบ: **Text**, **Image (Binary)** (ระบุ Image Data Field Name), **Image (URL)**
  - **Image Details**: Auto / Low (512px, ~65 tokens) / High (crop ละเอียด, ~129 tokens)
- **AI** — ตัวอย่างคำตอบที่คาดหวัง (ใช้คู่ User เพื่อทำ few-shot)

## Use case ที่เหมาะ
- Extract structured data จาก text/รูป (คู่ Structured Output Parser)
- Classify / summarize / rewrite แบบ one-shot
- Step ที่ predictable ใน pipeline ผสม (prompt chaining) — ส่วนที่ต้องตัดสินใจค่อยโยนให้ agent

## Gotcha
- **ค้นเว็บไม่ได้** — ไม่มี tool. ต้องใช้ [[Node - AI Agent]] แล้วต่อ tool ค้นเว็บ
- OpenAI built-in tools (Web Search / File Search / Code Interpreter) ผ่าน Responses API **ใช้กับ Basic LLM Chain ไม่ได้**

## Related
- [[Node - AI Agent]]
- [[Node - Chat Model]]
- [[Node - Vector Store]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/cluster-nodes/root-nodes/n8n-nodes-langchain.chainllm
- https://docs.n8n.io/build/integrate-ai/understand-ai-components/what-chains-do
- https://docs.n8n.io/build/integrate-ai/understand-ai-components/agents-vs-chains
