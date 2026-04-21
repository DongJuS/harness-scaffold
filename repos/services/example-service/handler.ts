/**
 * Request handlers for example-service.
 * Processes validated requests and returns typed responses.
 */

import type {
  Item,
  CreateItemRequest,
  UpdateItemRequest,
  ItemResponse,
  ItemListResponse,
} from './types';
import { Status } from '../../core/types/common';
import { generateId } from '../../core/utils/string';

const items = new Map<string, Item>();

export function handleCreateItem(data: CreateItemRequest): ItemResponse {
  const now = new Date().toISOString();
  const item: Item = {
    id: generateId(),
    status: Status.Active,
    name: data.name,
    description: data.description ?? '',
    tags: data.tags ?? [],
    createdAt: now,
    updatedAt: now,
  };

  items.set(item.id, item);

  return { success: true, data: item };
}

export function handleGetItem(id: string): ItemResponse {
  const item = items.get(id);

  if (!item) {
    return { success: false, error: { code: 'NOT_FOUND', message: `Item ${id} not found` } };
  }

  return { success: true, data: item };
}

export function handleUpdateItem(id: string, data: UpdateItemRequest): ItemResponse {
  const item = items.get(id);

  if (!item) {
    return { success: false, error: { code: 'NOT_FOUND', message: `Item ${id} not found` } };
  }

  const updated: Item = {
    ...item,
    name: data.name ?? item.name,
    description: data.description ?? item.description,
    tags: data.tags ?? item.tags,
    updatedAt: new Date().toISOString(),
  };

  items.set(id, updated);

  return { success: true, data: updated };
}

export function handleDeleteItem(id: string): ItemResponse {
  const item = items.get(id);

  if (!item) {
    return { success: false, error: { code: 'NOT_FOUND', message: `Item ${id} not found` } };
  }

  items.delete(id);

  return { success: true, data: item };
}

export function handleListItems(page: number, pageSize: number, search?: string): ItemListResponse {
  let allItems = Array.from(items.values());

  if (search) {
    const term = search.toLowerCase();
    allItems = allItems.filter(
      (item) => item.name.toLowerCase().includes(term) || item.description.toLowerCase().includes(term),
    );
  }

  const start = (page - 1) * pageSize;
  const paged = allItems.slice(start, start + pageSize);

  return { success: true, data: paged };
}
