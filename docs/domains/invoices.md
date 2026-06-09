# Invoices Module — Mobile

## Purpose

Create, track, and manage invoices for completed work. Invoices close the money loop — from contract milestones to payment confirmation.

## Responsibilities

- List invoices with payment status
- Create invoice with line items
- View invoice total, tax, and due date
- Record payment (full or partial)
- View overdue invoices dashboard

## Invoice Status

`unpaid → partially_paid → paid | overdue | void`

## API Endpoints

- `GET /invoices` — list (filter by status, date range)
- `POST /invoices` — create
- `GET /invoices/:id` — detail
- `PUT /invoices/:id` — update (unpaid only)
- `POST /invoices/:id/payments` — record payment
