#!/bin/bash

DOMAIN=$1
URL_DIR="projects/$DOMAIN/urls"
DIFF_DIR="projects/$DOMAIN/diff"

FILES=($(ls -t $URL_DIR/all_urls_*.txt))

if [ ${#FILES[@]} -lt 2 ]; then
  echo "[!] Not enough data for diff"
  exit 0
fi

NEW=${FILES[0]}
OLD=${FILES[1]}

comm -13 <(sort $OLD) <(sort $NEW) > $DIFF_DIR/new_urls.txt

echo "[+] New URLs detected: $(wc -l < $DIFF_DIR/new_urls.txt)"
