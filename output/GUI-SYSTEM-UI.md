# GUI System UI

Use this desktop GUI to manage Android/iPhone install/build/run actions from one place.

## Launch

One-click launcher:

```text
output/gui-system-ui.cmd
```

PowerShell launch:

```text
powershell -ExecutionPolicy Bypass -File output/gui-system-ui.ps1
```

## Features

- Install from GitHub (Android)
- Install from GitHub (iPhone/iPad)
- Terminal install mode (Android/iPhone)
- Build Android bundle
- Build iPhone bundle
- Build all bundles
- Open control panel URL
- Open install docs

## Inputs

- Host IP
- Port

The GUI uses existing scripts in `output/android`, `output/iphone`, and `output/`.
