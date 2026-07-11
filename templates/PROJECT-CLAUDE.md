# CLAUDE.md — Project Rules

## Active Project Repository

This repository is a cloned project created from HarnessScaffold.
Project-specific work belongs here.
Do not modify the upstream template repository when the change is only for this project.
If a change would improve all future projects, apply it to the template separately.

## Purpose

This file is the entry point for project policies.
Detailed rules live under `./policies/` so each topic has a dedicated file and stays easy to find.
If you need a policy for a specific concern, use the map below and open the relevant file.

## Policy Map

- Repository structure, 200-line limit, `INDEX.md`, `REGISTRY.md`, and navigation:
  `./policies/core-structure.md`
- Automation scripts, verification flow, and pre-commit workflow:
  `./policies/automation-workflow.md`
- Journals, deliberations, timeline, authority, ADR supersede chain, rollback, and conflicts:
  `./policies/logs-and-decisions.md`
- Writing standard, session handoff, context loading, cross-session sync, role review, and dashboard:
  `./policies/session-collaboration.md`
- External project linking and cross-project dependency handling:
  `./policies/external-projects.md`
- Directory overview of all policy files:
  `./policies/INDEX.md`

## Required Reading Order

1. Start with this file.
2. Always read `./policies/core-structure.md`.
3. Read the topic-specific policy files needed for the current task.
4. Follow `./START-HERE.md` when the task requires broader project context.

## Non-Negotiables

- Treat this repository as the active project workspace.
- Do not skip `./policies/core-structure.md`.
- Before committing, follow `./policies/automation-workflow.md`.
- Before work involving another project, read `./policies/external-projects.md`.
