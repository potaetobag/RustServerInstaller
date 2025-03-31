🛠️ Rust Dedicated Server GUI Installer

This PowerShell-based GUI tool makes it easy to install and configure a **Rust Dedicated Server on Windows**.  
It includes built-in logging, automated SteamCMD setup, and optional support for installing **uMod (Oxide)** to enable modding.

All server settings can be customized through simple graphical prompts, and a startup batch file is automatically created for easy launching and auto-restarting.

---

## ⚡ Features

- ✔️ GUI prompts to customize server details  
- ✔️ Automatically installs SteamCMD  
- ✔️ Installs or updates the Rust Dedicated Server  
- ✔️ Optionally installs uMod (Oxide) for modded servers  
- ✔️ Creates a `RustServer.bat` file for running your server  
- ✔️ Full logging to `RustServerInstaller.log` for easy troubleshooting  
- ✔️ No need to touch any config files manually  

---

## 🧰 Requirements

- Windows 10 or later  
- PowerShell 5+  
- Internet connection  
- Execution policy that allows scripts to run (see below)

---

## 🚀 How to Use (Windows)

1. **Download the script**  
   Save the provided script as `RustServerInstaller.ps1` on your system.

2. **Open PowerShell as Administrator**  
   - Press `Win + X` → Select `Windows PowerShell (Admin)`  
   - Or search “PowerShell”, right-click → **Run as Administrator**

3. **Run the installer**  
   Bypass the execution policy temporarily and run the script:

       powershell -ExecutionPolicy Bypass -File .\\RustServerInstaller.ps1

4. **Follow the GUI prompts**  
   - Choose install locations  
   - Customize server name, seed, player count, etc.  
   - Decide if you want to install uMod (Oxide)

5. **Check for logs**  
   - All progress is logged in `RustServerInstaller.log` in the script folder

6. **Start your server**  
   - Navigate to your Rust server folder  
   - Run `RustServer.bat`  
   - Your server will auto-update, start, and restart on crash

---

## 🔧 Example `RustServer.bat`

    @echo off
    :start
    "C:\\Path\\To\\SteamCMD\\steamcmd.exe" +force_install_dir "C:\\Path\\To\\RustServer" +login anonymous +app_update 258550 +quit
    cd /d "C:\\Path\\To\\RustServer"
    RustDedicated.exe -batchmode +server.port 28015 +server.level "Procedural Map" +server.seed 1234 +server.worldsize 4000 +server.maxplayers 10 +server.hostname "My Rust Server" +server.description "A cool new Rust server!" +server.url "http://yourwebsite.com" +server.headerimage "http://yourwebsite.com/serverimage.jpg" +server.identity "server1" +rcon.port 28016 +rcon.password letmein +rcon.web 1
    goto start

---

## 📝 Notes

- `Curl error 6` messages (about Unity cloud services) are normal on headless servers and can be ignored.  
- All input is sanitized and saved as plain text in the batch script.  
- To suppress startup shader or GPU-related warnings, ignore or redirect console output.  
- Use port forwarding on your router if you want others to connect to your server from outside your local network.

---

## 📂 Log Output Sample (`RustServerInstaller.log`)

    2025-03-31 14:30:15 - ======== Starting Rust Server Installer ========
    2025-03-31 14:30:20 - User selected to install Oxide: Yes
    2025-03-31 14:30:21 - Creating directories...
    2025-03-31 14:30:22 - Downloading SteamCMD...
    2025-03-31 14:30:25 - Extracting SteamCMD...
    2025-03-31 14:30:26 - SteamCMD extracted successfully.
    2025-03-31 14:31:40 - Rust server installation completed.
    2025-03-31 14:31:55 - ✓ Oxide installed successfully.
    2025-03-31 14:32:05 - ✓ RustServer.bat created successfully.
    2025-03-31 14:32:07 - Installation complete!

---

## 🤝 License

This project is provided as-is under the MIT License. Feel free to fork, share, or improve it.
