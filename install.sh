#!/bin/bash
# ============================================================
#  Spydomain — Burp Suite Professional Installer
#  Platform: Debian / Ubuntu / Kali Linux
#  Repository: https://github.com/Spydomain/burpsuite-pro
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

REPO_URL="https://github.com/Spydomain/burpsuite-pro.git"
VERSION=2025

echo -e "${CYAN}"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║       Spydomain — Burp Suite Pro Installer       ║"
echo "  ║            Debian / Ubuntu / Kali Linux          ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ── Detect run mode (piped vs local) and set INSTALL_DIR ─────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}" 2>/dev/null)" && pwd 2>/dev/null || pwd)"

if [ -f "${SCRIPT_DIR}/loader.jar" ]; then
    # Running from cloned repo directory
    INSTALL_DIR="$SCRIPT_DIR"
else
    # Running via pipe (wget ... | bash) — need to clone the repo
    INSTALL_DIR="/opt/Spydomain"
    echo -e "${YELLOW}[*]${NC} Piped install detected — cloning repository to ${INSTALL_DIR}..."
    sudo mkdir -p "$INSTALL_DIR"
    if [ -d "${INSTALL_DIR}/.git" ]; then
        echo -e "  ${GREEN}✓${NC} Repository already exists, pulling latest..."
        sudo git -C "$INSTALL_DIR" pull --ff-only || true
    else
        sudo git clone "$REPO_URL" "$INSTALL_DIR"
    fi
    echo -e "  ${GREEN}✓${NC} Repository ready at ${INSTALL_DIR}"
fi

# ── 1. Install Dependencies ──────────────────────────────────
echo -e "${YELLOW}[1/5]${NC} Installing dependencies..."
sudo apt update
sudo apt install -y git axel wget openjdk-21-jre openjdk-21-jdk

# ── 2. Set Java 21 as default ────────────────────────────────
echo -e "${YELLOW}[2/5]${NC} Setting Java 21 as default..."
JAVA21_PATH="/usr/lib/jvm/java-21-openjdk-amd64/bin/java"
if [ -f "$JAVA21_PATH" ]; then
    sudo update-alternatives --set java "$JAVA21_PATH" 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Java 21 set as default"
else
    echo -e "  ${YELLOW}⚠${NC} Java 21 path not found at expected location, trying update-alternatives..."
    sudo update-alternatives --config java
fi
java -version 2>&1 | head -1

# ── 3. Download Burp Suite Professional JAR ──────────────────
echo -e "${YELLOW}[3/5]${NC} Downloading Burp Suite Professional (latest)..."
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

# ── 4. Create launcher script ────────────────────────────────
echo -e "${YELLOW}[4/5]${NC} Creating launcher script..."

cat > "${INSTALL_DIR}/burpsuitepro" << EOF
#!/bin/bash
# Spydomain — Burp Suite Professional Launcher
java \\
    --add-opens=java.desktop/javax.swing=ALL-UNNAMED \\
    --add-opens=java.base/java.lang=ALL-UNNAMED \\
    --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED \\
    --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED \\
    --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED \\
    -javaagent:${INSTALL_DIR}/loader.jar \\
    -noverify \\
    -jar ${INSTALL_DIR}/burpsuite_pro_v${VERSION}.jar &
EOF

chmod +x "${INSTALL_DIR}/burpsuitepro"
sudo cp "${INSTALL_DIR}/burpsuitepro" /usr/local/bin/burpsuitepro 2>/dev/null || \
sudo cp "${INSTALL_DIR}/burpsuitepro" /bin/burpsuitepro
echo -e "  ${GREEN}✓${NC} Command 'burpsuitepro' installed globally"

# ── 5. Create desktop entry ──────────────────────────────────
echo -e "${YELLOW}[5/5]${NC} Creating desktop entry..."

DESKTOP_FILE="$HOME/.local/share/applications/spydomain-burpsuite.desktop"
mkdir -p "$(dirname "$DESKTOP_FILE")"

cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Spydomain - Burp Suite Pro
Comment=Web Security Testing Toolkit
Exec=/usr/local/bin/burpsuitepro
Icon=${INSTALL_DIR}/burp_suite.ico
Terminal=false
Type=Application
Categories=Development;Security;Network;
Keywords=burp;proxy;security;pentest;web;spydomain;
StartupWMClass=burp-StartBurp
EOF

echo -e "  ${GREEN}✓${NC} Desktop entry created"

# ── Launch ────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}  ╔══════════════════════════════════════════════════╗"
echo -e "  ║       Spydomain — Installation Complete! ✓        ║"
echo -e "  ╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}Run:${NC}  burpsuitepro"
echo ""
echo -e "  ${YELLOW}License Activation:${NC}"
echo "    1. Copy license from Loader → paste into Burp Suite"
echo "    2. Choose 'Manual Activation'"
echo "    3. Copy Request from Burp → paste into Loader"
echo "    4. Copy Response from Loader → paste into Burp"
echo "    5. Click Activate"
echo ""

echo -e "${CYAN}[*] Starting Loader keygen...${NC}"
(java -jar "${INSTALL_DIR}/loader.jar") &
sleep 2
echo -e "${CYAN}[*] Starting Burp Suite Professional...${NC}"
"${INSTALL_DIR}/burpsuitepro"
