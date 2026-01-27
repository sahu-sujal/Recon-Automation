import requests
from db import connect
from datetime import datetime

def load_webhook():
    with open("config/discord.conf") as f:
        for line in f:
            if line.startswith("DISCORD_WEBHOOK"):
                return line.split("=", 1)[1].strip().strip('"')

WEBHOOK = load_webhook()
conn = connect()
cur = conn.cursor()

cur.execute("""
SELECT id, template_id, name, severity, affected_url
FROM findings
WHERE alerted = false
AND severity IN ('high', 'critical')
ORDER BY first_seen ASC
""")

rows = cur.fetchall()

for r in rows:
    fid, template, name, severity, url = r

    payload = {
        "embeds": [{
            "title": f"🚨 {severity.upper()} Vulnerability",
            "description": f"**{name}**",
            "color": 15158332 if severity == "critical" else 15105570,
            "fields": [
                {"name": "Template", "value": template, "inline": True},
                {"name": "Severity", "value": severity.upper(), "inline": True},
                {"name": "Affected URL", "value": url, "inline": False},
            ],
            "footer": {
                "text": f"Recon Automation • {datetime.utcnow()} UTC"
            }
        }]
    }

    r = requests.post(WEBHOOK, json=payload)
    if r.status_code == 204:
        cur.execute("UPDATE findings SET alerted=true WHERE id=%s", (fid,))
        conn.commit()

cur.close()
conn.close()
