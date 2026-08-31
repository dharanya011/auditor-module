'use strict';

/**
 * routes/question_papers.js
 *
 * GET /api/question-papers       — list question paper audit records (optional filters)
 * GET /api/question-papers/:id   — single question paper record
 *
 * Inspects real PostgreSQL schema before querying.
 */

const express = require('express');
const router = express.Router();
const pool = require('../db');

let qpTableInfo = null;

async function inspectQPSchema() {
  if (qpTableInfo) return qpTableInfo;

  const candidates = [
    { schema: 'public', table: 'question_paper_records' },
    { schema: 'faculty', table: 'assessment_question_sets' },
    { schema: 'faculty', table: 'question_banks' },
    { schema: 'public', table: 'question_papers' },
  ];

  for (const c of candidates) {
    const check = await pool.query(
      `SELECT column_name, data_type
       FROM information_schema.columns
       WHERE table_schema = $1 AND table_name = $2
       ORDER BY ordinal_position`,
      [c.schema, c.table]
    );
    if (check.rows.length > 0) {
      qpTableInfo = {
        fullTableName: `"${c.schema}"."${c.table}"`,
        columns: check.rows.map((r) => r.column_name),
      };
      console.log(`[question_papers] Found table: ${qpTableInfo.fullTableName} with ${qpTableInfo.columns.length} columns`);
      return qpTableInfo;
    }
  }

  const all = await pool.query(
    `SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog', 'information_schema') ORDER BY table_schema, table_name`
  );
  console.warn('[question_papers] Could not find a question paper table. Available:', all.rows);
  qpTableInfo = { fullTableName: null, columns: [], availableTables: all.rows };
  return qpTableInfo;
}

function resolveCol(cols, ...candidates) {
  for (const c of candidates) {
    if (cols.includes(c)) return c;
  }
  return null;
}

function mapQPRecord(row, cols) {
  const id = row[resolveCol(cols, 'paperId', 'id', 'course_code')] || '';
  const courseCode = row[resolveCol(cols, 'courseCode', 'course_code', 'subject_code')] || '';
  const courseTitle = row[resolveCol(cols, 'courseTitle', 'subject_name', 'assessment_name', 'title')] || '';
  const regulation = row[resolveCol(cols, 'regulation', 'reg', 'academic_year')] || 'R2023';
  const department = row[resolveCol(cols, 'department', 'departmentId', 'dept')] || '';
  const semester = parseInt(row[resolveCol(cols, 'semester', 'sem')] || 1, 10);
  const academicYear = row[resolveCol(cols, 'academicYear', 'academic_year')] || '2025 - 2026';
  const bloomTaxonomyCompliant = Boolean(row[resolveCol(cols, 'bloomTaxonomyCompliant', 'bloom_compliant')]);
  const syllabusMapped = Boolean(row[resolveCol(cols, 'syllabusMapped', 'syllabus_mapped')]);
  const hodApproved = Boolean(row[resolveCol(cols, 'hodApproved', 'hod_approved')]);
  const coeApproved = Boolean(row[resolveCol(cols, 'coeApproved', 'coe_approved')]);
  const status = row[resolveCol(cols, 'status', 'audit_status')] || 'Pending';

  return {
    id: id.toString(),
    courseCode: courseCode.toString(),
    courseTitle: courseTitle.toString(),
    regulation: regulation.toString(),
    department: department.toString(),
    semester: isNaN(semester) ? 1 : semester,
    academicYear: academicYear.toString(),
    bloomTaxonomyCompliant,
    syllabusMapped,
    hodApproved,
    coeApproved,
    status: status.toString(),
  };
}

// GET /api/question-papers
router.get('/', async (req, res) => {
  try {
    const schema = await inspectQPSchema();

    if (!schema.fullTableName) {
      return res.status(503).json({
        error: 'Question paper table not found in database',
        available_tables: schema.availableTables,
      });
    }

    const { dept, status, limit = 100, offset = 0 } = req.query;
    const params = [];
    const conditions = [];

    const cols = schema.columns;
    const deptCol = resolveCol(cols, 'department', 'departmentId', 'dept');
    const statusCol = resolveCol(cols, 'status', 'audit_status');

    if (dept && deptCol) {
      params.push(`%${dept}%`);
      conditions.push(`${deptCol}::text ILIKE $${params.length}`);
    }
    if (status && statusCol) {
      params.push(status);
      conditions.push(`${statusCol}::text = $${params.length}`);
    }

    const whereClause = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    params.push(parseInt(limit, 10));
    params.push(parseInt(offset, 10));

    const query = `
      SELECT *
      FROM ${schema.fullTableName}
      ${whereClause}
      LIMIT $${params.length - 1}
      OFFSET $${params.length}
    `;

    const result = await pool.query(query, params);
    const questionPapers = result.rows.map((row) => mapQPRecord(row, cols));

    res.json({
      total: questionPapers.length,
      questionPapers,
    });
  } catch (err) {
    console.error('[question_papers] GET / error:', err.message);
    res.status(500).json({ error: 'Failed to fetch question papers' });
  }
});

// GET /api/question-papers/:id
router.get('/:id', async (req, res) => {
  try {
    const schema = await inspectQPSchema();

    if (!schema.fullTableName) {
      return res.status(503).json({ error: 'Question paper table not found in database' });
    }

    const { id } = req.params;
    const cols = schema.columns;
    const idCol = resolveCol(cols, 'paperId', 'id', 'course_code');

    if (!idCol) {
      return res.status(500).json({ error: 'Cannot determine question paper ID column in schema' });
    }

    const result = await pool.query(
      `SELECT * FROM ${schema.fullTableName} WHERE ${idCol}::text = $1 LIMIT 1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: `Question paper '${id}' not found` });
    }

    const paper = mapQPRecord(result.rows[0], cols);
    res.json(paper);
  } catch (err) {
    console.error('[question_papers] GET /:id error:', err.message);
    res.status(500).json({ error: 'Failed to fetch question paper' });
  }
});

module.exports = router;
