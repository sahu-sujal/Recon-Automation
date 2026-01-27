import sys, json, hashlib
from datetime import datetime
from db import connect

domain = sys.argv[1]
file = sys.argv[2]

conn = connect()
cur = conn.cursor()

cur.execute("SELECT id FROM programs WHERE domain=%s", (domain,))
pid = cur.fetchone()[0]

with open(file) as f:
    for line in f:
        d = json.loads(line)
        raw = f"{d.get('template-id')}|{d.get('matched-at')}"
        h = hashlib.sha256(raw.encode()).hexdigest()

        cur.execute("""
        INSERT INTO findings(
            program_id, template_id, name, severity,
            affected_url, hash, first_seen, last_seen
        )
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
        ON CONFLICT (hash)
        DO UPDATE SET last_seen=%s
        """, (
            pid,
            d.get("template-id"),
            d["info"]["name"],
            d["info"]["severity"],
            d.get("matched-at"),
            h,
            datetime.utcnow(),
            datetime.utcnow(),
            datetime.utcnow()
        ))

conn.commit()
cur.close()
conn.close()
