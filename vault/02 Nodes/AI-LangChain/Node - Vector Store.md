---
tags: [n8n/node]
type: node
node-type: ai
aliases: []
---

# Node - Vector Store

## What it does
เก็บ/ค้นข้อมูลเป็น **vector** (embedding) — ค้นด้วย *ความหมาย* ไม่ใช่ keyword. เป็นฐานของ **RAG** (Retrieval-Augmented Generation)

## Provider ที่มี node
Simple Vector Store (in-memory), Pinecone, Qdrant, Supabase, Weaviate, Azure AI Search, PGVector, Milvus, MongoDB Atlas

## Operation Mode (5 โหมด)
| Mode | ใช้เมื่อ |
|---|---|
| **Insert Documents** | ยัด document ใหม่เข้า vector store |
| **Get Many** | ค้นด้วย prompt → คืน document ที่คล้ายที่สุดพร้อม similarity score (ใช้เป็น node ธรรมดาได้เลย) |
| **Retrieve Documents (As Vector Store for Chain/Tool)** | ต่อกับ retriever node → ป้อนให้ chain |
| **Retrieve Documents (As Tool for AI Agent)** | ให้ [[Node - AI Agent]] เรียกใช้เป็น tool — ต้องตั้ง **Name** + **Description** ให้ LLM รู้ว่าเมื่อไหร่ควรใช้ |
| **Update Documents** | อัปเดตตาม ID |

**Rerank Results**: เปิดแล้วต้องต่อ reranking node — ใช้ได้กับ Get Many / Retrieve ทั้ง 2 แบบ

## Sub-node ที่ต้องต่อ
| Sub-node | ทำอะไร |
|---|---|
| **Embeddings** | แปลง text → vector (เช่น Embeddings OpenAI `text-embedding-3-small`) — **ต้องใช้ model เดียวกันทั้งตอน insert และตอน query** |
| **Default Data Loader** | ดึงเนื้อหาจากไฟล์/data แล้วแบ่ง chunk |
| **Text Splitter** | Character / **Recursive Character** (แนะนำ) / Token Text Splitter |

## Pipeline RAG มาตรฐาน
```
[ingest]  Trigger → download file → Default Data Loader (+Text Splitter)
          → Embeddings → Vector Store (Insert Documents)

[query]   Chat Trigger → AI Agent
          ├─ Chat Model
          ├─ Memory (Window Buffer)
          └─ Vector Store Tool → Vector Store (Retrieve as Tool) → Embeddings (ตัวเดิม)
```

## 2 วิธี query
1. **ผ่าน agent**: ต่อ vector store เป็น tool + ใส่ description ชัดๆ + ตั้ง **limit** (จำนวน chunk) + เปิด **Include Metadata**
2. **ผ่าน node ตรงๆ**: mode **Get Many** ใส่ prompt + limit — ใช้ทำ semantic search engine ได้โดยไม่ต้องมี agent

## Pro tip ประหยัด token
ใช้ **Vector Store Question Answer Tool** ดึง+สรุปด้วย model ถูกๆ ก่อน แล้วค่อยส่งผลให้ agent (model แพง) — แลกกับการที่ model ตอบคำถามไม่เห็น context เต็มของ agent

## Gotcha
- Embedding model ตอน insert กับตอน query **ต้องตรงกัน** ไม่งั้นค้นไม่เจอ
- `vectorSearchDimensions` ของ index ต้องตรงกับ output dimension ของ embedding model
- ใส่ **metadata** ตอน insert ไว้ filter ทีหลังจะดีมาก
- Description ของ tool คือสิ่งที่ LLM ใช้ตัดสินใจว่าจะเรียกหรือไม่ — เขียนให้เฉพาะเจาะจง

## Related
- [[Node - AI Agent]]
- [[Node - Tool (AI)]]
- [[Pattern - RAG Pipeline in n8n]]
- [[Node - Basic LLM Chain]] (Q&A Chain)

## Official Docs
- https://docs.n8n.io/build/integrate-ai/understand-ai-components/retrieve-relevant-context
- https://docs.n8n.io/build/integrate-ai/understand-ai-components/store-and-search-data-with-vectors
- https://docs.n8n.io/integrations/builtin/cluster-nodes/root-nodes/n8n-nodes-langchain.vectorstorepinecone
