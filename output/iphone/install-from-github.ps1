param(
    [string]$RepoUrl = "https://github.com/ArkansasIo/WebServer-SYNC-1.5.0",
    [int]$Port = 4090,
    [string]$HostIp = "",
    [string]$SitePath = ""
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    throw "Rust/Cargo is required. Install Rust from https://rustup.rs first."
}

if ([string]::IsNullOrWhiteSpace($SitePath)) {
    $SitePath = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
}

Write-Output "Installing WebServer SYNC 1.5.0 from GitHub..."
cargo install --git $RepoUrl --path app --force

Write-Output "Starting server for iPhone/iPad devices..."
Start-Process -FilePath "webserver-sync-1-5-0" -ArgumentList @("serve", $SitePath, "--bind", "0.0.0.0", "--port", "$Port") | Out-Null

if ([string]::IsNullOrWhiteSpace($HostIp)) {
    Write-Output "Installed and started. Open on iPhone/iPad: http://<host-ip>:$Port/~~penguin/panel"
} else {
    Write-Output "Installed and started. Open on iPhone/iPad: http://$HostIp`:$Port/~~penguin/panel"
}
