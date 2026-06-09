# Clients Module — Mobile

## Purpose

Maintain the freelancer's client address book. Clients are referenced by deals, proposals, contracts, and invoices.

## Responsibilities

- List and search clients
- Create / edit / archive clients
- View communication history log
- Filter by status (prospect / active / inactive / archived)
- Tag management

## Key Entities

- `Client` — `id`, `name`, `type` (individual|company), `status`, `email`, `phone`, `tags`

## API Endpoints

- `GET /clients` — list with search and filter
- `POST /clients` — create
- `GET /clients/:id` — detail
- `PUT /clients/:id` — update
- `DELETE /clients/:id` — soft delete
- `GET /clients/:id/communication-logs` — history
- `POST /clients/:id/communication-logs` — add log entry
