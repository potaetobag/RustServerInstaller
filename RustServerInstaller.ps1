 Add-Type -AssemblyName Microsoft.VisualBasic

Clear-Host
Write-Host ""
Write-Host "       ======================================" -ForegroundColor Cyan
Write-Host "       Version: 1.0"
Write-Host "       Owner: potaetobag"
Write-Host "       Description: GUI installer for Rust Dedicated Server with" -ForegroundColor Gray
Write-Host "                    logging, SteamCMD, and optional uMod/Oxide support." -ForegroundColor Gray
Write-Host "                    Prompts user for custom server settings and builds" -ForegroundColor Gray
Write-Host "                    a startup batch script automatically." -ForegroundColor Gray
Write-Host "       ======================================" -ForegroundColor Cyan
Write-Host ""

# === Logging Setup ===
$logFile = Join-Path -Path $PSScriptRoot -ChildPath "RustServerInstaller.log"
function Log {
    param([string]$message)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $fullMessage = "$timestamp - $message"
    Write-Host $fullMessage
    Add-Content -Path $logFile -Value $fullMessage
}

Log "======== Starting Rust Server Installer ========"

function AskInput {
    param([string]$message, [string]$default)
    return [Microsoft.VisualBasic.Interaction]::InputBox($message, "Rust Server Setup", $default)
}

# === Collect Inputs ===
$steamcmdDir = AskInput "Path to SteamCMD directory:" "C:\Rust\Server\SteamCMD"
$rustDir = AskInput "Path to Rust Server directory:" "C:\Rust\Server"
$serverName = AskInput "Server Name (as shown in Rust):" "My Rust Server"
$description = AskInput "Server Description:" "A cool new Rust server!"
$website = AskInput "Server Website URL:" "http://yourwebsite.com"
$headerImage = AskInput "Header Image URL (512x256 JPG):" "http://yourwebsite.com/serverimage.jpg"
$rconPassword = AskInput "RCON Password:" "letmein"
$serverSeed = AskInput "World Seed (0–2147483647):" "1234"
$worldSize = AskInput "World Size (1000–6000):" "4000"
$maxPlayers = AskInput "Max Players:" "10"
$serverIdentity = AskInput "Server Identity (no spaces):" "server1"

$oxideInstall = [System.Windows.Forms.MessageBox]::Show("Do you want to install uMod (Oxide) for mod support?", "Oxide Install", "YesNo", "Question")
Log "User selected to install Oxide: $oxideInstall"

# === Download and Install SteamCMD ===
Log "Creating directories..."
New-Item -ItemType Directory -Force -Path $steamcmdDir | Out-Null
New-Item -ItemType Directory -Force -Path $rustDir | Out-Null

$steamCmdZip = "$steamcmdDir\steamcmd.zip"
try {
    Log "Downloading SteamCMD..."
    Invoke-WebRequest -Uri "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -OutFile $steamCmdZip -ErrorAction Stop
    Log "Extracting SteamCMD..."
    Expand-Archive -Force $steamCmdZip -DestinationPath $steamcmdDir
    Log "SteamCMD extracted successfully."
} catch {
    Log "X Error downloading or extracting SteamCMD: $_"
    exit 1
}

