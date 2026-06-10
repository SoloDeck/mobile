# Proposals Module — Mobile

## Purpose

View and manage proposals sent to clients. Mobile is primarily a review and approval surface — full proposal drafting happens on web.

## Responsibilities

- List proposals for a deal
- View proposal content (scope, pricing, timeline)
- Send / resend proposal to client
- View acceptance / rejection status
- Trigger AI proposal generation

## Proposal Status Flow

```
draft → sent → accepted
             → rejected
             → expired
```

Only one proposal per deal may be in `sent` status at a time.

## API Endpoints

- `GET /proposals` — list (filter by deal, status)
- `POST /proposals` — create draft
- `GET /proposals/:id` — detail
- `PUT /proposals/:id` — update (draft only)
- `POST /proposals/:id/send` — send to client
- `POST /proposals/generate` — AI generation
