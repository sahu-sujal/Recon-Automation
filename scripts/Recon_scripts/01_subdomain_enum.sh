#!/bin/bash

##################################
# INPUT VALIDATION
##################################
DOMAIN=$1
if [ -z "$DOMAIN" ]; then
  echo "[!] ERROR: No domain provided"
  echo "Usage: ./01_subdomain_enum.sh example.com"
  exit 1
fi

##################################
# PATHS
##################################
OUT="projects/$DOMAIN/subdomains"
LOG="projects/$DOMAIN/logs/subdomain.log"
DATE=$(date +%F)

##################################
# SAFE EXECUTOR (NO CRASH EVER)
##################################
safe_run() {
  TOOL="$1"
  CMD="$2"
  OUTFILE="$3"

  BIN=$(echo "$CMD" | awk '{print $1}')

  echo " [+] Running $TOOL" | tee -a $LOG

  if ! command -v "$BIN" &>/dev/null; then
    echo "[!] $TOOL not installed, skipping" | tee -a "$LOG"
    return
  fi

  ERROR=$(eval "$CMD" 2>&1 > "$OUTFILE")
  CODE=$?

  if [ $CODE -ne 0 ]; then
    echo "[!] $TOOL error: $ERROR" | tee -a "$LOG"
    rm -f "$OUTFILE"
  fi
}

echo "[*] Subdomain enumeration for $DOMAIN" | tee -a $LOG

##################################
# 1. Subfinder
##################################
safe_run "Subfinder" \
"subfinder -d $DOMAIN -all -silent" \
"$OUT/subfinder_$DATE.txt"

##################################
# 2. Assetfinder
##################################
safe_run "Assetfinder" \
"assetfinder --subs-only $DOMAIN" \
"$OUT/assetfinder_$DATE.txt"

# ##################################
# # 4. Sublist3r
# ##################################
# safe_run "Sublist3r" \
# "sublist3r -d $DOMAIN -o /dev/stdout" \
# "$OUT/sublist3r_$DATE.txt"

##################################
# 5. Knockpy
##################################
if command -v knockpy &>/dev/null; then
  echo " [+] Running Knockpy" | tee -a $LOG
  knockpy -d "$DOMAIN" --recon --json --save "$OUT/knockpy" \
    2>>"$LOG" || echo "[!] Knockpy error" >>"$LOG"
  JSON_FILE=$(ls "$OUT/knockpy"/${DOMAIN}_*.json 2>/dev/null | head -1)
  if [ -f "$JSON_FILE" ]; then
    jq -r '.[].domain' "$JSON_FILE" \
      | sort -u > "$OUT/knockpy_$DATE.txt"
  else
    echo "[!] Knockpy JSON file not found" >>"$LOG"
  fi
  rm -rf "$OUT/knockpy"
  echo " [+] Knockpy TXT created and folder removed"
else
  echo "[!] Knockpy not installed, skipping" | tee -a "$LOG"
fi


# ##################################
# # 6. DNSGen (Permutations)
# ##################################
# if command -v dnsgen &>/dev/null; then
#   echo " [+] Running DNSGen" | tee -a $LOG
#   echo "$DOMAIN" | dnsgen - > "$OUT/dnsgen_$DATE.txt" 2>>"$LOG" \
#   || echo "[!] DNSGen error" >>"$LOG"
# else
#   echo "[!] DNSGen not installed, skipping" | tee -a "$LOG"
# fi

##################################
# 7. VirusTotal
##################################
if [ -n "$VT_API_KEY" ]; then
  echo " [+] Running VirusTotal" | tee -a $LOG
  VT_JSON=$(curl -s -H "x-apikey: $VT_API_KEY" \
    "https://www.virustotal.com/api/v3/domains/$DOMAIN/subdomains?limit=1000" \
    2>>"$LOG")

  echo "$VT_JSON" | jq -r '.data[].id' > "$OUT/virustotal_$DATE.txt" 2>>"$LOG" \
  || echo "[!] VirusTotal parse error" >>"$LOG"
else
  echo "[!] VirusTotal API key missing, skipping" | tee -a "$LOG"
fi

##################################
# 8. Censys
##################################
if [ -f "tools/censys-subdomain-finder.py" ]; then
  echo " [+] Running Censys Subdomain Finder" | tee -a $LOG
  python3 "tools/censys-subdomain-finder.py" "$DOMAIN" \
  > "$OUT/censys_$DATE.txt" 2>>"$LOG" \
  || echo "[!] Censys script error" >>"$LOG"
else
  echo "[!] Censys tool missing, skipping" | tee -a "$LOG"
fi

##################################
# 9. Chaos (ProjectDiscovery)
##################################
safe_run "Chaos" \
"chaos -d $DOMAIN -silent" \
"$OUT/chaos_$DATE.txt"

##################################
# 10. CRT.sh
##################################
echo " [+] Running CRT.sh" | tee -a $LOG
CRT=$(curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" 2>>"$LOG")

echo "$CRT" | jq -r '.[].name_value' \
| sed 's/\*\.//g' > "$OUT/crtsh_$DATE.txt" \
|| echo "[!] CRT.sh error" >>"$LOG"

##################################
# 11. OneForAll (NEW)
##################################
if [ -d "tools/OneForAll" ]; then
  echo " [+] Running OneForAll" | tee -a $LOG

  python3 "tools/OneForAll/oneforall.py" \
  --target "$DOMAIN" run \
  --format txt \
  --path "$OUT/oneforall" \
  2>>"$LOG" || echo "[!] OneForAll error" >>"$LOG"

  cat "$OUT/oneforall"/*.txt 2>/dev/null >> "$OUT/oneforall_$DATE.txt"
else
  echo "[!] OneForAll not found, skipping" | tee -a "$LOG"
fi

##################################
# 12. SubDomainizer (NEW)
##################################
if [ -d "tools/SubDomainizer" ]; then
  echo "[+] Running SubDomainizer" | tee -a $LOG
  python3 "tools/SubDomainizer/SubDomainizer.py" -u "https://$DOMAIN" \
  >> "$OUT/subdomainizer_$DATE.txt" 2>>"$LOG" || echo "[!] SubDomainizer error" >>"$LOG"
else
  echo "[!] SubDomainizer not found, skipping" | tee -a "$LOG"
fi

##################################
# 13. Subdominator (NEW)
##################################
if [ -d "tools/Subdominator" ]; then
  echo "[+] Running Subdominator" | tee -a $LOG
  python3 "tools/Subdominator/subdominator.py" -d "$DOMAIN" \
  >> "$OUT/subdominator_$DATE.txt" 2>>"$LOG" || echo "[!] Subdominator error" >>"$LOG"
else
  echo "[!] Subdominator not found, skipping" | tee -a "$LOG"
fi

##################################
# 🔥 OPTIONAL POWER TOOL
##################################
safe_run "Findomain" \
"findomain -t $DOMAIN -q" \
"$OUT/findomain_$DATE.txt"

##################################
# file processing
##################################
cat "$OUT"/*.txt 2>/dev/null \
| sed 's/\*\.//g' \
| grep -E "^[a-zA-Z0-9._-]+\.$DOMAIN$" \
| sort -u > "$OUT/all_$DATE.txt"

##################################
# 📊 SUMMARY
##################################
echo "[01] DONE for $DOMAIN"
echo "[01] Total unique subdomains: $(wc -l < "$OUT/all_$DATE.txt")" | tee -a $LOG
echo "[01] Error log: $LOG"
