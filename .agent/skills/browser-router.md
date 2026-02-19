# Browser Router Skill

## Purpose
Skill ini mengajarkan AI agent cara **memilih layer browser automation** yang tepat berdasarkan jenis task.
Baca skill ini sebelum melakukan APAPUN yang berkaitan dengan browser.

---

## 3 Layer Yang Tersedia

### Layer 1 — Stealth Browser
**MCP Server name:** `stealth-browser`
**Tech:** nodriver + Chrome DevTools Protocol

Gunakan saat:
- Target site punya Cloudflare, Queue-It, atau antibot detection
- Scraping data publik dari situs baru (tidak perlu login)
- Instagram, Twitter/X, LinkedIn, Amazon, Ticketmaster, Binance (public)
- Butuh fingerprint spoofing (WebGL, canvas, font, timezone)

Jangan gunakan saat:
- Task butuh session/cookie dari browser yang sudah login

---

### Layer 2 — Existing Session (CDP)
**MCP Server name:** `chrome-devtools`
**Tech:** Chrome DevTools Protocol — Puppeteer backend
**⚠️ PRASYARAT:** Chrome harus sudah berjalan via `scripts/chrome-launch.sh`

Gunakan saat:
- Task butuh akun yang sudah login (exchange, email, Twitter, dashboard)
- Tidak mau login ulang di script
- Butuh akses ke data di session (cart, notifikasi, inbox, portfolio)
- Butuh intercept network request dari tab yang aktif

Jangan gunakan saat:
- Chrome belum dilaunch dengan `--remote-debugging-port=9333`
- Kamu sedang di situs sensitif (banking, password manager)

---

### Layer 3 — AI Brain (browser-use)
**Cara pakai:** Jalankan Python script atau CLI
**Tech:** Python AI agent library + LLM backend

Gunakan saat:
- Task kompleks multi-step yang butuh keputusan AI
- Research: "cari semua harga X di 5 situs, bandingkan, buat laporan"
- Workflow unpredictable / butuh fallback logic sendiri
- Gabungan navigasi + ekstraksi data + analisis

Jangan gunakan saat:
- Task simpel yang bisa selesai dengan 1-3 tool call
- Kamu belum set API key (ANTHROPIC_API_KEY atau GEMINI_API_KEY)

---

## Decision Tree (Ikuti Urutan Ini)

```
START: Ada task browser?
  ↓
Q1: Task butuh AKUN YANG SUDAH LOGIN?
  YES:
    → Cek: apakah port 9333 aktif? (curl http://localhost:9333/json/version)
    → Aktif   → Gunakan LAYER 2 (chrome-devtools)
    → Tidak aktif → Beritahu user: "Jalankan scripts/chrome-launch.sh dulu"
  NO: ↓

Q2: Site target punya CLOUDFLARE / BOT DETECTION BERAT?
  Ciri-ciri: challenge page, CAPTCHA, "Are you human?", rate limit agresif
  YES → Gunakan LAYER 1 (stealth-browser)
  NO: ↓

Q3: Task butuh AI MULTI-STEP DECISION?
  Ciri-ciri: "cari", "bandingkan", "kumpulkan dari banyak sumber", "analisis"
  YES → Gunakan LAYER 3 (browser-use)
  NO  → Default: Gunakan LAYER 1 (stealth-browser)
```

---

## Tools Per Layer

### Layer 1 — stealth-browser tools
| Tool | Fungsi |
|---|---|
| `browser_navigate` | Buka URL |
| `browser_screenshot` | Screenshot halaman |
| `browser_click` | Klik elemen (CSS selector / koordinat) |
| `browser_type` | Ketik teks |
| `browser_scroll` | Scroll halaman |
| `browser_extract_content` | Ambil teks / HTML |
| `browser_wait` | Tunggu elemen / waktu |
| `browser_execute_script` | Jalankan JavaScript |
| `browser_network_intercept` | Monitor network traffic |

### Layer 2 — chrome-devtools tools
| Tool | Fungsi |
|---|---|
| `navigate_page` | Navigasi di tab yang sudah login |
| `take_screenshot` | Screenshot |
| `click` | Klik elemen |
| `fill` | Isi form input |
| `hover` | Hover elemen |
| `press_key` | Tekan keyboard |
| `handle_dialog` | Handle alert/confirm |
| `list_pages` | Lihat semua tab terbuka |
| `evaluate_script` | Jalankan JS |
| `get_network_request` | Baca network request |
| `get_console_message` | Baca console log |

### Layer 3 — browser-use
```bash
# CLI
python -m browser_use task "instruksi lengkap kamu"

# Dengan LLM pilihan
python -m browser_use task "..." --model gemini-2.0-flash
python -m browser_use task "..." --model claude-3-5-sonnet-20241022
```

---

## Rules Perilaku Manusiawi (WAJIB — Semua Layer)

1. **Screenshot dulu** sebelum mulai setiap aksi penting
2. **Tunggu 1.5–3 detik** antara setiap click (gunakan random delay)
3. **Scroll dulu** sebelum klik elemen yang mungkin di bawah viewport
4. **Jangan > 5 klik** dalam 1 menit di satu halaman yang sama
5. **Screenshot lagi** setelah setiap aksi untuk konfirmasi
6. **Jika elemen tidak ditemukan**: screenshot dulu, baru retry
7. **Tutup tab** setelah task selesai
8. **Jangan pernah** hardcode password di kode — gunakan env variable

---

## Error Handling

| Error | Kemungkinan Penyebab | Solusi |
|---|---|---|
| `Chrome not found` | Chrome tidak terinstall | Install Google Chrome |
| `Cannot connect to port 9333` | Chrome CDP belum launch | Jalankan `scripts/chrome-launch.sh` |
| `Connection refused` | MCP server tidak jalan | Restart IDE, cek mcp.json path |
| `API key missing` | Env var tidak di-set | Set ANTHROPIC_API_KEY atau GEMINI_API_KEY |
| `Cloudflare blocked` | Layer 1 masih kena detect | Coba tambah delay, atau ganti user-agent |
| `Session expired` | Cookie Layer 2 expired | Login ulang di Chrome normal dulu |
| `Timeout` | Situs lambat | Tambah wait time, screenshot untuk diagnosa |

---

## Contoh Prompt ke AI Agent

### Trading Price Research
```
Gunakan skill browser-router.
Task: Cek harga BTC/USDT di Binance dan CoinGecko.
Binance kemungkinan punya bot detection.
Ambil screenshot tiap halaman. Bandingkan harga dan laporkan selisihnya.
```

### Social Media Automation (Akun Sudah Login)
```
Gunakan skill browser-router.
Task: Buka Twitter di browser saya yang sudah login.
Like 3 tweet pertama di feed. Berperilaku seperti manusia.
Tunggu 2 detik antara tiap aksi.
```

### Multi-Site Research
```
Gunakan skill browser-router.
Task: Kumpulkan review laptop gaming 2025 dari TokoSus, Bhinneka, dan iBox.
Bandingkan harga dan spesifikasi. Buat tabel perbandingan.
```

### Check Layer 2 Availability
```
Gunakan skill browser-router.
Sebelum mulai, cek dulu apakah port 9333 aktif:
curl http://localhost:9333/json/version
Jika aktif, gunakan Layer 2. Jika tidak, beritahu user untuk jalankan chrome-launch.sh.
```
