---
tags: [n8n/deploy]
type: deploy
aliases: []
---

# Deploy - Environment Variables Reference

> Concept + pattern อยู่ที่ [[Environment Variables]] — note นี้เป็น cheat sheet

## Deployment / URL
| Variable | Default | หมายเหตุ |
|---|---|---|
| `N8N_HOST` | `localhost` | |
| `N8N_PORT` | `5678` | **port ภายใน** ไม่ใช่ 443 |
| `N8N_PROTOCOL` | `http` | |
| `N8N_LISTEN_ADDRESS` | `::` | |
| `N8N_EDITOR_BASE_URL` | - | URL ที่ user เข้า editor + ใช้ในอีเมล + SAML redirect |
| `N8N_WEBHOOK_URL` | - | ตั้งเองเมื่ออยู่หลัง proxy (แทน `WEBHOOK_URL` ที่ deprecated) |
| `N8N_PROXY_HOPS` | - | จำนวน reverse proxy |
| `N8N_PATH` | `/` | subpath (ระวังปัญหากับ proxy) |
| `N8N_SSL_CERT` / `N8N_SSL_KEY` | - | ถ้าไม่ใช้ reverse proxy |
| `N8N_ENCRYPTION_KEY` | สุ่มเอง | **ต้องเหมือนกันทุก instance ใน queue mode** |
| `GENERIC_TIMEZONE` | `America/New_York` | สำคัญกับ [[Node - Schedule Trigger]] |

## Database
| Variable | Default |
|---|---|
| `DB_TYPE` | `sqlite` (เลือก `postgresdb`) |
| `DB_POSTGRESDB_HOST/PORT/DATABASE/USER/PASSWORD/SCHEMA` | - |
| `DB_TABLE_PREFIX` | - |
| `DB_POSTGRESDB_POOL_SIZE` | - |

## Executions
| Variable | Default | หมายเหตุ |
|---|---|---|
| `EXECUTIONS_MODE` | `regular` | `queue` = [[Queue Mode]] |
| `EXECUTIONS_TIMEOUT` | `-1` (ปิด) | วินาที |
| `EXECUTIONS_TIMEOUT_MAX` | `3600` | |
| `EXECUTIONS_DATA_SAVE_ON_ERROR/SUCCESS` | `all` | |
| `EXECUTIONS_DATA_SAVE_ON_PROGRESS` | `false` | |
| `EXECUTIONS_DATA_PRUNE` | `true` | |
| `EXECUTIONS_DATA_MAX_AGE` | `336` (ชม.) | |
| `EXECUTIONS_DATA_PRUNE_MAX_COUNT` | `10000` | 0 = ไม่จำกัด |
| `EXECUTIONS_DATA_MAX_DISPLAY_SIZE` | `104857600` | เกินนี้แสดง "too large to display" |
| `N8N_CONCURRENCY_PRODUCTION_LIMIT` | `-1` | จำกัด execution พร้อมกัน |
| `N8N_EXECUTION_DATA_STORAGE_MODE` | `database` | `filesystem`/`s3`/`azure` (s3/azure ต้อง Enterprise) |

## Queue mode
`QUEUE_BULL_REDIS_HOST` (localhost) / `PORT` (6379) / `USERNAME` / `PASSWORD` / `DB` (0) / `TLS` / `TIMEOUT_THRESHOLD` (10000) / `QUEUE_BULL_REDIS_CLUSTER_NODES`
`QUEUE_HEALTH_CHECK_ACTIVE` (false) / `QUEUE_HEALTH_CHECK_PORT` (5678)
`QUEUE_WORKER_LOCK_DURATION` (60000) / `LOCK_RENEW_TIME` (10000) / `STALLED_INTERVAL` (30000) / `MAX_STALLED_COUNT` (1)
`OFFLOAD_MANUAL_EXECUTIONS_TO_WORKERS` (false)
`N8N_GRACEFUL_SHUTDOWN_TIMEOUT` (30 วิ)
Multi-main: `N8N_MULTI_MAIN_SETUP_ENABLED` (ต้องมี license) / `_KEY_TTL` (10) / `_CHECK_INTERVAL` (3)

## Binary data
| Variable | Default |
|---|---|
| `N8N_DEFAULT_BINARY_DATA_MODE` | `default` (memory) → ใช้ `filesystem` / `database` / `s3` / `azure` |
| `N8N_BINARY_DATA_STORAGE_PATH` | `N8N_USER_FOLDER/binaryData` |
| `N8N_PAYLOAD_SIZE_MAX` | 16 (MB) — max payload ของ [[Node - Webhook]] |

## Nodes / Code node
| Variable | Default |
|---|---|
| `NODES_EXCLUDE` | `["n8n-nodes-base.executeCommand","n8n-nodes-base.localFileTrigger"]` |
| `NODES_INCLUDE` | - |
| `NODE_FUNCTION_ALLOW_BUILTIN` | - (`*` = ทั้งหมด) |
| `NODE_FUNCTION_ALLOW_EXTERNAL` | - |
| `N8N_PYTHON_ENABLED` | `true` |
| `N8N_COMMUNITY_PACKAGES_ENABLED` | `true` |
| `N8N_CUSTOM_EXTENSIONS` | - path ของ custom node |
| `NODES_ERROR_TRIGGER_TYPE` | `n8n-nodes-base.errorTrigger` |

## Security / privacy
`N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true`
`N8N_BLOCK_ENV_ACCESS_IN_NODE=true`
`N8N_DIAGNOSTICS_ENABLED=false` (ปิดแล้วใช้ Ask AI ใน Code node ไม่ได้)
`N8N_VERSION_NOTIFICATIONS_ENABLED`
`N8N_ENV_FEAT_ENCRYPTION_KEY_ROTATION` — one-way, backup DB ก่อน

## Proxy
`HTTP_PROXY` / `HTTPS_PROXY` / `ALL_PROXY` / `NO_PROXY`
⚠️ ตัวพิมพ์เล็ก (`http_proxy`) **มี precedence สูงกว่า** ตัวพิมพ์ใหญ่

## `_FILE` suffix
เกือบทุก variable เติม `_FILE` ได้ เพื่อโหลดค่าจากไฟล์ (Docker Secrets / K8s Secrets):
```
DB_POSTGRESDB_PASSWORD_FILE=/run/secrets/db_password
N8N_ENCRYPTION_KEY_FILE=/run/secrets/n8n_encryption_key
```

## Related
- [[Environment Variables]]
- [[Deploy - Docker Compose]]
- [[Deploy - Queue Mode with Redis]]
