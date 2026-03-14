# One-Button Install from GitHub

Use the one-button launcher in this folder to install and start WebServer SYNC 1.5.0 for Android or iPhone/iPad.

## One-click (recommended)

- Double-click [install-from-github.cmd](install-from-github.cmd)
- Choose:
  - `1` for Android
  - `2` for iPhone/iPad

The launcher runs the correct platform installer script:

- Android: [android/install-from-github.ps1](android/install-from-github.ps1)
- iPhone/iPad: [iphone/install-from-github.ps1](iphone/install-from-github.ps1)

## Optional direct command

```text
powershell -ExecutionPolicy Bypass -File output/install-from-github.ps1 -Platform android -HostIp <host-ip> -Port 4090
```

or

```text
powershell -ExecutionPolicy Bypass -File output/install-from-github.ps1 -Platform iphone -HostIp <host-ip> -Port 4090
```

## Terminal-only system (non-interactive)

Use [install-from-terminal.ps1](install-from-terminal.ps1) when you want CLI-only install with no prompt.

## GUI system UI

Use [gui-system-ui.cmd](gui-system-ui.cmd) for a desktop button-based launcher.
