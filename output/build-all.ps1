$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Output "Building Android API app bundle..."
& (Join-Path $root "android\build.ps1")

Write-Output "Building iPhone/iPad API app bundle..."
& (Join-Path $root "iphone\build.ps1")

Write-Output "All mobile API app bundles built successfully."
