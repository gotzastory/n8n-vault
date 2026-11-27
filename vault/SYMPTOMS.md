---
tags: [symptoms, troubleshooting, index]
---

# Symptom Index (n8n)

หาจากอาการ แล้วเปิดโน้ต / ยิง MCP execution — อย่าเดาแก้จากความจำอย่างเดียว  
รูปแบบ: `อาการ | สาเหตุสั้น | แก้สั้น | [[โน้ต]]`

## Form / binary / multi-file

- form ส่งหลายไฟล์แล้วโหนดถัดไปไม่มี binary | Normalize แยก item แต่ไม่คง binary field | คง binary ใน Code / paired item ถูกต้อง | [[Pattern - Multi-file Slip Intake Node Connections]]
- Merge รวมแล้ว Parse อ่านไฟล์ไม่ได้ | Merge โหมดผิดหรือ binary อยู่คนละ item | ใช้ combineByPosition และตรวจช่อง binary หลัง Merge | [[Workflow - Slip Intake (BGwGhA8N15KGZxj4)]]
- Form completion ไม่ขึ้นสรุป | สาย output ไม่ถึง Form / error กลางทาง | ดู execution โหนดสุดท้ายที่ error | [[Troubleshoot - Expression Returns Undefined]]

## Credentials / HTTP / Maton

- credential auth failed | token หมดอายุ / wrong type / ยังไม่ผูกโหนด | ผูกใหม่ใน n8n UI แล้ว `list_credentials` / details | [[Troubleshoot - Credential Auth Failed]]
- Maton Drive upload ผ่าน แต่ไฟล์ไม่อยู่โฟลเดอร์วัน | อัปโหลดอย่างเดียวไม่ได้ addParents | ต้องมีขั้น Move/Rename หลัง upload | [[Decision - Prefer Maton HTTP for Google Drive upload]] [[Workflow - Slip Intake (BGwGhA8N15KGZxj4)]]
- HTTP 401/403 จาก API ภายนอก | header / bearer / Maton-Connection ผิด | เทียบ Service note + credential ชื่อใน n8n ไม่ใส่ secret ใน vault | [[Service - Thunder Solution]]

## Webhook / LINE / schedule

- webhook ไม่ยิง | URL ผิด, workflow inactive, หรือ path ไม่ตรง | เช็ค active + production URL จาก details | [[Troubleshoot - Webhook Not Triggering]]
- LINE รูปมาทีละภาพ ชุดปะปน | ไม่ group ด้วย imageSet / debounce | ใช้ Data Table + set processor ตาม OCR flow | [[Workflow - LINE Group OCR to Google Sheets]]
- schedule ชนกันสอง workflow | นาที cron ซ้อน | เยื้องนาที (เช่น :00 กับ :30) | [[Workflow - Shopee fal Video Generate]]

## Execution / self-host

- workflow ค้างใน queue | worker/queue mode หรือ wait node | ดู [[Troubleshoot - Workflow Stuck in Queue]] แล้ว execution list
- memory โหมัดตอน binary ใหญ่ | เก็บไฟล์ใหญ่ทั้งก้อนใน item | ใช้ Drive URL / แยก binaryMode | [[Troubleshoot - Memory Issues on Self-Hosted]]
- expression เป็น undefined | อ้างโหนดผิดชื่อ / item ว่างหลัง IF | ตรวจ paired item + `$('Node').item` | [[Troubleshoot - Expression Returns Undefined]]

## MCP loop เมื่อเจออาการใหม่
1. เพิ่มบรรทัดในไฟล์นี้  
2. `search_workflow_executions` + `get_workflow_execution`  
3. แก้ผ่าน MCP หลังอนุมัติ  
4. อัปเดต Known issues / History ใน note ที่เกี่ยว
