import sys
from datetime import datetime
from db import connect

domain, js_url, secret_type, secret_value = sys.argv[1:5]

conn = connect()
cur = conn.cursor()

cur.execute("SELECT id FROM programs WHERE domain=%s", (domain,))
pid = cur.fetchone()[0]

cur.execute("""
INSERT INTO js_secrets(program_id, js_url, secret_type, secret_value, discovered_at)
VALUES (%s,%s,%s,%s,%s)
""", (pid, js_url, secret_type, secret_value, datetime.utcnow()))

conn.commit()
cur.close()
conn.close()
