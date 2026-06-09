# Deals Module — Mobile

## Purpose

Display and manage the freelancer's sales pipeline. Deals are the central entity — they connect clients to proposals, contracts, and invoices.

## Responsibilities

- List deals grouped by pipeline stage
- Create new deals (manual and via voice lead capture)
- Transition deal stages
- View deal activity timeline
- Show deal value and status summary

## Pipeline Stages

```
new_lead → qualified → proposal_sent → in_negotiation → active → completed_and_billed
                                                         ↑
                                                        lost (from any non-terminal stage)
```

Stage transitions are validated by `DealStage.canTransitionTo()` in the domain entity.

## Key Files

| File | Role |
|---|---|
| `domain/entities/deal.dart` | Freezed entity + `DealStage` enum + `canTransitionTo` |
| `domain/repositories/deals_repository.dart` | Abstract interface |
| `infrastructure/datasource/deals_remote_datasource.dart` | Dio calls |
| `infrastructure/datasource/deals_local_datasource.dart` | Drift queries |
| `infrastructure/repository/deals_repository_impl.dart` | Offline-first impl |
| `application/usecases/get_deals_usecase.dart` | Fetch paginated deals |
| `application/usecases/transition_stage_usecase.dart` | Stage change |
| `presentation/pages/deals_page.dart` | Pipeline board |
| `presentation/controllers/deals_controller.dart` | AsyncNotifier |

## API Endpoints

- `GET /deals` — list (paginated, filterable by stage)
- `POST /deals` — create deal
- `GET /deals/:id` — detail
- `PUT /deals/:id` — update
- `POST /deals/:id/stage-transition` — change stage
- `GET /deals/:id/activities` — activity timeline
