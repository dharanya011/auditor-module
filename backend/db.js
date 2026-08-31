'use strict';

/**
 * db.js — PostgreSQL connection pool
 *
 * Credentials are loaded ONLY from environment variables (via dotenv in server.js).
 * DB_PASSWORD is never logged, echoed, or returned in API responses.
 */

const { Pool } = require('pg');

// Validate that all required environment variables are present
const required = ['DB_HOST', 'DB_NAME', 'DB_USER', 'DB_PASSWORD'];
for (const key of required) {
  if (!process.env[key]) {
    console.error(`[db] Missing required environment variable: ${key}`);
    process.exit(1);
  }
}

const pool = new Pool({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || '5432', 10),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  // Connection pool settings
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});

// Test connectivity on startup (logs success/failure — never logs credentials)
pool.connect((err, client, release) => {
  if (err) {
    console.error('[db] Failed to connect to PostgreSQL:', err.message);
  } else {
    console.log('[db] PostgreSQL connected successfully');
    release();
  }
});

module.exports = pool;
