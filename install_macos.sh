#!/bin/bash
# ============================================================
#  Spydomain — Burp Suite Professional Installer
#  Platform: macOS (Intel + Apple Silicon)
#  Repository: https://github.com/povzayd/Burpsuite-Professional
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION=2025

echo -e "${CYAN}"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║       Spydomain — Burp Suite Pro Installer       ║"
echo "  ║                    macOS                         ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ── 1. Install Homebrew + Dependencies ───────────────────────
echo -e "${YELLOW}[1/5]${NC} Checking Homebrew and dependencies..."

if ! command -v brew &>/dev/null; then
    echo -e "  Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew install git openjdk@21 axel wget 2>/dev/null || true

# ── 2. Set Java 21 ──────────────────────────────────────────
echo -e "${YELLOW}[2/5]${NC} Configuring Java 21..."

JAVA_HOME_PATH="$(brew --prefix openjdk@21)/libexec/openjdk.jdk/Contents/Home"
if [ -d "$JAVA_HOME_PATH" ]; then
    export JAVA_HOME="$JAVA_HOME_PATH"
    export PATH="$JAVA_HOME/bin:$PATH"

    # Add to shell profile if not already there
    SHELL_RC="$HOME/.zshrc"
    [ -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.bashrc"

    if ! grep -q "openjdk@21" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# Spydomain — Java 21 for Burp Suite" >> "$SHELL_RC"
        echo "export JAVA_HOME=\"${JAVA_HOME_PATH}\"" >> "$SHELL_RC"
        echo "export PATH=\"\$JAVA_HOME/bin:\$PATH\"" >> "$SHELL_RC"
        echo -e "  ${GREEN}✓${NC} Java 21 added to ${SHELL_RC}"
    fi
fi

JAVA_VER=$(java -version 2>&1 | head -1)
echo -e "  ${GREEN}✓${NC} Active Java: ${JAVA_VER}"

# ── 3. Download Burp Suite Professional JAR ──────────────────
echo -e "${YELLOW}[3/5]${NC} Downloading Burp Suite Professional (latest)..."
JAR_FILE="${INSTALL_DIR}/burpsuite_pro_v${VERSION}.jar"
URL="https://portswigger-cdn.net/burp/releases/download?product=pro&type=Jar"

if [ -f "$JAR_FILE" ]; then
    SIZE=$(du -h "$JAR_FILE" | awk '{print $1}')
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
# Spydomain — Burp Suite Professional Launcher (macOS)
export JAVA_HOME="${JAVA_HOME_PATH}"
export PATH="\$JAVA_HOME/bin:\$PATH"

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

# ── 5. Install globally ─────────────────────────────────────
echo -e "${YELLOW}[5/5]${NC} Installing to /usr/local/bin..."
sudo cp "${INSTALL_DIR}/burpsuitepro" /usr/local/bin/burpsuitepro
sudo chmod +x /usr/local/bin/burpsuitepro
echo -e "  ${GREEN}✓${NC} Command 'burpsuitepro' available globally"

# ── Done ──────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}  ╔══════════════════════════════════════════════════╗"
echo -e "  ║       Spydomain — Installation Complete! ✓        ║"
echo -e "  ╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}Run:${NC}  burpsuitepro"
echo ""

echo -e "${CYAN}[*] Starting Loader keygen...${NC}"
(java -jar "${INSTALL_DIR}/loader.jar") &
sleep 2
echo -e "${CYAN}[*] Starting Burp Suite Professional...${NC}"
"${INSTALL_DIR}/burpsuitepro"
