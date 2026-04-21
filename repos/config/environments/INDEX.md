# environments

## Purpose

Per-environment configuration files. Each environment extends the base config with its own overrides. The base config defines all available settings with sensible defaults; environment-specific files override only what differs.

## Files

- `./base.ts` — base configuration with all settings and their default values; every new setting starts here
- `./development.ts` — development environment overrides; enables verbose logging, uses local service URLs
- `./production.ts` — production environment overrides; strict security, optimized performance, real service URLs

## How To

- To add a new environment variable → `base.ts` (add it with a sensible default)
- To override for production → `production.ts` (override only the fields that differ from base)
- To override for development → `development.ts` (override only the fields that differ from base)
- To add a new environment → create a new file that imports and spreads `baseConfig`, overriding specific fields

## Dependencies

- `../../core/constants/` — shared constants for default values (page sizes, timeouts, limits)

## Related

- `../` — parent config directory
- `../../core/constants/defaults.ts` — source of default values used in base config
