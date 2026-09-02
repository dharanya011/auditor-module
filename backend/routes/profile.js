'use strict';

const express = require('express');
const router = express.Router();
const pool = require('../db');

/**
 * GET /api/profile
 * Fetch the active auditor profile from public.auditor_users
 */
router.get('/', async (req, res, next) => {
  try {
    const query = `
      SELECT 
        id, 
        email, 
        "fullName", 
        role, 
        "departmentId", 
        "isActive"
      FROM "public"."auditor_users"
      ORDER BY id ASC
      LIMIT 1;
    `;
    
    const result = await pool.query(query);

    if (result.rows.length === 0) {
      return res.json({ profile: null });
    }

    const row = result.rows[0];
    res.json({
      profile: {
        id: row.id,
        email: row.email || '',
        fullName: row.fullName || '',
        role: row.role || '',
        departmentId: row.departmentId,
        isActive: row.isActive
      }
    });
  } catch (err) {
    if (err.code === '42P01') {
      // relation does not exist
      return res.json({ profile: null });
    }
    next(err);
  }
});

module.exports = router;
