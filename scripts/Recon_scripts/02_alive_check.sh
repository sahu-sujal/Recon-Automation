#!/bin/bash

DOMAIN=$1
SUBS_DIR="projects/$DOMAIN/subdomains"
OUT="projects/$DOMAIN/live"
DATE=$(date +%F)

LATEST_SUBS=$(ls -t $SUBS_DIR/all_*.txt | head -n 1)

echo "[*] Checking alive hosts"

cat $LATEST_SUBS | httpx -silent -status-code -title \
  > $OUT/live_$DATE.txt

echo "[+] Live hosts: $(wc -l < $OUT/live_$DATE.txt)"
