# Boonker demo API

Development-only HTTP server for exercising the iOS API contract before a real
authentication service and WireGuard control plane are deployed.

## Run

```sh
cd backend
cp .env.example .env
node src/server.js
```

Demo credentials are `demo@boonker.test` / `demo-password` unless overridden by
environment variables. This server does not create a VPN tunnel and must not be
used as a production backend.

## Smoke test

```sh
curl http://localhost:8787/health
curl http://localhost:8787/v1/locations
curl -X POST http://localhost:8787/v1/auth/login \
  -H 'content-type: application/json' \
  -d '{"email":"demo@boonker.test","password":"demo-password"}'
```
