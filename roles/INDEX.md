# roles

## Purpose

Role profiles for solo full-stack development. Each file defines a professional
perspective the AI agent can adopt when reviewing work, ensuring blind spots from
wearing multiple hats are caught early. Roles are activated per-task via the
routing matrix in ROUTING.md (created in a later user story).

## Files

- `./product.md` — Product Owner perspective: user value, priority, market fit, scope, success metrics
- `./architect.md` — Architect perspective: system design, scalability, maintainability, convention compliance
- `./backend.md` — Backend Developer perspective: API design, database schema, business logic, error handling
- `./frontend.md` — Frontend Developer perspective: UI/UX, component design, accessibility, state management
- `./data.md` — Data Engineer / AI Scientist perspective: pipelines, data quality, ML design, analytics
- `./devops.md` — DevOps perspective: CI/CD, deployment, infrastructure, monitoring, disaster recovery
- `./security.md` — Security perspective: authentication, authorization, input validation, compliance
- `./finance.md` — Finance perspective: cloud costs, API usage, resource optimization, budget tracking

## Dependencies

- `../CLAUDE.md` — AI agent rules that reference role-based review workflow
- `../docs/AUTHORITY.md` — Authority registry that maps topics to authoritative documents

## Related

- `../docs/reviews/` — Review records generated using role checklists (created in a later user story)
- `../scripts/` — Automation scripts including role activation (created in a later user story)
