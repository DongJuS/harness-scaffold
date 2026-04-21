# core

## Purpose

Shared types, constants, and utility functions used across all sub-repos in the HarnessScaffold project. This is the foundational layer that other sub-repos depend on.

## Files

- `./types/` — shared type definitions used across all sub-repos
- `./utils/` — utility functions with single responsibility, used across all sub-repos
- `./constants/` — shared constants (enums, magic values, defaults)

## Dependencies

- _None — this is the foundational layer with no internal dependencies_

## Related

- `../services/` — consumes types, utils, and constants from this directory
- `../config/` — may reference constants defined here
