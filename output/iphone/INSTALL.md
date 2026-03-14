# iPhone / iPad Install + Setup

This folder is for iPhone/iPad-side API app output artifacts.

## Supported iOS/iPadOS versions

- iOS 15+ and iPadOS 15+

## Requirements

- WebServer SYNC 1.5.0 running on your PC/server
- iPhone/iPad on the same network (Wi-Fi/LAN)
- Safari/Chrome or any app that can call HTTP APIs

## Quick setup

1. Start server on host:

```text
webserver-sync-1-5-0 serve . --bind 0.0.0.0 --port 4090
```

2. Open control panel on iPhone/iPad:

```text
http://<host-ip>:4090/~~penguin/panel
```

3. Use API from iOS app:

```text
GET  http://<host-ip>:4090/~~penguin/api/v1/status
POST http://<host-ip>:4090/~~penguin/api/v1/reload
POST http://<host-ip>:4090/~~penguin/api/v1/message
POST http://<host-ip>:4090/~~penguin/api/v1/shutdown
```

## Notes

- If requests fail, allow local network access in iOS app settings.
- `127.0.0.1` works only on the same device; use host LAN IP for iPhone/iPad.
