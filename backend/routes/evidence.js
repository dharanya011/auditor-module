'use strict';

const express = require('express');
const router = express.Router();
const pool = require('../db');

/**
 * GET /api/evidence
 * Fetch evidence/documents from dean.dean_repository_documents
 * The Flutter EvidenceItem model expects:
 * evidenceId, recordId, recordType, uploadedBy, uploadDate, documentType, version, fileName, fileSize, status
 */
router.get('/', async (_req, res, next) => {
  try {
    // Read-only query to get evidence repository records.
    // Using dean.dean_repository_documents as the primary evidence source.
    const query = `
      SELECT 
        id, 
        display_id, 
        category, 
        uploaded_by, 
        created_at, 
        description, 
        version, 
        file_name, 
        status
      FROM dean.dean_repository_documents
      ORDER BY created_at DESC;
    `;
    
    const result = await pool.query(query);

    // Map the database rows to the structure expected by Flutter EvidenceItem
    const records = result.rows.map(row => ({
      evidenceId: row.id ? row.id.toString() : '',
      recordId: row.display_id ? row.display_id.toString() : 'N/A',
      recordType: row.category ? row.category.toString() : 'Document',
      uploadedBy: row.uploaded_by ? row.uploaded_by.toString() : 'System',
      uploadDate: row.created_at ? new Date(row.created_at).toISOString().split('T')[0] : '',
      documentType: row.description ? row.description.toString() : 'PDF',
      version: row.version ? row.version.toString() : 'v1.0',
      fileName: row.file_name ? row.file_name.toString() : 'Unknown File',
      fileSize: 'Unknown Size', // Not in table, default placeholder
      status: row.status ? row.status.toString() : 'Pending'
    }));

    res.json({ records });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
