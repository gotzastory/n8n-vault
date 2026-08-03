---
tags: [n8n/troubleshoot]
type: troubleshoot
aliases: []
---

# Troubleshoot - Memory Issues on Self-Hosted

## อาการที่บ่งชี้
- **Execution stopped at this node (n8n may have run out of memory while executing it)**
- **Workflow did not finish, possible out-of-memory issue**
- **Problem running workflow** / **Connection Lost** / **503 Service Temporarily Unavailable**
- server log: **FATAL ERROR: Reached heap limit Allocation failed - JavaScript heap out of memory**
- Docker: **exit code 137** / log มีคำว่า `Killed`
- **"Error in ~6-8 วินาที" ทั้งที่รันไปเป็นชั่วโมง** + "The execution was interrupted, so the data was not saved" ← process ถูก kill ไม่ใช่ error จริง

Docker/Cloud restart ให้อัตโนมัติ; npm ต้อง restart เอง

## สาเหตุที่ทำให้กิน memory
- ปริมาณ JSON data
- **ขนาด binary data** ← ตัวการอันดับ 1
- จำนวน node ใน workflow
- **[[Node - Code]]** (และ Function node เก่า) กิน memory หนัก
- **Manual execution กินมากกว่า production** — n8n copy data ไปให้ frontend ด้วย
- workflow อื่นรันพร้อมกัน

## แก้ตามลำดับที่ควรลอง

### 1. ⭐ Binary data mode (ได้ผลมากสุด)
```
N8N_DEFAULT_BINARY_DATA_MODE=filesystem
```
default เก็บใน **memory** → ไฟล์ใหญ่ = ระเบิด
- **Queue mode ใช้ filesystem ไม่ได้** → ใช้ `database` หรือ S3/Azure external storage

### 2. Prune execution data
```
EXECUTIONS_DATA_PRUNE=true
EXECUTIONS_DATA_MAX_AGE=168
EXECUTIONS_DATA_PRUNE_MAX_COUNT=50000
EXECUTIONS_DATA_SAVE_MANUAL_EXECUTIONS=false
```

### 3. เพิ่ม heap ของ Node.js
```
NODE_OPTIONS=--max-old-space-size=4096
```
(หน่วย MB — ตั้งไม่เกิน RAM ที่มีจริง)

### 4. จำกัด concurrency
```
N8N_CONCURRENCY_PRODUCTION_LIMIT=3
```

### 5. แก้ที่ workflow (ยั่งยืนสุด)
- **แบ่ง data เป็น chunk เล็ก**: ดึง 200 แถวต่อรอบ แทน 10,000 แถวรวดเดียว
- **เลี่ยง Code node** — ใช้ built-in node ([[Node - Filter]], [[Node - Aggregate]], Split Out) แทน
- **เลี่ยง manual execution กับ data ใหญ่**
- **แตกเป็น sub-workflow** + ให้ sub-workflow คืน result set เล็กๆ กลับมา
  - ดูขัดแย้งกับสัญชาตญาณ (ต้องเพิ่ม [[Node - Split In Batches]] + Execute Workflow) แต่ได้ผลจริง เพราะ sub-workflow ถือ data แค่ batch ปัจจุบัน จบแล้ว memory ถูกคืน
  - ⚠️ **ปิด "Wait for Sub-Workflow Completion"** ถ้าไม่จำเป็น ไม่งั้น data ยังค้างใน memory อยู่ดี
  - **ย้าย Loop node ไปอยู่ใน sub-workflow** — loop ใน workflow หลักคือจุดที่กิน memory หนัก

### 6. จำกัด memory ของ container
```yaml
n8n-dev:
  mem_limit: 1024m
  cpus: 1
```
กันไม่ให้ container เดียวกิน RAM ทั้งเครื่อง (container จะกินเท่าที่มีถ้าไม่จำกัด)

## Debug: หา node ที่พัง
เปิด **Save Execution Progress** ใน workflow settings → save ผลทีละ node ทำให้รู้ว่าพังตรงไหน (แลกกับ latency เพิ่ม)

เช็ค log ว่าโดน OOM kill จริงไหม:
```bash
docker logs <container> --tail 50 | grep -iE "killed|out of memory"
```

## RAM เท่าไหร่ถึงพอ
| ระดับ | RAM |
|---|---|
| ขั้นต่ำสุด (ทดสอบ) | 2 GB (1 GB ใช้ได้แต่ช้ามาก) |
| production เล็ก | 4-8 GB |
| production กลาง | 8-16 GB |
| production ใหญ่ / binary data หนัก | 16+ GB |

**512 MB ไม่พอสำหรับ n8n ยุคนี้** — AI Agent / LLM node ทำ OOM แน่นอน (มีรายงานจริงจากผู้ใช้บน Render 512MB → ต้องอัปเป็น 2GB)

Memory ขึ้นไป 2 GB ตอนรัน workflow หนักแล้วลงมา 200 MB หลังเสร็จ = **ปกติ** ไม่ใช่ leak

## Related
- [[Binary Data]]
- [[Deploy - Scaling Workers]]
- [[Sub-workflow (Execute Workflow)]]
- [[Node - Split In Batches]]
- [[Environment Variables]]
