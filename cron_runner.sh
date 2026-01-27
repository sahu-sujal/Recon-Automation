#!/bin/bash

source $BASE_DIR/config/env.sh
BASE_DIR="/home/$USER/recon-automation"
LOG_DIR="$BASE_DIR/cron_logs"
DATE=$(date +%F)

mkdir -p $LOG_DIR

DOMAINS=(
  "example.com"
  "test.com"
)

echo "[*] Cron run started at $(date)" >> $LOG_DIR/cron_$DATE.log

cd $BASE_DIR || exit 1

for DOMAIN in "${DOMAINS[@]}"; do
  echo "[*] Running recon for $DOMAIN" >> $LOG_DIR/cron_$DATE.log
  ./run.sh $DOMAIN >> $LOG_DIR/cron_$DATE.log 2>&1
done

echo "[+] Cron run completed at $(date)" >> $LOG_DIR/cron_$DATE.log
