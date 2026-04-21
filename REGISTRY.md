# Repository Registry

This file is the single source of truth for all sub-repositories in the HarnessScaffold project.
Every sub-repo must be registered here with its path, remote URL, and purpose.

## Sub-Repositories

| Name | Path | Remote | Purpose |
|------|------|--------|---------|
| core | `./repos/core/` | _(local only)_ | Shared types, constants, and utility functions used across all sub-repos |
| services | `./repos/services/` | _(local only)_ | Business logic modules, each as a self-contained service |
| config | `./repos/config/` | _(local only)_ | Centralized configuration with per-environment separation |

## Quick Start

Clone the root repository and initialize all sub-repos:

```bash
# 1. Clone the root repository
git clone <root-remote-url> harness-scaffold
cd harness-scaffold

# 2. Run the setup script to initialize all sub-repos
./setup.sh

# 3. Verify the structure is valid
./scripts/validate.sh
```

If you do not have `setup.sh` yet, you can manually initialize each sub-repo:

```bash
# Initialize each sub-repo individually
cd repos/core && git init && cd ../..
cd repos/services && git init && cd ../..
cd repos/config && git init && cd ../..
```

To add a remote to a sub-repo after initialization:

```bash
cd repos/<name>
git remote add origin <remote-url>
```

## Conventions

- Every sub-repo lives under `./repos/`
- Every sub-repo has its own `INDEX.md` describing its contents
- Every file in any sub-repo must stay under 200 lines
- When adding a new sub-repo, register it in this table and run `./scripts/validate.sh`
