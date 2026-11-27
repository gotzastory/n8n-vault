---
tags: [n8n/concept]
type: concept
aliases: []
---

# OAuth2 in n8n

## Definition
[[Credential]] แบบ OAuth2 — n8n จัดการ auth flow ให้อัตโนมัติ (ไม่ต้องยิง request ขอ token เองก่อน) เมื่อกด **Connect my account** จะ redirect ไป authenticate แล้วดึง refresh token กลับมาจัดการเองตลอด

## Grant type ที่รองรับ (ผ่าน HTTP Request credential แบบ generic)
| Grant type | ใช้เมื่อ |
|---|---|
| Authorization Code | มาตรฐานที่สุด — user login แล้ว redirect กลับพร้อม code แลก access token |
| PKCE | ต่อยอด Authorization Code กัน CSRF/code injection |
| Client Credentials | app คุยกับ resource ของตัวเอง ไม่ใช่แทน user |

Field ที่ต้องกรอก: Authorization URL, Access Token URL, Client ID/Secret, Scope (ว่าง = ขอทุก scope ที่ client มีสิทธิ์), Authentication (Header vs Body)

## Redirect URL
Copy **OAuth Redirect URL** จาก n8n credential ไปตั้งเป็น callback URL ฝั่ง service นั้น (Google Cloud Console, GitHub OAuth App, Microsoft App Registration ฯลฯ) — ต้องตรงเป๊ะไม่งั้น auth fail

## n8n Cloud vs self-host
- **Cloud**: บาง service ไม่ต้องตั้ง OAuth app เอง กด "Connect my account" ผ่าน browser ได้เลย
- **Self-host**: ต้องสร้าง OAuth app เองในทุก service (Google Cloud Console, Microsoft Entra, GitHub Developer settings ฯลฯ), เอา Client ID/Secret มาใส่ credential

## JWE token decryption (advanced)
บาง IdP ส่ง token แบบเข้ารหัส JWE — เปิดผ่าน `N8N_ENV_FEAT_OAUTH2_JWE=true` แล้ว toggle **Encrypted Tokens (JWE)** ในตัว credential, ใส่ JWKS URI ให้ IdP รู้จัก

## Related
- [[Credential]]
- [[Environment Variables]]

## Official Docs
- https://docs.n8n.io/integrations/builtin/credentials/httprequest#using-oauth2
- https://docs.n8n.io/deploy/host-n8n/configure-n8n/security/decrypt-oauth-20-tokens-with-jwe