# === Install Rust Server ===
try {
    Log "Installing Rust server via SteamCMD..."
    Start-Process "$steamcmdDir\steamcmd.exe" -ArgumentList "+login anonymous +force_install_dir `"$rustDir`" +app_update 258550 validate +quit" -Wait
    Log "Rust server installation completed."
} catch {
    Log "X Error installing Rust server: $_"
    exit 1
}

# === Optional: Download and Install Oxide ===
if ($oxideInstall -eq "Yes") {
    try {
        Log "Downloading Oxide/uMod..."
        $oxideZip = "$env:TEMP\oxide.zip"
        Invoke-WebRequest -Uri "https://umod.org/games/rust/download/develop" -OutFile $oxideZip -ErrorAction Stop
        Log "Extracting Oxide/uMod..."
        Expand-Archive -Force $oxideZip -DestinationPath $rustDir
        Remove-Item $oxideZip
        Log "✓ Oxide installed successfully."
    } catch {
        Log "X Error downloading or installing Oxide: $_"
    }
}

# === Opening required Rust server ports in Windows Defender Firewall ===
$ports = @(
    @{ Name = "Rust Game Port"; Port = 28015 },
    @{ Name = "Rust RCON Port"; Port = 28016 },
    @{ Name = "Rust Server Queries"; Port = 28017 }
)

foreach ($entry in $ports) {
    $name = $entry.Name
    $port = $entry.Port

    # Inbound TCP
    $tcpRuleName = "$name (TCP)"
    if (-not (Get-NetFirewallRule -DisplayName $tcpRuleName -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -DisplayName $tcpRuleName -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow -Profile Any -ErrorAction SilentlyContinue
        Write-Host "✅ Opened $tcpRuleName"
    } else {
        Write-Host "ℹ️ Rule already exists: $tcpRuleName"
    }

    # Inbound UDP
    $udpRuleName = "$name (UDP)"
    if (-not (Get-NetFirewallRule -DisplayName $udpRuleName -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -DisplayName $udpRuleName -Direction Inbound -Protocol UDP -LocalPort $port -Action Allow -Profile Any -ErrorAction SilentlyContinue
        Write-Host "✅ Opened $udpRuleName"
    } else {
        Write-Host "ℹ️ Rule already exists: $udpRuleName"
    }
}

# === Installing Visual C++ 2022 Redistributables (x64 and x86) ===
# Paths for download
$tempDir = "$env:TEMP\vc_redist"
mkdir $tempDir -Force | Out-Null

# URLs for Visual C++ 2022 Redistributables
$x64Url = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$x86Url = "https://aka.ms/vs/17/release/vc_redist.x86.exe"

# Local file paths
$x64Installer = "$tempDir\vc_redist.x64.exe"
$x86Installer = "$tempDir\vc_redist.x86.exe"

# Download installers
Write-Host "📥 Downloading Visual C++ 2022 x64..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $x64Url -OutFile $x64Installer -UseBasicParsing

Write-Host "📥 Downloading Visual C++ 2022 x86..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $x86Url -OutFile $x86Installer -UseBasicParsing

# Install silently
Write-Host "🛠 Installing Visual C++ 2022 x64..." -ForegroundColor Yellow
Start-Process -FilePath $x64Installer -ArgumentList "/quiet", "/norestart" -Wait

Write-Host "🛠 Installing Visual C++ 2022 x86..." -ForegroundColor Yellow
Start-Process -FilePath $x86Installer -ArgumentList "/quiet", "/norestart" -Wait

Write-Host "✅ Visual C++ 2022 Redistributables installed." -ForegroundColor Green


# === Create RustServer.bat ===
try {
    $batPath = Join-Path $rustDir "RustServer.bat"
    Log "Creating RustServer.bat at $batPath..."

    @"
@echo off
title RustServerInstance
:start
"$steamcmdDir\steamcmd.exe" +force_install_dir "$rustDir" +login anonymous +app_update 258550 +quit
cd /d "$rustDir"
RustDedicated.exe -batchmode +server.port 28015 +server.level "Procedural Map" +server.seed $serverSeed +server.worldsize $worldSize +server.maxplayers $maxPlayers +server.hostname "$serverName" +server.description "$description" +server.url "$website" +server.headerimage "$headerImage" +server.identity "$serverIdentity" +rcon.port 28016 +rcon.password $rconPassword +rcon.web 1
goto start
"@ | Set-Content -Encoding ASCII -Path $batPath

    Log "✓ RustServer.bat created successfully."
} catch {
    Log "X Error creating batch file: $_"
    exit 1
}

Log "Installation complete!"
Log "To start your server, run: $batPath"
Pause
 
