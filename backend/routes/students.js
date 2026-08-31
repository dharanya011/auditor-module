'use strict';

/**
 * routes/students.js
 *
 * GET /api/students             — list all students (optional ?dept= filter)
 * GET /api/students/:studentId  — single student detail + group statuses
 *
 * This route first inspects the real PostgreSQL schema, then queries accordingly.
 * It does NOT assume specific column names — it adapts to what exists in the DB.
 */

const express = require('express');
const router = express.Router();
const pool = require('../db');

// ──────────────────────────────────────────────────────────────────────────────
// Schema inspection helper — runs once to discover table/column structure
// ──────────────────────────────────────────────────────────────────────────────
// ──────────────────────────────────────────────────────────────────────────────
// Schema inspection helper — runs once to discover table/column structure
// ──────────────────────────────────────────────────────────────────────────────
let studentTableInfo = null;

async function inspectStudentSchema() {
  if (studentTableInfo) return studentTableInfo;

  const candidates = [
    { schema: 'student', table: 'students' },
    { schema: 'public', table: 'students' },
    { schema: 'public', table: 'student_records' },
    { schema: 'public', table: 'student_audit_records' },
    { schema: 'public', table: 'student' },
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
      studentTableInfo = {
        fullTableName: `"${c.schema}"."${c.table}"`,
        columns: check.rows.map((r) => r.column_name),
        columnTypes: Object.fromEntries(check.rows.map((r) => [r.column_name, r.data_type])),
      };
      console.log(`[students] Found table: ${studentTableInfo.fullTableName} with ${studentTableInfo.columns.length} columns`);
      return studentTableInfo;
    }
  }

  const all = await pool.query(
    `SELECT table_schema, table_name FROM information_schema.tables
     WHERE table_schema NOT IN ('pg_catalog', 'information_schema') ORDER BY table_schema, table_name`
  );
  console.warn('[students] Could not find student table. Available tables:', all.rows);
  studentTableInfo = { fullTableName: null, columns: [], availableTables: all.rows };
  return studentTableInfo;
}

// ──────────────────────────────────────────────────────────────────────────────
// Column mapping — maps Flutter model field names to actual DB column names
// ──────────────────────────────────────────────────────────────────────────────
function resolveCol(cols, ...candidates) {
  for (const c of candidates) {
    if (cols.includes(c)) return c;
  }
  return null;
}

// ──────────────────────────────────────────────────────────────────────────────
// Map a raw DB row to a Flutter-compatible student object
// ──────────────────────────────────────────────────────────────────────────────
function mapStudent(row, cols) {
  return {
    register_no: row[resolveCol(cols, 'register_no', 'student_id', 'roll_no', 'id')] || row.id || '',
    name: row[resolveCol(cols, 'full_name', 'name', 'student_name')] || '',
    department: row[resolveCol(cols, 'department', 'dept', 'department_name')] || '',
    semester: row[resolveCol(cols, 'semester', 'sem', 'current_semester')] || null,
    cgpa: parseFloat(row[resolveCol(cols, 'cgpa', 'gpa', 'cumulative_gpa')] || 0),
    attendance: parseFloat(row[resolveCol(cols, 'attendance_percentage', 'attendance', 'att_percent')] || 0),
    status: row[resolveCol(cols, 'status', 'audit_status')] || 'Pending',
    photo_url: row[resolveCol(cols, 'photo_url', 'photo', 'avatar_url')] || '',
  };
}

// ──────────────────────────────────────────────────────────────────────────────
// GET /api/students
// ──────────────────────────────────────────────────────────────────────────────
router.get('/', async (req, res) => {
  try {
    const schema = await inspectStudentSchema();

    if (!schema.fullTableName) {
      return res.status(503).json({
        error: 'Student table not found in database',
        available_tables: schema.availableTables,
      });
    }

    const { dept, status, limit = 100, offset = 0 } = req.query;
    const params = [];
    const conditions = [];

    const cols = schema.columns;
    const deptCol = resolveCol(cols, 'department', 'dept', 'department_name');
    const statusCol = resolveCol(cols, 'status', 'audit_status');

    if (dept && deptCol) {
      params.push(`%${dept}%`);
      conditions.push(`${deptCol} ILIKE $${params.length}`);
    }
    if (status && statusCol) {
      params.push(status);
      conditions.push(`${statusCol} = $${params.length}`);
    }

    const whereClause = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    params.push(parseInt(limit, 10));
    params.push(parseInt(offset, 10));

    const query = `
      SELECT *
      FROM ${schema.fullTableName}
      ${whereClause}
      ORDER BY 1
      LIMIT $${params.length - 1}
      OFFSET $${params.length}
    `;

    const result = await pool.query(query, params);
    const students = result.rows.map((row) => mapStudent(row, cols));

    res.json({
      total: students.length,
      students,
    });
  } catch (err) {
    console.error('[students] GET / error:', err.message);
    res.status(500).json({ error: 'Failed to fetch students' });
  }
});

// ──────────────────────────────────────────────────────────────────────────────
// GET /api/students/:studentId
// ──────────────────────────────────────────────────────────────────────────────
router.get('/:studentId', async (req, res) => {
  try {
    const schema = await inspectStudentSchema();

    if (!schema.fullTableName) {
      return res.status(503).json({ error: 'Student table not found in database' });
    }

    const { studentId } = req.params;
    const cols = schema.columns;
    const idCol = resolveCol(cols, 'register_no', 'student_id', 'roll_no', 'id');

    if (!idCol) {
      return res.status(500).json({ error: 'Cannot determine student ID column in schema' });
    }

    const result = await pool.query(
      `SELECT * FROM ${schema.fullTableName} WHERE ${idCol} = $1 LIMIT 1`,
      [studentId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: `Student '${studentId}' not found` });
    }

    const student = mapStudent(result.rows[0], cols);

    // Try to fetch audit group statuses from a related table if it exists
    let groupStatuses = [];
    try {
      const gsCheck = await pool.query(
        `SELECT column_name FROM information_schema.columns
         WHERE table_schema = 'public'
         AND table_name IN ('student_group_statuses', 'audit_group_statuses', 'student_audit_groups')
         LIMIT 1`
      );
      if (gsCheck.rows.length > 0) {
        const gsTable = gsCheck.rows[0].table_schema; // unused but present
        const gsResult = await pool.query(
          `SELECT * FROM student_group_statuses WHERE student_id = $1`,
          [studentId]
        );
        groupStatuses = gsResult.rows.map((r) => ({
          group_name: r.group_name || r.groupname || '',
          status: r.status || 'Pending',
          details: r.details || '',
        }));
      }
    } catch (_) {
      // group status table may not exist — that's fine
    }

    res.json({ ...student, group_statuses: groupStatuses });
  } catch (err) {
    console.error('[students] GET /:studentId error:', err.message);
    res.status(500).json({ error: 'Failed to fetch student' });
  }
});

module.exports = router;
