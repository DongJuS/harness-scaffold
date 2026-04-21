# Task-to-Role Routing Matrix

## Background

In the HarnessScaffold project (a self-documenting hierarchical repository scaffold),
a solo developer handles all professional roles. Not every role is relevant to every
task. This document maps task types to the roles that should review the work, so the
AI agent applies only the perspectives that matter and avoids unnecessary overhead.

## How to Use

1. Identify your task type from the table below
2. Read all role files listed in the "Required" column — these MUST review the work
3. Optionally read role files in the "Optional" column — review if time allows
4. After completing the work, answer every checklist question from all required roles
5. Use `scripts/activate-roles.sh <task-type>` to automate this lookup

## Routing Matrix

| Task Type | Required Roles | Optional Roles |
|-----------|---------------|----------------|
| new-feature | product, architect | finance |
| backend-api | backend, security | architect, devops |
| frontend-ui | frontend | product |
| database-schema | backend, architect | security, data |
| data-pipeline | data | architect, finance |
| deployment | devops | security, finance |
| auth | security, backend | architect |
| cost-optimization | finance | devops |
| bug-fix | _(affected area role)_ | _(none)_ |
| major-refactor | architect, devops | _(affected area roles)_ |

## Task Type Descriptions

- **new-feature**: Creating a new user story, feature, or PRD item from scratch
- **backend-api**: Adding or modifying API endpoints, request handling, or server logic
- **frontend-ui**: Building or changing UI components, layouts, or client-side behavior
- **database-schema**: Creating or altering database tables, indexes, or data models
- **data-pipeline**: Building data ingestion, transformation, ML training, or analytics
- **deployment**: Configuring CI/CD, infrastructure, containers, or deployment scripts
- **auth**: Implementing authentication flows, authorization rules, or access control
- **cost-optimization**: Reducing cloud spend, optimizing API usage, or tracking budgets
- **bug-fix**: Fixing a defect — activate the role matching the affected code area
- **major-refactor**: Restructuring code, creating sub-repos, or changing conventions

## Glossary References

- **Role Profile**: A file in `roles/` defining a professional perspective with a
  review checklist — see `roles/INDEX.md` for the full list of available roles
- **HarnessScaffold**: The project name for this self-documenting repository scaffold
