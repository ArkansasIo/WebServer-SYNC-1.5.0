# Feature Audit and Full-Stack Roadmap

**Audit scope:** repository tree and current `main` source, including the CLI, Rust library, browser control panel, proxy/file-serving code, and CI workflow.

**Current product boundary:** WebServer SYNC 1.5.0 is a developer server and browser live-reload utility. It is not currently a general-purpose hosting control panel, authoritative DNS server, database administration system, or production web-server replacement. This document distinguishes existing behavior from proposed work.

## 1. Current feature inventory

| Area | Present in repository | Missing or limited |
|---|---|---|
| HTTP server | Rust/Hyper-based listener; static directory serving | Production hardening, comprehensive operational controls, compatibility and load testing |
| Reverse proxy | HTTP/HTTPS proxy target, response and redirect adjustments | A full virtual-host/site manager, proxy policy UI, robust production routing policy |
| Static files | Directory mounts, embedded error/listing pages, HTML live-reload injection | File upload/editor, file permissions UI, backup/restore, deploy/rollback |
| Browser client | TypeScript source and checked-in generated JavaScript; reload and overlay messaging | Rich browser developer console, diagnostics, asset/build pipeline management |
| Control panel | Embedded mobile-friendly HTML panel, status, mounts, reload, message overlay, shutdown | Authentication, users/roles, persistent settings, configurable navigation/menu, audit log |
| API | Versioned status/reload/message/shutdown endpoints | API authentication/authorization, rate limits, CSRF/origin policy, API schema and integration tests |
| File watching | Watch mounts and additional paths; configurable debounce | Watch health visibility, ignore patterns, per-project profiles, recovery reporting |
| DNS | Can print a configured public host; README documents wildcard-DNS testing patterns | DNS record editor, zones, registrar/provider integration, authoritative DNS service, DNS health checks |
| PHP | Can proxy to a separately running HTTP server | PHP-FPM/FastCGI adapter, PHP runtime manager, Composer lifecycle, PHP-specific diagnostics |
| Apache | Can proxy to an HTTP endpoint, including a separately running Apache server | Apache configuration manager, module/vhost management, service lifecycle integration |
| Database / phpMyAdmin | No database service or admin UI identified in the repository tree | MySQL/MariaDB integration, credentials/secrets management, phpMyAdmin deployment and access controls |
| TLS | Proxy targets can use HTTPS; advertised URLs are currently constructed with `http://` | Native inbound TLS, certificate lifecycle/ACME, HTTPS redirect and HSTS configuration |
| Operations | CLI logging and CI build/test workflow | Structured access logs, metrics, health/readiness endpoints, graceful lifecycle management, deploy packaging |
| Platform installers | Android/iOS-oriented install guides and PowerShell helpers | Reproducible cross-platform release matrix and end-to-end installer tests |

This is a source-tree audit, not a claim that every runtime path has been exhaustively tested.

## 2. Suggested architecture

Keep the existing Rust development server as the lightweight core. Add optional, separately testable modules instead of embedding every hosting product into the request handler.

```text
WebServer SYNC
├── Core HTTP runtime
│   ├── Static files and mounts
│   ├── Reverse proxy and WebSocket forwarding
│   ├── Live reload / browser client
│   └── Versioned local control API
├── Control plane (new)
│   ├── Configuration profiles and validation
│   ├── Navigation/menu registry
│   ├── Site / virtual-host registry
│   ├── Logs, health and metrics
│   └── Authentication, roles and audit events
├── Optional integrations (new)
│   ├── DNS provider adapters (API-backed)
│   ├── Apache adapter (external service/config validation)
│   ├── PHP adapter (PHP-FPM/FastCGI or an HTTP PHP dev server)
│   └── Database adapter (MySQL/MariaDB connection metadata)
└── Web UI (expand existing panel)
    ├── Overview
    ├── Sites and routes
    ├── DNS zones and records
    ├── PHP / Apache integrations
    ├── Databases / phpMyAdmin link
    ├── Logs and diagnostics
    └── Settings, users and permissions
```

The UI must not directly run shell commands or hold provider/database passwords. Privileged actions should go through a narrow API with authorization, input validation, explicit confirmation for destructive actions, and redacted logs.

## 3. DNS management design

DNS editing requires an explicit operating model; it is not provided by the current `--public-host` option.

1. **Provider-managed DNS (recommended first):** implement provider adapters for APIs such as Cloudflare or another selected DNS host. Manage A, AAAA, CNAME, TXT, MX, and supported SRV records, with provider capability checks.
2. **Zone workflow:** list zones; inspect records; create, update, and delete records; validate record names, types, TTL and content; show a diff and require confirmation before applying changes.
3. **Safety:** least-privilege API tokens, secret storage outside version control, redaction, audit events, pagination, rate-limit handling, and dry-run mode where the provider supports it.
4. **Verification:** query public resolvers after changes, report propagation as pending/observed rather than guaranteeing a global completion time, and distinguish authoritative answers from cached recursive responses.
5. **Authoritative DNS:** treat this as a separate optional service, not as a small feature in the HTTP server. It needs zone storage, DNS protocol handling, delegation/glue guidance, DNSSEC strategy, abuse controls, backups, and dedicated security review.

