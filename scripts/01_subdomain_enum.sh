#!/bin/bash

DOMAIN=$1
OUT="projects/$DOMAIN/subdomains"
LOG="projects/$DOMAIN/logs/subdomain.log"
DATE=$(date +%F)

echo "[*] Subdomain enumeration for $DOMAIN" | tee -a $LOG

subfinder -d $DOMAIN -silent > $OUT/subfinder_$DATE.txt
assetfinder --subs-only $DOMAIN > $OUT/assetfinder_$DATE.txt
amass enum -passive -d $DOMAIN -o $OUT/amass_$DATE.txt

cat $OUT/*_$DATE.txt | sort -u > $OUT/all_$DATE.txt

echo "[+] Total subdomains: $(wc -l < $OUT/all_$DATE.txt)" | tee -a $LOG
