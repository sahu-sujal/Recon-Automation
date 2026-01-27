from fastapi import FastAPI, Request
from fastapi.templating import Jinja2Templates
from db import connect

app = FastAPI(title="Recon Automation Dashboard")
templates = Jinja2Templates(directory="dashboard/templates")

@app.get("/")
def index(request: Request):
    conn = connect()
    cur = conn.cursor()
    cur.execute("SELECT id, domain FROM programs ORDER BY domain")
    programs = cur.fetchall()
    cur.close()
    conn.close()
    return templates.TemplateResponse(
        "index.html",
        {"request": request, "programs": programs}
    )

@app.get("/subdomains")
def subdomains(request: Request):
    conn = connect()
    cur = conn.cursor()
    cur.execute("""
        SELECT p.domain, s.subdomain, s.first_seen, s.last_seen
        FROM subdomains s
        JOIN programs p ON p.id=s.program_id
        ORDER BY s.last_seen DESC
        LIMIT 500
    """)
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return templates.TemplateResponse(
        "subdomains.html",
        {"request": request, "rows": rows}
    )

@app.get("/urls")
def urls(request: Request):
    conn = connect()
    cur = conn.cursor()
    cur.execute("""
        SELECT p.domain, u.url, u.first_seen, u.last_seen
        FROM urls u
        JOIN programs p ON p.id=u.program_id
        ORDER BY u.last_seen DESC
        LIMIT 500
    """)
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return templates.TemplateResponse(
        "urls.html",
        {"request": request, "rows": rows}
    )

@app.get("/js")
def js_files(request: Request):
    conn = connect()
    cur = conn.cursor()
    cur.execute("""
        SELECT p.domain, j.js_url, j.first_seen, j.last_seen
        FROM js_files j
        JOIN programs p ON p.id=j.program_id
        ORDER BY j.last_seen DESC
        LIMIT 500
    """)
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return templates.TemplateResponse(
        "js.html",
        {"request": request, "rows": rows}
    )

@app.get("/findings")
def findings(request: Request):
    conn = connect()
    cur = conn.cursor()
    cur.execute("""
        SELECT p.domain, f.name, f.severity, f.affected_url,
               f.first_seen, f.alerted
        FROM findings f
        JOIN programs p ON p.id=f.program_id
        WHERE severity IN ('high','critical')
        ORDER BY f.first_seen DESC
    """)
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return templates.TemplateResponse(
        "findings.html",
        {"request": request, "rows": rows}
    )

@app.get("/findings/new")
def new_findings(request: Request):
    conn = connect()
    cur = conn.cursor()
    cur.execute("""
        SELECT p.domain, f.name, f.severity, f.affected_url, f.first_seen
        FROM findings f
        JOIN programs p ON p.id=f.program_id
        WHERE f.alerted=false
        ORDER BY f.first_seen DESC
    """)
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return templates.TemplateResponse(
        "findings.html",
        {"request": request, "rows": rows}
    )
