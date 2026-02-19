---
description: Operational rules for AI agents managing the trading stack
---

# Trading Agent Operations Skill

## Purpose
Rules for AI agents managing crypto trading infrastructure. Follow these rules strictly.

## Operational Rules (WAJIB)

### Rule 1: Layer Isolation
- **Jangan** mix Browser Layer 1 + Layer 2 dalam 1 task
- Default ke **satu layer per task** kecuali ada alasan jelas

### Rule 2: CDP Safety 
- Jangan jalankan Layer 2 kalau CDP belum ready
- **Wajib cek**: `curl http://127.0.0.1:9333/json/version`
- **Jangan** pakai Layer 2 untuk situs sensitif (banking, password manager)

### Rule 3: Login Handling
- Login selalu prefer **Layer 2** (existing session)
- Jangan suruh Layer 1 "coba login" — bikin state kacau

### Rule 4: Trading Safety
- **Selalu paper trade dulu** sebelum live
- Alert ke Telegram sebelum switch regime
- Never switch strategy saat ada open position tanpa konfirmasi

### Rule 5: Memory Routing
- Gunakan `memory-router.md` skill untuk query routing
- Start dengan **Mem0** untuk 80% query
- Escalate ke Qdrant/Neo4j hanya saat Mem0 tidak cukup

## Regime Detection Flow (1h interval)
```
1. Get market data (CCXT/TA-Lib)
2. Run HMM state detection
3. Classify: Bull / Bear / Range
4. If regime changed:
   a. Alert Telegram: "Regime changed: Bull → Bear"
   b. If no open position → switch strategy
   c. If open position → alert only, wait close
5. Log to memory (Mem0)
```

## Emergency Commands
```bash
# Stop Freqtrade trading
docker stop freqtrade

# Stop all Docker services 
docker compose -f ~/Projects/browser-agent-hub/docker-compose.yml down

# Kill Chrome CDP (emergency)
pkill -f "remote-debugging-port=9333"
```
