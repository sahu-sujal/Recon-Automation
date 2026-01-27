#!/bin/bash

DOMAIN=$1
URL_DIR="projects/$DOMAIN/urls"
OUT="projects/$DOMAIN/js"
DATE=$(date +%F)

mkdir -p $OUT

LATEST_URLS=$(ls -t $URL_DIR/all_urls_*.txt | head -n 1)

echo "[*] Extracting JS files"

grep -Ei "\.js($|\?)" $LATEST_URLS | sort -u > $OUT/js_urls_$DATE.txt

echo "[+] JS files found: $(wc -l < $OUT/js_urls_$DATE.txt)"
