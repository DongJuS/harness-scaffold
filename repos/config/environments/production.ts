/**
 * Production environment overrides.
 * Extends base config with settings suited for production:
 * strict security, optimized performance, real service URLs.
 * Keep under 200 lines.
 */

import { AppConfig, baseConfig } from "./base";

export const productionConfig: AppConfig = {
  ...baseConfig,
  env: "production",
  port: 8080,
  host: "0.0.0.0",

  logging: {
    ...baseConfig.logging,
    level: "warn",
    format: "json",
  },

  database: {
    ...baseConfig.database,
    host: process.env.DB_HOST || "db.production.internal",
    port: Number(process.env.DB_PORT) || 5432,
    name: process.env.DB_NAME || "harness_prod",
    maxConnections: 50,
    connectionTimeoutMs: 3000,
  },

  auth: {
    ...baseConfig.auth,
    jwtSecret: process.env.JWT_SECRET || "MUST_SET_IN_ENV",
    tokenExpirationMs: 15 * 60 * 1000,
    refreshTokenExpirationMs: 24 * 60 * 60 * 1000,
    bcryptRounds: 12,
  },

  api: {
    ...baseConfig.api,
    rateLimitPerMinute: 30,
    requestTimeoutMs: 15000,
  },

  cors: {
    ...baseConfig.cors,
    allowedOrigins: [process.env.ALLOWED_ORIGIN || "https://app.example.com"],
    allowCredentials: true,
  },

  cache: {
    ...baseConfig.cache,
    enabled: true,
    ttlMs: 10 * 60 * 1000,
    maxEntries: 5000,
  },
};
