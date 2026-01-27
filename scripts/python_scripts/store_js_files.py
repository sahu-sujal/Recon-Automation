import sys
from datetime import date
from db import connect

domain = sys.argv[1]
js_file = sys.argv[2]

conn = connect()
cur = conn.cursor()

cur.execute("SELECT id FROM programs WHERE domain=%s", (domain,))
pid = cur.fetchone()[0]

new_js = []

with open(js_file) as f:
    for js in f:
        js = js.strip()
        cur.execute("""
        INSERT INTO js_files(program_id, js_url, first_seen, last_seen)
        VALUES (%s,%s,%s,%s)
        ON CONFLICT (program_id, js_url)
        DO UPDATE SET last_seen=%s
        RETURNING xmax=0
        """, (pid, js, date.today(), date.today(), date.today()))
        if cur.fetchone()[0]:
            new_js.append(js)

conn.commit()
cur.close()
conn.close()

# Save only new JS files
if new_js:
    with open(f"projects/{domain}/diff/new_js.txt", "w") as f:
        f.write("\n".join(new_js))
