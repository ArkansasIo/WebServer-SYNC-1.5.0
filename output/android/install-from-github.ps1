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
cargo install --git $RepoUrl penguin-app --force
if ($LASTEXITCODE -ne 0) {
    throw "cargo install failed with exit code $LASTEXITCODE"
}

$cargoHome = if ([string]::IsNullOrWhiteSpace($env:CARGO_HOME)) {
    Join-Path $env:USERPROFILE ".cargo"
} else {
    $env:CARGO_HOME
}
$installedExe = Join-Path (Join-Path $cargoHome "bin") "webserver-sync-1-5-0.exe"
$exe = if (Test-Path $installedExe) { $installedExe } else { "webserver-sync-1-5-0" }

Write-Output "Starting server for Android devices..."
Start-Process -FilePath $exe -ArgumentList @("serve", $SitePath, "--bind", "0.0.0.0", "--port", "$Port") | Out-Null

if ([string]::IsNullOrWhiteSpace($HostIp)) {
    Write-Output "Installed and started. Open on Android: http://<host-ip>:$Port/~~penguin/panel"
} else {
    Write-Output "Installed and started. Open on Android: http://$HostIp`:$Port/~~penguin/panel"
}
