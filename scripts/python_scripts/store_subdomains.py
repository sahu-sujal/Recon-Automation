import sys
from datetime import date
from db import connect

domain = sys.argv[1]
subs_file = sys.argv[2]

conn = connect()
cur = conn.cursor()

cur.execute("SELECT id FROM programs WHERE domain=%s", (domain,))
pid = cur.fetchone()[0]

with open(subs_file) as f:
    for sub in f:
        sub = sub.strip()
        cur.execute("""
        INSERT INTO subdomains(program_id, subdomain, first_seen, last_seen)
        VALUES (%s,%s,%s,%s)
        ON CONFLICT (program_id, subdomain)
        DO UPDATE SET last_seen=%s
        """, (pid, sub, date.today(), date.today(), date.today()))

conn.commit()
cur.close()
conn.close()