The existing `--public-host` option only affects advertised URLs and proxy redirect rewriting; it does not create or modify DNS records.

## 4. PHP, Apache, MySQL and phpMyAdmin integration

### PHP
- Initial option: run PHP through an existing HTTP development server and use proxy mode.
- Hosting option: add a dedicated FastCGI/PHP-FPM adapter with socket/endpoint configuration, request method and body forwarding, script-path resolution, upload limits, timeout controls and integration tests.
- Provide PHP version/runtime detection and Composer diagnostics only if a PHP executable/runtime is configured.
- Do not execute PHP source as static text.

### Apache
- Initial option: run Apache independently and proxy to its HTTP listener.
- Optional adapter: detect configured Apache binaries, validate configuration with Apache's own config-test command, display service status and manage named virtual-host templates. Never rewrite user configuration silently; show diffs and keep backups.
- Avoid competing for the same listener ports. Document which process owns each port.

### MySQL/MariaDB and phpMyAdmin
- Treat the database as an external dependency or separately provisioned service.
- Offer connection health checks, schema/database metadata, and a link or reverse-proxy mount for an existing phpMyAdmin installation.
- phpMyAdmin is a separate PHP application, not a Rust module. Do not bundle it without tracking its license, update lifecycle, supported PHP versions and security advisories.
- Require authentication and network restrictions before exposing database administration. Do not place database credentials in frontend JavaScript, sample configs, logs, or Git.

## 5. Menu and navigation model

The control panel currently has a fixed set of cards/actions. A future menu should be generated from a typed navigation registry, for example:

- **Dashboard:** status, bind address, active mounts, upstream health.
- **Sites:** mounts, proxy targets, virtual hosts, route validation.
- **DNS:** providers, zones, records, change history.
- **Runtime:** PHP-FPM and Apache integrations, configured endpoints and health.
- **Databases:** connection metadata, database health, external phpMyAdmin link.
- **Live Reload:** connected browser sessions, watch paths, debounce settings.
- **Logs & Metrics:** recent errors, request counts, latency and health checks.
- **Settings:** listener, control path, allowed origins, integrations, backups.
- **Security:** users, roles, session policy, audit history.

Every menu item should be feature-gated and hidden or marked unavailable when its integration is not configured. Menu visibility is not a security boundary; every API endpoint must independently authorize requests.

## 6. Prioritized implementation plan

### P0 — Safety and correctness
- [ ] Review all control API handlers for authentication assumptions and exposure on non-loopback bind addresses.
- [ ] Add tests for path traversal, encoded paths, malformed request targets, proxy headers and redirect rewriting.
- [ ] Document that binding to `0.0.0.0` exposes the development control surface to the network.
- [ ] Add explicit production-use warnings and a safe local-only default profile.
- [ ] Review the status and shutdown APIs, including origin/CSRF protections and rate limiting.

### P1 — Core server usability
- [ ] Add a validated configuration file/profile format with schema versioning.
- [ ] Add persistent named site/mount/proxy profiles and safe import/export.
- [ ] Add structured request/error logs and health/readiness endpoints.
- [ ] Expand tests for API status/reload/message/shutdown and browser-panel behavior.
- [ ] Add CI checks for formatting, linting, Rust tests, generated browser assets, and dependency advisories.

### P2 — Frontend control panel
- [ ] Replace the fixed panel layout with responsive dashboard/navigation components.
- [ ] Add site, route, watch-path, and proxy configuration forms with validation and preview.
- [ ] Add accessible status indicators, loading/error states, and action confirmation.
- [ ] Define and document a versioned API schema before adding more integrations.

### P3 — External software integrations
- [ ] Select one DNS provider and implement a least-privilege provider adapter.
- [ ] Add a read-only Apache health/config-validation adapter before write operations.
- [ ] Add PHP-FPM integration only after its request mapping and upload/timeout behavior are specified.
- [ ] Add database connectivity checks and an optional protected phpMyAdmin link.
- [ ] Add end-to-end tests with isolated test services and no production credentials.

### P4 — Deployment and release engineering
- [ ] Add supported OS/architecture matrix and reproducible release artifacts.
- [ ] Add install/upgrade/uninstall and rollback documentation.
- [ ] Add backup/restore tests for configuration and integration metadata.
- [ ] Conduct a threat model and security review before any production-hosting claim.

## 7. Acceptance criteria for future features

A feature is not complete just because a menu item exists. Each feature should include:
- a documented API/config contract;
- validated inputs and clear error messages;
- unit tests plus integration tests where practical;
- least-privilege handling of credentials;
- no secrets in browser code or logs;
- user-facing documentation and upgrade notes;
- CI evidence for the supported build/test matrix.

## 8. Explicit non-goals until separately approved

- Replacing Apache or Nginx as a hardened production edge server.
- Becoming a new authoritative DNS platform in the first DNS milestone.
- Bundling a database server or phpMyAdmin by default.
- Claiming production readiness before threat modeling, security review, and load testing.

The safest path is to keep WebServer SYNC's current development-server core stable and add the administration surface incrementally, with DNS, Apache, PHP and database capabilities implemented as explicit integrations.
