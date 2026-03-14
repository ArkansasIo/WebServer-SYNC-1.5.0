param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("android", "iphone")]
    [string]$Platform,
    [string]$HostIp = "",
    [int]$Port = 4090,
    [string]$RepoUrl = "https://github.com/ArkansasIo/WebServer-SYNC-1.5.0",
    [string]$SitePath = ""
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$entry = Join-Path $root "install-from-github.ps1"

if (-not (Test-Path $entry)) {
    throw "Missing entry installer: $entry"
}

$args = @(
    "-ExecutionPolicy", "Bypass",
    "-File", $entry,
    "-Platform", $Platform,
    "-Port", "$Port",
    "-RepoUrl", $RepoUrl
)

if (-not [string]::IsNullOrWhiteSpace($HostIp)) {
    $args += @("-HostIp", $HostIp)
}
if (-not [string]::IsNullOrWhiteSpace($SitePath)) {
    $args += @("-SitePath", $SitePath)
}

Write-Output "Running terminal install for platform: $Platform"
& powershell @args
