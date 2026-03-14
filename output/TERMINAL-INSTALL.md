# Terminal Install System

Use this when you want full terminal/CLI install flow (non-interactive).

## Requirements

- Windows PowerShell
- Rust/Cargo installed (`cargo` available in terminal)
- Network access to GitHub

## Commands

Android:

```text
powershell -ExecutionPolicy Bypass -File output/install-from-terminal.ps1 -Platform android -HostIp <host-ip> -Port 4090
```

iPhone/iPad:

```text
powershell -ExecutionPolicy Bypass -File output/install-from-terminal.ps1 -Platform iphone -HostIp <host-ip> -Port 4090
```

## Optional parameters

- `-RepoUrl` custom GitHub repo URL
- `-SitePath` directory to serve

Example with custom site path:

```text
powershell -ExecutionPolicy Bypass -File output/install-from-terminal.ps1 -Platform android -SitePath . -HostIp 192.168.1.23
```
