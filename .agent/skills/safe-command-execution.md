---
description: Detect and prevent blocking/looping commands before execution
---

# Safe Command Execution Skill

## Purpose
Skill ini WAJIB dibaca sebelum menjalankan `run_command`. Tujuannya: **deteksi command yang akan block/loop selamanya**, lalu pilih alternatif aman atau suruh user jalankan manual.

---

## 🔴 BLACKLIST — Jangan Pernah Jalankan via run_command

| Pattern | Kenapa Block | Alternatif |
|:--|:--|:--|
| `read -r` / `read -p` | Menunggu input keyboard | Skip, atau gunakan `echo "" \|` pipe |
| `npx <mcp-server>` (tanpa --help) | Server jalan selamanya | Cek `command -v npx` saja |
| `npx ... --help` | Download dulu, bisa prompt | Cek `command -v npx` saja |
| `python -m http.server` | Server jalan selamanya | Suruh user jalankan manual |
| `docker run` (tanpa `-d`) | Container foreground selamanya | Tambah `-d` atau suruh user |
| `npm start` / `npm run dev` | Dev server selamanya | Suruh user jalankan manual |
| `tail -f` | Follow log selamanya | Gunakan `tail -n 20` |
| `watch` | Loop selamanya | Jalankan command 1x saja |
| `ssh` / `telnet` | Interactive session | Suruh user |
| Script yang mengandung `read` | Tunggu Enter | Review script dulu, pipe echo |

---

## 🟡 CAUTION — Butuh Safeguard

| Pattern | Risiko | Safeguard |
|:--|:--|:--|
| `curl` tanpa timeout | Server lambat = hang | Selalu `--max-time 3` |
| `git clone` repo besar | Lama | `--depth 1` |
| `pip install` banyak package | Lama | `--quiet`, max 3 packages |
| `sleep N` (N > 5) | Lambat tanpa alasan | Kurangi, atau hapus |
| Background `&` + `sleep` | Spawn zombie | Jangan gabungkan |
| Chain panjang `&&` (>5) | Kalau 1 hang, semua hang | Pecah jadi beberapa command |

---

## ✅ SAFE — Selalu Aman

| Pattern | Kenapa Aman |
|:--|:--|
| `ls`, `cat`, `head`, `tail -n` | Read-only, instant |
| `grep`, `find`, `wc` | Read-only, instant |
| `python -c "import X; print()"` | One-shot, exit sendiri |
| `curl --max-time N` | Guaranteed timeout |
| `command -v X` | Check binary, instant |
| `echo`, `printf` | No side effects |

---

## Decision Flow — Sebelum run_command

```
SEBELUM jalankan command, tanya:

Q1: Apakah command ini akan EXIT sendiri dalam < 10 detik?
  NO → JANGAN jalankan. Cari alternatif atau suruh user.
  YES → ↓

Q2: Apakah command ini butuh INPUT dari keyboard?
  YES → JANGAN jalankan. Pipe echo atau suruh user.
  NO → ↓

Q3: Apakah command ini start SERVER atau LONG-RUNNING PROCESS?
  YES → JANGAN jalankan. Cek availability saja, suruh user.
  NO → ↓

Q4: Apakah ada curl/wget TANPA --max-time?
  YES → Tambahkan --max-time 3.
  NO → ↓

✅ AMAN — Boleh jalankan.
```

---

## Aksi Saat Mendeteksi Blocking Command

**Opsi A — Ganti metode (preferred):**
```
TERDETEKSI: `npx chrome-devtools-mcp@latest --help`
MASALAH: npx download + possible prompt
ALTERNATIF: `command -v npx && echo "OK"` ← cek binary saja
→ Jalankan alternatif
```

**Opsi B — Suruh user jalankan manual:**
```
TERDETEKSI: `bash scripts/chrome-launch.sh`
MASALAH: Script punya `read -r` (tunggu Enter)
→ Beritahu user: "Jalankan ini di terminal Anda sendiri:"
→ Berikan command yang siap copy-paste
→ Lanjutkan task setelah user konfirmasi
```

**Opsi C — Timeout & Kill (untuk command yang mungkin lambat):**
```
TERDETEKSI: `curl https://api-lambat.com/data`
AKSI:
  1. Jalankan dengan WaitMsBeforeAsync=3000
  2. Kalau return background ID → command_status(wait=5s)
  3. Kalau masih RUNNING → send_command_input(Terminate=true)
  4. Laporkan: "Command timeout, kemungkinan server lambat"
```

**Opsi D — Pre-scan script sebelum eksekusi:**
```
TERDETEKSI: `bash scripts/unknown.sh`
AKSI:
  1. view_file("scripts/unknown.sh") ← baca isi dulu
  2. Scan untuk: read, sleep >5, while true, server start
  3. Kalau aman → jalankan
  4. Kalau ada blocking pattern → pilih Opsi A/B/C
```

**Opsi E — Ganti run_command dengan tool lain (paling aman):**
```
TUJUAN: Cek apakah file "9222" ada di project
❌ run_command: grep -rn "9222" ~/Projects/
✅ grep_search: query="9222", SearchPath="~/Projects/"
→ Guaranteed selesai, zero risk hang

TUJUAN: Cek apakah folder/file ada
❌ run_command: ls -la ~/some/path
✅ list_dir: DirectoryPath="~/some/path"
✅ find_by_name: Pattern="*.json"
→ Guaranteed selesai, zero risk hang

TUJUAN: Baca isi file
❌ run_command: cat ~/file.txt
✅ view_file: AbsolutePath="~/file.txt"
→ Guaranteed selesai, zero risk hang
```

---

## Contoh Penerapan

### ❌ SALAH
```bash
# Menjalankan server via run_command
npx chrome-devtools-mcp@latest --browser-url=http://127.0.0.1:9333
# RESULT: Stuck selamanya
```

### ✅ BENAR
```bash
# Cek apakah tool available saja
command -v npx && echo "chrome-devtools-mcp ready via npx $(npx --version)"
# RESULT: Selesai < 1 detik
```

### ❌ SALAH
```bash
# Jalankan script interactive
bash scripts/chrome-launch.sh
# RESULT: Stuck di `read -r`
```

### ✅ BENAR
```
# Beritahu user
"Jalankan di terminal Anda: bash ~/Projects/browser-agent-hub/scripts/chrome-launch.sh"
# RESULT: User eksekusi sendiri, tekan Enter sendiri
```
