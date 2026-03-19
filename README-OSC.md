# SuperTokens Core - OSC Deployment

This fork contains OSC (Open Source Cloud) containerization artifacts for [supertokens/supertokens-core](https://github.com/supertokens/supertokens-core).

## Overview

SuperTokens is an open-source authentication service providing session management, social login, passwordless auth, and MFA. This OSC deployment uses the PostgreSQL plugin.

## Environment Variables

| Variable | Required | Description |
|---|---|---|
| `DATABASE_URL` | Yes | PostgreSQL connection URL (e.g., `postgresql://user:pass@host:5432/dbname`) |
| `API_KEYS` | No | Comma-separated API keys to restrict access |
| `POSTGRESQL_CONNECTION_URI` | No | Override DATABASE_URL with explicit PostgreSQL URI |
| `OAUTH_CLIENT_SECRET_ENCRYPTION_KEY` | No | Encryption key for OAuth client secrets |
| `ACCESS_TOKEN_VALIDITY` | No | Access token validity in seconds (default: 3600) |
| `REFRESH_TOKEN_VALIDITY` | No | Refresh token validity in minutes (default: 144000) |
| `LOG_LEVEL` | No | Logging level (default: INFO) |

## OSC Platform

- Port: `$PORT` (default 8080)
- Persistent storage: not required (data stored in PostgreSQL)
- Service type: service (long-running HTTP API)

## Added Files

- `Dockerfile.osc` - OSC-optimized Docker image based on supertokens/supertokens-docker-postgresql
- `osc-entrypoint.sh` - Entrypoint handling OSC platform conventions
- `README-OSC.md` - This file
- `CHANGELOG-OSC.md` - OSC artifact changelog
