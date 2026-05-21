#!/bin/bash
# ============================================================
#  Spydomain — Burp Suite Professional Updater
#  Auto-detects platform: Debian/Arch/macOS
#  Repository: https://github.com/Spydomain/burpsuite-pro
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

VERSION=2025

echo -e "${CYAN}"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║          Spydomain — Updater                     ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ── Detect platform ──────────────────────────────────────────
if command -v pacman &>/dev/null; then
    PLATFORM="arch"
elif command -v apt &>/dev/null; then
    PLATFORM="debian"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
else
    echo -e "${RED}[✗] Unsupported platform${NC}"
    exit 1
fi
echo -e "  ${GREEN}✓${NC} Detected platform: ${PLATFORM}"

# ── Remove old system command ────────────────────────────────
echo -e "\n${YELLOW}[1/4]${NC} Removing old installation..."
sudo rm -f /usr/local/bin/burpsuitepro /bin/burpsuitepro 2>/dev/null || true
echo -e "  ${GREEN}✓${NC} Old launcher removed"

# ── Update dependencies ─────────────────────────────────────
echo -e "\n${YELLOW}[2/4]${NC} Updating dependencies..."
case $PLATFORM in
    debian)
        sudo apt update && sudo apt install -y git axel wget openjdk-21-jre openjdk-21-jdk
        sudo update-alternatives --set java /usr/lib/jvm/java-21-openjdk-amd64/bin/java 2>/dev/null || true
        ;;
    arch)
        sudo pacman -Syu --needed --noconfirm jdk21-openjdk wget axel git
        sudo archlinux-java set java-21-openjdk 2>/dev/null || true
        ;;
    macos)
        brew update && brew upgrade openjdk@21 2>/dev/null || true
        ;;
esac

# ── Re-clone and update ─────────────────────────────────────
echo -e "\n${YELLOW}[3/4]${NC} Fetching latest from GitHub..."
PARENT_DIR="$(dirname "$(pwd)")"
REPO_DIR="${PARENT_DIR}/Spydomain"

if [ -d "$REPO_DIR/.git" ]; then
    cd "$REPO_DIR"
    git pull origin master
else
    cd "$PARENT_DIR"
    git clone https://github.com/Spydomain/burpsuite-pro.git Spydomain 2>/dev/null || \
    git clone https://github.com/Spydomain/burpsuite-pro.git
    REPO_DIR="$(ls -td "${PARENT_DIR}"/Spydomain "${PARENT_DIR}"/Burpsuite-Professional 2>/dev/null | head -1)"
    cd "$REPO_DIR"
fi

# ── Download latest JAR ─────────────────────────────────────
echo -e "\n${YELLOW}[4/4]${NC} Downloading latest Burp Suite Professional..."
URL="https://portswigger-cdn.net/burp/releases/download?product=pro&type=Jar"
rm -f "burpsuite_pro_v${VERSION}.jar"
axel "$URL" -o "burpsuite_pro_v${VERSION}.jar"

# ── Run the appropriate installer ────────────────────────────
echo -e "\n${CYAN}[*] Running installer for ${PLATFORM}...${NC}"
case $PLATFORM in
    debian)  chmod +x install.sh && ./install.sh ;;
    arch)    chmod +x install_arch.sh && ./install_arch.sh ;;
    macos)   chmod +x install_macos.sh && ./install_macos.sh ;;
esac
