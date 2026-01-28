#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: ./run.sh example.com"
  exit 1
fi

DOMAIN=$1
BASE_DIR="projects/$DOMAIN"
DATE=$(date +%F)

source $BASE_DIR/config/env.sh

mkdir -p \
  $BASE_DIR/{input,subdomains,live,urls,nuclei,diff,logs}

echo "[+] Starting recon for $DOMAIN"

bash scripts/Recon_scripts/01_subdomain_enum.sh $DOMAIN


echo "[+] Recon completed for $DOMAIN"
