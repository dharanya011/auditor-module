'use strict';

const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/', async (req, res) => {
  try {
    const cases = [];

    // Query public.audit_case_items ONLY
    const caseCheck = await pool.query(
      `SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'audit_case_items'`
    );
    
    if (caseCheck.rows.length > 0) {
      const caseRes = await pool.query(`SELECT * FROM "public"."audit_case_items" ORDER BY id DESC LIMIT 50`);
      caseRes.rows.forEach((r) => {
        cases.push({
          caseId: r.caseId ? r.caseId.toString() : '',
          title: r.title ? r.title.toString() : '',
          category: r.category ? r.category.toString() : '',
          targetRecordId: r.targetRecordId ? r.targetRecordId.toString() : '',
          severity: r.severity ? r.severity.toString() : '',
          assignedTo: r.assignedTo ? r.assignedTo.toString() : '',
          lifecycleStage: r.lifecycleStage ? r.lifecycleStage.toString() : '',
          createdDate: r.createdDate ? new Date(r.createdDate).toISOString().split('T')[0] : '',
          description: r.description ? r.description.toString() : '',
        });
      });
    }

    res.json({
      total: cases.length,
      cases,
    });
  } catch (err) {
    console.error('[cases] GET / error:', err.message);
    res.status(500).json({ error: 'Failed to fetch audit cases' });
  }
});

module.exports = router;
