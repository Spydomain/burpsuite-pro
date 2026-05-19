<div align="center">

# 🕷️ Spydomain

### Burp Suite Professional — Automated Setup & Activation

[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-blue?style=for-the-badge)]()
[![Arch](https://img.shields.io/badge/Arch%20%2F%20CachyOS-Wayland%20Ready-green?style=for-the-badge)]()
[![Java](https://img.shields.io/badge/Java-21%20LTS-orange?style=for-the-badge)]()
[![License](https://img.shields.io/badge/Version-2025%20Latest-red?style=for-the-badge)]()

**One-command installer for Burp Suite Professional with automatic Java configuration, Wayland support, and cross-platform compatibility.**

[Overview](https://portswigger.net/burp/pro) · [Troubleshooting](#-troubleshooting) · [Credits](#-credits)

</div>

---

## 📋 Supported Platforms

| Platform | Script | Display Server |
|----------|--------|----------------|
| Debian / Ubuntu / Kali | `install.sh` | X11 |
| Arch / CachyOS / Manjaro | `install_arch.sh` | X11 + **Wayland** |
| macOS (Intel + Apple Silicon) | `install_macos.sh` | Aqua |
| Windows 10/11 | `install.ps1` | — |

---

## 🚀 Quick Install

### 🐧 Debian / Ubuntu / Kali Linux

```bash
sudo apt update && sudo apt install -y wget && wget -qO- https://raw.githubusercontent.com/povzayd/Burpsuite-Professional/main/install.sh | sudo bash
```

Or clone & run:
```bash
git clone https://github.com/povzayd/Burpsuite-Professional.git Spydomain
cd Spydomain
chmod +x install.sh
sudo ./install.sh
```

### 🔷 Arch Linux / CachyOS / Manjaro (Wayland)

```bash
git clone https://github.com/povzayd/Burpsuite-Professional.git Spydomain
cd Spydomain
chmod +x install_arch.sh
./install_arch.sh
```

> **Wayland users:** The installer auto-detects Wayland and configures XWayland fallback for stable rendering. Java Swing apps require this for proper display.

### 🍎 macOS

**Step 1:** Install Homebrew and dependencies:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install git openjdk@21
```

**Step 2:** Run the installer:
```bash
git clone https://github.com/povzayd/Burpsuite-Professional.git Spydomain
cd Spydomain
chmod +x install_macos.sh
./install_macos.sh
```

### 🪟 Windows

1. Download and extract this repo to `C:\Spydomain`
2. Open **PowerShell as Administrator**
3. Set execution policy:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
   ```
4. Navigate and run:
   ```powershell
   cd C:\Spydomain
   .\install.ps1
   ```
5. *(Optional)* Change the icon of `Burp-Suite-Pro.vbs` → right-click → Properties → Change Icon → select `burp_suite.ico`
6. *(Optional)* Copy `Burp-Suite-Pro.vbs` to `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\` for Start Menu access

---

## ▶️ Run

```bash
burpsuitepro
```

### Wayland Native Mode (Experimental)
```bash
burpsuitepro --wayland-native
```

> Uses JDK 21's experimental `WLToolkit` for native Wayland rendering. Falls back to XWayland if issues occur.

---

## 🔑 License Activation

> [!IMPORTANT]
> The Loader keygen window opens **alongside** Burp Suite. Follow these steps in order:

1. **Copy** the license key from the **Loader** window
2. **Paste** it into the Burp Suite activation dialog
3. Select **"Manual Activation"**
4. **Copy** the Request key from Burp Suite → **paste** into the Loader's Request field
5. **Copy** the Response key from the Loader → **paste** into Burp Suite's Response field
6. Click **Activate** ✅

---

## 🔄 Update

Auto-detects your platform and updates everything:

```bash
chmod +x update.sh && ./update.sh
```

Or one-liner:
```bash
wget -qO- https://raw.githubusercontent.com/povzayd/Burpsuite-Professional/main/update.sh | sudo bash
```

---

## ☕ Java Version

Spydomain requires **OpenJDK 21 (LTS)**. The installers set this automatically, but if you need to switch manually:

**Debian/Ubuntu/Kali:**
```bash
sudo update-alternatives --config java
# Select the java-21-openjdk option
```

**Arch/CachyOS:**
```bash
archlinux-java status
sudo archlinux-java set java-21-openjdk
```

**Verify:**
```bash
java -version
# Should show: openjdk version "21.x.x"
```

---

## 🛠 Troubleshooting

<details>
<summary><b>"Invalid Key" or "Key Not Valid" error</b></summary>

**Cause:** Wrong Java version. The loader requires JDK 21 specifically.

```bash
# Check current version
java -version

# Fix on Debian/Kali
sudo update-alternatives --set java /usr/lib/jvm/java-21-openjdk-amd64/bin/java

# Fix on Arch/CachyOS
sudo archlinux-java set java-21-openjdk
```
</details>

<details>
<summary><b>Blank/grey window on Wayland (CachyOS/Hyprland/Sway)</b></summary>

**Cause:** Java Swing doesn't support Wayland natively by default.

```bash
# Use the default launcher (auto-configures XWayland)
burpsuitepro

# Or try native Wayland (experimental)
burpsuitepro --wayland-native
```

If still broken, force X11 manually:
```bash
export GDK_BACKEND=x11
export _JAVA_AWT_WM_NONREPARENTING=1
burpsuitepro
```
</details>

<details>
<summary><b>"No such file" when running <code>burpsuitepro</code></b></summary>

**Cause:** The launcher script references a JAR filename that doesn't exist.

```bash
# Check what JAR you have
ls ~/Spydomain/burpsuite_pro_v*.jar

# Re-run the installer for your platform
./install.sh        # Debian
./install_arch.sh   # Arch/CachyOS
./install_macos.sh  # macOS
```
</details>

<details>
<summary><b>Command <code>burpsuitepro</code> not found</b></summary>

```bash
# Re-install the launcher globally
sudo cp burpsuitepro /usr/local/bin/burpsuitepro
sudo chmod +x /usr/local/bin/burpsuitepro
```
</details>

<details>
<summary><b>Help command</b></summary>

```bash
chmod +x help.sh && ./help.sh
```
</details>

---

## 📁 Repository Structure

```
Spydomain/
├── loader.jar            # Keygen/Loader (required)
├── burp_suite.ico        # Application icon
├── install.sh            # Installer — Debian/Ubuntu/Kali
├── install_arch.sh       # Installer — Arch/CachyOS/Manjaro (Wayland)
├── install_macos.sh      # Installer — macOS
├── install.ps1           # Installer — Windows PowerShell
├── update.sh             # Cross-platform updater
├── help.sh               # Help & troubleshooting
├── Launcher.jpg          # Desktop launcher screenshot
└── README.md             # This file
```

> **Note:** `burpsuite_pro_v2025.jar` is downloaded automatically by the install scripts. It is not included in the repository due to its size (~660MB).

---

## 🏗 NixOS / Nix Flake

Add this repo's flake to your flake inputs:

```nix
# flake.nix
{
  inputs = {
    burpsuitepro = {
      type = "github";
      owner = "povzayd";
      repo = "Burpsuite-Professional";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

With `environment.systemPackages` (NixOS):
```nix
{ inputs, ... }: {
  environment.systemPackages = [
    inputs.burpsuitepro.packages.${system}.default
  ];
}
```

With `home.packages` (home-manager):
```nix
{ inputs, ... }: {
  home.packages = [
    inputs.burpsuitepro.packages.${system}.default
  ];
}
```

> **Note:** `loader.jar` is symlinked to `burpsuite.jar` so Burp Suite recognizes the license keys. Access the loader command from terminal with `loader`.

---

## 🙏 Credits

| Component | Author |
|-----------|--------|
| Loader.jar | [h3110w0r1d-y](https://github.com/h3110w0r1d-y/BurpLoaderKeygen) |
| Original Script | [cyb3rzest](https://github.com/cyb3rzest/Burp-Suite-Pro) |
| Spydomain | [povzayd](https://github.com/povzayd) |

---

<div align="center">

**⭐ Star this repo if Spydomain helped you!**

</div>
