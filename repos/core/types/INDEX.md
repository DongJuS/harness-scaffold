# types

## Purpose

Shared type definitions used across all sub-repos. Each file defines types for a single domain concept and must stay under 200 lines. When a type file grows beyond 200 lines, split it by sub-domain.

## Files

- `./common.ts` — base types used everywhere: ID types, timestamps, status enums, pagination
- `./errors.ts` — standardized error types and error code enums

## Dependencies

- _None — types are self-contained definitions with no runtime dependencies_

## Related

- `../utils/` — utility functions that operate on these types
- `../constants/` — constants that may use these types for type-safe definitions
