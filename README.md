# Recon Automation Platform

A **production‑grade, end‑to‑end reconnaissance automation framework** designed for **bug bounty hunters, red teams, and cloud security researchers**.

This project implements a **continuous recon + monitoring pipeline** with:

* Multi‑stage automation
* Differential (new asset) detection
* PostgreSQL‑backed history
* Discord alerting with duplicate suppression
* JavaScript analysis
* Weekly/Daily cron automation
* FastAPI web dashboard

> Philosophy: **Automation finds opportunities, humans validate vulnerabilities** (60/40 rule).

---

## 📌 High‑Level Capabilities

* 🔍 Subdomain enumeration (multi‑tool aggregation)
* 🌐 Live host detection + tech fingerprinting
* 🔗 URL & endpoint discovery (active + passive)
* 🧠 JavaScript endpoint & secret analysis
* 🚨 High/Critical vulnerability detection (Nuclei)
* 🗄️ Full historical storage (PostgreSQL)
* 🔔 Discord alerts (deduplicated)
* 📊 Web dashboard (FastAPI)
* ⏰ Continuous monitoring (cron‑based)

---

## 🧱 Project Architecture Overview

```
Scope (Domain)
   ↓
Subdomain Enumeration
   ↓
Alive Host Detection
   ↓
URL Discovery
   ↓
JavaScript Discovery & Analysis
   ↓
Differential Analysis (New Assets Only)
   ↓
Nuclei Scanning (High/Critical)
   ↓
PostgreSQL Storage
   ↓
Discord Alerts (Once Only)
   ↓
FastAPI Dashboard
```

---

## 📁 Folder & File Structure

```
recon-automation/
│
├── run.sh                      # Master pipeline runner
│
├── config/
│   ├── env.sh                  # Environment variables for cron
│   ├── db.conf                 # PostgreSQL credentials
│   └── discord.conf            # Discord webhook
│
├── scripts/
│   ├── 01_subdomain_enum.sh    # Subdomain discovery
│   ├── 02_alive_check.sh       # Alive host probing
│   ├── 03_url_discovery.sh     # URL discovery
│   ├── 04_diff_check.sh        # New asset detection
│   ├── 05_nuclei_scan.sh       # Batch nuclei scanning
│   ├── 06_js_discovery.sh      # JS file discovery
│   ├── 07_js_endpoint_extract.sh
│   ├── 08_js_secret_scan.sh
│   ├── cron_runner.sh          # Weekly/daily automation
│
│   ├── db.py                   # PostgreSQL helper
│   ├── register_program.py
│   ├── store_subdomains.py
│   ├── store_urls.py
│   ├── store_findings.py
│   ├── store_js_files.py
│   ├── discord_alert_from_db.py
│
├── db/
│   └── schema.sql              # Database schema
│
├── projects/
│   └── example.com/
│       ├── subdomains/
│       ├── live/
│       ├── urls/
│       ├── js/
│       ├── nuclei/
│       ├── diff/
│       └── logs/
│
├── dashboard/
│   ├── app.py                  # FastAPI application
│   ├── templates/              # Jinja2 HTML templates
│   └── static/
│
└── cron_logs/
```

---

## 🗄️ Database Schema (PostgreSQL)

### `programs`

Tracks each scope/project.

| Column     | Type      | Description   |
| ---------- | --------- | ------------- |
| id         | SERIAL    | Primary key   |
| domain     | TEXT      | Root domain   |
| created_at | TIMESTAMP | Creation time |

---

### `subdomains`

Tracks full lifecycle of subdomains.

| Column     | Type | Description     |
| ---------- | ---- | --------------- |
| program_id | INT  | FK → programs   |
| subdomain  | TEXT | Subdomain       |
| first_seen | DATE | First discovery |
| last_seen  | DATE | Last observed   |

---

### `live_hosts`

Stores alive HTTP services.

