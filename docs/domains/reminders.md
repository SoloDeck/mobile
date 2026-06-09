# Reminders Module — Mobile

## Purpose

Display and manage scheduled nudges that keep deals from going cold and invoices from going unpaid.

## Responsibilities

- List upcoming reminders
- Create manual reminders for deals, clients, invoices, contracts
- Mark reminders as done
- View overdue reminders
- Receive push notifications for due reminders

## Reminder Types

- `follow_up` — Check in on a deal or client
- `proposal_follow_up` — Nudge for proposal response
- `payment_due` — Invoice approaching due date
- `payment_overdue` — Invoice past due date
- `contract_renewal` — Contract nearing end date

## API Endpoints

- `GET /reminders` — list
- `POST /reminders` — create
- `GET /reminders/:id` — detail
- `PATCH /reminders/:id` — update / cancel
- `DELETE /reminders/:id` — delete
