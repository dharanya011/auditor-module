'use strict';

const express = require('express');
const router = express.Router();
const pool = require('../db');

/**
 * GET /api/audit-history
 * Fetch audit history logs from public.auditor_audit_logs
 * The Flutter AuditLogItem model expects:
 * id, timestamp, auditorName, ipAddress, action, recordId, details
 */
router.get('/', async (req, res, next) => {
  try {
    const query = `
      SELECT 
        "logId", 
        "timestamp", 
        "auditorName", 
        "ipAddress", 
        "action", 
        "recordId", 
        "details"
      FROM "public"."auditor_audit_logs"
      ORDER BY "timestamp" DESC;
    `;
    
    const result = await pool.query(query);

    const records = result.rows.map(row => ({
      id: row.logId ? row.logId.toString() : '',
      timestamp: row.timestamp ? new Date(row.timestamp).toISOString() : '',
      auditorName: row.auditorName ? row.auditorName.toString() : '',
      ipAddress: row.ipAddress ? row.ipAddress.toString() : '',
      action: row.action ? row.action.toString() : '',
      recordId: row.recordId ? row.recordId.toString() : '',
      details: row.details ? row.details.toString() : ''
    }));

    res.json({ records });
  } catch (err) {
    if (err.code === '42P01') {
      // relation does not exist
      return res.json({ records: [] });
    }
    next(err);
  }
});

module.exports = router;
