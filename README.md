# YouTube video sharing — API (Rails)

Backend for the Remitano-style exercise: **JWT auth**, **shared YouTube links** (oEmbed titles), **authenticated feed**, **Action Cable** real-time notifications, **Sidekiq** background broadcasts.


---

## Introduction

- `POST /api/v1/auth/register` · `POST /api/v1/auth/login` — returns a JWT and user.
- `GET /api/v1/auth/me` — current user from Bearer JWT (for SPA session restore).
- `GET /api/v1/shared_videos` — list newest shares when logged in (optional `?limit=`; default 50, max 100).
- `POST /api/v1/shared_videos` — share a URL (Bearer JWT).
- `DELETE /api/v1/shared_videos/:id` — remove your own share (Bearer JWT).
- `GET /cable?token=<jwt>` — WebSocket; subscribe to `VideoNotificationsChannel` for `{ type, title, sharer_name, youtube_video_id }` when others share.

---

## Prerequisites

| Tool | Notes |
|------|--------|
| Ruby | 3.2+ (see `.ruby-version`) |
| Bundler | 2.x |
| PostgreSQL | 14+ |
| Redis | For Sidekiq + Action Cable (dev uses Redis adapter) |
| Docker (optional) | For one-command Postgres + Redis via `docker-compose.yml` |

---

## Installation & configuration

```bash
git clone <your-backend-repo-url>
cd backend
bundle install
cp .env.example .env
```

Edit `.env` for your machine. With Docker Postgres on `localhost`, the defaults in `.env.example` usually work.

---

## Database setup

**Option A — Docker (recommended)**

Start containers **before** `db:create`, or you will see `connection refused` on `127.0.0.1:5432`:

```bash
docker compose up -d
# wait until healthy (a few seconds)
bin/rails db:create db:migrate
RAILS_ENV=test bin/rails db:create db:migrate   # optional, for tests
```

**Option B — local PostgreSQL**

Unset `DATABASE_HOST` if you use peer/socket auth, or set `DATABASE_URL` to your instance.

Load demo data (optional):

```bash
bin/rails db:seed
```

Demo account (created if missing): `demo@example.com` / `password1234`.

---

## Running the application

Terminal 1 — API:

```bash
bin/rails server -p 3000
```

Terminal 2 — Sidekiq (required for broadcast jobs):

```bash
bundle exec sidekiq -C config/sidekiq.yml
```

- Service index: `GET /`
- Health: `GET /up`
- WebSocket: `ws://localhost:3000/cable?token=<jwt>`

---

## Docker deployment

This repo includes **`docker-compose.yml`** for **Postgres + Redis** only. Run the Rails app on your host (or use the included `Dockerfile` on a platform that supports long-lived containers: Render, Fly.io, Railway, etc.).

Production checklist:

- `DATABASE_URL`, `REDIS_URL`, `RAILS_MASTER_KEY`
- `FRONTEND_ORIGIN` — comma-separated SPA origins (CORS + Action Cable)
- `JWT_SECRET_KEY` — optional; defaults to `secret_key_base` if unset
- TLS so the SPA can use `wss://` for Action Cable

Build the stock image:

```bash
docker build -t yt-share-api .
```

---

## Usage (API)

| Method | Path | Auth |
|--------|------|------|
| GET | `/` | No — JSON service map |
| GET | `/up` | No — load balancer health |
| POST | `/api/v1/auth/register` | No — JSON body: `email`, `password`, `password_confirmation`, `name` |
| POST | `/api/v1/auth/login` | No — `email`, `password` |
| GET | `/api/v1/auth/me` | Yes — Bearer JWT; returns `{ user: { id, email, name } }` |
| GET | `/api/v1/shared_videos?limit=20` | Yes — Bearer JWT |
| POST | `/api/v1/shared_videos` | Yes — `Authorization: Bearer <jwt>`, body: `youtube_url` |
| DELETE | `/api/v1/shared_videos/:id` | Yes — removes the row only if it belongs to the JWT user |
| WS | `/cable?token=<jwt>` | JWT — subscribe to `VideoNotificationsChannel` |

---

## Running the test suite

```bash
bin/rails test
```

Includes unit tests (models, services), controller tests, integration flow, job, and Action Cable connection tests.

---

## Troubleshooting

| Symptom | What to try |
|---------|-------------|
| `socket "/tmp/.s.PGSQL.5432"` | Set `DATABASE_HOST=localhost` in `.env` when using Docker Postgres. |
| Redis / Sidekiq errors | Start Redis; match `REDIS_URL` in `.env`. |
| CORS / Cable blocked | Add your SPA origin to `FRONTEND_ORIGIN` (comma-separated). |
| No live notifications | Ensure Sidekiq is running so `BroadcastNewVideoJob` executes. |

---
