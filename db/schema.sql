CREATE TABLE IF NOT EXISTS programs (
    id SERIAL PRIMARY KEY,
    domain TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS subdomains (
    id SERIAL PRIMARY KEY,
    program_id INT REFERENCES programs(id),
    subdomain TEXT,
    first_seen DATE,
    last_seen DATE,
    UNIQUE(program_id, subdomain)
);

CREATE TABLE IF NOT EXISTS live_hosts (
    id SERIAL PRIMARY KEY,
    program_id INT REFERENCES programs(id),
    url TEXT,
    status_code INT,
    title TEXT,
    tech TEXT,
    last_seen DATE,
    UNIQUE(program_id, url)
);

CREATE TABLE IF NOT EXISTS urls (
    id SERIAL PRIMARY KEY,
    program_id INT REFERENCES programs(id),
    url TEXT,
    first_seen DATE,
    last_seen DATE,
    UNIQUE(program_id, url)
);

CREATE TABLE IF NOT EXISTS findings (
    id SERIAL PRIMARY KEY,
    program_id INT REFERENCES programs(id),
    template_id TEXT,
    name TEXT,
    severity TEXT,
    affected_url TEXT,
    hash TEXT UNIQUE,
    first_seen TIMESTAMP,
    last_seen TIMESTAMP,
    reported BOOLEAN DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS js_files (
    id SERIAL PRIMARY KEY,
    program_id INT REFERENCES programs(id),
    js_url TEXT,
    first_seen DATE,
    last_seen DATE,
    UNIQUE(program_id, js_url)
);

CREATE TABLE IF NOT EXISTS js_secrets (
    id SERIAL PRIMARY KEY,
    program_id INT REFERENCES programs(id),
    js_url TEXT,
    secret_type TEXT,
    secret_value TEXT,
    discovered_at TIMESTAMP
);
