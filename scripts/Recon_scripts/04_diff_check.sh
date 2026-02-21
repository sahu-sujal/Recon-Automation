#!/bin/bash

# ==========================================

# Stage 04 - Stateful + Date Based Diff

# Safe for automation pipelines

# ==========================================

DOMAIN=$1
if [ -z "$DOMAIN" ]; then
echo "Usage: ./04_diff_check.sh example.com"
exit 1
fi

# Auto detect project root (works from anywhere)

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PROJ="$BASE/projects/$DOMAIN"
DIFF="$PROJ/diff"
LOG="$PROJ/logs/diff.log"
DATE=$(date +%F)

mkdir -p "$DIFF" "$PROJ/logs"

echo "=============================" >> "$LOG"
echo "[04] Diff Started $DATE" >> "$LOG"

###########################################

# FUNCTION: STATEFUL COMPARISON

###########################################
state_compare () {

TYPE=$1
INPUT=$2

MASTER="$DIFF/master_${TYPE}.txt"
TODAY_OUT="$DIFF/new_${TYPE}_${DATE}.txt"

# Always create today's file (prevents stage-05 crash)

> "$TODAY_OUT"

# Missing input protection

if [ -z "$INPUT" ] || [ ! -f "$INPUT" ]; then
echo "[!] Missing $TYPE input" | tee -a "$LOG"
return
fi

# Normalize (remove duplicates)

sort -u "$INPUT" -o "$INPUT"

# FIRST RUN → everything new

if [ ! -f "$MASTER" ]; then
cp "$INPUT" "$MASTER"
cp "$INPUT" "$TODAY_OUT"
COUNT=$(wc -l < "$TODAY_OUT")
echo "[i] First run baseline for $TYPE ($COUNT)" | tee -a "$LOG"
return
fi

# Compare with master database

comm -13 "$MASTER" "$INPUT" > "$TODAY_OUT"
NEWCOUNT=$(wc -l < "$TODAY_OUT")

# Update master DB (memory)

cat "$MASTER" "$TODAY_OUT" | sort -u > "$MASTER.tmp"
mv "$MASTER.tmp" "$MASTER"

echo "[+] $TYPE new today: $NEWCOUNT" | tee -a "$LOG"
}

###########################################

# FETCH LATEST FILES FROM PREVIOUS STAGES

###########################################

LATEST_SUB=$(ls -t "$PROJ/subdomains"/all_*.txt 2>/dev/null | head -n 1 || true)
LATEST_LIVE=$(ls -t "$PROJ/live"/live_*.txt 2>/dev/null | head -n 1 || true)
LATEST_URL=$(ls -t "$PROJ/urls"/all_urls_*.txt 2>/dev/null | head -n 1 || true)

###########################################

# RUN DIFF CHECK

###########################################

state_compare "subdomains" "$LATEST_SUB"
state_compare "live" "$LATEST_LIVE"
state_compare "urls" "$LATEST_URL"

echo "[04] Diff Completed" | tee -a "$LOG"
