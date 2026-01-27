import psycopg2
import os

def load_db():
    conf = {}
    with open("config/db.conf") as f:
        for line in f:
            if "=" in line:
                k, v = line.strip().split("=", 1)
                conf[k] = v
    return conf

def connect():
    c = load_db()
    return psycopg2.connect(
        host=c["DB_HOST"],
        dbname=c["DB_NAME"],
        user=c["DB_USER"],
        password=c["DB_PASS"]
    )
