#!/bin/bash
# ================================================
# QA Test Runner — Browser Hub 3-Layer
# SAFE: No npx, no servers, no read, no sleep
# Only: Python imports, curl with timeout, grep
# ================================================

PASS=0; FAIL=0; SKIP=0; REPORT=""
log_pass() { PASS=$((PASS+1)); REPORT+="✅ $1\n"; echo "✅ PASS: $1"; }
log_fail() { FAIL=$((FAIL+1)); REPORT+="❌ $1 — $2\n"; echo "❌ FAIL: $1 — $2"; }
log_skip() { SKIP=$((SKIP+1)); REPORT+="⏭️ $1\n"; echo "⏭️ SKIP: $1 — $2"; }

echo ""; echo "======== QA Phase A: Infrastructure ========"

# T1.01 Layer 1 Python
echo "--- T1.01 ---"
L1PY="$HOME/browser-agent-tools/stealth-browser-mcp/venv/bin/python3.12"
R=$("$L1PY" -c "import fastmcp; print(fastmcp.__version__)" 2>&1) && log_pass "T1.01 Layer1 fastmcp=$R" || log_fail "T1.01" "$R"

# T1.02 CDP Port (curl only, 2 sec max)
echo "--- T1.02 ---"
R=$(curl -s --max-time 2 http://127.0.0.1:9333/json/version 2>&1)
echo "$R" | grep -q "Browser" && log_pass "T1.02 CDP port 9333 active" || log_skip "T1.02 CDP not active" "Run chrome-launch.sh manually first"

# T1.03 Profile dir
echo "--- T1.03 ---"
[ -d "$HOME/Library/Application Support/Chrome-AI-CDP" ] && log_pass "T1.03 Isolated profile dir exists" || log_skip "T1.03 Profile dir" "Created on first CDP launch"

# T1.04 NPX available (check binary exists, DO NOT RUN SERVER)
echo "--- T1.04 ---"
command -v npx >/dev/null 2>&1 && log_pass "T1.04 npx binary found ($(npx --version 2>/dev/null))" || log_fail "T1.04" "npx not found"

# Layer 3 + Mem0
echo ""; echo "======== QA Phase A2: Tools Venv ========"
TPY="$HOME/tools-venv/bin/python3.12"

echo "--- T_L3 ---"
R=$("$TPY" -c "import browser_use; print('OK')" 2>&1) && log_pass "T_L3 browser-use import OK" || log_fail "T_L3" "$R"

echo "--- T_MEM0 ---"
R=$("$TPY" -c "import mem0; print('OK')" 2>&1) && log_pass "T_MEM0 Mem0 import OK" || log_fail "T_MEM0" "$R"

# Memory Router
echo ""; echo "======== QA Phase A3: Memory Router ========"
ROUTER="$HOME/Projects/browser-agent-hub/scripts/memory_router.py"
ALLOK=true
for pair in "Janji ketemu siapa?:mem0" "Website tahun 2025:qdrant" "BTC terkait project X:neo4j" "Bagaimana cuaca?:hybrid"; do
    Q="${pair%%:*}"; E="${pair##*:}"
    R=$("$TPY" "$ROUTER" "$Q" 2>&1)
    echo "$R" | grep -q "\"backend\": \"$E\"" && echo "  ✓ $Q → $E" || { echo "  ✗ $Q expected $E"; ALLOK=false; }
done
[ "$ALLOK" = true ] && log_pass "T_ROUTER 4/4 routes correct" || log_fail "T_ROUTER" "Some wrong"

# Security
echo ""; echo "======== QA Phase B: Security & Skill Rules ========"
SKILL="$HOME/.agent/skills/browser-router.md"

echo "--- T9.03 Port files ---"
OLD=$(grep -rn --exclude="run_qa.sh" "9222" "$HOME/Projects/browser-agent-hub/scripts/" "$SKILL" 2>/dev/null)
[ -z "$OLD" ] && log_pass "T9.03 No legacy 9222 in scripts/skill" || log_fail "T9.03" "Found: $OLD"

echo "--- T9.03b Port 9222 ---"
R=$(curl -s --max-time 2 http://127.0.0.1:9222/json/version 2>&1)
echo "$R" | grep -q "Browser" && log_fail "T9.03b Port 9222 ACTIVE" "Security risk" || log_pass "T9.03b Port 9222 inactive"

# Skill decision tree validation
echo ""; echo "======== QA Phase B2: Skill Decision Tree ========"
TREE_OK=true
check() { grep -qi "$1" "$SKILL" 2>/dev/null && echo "  ✓ $2" || { echo "  ✗ MISSING: $2"; TREE_OK=false; }; }

check "AKUN YANG SUDAH LOGIN" "Q1 Login→L2"
check "CLOUDFLARE" "Q2 Bot→L1"
check "AI MULTI-STEP" "Q3 Multi→L3"
check "Default.*Layer 1" "Default→L1"
check "chrome-launch" "CDP-off fallback"
check "banking" "Banking warning"
check "hardcode password" "No hardcode PW"
check "Screenshot dulu" "Screenshot-first rule"
check "detik" "Delay rule"
check "Scroll dulu" "Scroll-first rule"
check "Tutup tab" "Close-tab rule"
check "5 klik" "Rate-limit rule"
[ "$TREE_OK" = true ] && log_pass "Skill: 12/12 rules verified" || log_fail "Skill" "Missing rules"

# Cross-layer
echo ""; echo "======== QA Phase C: Cross-Layer Rules ========"
CL_OK=true
grep -qi "satu layer per task\|mix.*Layer\|Jangan.*mix" "$SKILL" && echo "  ✓ No-mix rule" || { echo "  ✗ No-mix"; CL_OK=false; }
grep -qi "Login selalu.*Layer 2\|login.*prefer" "$SKILL" && echo "  ✓ Login→L2 rule" || { echo "  ✗ Login→L2"; CL_OK=false; }
[ "$CL_OK" = true ] && log_pass "Cross-layer rules OK" || log_fail "Cross-layer" "Missing"

# Final
echo ""; echo "════════════════════════════════════════"
echo "  PASS=$PASS  FAIL=$FAIL  SKIP=$SKIP  TOTAL=$((PASS+FAIL+SKIP))"
echo "════════════════════════════════════════"
[ $FAIL -eq 0 ] && echo "🎉 ALL PASSED" || echo "⚠️ $FAIL FAILED"
