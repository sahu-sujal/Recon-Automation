#!/bin/bash

# ==========================================

# Stage 07 - JS Endpoint Extraction

# Extract endpoints only from today's JS files

# ==========================================

DOMAIN=$1
if [ -z "$DOMAIN" ]; then
echo "Usage: ./07_js_endpoint_extract.sh example.com"
exit 1
fi

# auto detect project root

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PROJ="$BASE/projects/$DOMAIN"
JS_DIR="$PROJ/js"
LOG="$PROJ/logs/js_endpoint.log"
DATE=$(date +%F)

JS_FILE="$JS_DIR/js_files_$DATE.txt"
OUT_FILE="$JS_DIR/js_endpoints_$DATE.txt"
# echoing JS_FILE to stdout was printing the path; remove to keep output silent

mkdir -p "$JS_DIR" "$PROJ/logs"

echo "=============================" >> "$LOG"
echo "[07] JS Endpoint Extraction Started $DATE" >> "$LOG"

# Always create output (pipeline safety)

> "$OUT_FILE"

# dependency check

if ! command -v python3 &>/dev/null; then
echo "[!] python3 missing" | tee -a "$LOG"
exit 0
fi

LINKFINDER="$BASE/tools/LinkFinder/linkfinder.py"

if [ ! -f "$LINKFINDER" ]; then
echo "[!] LinkFinder not found in tools folder" | tee -a "$LOG"
exit 0
fi

# no js today

if [ ! -s "$JS_FILE" ]; then
echo "[i] No JS files today" | tee -a "$LOG"
exit 0
fi

echo "[+] Extracting endpoints from JS" >> "$LOG"

# Run LinkFinder per JS file, append stdout to OUT_FILE and errors to LOG
while read -r js; do
	# Run LinkFinder: send stderr to log. Filter stdout to remove usage/error messages
	# and extract only URL-like strings before saving to OUT_FILE.
	python3 "$LINKFINDER" -i "$js" -o cli 2>>"$LOG" \
		| grep -Ev '^(Usage:|Error:|Traceback|\s*$)' \
		| grep -Eo "(https?://[^ \"']+|/[^ \"']+)" >> "$OUT_FILE"
done < "$JS_FILE"

# Deduplicate results in-place if file is non-empty
if [ -s "$OUT_FILE" ]; then
	sort -u -o "$OUT_FILE" "$OUT_FILE"
fi

COUNT=$(wc -l < "$OUT_FILE")

echo "[+] Endpoints found: $COUNT" | tee -a "$LOG"
echo "[07] JS Endpoint Extraction Completed" | tee -a "$LOG"
