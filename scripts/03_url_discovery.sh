#!/bin/bash

DOMAIN=$1
LIVE_DIR="projects/$DOMAIN/live"
OUT="projects/$DOMAIN/urls"
DATE=$(date +%F)

LATEST_LIVE=$(ls -t $LIVE_DIR/live_*.txt | head -n 1 | awk '{print $1}')

echo "[*] URL discovery started"

cat $LATEST_LIVE | awk '{print $1}' | waybackurls > $OUT/wayback_$DATE.txt
cat $LATEST_LIVE | awk '{print $1}' | gau --blacklist png,jpg,css > $OUT/gau_$DATE.txt
cat $LATEST_LIVE | awk '{print $1}' | katana -d 3 -silent > $OUT/katana_$DATE.txt

cat $OUT/*_$DATE.txt | sort -u > $OUT/all_urls_$DATE.txt

echo "[+] URLs found: $(wc -l < $OUT/all_urls_$DATE.txt)"
