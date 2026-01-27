#!/bin/bash

DOMAIN=$1
DIFF="projects/$DOMAIN/diff/new_js.txt"
OUT="projects/$DOMAIN/js/secrets"
DATE=$(date +%F)

mkdir -p $OUT

[ ! -s $DIFF ] && echo "[*] No new JS files" && exit 0

while read js; do
  python3 SecretFinder/SecretFinder.py \
    -i $js \
    -o $OUT/secrets_$DATE.html
done < $DIFF
