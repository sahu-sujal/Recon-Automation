#!/bin/bash

# ==========================================

# Stage 08 - JS Secret Scan (Incremental)

# Scan secrets only from today's JS files

# ==========================================

DOMAIN=$1
if [ -z "$DOMAIN" ]; then
echo "Usage: ./08_js_secret_scan.sh example.com"
exit 1
fi

# auto detect project root

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PROJ="$BASE/projects/$DOMAIN"
JS_DIR="$PROJ/js"
LOG="$PROJ/logs/js_secret.log"
DATE=$(date +%F)

JS_FILE="$JS_DIR/js_files_$DATE.txt"
OUT_FILE="$JS_DIR/js_secrets_$DATE.txt"

mkdir -p "$JS_DIR" "$PROJ/logs"

echo "=============================" >> "$LOG"
echo "[08] JS Secret Scan Started $DATE" >> "$LOG"

# Always create output file (pipeline safety)

> "$OUT_FILE"

# dependency check

if ! command -v python3 &>/dev/null; then
echo "[!] python3 missing" | tee -a "$LOG"
exit 0
fi

SECRETFINDER="$BASE/tools/secretfinder/SecretFinder.py"

if [ ! -f "$SECRETFINDER" ]; then
echo "[!] SecretFinder not found in tools folder" | tee -a "$LOG"
exit 0
fi

# no js today

if [ ! -s "$JS_FILE" ]; then
echo "[i] No JS files today" | tee -a "$LOG"
exit 0
fi

echo "[+] Scanning JS for secrets" >> "$LOG"

# Run SecretFinder per JS file, filter output to remove usage/error messages
while read -r js; do
	python3 "$SECRETFINDER" -i "$js" -o cli 2>>"$LOG" \
		| grep -Ev '^(Usage:|Error:|Traceback|\s*$)' \
		| grep -v '^$' >> "$OUT_FILE"
done < "$JS_FILE"

# Deduplicate results in-place if file is non-empty
if [ -s "$OUT_FILE" ]; then
	sort -u -o "$OUT_FILE" "$OUT_FILE"
fi

COUNT=$(wc -l < "$OUT_FILE")

echo "[+] Secrets found: $COUNT" | tee -a "$LOG"
echo "[08] JS Secret Scan Completed" | tee -a "$LOG"
