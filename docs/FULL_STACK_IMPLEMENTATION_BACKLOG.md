# Full-Stack Implementation Backlog

This backlog is the source of truth for implementation work. A checked box means code and tests exist, not merely that documentation exists.

## Stage 0 — baseline and safety
- [ ] Add test coverage for every existing control API route.
- [ ] Test traversal/encoded path handling, proxy redirects, request headers and WebSocket behavior.
- [ ] Document the trust boundary for the control API and non-loopback bind addresses.
- [ ] Add Rust formatting and lint checks to CI.
- [ ] Add dependency audit and supported toolchain checks.

## Stage 1 — core admin contracts
- [ ] Introduce versioned config structs with serde serialization/deserialization.
- [ ] Validate config before applying it; reject unknown/invalid modes and invalid listener addresses.
- [ ] Add atomic config writes and backup/restore tests.
- [ ] Add health/readiness output with no secret values.
- [ ] Add structured, redacted audit events.
- [ ] Implement authentication and role checks before network administration is supported.

## Stage 2 — backend site manager
- [ ] CRUD for named site profiles.
- [ ] Route/mount validation and preview.
- [ ] Proxy target validation and upstream health.
- [ ] Explicit apply/reload operation with rollback on invalid config.
- [ ] Integration tests for API status codes and malformed requests.

## Stage 3 — frontend
- [ ] Build typed API client and error model.
- [ ] Connect dashboard to real status endpoint.
- [ ] Connect sites UI to implemented site APIs.
- [ ] Add form validation, loading states, errors and confirmation.
- [ ] Accessibility and responsive browser tests.

## Stage 4 — integrations, in this order
- [ ] DNS provider adapter (choose one provider first).
- [ ] DNS dry-run/change preview, apply and verification.
- [ ] Apache detection/config-test adapter.
- [ ] PHP HTTP development server integration.
- [ ] PHP-FPM/FastCGI integration only after platform behavior is tested.
- [ ] MySQL/MariaDB read-only connectivity diagnostics.
- [ ] Optional protected phpMyAdmin link/proxy to separately installed software.

## Stage 5 — deployment readiness
- [ ] TLS termination and certificate lifecycle.
- [ ] Release matrix, packaging and upgrade/rollback tests.
- [ ] Load tests and resource limits.
- [ ] Security review, threat model and operational documentation.

## Definition of done

For each feature: implementation, unit tests, integration tests where appropriate, documentation, failure behavior, secret redaction, and CI evidence. Do not describe external integrations as implemented until they can be configured and tested end-to-end.
