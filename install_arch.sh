#!/bin/bash
# ============================================================
#  Spydomain — Burp Suite Professional Installer
#  Platform: Arch Linux / CachyOS / Manjaro (Wayland + X11)
#  Repository: https://github.com/Spydomain/burpsuite-pro
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION=2025

echo -e "${CYAN}"
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║        Spydomain — Burp Suite Pro Installer          ║"
echo "  ║       Arch Linux / CachyOS / Manjaro (Wayland)       ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ── Detect package manager ────────────────────────────────────
if command -v pacman &>/dev/null; then
    PKG_MGR="pacman"
elif command -v yay &>/dev/null; then
    PKG_MGR="yay"
elif command -v paru &>/dev/null; then
    PKG_MGR="paru"
else
    echo -e "${RED}[✗] No supported package manager found (pacman/yay/paru)${NC}"
    exit 1
fi
echo -e "  ${GREEN}✓${NC} Detected package manager: ${PKG_MGR}"

# ── 1. Install Dependencies ──────────────────────────────────
echo -e "\n${YELLOW}[1/6]${NC} Installing dependencies..."
sudo pacman -Syu --needed --noconfirm \
    jdk21-openjdk \
    wget \
    axel \
    git

# Install xorg-xwayland for Wayland compatibility (optional but recommended)
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    echo -e "  ${CYAN}ℹ${NC} Wayland session detected, installing XWayland..."
    sudo pacman -S --needed --noconfirm xorg-xwayland 2>/dev/null || true
fi

# ── 2. Set Java 21 as default ────────────────────────────────
echo -e "\n${YELLOW}[2/6]${NC} Setting Java 21 as default..."

# List available Java versions
echo -e "  Available Java environments:"
archlinux-java status 2>/dev/null || true

sudo archlinux-java set java-21-openjdk 2>/dev/null || {
    echo -e "  ${YELLOW}⚠${NC} Could not auto-set Java 21. Trying alternative names..."
    # Try common alternative names on CachyOS/Manjaro
    for name in "java-21-openjdk" "java-21-jdk" "jdk-21"; do
        if sudo archlinux-java set "$name" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} Set Java to: $name"
            break
        fi
    done
}

JAVA_VER=$(java -version 2>&1 | head -1)
echo -e "  ${GREEN}✓${NC} Active Java: ${JAVA_VER}"

# Verify it's Java 21
if ! java -version 2>&1 | grep -q '"21'; then
    echo -e "  ${RED}⚠ WARNING:${NC} Java version does not appear to be 21!"
    echo -e "  Run: ${CYAN}sudo archlinux-java set java-21-openjdk${NC}"
    read -rp "  Continue anyway? [y/N]: " cont
    [[ ! "$cont" =~ ^[Yy]$ ]] && exit 1
fi

# ── 3. Download Burp Suite Professional JAR ──────────────────
echo -e "\n${YELLOW}[3/6]${NC} Downloading Burp Suite Professional (latest)..."
JAR_FILE="${INSTALL_DIR}/burpsuite_pro_v${VERSION}.jar"
URL="https://portswigger-cdn.net/burp/releases/download?product=pro&type=Jar"

if [ -f "$JAR_FILE" ]; then
    SIZE=$(du -h "$JAR_FILE" | cut -f1)
    echo -e "  ${GREEN}✓${NC} JAR already exists: $(basename "$JAR_FILE") (${SIZE})"
    read -rp "  Re-download latest? [y/N]: " redownload
    if [[ "$redownload" =~ ^[Yy]$ ]]; then
        rm -f "$JAR_FILE"
        axel "$URL" -o "$JAR_FILE"
    fi
else
    axel "$URL" -o "$JAR_FILE"
fi

# ── 4. Create Wayland-aware launcher script ──────────────────
echo -e "\n${YELLOW}[4/6]${NC} Creating Wayland-aware launcher script..."

cat > "${INSTALL_DIR}/burpsuitepro" << 'LAUNCHER'
#!/bin/bash
# ─────────────────────────────────────────────────────
#  Spydomain — Burp Suite Professional Launcher
#  Supports: Wayland (XWayland) + X11 + native Wayland
# ─────────────────────────────────────────────────────