| Column      | Type | Description   |
| ----------- | ---- | ------------- |
| url         | TEXT | Full URL      |
| status_code | INT  | HTTP status   |
| title       | TEXT | Page title    |
| tech        | TEXT | Detected tech |
| last_seen   | DATE | Last alive    |

---

### `urls`

Tracks endpoints over time.

| Column     | Type | Description     |
| ---------- | ---- | --------------- |
| url        | TEXT | Endpoint        |
| first_seen | DATE | First discovery |
| last_seen  | DATE | Last seen       |

---

### `js_files`

Tracks JavaScript assets.

| Column     | Type | Description |
| ---------- | ---- | ----------- |
| js_url     | TEXT | JS file URL |
| first_seen | DATE | First seen  |
| last_seen  | DATE | Last seen   |

---

### `findings`

Stores vulnerability findings.

| Column       | Type      | Description          |
| ------------ | --------- | -------------------- |
| template_id  | TEXT      | Nuclei template      |
| name         | TEXT      | Finding name         |
| severity     | TEXT      | Severity             |
| affected_url | TEXT      | Vulnerable URL       |
| hash         | TEXT      | Unique fingerprint   |
| first_seen   | TIMESTAMP | First detection      |
| last_seen    | TIMESTAMP | Last detection       |
| alerted      | BOOLEAN   | Discord sent         |
| reported     | BOOLEAN   | Reported to platform |

---

## 🌐 REST API (FastAPI Dashboard)

### Base URL

```
http://<server-ip>:8000
```

### Available Endpoints

| Endpoint        | Description            |
| --------------- | ---------------------- |
| `/`             | Programs overview      |
| `/subdomains`   | Subdomain history      |
| `/urls`         | URL inventory          |
| `/js`           | JavaScript files       |
| `/findings`     | High/Critical findings |
| `/findings/new` | Unalerted findings     |

---

## 🛠️ Tools Used & Commands

### Subdomain Enumeration

```bash
subfinder -d example.com -all -silent
assetfinder --subs-only example.com
amass enum -passive -d example.com
```

---

### Alive Check

```bash
httpx -silent -status-code -title -tech-detect
```

---

### URL Discovery

```bash
waybackurls
gau --blacklist png,jpg,css
katana -d 3 -silent
```

---

### JavaScript Analysis

```bash
JSFinder
SecretFinder
```

---

### Vulnerability Scanning

```bash
nuclei -severity high,critical -json
```

Batching:

```bash
split -l 50 urls.txt batch_
```

---

## 🔔 Discord Alerting Logic

* Alerts pulled **from DB**, not raw output
* Only **High / Critical**
* Only **unalerted findings**
* Each finding alerted **once**

This guarantees:

* ❌ No spam
* ❌ No duplicates
* ✅ Safe cron reruns

---

## ⏰ Automation (Cron)

### Weekly Full Scan

```cron
0 3 * * 0 /home/USER/recon-automation/scripts/cron_runner.sh
```

### Daily Lightweight Monitoring (Optional)

```cron
0 2 * * * /home/USER/recon-automation/run.sh example.com
```

---

## 🔐 Security & Safety Controls

* Rate limiting enabled
* Differential scans preferred
* No aggressive templates by default
* Manual validation mandatory

---

## 🧠 Recommended Workflow

1. Let automation run
2. Watch Discord alerts
3. Validate manually
4. Mark `reported=true`
5. Track via dashboard

---

## 🏁 Final Notes

This platform is **not a beginner script**.

It is a **scalable, extensible recon system** comparable to:

* Internal red‑team tooling
* SOC recon pipelines
* Advanced bug bounty automation

> The power comes from **consistency, history, and speed**.

---

## 🚀 Future Enhancements

* Authentication & RBAC
* Risk scoring engine
* Auto report generation
* Distributed scanning (Axiom)
* Graph‑based asset relationships

---

Happy Hunting 🕵️‍♂️🔥
