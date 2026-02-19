#!/bin/bash
# ================================================
# Chrome CDP Launch Script — Layer 2
# Gunakan ini untuk pakai sesi browser yang sudah login
# ================================================

echo ""
echo "================================================"
echo "  Chrome CDP Launcher — Layer 2"
echo "================================================"
echo ""
echo "⚠️  PENTING: Tutup semua Chrome window dulu!"
echo "   Jika Chrome masih jalan, script ini akan gagal."
echo ""
echo "Tekan Enter untuk lanjut, atau Ctrl+C untuk batal..."
read -r

# --- Deteksi OS ---
if [[ "$OSTYPE" == "darwin"* ]]; then
    CHROME_BIN="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    PROFILE_DIR="$HOME/Library/Application Support/Google/Chrome"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Coba beberapa binary name yang umum
    if command -v google-chrome &> /dev/null; then
        CHROME_BIN="google-chrome"
    elif command -v google-chrome-stable &> /dev/null; then
        CHROME_BIN="google-chrome-stable"
    elif command -v chromium-browser &> /dev/null; then
        CHROME_BIN="chromium-browser"
    else
        echo "❌ Chrome/Chromium tidak ditemukan. Install dulu."
        exit 1
    fi
    PROFILE_DIR="$HOME/.config/google-chrome"
else
    echo "❌ OS tidak dikenali. Edit script ini manual untuk Windows."
    exit 1
fi

# --- Cek Chrome ada ---
if [[ "$OSTYPE" == "darwin"* ]] && [ ! -f "$CHROME_BIN" ]; then
    echo "❌ Chrome tidak ditemukan di: $CHROME_BIN"
    echo "   Install dari: https://www.google.com/chrome/"
    exit 1
fi

# --- Launch Chrome ---
echo "🚀 Launching Chrome dengan CDP..."
echo "   Profile: $PROFILE_DIR"
echo "   Debug Port: 9222"
echo ""

"$CHROME_BIN" \
    --remote-debugging-port=9222 \
    --user-data-dir="$PROFILE_DIR" \
    --profile-directory="Default" \
    --no-first-run \
    --disable-infobars \
    &

# --- Tunggu Chrome ready ---
echo "⏳ Menunggu Chrome siap..."
sleep 3

# --- Verifikasi ---
if curl -s http://localhost:9222/json/version > /dev/null 2>&1; then
    echo "✅ Chrome berhasil launch di port 9222!"
    echo ""
    echo "ℹ️  Info:"
    curl -s http://localhost:9222/json/version | python3 -m json.tool 2>/dev/null || \
    curl -s http://localhost:9222/json/version
    echo ""
    echo "⚠️  SECURITY REMINDER:"
    echo "   - Port 9222 terbuka dan bisa diakses oleh proses lain di mesin ini"
    echo "   - Jangan buka banking atau password manager sekarang"
    echo "   - Tutup Chrome ini setelah selesai menggunakan Layer 2"
    echo ""
    echo "📋 Untuk AI Agent (Cursor/Antigravity):"
    echo "   chrome-devtools MCP server sudah bisa connect ke session kamu"
else
    echo "❌ Chrome tidak berhasil start atau port 9222 tidak accessible"
    echo "   Pastikan tidak ada Chrome lain yang berjalan"
    echo "   Coba tutup semua Chrome dan jalankan script ini lagi"
    exit 1
fi
