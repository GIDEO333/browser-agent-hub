#!/bin/bash
# ================================================
# Install Script — Browser Agent Hub
# Setup Layer 1 (stealth), Layer 2 (CDP), Layer 3 (browser-use)
# ================================================

set -e

echo ""
echo "================================================"
echo "  Browser Agent Hub — Installer"
echo "================================================"
echo ""

# --- Cek dependencies ---
echo "🔍 Cek dependencies..."

if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 tidak ditemukan. Install dulu."
    exit 1
fi

if ! command -v npx &> /dev/null; then
    echo "❌ npx tidak ditemukan. Install Node.js dari: https://nodejs.org"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "❌ git tidak ditemukan. Install git dulu."
    exit 1
fi

echo "✅ Python3: $(python3 --version)"
echo "✅ npx: $(npx --version)"
echo "✅ git: $(git --version | head -1)"
echo ""

# --- Layer 1: stealth-browser-mcp ---
echo "📦 [Layer 1] Menginstall stealth-browser-mcp..."

INSTALL_DIR="$HOME/browser-agent-tools"
mkdir -p "$INSTALL_DIR"

if [ ! -d "$INSTALL_DIR/stealth-browser-mcp" ]; then
    git clone https://github.com/vibheksoni/stealth-browser-mcp.git "$INSTALL_DIR/stealth-browser-mcp"
    echo "   ✅ Cloned."
else
    echo "   ℹ️  Sudah ada, pull update..."
    git -C "$INSTALL_DIR/stealth-browser-mcp" pull
fi

(
    cd "$INSTALL_DIR/stealth-browser-mcp"
    python3 -m venv venv
    source venv/bin/activate
    pip install --quiet -r requirements.txt
    deactivate
)

STEALTH_PYTHON="$INSTALL_DIR/stealth-browser-mcp/venv/bin/python"
STEALTH_SERVER="$INSTALL_DIR/stealth-browser-mcp/src/server.py"

echo "✅ Layer 1 ready!"
echo ""

# --- Layer 2: chrome-devtools-mcp (via npx, tidak perlu install) ---
echo "📦 [Layer 2] chrome-devtools-mcp..."
command -v npx >/dev/null 2>&1 && echo "✅ Layer 2 ready! (npx $(npx --version), auto-download saat diperlukan)" || echo "❌ npx not found — install Node.js"
echo ""

# --- Layer 3: browser-use ---
echo "📦 [Layer 3] Menginstall browser-use..."
TOOLS_VENV="$HOME/tools-venv"
if [ ! -d "$TOOLS_VENV" ]; then
    python3 -m venv "$TOOLS_VENV"
fi
"$TOOLS_VENV/bin/pip" install --quiet browser-use mem0ai
echo "✅ Layer 3 + Mem0 ready! (venv: $TOOLS_VENV)"
echo ""

# --- Generate MCP Config ---
echo "📝 Generate MCP config..."

MCP_CONFIG="{
  \"mcpServers\": {
    \"stealth-browser\": {
      \"command\": \"$STEALTH_PYTHON\",
      \"args\": [\"$STEALTH_SERVER\"]
    },
    \"chrome-devtools\": {
      \"command\": \"npx\",
      \"args\": [
        \"chrome-devtools-mcp@latest\",
        \"--browser-url=http://127.0.0.1:9333\",
        \"--no-usage-statistics\",
        \"-y\"
      ]
    }
  }
}"

echo "$MCP_CONFIG" > /tmp/browser-agent-mcp.json
echo "✅ Config tersimpan di: /tmp/browser-agent-mcp.json"
echo ""

# --- Selesai ---
echo "================================================"
echo "✅ INSTALASI SELESAI!"
echo "================================================"
echo ""
echo "📋 LANGKAH SELANJUTNYA:"
echo ""
echo "1️⃣  Copy MCP config ke Cursor:"
echo "    cp /tmp/browser-agent-mcp.json ~/.cursor/mcp.json"
echo ""
echo "    Atau untuk Antigravity:"
echo "    cp /tmp/browser-agent-mcp.json ~/.config/antigravity/mcp.json"
echo ""
echo "2️⃣  Copy skill ke project kamu:"
echo "    mkdir -p YOUR_PROJECT/.agent/skills"
echo "    cp $(pwd)/../.agent/skills/browser-router.md YOUR_PROJECT/.agent/skills/"
echo ""
echo "3️⃣  Untuk Layer 2 (existing session):"
echo "    bash scripts/chrome-launch.sh"
echo ""
echo "4️⃣  Restart Cursor/Antigravity IDE"
echo ""
echo "5️⃣  Test dengan prompt:"
echo "    \"Gunakan skill browser-router. Cek apakah port 9333 aktif. Lalu screenshot google.com\""
echo ""
echo "================================================"
