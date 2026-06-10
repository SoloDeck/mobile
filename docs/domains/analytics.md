# Analytics Module — Mobile

## Purpose

Surface key business metrics on the mobile dashboard. Analytics is read-only — it never writes to operational data.

## Responsibilities

- Revenue summary (total billed, collected, outstanding)
- Pipeline overview (deal count per stage, total pipeline value)
- Win rate for the selected period
- Top clients by revenue
- Period-over-period comparison

## API Endpoints (all GET, read-only)

- `GET /analytics/revenue` — revenue metrics
- `GET /analytics/pipeline` — pipeline snapshot
- `GET /analytics/win-rate` — win rate
- `GET /analytics/top-clients` — top clients by revenue
