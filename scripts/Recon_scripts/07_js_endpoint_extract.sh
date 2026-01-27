#!/bin/bash

DOMAIN=$1
DIFF="projects/$DOMAIN/diff/new_js.txt"
OUT="projects/$DOMAIN/js/endpoints"
DATE=$(date +%F)

mkdir -p $OUT

[ ! -s $DIFF ] && echo "[*] No new JS files" && exit 0

while read js; do
  echo "[*] Analyzing $js"
  echo $js | JSFinder >> $OUT/js_endpoints_$DATE.txt
done < $DIFF
