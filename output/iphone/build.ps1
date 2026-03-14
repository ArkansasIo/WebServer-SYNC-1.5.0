param(
    [string]$OutDir = "./dist"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$required = @(
    "api-app.example.json",
    "api-config.example.json",
    "loading-screen.html",
    "splash-screen.html",
    "logo.svg",
    "INSTALL.md"
)

foreach ($file in $required) {
    if (-not (Test-Path (Join-Path $root $file))) {
        throw "Missing required file: $file"
    }
}

$distPath = Join-Path $root $OutDir
if (Test-Path $distPath) {
    Remove-Item -Recurse -Force $distPath
}
New-Item -ItemType Directory -Path $distPath | Out-Null

Copy-Item (Join-Path $root "api-app.example.json") (Join-Path $distPath "api-app.json")
Copy-Item (Join-Path $root "api-config.example.json") (Join-Path $distPath "api-config.json")
Copy-Item (Join-Path $root "loading-screen.html") $distPath
Copy-Item (Join-Path $root "splash-screen.html") $distPath
Copy-Item (Join-Path $root "logo.svg") $distPath
Copy-Item (Join-Path $root "INSTALL.md") $distPath

$version = [ordered]@{
    platform = "iphone-ipad"
    appName = "WebServer SYNC Mobile"
    appVersion = "1.5.0"
    minimumOS = "iOS 15.0"
    buildTimeUtc = (Get-Date).ToUniversalTime().ToString("o")
    apiVersion = "v1"
}
$version | ConvertTo-Json -Depth 5 | Set-Content -Path (Join-Path $distPath "version.json") -Encoding UTF8

Write-Output "iPhone/iPad API app bundle created: $distPath"
