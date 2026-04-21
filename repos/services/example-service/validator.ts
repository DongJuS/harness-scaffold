/**
 * Input validation for example-service.
 * Validates and sanitizes request data before the handler processes it.
 */

import type {
  CreateItemRequest,
  UpdateItemRequest,
  GetItemRequest,
  ListItemsRequest,
  ValidationResult,
  ValidationError,
} from './types';
import { DEFAULT_MAX_PAGE_SIZE, DEFAULT_PAGE_SIZE } from '../../core/constants/defaults';
import { MAX_NAME_LENGTH } from '../../core/constants/limits';

export function validateCreateItem(input: unknown): ValidationResult<CreateItemRequest> {
  const errors: ValidationError[] = [];
  const data = input as Record<string, unknown>;

  if (!data || typeof data !== 'object') {
    return { valid: false, errors: [{ field: 'body', message: 'Request body must be an object', code: 'INVALID_BODY' }] };
  }

  if (typeof data.name !== 'string' || data.name.trim().length === 0) {
    errors.push({ field: 'name', message: 'Name is required and must be a non-empty string', code: 'REQUIRED' });
  } else if (data.name.length > MAX_NAME_LENGTH) {
    errors.push({ field: 'name', message: `Name must be ${MAX_NAME_LENGTH} characters or fewer`, code: 'TOO_LONG' });
  }

  if (data.description !== undefined && typeof data.description !== 'string') {
    errors.push({ field: 'description', message: 'Description must be a string', code: 'INVALID_TYPE' });
  }

  if (data.tags !== undefined) {
    if (!Array.isArray(data.tags) || !data.tags.every((t: unknown) => typeof t === 'string')) {
      errors.push({ field: 'tags', message: 'Tags must be an array of strings', code: 'INVALID_TYPE' });
    }
  }

  if (errors.length > 0) {
    return { valid: false, errors };
  }

  return {
    valid: true,
    data: {
      name: (data.name as string).trim(),
      description: data.description as string | undefined,
      tags: (data.tags as string[] | undefined) ?? [],
    },
  };
}

export function validateUpdateItem(input: unknown): ValidationResult<UpdateItemRequest> {
  const errors: ValidationError[] = [];
  const data = input as Record<string, unknown>;

  if (!data || typeof data !== 'object') {
    return { valid: false, errors: [{ field: 'body', message: 'Request body must be an object', code: 'INVALID_BODY' }] };
  }

  if (data.name !== undefined) {
    if (typeof data.name !== 'string' || data.name.trim().length === 0) {
      errors.push({ field: 'name', message: 'Name must be a non-empty string', code: 'INVALID_VALUE' });
    } else if (data.name.length > MAX_NAME_LENGTH) {
      errors.push({ field: 'name', message: `Name must be ${MAX_NAME_LENGTH} characters or fewer`, code: 'TOO_LONG' });
    }
  }

  if (data.description !== undefined && typeof data.description !== 'string') {
    errors.push({ field: 'description', message: 'Description must be a string', code: 'INVALID_TYPE' });
  }

  if (data.tags !== undefined) {
    if (!Array.isArray(data.tags) || !data.tags.every((t: unknown) => typeof t === 'string')) {
      errors.push({ field: 'tags', message: 'Tags must be an array of strings', code: 'INVALID_TYPE' });
    }
  }

  if (errors.length > 0) {
    return { valid: false, errors };
  }

  return {
    valid: true,
    data: {
      name: data.name ? (data.name as string).trim() : undefined,
      description: data.description as string | undefined,
      tags: data.tags as string[] | undefined,
    },
  };
}

export function validateGetItem(input: unknown): ValidationResult<GetItemRequest> {
  const data = input as Record<string, unknown>;

  if (!data?.id || typeof data.id !== 'string') {
    return { valid: false, errors: [{ field: 'id', message: 'ID is required and must be a string', code: 'REQUIRED' }] };
  }

  return { valid: true, data: { id: data.id } };
}

export function validateListItems(input: unknown): ValidationResult<ListItemsRequest> {
  const errors: ValidationError[] = [];
  const data = (input as Record<string, unknown>) ?? {};

  const page = data.page !== undefined ? Number(data.page) : 1;
  if (isNaN(page) || page < 1) {
    errors.push({ field: 'page', message: 'Page must be a positive integer', code: 'INVALID_VALUE' });
  }

  const pageSize = data.pageSize !== undefined ? Number(data.pageSize) : DEFAULT_PAGE_SIZE;
  if (isNaN(pageSize) || pageSize < 1 || pageSize > DEFAULT_MAX_PAGE_SIZE) {
    errors.push({ field: 'pageSize', message: `Page size must be between 1 and ${DEFAULT_MAX_PAGE_SIZE}`, code: 'OUT_OF_RANGE' });
  }

  if (data.search !== undefined && typeof data.search !== 'string') {
    errors.push({ field: 'search', message: 'Search must be a string', code: 'INVALID_TYPE' });
  }

  if (errors.length > 0) {
    return { valid: false, errors };
  }

  return {
    valid: true,
    data: { page, pageSize, search: data.search as string | undefined },
  };
}
