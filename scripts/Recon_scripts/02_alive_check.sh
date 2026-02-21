#!/bin/bash

DOMAIN=$1
if [ -z "$DOMAIN" ]; then
  echo "[!] ERROR: No domain provided"
  echo "Usage: ./02_alive_check.sh example.com"
  exit 1
fi

SUBS_DIR="projects/$DOMAIN/subdomains"
OUT="projects/$DOMAIN/live"
DATE=$(date +%F)
LOG="projects/$DOMAIN/logs/alive_check.log"
LATEST_SUBS=$(ls -t "$SUBS_DIR"/all_*.txt 2>/dev/null | head -n 1)

echo "[*] Checking alive hosts" | tee -a "$LOG"

# ---------- checks ----------
if [ -z "$LATEST_SUBS" ]; then
  echo "[!] No subdomain file found" | tee -a "$LOG"
  exit 1
fi

if ! command -v httpx >/dev/null 2>&1; then
  echo "[!] httpx not installed" | tee -a "$LOG"
  exit 1
fi
# ----------------------------
# ---------- alive logic ----------

cat "$LATEST_SUBS" | httpx-toolkit -silent -status-code -no-color \
  -o "$OUT/live_$DATE.txt" 2>>"$LOG" || echo "[!] httpx error" | tee -a "$LOG"

# -------------------------------

echo "[+] Live hosts: $(wc -l < "$OUT/live_$DATE.txt")" | tee -a "$LOG"