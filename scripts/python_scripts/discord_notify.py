import json
import requests
import sys
import os
from datetime import datetime

# Load webhook
def load_webhook():
    candidates = [
        os.path.join(os.path.dirname(__file__), '..', '..', 'config', 'discord.conf'),
        os.path.join(os.getcwd(), 'config', 'discord.conf'),
        '/home/sujal/Desktop/Recon-Automation/config/discord.conf'
    ]
    for path in candidates:
        try:
            abs_path = os.path.abspath(path)
            if not os.path.exists(abs_path):
                continue
            with open(abs_path) as f:
                for line in f:
                    if line.strip().startswith("DISCORD_WEBHOOK"):
                        return line.split("=", 1)[1].strip().strip('"')
        except Exception:
            continue
    return None

WEBHOOK_URL = load_webhook()

if not WEBHOOK_URL:
    print("[-] Discord webhook not found")
    sys.exit(1)

NUCLEI_FILE = sys.argv[1]
DOMAIN = sys.argv[2]

if not os.path.exists(NUCLEI_FILE):
    sys.exit(0)

with open(NUCLEI_FILE) as f:
    lines = f.readlines()

if not lines:
    sys.exit(0)

for line in lines:
    data = json.loads(line)

    template = data.get("template-id", "N/A")
    severity = data.get("info", {}).get("severity", "unknown").upper()
    name = data.get("info", {}).get("name", "Unknown Finding")
    url = data.get("matched-at", "N/A")

    payload = {
        "embeds": [
            {
                "title": f"🚨 {severity} Vulnerability Found",
                "description": f"**{name}**",
                "color": 15158332 if severity == "CRITICAL" else 15105570,
                "fields": [
                    {"name": "Domain", "value": DOMAIN, "inline": True},
                    {"name": "Severity", "value": severity, "inline": True},
                    {"name": "Template", "value": template, "inline": False},
                    {"name": "Affected URL", "value": url, "inline": False},
                ],
                "footer": {
                    "text": f"Recon Automation • {datetime.utcnow().isoformat()} UTC"
                }
            }
        ]
    }

    requests.post(WEBHOOK_URL, json=payload)
