'use strict';

/**
 * routes/health.js
 * GET /api/health — DB connectivity ping
 */

const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/', async (_req, res) => {
  try {
    const result = await pool.query('SELECT NOW() AS server_time');
    res.json({
      status: 'ok',
      db: 'connected',
      server_time: result.rows[0].server_time,
      uptime_seconds: Math.floor(process.uptime()),
    });
  } catch (err) {
    // Never expose DB_PASSWORD in the error response
    res.status(503).json({
      status: 'error',
      db: 'unreachable',
      message: err.message,
    });
  }
});

module.exports = router;
