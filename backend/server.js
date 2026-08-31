'use strict';

/**
 * server.js — KSRCE Auditor Module Backend API
 *
 * Security rules enforced:
 *  - AWS PostgreSQL credentials are loaded ONLY from .env via dotenv
 *  - DB_PASSWORD is never logged or returned in any response
 *  - Flutter communicates with PostgreSQL ONLY through this REST API
 */

// Load .env BEFORE any other require that touches process.env
require('dotenv').config();

const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 5000;

// ──────────────────────────────────────────────
// Middleware
// ──────────────────────────────────────────────
app.use(cors());
app.use(express.json());

// Request logger (never logs DB_PASSWORD)
app.use((req, _res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

// ──────────────────────────────────────────────
// Routes
// ──────────────────────────────────────────────
const healthRouter = require('./routes/health');
const studentsRouter = require('./routes/students');
const marksRouter = require('./routes/marks');
const attendanceRouter = require('./routes/attendance');
const assignmentsRouter = require('./routes/assignments');
const questionPapersRouter = require('./routes/question_papers');
const facultyReportsRouter = require('./routes/faculty_reports');
const researchRouter = require('./routes/research');
const searchRouter = require('./routes/search');
const workQueueRouter = require('./routes/work_queue');
const casesRouter = require('./routes/cases');

app.use('/api/health', healthRouter);
app.use('/api/students', studentsRouter);
app.use('/api/marks', marksRouter);
app.use('/api/attendance', attendanceRouter);
app.use('/api/assignments', assignmentsRouter);
app.use('/api/question-papers', questionPapersRouter);
app.use('/api/faculty-reports', facultyReportsRouter);
app.use('/api/research', researchRouter);
app.use('/api/search', searchRouter);
app.use('/api/work-queue', workQueueRouter);
app.use('/api/cases', casesRouter);

// ──────────────────────────────────────────────
// 404 handler
// ──────────────────────────────────────────────
app.use((_req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// ──────────────────────────────────────────────
// Global error handler — never exposes DB_PASSWORD
// ──────────────────────────────────────────────
app.use((err, _req, res, _next) => {
  // Strip any credential info from the error message before responding
  const safeMessage = (err.message || 'Internal server error')
    .replace(/password[=:\s]\S+/gi, 'password=[REDACTED]')
    .replace(/DB_PASSWORD[=:\s]\S+/gi, 'DB_PASSWORD=[REDACTED]');
  console.error('[server] Error:', safeMessage);
  res.status(500).json({ error: safeMessage });
});

// ──────────────────────────────────────────────
// Start
// ──────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`[server] KSRCE Auditor API running on http://localhost:${PORT}`);
  console.log(`[server] Connected to DB host: ${process.env.DB_HOST}`);
  // DB_PASSWORD is intentionally NOT logged here
});
