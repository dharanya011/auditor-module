'use strict';

/**
 * routes/search.js
 *
 * GET /api/search?q=<query>&type=<recordType>
 * Grouped multi-table REST search API over real PostgreSQL database.
 */

const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/', async (req, res) => {
  try {
    const { q, type = 'All Records', limit = 50 } = req.query;
    const queryStr = (q || '').trim();

    if (!queryStr) {
      return res.json({
        total: 0,
        results: [],
      });
    }

    const searchTerm = `%${queryStr}%`;
    const results = [];

    // 1. Search Students if type is 'All Records' or 'Students'
    if (type === 'All Records' || type === 'Students') {
      try {
        const studentRes = await pool.query(
          `SELECT student_id, register_no, roll_no, full_name, department, semester, cgpa, attendance_percentage, status
           FROM "student"."students"
           WHERE full_name ILIKE $1
              OR register_no::text ILIKE $1
              OR student_id::text ILIKE $1
              OR roll_no::text ILIKE $1
              OR department ILIKE $1
           LIMIT 20`,
          [searchTerm]
        );

        studentRes.rows.forEach((r) => {
          results.push({
            id: (r.register_no || r.student_id || r.roll_no || '').toString(),
            title: `${r.full_name || 'Student'} (Reg No: ${r.register_no || r.student_id || 'N/A'})`,
            subtitle: `Student Profile • ${r.department || 'Dept'} • Sem ${r.semester || 'N/A'} • CGPA: ${r.cgpa || 'N/A'} • Attendance: ${r.attendance_percentage ? r.attendance_percentage + '%' : 'N/A'}`,
            type: 'Student Audit',
            status: r.status || 'Verified',
            moduleKey: 'Student Audit',
            raw: r,
          });
        });
      } catch (err) {
        console.warn('[search] Students search error:', err.message);
      }
    }

    // 2. Search Assignments if type is 'All Records' or 'Assignments'
    if (type === 'All Records' || type === 'Assignments') {
      try {
        const checkAsgn = await pool.query(
          `SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'assignment_records'`
        );
        if (checkAsgn.rows.length > 0) {
          const asgnRes = await pool.query(
            `SELECT * FROM "public"."assignment_records"
             WHERE "title" ILIKE $1
                OR "studentName" ILIKE $1
                OR "registerNo"::text ILIKE $1
                OR "subject" ILIKE $1
             LIMIT 20`,
            [searchTerm]
          );
          asgnRes.rows.forEach((r) => {
            results.push({
              id: (r.assignmentId || r.id || '').toString(),
              title: `Assignment — ${r.title || 'Assignment'} (Student: ${r.studentName || r.registerNo || 'N/A'})`,
              subtitle: `Subject: ${r.subject || 'N/A'} • Submitted: ${r.submissionDate || 'N/A'} • Marks: ${r.marksObtained}/${r.totalMarks}`,
              type: 'Assignment Audit',
              status: r.status || 'Pending',
              moduleKey: 'Assignment Audit',
              raw: r,
            });
          });
        }
      } catch (err) {
        console.warn('[search] Assignments search error:', err.message);
      }
    }

    // 3. Search Marks if type is 'All Records' or 'Marks'
    if (type === 'All Records' || type === 'Marks') {
      try {
        const checkMarks = await pool.query(
          `SELECT column_name FROM information_schema.columns WHERE table_schema = 'faculty' AND table_name = 'marks'`
        );
        if (checkMarks.rows.length > 0) {
          const cols = checkMarks.rows.map((c) => c.column_name);
          const studentIdCol = cols.includes('student_id') ? 'student_id' : (cols.includes('register_no') ? 'register_no' : null);
          const subjectCodeCol = cols.includes('subject_code') ? 'subject_code' : null;
          const subjectNameCol = cols.includes('subject_name') ? 'subject_name' : null;

          const conds = [];
          if (studentIdCol) conds.push(`${studentIdCol}::text ILIKE $1`);
          if (subjectCodeCol) conds.push(`${subjectCodeCol}::text ILIKE $1`);
          if (subjectNameCol) conds.push(`${subjectNameCol}::text ILIKE $1`);

          if (conds.length > 0) {
            const marksRes = await pool.query(
              `SELECT * FROM "faculty"."marks" WHERE ${conds.join(' OR ')} LIMIT 20`,
              [searchTerm]
            );
            marksRes.rows.forEach((r) => {
              const sid = r[studentIdCol] || '';
              const scode = r[subjectCodeCol] || '';
              const sname = r[subjectNameCol] || '';
              results.push({
                id: `MRK-${sid}-${scode}`,
                title: `Marks Record — ${scode} ${sname} (Student: ${sid})`,
                subtitle: `Subject: ${sname} (${scode}) • Marks: ${r.marks || r.internal_marks || 'N/A'}`,
                type: 'Marks Audit',
                status: 'Verified',
                moduleKey: 'Marks Audit',
                raw: r,
              });
            });
          }
        }
      } catch (err) {
        console.warn('[search] Marks search error:', err.message);
      }
    }

    // 4. Search Faculty Reports if type is 'All Records' or 'Faculty Reports'
    if (type === 'All Records' || type === 'Faculty Reports') {
      try {
        const checkReports = await pool.query(
          `SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'faculty_report_records'`
        );
        if (checkReports.rows.length > 0) {
          const reportRes = await pool.query(
            `SELECT * FROM "public"."faculty_report_records"
             WHERE "facultyName" ILIKE $1
                OR "reportId" ILIKE $1
                OR "reportType" ILIKE $1
             LIMIT 20`,
            [searchTerm]
          );
          reportRes.rows.forEach((r) => {
            results.push({
              id: (r.reportId || r.id || '').toString(),
              title: `Faculty Report — ${r.reportType || 'Report'} (${r.facultyName || 'Faculty'})`,
              subtitle: `Dept: ${r.departmentId || 'N/A'} • AY: ${r.academicYear || 'N/A'} • Status: ${r.status || 'Pending'}`,
              type: 'Faculty Report Audit',
              status: r.status || 'Pending',
              moduleKey: 'Faculty Report Audit',
              raw: r,
            });
          });
        }
      } catch (err) {
        console.warn('[search] Faculty Reports search error:', err.message);
      }
    }

    // 5. Search Question Papers if type is 'All Records' or 'Question Papers'
    if (type === 'All Records' || type === 'Question Papers') {
      try {
        const checkQP = await pool.query(
          `SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'question_paper_records'`
        );
        if (checkQP.rows.length > 0) {
          const qpRes = await pool.query(
            `SELECT * FROM "public"."question_paper_records"
             WHERE "paperId" ILIKE $1
                OR "courseCode" ILIKE $1
                OR "courseTitle" ILIKE $1
             LIMIT 20`,
            [searchTerm]
          );
          qpRes.rows.forEach((r) => {
            results.push({
              id: (r.paperId || r.id || '').toString(),
              title: `Question Paper — ${r.courseCode || ''} ${r.courseTitle || 'Question Paper'}`,
              subtitle: `Regulation: ${r.regulation || 'R2023'} • Sem ${r.semester || 'N/A'} • Status: ${r.status || 'Pending'}`,
              type: 'Question Paper Audit',
              status: r.status || 'Pending Verification',
              moduleKey: 'Question Paper Audit',
              raw: r,
            });
          });
        }
      } catch (err) {
        console.warn('[search] Question Papers search error:', err.message);
      }
    }

    // 6. Search Research if type is 'All Records' or 'Research'
    if (type === 'All Records' || type === 'Research') {
      try {
        const checkRes = await pool.query(
          `SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'research_records'`
        );
        if (checkRes.rows.length > 0) {
          const resRows = await pool.query(
            `SELECT * FROM "public"."research_records"
             WHERE "title" ILIKE $1
                OR "authors" ILIKE $1
                OR "facultyName" ILIKE $1
                OR "doi" ILIKE $1
                OR "journalName" ILIKE $1
             LIMIT 20`,
            [searchTerm]
          );
          resRows.rows.forEach((r) => {
            results.push({
              id: (r.researchId || r.id || '').toString(),
              title: `Research Paper — ${r.title || 'Untitled'} (${r.facultyName || r.authors || 'Faculty'})`,
              subtitle: `DOI: ${r.doi || 'N/A'} • Journal: ${r.journalName || 'N/A'} • Indexing: ${r.indexing || 'Scopus'}`,
              type: 'Research Audit',
              status: r.status || 'Pending Examination',
              moduleKey: 'Research Audit',
              raw: r,
            });
          });
        }

        const checkPub = await pool.query(
          `SELECT column_name FROM information_schema.columns WHERE table_schema = 'faculty' AND table_name = 'publications'`
        );
        if (checkPub.rows.length > 0) {
          const pubRows = await pool.query(
            `SELECT * FROM "faculty"."publications"
             WHERE "title" ILIKE $1
                OR "authors" ILIKE $1
                OR "journal_or_conf_name" ILIKE $1
                OR "doi" ILIKE $1
             LIMIT 20`,
            [searchTerm]
          );
          pubRows.rows.forEach((r) => {
            results.push({
              id: (r.id || r.doi || '').toString(),
              title: `Publication — ${r.title || 'Untitled'}`,
              subtitle: `Journal: ${r.journal_or_conf_name || 'N/A'} • DOI: ${r.doi || 'N/A'} • Indexing: ${r.indexing || 'Scopus'}`,
              type: 'Research Audit',
              status: r.verification_status || 'Verified',
              moduleKey: 'Research Audit',
              raw: r,
            });
          });
        }
      } catch (err) {
        console.warn('[search] Research search error:', err.message);
      }
    }

    res.json({
      total: results.length,
      results,
    });
  } catch (err) {
    console.error('[search] GET / error:', err.message);
    res.status(500).json({ error: 'Failed to perform global search' });
  }
});

module.exports = router;
