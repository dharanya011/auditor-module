'use strict';

const express = require('express');
const router = express.Router();
const pool = require('../db');

/**
 * GET /api/db/meta/tables
 * Returns list of schemas and table names from information_schema.
 * READ-ONLY Operation.
 */
router.get('/meta/tables', async (_req, res, next) => {
  try {
    const query = `
      SELECT table_schema, table_name
      FROM information_schema.tables
      WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
      ORDER BY table_schema, table_name;
    `;
    const result = await pool.query(query);
    res.json({ tables: result.rows });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/db/:schema/:table
 * Returns read-only rows for a specific table up to limit (max 100).
 * READ-ONLY Operation.
 */
router.get('/:schema/:table', async (req, res, next) => {
  const { schema, table } = req.params;

  // Validate identifiers to prevent SQL injection
  if (!/^[a-zA-Z0-9_]+$/.test(schema) || !/^[a-zA-Z0-9_]+$/.test(table)) {
    return res.status(400).json({ error: 'Invalid schema or table name' });
  }

  const limit = Math.min(parseInt(req.query.limit, 10) || 100, 100);

  try {
    const query = `SELECT * FROM "${schema}"."${table}" LIMIT $1;`;
    const result = await pool.query(query, [limit]);
    res.json(result.rows);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
