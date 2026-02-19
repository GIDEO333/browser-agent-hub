# 🤖 Browser Agent Hub

Sistem browser automation 3 layer untuk AI Agent (Cursor / Antigravity IDE).

## Cara Kerja

```
AI Agent (Cursor/Antigravity)
        ↓
  .agent/skills/browser-router.md   ← AI baca ini untuk PILIH layer
        ↓
┌───────────────────────────────────────────────────┐
│  Layer 1 (Stealth)  │  Layer 2 (Session)  │  Layer 3 (Brain)  │
│  stealth-browser-mcp│  chrome-devtools-mcp│  browser-use      │
│  Bypass Cloudflare  │  Pakai login yg ada │  AI multi-step    │
└───────────────────────────────────────────────────┘
        ↓
     Chrome Browser
```

## Quick Start

```bash
git clone https://github.com/GIDEO333/browser-agent-hub
cd browser-agent-hub
bash scripts/install.sh
```

Lalu ikuti instruksi yang muncul di terminal.

## File Structure

```
browser-agent-hub/
├── .agent/skills/
│   └── browser-router.md       ← CORE: AI agent routing logic
├── configs/
│   ├── mcp-cursor.json         ← Copy ke ~/.cursor/mcp.json
│   └── mcp-antigravity.json    ← Copy ke ~/.config/antigravity/mcp.json
├── scripts/
│   ├── chrome-launch.sh        ← Launch Chrome dengan CDP port 9333
│   └── install.sh              ← Setup semua dependencies
└── README.md
```

## Layer Summary

| Layer | Repo | Status | Gunakan Untuk |
|---|---|---|---|
| 1 - Stealth | [vibheksoni/stealth-browser-mcp](https://github.com/vibheksoni/stealth-browser-mcp) | ✅ Aktif v0.2.5 (Feb 2026) | Situs dengan Cloudflare/antibot |
| 2 - Session | [ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp) | ✅ Aktif Google (Feb 2026) | Akun yang sudah login |
| 3 - Brain | [browser-use/browser-use](https://github.com/browser-use/browser-use) | ✅ Sangat aktif (Feb 2026) | Task multi-step dengan AI |

## ⚠️ Security Notes

- Tutup Chrome normal sebelum jalankan `chrome-launch.sh`
- Jangan buka banking/password manager saat port 9333 aktif
- Port 9333 hanya aktif saat kamu butuh Layer 2
- Tutup Chrome CDP setelah selesai pakai Layer 2

## Cara AI Agent Milih Layer

AI agent baca `.agent/skills/browser-router.md` dan ikuti decision tree:

```
Butuh akun yg sudah login?  → YES → Layer 2
Site ada Cloudflare/antibot? → YES → Layer 1
Task multi-step AI decision? → YES → Layer 3
Default (scraping biasa)     →       Layer 1
```
