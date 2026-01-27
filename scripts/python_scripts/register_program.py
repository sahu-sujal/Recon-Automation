import sys
from db import connect

domain = sys.argv[1]
conn = connect()
cur = conn.cursor()

cur.execute(
    "INSERT INTO programs(domain) VALUES(%s) ON CONFLICT DO NOTHING",
    (domain,)
)

conn.commit()
cur.close()
conn.close()
