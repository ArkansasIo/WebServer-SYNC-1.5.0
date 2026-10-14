# Security Baseline

## Before any administration endpoint is exposed beyond loopback

- [ ] Define an explicit threat model and supported deployment model.
- [ ] Authenticate every privileged action.
- [ ] Enforce role-based authorization server-side.
- [ ] Use CSRF protections and a strict Origin/Host policy for browser-driven mutations.
- [ ] Apply rate limits to authentication and expensive operations.
- [ ] Bind locally by default and clearly warn when binding to a LAN/public interface.
- [ ] Protect secrets with an OS-appropriate secret store or restricted configuration file.
- [ ] Redact credentials, cookies, authorization headers and connection strings from logs.
- [ ] Add audit events for DNS writes, service actions, configuration changes and database operations.
- [ ] Add request size, upload size, timeout and concurrency limits.
- [ ] Test path traversal, encoded path variants, proxy header trust, redirect rewriting and WebSocket forwarding.
- [ ] Add dependency scanning, formatting, linting, tests and supported-platform CI.
- [ ] Document that TLS for upstream connections does not automatically provide TLS for inbound client connections.

## DNS safety

Use least-privilege provider tokens, validate record type/name/content/TTL, preview changes, keep audit events, and handle provider rate limits. DNS propagation is asynchronous and cannot be guaranteed globally by the application.

## PHP and database safety

Never serve PHP source as static files. Do not put database credentials or provider tokens in frontend code or committed example configuration. phpMyAdmin is a separate PHP application and must have its own updates, authentication and network restrictions.

## Deployment boundary

The project currently identifies itself as a development server. Passing tests or adding a control panel does not establish production readiness; that requires a separate security review, load testing, supported deployment documentation and operational monitoring.
