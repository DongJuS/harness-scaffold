# config

## Purpose

Centralized configuration for the HarnessScaffold project. All environment-specific settings live here with clear separation: a shared base config and per-environment overrides. Services and other sub-repos import configuration from this directory instead of defining their own.

## Files

- `./environments/` — environment-specific configuration files (base, development, production)

## How To

- To add a new environment variable → `environments/base.ts` (add it to the base config so all environments get it)
- To override a value for production → `environments/production.ts` (override only the fields that differ)
- To override a value for development → `environments/development.ts` (override only the fields that differ)
- To add a new environment → create a new file in `environments/` that extends `baseConfig`

## Dependencies

- `../core/constants/` — may reference shared constants for default values

## Related

- `../core/` — foundational types and constants
- `../services/` — services consume config values from this directory
- `../../REGISTRY.md` — registry of all sub-repos including this one
