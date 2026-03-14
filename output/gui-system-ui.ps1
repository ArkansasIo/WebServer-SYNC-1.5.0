param(
    [string]$DefaultHostIp = "127.0.0.1",
    [int]$DefaultPort = 4090,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$outputRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$androidInstall = Join-Path $outputRoot "android\install-from-github.ps1"
$iphoneInstall = Join-Path $outputRoot "iphone\install-from-github.ps1"
$androidBuild = Join-Path $outputRoot "android\build.ps1"
$iphoneBuild = Join-Path $outputRoot "iphone\build.ps1"
$buildAll = Join-Path $outputRoot "build-all.ps1"
$terminalInstall = Join-Path $outputRoot "install-from-terminal.ps1"

if ($DryRun) {
    $required = @($androidInstall, $iphoneInstall, $androidBuild, $iphoneBuild, $buildAll, $terminalInstall)
    foreach ($path in $required) {
        if (-not (Test-Path $path)) {
            throw "Missing required script: $path"
        }
    }

    Write-Output "GUI_SYSTEM_UI_READY"
    exit 0
}

function Invoke-Script {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Script,
        [string[]]$Arguments = @(),
        [switch]$Background
    )

    if (-not (Test-Path $Script)) {
        [System.Windows.Forms.MessageBox]::Show("Missing script: $Script", "WebServer SYNC", "OK", "Error") | Out-Null
        return
    }

    $argLine = @("-ExecutionPolicy", "Bypass", "-File", ('"' + $Script + '"')) + $Arguments

    if ($Background) {
        Start-Process -FilePath "powershell" -ArgumentList $argLine | Out-Null
    } else {
        Start-Process -FilePath "powershell" -ArgumentList $argLine -Wait
    }
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "WebServer SYNC 1.5.0 - GUI System UI"
$form.Size = New-Object System.Drawing.Size(760, 580)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(18, 24, 38)
$form.ForeColor = [System.Drawing.Color]::White

$title = New-Object System.Windows.Forms.Label
$title.Text = "WebServer SYNC 1.5.0 - GUI System UI"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(20, 18)
$form.Controls.Add($title)

$sub = New-Object System.Windows.Forms.Label
$sub.Text = "One-click install/build/run controls for Android and iPhone/iPad"
$sub.AutoSize = $true
$sub.Location = New-Object System.Drawing.Point(22, 52)
$form.Controls.Add($sub)

$hostLabel = New-Object System.Windows.Forms.Label
$hostLabel.Text = "Host IP"
$hostLabel.AutoSize = $true
$hostLabel.Location = New-Object System.Drawing.Point(24, 92)
$form.Controls.Add($hostLabel)

$hostBox = New-Object System.Windows.Forms.TextBox
$hostBox.Text = $DefaultHostIp
$hostBox.Location = New-Object System.Drawing.Point(90, 88)
$hostBox.Size = New-Object System.Drawing.Size(170, 24)
$form.Controls.Add($hostBox)

$portLabel = New-Object System.Windows.Forms.Label
$portLabel.Text = "Port"
$portLabel.AutoSize = $true
$portLabel.Location = New-Object System.Drawing.Point(285, 92)
$form.Controls.Add($portLabel)

$portBox = New-Object System.Windows.Forms.TextBox
$portBox.Text = $DefaultPort.ToString()
$portBox.Location = New-Object System.Drawing.Point(325, 88)
$portBox.Size = New-Object System.Drawing.Size(90, 24)
$form.Controls.Add($portBox)

$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ScrollBars = "Vertical"
$logBox.ReadOnly = $true
$logBox.Location = New-Object System.Drawing.Point(22, 360)
$logBox.Size = New-Object System.Drawing.Size(700, 170)
$logBox.BackColor = [System.Drawing.Color]::FromArgb(10, 14, 24)
$logBox.ForeColor = [System.Drawing.Color]::FromArgb(180, 220, 255)
$form.Controls.Add($logBox)

function Add-Log([string]$msg) {
    $time = (Get-Date).ToString("HH:mm:ss")
    $logBox.AppendText("[$time] $msg`r`n")
}

function Get-Port {
    if (-not [int]::TryParse($portBox.Text, [ref]$null)) {
        [System.Windows.Forms.MessageBox]::Show("Port must be a number.", "WebServer SYNC", "OK", "Warning") | Out-Null
        return $null
    }
    return [int]$portBox.Text
}

function New-Button([string]$text, [int]$x, [int]$y, [int]$w = 220) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Location = New-Object System.Drawing.Point($x, $y)
    $btn.Size = New-Object System.Drawing.Size($w, 38)
    $btn.BackColor = [System.Drawing.Color]::FromArgb(56, 189, 248)
    $btn.ForeColor = [System.Drawing.Color]::White
    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderSize = 0
    $form.Controls.Add($btn)
    return $btn
}

