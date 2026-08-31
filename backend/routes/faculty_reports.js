'use strict';

/**
 * routes/faculty_reports.js
 *
 * GET /api/faculty-reports       — list faculty report audit records (optional filters)
 * GET /api/faculty-reports/:id   — single faculty report audit record
 *
 * Inspects real PostgreSQL schema before querying.
 */

const express = require('express');
const router = express.Router();
const pool = require('../db');

let facultyReportTableInfo = null;

async function inspectFacultyReportSchema() {
  if (facultyReportTableInfo) return facultyReportTableInfo;

  const candidates = [
    { schema: 'public', table: 'faculty_report_records' },
    { schema: 'faculty', table: 'faculty_reports' },
    { schema: 'principal', table: 'faculty_reports' },
    { schema: 'public', table: 'faculty_reports' },
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
      facultyReportTableInfo = {
        fullTableName: `"${c.schema}"."${c.table}"`,
        columns: check.rows.map((r) => r.column_name),
      };
      console.log(`[faculty_reports] Found table: ${facultyReportTableInfo.fullTableName} with ${facultyReportTableInfo.columns.length} columns`);
      return facultyReportTableInfo;
    }
  }

  const all = await pool.query(
    `SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog', 'information_schema') ORDER BY table_schema, table_name`
  );
  console.warn('[faculty_reports] Could not find a faculty report table. Available:', all.rows);
  facultyReportTableInfo = { fullTableName: null, columns: [], availableTables: all.rows };
  return facultyReportTableInfo;
}

function resolveCol(cols, ...candidates) {
  for (const c of candidates) {
    if (cols.includes(c)) return c;
  }
  return null;
}

function mapFacultyReportRecord(row, cols) {
  const id = row[resolveCol(cols, 'reportId', 'id', 'report_id')] || '';
  const facultyName = row[resolveCol(cols, 'facultyName', 'faculty_name', 'name')] || '';
  const department = row[resolveCol(cols, 'department', 'departmentId', 'dept')] || '';
  const reportType = row[resolveCol(cols, 'reportType', 'report_type', 'type')] || 'Course Completion Report';
  const academicYear = row[resolveCol(cols, 'academicYear', 'academic_year')] || '2025 - 2026';
  const regulation = row[resolveCol(cols, 'regulation', 'reg')] || 'R2023';
  const semester = parseInt(row[resolveCol(cols, 'semester', 'sem')] || 1, 10);
  const reportedAttendance = parseFloat(row[resolveCol(cols, 'reportedAttendance', 'reported_attendance')] || 0);
  const actualAttendance = parseFloat(row[resolveCol(cols, 'actualAttendance', 'actual_attendance')] || 0);
  const syllabusCompletionPercent = parseInt(row[resolveCol(cols, 'syllabusCompletionPercent', 'syllabus_completion_percent')] || 100, 10);
  const mentoringSessionsLogged = parseInt(row[resolveCol(cols, 'mentoringSessionsLogged', 'mentoring_sessions_logged')] || 0, 10);
  const hasConflict = Boolean(row[resolveCol(cols, 'hasConflict', 'has_conflict')]);
  const conflictDetails = row[resolveCol(cols, 'conflictDetails', 'conflict_details')] || '';
  const status = row[resolveCol(cols, 'status', 'audit_status')] || 'Pending';

  return {
    id: id.toString(),
    facultyName: facultyName.toString(),
    department: department.toString(),
    reportType: reportType.toString(),
    academicYear: academicYear.toString(),
    regulation: regulation.toString(),
    semester: isNaN(semester) ? 1 : semester,
    reportedAttendance: isNaN(reportedAttendance) ? 0.0 : reportedAttendance,
    actualAttendance: isNaN(actualAttendance) ? 0.0 : actualAttendance,
    syllabusCompletionPercent: isNaN(syllabusCompletionPercent) ? 100 : syllabusCompletionPercent,
    mentoringSessionsLogged: isNaN(mentoringSessionsLogged) ? 0 : mentoringSessionsLogged,
    hasConflict,
    conflictDetails: conflictDetails.toString(),
    status: status.toString(),
  };
}

// GET /api/faculty-reports
router.get('/', async (req, res) => {
  try {
    const schema = await inspectFacultyReportSchema();

    if (!schema.fullTableName) {
      return res.status(503).json({
        error: 'Faculty report table not found in database',
        available_tables: schema.availableTables,
      });
    }

    const { dept, docType, status, limit = 100, offset = 0 } = req.query;
    const params = [];
    const conditions = [];

    const cols = schema.columns;
    const deptCol = resolveCol(cols, 'department', 'departmentId', 'dept');
    const docTypeCol = resolveCol(cols, 'reportType', 'report_type', 'type');
    const statusCol = resolveCol(cols, 'status', 'audit_status');

    if (dept && deptCol) {
      params.push(`%${dept}%`);
      conditions.push(`${deptCol}::text ILIKE $${params.length}`);
    }
    if (docType && docTypeCol) {
      params.push(`%${docType}%`);
      conditions.push(`${docTypeCol}::text ILIKE $${params.length}`);
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
    const facultyReports = result.rows.map((row) => mapFacultyReportRecord(row, cols));

    res.json({
      total: facultyReports.length,
      facultyReports,
    });
  } catch (err) {
    console.error('[faculty_reports] GET / error:', err.message);
    res.status(500).json({ error: 'Failed to fetch faculty reports' });
  }
});

// GET /api/faculty-reports/:id
router.get('/:id', async (req, res) => {
  try {
    const schema = await inspectFacultyReportSchema();

    if (!schema.fullTableName) {
      return res.status(503).json({ error: 'Faculty report table not found in database' });
    }

    const { id } = req.params;
    const cols = schema.columns;
    const idCol = resolveCol(cols, 'reportId', 'id', 'report_id');

    if (!idCol) {
      return res.status(500).json({ error: 'Cannot determine faculty report ID column in schema' });
    }

    const result = await pool.query(
      `SELECT * FROM ${schema.fullTableName} WHERE ${idCol}::text = $1 LIMIT 1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: `Faculty report '${id}' not found` });
    }

    const report = mapFacultyReportRecord(result.rows[0], cols);
    res.json(report);
  } catch (err) {
    console.error('[faculty_reports] GET /:id error:', err.message);
    res.status(500).json({ error: 'Failed to fetch faculty report' });
  }
});

module.exports = router;
