---
tags: [n8n/pattern]
type: pattern
aliases: []
---

# Pattern - RAG Pipeline in n8n

## Problem
ให้ LLM ตอบจากความรู้เฉพาะขององค์กร (เอกสาร, playbook, API spec) แทนที่จะเดาจาก training data → ลด hallucination

## 2 workflow แยกกัน
### Workflow 1 — Ingest (ยัดข้อมูลเข้า vector store)
```
Trigger (Google Drive Trigger / Form / [[Node - Schedule Trigger]])
  → download file
  → Default Data Loader
       └─ Text Splitter (Recursive Character — แนะนำ)
  → Embeddings node (เช่น OpenAI text-embedding-3-small)
  → [[Node - Vector Store]] (mode = Insert Documents)
```

### Workflow 2 — Query
```
Chat Trigger → [[Node - AI Agent]]
                 ├─ [[Node - Chat Model]]
                 ├─ Window Buffer Memory
                 └─ Vector Store Tool → [[Node - Vector Store]] (mode = Retrieve as Tool)
                                          └─ Embeddings (**ตัวเดียวกับตอน insert**)
```

## Text Splitter
| แบบ | แบ่งตาม |
|---|---|
| Character Text Splitter | จำนวนตัวอักษร |
| **Recursive Character Text Splitter** | Markdown/HTML/code block/ตัวอักษร (แนะนำสำหรับเกือบทุกเคส) |
| Token Text Splitter | จำนวน token |

## 2 วิธี query
1. **ผ่าน agent** (agentic retrieval) — agent ตัดสินใจเองว่าจะค้นเมื่อไหร่. ตั้ง **Name** + **Description** ให้ชัด, ตั้ง **limit** จำนวน chunk, เปิด **Include Metadata**
2. **ผ่าน node ตรงๆ** (mode **Get Many**) — ใช้ทำ semantic search engine โดยไม่ต้องมี agent เลย

## เทคนิคประหยัด token
ใช้ **Vector Store Question Answer Tool** ให้ model ถูกๆ ดึง+สรุปก่อน แล้วส่งผลให้ agent (model แพง)
- ข้อดี: token ลดมาก
- ข้อเสีย: model ที่ตอบไม่เห็น context เต็มของ agent และไม่ส่ง metadata กลับ

## Reranking
เปิด **Rerank Results** บน vector store node แล้วต่อ reranking node → เรียงลำดับผลลัพธ์ใหม่ให้ตรงคำถามขึ้น (ใช้ได้กับ Get Many / Retrieve ทั้ง 2 โหมด)

## Gotchas
- **Embedding model ตอน insert กับ query ต้องเป็นตัวเดียวกัน** ไม่งั้นค้นไม่เจอ
- dimension ของ index ต้องตรงกับ output ของ embedding model
- ใส่ **metadata** ตอน insert (source, date, type) ไว้ filter ทีหลัง
- vector search ไม่เก่งเรื่อง**ความสัมพันธ์** ("ลูกค้าคนไหนคู่กับ ticket ไหน") — เคสนั้นต้องใช้ knowledge graph หรือ database ปกติ
- Production ส่วนใหญ่ผสมหลาย storage: buffer สำหรับบทสนทนาปัจจุบัน + database สำหรับ session history + vector store สำหรับค้นข้ามข้อมูลเก่า

## Multi-domain RAG
แยก vector store/collection ตาม domain แล้วให้ agent เลือกเอง — หรือทำ **RAG sub-agent** เฉพาะเรื่องเอกสาร (มี system prompt + model ของตัวเอง) แล้วให้ agent หลักเรียกใช้

## Related Patterns
- [[Pattern - AI Agent with Tools]]
- [[Pattern - Chatbot Workflow]]
- [[Node - Vector Store]]
