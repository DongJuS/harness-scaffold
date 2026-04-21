/**
 * Date formatting and comparison helpers.
 * Keep under 200 lines — one responsibility per function.
 */

export function toISODate(date: Date): string {
  return date.toISOString().split("T")[0];
}

export function toISOTimestamp(date: Date): string {
  return date.toISOString();
}

export function isAfter(a: Date, b: Date): boolean {
  return a.getTime() > b.getTime();
}

export function isBefore(a: Date, b: Date): boolean {
  return a.getTime() < b.getTime();
}

export function daysBetween(a: Date, b: Date): number {
  const msPerDay = 86_400_000;
  return Math.round(Math.abs(a.getTime() - b.getTime()) / msPerDay);
}
