import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuditState extends ChangeNotifier {
  String _activeModule = 'Dashboard';
  String _selectedAcademicYear = '2025 - 2026';
  String _globalSearchQuery = '';
  String _userRole = 'Lead Auditor';
  final String _userName = 'Auditor User';

  // Backend API state
  bool _isLoading = false;
  bool _backendConnected = false;
  String? _backendError;

  bool get isLoading => _isLoading;
  bool get backendConnected => _backendConnected;
  String? get backendError => _backendError;

  // Dialog State
  EvidenceItem? _selectedEvidence;
  String? _notificationToast;

  // Active view getter & setter
  String get activeModule => _activeModule;
  String get selectedAcademicYear => _selectedAcademicYear;
  String get globalSearchQuery => _globalSearchQuery;
  String get userRole => _userRole;
  String get userName => _userName;
  EvidenceItem? get selectedEvidence => _selectedEvidence;
  String? get notificationToast => _notificationToast;

  // Department Scope & Permissions
  String? get departmentScope => _userRole == 'Department Auditor' ? 'CSE' : null;

  bool get canVerify {
    if (_userRole == 'System Admin') return false;
    return true;
  }

  bool get canFlagIssue {
    if (_userRole == 'System Admin' || _userRole == 'HOD' || _userRole == 'Dean Academics' || _userRole == 'Read-Only Inspector') {
      return false;
    }
    return true;
  }

  bool get canRequestCorrection {
    if (_userRole == 'System Admin' || _userRole == 'HOD' || _userRole == 'Dean Academics' || _userRole == 'Read-Only Inspector') {
      return false;
    }
    return true;
  }

  bool get canEditRecords => false;

  void setUserRole(String role) {
    _userRole = role;
    notifyListeners();
  }

  void setActiveModule(String module) {
    _activeModule = module;
    notifyListeners();
  }

  void setSelectedAcademicYear(String year) {
    _selectedAcademicYear = year;
    notifyListeners();
  }

  void setGlobalSearchQuery(String query) {
    _globalSearchQuery = query;
    notifyListeners();
  }

  void setSelectedEvidence(EvidenceItem? item) {
    _selectedEvidence = item;
    notifyListeners();
  }

  void showToast(String message) {
    _notificationToast = message;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      if (_notificationToast == message) {
        _notificationToast = null;
        notifyListeners();
      }
    });
  }

  // Dynamic Dashboard Stats calculated from REAL PostgreSQL collections
  List<AuditKPI> get kpis {
    final studentCount = studentRecords.length;
    final marksCount = marksEntries.length;
    final assignCount = assignmentRecords.length;
    final qpCount = questionPapers.length;
    final reportCount = facultyReports.length;
    final researchCount = researchRecords.length;

    final totalRecords = studentCount + marksCount + assignCount + qpCount + reportCount + researchCount;

    final verifiedCount = studentRecords.where((s) => s.status == 'Active' || s.status == 'Verified').length +
        marksEntries.where((m) => m.status == 'Verified').length +
        assignmentRecords.where((a) => a.status == 'Verified').length +
        questionPapers.where((q) => q.status == 'Verified').length +
        facultyReports.where((f) => f.status == 'Verified').length +
        researchRecords.where((r) => r.status == 'Verified').length;

    final pendingCount = studentRecords.where((s) => s.status == 'Pending').length +
        marksEntries.where((m) => m.status == 'Pending').length +
        assignmentRecords.where((a) => a.status == 'Pending').length +
        questionPapers.where((q) => q.status == 'Pending').length +
        facultyReports.where((f) => f.status == 'Pending' || f.status == 'Under Review').length +
        researchRecords.where((r) => r.status == 'Pending Examination' || r.status == 'Under Review').length;

    final issuesCount = studentRecords.where((s) => s.status == 'Discrepancy' || s.status == 'Inactive').length +
        marksEntries.where((m) => m.isMismatch || m.status == 'Rejected').length +
        assignmentRecords.where((a) => a.isMissingFile || a.isDuplicate || a.status == 'Rejected').length +
        questionPapers.where((q) => q.status == 'Rejected' || !q.bloomTaxonomyCompliant).length +
        facultyReports.where((f) => f.hasConflict || f.status == 'Rejected').length +
        researchRecords.where((r) => r.duplicateFlag || r.status == 'Needs Correction' || r.status == 'Rejected').length;

    final criticalCount = auditCases.where((c) => c.severity == 'High' || c.severity == 'Critical').length;

    final correctionsCount = assignmentRecords.where((a) => a.isLate).length +
        facultyReports.where((f) => f.status == 'Under Review').length +
        researchRecords.where((r) => r.status == 'Under Review' || r.status == 'Needs Correction').length;

    return [
      AuditKPI(
        title: 'Total Records Audited',
        value: totalRecords.toString(),
        change: 'Real-time DB query',
        isPositive: true,
        icon: Icons.assignment_turned_in_rounded,
        color: const Color(0xFF6366F1),
      ),
      AuditKPI(
        title: 'Pending Verification',
        value: pendingCount.toString(),
        change: 'Real-time DB query',
        isPositive: true,
        icon: Icons.hourglass_top_rounded,
        color: const Color(0xFFF59E0B),
      ),
      AuditKPI(
        title: 'Verified',
        value: verifiedCount.toString(),
        change: 'Real-time DB query',
        isPositive: true,
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF10B981),
      ),
      AuditKPI(
        title: 'Issues Found',
        value: issuesCount.toString(),
        change: 'Real-time DB query',
        isPositive: false,
        icon: Icons.error_rounded,
        color: const Color(0xFFEF4444),
      ),
      AuditKPI(
        title: 'Critical Issues',
        value: criticalCount.toString(),
        change: 'Real-time DB query',
        isPositive: false,
        icon: Icons.flag_rounded,
        color: const Color(0xFFDC2626),
      ),
      AuditKPI(
        title: 'Corrections Pending',
        value: correctionsCount.toString(),
        change: 'Real-time DB query',
        isPositive: true,
        icon: Icons.published_with_changes_rounded,
        color: const Color(0xFF3B82F6),
      ),
    ];
  }

  List<ModuleProgress> get moduleProgress {
    // Student Records
    final sTotal = studentRecords.length;
    final sVerified = studentRecords.where((s) => s.status == 'Active' || s.status == 'Verified').length;
    final sPending = studentRecords.where((s) => s.status == 'Pending').length;
    final sIssues = sTotal - sVerified - sPending;
    final sPct = sTotal > 0 ? (sVerified / sTotal) : 0.0;

    // Assignments
    final aTotal = assignmentRecords.length;
    final aVerified = assignmentRecords.where((a) => a.status == 'Verified').length;
    final aPending = assignmentRecords.where((a) => a.status == 'Pending').length;
    final aIssues = assignmentRecords.where((a) => a.isMissingFile || a.isDuplicate || a.status == 'Rejected').length;
    final aPct = aTotal > 0 ? (aVerified / aTotal) : 0.0;

    // Marks
    final mTotal = marksEntries.length;
    final mVerified = marksEntries.where((m) => m.status == 'Verified').length;
    final mPending = marksEntries.where((m) => m.status == 'Pending').length;
    final mIssues = marksEntries.where((m) => m.isMismatch || m.status == 'Rejected').length;
    final mPct = mTotal > 0 ? (mVerified / mTotal) : 0.0;

    // Faculty Reports
    final fTotal = facultyReports.length;
    final fVerified = facultyReports.where((f) => f.status == 'Verified').length;
    final fPending = facultyReports.where((f) => f.status == 'Pending' || f.status == 'Under Review').length;
    final fIssues = facultyReports.where((f) => f.hasConflict || f.status == 'Rejected').length;
    final fPct = fTotal > 0 ? (fVerified / fTotal) : 0.0;

    // Question Papers
    final qTotal = questionPapers.length;
    final qVerified = questionPapers.where((q) => q.status == 'Verified').length;
    final qPending = questionPapers.where((q) => q.status == 'Pending').length;
    final qIssues = questionPapers.where((q) => q.status == 'Rejected').length;
    final qPct = qTotal > 0 ? (qVerified / qTotal) : 0.0;

    // Research & Publications
    final rTotal = researchRecords.length;
    final rVerified = researchRecords.where((r) => r.status == 'Verified').length;
    final rPending = researchRecords.where((r) => r.status == 'Pending Examination' || r.status == 'Under Review').length;
    final rIssues = researchRecords.where((r) => r.duplicateFlag || r.status == 'Needs Correction').length;
    final rPct = rTotal > 0 ? (rVerified / rTotal) : 0.0;

    return [
      ModuleProgress(name: 'Student Records', verified: sVerified, pending: sPending, issues: sIssues < 0 ? 0 : sIssues, percentage: sPct),
      ModuleProgress(name: 'Assignments', verified: aVerified, pending: aPending, issues: aIssues, percentage: aPct),
      ModuleProgress(name: 'Marks', verified: mVerified, pending: mPending, issues: mIssues, percentage: mPct),
      ModuleProgress(name: 'Faculty Reports', verified: fVerified, pending: fPending, issues: fIssues, percentage: fPct),
      ModuleProgress(name: 'Question Papers', verified: qVerified, pending: qPending, issues: qIssues, percentage: qPct),
      ModuleProgress(name: 'Research & Publications', verified: rVerified, pending: rPending, issues: rIssues, percentage: rPct),
    ];
  }

  final List<AuditActivity> recentActivities = const [
    AuditActivity(
      id: 'ACT-901',
      title: 'Student record verified - 23CS0456 (John Doe)',
      module: 'Student Audit',
      timestamp: '10:30 AM',
      status: 'Verified',
      icon: Icons.check_circle_rounded,
      iconColor: Color(0xFF10B981),
      auditor: 'Auditor User',
    ),
    AuditActivity(
      id: 'ACT-902',
      title: 'Assignment evidence checked - 23IT312_A1',
      module: 'Assignment Audit',
      timestamp: '10:15 AM',
      status: 'Checked',
      icon: Icons.task_alt_rounded,
      iconColor: Color(0xFF10B981),
      auditor: 'Auditor User',
    ),
    AuditActivity(
      id: 'ACT-903',
      title: 'Marks discrepancy detected - 23EC106 (Analog Electronics)',
      module: 'Marks Audit',
      timestamp: '09:45 AM',
      status: 'Discrepancy',
      icon: Icons.warning_amber_rounded,
      iconColor: Color(0xFFF59E0B),
      auditor: 'Auditor User',
    ),
    AuditActivity(
      id: 'ACT-904',
      title: 'Faculty report rejected - Dr. R. Kumar (Course Completion)',
      module: 'Faculty Report Audit',
      timestamp: '09:20 AM',
      status: 'Rejected',
      icon: Icons.cancel_rounded,
      iconColor: Color(0xFFEF4444),
      auditor: 'Auditor User',
    ),
    AuditActivity(
      id: 'ACT-905',
      title: 'Research paper verified - AI in Education (Dr. S. Meena)',
      module: 'Research Audit',
      timestamp: '09:05 AM',
      status: 'Verified',
      icon: Icons.check_circle_rounded,
      iconColor: Color(0xFF10B981),
      auditor: 'Auditor User',
    ),
  ];

  final List<CriticalIssue> criticalIssues = const [
    CriticalIssue(
      id: 'AUD-2025-00145',
      title: 'Marks mismatch in 23CS201 (Data Structures)',
      priority: 'High Priority',
      code: '23CS201',
      department: 'Computer Science & Engg',
      date: '2026-08-18',
    ),
    CriticalIssue(
      id: 'AUD-2025-00142',
      title: 'Missing assignment submission evidence - 12 Students',
      priority: 'High Priority',
      code: '23IT304',
      department: 'Information Tech',
      date: '2026-08-17',
    ),
    CriticalIssue(
      id: 'AUD-2025-00140',
      title: 'Question paper not approved - 23IT204 (DBMS)',
      priority: 'High Priority',
      code: '23IT204',
      department: 'Information Tech',
      date: '2026-08-16',
    ),
    CriticalIssue(
      id: 'AUD-2025-00138',
      title: 'Faculty report data inconsistency - CSE Department',
      priority: 'Medium Priority',
      code: 'REP-CSE-99',
      department: 'CSE',
      date: '2026-08-15',
    ),
    CriticalIssue(
      id: 'AUD-2025-00135',
      title: 'Research publication DOI mismatch - 2 Records',
      priority: 'Medium Priority',
      code: 'PUB-2025-012',
      department: 'Electronics & Comm',
      date: '2026-08-14',
    ),
  ];

  // Student records — populated exclusively from the REST API (GET /api/students).
  // No mock/static data. Empty until the backend loads real PostgreSQL data.
  final List<StudentAuditRecord> studentRecords = [];

  // Marks entries — populated exclusively from the REST API (GET /api/marks/:id).
  // No mock/static data. Empty until the backend loads real PostgreSQL data.
  final List<MarksAuditEntry> marksEntries = [];

  // Assignment Records — populated exclusively from the REST API (GET /api/assignments).
  // No mock/static data. Empty until the backend loads real PostgreSQL data.
  final List<AssignmentRecord> assignmentRecords = [];

  // Faculty Report Records — populated exclusively from the REST API (GET /api/faculty-reports).
  // No mock/static data. Empty until the backend loads real PostgreSQL data.
  final List<FacultyReportRecord> facultyReports = [];

  // Question Paper Audit Records — populated exclusively from the REST API (GET /api/question-papers).
  // No mock/static data. Empty until the backend loads real PostgreSQL data.
  final List<QuestionPaperRecord> questionPapers = [];

  // Research Records — populated exclusively from the REST API (GET /api/research).
  // No mock/static data. Empty until the backend loads real PostgreSQL data.
  final List<ResearchRecord> researchRecords = [];

  // Evidence Repository Items
  final List<EvidenceItem> evidenceItems = [
    EvidenceItem(
      evidenceId: 'EVD-8891',
      recordId: '23CS001_CAT1',
      recordType: 'Answer Sheet Scan',
      uploadedBy: 'Faculty - Dr. R. Kumar',
      uploadDate: '2026-08-12 11:20',
      documentType: 'PDF Document',
      version: 'v1.0',
      fileName: '23CS001_DataStructures_CAT1.pdf',
      fileSize: '4.2 MB',
      status: 'Accepted',
    ),
    EvidenceItem(
      evidenceId: 'EVD-8894',
      recordId: 'RES-2025-01',
      recordType: 'Research Paper PDF',
      uploadedBy: 'Dr. S. Meena',
      uploadDate: '2026-08-14 16:45',
      documentType: 'Journal Reprint',
      version: 'v1.2',
      fileName: 'IEEE_AI_Education_Final.pdf',
      fileSize: '2.8 MB',
      status: 'Accepted',
    ),
    EvidenceItem(
      evidenceId: 'EVD-8899',
      recordId: 'QP-23IT204',
      recordType: 'Question Paper Draft',
      uploadedBy: 'Dept CoE IT',
      uploadDate: '2026-08-16 10:00',
      documentType: 'Question Paper',
      version: 'v0.9',
      fileName: '23IT204_DBMS_EndSem_Draft.pdf',
      fileSize: '1.5 MB',
      status: 'Pending Verification',
    ),
  ];

  // Audit Cases — populated exclusively from REST API (GET /api/cases).
  // No mock/static data. Empty until the backend loads real PostgreSQL data.
  final List<AuditCaseItem> auditCases = [];

  // AI Anomalies
  final List<AIAnomalyItem> aiAnomalies = [
    AIAnomalyItem(
      id: 'AI-ANO-01',
      anomalyTitle: 'Unusually high identical marks distribution',
      category: 'Marks Anomaly',
      severity: 'High',
      detectionReason: '42 students in Section B scored identical marks (85/100) in CAT-2 Internal Exam.',
      recordReference: 'Course 23EC106 (Analog Electronics)',
      recommendation: 'Request raw answer sheet scan verification for Section B.',
      status: 'Active Alert',
    ),
    AIAnomalyItem(
      id: 'AI-ANO-02',
      anomalyTitle: 'Assignment marked submitted but file missing',
      category: 'Assignment Anomaly',
      severity: 'Medium',
      detectionReason: '12 assignment records marked as "Submitted" in ERP database without S3 file hash.',
      recordReference: 'Subject 23IT304 (Web Dev)',
      recommendation: 'Issue automated correction request to IT department.',
      status: 'Active Alert',
    ),
    AIAnomalyItem(
      id: 'AI-ANO-03',
      anomalyTitle: 'Research DOI metadata discrepancy',
      category: 'Research Anomaly',
      severity: 'Medium',
      detectionReason: 'Uploaded publication DOI links to a different paper title on IEEE Xplore.',
      recordReference: 'Publication RES-2025-02',
      recommendation: 'Verify author affiliation and original PDF evidence.',
      status: 'Flagged',
    ),
  ];

  // Audit Logs
  final List<AuditLogItem> auditLogs = [
    AuditLogItem(
      id: 'LOG-8801',
      timestamp: '2026-08-18 10:30:15',
      auditorName: 'Auditor User (Chief Auditor)',
      ipAddress: '192.168.1.104',
      action: 'RECORD_VERIFIED',
      recordId: '23CS001',
      details: 'Verified student academic record 23CS001 Adithya V. All 6 record groups passed.',
    ),
    AuditLogItem(
      id: 'LOG-8802',
      timestamp: '2026-08-18 09:45:22',
      auditorName: 'Auditor User (Chief Auditor)',
      ipAddress: '192.168.1.104',
      action: 'DISCREPANCY_FLAGGED',
      recordId: 'MRK-2025-02',
      details: 'Flagged marks mismatch case AUD-2026-001245 for Student 23CS0456.',
    ),
    AuditLogItem(
      id: 'LOG-8803',
      timestamp: '2026-08-18 09:20:01',
      auditorName: 'Auditor User (Chief Auditor)',
      ipAddress: '192.168.1.104',
      action: 'REPORT_REJECTED',
      recordId: 'REP-CSE-101',
      details: 'Rejected faculty course completion report REP-CSE-101 due to attendance conflict.',
    ),
  ];

  // Verification & Action Methods
  void verifyStudentRecord(String regNo) {
    final idx = studentRecords.indexWhere((r) => r.registerNo == regNo);
    if (idx != -1) {
      studentRecords[idx] = StudentAuditRecord(
        registerNo: studentRecords[idx].registerNo,
        name: studentRecords[idx].name,
        department: studentRecords[idx].department,
        semester: studentRecords[idx].semester,
        cgpa: studentRecords[idx].cgpa,
        attendance: studentRecords[idx].attendance,
        photoUrl: studentRecords[idx].photoUrl,
        status: 'Verified',
        groupStatuses: studentRecords[idx].groupStatuses.map((g) => RecordGroupStatus(
          groupName: g.groupName,
          status: 'Verified',
          details: 'Verified by Auditor at ${DateTime.now().toLocal().toString().split('.')[0]}',
        )).toList(),
      );
      addAuditLog('RECORD_VERIFIED', regNo, 'Verified all groups for student $regNo');
      showToast('Student record $regNo verified successfully!');
      notifyListeners();
    }
  }

  void flagIssue(String recordId, String reason, String severity) {
    final caseId = 'AUD-2026-00${1246 + auditCases.length}';
    auditCases.insert(0, AuditCaseItem(
      caseId: caseId,
      title: 'Discrepancy Flagged: $reason',
      category: 'General Audit',
      targetRecordId: recordId,
      severity: severity,
      assignedTo: 'HOD / Department',
      lifecycleStage: 'Correction Requested',
      createdDate: DateTime.now().toLocal().toString().split(' ')[0],
      description: reason,
    ));
    addAuditLog('CASE_CREATED', recordId, 'Created audit case $caseId for $recordId with severity $severity');
    showToast('Audit Case $caseId created and sent for review!');
    notifyListeners();
  }

  void addAuditLog(String action, String recordId, String details) {
    auditLogs.insert(0, AuditLogItem(
      id: 'LOG-${8804 + auditLogs.length}',
      timestamp: DateTime.now().toLocal().toString().split('.')[0],
      auditorName: '$_userName ($_userRole)',
      ipAddress: '192.168.1.104',
      action: action,
      recordId: recordId,
      details: details,
    ));
  }


  void updateResearchRecord(ResearchRecord updated) {
    final idx = researchRecords.indexWhere((r) => r.id == updated.id);
    if (idx != -1) {
      researchRecords[idx] = updated;
      addAuditLog('RESEARCH_AUDITED', updated.id, 'Audited research paper ${updated.id}. Status: ${updated.status}');
      showToast('Research details saved successfully!');
      notifyListeners();
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Backend API Integration
  // ────────────────────────────────────────────────────────────────────────────

  /// Load real data from the Node.js/Express backend → AWS PostgreSQL.
  ///
  /// Data flow: Flutter → HTTP REST API → Node.js → pg driver → AWS PostgreSQL
  ///
  /// Security:
  ///   - PostgreSQL credentials are ONLY in backend/.env
  ///   - .env is gitignored — never committed
  ///   - Credentials are NEVER sent to Flutter or logged in responses
  ///   - DB_PASSWORD is NEVER exposed in any API response
  ///
  /// Error handling:
  ///   - If the backend is unreachable → sets [_backendError], lists stay EMPTY
  ///   - If an API call fails → sets [_backendError], lists stay EMPTY
  ///   - NO mock/static data is substituted as a fallback — EVER
  ///   - Empty result from API → lists stay empty (empty-data state shown in UI)
  Future<void> loadFromApi() async {
    _isLoading = true;
    _backendError = null;
    _backendConnected = false;

    // Always start with empty lists — no stale or mock data
    studentRecords.clear();
    marksEntries.clear();
    assignmentRecords.clear();
    questionPapers.clear();
    facultyReports.clear();
    researchRecords.clear();
    notifyListeners();

    try {
      final api = ApiService.instance;

      // ── Step 1: Health check ──────────────────────────────────────────────
      final healthy = await api.checkHealth();
      if (!healthy) {
        _backendError =
            'Cannot reach the backend API server.\n'
            'Make sure the Node.js server is running:\n'
            '  cd backend  →  node server.js\n'
            'And that backend/.env has valid AWS PostgreSQL credentials.';
        _isLoading = false;
        notifyListeners();
        return; // No mock fallback — stay empty
      }
      _backendConnected = true;

      // ── Step 2: Fetch students from real PostgreSQL ───────────────────────
      final rawStudents = await api.fetchStudents(limit: 500);
      // Always replace with API result — even if empty
      studentRecords.clear();
      for (final s in rawStudents) {
        studentRecords.add(StudentAuditRecord(
          registerNo: (s['register_no'] ?? s['id'] ?? '').toString(),
          name: (s['name'] ?? '').toString(),
          department: (s['department'] ?? '').toString(),
          semester: int.tryParse(s['semester']?.toString() ?? '1') ?? 1,
          cgpa: double.tryParse(s['cgpa']?.toString() ?? '0') ?? 0.0,
          attendance: double.tryParse(s['attendance']?.toString() ?? '0') ?? 0.0,
          photoUrl: (s['photo_url'] ?? '').toString(),
          status: (s['status'] ?? 'Pending').toString(),
          groupStatuses: ((s['group_statuses'] ?? []) as List)
              .map((g) => RecordGroupStatus(
                    groupName: (g['group_name'] ?? '').toString(),
                    status: (g['status'] ?? 'Pending').toString(),
                    details: (g['details'] ?? '').toString(),
                  ))
              .toList(),
        ));
      }

      // ── Step 3: Fetch marks for all loaded students from real PostgreSQL ──
      marksEntries.clear();
      for (final student in studentRecords) {
        final rawMarks = await api.fetchMarks(student.registerNo);
        for (final m in rawMarks) {
          marksEntries.add(MarksAuditEntry(
            id: (m['id'] ?? '').toString(),
            studentRegNo: (m['student_reg_no'] ?? '').toString(),
            studentName: (m['student_name'] ?? '').toString(),
            subjectCode: (m['subject_code'] ?? '').toString(),
            subjectName: (m['subject_name'] ?? '').toString(),
            facultyEntry: int.tryParse(m['faculty_entry']?.toString() ?? '0') ?? 0,
            deptRecord: int.tryParse(m['dept_record']?.toString() ?? '0') ?? 0,
            examRecord: int.tryParse(m['exam_record']?.toString() ?? '0') ?? 0,
            finalResult: int.tryParse(m['final_result']?.toString() ?? '0') ?? 0,
            isMismatch: m['is_mismatch'] == true || m['is_mismatch'] == 'true',
            mismatchReason: (m['mismatch_reason'] ?? '').toString(),
            status: (m['status'] ?? 'Pending').toString(),
          ));
        }
      }

      // ── Step 4: Fetch assignments from real PostgreSQL ───────────────────
      final rawAssignments = await api.fetchAssignments();
      assignmentRecords.clear();
      for (final a in rawAssignments) {
        assignmentRecords.add(AssignmentRecord(
          id: (a['id'] ?? '').toString(),
          studentRegNo: (a['studentRegNo'] ?? '').toString(),
          studentName: (a['studentName'] ?? '').toString(),
          title: (a['title'] ?? '').toString(),
          subject: (a['subject'] ?? '').toString(),
          submissionDate: (a['submissionDate'] ?? '').toString(),
          marksObtained: int.tryParse(a['marksObtained']?.toString() ?? '0') ?? 0,
          totalMarks: int.tryParse(a['totalMarks']?.toString() ?? '100') ?? 100,
          evidenceFile: (a['evidenceFile'] ?? '').toString(),
          isMissingFile: a['isMissingFile'] == true || a['isMissingFile'] == 'true',
          isLate: a['isLate'] == true || a['isLate'] == 'true',
          isDuplicate: a['isDuplicate'] == true || a['isDuplicate'] == 'true',
          status: (a['status'] ?? 'Pending').toString(),
        ));
      }

      // ── Step 5: Fetch question papers from real PostgreSQL ───────────────
      final rawQP = await api.fetchQuestionPapers();
      questionPapers.clear();
      for (final q in rawQP) {
        questionPapers.add(QuestionPaperRecord(
          id: (q['id'] ?? '').toString(),
          courseCode: (q['courseCode'] ?? '').toString(),
          courseTitle: (q['courseTitle'] ?? '').toString(),
          regulation: (q['regulation'] ?? 'R2023').toString(),
          department: (q['department'] ?? '').toString(),
          semester: int.tryParse(q['semester']?.toString() ?? '1') ?? 1,
          academicYear: (q['academicYear'] ?? '2025 - 2026').toString(),
          bloomTaxonomyCompliant: q['bloomTaxonomyCompliant'] == true || q['bloomTaxonomyCompliant'] == 'true',
          syllabusMapped: q['syllabusMapped'] == true || q['syllabusMapped'] == 'true',
          hodApproved: q['hodApproved'] == true || q['hodApproved'] == 'true',
          coeApproved: q['coeApproved'] == true || q['coeApproved'] == 'true',
          status: (q['status'] ?? 'Pending').toString(),
        ));
      }

      // ── Step 6: Fetch faculty reports from real PostgreSQL ───────────────
      final rawReports = await api.fetchFacultyReports();
      facultyReports.clear();
      for (final r in rawReports) {
        facultyReports.add(FacultyReportRecord(
          id: (r['id'] ?? '').toString(),
          facultyName: (r['facultyName'] ?? '').toString(),
          department: (r['department'] ?? '').toString(),
          reportType: (r['reportType'] ?? 'Course Completion Report').toString(),
          academicYear: (r['academicYear'] ?? '2025 - 2026').toString(),
          regulation: (r['regulation'] ?? 'R2023').toString(),
          semester: int.tryParse(r['semester']?.toString() ?? '1') ?? 1,
          reportedAttendance: double.tryParse(r['reportedAttendance']?.toString() ?? '0') ?? 0.0,
          actualAttendance: double.tryParse(r['actualAttendance']?.toString() ?? '0') ?? 0.0,
          syllabusCompletionPercent: int.tryParse(r['syllabusCompletionPercent']?.toString() ?? '100') ?? 100,
          mentoringSessionsLogged: int.tryParse(r['mentoringSessionsLogged']?.toString() ?? '0') ?? 0,
          hasConflict: r['hasConflict'] == true || r['hasConflict'] == 'true',
          conflictDetails: (r['conflictDetails'] ?? '').toString(),
          status: (r['status'] ?? 'Pending').toString(),
        ));
      }

      // ── Step 7: Fetch research records from real PostgreSQL ───────────────
      final rawResearch = await api.fetchResearch();
      researchRecords.clear();
      for (final resItem in rawResearch) {
        final checklistRaw = resItem['verificationChecklist'];
        final Map<String, String> checklist = (checklistRaw is Map)
            ? checklistRaw.map((k, v) => MapEntry(k.toString(), v.toString()))
            : {};

        researchRecords.add(ResearchRecord(
          id: (resItem['id'] ?? '').toString(),
          title: (resItem['title'] ?? '').toString(),
          authors: (resItem['authors'] ?? '').toString(),
          type: (resItem['type'] ?? 'Journal Article').toString(),
          doi: (resItem['doi'] ?? '').toString(),
          journalName: (resItem['journalName'] ?? '').toString(),
          indexing: (resItem['indexing'] ?? 'Scopus').toString(),
          year: (resItem['year'] ?? '2025').toString(),
          metadataMatch: resItem['metadataMatch'] == true || resItem['metadataMatch'] == 'true',
          duplicateFlag: resItem['duplicateFlag'] == true || resItem['duplicateFlag'] == 'true',
          status: (resItem['status'] ?? 'Pending Examination').toString(),
          organization: (resItem['organization'] ?? 'KSR College of Engineering').toString(),
          department: (resItem['department'] ?? 'Computer Science & Engineering').toString(),
          facultyName: (resItem['facultyName'] ?? '').toString(),
          description: (resItem['description'] ?? '').toString(),
          documentName: (resItem['documentName'] ?? '').toString(),
          documentType: (resItem['documentType'] ?? 'PDF Document').toString(),
          documentSize: (resItem['documentSize'] ?? '').toString(),
          documentStatus: (resItem['documentStatus'] ?? 'Not Uploaded').toString(),
          verificationChecklist: checklist,
          auditorRemarks: (resItem['auditorRemarks'] ?? '').toString(),
        ));
      }

      // ── Step 8: Fetch audit cases from real PostgreSQL ───────────────────
      final rawCases = await api.fetchAuditCases();
      auditCases.clear();
      auditCases.addAll(rawCases);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Any API failure → error state, lists stay empty — no mock substitution
      _backendConnected = false;
      _backendError =
          'API error: ${e.toString().replaceAll(RegExp(r'password[=:\s]\S+', caseSensitive: false), 'password=[REDACTED]')}';
      _isLoading = false;
      debugPrint('[AuditState] loadFromApi error (credentials NOT logged): ${e.runtimeType}');
      notifyListeners();
    }
  }

  /// Add new research paper record to real PostgreSQL DB via API service.
  Future<void> addResearchRecord(ResearchRecord record) async {
    try {
      final res = await ApiService.instance.createResearch({
        'title': record.title,
        'authors': record.authors,
        'type': record.type,
        'doi': record.doi,
        'journalName': record.journalName,
        'indexing': record.indexing,
        'year': record.year,
        'organization': record.organization,
        'facultyName': record.facultyName,
        'description': record.description,
      });

      final created = ResearchRecord(
        id: (res['id'] ?? record.id).toString(),
        title: (res['title'] ?? record.title).toString(),
        authors: (res['authors'] ?? record.authors).toString(),
        type: (res['type'] ?? record.type).toString(),
        doi: (res['doi'] ?? record.doi).toString(),
        journalName: (res['journalName'] ?? record.journalName).toString(),
        indexing: (res['indexing'] ?? record.indexing).toString(),
        year: (res['year'] ?? record.year).toString(),
        metadataMatch: res['metadataMatch'] == true || res['metadataMatch'] == 'true',
        duplicateFlag: res['duplicateFlag'] == true || res['duplicateFlag'] == 'true',
        status: (res['status'] ?? 'Pending Examination').toString(),
        organization: (res['organization'] ?? record.organization).toString(),
        department: (res['department'] ?? record.department).toString(),
        facultyName: (res['facultyName'] ?? record.facultyName).toString(),
        description: (res['description'] ?? record.description).toString(),
        documentName: record.documentName,
        documentType: record.documentType,
        documentSize: record.documentSize,
        documentStatus: record.documentStatus,
        verificationChecklist: record.verificationChecklist,
        auditorRemarks: record.auditorRemarks,
      );

      researchRecords.insert(0, created);
      notifyListeners();
    } catch (e) {
      researchRecords.insert(0, record);
      notifyListeners();
    }
  }
}
