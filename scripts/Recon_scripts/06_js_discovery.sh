#!/bin/bash

# ==========================================

# Stage 06 - JS Discovery (Incremental)

# Extract JS only from NEW URLs (diff folder)

# ==========================================

DOMAIN=$1
if [ -z "$DOMAIN" ]; then
echo "Usage: ./06_js_discovery.sh example.com"
exit 1
fi

# auto detect project root

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PROJ="$BASE/projects/$DOMAIN"
DIFF="$PROJ/diff"
OUT="$PROJ/js"
LOG="$PROJ/logs/js.log"
DATE=$(date +%F)

mkdir -p "$OUT" "$PROJ/logs"

URL_FILE="$DIFF/new_urls_$DATE.txt"
JS_OUT="$OUT/js_files_$DATE.txt"

echo "=============================" >> "$LOG"
echo "[06] JS Discovery Started $DATE" >> "$LOG"

# Always create output file (pipeline safety)

> "$JS_OUT"

# If no new URLs → skip safely

if [ ! -s "$URL_FILE" ]; then
echo "[i] No new URLs for JS discovery" | tee -a "$LOG"
exit 0
fi

echo "[+] Extracting JS files" | tee -a "$LOG"

grep -Ei '\.js([?#]|$)' "$URL_FILE" | sed "s/[\"'<>]//g" | sort -u > "$JS_OUT"

COUNT=$(wc -l < "$JS_OUT")

echo "[+] JS files found: $COUNT" | tee -a "$LOG"
echo "[06] JS Discovery Completed" | tee -a "$LOG"
