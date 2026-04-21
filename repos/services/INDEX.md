# services

## Purpose

Business logic modules for the HarnessScaffold project. Each service is a self-contained module with clear boundaries, its own types, validation, and handler logic. Services consume shared utilities from `../core/`.

## Files

- `./example-service/` — reference implementation showing the standard service structure (entry point, handler, validator, types)

## Dependencies

- `../core/` — shared types, utilities, and constants

## Related

- `../config/` — environment-specific settings consumed by services
- `../../REGISTRY.md` — registry of all sub-repos including this one
