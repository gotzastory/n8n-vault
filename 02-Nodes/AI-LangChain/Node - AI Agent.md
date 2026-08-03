---
tags: [n8n/node]
type: node
node-type: ai
aliases: [Tools Agent]
---

# Node - AI Agent

## What it does
**Root node** ของ cluster — ต่อ chat model + tool อย่างน้อย 1 ตัว แล้ว agent ตัดสินใจเองว่าจะเรียก tool ไหนเพื่อทำงานให้เสร็จ

Agent = chain ที่ตัดสินใจเองได้: chain รันตามลำดับที่กำหนดไว้ตายตัว ส่วน agent ใช้ LLM เลือกว่าจะทำอะไรต่อ

## Agent type
ตั้งแต่ **n8n 1.82.0** ตัวเลือก agent type ถูกเอาออกแล้ว — ทุก AI Agent node ทำงานเป็น **Tools Agent** ทั้งหมด (ซึ่งเป็นตัวที่แนะนำและใช้กันมากที่สุดอยู่แล้ว). workflow เก่าที่ตั้งเป็น Tools Agent ยังทำงานเหมือนเดิม

## Sub-node ที่ต่อได้
| ประเภท | หมายเหตุ |
|---|---|
| Chat Model | **บังคับ** — ดู [[Node - Chat Model]] |
| Tool | **บังคับอย่างน้อย 1 ตัว** — ดู [[Node - Tool (AI)]] |
| Memory | ได้ **1 ตัวต่อ agent** เท่านั้น |
| Output Parser | เมื่อเปิด Require Specific Output Format |

## Key Parameters
- **Source for Prompt (User Message)**: Connected Chat Trigger Node / Define below
- **Require Specific Output Format** → ต่อ output parser (Structured / Item List / Auto-fixing)
- **Enable Fallback Model**: ต่อ chat model สำรองเผื่อตัวหลักล่ม

## Node options
- **System Message** — prompt กำหนดบทบาท/น้ำเสียง/ข้อจำกัด
- **Max Iterations** — กันวนไม่จบ
- **Return Intermediate Steps**
- **Automatically Passthrough Binary Images**
- **Batch Processing**: Batch Size + Delay Between Batches (กัน rate limit)

## Multi-agent (AI Agent Tool node, ตั้งแต่ 1.103.0)
ต่อ **AI Agent Tool** sub-node เข้ากับ agent หลัก → agent หลักสั่งงาน agent ย่อยได้ใน execution เดียว บน canvas เดียว (ต่างจาก [[Sub-workflow (Execute Workflow)|sub-workflow]] ที่แยก execution)
- **agent หลักไม่ส่ง execution context เต็มให้ agent ย่อย** — ต้องใส่ context ที่จำเป็นลงใน prompt เอง
- ซ้อนหลายชั้นได้

## Gotcha
- Agent **รันหลายรอบต่อ 1 execution** (setup → เรียก tool → ประเมินผล → ตอบ) — ดู log ตามลำดับนี้
- output ของ agent อยู่ที่ key `output` เสมอ (`{{ $json.output }}`)
- **n8n AI Agent ไม่ได้ใช้ LangChain แล้ว** — ใช้ระบบ agent ภายในของ n8n เอง เน้น tool-calling + workflow orchestration. เก่งเรื่อง multi-step reasoning/ใช้ n8n node เป็น tool แต่ไม่ลึกเท่า LangGraph/CrewAI เรื่อง long-term memory และ full autonomy
- Sub-node **resolve expression เป็น item แรกเสมอ** (ไม่ loop ตาม item เหมือน node ปกติ)
- Queue mode: sub-workflow tool รันบน worker เดียวกับ parent (ดู [[Queue Mode]])

## Related
- [[Node - Chat Model]]
- [[Node - Tool (AI)]]
- [[Node - Vector Store]]
- [[Node - Basic LLM Chain]] (ไม่มี memory/tool)
- [[Pattern - AI Agent with Tools]]
- [[Pattern - RAG Pipeline in n8n]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/cluster-nodes/root-nodes/n8n-nodes-langchain.agent
- https://docs.n8n.io/build/integrate-ai/understand-ai-components/what-agents-do
- https://docs.n8n.io/integrations/builtin/cluster-nodes/sub-nodes/n8n-nodes-langchain.toolaiagent
