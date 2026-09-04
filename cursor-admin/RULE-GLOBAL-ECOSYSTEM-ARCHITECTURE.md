# New Age ecosystem architecture

<!-- Copy this file into Cursor → Dashboard → Team Rules. -->
<!-- Suggested name: New Age ecosystem architecture -->
<!-- Application: Always Apply -->
<!-- File patterns: All files -->

**Cursor Admin — Application:** Always Apply  
**Cursor Admin — File patterns:** `All files`

# Rule name: New Age ecosystem architecture


## Rule

- Treat New Age as a workspace of independent Git repositories, never as one build monorepo.
- Read in dependency order: `contracts` → `auth-service` → `platform-api` → business modules.
- `contracts` owns shared data contracts and user-token validation; it is not a runtime service.
- `auth-service` exclusively owns login, JWT issuance, role bindings and ACL evaluation.
- `platform-api` owns shared platform/core resources and exposes them through `/v1/*`.
- A business module owns one independently deployable business capability: its API, its storage and its own production frontend.
- `play` is one production web client, not the single entry point for every capability. Inside `play`, the dependency direction is `play` → `playdoo` → `deesplay`.
- `play` business UI and routes belong in `play/packages/playdoo`; the `play` package remains a thin host. This applies to `play` only, not to module frontends.
- Shared UI primitives belong in `deesplay`; they must not depend on application or business code.
- Inter-service communication uses HTTP APIs and stable identifiers. Never import another service's application code.
- Never access another service's database or create cross-service SQL foreign keys.
- Before creating a new repository, package or top-level directory, identify the owning capability and obtain explicit approval.