$btnInstallAndroid = New-Button "Install from GitHub (Android)" 22 140
$btnInstallIphone = New-Button "Install from GitHub (iPhone/iPad)" 262 140
$btnTerminalAndroid = New-Button "Terminal Install (Android)" 502 140
$btnTerminalAndroid.Width = 220

$btnTerminalIphone = New-Button "Terminal Install (iPhone/iPad)" 22 186
$btnBuildAndroid = New-Button "Build Android Bundle" 262 186
$btnBuildIphone = New-Button "Build iPhone Bundle" 502 186
$btnBuildIphone.Width = 220

$btnBuildAll = New-Button "Build All Bundles" 22 232
$btnOpenPanel = New-Button "Open Control Panel URL" 262 232
$btnOpenDocs = New-Button "Open Install Docs" 502 232
$btnOpenDocs.Width = 220

$btnExit = New-Button "Close" 22 278
$btnExit.BackColor = [System.Drawing.Color]::FromArgb(100, 116, 139)

$btnInstallAndroid.Add_Click({
    $port = Get-Port
    if ($null -eq $port) { return }
    Add-Log "Starting Android GitHub install..."
    Invoke-Script -Script $androidInstall -Arguments @("-HostIp", $hostBox.Text, "-Port", "$port", "-SitePath", ".")
    Add-Log "Android GitHub install completed."
})

$btnInstallIphone.Add_Click({
    $port = Get-Port
    if ($null -eq $port) { return }
    Add-Log "Starting iPhone GitHub install..."
    Invoke-Script -Script $iphoneInstall -Arguments @("-HostIp", $hostBox.Text, "-Port", "$port", "-SitePath", ".")
    Add-Log "iPhone GitHub install completed."
})

$btnTerminalAndroid.Add_Click({
    $port = Get-Port
    if ($null -eq $port) { return }
    Add-Log "Running terminal install (Android)..."
    Invoke-Script -Script $terminalInstall -Arguments @("-Platform", "android", "-HostIp", $hostBox.Text, "-Port", "$port", "-SitePath", ".")
    Add-Log "Terminal install (Android) completed."
})

$btnTerminalIphone.Add_Click({
    $port = Get-Port
    if ($null -eq $port) { return }
    Add-Log "Running terminal install (iPhone/iPad)..."
    Invoke-Script -Script $terminalInstall -Arguments @("-Platform", "iphone", "-HostIp", $hostBox.Text, "-Port", "$port", "-SitePath", ".")
    Add-Log "Terminal install (iPhone/iPad) completed."
})

$btnBuildAndroid.Add_Click({
    Add-Log "Building Android output bundle..."
    Invoke-Script -Script $androidBuild
    Add-Log "Android output bundle built."
})

$btnBuildIphone.Add_Click({
    Add-Log "Building iPhone output bundle..."
    Invoke-Script -Script $iphoneBuild
    Add-Log "iPhone output bundle built."
})

$btnBuildAll.Add_Click({
    Add-Log "Building all output bundles..."
    Invoke-Script -Script $buildAll
    Add-Log "All output bundles built."
})

$btnOpenPanel.Add_Click({
    $port = Get-Port
    if ($null -eq $port) { return }
    $url = "http://$($hostBox.Text):$port/~~penguin/panel"
    Add-Log "Opening: $url"
    Start-Process $url | Out-Null
})

$btnOpenDocs.Add_Click({
    $doc = Join-Path $outputRoot "INSTALL-FROM-GITHUB.md"
    Add-Log "Opening docs: $doc"
    Start-Process $doc | Out-Null
})

$btnExit.Add_Click({
    $form.Close()
})

Add-Log "GUI ready."
Add-Log "Tip: Use 'Install from GitHub' buttons first, then open control panel URL."

[void]$form.ShowDialog()
