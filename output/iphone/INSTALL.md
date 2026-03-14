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

## Compile / build / run

From the project root:

```text
cargo build -p penguin-app
```

Build iPhone/iPad API app output bundle:

```text
powershell -ExecutionPolicy Bypass -File output/iphone/build.ps1
```

Run/open iPhone/iPad control interface:

```text
powershell -ExecutionPolicy Bypass -File output/iphone/run.ps1 -Host <host-ip> -Port 4090
```

## Install from GitHub

From the project root, install and start in one step:

```text
powershell -ExecutionPolicy Bypass -File output/iphone/install-from-github.ps1 -HostIp <host-ip> -Port 4090
```

This installs WebServer SYNC 1.5.0 from GitHub using Cargo and starts the server for iPhone/iPad access.

## API app files in this folder

- `api-app.example.json` (app-level API config)
- `api-config.example.json` (endpoint template)
- `loading-screen.html` (loading view)
- `splash-screen.html` (splash view)
- `logo.svg` (app/logo asset)

## Notes

- If requests fail, allow local network access in iOS app settings.
- `127.0.0.1` works only on the same device; use host LAN IP for iPhone/iPad.
