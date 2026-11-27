---
tags: [n8n/concept]
type: glossary
aliases: []
---

# Glossary

> อ้างอิงจาก [n8n Key concept glossary](https://docs.n8n.io/key-concept-glossary) + [Terminology guide](https://docs.n8n.io/contribute/terminology)

## Core
| คำ | ความหมาย |
|---|---|
| **workflow** | collection ของ node ที่เชื่อมกันเพื่อ automate process → [[Workflow]] |
| **node** | building block — entry point ดึงข้อมูล / ฟังก์ชันประมวลผล / exit ส่งออก → [[Node]] |
| **execution** | การรัน workflow 1 ครั้ง → [[Execution]] |
| **item** | 1 data point ที่ไหลระหว่าง node (array ของ object มี key `json`/`binary`) → [[Item (n8n Data Structure)]] |
| **canvas** | พื้นที่หลักใน editor ที่วาง/ต่อ node |
| **connection** | เส้นเชื่อม output → input → [[Connection (Main vs Error Output)]] |
| **expression** | โค้ด JS-like ใน `{{ }}` ที่ใส่ใน parameter → [[Expression Syntax]] |
| **credential** | ข้อมูล auth ที่เก็บเข้ารหัสใน n8n → [[Credential]] |

## Node types
| คำ | ความหมาย |
|---|---|
| **trigger node** | node ที่เริ่ม workflow ตาม condition — production workflow ต้องมีอย่างน้อย 1 → [[Trigger vs Action Node]] |
| **app node** | node ที่ต่อกับ service ภายนอกเฉพาะเจาะจง |
| **core node** | node ที่ให้ logic/scheduling/generic API call |
| **cluster node** | กลุ่ม node ที่ทำงานร่วมกัน = **root node** + **sub-node** |
| **root node** | node หลักของ cluster ที่นิยาม functionality (เช่น [[Node - AI Agent]]) |
| **sub-node** | node ที่ต่อเข้า root node เพื่อขยายความสามารถ (chat model, memory, tool) |
| **community node** | node ที่ชุมชนสร้างและ publish เป็น npm package |
| **credential-only node** | มี credential ให้ใช้กับ HTTP Request node แต่ไม่มี node แยก |

## AI
| คำ | ความหมาย |
|---|---|
| **AI agent** | ระบบ AI ที่ตอบสนอง ตัดสินใจ และทำงานจริง ใช้ LLM ตีความ input → [[Node - AI Agent]] |
| **AI chain** | เรียก component ต่อกันเป็นลำดับที่กำหนดไว้ — **ไม่มี memory** → [[Node - Basic LLM Chain]] |
| **AI tool** | resource เสริมที่ AI เรียกใช้เพื่อเข้าถึงข้อมูล/ทำ action → [[Node - Tool (AI)]] |
| **completion** | คำตอบที่ model สร้างออกมา |
| **embedding** | การแทนข้อมูลด้วย vector ตัวเลข |
| **vector store** | database ที่เก็บ embedding ค้นด้วยความหมาย → [[Node - Vector Store]] |
| **RAG** | Retrieval-Augmented Generation — ดึงเอกสารจริงมาประกอบคำตอบ → [[Pattern - RAG Pipeline in n8n]] |
| **reranking** | จัดลำดับผลลัพธ์ที่ค้นมาใหม่ให้ตรงคำถามขึ้น |
| **groundedness** | ระดับที่คำตอบสะท้อนข้อมูลต้นทางจริง (ตรงข้าม = hallucination) |
| **hallucination** | LLM แต่งข้อมูลที่ไม่มีจริง |
| **AI memory** | เก็บ context ข้ามข้อความ — agent ใช้ได้ chain ใช้ไม่ได้ |

## Platform
| คำ | ความหมาย |
|---|---|
| **instance** | n8n ที่ติดตั้ง 1 ชุด |
| **project** | แยก workflow/variable/credential เป็นกลุ่มเพื่อจัดการ/แชร์ในทีม |
| **environment** | instance + config + Git branch ที่ผูกกัน → [[Deploy - Backup & Version Control of Workflows]] |
| **template** | workflow สำเร็จรูปที่ import ได้ |
| **data pinning** | freeze output ของ node ไว้ใช้ซ้ำตอน dev → [[Pinned Data]] |
| **queue mode** | โหมด scale ที่แยก main กับ worker ผ่าน Redis → [[Queue Mode]] |
| **sub-workflow** | workflow ที่ถูกเรียกจาก workflow อื่น → [[Sub-workflow (Execute Workflow)]] |
| **data table** | ตารางเก็บข้อมูลข้าม execution ในตัว n8n |

## ⚠️ ใช้คำให้ตรง (n8n terminology)
| ✅ ใช้ | ❌ อย่าใช้ |
|---|---|
| workflow | flow, automation, scenario, pipeline, zap |
| node | step, block, module |
| execution | run (นาม), job |
| **publish / unpublish** | activate, deactivate, enable, deploy |
| pin data | mock data, freeze data, sample data |
| sub-workflow | subworkflow, subflow, child workflow |
| self-hosted / n8n Cloud | on-prem / SaaS |
| **n8n** (พิมพ์เล็กเสมอ) | N8N, N8n |

## Related
- [[MOC - n8n Knowledge Base]]
- [[Best Practice - Naming Convention for Nodes]]
