param(
    [string]$Host = "127.0.0.1",
    [int]$Port = 4090,
    [string]$Path = "/~~penguin/panel"
)

$url = "http://$Host`:$Port$Path"
Write-Output "Open iPhone/iPad control/app interface: $url"
Start-Process $url
