# Implementation Status

This file tracks implemented code separately from proposed integrations.

## Current core
- [x] Rust development HTTP server
- [x] Static directory mounts
- [x] Reverse proxy
- [x] Browser live reload and overlay
- [x] Embedded mobile-friendly control panel
- [x] Status/reload/message/shutdown control endpoints

## Foundation added in this milestone
- [x] Feature-gap audit and architecture roadmap
- [x] API/security/configuration contract for planned admin features
- [ ] Persistent config profile implementation
- [ ] Authentication and role-based authorization
- [ ] TLS termination and certificate lifecycle
- [ ] DNS provider adapter
- [ ] Apache integration
- [ ] PHP-FPM integration
- [ ] Database connectivity adapter
- [ ] Browser UI for integrations
- [ ] End-to-end security and integration test matrix

Do not mark a feature complete until implementation, tests, and documentation are merged. This repository is a development server, not a production hosting panel.
