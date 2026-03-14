# Android Install + Setup

This folder is for Android-side API app output artifacts.

## Supported Android versions

- Android 10 and newer (recommended)
- Android 8/9 may work for browser-based control only

## Requirements

- WebServer SYNC 1.5.0 running on your PC/server
- Android device on the same network (Wi-Fi/LAN)
- Any HTTP-capable app/browser (or your own Android client)

## Quick setup

1. Start server on host:

```text
webserver-sync-1-5-0 serve . --bind 0.0.0.0 --port 4090
```

2. Open control panel on Android:

```text
http://<host-ip>:4090/~~penguin/panel
```

3. Use API from Android app:

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

Build Android API app output bundle:

```text
powershell -ExecutionPolicy Bypass -File output/android/build.ps1
```

Run/open Android control interface:

```text
powershell -ExecutionPolicy Bypass -File output/android/run.ps1 -Host <host-ip> -Port 4090
```

## API app files in this folder

- `api-app.example.json` (app-level API config)
- `api-config.example.json` (endpoint template)
- `loading-screen.html` (loading view)
- `splash-screen.html` (splash view)
- `logo.svg` (app/logo asset)

## Notes

- If mobile cannot connect, check firewall/network profile on host.
- `127.0.0.1` works only on the same device; use host LAN IP for Android.
