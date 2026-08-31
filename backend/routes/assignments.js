'use strict';

/**
 * routes/assignments.js
 *
 * GET /api/assignments       — list assignment audit records (optional filters)
 * GET /api/assignments/:id   — single assignment audit record
 *
 * Inspects real PostgreSQL schema before querying.
 */

const express = require('express');
const router = express.Router();
const pool = require('../db');

let assignmentTableInfo = null;

async function inspectAssignmentSchema() {
  if (assignmentTableInfo) return assignmentTableInfo;

  const candidates = [
    { schema: 'public', table: 'assignment_records' },
    { schema: 'faculty', table: 'assignment_marks' },
    { schema: 'faculty', table: 'assignments' },
    { schema: 'public', table: 'assignments' },
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
      assignmentTableInfo = {
        fullTableName: `"${c.schema}"."${c.table}"`,
        columns: check.rows.map((r) => r.column_name),
      };
      console.log(`[assignments] Found table: ${assignmentTableInfo.fullTableName} with ${assignmentTableInfo.columns.length} columns`);
      return assignmentTableInfo;
    }
  }

  const all = await pool.query(
    `SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog', 'information_schema') ORDER BY table_schema, table_name`
  );
  console.warn('[assignments] Could not find an assignment table. Available:', all.rows);
  assignmentTableInfo = { fullTableName: null, columns: [], availableTables: all.rows };
  return assignmentTableInfo;
}

function resolveCol(cols, ...candidates) {
  for (const c of candidates) {
    if (cols.includes(c)) return c;
  }
  return null;
}

function mapAssignmentRecord(row, cols) {
  const regNo = row[resolveCol(cols, 'studentRegNo', 'reg_no', 'student_id', 'student_reg_no', 'register_no')] || '';
  const name = row[resolveCol(cols, 'studentName', 'name', 'full_name', 'student_name')] || '';
  const title = row[resolveCol(cols, 'title', 'assignment_title', 'subject_name')] || '';
  const subject = row[resolveCol(cols, 'subject', 'subject_code', 'course_code')] || '';
  const submissionDate = row[resolveCol(cols, 'submissionDate', 'submitted_at', 'created_at', 'due_date')] || '';
  const marksObtained = parseInt(row[resolveCol(cols, 'marksObtained', 'marks', 'obtained_marks')] || 0, 10);
  const totalMarks = parseInt(row[resolveCol(cols, 'totalMarks', 'total_marks', 'max_marks')] || 100, 10);
  const evidenceFile = row[resolveCol(cols, 'evidenceFile', 'assignment_file', 'attachment_url')] || '';
  const isMissingFile = Boolean(row[resolveCol(cols, 'isMissingFile', 'missing_file')]) || (evidenceFile === '');
  const isLate = Boolean(row[resolveCol(cols, 'isLate', 'is_late')]);
  const isDuplicate = Boolean(row[resolveCol(cols, 'isDuplicate', 'is_duplicate')]);
  const status = row[resolveCol(cols, 'status', 'audit_status')] || 'Pending';

  return {
    id: (row[resolveCol(cols, 'id', 'assignmentId', 'assignment_id')] || '').toString(),
    studentRegNo: regNo.toString(),
    studentName: name.toString(),
    title: title.toString(),
    subject: subject.toString(),
    submissionDate: submissionDate ? submissionDate.toString() : '',
    marksObtained: isNaN(marksObtained) ? 0 : marksObtained,
    totalMarks: isNaN(totalMarks) ? 100 : totalMarks,
    evidenceFile: evidenceFile.toString(),
    isMissingFile: isMissingFile,
    isLate: isLate,
    isDuplicate: isDuplicate,
    status: status.toString(),
  };
}

// GET /api/assignments
router.get('/', async (req, res) => {
  try {
    const schema = await inspectAssignmentSchema();

    if (!schema.fullTableName) {
      return res.status(503).json({
        error: 'Assignment table not found in database',
        available_tables: schema.availableTables,
      });
    }

    const { dept, studentId, status, limit = 100, offset = 0 } = req.query;
    const params = [];
    const conditions = [];

    const cols = schema.columns;
    const deptCol = resolveCol(cols, 'department', 'departmentId', 'dept');
    const studentCol = resolveCol(cols, 'studentRegNo', 'reg_no', 'student_id', 'student_reg_no', 'register_no');
    const statusCol = resolveCol(cols, 'status', 'audit_status');

    if (dept && deptCol) {
      params.push(`%${dept}%`);
      conditions.push(`${deptCol}::text ILIKE $${params.length}`);
    }
    if (studentId && studentCol) {
      params.push(studentId);
      conditions.push(`${studentCol}::text = $${params.length}`);
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
    const assignments = result.rows.map((row) => mapAssignmentRecord(row, cols));

    res.json({
      total: assignments.length,
      assignments,
    });
  } catch (err) {
    console.error('[assignments] GET / error:', err.message);
    res.status(500).json({ error: 'Failed to fetch assignments' });
  }
});

// GET /api/assignments/:id
router.get('/:id', async (req, res) => {
  try {
    const schema = await inspectAssignmentSchema();

    if (!schema.fullTableName) {
      return res.status(503).json({ error: 'Assignment table not found in database' });
    }

    const { id } = req.params;
    const cols = schema.columns;
    const idCol = resolveCol(cols, 'id', 'assignmentId', 'assignment_id');

    if (!idCol) {
      return res.status(500).json({ error: 'Cannot determine assignment ID column in schema' });
    }

    const result = await pool.query(
      `SELECT * FROM ${schema.fullTableName} WHERE ${idCol}::text = $1 LIMIT 1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: `Assignment '${id}' not found` });
    }

    const assignment = mapAssignmentRecord(result.rows[0], cols);
    res.json(assignment);
  } catch (err) {
    console.error('[assignments] GET /:id error:', err.message);
    res.status(500).json({ error: 'Failed to fetch assignment' });
  }
});

module.exports = router;
