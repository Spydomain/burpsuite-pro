#!/bin/bash
# ============================================================
#  Spydomain — Help & Troubleshooting
# ============================================================

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║           Spydomain — Help Guide                 ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${GREEN}USAGE:${NC}"
echo "  burpsuitepro                     Launch Burp Suite Professional"
echo "  burpsuitepro --wayland-native    Launch with native Wayland (experimental)"
echo ""

echo -e "${GREEN}INSTALLATION:${NC}"
echo "  Debian/Kali/Ubuntu:  chmod +x install.sh && sudo ./install.sh"
echo "  Arch/CachyOS:        chmod +x install_arch.sh && ./install_arch.sh"
echo "  macOS:               chmod +x install_macos.sh && ./install_macos.sh"
echo "  Windows:             Set-ExecutionPolicy bypass -Scope process; ./install.ps1"
echo ""

echo -e "${GREEN}UPDATE:${NC}"
echo "  chmod +x update.sh && ./update.sh"
echo ""

echo -e "${GREEN}LICENSE ACTIVATION:${NC}"
echo "  1. Loader window opens alongside Burp Suite"
echo "  2. Copy license key from Loader → paste into Burp Suite"
echo "  3. Choose 'Manual Activation'"
echo "  4. Copy Request from Burp → paste into Loader Request field"
echo "  5. Copy Response from Loader → paste into Burp Response field"
echo "  6. Click Activate — done!"
echo ""

echo -e "${YELLOW}TROUBLESHOOTING:${NC}"
echo ""
echo -e "  ${RED}Problem:${NC} 'Invalid Key' or 'Key Not Valid'"
echo -e "  ${GREEN}Fix:${NC}     Ensure Java 21 is the default:"
echo "           Debian:  sudo update-alternatives --set java /usr/lib/jvm/java-21-openjdk-amd64/bin/java"
echo "           Arch:    sudo archlinux-java set java-21-openjdk"
echo ""
echo -e "  ${RED}Problem:${NC} Blank/grey window on Wayland"
echo -e "  ${GREEN}Fix:${NC}     Run: burpsuitepro  (uses XWayland fallback)"
echo "           Or try: burpsuitepro --wayland-native"
echo ""
echo -e "  ${RED}Problem:${NC} 'No such file' when running burpsuitepro"
echo -e "  ${GREEN}Fix:${NC}     Re-run the installer for your platform"
echo ""
echo -e "  ${RED}Problem:${NC} Java version mismatch"
echo -e "  ${GREEN}Fix:${NC}     Check with: java -version"
echo "           Must show version 21.x.x"
echo ""

echo -e "${GREEN}JAVA VERSION:${NC}"
echo "  Select the correct Java runtime if multiple installed:"
echo "    Debian:  sudo update-alternatives --config java"
echo "    Arch:    archlinux-java status"
echo ""

echo -e "${GREEN}CREDITS:${NC}"
echo "  Loader.jar  → h3110w0r1d-y (github.com/h3110w0r1d-y/BurpLoaderKeygen)"
echo "  Script      → cyb3rzest (github.com/cyb3rzest/Burp-Suite-Pro)"
echo "  Spydomain   → povzayd (github.com/povzayd)"
echo ""
