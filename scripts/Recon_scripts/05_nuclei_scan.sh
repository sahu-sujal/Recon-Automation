#!/bin/bash

DOMAIN=$1
DIFF="projects/$DOMAIN/diff/new_urls.txt"
OUT="projects/$DOMAIN/nuclei"
DATE=$(date +%F)

[ ! -s $DIFF ] && echo "[*] No new URLs to scan" && exit 0

split -l 50 $DIFF /tmp/nuclei_batch_

for file in /tmp/nuclei_batch_*; do
  nuclei -l $file \
    -severity high,critical \
    -o $OUT/nuclei_$DATE.json \
    -silent
done

python3 scripts/store_findings.py $DOMAIN $OUT/nuclei_$DATE.json

if [ -s $OUT/nuclei_$DATE.json ]; then
  python3 scripts/discord_notify.py \
    $OUT/nuclei_$DATE.json \
    $DOMAIN
fi

rm /tmp/nuclei_batch_*
echo "[+] Nuclei scan completed"
