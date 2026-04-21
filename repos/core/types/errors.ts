/**
 * Standardized error types and error code enums.
 * Keep under 200 lines — split by domain if this grows.
 */

export enum ErrorCode {
  NotFound = "NOT_FOUND",
  ValidationFailed = "VALIDATION_FAILED",
  Unauthorized = "UNAUTHORIZED",
  Forbidden = "FORBIDDEN",
  Conflict = "CONFLICT",
  InternalError = "INTERNAL_ERROR",
  RateLimited = "RATE_LIMITED",
  Timeout = "TIMEOUT",
}

export interface AppError {
  code: ErrorCode;
  message: string;
  details?: Record<string, unknown>;
}

export interface ValidationError extends AppError {
  code: ErrorCode.ValidationFailed;
  field: string;
  constraint: string;
}

export type Result<T> =
  | { ok: true; value: T }
  | { ok: false; error: AppError };
