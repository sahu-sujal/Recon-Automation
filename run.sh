#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: ./run.sh example.com"
  exit 1
fi

DOMAIN=$1
BASE_DIR="projects/$DOMAIN"
DATE=$(date +%F)

mkdir -p \
  $BASE_DIR/{input,subdomains,live,urls,nuclei,diff,logs}

echo "[+] Starting recon for $DOMAIN"

bash scripts/01_subdomain_enum.sh $DOMAIN
bash scripts/02_alive_check.sh $DOMAIN
bash scripts/03_url_discovery.sh $DOMAIN
bash scripts/04_diff_check.sh $DOMAIN
bash scripts/05_nuclei_scan.sh $DOMAIN
bash scripts/06_js_discovery.sh $DOMAIN
bash scripts/07_js_endpoint_extract.sh $DOMAIN
bash scripts/08_js_secret_scan.sh $DOMAIN

echo "[+] Recon completed for $DOMAIN"
