# Frontend Administration Specification

## UX requirements

- Responsive desktop and mobile layout; keyboard navigation and visible focus.
- Feature-aware navigation: unavailable integrations are labelled as not configured.
- Every async action has loading, success and error states.
- Destructive actions require confirmation and show the affected resource.
- Never store provider tokens, database passwords, or private keys in browser local storage.
- Do not rely on hidden menu items for authorization.

## Navigation

1. Dashboard: server state, listener, active mounts and recent errors.
2. Sites: static mounts, upstreams, route validation and redirects.
3. DNS: provider connection, zones, records, preview and history.
4. Runtime: Apache and PHP integration status.
5. Databases: connection status and protected phpMyAdmin link.
6. Live reload: watched paths, debounce settings and browser status.
7. Logs: filtered diagnostics with secret redaction.
8. Settings: named profiles, listener and allowed origins.
9. Security: users, roles, sessions and audit events.

## API client

- Use a single typed API client module.
- Parse JSON only when the response content type says JSON.
- Handle non-2xx responses and network failures explicitly.
- Apply request timeouts and cancellation to long-running requests.
- Never display raw stack traces or unredacted server errors.
- Include a request/correlation identifier in diagnostics where supported.

## Current status

The repository's existing control panel is embedded HTML/JavaScript and provides live-reload controls. This document is the implementation specification for an expanded frontend; it does not claim that the navigation above is implemented.
