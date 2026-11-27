---
tags: [n8n/concept]
type: concept
aliases: []
---

# Environment Variables

## Definition
ตั้งค่า self-hosted n8n instance ผ่าน env var แทนตั้งใน UI — ใช้กับ deployment pipeline อัตโนมัติได้. รองรับผ่าน CLI (`export`, `set`, `$env:`), Docker (`-e`), Docker Compose (`environment:`), หรือ config file

## ที่ใช้บ่อยสุด
| หมวด | ตัวอย่าง variable |
|---|---|
| Deployment/URL | `N8N_HOST`, `N8N_PORT`, `N8N_PROTOCOL`, `N8N_EDITOR_BASE_URL`, `WEBHOOK_URL` |
| Encryption | `N8N_ENCRYPTION_KEY` (ต้องเหมือนกันทุก instance ถ้าใช้ [[Queue Mode]]) |
| Database | `DB_TYPE` (sqlite/postgresdb), `DB_POSTGRESDB_*` |
| Execution | `EXECUTIONS_MODE`, `EXECUTIONS_TIMEOUT`, `EXECUTIONS_DATA_PRUNE`, `EXECUTIONS_DATA_MAX_AGE` |
| Binary data | `N8N_DEFAULT_BINARY_DATA_MODE`, `N8N_BINARY_DATA_STORAGE_PATH` |
| Nodes | `NODES_EXCLUDE`, `NODES_INCLUDE`, `NODE_FUNCTION_ALLOW_BUILTIN/EXTERNAL`, `N8N_COMMUNITY_PACKAGES_ENABLED` |
| Queue mode | `QUEUE_BULL_REDIS_HOST/PORT/PASSWORD` |

## Sensitive data → ใช้ `_FILE` suffix
เกือบทุก variable เติม `_FILE` ต่อท้ายชื่อได้ (เช่น `DB_POSTGRESDB_PASSWORD_FILE`) เพื่อโหลดค่าจากไฟล์แยกแทนแปะ plaintext ตรงๆ — ใช้กับ Docker Secrets / Kubernetes Secrets ได้ตรง

## `<AREA>_MANAGED_BY_ENV` pattern
สำหรับ setting กลุ่มใหญ่ (Instance owner, SSO, Security policy, Log streaming, MCP, Community packages) ต้องเปิด `<AREA>_MANAGED_BY_ENV=true` ก่อน env var ย่อยในกลุ่มนั้นถึงจะมีผล — เปิดแล้ว n8n reapply ค่าทุก startup และ lock UI control ที่เกี่ยวข้องเป็น read-only

## Gotcha
- `N8N_COMMUNITY_PACKAGES_MANAGED_BY_ENV=true` ครั้งแรก จะ **uninstall package ที่ไม่อยู่ใน list** ทันที — เช็ค settings ก่อนเปิด
- `N8N_INSTANCE_OWNER_PASSWORD_HASH` ต้องเป็น bcrypt hash เท่านั้น ใส่ plaintext = login พัง
- ตั้ง `DB_TYPE=postgresdb` แล้ว [[Queue Mode]] จะไม่แนะนำ SQLite เด็ดขาด

## Related
- [[Queue Mode]]
- [[Credential]]
- [[Binary Data]]
- [[Deploy - Environment Variables Reference]]

## Official Docs
- https://docs.n8n.io/deploy/host-n8n/configure-n8n/basic-configuration/use-environment-variables
- https://docs.n8n.io/deploy/host-n8n/configure-n8n/manage-settings-using-environment-variables
