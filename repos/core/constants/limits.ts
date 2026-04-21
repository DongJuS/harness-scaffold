/**
 * System-wide limits.
 * Keep under 200 lines — group by domain.
 */

export const MAX_FILE_LINES = 200;
export const MAX_FILE_SIZE_BYTES = 50_000;

export const MAX_SLUG_LENGTH = 80;
export const MAX_TITLE_LENGTH = 200;
export const MAX_DESCRIPTION_LENGTH = 2_000;

export const RATE_LIMIT_REQUESTS_PER_MINUTE = 60;
export const RATE_LIMIT_BURST = 10;
