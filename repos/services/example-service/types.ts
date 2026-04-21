/**
 * Service-specific types for example-service.
 * Each service defines its own request/response shapes and internal models.
 */

import type { Entity, ApiResponse } from '../../core/types/common';

// --- Request Types ---

export interface CreateItemRequest {
  name: string;
  description?: string;
  tags?: string[];
}

export interface UpdateItemRequest {
  name?: string;
  description?: string;
  tags?: string[];
}

export interface GetItemRequest {
  id: string;
}

export interface ListItemsRequest {
  page?: number;
  pageSize?: number;
  search?: string;
}

// --- Domain Models ---

export interface Item extends Entity {
  name: string;
  description: string;
  tags: string[];
}

// --- Response Types ---

export type ItemResponse = ApiResponse<Item>;
export type ItemListResponse = ApiResponse<Item[]>;

// --- Validation Result ---

export interface ValidationResult<T = unknown> {
  valid: boolean;
  data?: T;
  errors?: ValidationError[];
}

export interface ValidationError {
  field: string;
  message: string;
  code: string;
}
