'use strict';

/**
 * routes/attendance.js
 *
 * GET /api/attendance/:studentId — attendance records for a specific student
 *
 * Inspects real PostgreSQL schema before querying.
 */

const express = require('express');
const router = express.Router();
const pool = require('../db');

let attendanceTableInfo = null;

async function inspectAttendanceSchema() {
  if (attendanceTableInfo) return attendanceTableInfo;

  const candidates = [
    { schema: 'student', table: 'attendance_table' },
    { schema: 'public', table: 'attendance' },
    { schema: 'public', table: 'student_attendance' },
    { schema: 'public', table: 'attendance_records' },
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
      attendanceTableInfo = {
        fullTableName: `"${c.schema}"."${c.table}"`,
        columns: check.rows.map((r) => r.column_name),
      };
      console.log(`[attendance] Found table: ${attendanceTableInfo.fullTableName} with ${attendanceTableInfo.columns.length} columns`);
      return attendanceTableInfo;
    }
  }

  const all = await pool.query(
    `SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog', 'information_schema') ORDER BY table_schema, table_name`
  );
  console.warn('[attendance] Could not find an attendance table. Available:', all.rows);
  attendanceTableInfo = { fullTableName: null, columns: [], availableTables: all.rows };
  return attendanceTableInfo;
}

function resolveCol(cols, ...candidates) {
  for (const c of candidates) {
    if (cols.includes(c)) return c;
  }
  return null;
}

function mapAttendanceRow(row, cols) {
  const attPct = row.attendance_percentage != null ? parseFloat(row.attendance_percentage) : null;
  return {
    id: row[resolveCol(cols, 'id', 'attendance_id')] || '',
    student_reg_no: row[resolveCol(cols, 'reg_no', 'student_reg_no', 'register_no', 'student_id')] || '',
    name: row[resolveCol(cols, 'name', 'full_name')] || '',
    dept: row[resolveCol(cols, 'dept', 'department')] || '',
    section: row[resolveCol(cols, 'section')] || '',
    year: row[resolveCol(cols, 'year')] || '',
    date: row[resolveCol(cols, 'date', 'attendance_date', 'recorded_date')] || null,
    attendance_percentage: attPct,
    status: row[resolveCol(cols, 'status', 'audit_status')] || 'Recorded',
  };
}

// GET /api/attendance/:studentId
router.get('/:studentId', async (req, res) => {
  try {
    const schema = await inspectAttendanceSchema();

    if (!schema.fullTableName) {
      return res.status(503).json({
        error: 'Attendance table not found in database',
        available_tables: schema.availableTables,
      });
    }

    const { studentId } = req.params;
    const cols = schema.columns;

    const matchConditions = [];
    if (cols.includes('reg_no')) matchConditions.push(`reg_no = $1`);
    if (cols.includes('student_reg_no')) matchConditions.push(`student_reg_no = $1`);
    if (cols.includes('register_no')) matchConditions.push(`register_no = $1`);
    if (cols.includes('student_id')) matchConditions.push(`student_id = $1`);

    const whereClause = matchConditions.length > 0 ? `WHERE (${matchConditions.join(' OR ')})` : '';

    const result = await pool.query(
      `SELECT * FROM ${schema.fullTableName} ${whereClause}`,
      [studentId]
    );

    const records = result.rows.map((row) => mapAttendanceRow(row, cols));

    // Calculate overall percentage from real database records
    const validPctRows = records.filter(r => r.attendance_percentage !== null);
    const overallPercentage = validPctRows.length > 0
      ? parseFloat((validPctRows.reduce((sum, r) => sum + r.attendance_percentage, 0) / validPctRows.length).toFixed(2))
      : 0;

    res.json({
      student_id: studentId,
      overall_percentage: overallPercentage,
      total_subjects: records.length,
      records,
    });
  } catch (err) {
    console.error('[attendance] GET /:studentId error:', err.message);
    res.status(500).json({ error: 'Failed to fetch attendance' });
  }
});

module.exports = router;
