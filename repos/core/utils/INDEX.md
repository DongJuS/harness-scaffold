# utils

## Purpose

Utility functions used across all sub-repos. Each file has a single responsibility and must stay under 200 lines. Functions should be pure where possible and have no side effects.

## Files

- `./string.ts` — string manipulation helpers: slugify, truncate, capitalize
- `./date.ts` — date formatting and comparison helpers

## Dependencies

- `../types/` — uses shared type definitions for input/output signatures

## Related

- `../constants/` — may use constants for default values
- `../../services/` — services consume these utilities