INSTALL_DIR="PLACEHOLDER_DIR"
VERSION="PLACEHOLDER_VER"

WAYLAND_FLAG=""

# Auto-detect Wayland and apply compatibility
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    export _JAVA_AWT_WM_NONREPARENTING=1

    if [ "$1" = "--wayland-native" ]; then
        # Experimental: Java 21+ native Wayland rendering
        WAYLAND_FLAG="-Dawt.toolkit.name=WLToolkit"
        echo "[Spydomain] Using EXPERIMENTAL native Wayland toolkit"
    else
        export GDK_BACKEND=x11
        echo "[Spydomain] Using XWayland fallback (stable)"
    fi
fi

java \
    --add-opens=java.desktop/javax.swing=ALL-UNNAMED \
    --add-opens=java.base/java.lang=ALL-UNNAMED \
    --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED \
    --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED \
    --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED \
    -javaagent:"${INSTALL_DIR}/loader.jar" \
    -noverify \
    ${WAYLAND_FLAG} \
    -jar "${INSTALL_DIR}/burpsuite_pro_v${VERSION}.jar" &
LAUNCHER

# Replace placeholders
sed -i "s|PLACEHOLDER_DIR|${INSTALL_DIR}|g" "${INSTALL_DIR}/burpsuitepro"
sed -i "s|PLACEHOLDER_VER|${VERSION}|g" "${INSTALL_DIR}/burpsuitepro"
chmod +x "${INSTALL_DIR}/burpsuitepro"

# ── 5. Install system-wide ───────────────────────────────────
echo -e "\n${YELLOW}[5/6]${NC} Installing 'burpsuitepro' to /usr/local/bin..."
sudo cp "${INSTALL_DIR}/burpsuitepro" /usr/local/bin/burpsuitepro
sudo chmod +x /usr/local/bin/burpsuitepro
echo -e "  ${GREEN}✓${NC} Command 'burpsuitepro' available globally"

# ── 6. Create .desktop entry for app launchers ───────────────
echo -e "\n${YELLOW}[6/6]${NC} Creating desktop entry..."

DESKTOP_FILE="$HOME/.local/share/applications/spydomain-burpsuite.desktop"
mkdir -p "$(dirname "$DESKTOP_FILE")"

ICON_PATH="${INSTALL_DIR}/burp_suite.ico"
[ ! -f "$ICON_PATH" ] && ICON_PATH="utilities-terminal"

cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Spydomain - Burp Suite Pro
Comment=Web Security Testing Toolkit — Spydomain
Exec=/usr/local/bin/burpsuitepro
Icon=${ICON_PATH}
Terminal=false
Type=Application
Categories=Development;Security;Network;
Keywords=burp;proxy;security;pentest;web;spydomain;
StartupWMClass=burp-StartBurp
EOF

echo -e "  ${GREEN}✓${NC} Desktop entry: ${DESKTOP_FILE}"

# ── Done ──────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}  ╔══════════════════════════════════════════════════════╗"
echo -e "  ║        Spydomain — Installation Complete! ✓           ║"
echo -e "  ╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}Run:${NC}          burpsuitepro"
echo -e "  ${CYAN}Wayland:${NC}      burpsuitepro --wayland-native  (experimental)"
echo ""
echo -e "  ${YELLOW}License Activation:${NC}"
echo "    1. Copy license from Loader → paste into Burp Suite"
echo "    2. Choose 'Manual Activation'"
echo "    3. Copy Request from Burp → paste into Loader"
echo "    4. Copy Response from Loader → paste into Burp"
echo "    5. Click Activate"
echo ""

read -rp "Launch Burp Suite now? [Y/n]: " launch
if [[ ! "$launch" =~ ^[Nn]$ ]]; then
    echo -e "${CYAN}[*] Starting Loader keygen...${NC}"
    (java -jar "${INSTALL_DIR}/loader.jar") &
    sleep 2
    echo -e "${CYAN}[*] Starting Burp Suite Professional...${NC}"
    "${INSTALL_DIR}/burpsuitepro"
fi
