/**
 * Development environment overrides.
 * Extends base config with settings suited for local development:
 * verbose logging, relaxed limits, local service URLs.
 * Keep under 200 lines.
 */

import { AppConfig, baseConfig } from "./base";

export const developmentConfig: AppConfig = {
  ...baseConfig,
  env: "development",
  port: 3000,
  host: "localhost",

  logging: {
    ...baseConfig.logging,
    level: "debug",
    format: "text",
  },

  database: {
    ...baseConfig.database,
    host: "localhost",
    name: "harness_dev",
    maxConnections: 5,
  },

  auth: {
    ...baseConfig.auth,
    jwtSecret: "dev-secret-not-for-production",
    tokenExpirationMs: 24 * 60 * 60 * 1000,
    bcryptRounds: 4,
  },

  api: {
    ...baseConfig.api,
    rateLimitPerMinute: 1000,
    requestTimeoutMs: 60000,
  },

  cors: {
    ...baseConfig.cors,
    allowedOrigins: ["http://localhost:3000", "http://localhost:5173"],
    allowCredentials: true,
  },

  cache: {
    ...baseConfig.cache,
    enabled: false,
  },
};
