# Contracts Module — Mobile

## Purpose

View and sign service agreements generated from accepted proposals. Contracts are simple working agreements ("hợp đồng dịch vụ đơn giản") — not legally binding instruments.

## Responsibilities

- View contract content (scope, payment schedule, terms)
- Sign contracts (freelancer signature)
- Track client signing status
- View payment milestone schedule
- Trigger AI contract generation

## Contract Status

`draft → active (both signed) → completed → terminated`

## API Endpoints

- `GET /contracts` — list
- `POST /contracts` — create from proposal
- `GET /contracts/:id` — detail
- `PUT /contracts/:id` — update (draft only)
- `POST /contracts/:id/sign` — freelancer signs
