---
tags: [n8n/node]
type: node
node-type: ai
aliases: [LLM sub-node]
---

# Node - Chat Model

## What it does
**Sub-node** — จ่าย LLM ให้ root node ([[Node - AI Agent]], [[Node - Basic LLM Chain]], Q&A Chain, Summarization Chain). สลับ provider ได้โดยไม่ต้องรื้อ workflow

## Provider ที่มี node ให้
OpenAI, Anthropic (Claude), Google Gemini, Mistral Cloud, DeepSeek, OpenRouter, Ollama (local), Azure OpenAI, MiniMax, Moonshot Kimi, Qwen Cloud, NVIDIA Nemotron, Lemonade, Groq ฯลฯ

## Parameter ร่วมของเกือบทุกตัว
- **Model** — n8n โหลดรายชื่อ model แบบ dynamic จาก account ของคุณ (เห็นเฉพาะที่มีสิทธิ์)
- **Sampling Temperature** — สูง = หลากหลายขึ้นแต่เสี่ยง hallucinate
- **Top P** — nucleus sampling. **ปรับ Top P หรือ Temperature อย่างใดอย่างหนึ่ง อย่าปรับทั้งคู่**
- **Maximum Number of Tokens** — `-1` = ใช้ default ของ model
- **Frequency Penalty** (ลดการพูดซ้ำ) / **Presence Penalty** (เพิ่มโอกาสพูดเรื่องใหม่)
- **Response Format**: Text / JSON
- **Timeout** (ms) / **Max Retries**

## เฉพาะ provider
- **OpenAI**: toggle **Use Responses API** (แทน Chat Completions) → ปลดล็อก built-in tools: Web Search, File Search, Code Interpreter — **ใช้ได้เฉพาะคู่กับ [[Node - AI Agent]] เท่านั้น ไม่ทำงานกับ Basic LLM Chain**
- **Anthropic**: มี Top K + toggle thinking mode
- **Mistral**: Enable Safe Mode, Random Seed (deterministic)
- **MiniMax**: Hide Thinking (ตัด `<think>` tag ออก, default เปิด)
- **Ollama**: รัน model local ฟรี — เหมาะกับ self-host AI Starter Kit (Ollama + Qdrant + Postgres)

## Gotcha สำคัญของ sub-node ทุกตัว
**Expression ใน sub-node resolve เป็น item แรกเสมอ** — ต่างจาก root node ที่ loop ตามทุก item. input 5 ตัว → `{{ $json.name }}` คืนชื่อแรกเสมอ

## Related
- [[Node - AI Agent]]
- [[Node - Basic LLM Chain]]
- [[Credential]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/cluster-nodes/sub-nodes/n8n-nodes-langchain.lmchatopenai
- https://docs.n8n.io/integrations/builtin/cluster-nodes/sub-nodes/n8n-nodes-langchain.lmchatanthropic
- https://docs.n8n.io/integrations/builtin/cluster-nodes/sub-nodes/n8n-nodes-langchain.lmchatollama
