# One-Button Install from GitHub (Windows host)

This folder contains **Windows** launchers that install and start the **WebServer SYNC 1.5.0 server on a Windows PC** (or Windows server). Your **Android phone/tablet does not run these `.cmd` / `.ps1` installers**.

If you only have an Android device (no PC/server), see **“Android-only (no PC) options”** below.

## What “Android install” means in this repo

- The **server** runs on a host machine (Windows PC/server).
- Android is a **client/controller** that connects to the host server over your network.
- On Android you typically just open the control panel in a browser.

Android control panel URL:

```text
http://<host-ip>:4090/~~penguin/panel
```

## One-click (recommended, Windows)

1. Double-click `install-from-github.cmd`
2. Choose:
   - `1` for Android
   - `2` for iPhone/iPad

The launcher runs the correct platform installer script:

- Android: `android/install-from-github.ps1`
- iPhone/iPad: `iphone/install-from-github.ps1`

## Optional direct command (Windows)

Android:

```text
powershell -ExecutionPolicy Bypass -File output/install-from-github.ps1 -Platform android -HostIp <host-ip> -Port 4090
```

iPhone/iPad:

```text
powershell -ExecutionPolicy Bypass -File output/install-from-github.ps1 -Platform iphone -HostIp <host-ip> -Port 4090
```

## Terminal-only system (Windows, non-interactive)

Use `install-from-terminal.ps1` when you want CLI-only install with no prompt.

## GUI system UI (Windows)

Use `gui-system-ui.cmd` for a desktop button-based launcher.

## Android-only (no PC) options

### Option A: Use Android as a controller (needs a host server)

If you have **any** machine running the server (Windows/Linux/Mac/Raspberry Pi), you can control it from Android by opening:

```text
http://<host-ip>:4090/~~penguin/panel
```

### Option B: Run the server on Android with Termux (advanced)

This repository does **not** currently provide a one-click Android/Termux installer. If you want this added, create an issue/PR request describing your Android version and whether you want to serve files from internal storage.