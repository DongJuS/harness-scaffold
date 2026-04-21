/**
 * Base types used across all sub-repos.
 * Keep under 200 lines — split by sub-domain if this grows.
 */

export type ID = string;

export type Timestamp = string;

export enum Status {
  Active = "active",
  Inactive = "inactive",
  Pending = "pending",
  Archived = "archived",
}

export interface Identifiable {
  id: ID;
}

export interface Timestamped {
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface Entity extends Identifiable, Timestamped {
  status: Status;
}

export interface PaginationParams {
  page: number;
  pageSize: number;
}

export interface PaginatedResult<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}
