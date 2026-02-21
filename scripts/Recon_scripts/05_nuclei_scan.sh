#!/bin/bash

# ==========================================

# Stage 05 - Incremental Nuclei Scanner

# Scans only NEW assets discovered today

# ==========================================

DOMAIN=$1
if [ -z "$DOMAIN" ]; then
echo "Usage: ./05_nuclei_scan.sh example.com"
exit 1
fi

# auto detect project root

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PROJ="$BASE/projects/$DOMAIN"
DIFF="$PROJ/diff"
OUT="$PROJ/nuclei"
LOG="$PROJ/logs/nuclei.log"
NUCLEI_TEMPLATES="$BASE/nuclei-templates"
DATE=$(date +%F)

mkdir -p "$OUT" "$PROJ/logs"

LIVE_FILE="$DIFF/new_live_$DATE.txt"
URL_FILE="$DIFF/new_urls_$DATE.txt"

if ! command -v nuclei &>/dev/null; then
echo "[!] nuclei not installed" | tee -a "$LOG"
exit 0
fi

echo "=============================" >> "$LOG" 
echo "[05] Nuclei Started $DATE" >> "$LOG"

###########################################

# HOST SCAN

###########################################
if [ -s "$LIVE_FILE" ]; then
echo "[+] Scanning new live hosts" | tee -a "$LOG"

nuclei -l "$LIVE_FILE" \
  -t "$NUCLEI_TEMPLATES" \
  -severity medium,high,critical \
  -silent \
  -o "$OUT/hosts_$DATE.txt" \
  2>>"$LOG"

else
echo "[i] No new live hosts" | tee -a "$LOG"
touch "$OUT/hosts_$DATE.txt"
fi

###########################################

# URL SCAN

###########################################
if [ -s "$URL_FILE" ]; then
echo "[+] Scanning new URLs" | tee -a "$LOG"

nuclei -l "$URL_FILE" \
  -t "$NUCLEI_TEMPLATES" \
  -severity medium,high,critical \
  -silent \
  -o "$OUT/urls_$DATE.txt" \
  2>>"$LOG"

else
echo "[i] No new URLs" | tee -a "$LOG"
touch "$OUT/urls_$DATE.txt"
fi

###########################################

# MERGED DAILY REPORT

###########################################
cat "$OUT/hosts_$DATE.txt" "$OUT/urls_$DATE.txt" > "$OUT/nuclei_$DATE.txt"

echo "[05] Nuclei Completed" | tee -a "$LOG"
