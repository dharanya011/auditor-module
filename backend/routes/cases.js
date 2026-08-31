'use strict';

/**
 * routes/cases.js
 *
 * GET /api/cases — fetch audit cases from real PostgreSQL database
 */

const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/', async (req, res) => {
  try {
    const cases = [];

    // 1. Query public.audit_case_items
    try {
      const caseCheck = await pool.query(
        `SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'audit_case_items'`
      );
      if (caseCheck.rows.length > 0) {
        const caseRes = await pool.query(`SELECT * FROM "public"."audit_case_items" ORDER BY id DESC LIMIT 50`);
        caseRes.rows.forEach((r) => {
          cases.push({
            caseId: (r.caseId || `AUD-${r.id}`).toString(),
            title: (r.title || 'Audit Case').toString(),
            category: (r.category || 'Audit Case').toString(),
            targetRecordId: (r.targetRecordId || `REC-${r.id}`).toString(),
            severity: (r.severity || 'Normal').toString(),
            assignedTo: (r.assignedTo || 'Unassigned').toString(),
            lifecycleStage: (r.lifecycleStage || 'Pending Verification').toString(),
            createdDate: r.createdDate ? new Date(r.createdDate).toISOString().split('T')[0] : '2026-08-29',
            description: (r.description || '').toString(),
          });
        });
      }
    } catch (err) {
      console.warn('[cases] audit_case_items query error:', err.message);
    }

    // 2. Compile cases from flagged research_records in DB
    try {
      const resCheck = await pool.query(
        `SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'research_records'`
      );
      if (resCheck.rows.length > 0) {
        const resRes = await pool.query(
          `SELECT * FROM "public"."research_records" WHERE "duplicateFlag" = true OR "status" = 'Needs Correction' ORDER BY id DESC LIMIT 20`
        );
        resRes.rows.forEach((r) => {
          cases.push({
            caseId: (r.researchId || `AUD-RES-${r.id}`).toString(),
            title: `Research verification — ${r.title || 'Paper'}`,
            category: 'Research Audit',
            targetRecordId: (r.doi || r.title || 'Research').toString(),
            severity: r.duplicateFlag ? 'High' : 'Medium',
            assignedTo: r.facultyName || 'Auditor',
            lifecycleStage: (r.status || 'Under Review').toString(),
            createdDate: r.createdAt ? new Date(r.createdAt).toISOString().split('T')[0] : '2026-08-29',
            description: (r.description || 'Duplicate / mismatch flagged in research submission.').toString(),
          });
        });
      }
    } catch (err) {
      console.warn('[cases] research_records query error:', err.message);
    }

    // 3. Compile cases from flagged assignment_records in DB
    try {
      const asgnCheck = await pool.query(
        `SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'assignment_records'`
      );
      if (asgnCheck.rows.length > 0) {
        const asgnRes = await pool.query(
          `SELECT * FROM "public"."assignment_records" WHERE "isMissingFile" = true OR "isDuplicate" = true ORDER BY id DESC LIMIT 20`
        );
        asgnRes.rows.forEach((r) => {
          cases.push({
            caseId: (r.assignmentId || `AUD-ASN-${r.id}`).toString(),
            title: `Assignment discrepancy — ${r.title || 'Assignment'}`,
            category: 'Assignment Audit',
            targetRecordId: `${r.studentName || r.registerNo} (${r.subject})`,
            severity: 'High',
            assignedTo: 'Department Auditor',
            lifecycleStage: 'Correction Requested',
            createdDate: r.createdAt ? new Date(r.createdAt).toISOString().split('T')[0] : '2026-08-29',
            description: r.isMissingFile ? 'Submission marked complete but file attachment missing.' : 'Duplicate submission flagged.',
          });
        });
      }
    } catch (err) {
      console.warn('[cases] assignment_records query error:', err.message);
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
