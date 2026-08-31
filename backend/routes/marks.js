'use strict';

/**
 * routes/marks.js
 *
 * GET /api/marks/:studentId — marks / audit entries for a specific student
 *
 * Inspects real PostgreSQL schema before querying.
 */

const express = require('express');
const router = express.Router();
const pool = require('../db');

let marksTableInfo = null;

async function inspectMarksSchema() {
  if (marksTableInfo) return marksTableInfo;

  const candidates = [
    { schema: 'faculty', table: 'marks' },
    { schema: 'public', table: 'marks' },
    { schema: 'public', table: 'marks_audit' },
    { schema: 'public', table: 'marks_audit_entries' },
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
      marksTableInfo = {
        fullTableName: `"${c.schema}"."${c.table}"`,
        columns: check.rows.map((r) => r.column_name),
      };
      console.log(`[marks] Found table: ${marksTableInfo.fullTableName} with ${marksTableInfo.columns.length} columns`);
      return marksTableInfo;
    }
  }

  const all = await pool.query(
    `SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog', 'information_schema') ORDER BY table_schema, table_name`
  );
  console.warn('[marks] Could not find a marks table. Available tables:', all.rows);
  marksTableInfo = { fullTableName: null, columns: [], availableTables: all.rows };
  return marksTableInfo;
}

function resolveCol(cols, ...candidates) {
  for (const c of candidates) {
    if (cols.includes(c)) return c;
  }
  return null;
}

function mapMarksEntry(row, cols) {
  return {
    id: row[resolveCol(cols, 'id', 'marks_id', 'entry_id')] || '',
    student_reg_no: row[resolveCol(cols, 'student_id', 'register_no', 'student_reg_no', 'reg_no')] || '',
    student_name: row[resolveCol(cols, 'student_name', 'name')] || '',
    subject_code: row[resolveCol(cols, 'subject_code', 'subject', 'course_code', 'code')] || '',
    subject_name: row[resolveCol(cols, 'subject', 'subject_name', 'course_name')] || '',
    faculty_entry: parseInt(row[resolveCol(cols, 'faculty_entry', 'total', 'faculty_marks', 'internal_marks')] || 0, 10),
    dept_record: parseInt(row[resolveCol(cols, 'dept_record', 'department_record', 'dept_marks')] || 0, 10),
    exam_record: parseInt(row[resolveCol(cols, 'exam_record', 'examination_record', 'exam_marks')] || 0, 10),
    final_result: parseInt(row[resolveCol(cols, 'final_result', 'total', 'final_marks', 'result')] || 0, 10),
    is_mismatch: Boolean(row[resolveCol(cols, 'is_mismatch', 'mismatch', 'has_discrepancy')]),
    mismatch_reason: row[resolveCol(cols, 'mismatch_reason', 'remarks', 'discrepancy_reason', 'reason')] || '',
    status: row[resolveCol(cols, 'status', 'audit_status')] || 'Pending',
  };
}

// GET /api/marks/:studentId
router.get('/:studentId', async (req, res) => {
  try {
    const schema = await inspectMarksSchema();

    if (!schema.fullTableName) {
      return res.status(503).json({
        error: 'Marks table not found in database',
        available_tables: schema.availableTables,
      });
    }

    const { studentId } = req.params;
    const cols = schema.columns;

    const matchConditions = [];
    if (cols.includes('student_id')) matchConditions.push(`student_id = $1`);
    if (cols.includes('register_no')) matchConditions.push(`register_no = $1`);
    if (cols.includes('student_roll')) matchConditions.push(`student_roll = $1`);

    const whereClause = matchConditions.length > 0 ? `WHERE (${matchConditions.join(' OR ')})` : '';

    const result = await pool.query(
      `SELECT * FROM ${schema.fullTableName} ${whereClause}`,
      [studentId]
    );

    const entries = result.rows.map((row) => mapMarksEntry(row, cols));

    res.json({
      student_id: studentId,
      total: entries.length,
      marks: entries,
    });
  } catch (err) {
    console.error('[marks] GET /:studentId error:', err.message);
    res.status(500).json({ error: 'Failed to fetch marks' });
  }
});

module.exports = router;
