'use strict';

/**
 * routes/work_queue.js
 *
 * GET /api/work-queue  — fetch work queue tasks from real PostgreSQL database
 */

const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/', async (req, res) => {
  try {
    const tasks = [];

    // 1. Fetch cases from public.audit_case_items if exists
    try {
      const caseCheck = await pool.query(
        `SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'audit_case_items'`
      );
      if (caseCheck.rows.length > 0) {
        const caseRes = await pool.query(`SELECT * FROM "public"."audit_case_items" ORDER BY id DESC LIMIT 50`);
        caseRes.rows.forEach((r) => {
          tasks.push({
            id: (r.caseId || `AUD-${r.id}`).toString(),
            target: (r.targetRecordId || r.title || 'Audit Item').toString(),
            module: (r.category || 'Audit Case').toString(),
            dept: r.assignedToDept ? `DEPT-${r.assignedToDept}` : 'CSE',
            priority: (r.severity || 'Normal').toString(),
            status: (r.lifecycleStage || 'Pending Verification').toString(),
            description: (r.description || '').toString(),
          });
        });
      }
    } catch (err) {
      console.warn('[work_queue] audit_case_items query error:', err.message);
    }

    // 2. Fetch pending items from public.research_records
    try {
      const resCheck = await pool.query(
        `SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'research_records'`
      );
      if (resCheck.rows.length > 0) {
        const resRes = await pool.query(`SELECT * FROM "public"."research_records" ORDER BY id DESC LIMIT 20`);
        resRes.rows.forEach((r) => {
          tasks.push({
            id: (r.researchId || `RES-${r.id}`).toString(),
            target: `${r.title || 'Research Paper'} (${r.facultyName || r.authors || 'Faculty'})`,
            module: 'Research Audit',
            dept: r.departmentId ? `DEPT-${r.departmentId}` : 'CSE',
            priority: r.duplicateFlag ? 'High' : 'Medium',
            status: (r.status || 'Pending Examination').toString(),
            description: (r.description || '').toString(),
          });
        });
      }
    } catch (err) {
      console.warn('[work_queue] research_records query error:', err.message);
    }

    // 3. Fetch pending items from public.question_paper_records
    try {
      const qpCheck = await pool.query(
        `SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'question_paper_records'`
      );
      if (qpCheck.rows.length > 0) {
        const qpRes = await pool.query(`SELECT * FROM "public"."question_paper_records" ORDER BY id DESC LIMIT 20`);
        qpRes.rows.forEach((r) => {
          tasks.push({
            id: (r.paperId || `QP-${r.id}`).toString(),
            target: `${r.courseCode || ''} ${r.courseTitle || 'Question Paper'}`,
            module: 'Question Paper Audit',
            dept: r.departmentId ? `DEPT-${r.departmentId}` : 'IT',
            priority: r.bloomTaxonomyCompliant ? 'Normal' : 'High',
            status: (r.status || 'Pending Verification').toString(),
            description: '',
          });
        });
      }
    } catch (err) {
      console.warn('[work_queue] question_paper_records query error:', err.message);
    }

    // 4. Fetch pending items from public.faculty_report_records
    try {
      const repCheck = await pool.query(
        `SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'faculty_report_records'`
      );
      if (repCheck.rows.length > 0) {
        const repRes = await pool.query(`SELECT * FROM "public"."faculty_report_records" ORDER BY id DESC LIMIT 20`);
        repRes.rows.forEach((r) => {
          tasks.push({
            id: (r.reportId || `REP-${r.id}`).toString(),
            target: `${r.reportType || 'Report'} (${r.facultyName || 'Faculty'})`,
            module: 'Faculty Report Audit',
            dept: r.departmentId ? `DEPT-${r.departmentId}` : 'CSE',
            priority: r.hasConflict ? 'High' : 'Normal',
            status: (r.status || 'Under Review').toString(),
            description: (r.conflictDetails || '').toString(),
          });
        });
      }
    } catch (err) {
      console.warn('[work_queue] faculty_report_records query error:', err.message);
    }

    // 5. Fetch pending items from public.assignment_records
    try {
      const asgnCheck = await pool.query(
        `SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'assignment_records'`
      );
      if (asgnCheck.rows.length > 0) {
        const asgnRes = await pool.query(`SELECT * FROM "public"."assignment_records" ORDER BY id DESC LIMIT 20`);
        asgnRes.rows.forEach((r) => {
          tasks.push({
            id: (r.assignmentId || `ASN-${r.id}`).toString(),
            target: `${r.title || 'Assignment'} (${r.studentName || r.registerNo || 'Student'})`,
            module: 'Assignment Audit',
            dept: 'CSE',
            priority: r.isMissingFile || r.isDuplicate ? 'High' : 'Normal',
            status: (r.status || 'Pending Verification').toString(),
            description: '',
          });
        });
      }
    } catch (err) {
      console.warn('[work_queue] assignment_records query error:', err.message);
    }

    res.json({
      total: tasks.length,
      tasks,
    });
  } catch (err) {
    console.error('[work_queue] GET / error:', err.message);
    res.status(500).json({ error: 'Failed to fetch work queue tasks' });
  }
});

module.exports = router;
