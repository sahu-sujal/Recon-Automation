import sys
from datetime import date
from db import connect

domain = sys.argv[1]
url_file = sys.argv[2]

conn = connect()
cur = conn.cursor()

cur.execute("SELECT id FROM programs WHERE domain=%s", (domain,))
pid = cur.fetchone()[0]

with open(url_file) as f:
    for url in f:
        url = url.strip()
        cur.execute("""
        INSERT INTO urls(program_id, url, first_seen, last_seen)
        VALUES (%s,%s,%s,%s)
        ON CONFLICT (program_id, url)
        DO UPDATE SET last_seen=%s
        """, (pid, url, date.today(), date.today(), date.today()))

conn.commit()
cur.close()
conn.close()
