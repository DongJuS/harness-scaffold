# repos

## Purpose

Container for all sub-repositories in the HarnessScaffold project. Each sub-directory is an independent module with its own INDEX.md and git history.

## Files

- `./core/` — Shared types, constants, and utility functions used across all sub-repos
- `./services/` — Business logic modules, each as a self-contained service
- `./config/` — Centralized configuration with per-environment separation

## Dependencies

- _None — this is the top-level container_

## Related

- `../REGISTRY.md` — Authoritative registry of all sub-repos with paths and purposes
- `../setup.sh` — Initializes git in each sub-repo after cloning
