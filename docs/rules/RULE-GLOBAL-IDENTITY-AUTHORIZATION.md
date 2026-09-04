# Rule name: Identity and authorization ownership

Application: intelligent/file-scoped.  
File patterns: `**/*.{py,ts,tsx,vue,js,mjs,mts,csv,yaml,yml}`.

## Rule

- `auth-service` is the only JWT issuer and ACL authority.
- Services validate user JWTs through `deepidoo-contracts`; never duplicate decode, issuer, claim or JTI logic.
- Services validate module JWTs through `auth-service` introspection.
- Keep current scopes until an explicit migration: platform CRUD uses `resource:read|write|delete`; `play_music_ai` uses `music_ai:read|write`.
- Capability-oriented scopes are the target, not the current contract. Do not introduce them piecemeal without a migration decision.
- Backend authorization is mandatory and authoritative. UI visibility is never a security boundary.
- Keep three concepts separate: permission scopes, commercial licences and organisation feature flags.
- During the current migration, document intended UI scopes but do not require frontend route enforcement unless explicitly requested.
- Every protected API route must expose its required scope in OpenAPI/route metadata or a reusable dependency.
- Every new scope must be registered in `auth-service`, assigned to the intended roles/modules and documented in the owning module contract.
- Default to least privilege. Never grant a wildcard, admin scope or write permission to make a failing request pass.
- Return `401` for missing/invalid identity and `403` for an authenticated principal lacking permission.
