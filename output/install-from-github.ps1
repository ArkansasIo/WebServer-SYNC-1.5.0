param(
    [ValidateSet("android", "iphone", "ask")]
    [string]$Platform = "ask",
    [string]$HostIp = "",
    [int]$Port = 4090,
    [string]$RepoUrl = "https://github.com/ArkansasIo/WebServer-SYNC-1.5.0",
    [string]$SitePath = ""
)

$ErrorActionPreference = "Stop"

function Resolve-Platform {
    param([string]$Current)

    if ($Current -ne "ask") {
        return $Current
    }

    Write-Output "Select device platform:"
    Write-Output "  [1] Android"
    Write-Output "  [2] iPhone / iPad"

    $choice = Read-Host "Enter 1 or 2"
    switch ($choice) {
        "1" { return "android" }
        "2" { return "iphone" }
        default { throw "Invalid selection '$choice'. Use 1 (Android) or 2 (iPhone/iPad)." }
    }
}

$selected = Resolve-Platform -Current $Platform
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

$scriptPath = switch ($selected) {
    "android" { Join-Path $root "android\install-from-github.ps1" }
    "iphone" { Join-Path $root "iphone\install-from-github.ps1" }
    default { throw "Unsupported platform: $selected" }
}

if (-not (Test-Path $scriptPath)) {
    throw "Missing installer script: $scriptPath"
}

$args = @(
    "-ExecutionPolicy", "Bypass",
    "-File", $scriptPath,
    "-RepoUrl", $RepoUrl,
    "-Port", "$Port"
)

if (-not [string]::IsNullOrWhiteSpace($HostIp)) {
    $args += @("-HostIp", $HostIp)
}

if (-not [string]::IsNullOrWhiteSpace($SitePath)) {
    $args += @("-SitePath", $SitePath)
}

Write-Output "Running one-click GitHub installer for: $selected"
& powershell @args
