# constants

## Purpose

Shared constants used across all sub-repos. Includes enums, default values, magic numbers, and configuration keys. Each file groups constants by domain and must stay under 200 lines.

## Files

- `./defaults.ts` — default values for common configuration: page sizes, timeouts, retry counts
- `./limits.ts` — system-wide limits: max file size, max line count, rate limits

## Dependencies

- `../types/` — may use shared types for type-safe constant definitions

## Related

- `../utils/` — utilities may reference these constants for default behavior
- `../../config/` — environment-specific config may override these defaults
