# example-service

## Purpose

Reference implementation of a service module. Use this as the template when creating new services. Demonstrates the standard structure: entry point, request handler, input validation, and service-specific types.

## Files

- `./index.ts` — service entry point; exports the public API and wires handler to routes
- `./handler.ts` — request handler; processes incoming requests and returns responses
- `./validator.ts` — input validation; validates and sanitizes request data before handler processes it
- `./types.ts` — service-specific type definitions; request/response shapes and internal models

## How To

- To add a new endpoint → `handler.ts` (add handler function), then register in `index.ts`
- To modify validation rules → `validator.ts`
- To change request/response shapes → `types.ts`, then update `validator.ts` and `handler.ts`
- To expose a new public API → `index.ts` (add to exports)

## Dependencies

- `../../core/types/` — shared base types (Entity, ApiResponse, etc.)
- `../../core/utils/` — shared utility functions
- `../../core/constants/` — shared constants (defaults, limits)

## Related

- `../` — parent services directory; other services live alongside this one
- `../../core/` — shared foundational layer
