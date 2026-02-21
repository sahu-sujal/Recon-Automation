#!/bin/bash

DOMAIN=$1
LIVE_DIR="projects/$DOMAIN/live"
OUT="projects/$DOMAIN/urls"
LOG_DIR="projects/$DOMAIN/logs"
DATE=$(date +%F)
LOG_FILE="$LOG_DIR/url_discovery.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

LATEST_LIVE=$(ls -t $LIVE_DIR/live_*.txt | head -n 1 | awk '{print $1}')

echo "[*] URL discovery for $DOMAIN" | tee -a "$LOG_FILE"

echo "[+] Running waybackurls" | tee -a "$LOG_FILE"
cat $LATEST_LIVE | awk '{print $1}' | waybackurls > $OUT/wayback_$DATE.txt

echo "[+] Running gau" | tee -a "$LOG_FILE"
cat $LATEST_LIVE | awk '{print $1}' | gau --blacklist png,jpg,css > $OUT/gau_$DATE.txt

echo "[+] Running katana" | tee -a "$LOG_FILE"
cat $LATEST_LIVE | awk '{print $1}' | katana -d 3 -silent > $OUT/katana_$DATE.txt

cat $OUT/*_$DATE.txt | sort -u > $OUT/all_urls_$DATE.txt

echo "[01] Total unique URLs: $(wc -l < $OUT/all_urls_$DATE.txt)" | tee -a "$LOG_FILE"
