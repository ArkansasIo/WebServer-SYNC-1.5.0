# Administration API Design

## Rules

- Keep the current live-reload API stable while introducing admin APIs under `/api/v1/admin`.
- The embedded control API is currently designed for local development. Before exposing administration over a network, add authentication, authorization, origin/CSRF policy, rate limits, and audit events.
- Never return secret values from an API. Return a redacted state such as `configured: true`.
- Validate all request fields server-side. Frontend validation is only a usability feature.
- Destructive changes must support a preview/diff and explicit confirmation.
- Use versioned schemas and consistent JSON errors.

## Proposed endpoints

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/api/v1/admin/health` | Readiness and dependency summary |
| GET/POST | `/api/v1/admin/profiles` | List/create named configuration profiles |
| GET/PUT/DELETE | `/api/v1/admin/profiles/{id}` | Read/update/delete a profile |
| GET/POST | `/api/v1/admin/sites` | List/create sites and routes |
| GET/PUT/DELETE | `/api/v1/admin/sites/{id}` | Read/update/delete a site |
| GET | `/api/v1/admin/integrations` | Integration status, without secrets |
| POST | `/api/v1/admin/integrations/{name}/test` | Validate a configured integration |
| GET | `/api/v1/admin/audit` | Authorized audit-event query |

These are design proposals, not endpoints currently implemented by the server.

## Error format

Use a consistent shape such as:

```json
{
  "error": {
    "code": "invalid_configuration",
    "message": "The configuration is invalid.",
    "details": []
  }
}
```

Avoid returning stack traces, filesystem secrets, tokens, environment variables, or internal network details to unauthenticated clients.
