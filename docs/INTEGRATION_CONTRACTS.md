# Integration Contracts: DNS, Apache, PHP and Databases

This document defines the first integration boundary. It intentionally does not pretend that these external services are already managed by the core.

## DNS provider

Provider adapter responsibilities:
- report supported record types and provider capabilities;
- list zones and records with pagination;
- validate proposed record changes;
- provide a redacted change preview;
- apply changes only after authorized confirmation;
- record success/failure and provider request identifiers;
- perform verification lookups separately from the write operation.

Provider credentials must be stored outside frontend JavaScript and version control. Start with one selected provider and contract tests against a mock API before adding multiple providers.

## Apache

Treat Apache as an external process. An adapter may detect a configured executable, run its configuration-test mode, report status and propose a diff for virtual-host changes. Never overwrite an existing configuration without backup and user confirmation. Do not assume a service manager or Apache installation path is the same on every operating system.

## PHP

Preferred initial development integration: proxy to a PHP HTTP development server. A later PHP-FPM integration must explicitly define FastCGI parameter mapping, script filename resolution, document root, request body handling, upload limits, timeouts, error mapping and platform-specific socket/TCP configuration.

Never pass a request path directly to a shell. Never execute PHP source as static content.

## MySQL / MariaDB

Start with read-only connection validation and server/version metadata. Keep credentials out of responses and logs. Database provisioning, query execution and backups require distinct authorization scopes and audit trails.

## phpMyAdmin

phpMyAdmin is a separate PHP web application. The core may provide a protected link or optional reverse-proxy route to a separately installed instance. Track its own license and update/security lifecycle. Never expose it publicly without authentication and network controls.

## TLS

Inbound TLS termination and automatic certificate issuance are separate from configuring an HTTPS upstream. Before implementing ACME, specify challenge methods, renewal scheduling, private-key permissions, failure reporting and rollback.
