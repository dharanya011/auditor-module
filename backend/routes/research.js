'use strict';

/**
 * routes/research.js
 *
 * GET  /api/research       — list research audit records (optional filters)
 * POST /api/research       — add new research paper record
 * GET  /api/research/:id   — single research audit record
 *
 * Inspects real PostgreSQL schema before querying.
 */

const express = require('express');
const router = express.Router();
const pool = require('../db');

let researchTableInfo = null;

async function inspectResearchSchema() {
  if (researchTableInfo) return researchTableInfo;

  const candidates = [
    { schema: 'public', table: 'research_records' },
    { schema: 'faculty', table: 'research_publications' },
    { schema: 'faculty', table: 'publications' },
    { schema: 'principal', table: 'profile_research_papers' },
    { schema: 'public', table: 'publications' },
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
      researchTableInfo = {
        fullTableName: `"${c.schema}"."${c.table}"`,
        columns: check.rows.map((r) => r.column_name),
      };
      console.log(`[research] Found table: ${researchTableInfo.fullTableName} with ${researchTableInfo.columns.length} columns`);
      return researchTableInfo;
    }
  }

  const all = await pool.query(
    `SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog', 'information_schema') ORDER BY table_schema, table_name`
  );
  console.warn('[research] Could not find a research table. Available:', all.rows);
  researchTableInfo = { fullTableName: null, columns: [], availableTables: all.rows };
  return researchTableInfo;
}

function resolveCol(cols, ...candidates) {
  for (const c of candidates) {
    if (cols.includes(c)) return c;
  }
  return null;
}

function mapResearchRecord(row, cols) {
  const id = row[resolveCol(cols, 'researchId', 'id', 'doi')] || '';
  const title = row[resolveCol(cols, 'title', 'paper_title')] || '';
  const authors = row[resolveCol(cols, 'authors', 'author_names')] || '';
  const type = row[resolveCol(cols, 'type', 'pub_type', 'publication_type')] || 'Journal Article';
  const doi = row[resolveCol(cols, 'doi', 'doi_or_link')] || '';
  const journalName = row[resolveCol(cols, 'journalName', 'journal_or_conf_name', 'journal')] || '';
  const indexing = row[resolveCol(cols, 'indexing', 'index_type')] || 'Scopus';
  const year = row[resolveCol(cols, 'year', 'publication_date', 'created_at')] || '2025';
  const yearClean = year ? year.toString().substring(0, 4) : '2025';
  const metadataMatch = Boolean(row[resolveCol(cols, 'metadataMatch', 'metadata_match')]);
  const duplicateFlag = Boolean(row[resolveCol(cols, 'duplicateFlag', 'is_duplicate')]);
  const status = row[resolveCol(cols, 'status', 'verification_status', 'audit_status')] || 'Pending Examination';
  const organization = row[resolveCol(cols, 'organization', 'org')] || 'KSR College of Engineering';
  const department = row[resolveCol(cols, 'department', 'dept')] || 'Computer Science & Engineering';
  const facultyName = row[resolveCol(cols, 'facultyName', 'faculty_employee_id', 'faculty')] || '';
  const description = row[resolveCol(cols, 'description')] || '';
  const documentName = row[resolveCol(cols, 'documentName', 'document_url')] || '';
  const documentType = row[resolveCol(cols, 'documentType')] || 'PDF Document';
  const documentSize = row[resolveCol(cols, 'documentSize')] || '';
  const documentStatus = row[resolveCol(cols, 'documentStatus')] || 'Uploaded';
  const checklist = row[resolveCol(cols, 'verificationChecklist')] || {};
  const remarks = row[resolveCol(cols, 'auditorRemarks', 'rejection_remarks')] || '';

  return {
    id: id.toString(),
    title: title.toString(),
    authors: authors.toString(),
    type: type.toString(),
    doi: doi.toString(),
    journalName: journalName.toString(),
    indexing: indexing.toString(),
    year: yearClean,
    metadataMatch,
    duplicateFlag,
    status: status.toString(),
    organization: organization.toString(),
    department: department.toString(),
    facultyName: facultyName.toString(),
    description: description.toString(),
    documentName: documentName.toString(),
    documentType: documentType.toString(),
    documentSize: documentSize.toString(),
    documentStatus: documentStatus.toString(),
    verificationChecklist: typeof checklist === 'object' && checklist !== null ? checklist : {},
    auditorRemarks: remarks.toString(),
  };
}

