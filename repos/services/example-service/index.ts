/**
 * Entry point for example-service.
 * Wires validation to handlers and exports the public API.
 */

import {
  validateCreateItem,
  validateUpdateItem,
  validateGetItem,
  validateListItems,
} from './validator';
import {
  handleCreateItem,
  handleGetItem,
  handleUpdateItem,
  handleDeleteItem,
  handleListItems,
} from './handler';
import type { ItemResponse, ItemListResponse, ValidationResult } from './types';

function failValidation(errors: NonNullable<ValidationResult['errors']>): ItemResponse {
  return {
    success: false,
    error: { code: 'VALIDATION_ERROR', message: errors.map((e) => `${e.field}: ${e.message}`).join('; ') },
  };
}

export function createItem(input: unknown): ItemResponse {
  const validation = validateCreateItem(input);
  if (!validation.valid || !validation.data) return failValidation(validation.errors!);
  return handleCreateItem(validation.data);
}

export function getItem(input: unknown): ItemResponse {
  const validation = validateGetItem(input);
  if (!validation.valid || !validation.data) return failValidation(validation.errors!);
  return handleGetItem(validation.data.id);
}

export function updateItem(id: string, input: unknown): ItemResponse {
  const validation = validateUpdateItem(input);
  if (!validation.valid || !validation.data) return failValidation(validation.errors!);
  return handleUpdateItem(id, validation.data);
}

export function deleteItem(id: string): ItemResponse {
  return handleDeleteItem(id);
}

export function listItems(input?: unknown): ItemListResponse {
  const validation = validateListItems(input ?? {});
  if (!validation.valid || !validation.data) {
    return {
      success: false,
      error: { code: 'VALIDATION_ERROR', message: validation.errors!.map((e) => `${e.field}: ${e.message}`).join('; ') },
    };
  }
  return handleListItems(validation.data.page!, validation.data.pageSize!, validation.data.search);
}
