/**
 * Base configuration — all settings with sensible defaults.
 * Every new setting must be added here first.
 * Environment-specific files override only what differs.
 * Keep under 200 lines — split into domain-specific files if this grows.
 */

export interface AppConfig {
  env: string;
  port: number;
  host: string;

  logging: {
    level: "debug" | "info" | "warn" | "error";
    format: "json" | "text";
    includeTimestamp: boolean;
  };

  database: {
    host: string;
    port: number;
    name: string;
    maxConnections: number;
    connectionTimeoutMs: number;
  };

  auth: {
    jwtSecret: string;
    tokenExpirationMs: number;
    refreshTokenExpirationMs: number;
    bcryptRounds: number;
  };

  api: {
    basePath: string;
    defaultPageSize: number;
    maxPageSize: number;
    rateLimitPerMinute: number;
    requestTimeoutMs: number;
  };

  cors: {
    allowedOrigins: string[];
    allowedMethods: string[];
    allowCredentials: boolean;
  };

  cache: {
    enabled: boolean;
    ttlMs: number;
    maxEntries: number;
  };
}

export const baseConfig: AppConfig = {
  env: "base",
  port: 3000,
  host: "0.0.0.0",

  logging: {
    level: "info",
    format: "json",
    includeTimestamp: true,
  },

  database: {
    host: "localhost",
    port: 5432,
    name: "harness_db",
    maxConnections: 10,
    connectionTimeoutMs: 5000,
  },

  auth: {
    jwtSecret: "CHANGE_ME_IN_ENV",
    tokenExpirationMs: 15 * 60 * 1000,
    refreshTokenExpirationMs: 7 * 24 * 60 * 60 * 1000,
    bcryptRounds: 10,
  },

  api: {
    basePath: "/api/v1",
    defaultPageSize: 20,
    maxPageSize: 100,
    rateLimitPerMinute: 60,
    requestTimeoutMs: 30000,
  },

  cors: {
    allowedOrigins: ["*"],
    allowedMethods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
    allowCredentials: false,
  },

  cache: {
    enabled: true,
    ttlMs: 5 * 60 * 1000,
    maxEntries: 1000,
  },
};