// GET /api/research
router.get('/', async (req, res) => {
  try {
    const schema = await inspectResearchSchema();

    if (!schema.fullTableName) {
      return res.status(503).json({
        error: 'Research table not found in database',
        available_tables: schema.availableTables,
      });
    }

    const { dept, org, faculty, type, status, limit = 100, offset = 0 } = req.query;
    const params = [];
    const conditions = [];

    const cols = schema.columns;
    const deptCol = resolveCol(cols, 'department', 'departmentId', 'dept');
    const orgCol = resolveCol(cols, 'organization', 'org');
    const facCol = resolveCol(cols, 'facultyName', 'faculty_employee_id', 'faculty');
    const typeCol = resolveCol(cols, 'type', 'pub_type', 'publication_type');
    const statusCol = resolveCol(cols, 'status', 'verification_status', 'audit_status');

    if (dept && deptCol) {
      params.push(`%${dept}%`);
      conditions.push(`${deptCol}::text ILIKE $${params.length}`);
    }
    if (org && orgCol) {
      params.push(`%${org}%`);
      conditions.push(`${orgCol}::text ILIKE $${params.length}`);
    }
    if (faculty && facCol) {
      params.push(`%${faculty}%`);
      conditions.push(`${facCol}::text ILIKE $${params.length}`);
    }
    if (type && typeCol) {
      params.push(`%${type}%`);
      conditions.push(`${typeCol}::text ILIKE $${params.length}`);
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
    const research = result.rows.map((row) => mapResearchRecord(row, cols));

    res.json({
      total: research.length,
      research,
    });
  } catch (err) {
    console.error('[research] GET / error:', err.message);
    res.status(500).json({ error: 'Failed to fetch research records' });
  }
});

// POST /api/research
router.post('/', async (req, res) => {
  try {
    const schema = await inspectResearchSchema();
    if (!schema.fullTableName) {
      return res.status(503).json({ error: 'Research table not found in database' });
    }

    const {
      title,
      authors,
      type,
      doi,
      journalName,
      indexing,
      year,
      organization,
      facultyName,
      description,
    } = req.body;

    const cols = schema.columns;
    const researchId = `RES-${Date.now()}`;
    const insertCols = [];
    const insertVals = [];
    const params = [];

    function addVal(colName, val) {
      if (cols.includes(colName)) {
        insertCols.push(`"${colName}"`);
        params.push(val);
        insertVals.push(`$${params.length}`);
      }
    }

    addVal('researchId', researchId);
    addVal('title', title || 'Untitled');
    addVal('authors', authors || '');
    addVal('type', type || 'Journal Article');
    addVal('doi', doi || '');
    addVal('journalName', journalName || '');
    addVal('indexing', indexing || 'Scopus');
    addVal('year', year || '2025');
    addVal('status', 'Pending Examination');
    addVal('organization', organization || 'KSR College of Engineering');
    addVal('facultyName', facultyName || '');
    addVal('description', description || '');
    addVal('metadataMatch', true);
    addVal('duplicateFlag', false);

    if (insertCols.length === 0) {
      return res.status(500).json({ error: 'Schema mismatch for insert' });
    }

    const insertQuery = `
      INSERT INTO ${schema.fullTableName} (${insertCols.join(', ')})
      VALUES (${insertVals.join(', ')})
      RETURNING *
    `;

    const result = await pool.query(insertQuery, params);
    const created = mapResearchRecord(result.rows[0], cols);
    res.status(201).json(created);
  } catch (err) {
    console.error('[research] POST / error:', err.message);
    res.status(500).json({ error: 'Failed to create research paper record' });
  }
});

// GET /api/research/:id
router.get('/:id', async (req, res) => {
  try {
    const schema = await inspectResearchSchema();

    if (!schema.fullTableName) {
      return res.status(503).json({ error: 'Research table not found in database' });
    }

    const { id } = req.params;
    const cols = schema.columns;
    const idCol = resolveCol(cols, 'researchId', 'id', 'doi');

    if (!idCol) {
      return res.status(500).json({ error: 'Cannot determine research ID column in schema' });
    }

    const result = await pool.query(
      `SELECT * FROM ${schema.fullTableName} WHERE ${idCol}::text = $1 LIMIT 1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: `Research record '${id}' not found` });
    }

    const record = mapResearchRecord(result.rows[0], cols);
    res.json(record);
  } catch (err) {
    console.error('[research] GET /:id error:', err.message);
    res.status(500).json({ error: 'Failed to fetch research record' });
  }
});

module.exports = router;
