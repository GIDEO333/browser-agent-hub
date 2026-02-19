# Tradeoff Analysis — Pilih Layer Yang Tepat

## Quick Decision Cheatsheet

| Situasi | Layer | Kenapa |
|---|---|---|
| Bypass Cloudflare | Layer 1 | nodriver tidak punya automation signature |
| Scraping data publik | Layer 1 | Paling ringan, tidak perlu login |
| Akun exchange sudah login | Layer 2 | Pakai session yang ada, tidak perlu re-auth |
| Sosmed automation (sudah login) | Layer 2 | Session + cookies aktif |
| Research multi-situs kompleks | Layer 3 | AI yang buat keputusan, bukan kamu |
| Trading price comparison | Layer 1 + Layer 3 | Stealth untuk fetch, AI untuk analisis |

---

## Layer 1 — Stealth Browser

**Pros:**
- Bypass Cloudflare, Queue-It, antibot detection berat
- 90+ tools tersedia
- Fingerprint spoofing (WebGL, canvas, font, timezone)
- Spawn browser bersih — tidak bawa history/cookies lama
- Aktif dikembangkan (v0.2.5, Feb 2026)

**Cons:**
- Browser baru = tidak ada session login
- Butuh Python + venv setup
- Lebih berat dari CDP langsung
- Jika target detect nodriver, perlu update library

**Best for:** Scraping, price fetching, data extraction dari situs publik

---

## Layer 2 — Existing Session (CDP)

**Pros:**
- Pakai semua session yang sudah login
- Google-maintained = stabil dan aktif
- Tidak perlu login ulang di script
- Puppeteer backend = tidak set `navigator.webdriver=true`
- Bisa intercept network request

**Cons:**
- Chrome harus dilaunch manual dengan flag khusus
- Port 9222 membuka attack surface keamanan
- Bot detection level Cloudflare bisa masih terdeteksi
- Harus tutup semua Chrome window sebelum launch

**Best for:** Exchange dashboard, email, sosmed dengan akun yang sudah login

---

## Layer 3 — AI Brain (browser-use)

**Pros:**
- AI buat keputusan sendiri — tidak perlu script step-by-step
- Handle halaman yang struktur-nya tidak diketahui sebelumnya
- Bisa retry sendiri jika gagal
- Community sangat aktif (commit hari ini, Feb 2026)

**Cons:**
- Token-heavy = biaya API lebih tinggi
- Lebih lambat dari script langsung
- Butuh LLM API key
- Tidak secanggih Layer 1 untuk stealth

**Best for:** Research kompleks, workflow multi-situs, task yang unpredictable

---

## Kombinasi Recommended

### Untuk Trading Bot Research
```
Layer 1 → Fetch harga dari exchange/DeFi (stealth)
Layer 3 → Analisis dan bandingkan (AI decision)
```

### Untuk Sosmed Monitoring
```
Layer 2 → Baca feed/notifikasi (session aktif)
Layer 1 → Scrape profil publik (stealth)
```

### Untuk Full Automation
```
Layer 2 → Aksi di akun (login session)
Layer 1 → Riset data eksternal (stealth)
Layer 3 → Orchestrasi keseluruhan (AI brain)
```

---

## Status Repo (Update Feb 2026)

| Repo | Last Commit | Stars | Verdict |
|---|---|---|---|
| vibheksoni/stealth-browser-mcp | Feb 10, 2026 | Growing | ✅ Pakai |
| ChromeDevTools/chrome-devtools-mcp | Feb 18, 2026 | Maintained by Google | ✅ Pakai |
| browser-use/browser-use | Feb 19, 2026 | 40k+ | ✅ Pakai |
| BrowserMCP/mcp | Apr 2025 | 5.3k (stagnan) | ❌ Skip |
| merajmehrabi/puppeteer-mcp | Mar 2025 | Kecil | ❌ Skip (stale) |
