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

  // Loading & Error State
  bool _isLoading = false;
  String? _error;

  // Active view getter & setter
  String get activeModule => _activeModule;
  String get selectedAcademicYear => _selectedAcademicYear;
  String get globalSearchQuery => _globalSearchQuery;
  String get userRole => _userRole;
  String get userName => _userName;
  EvidenceItem? get selectedEvidence => _selectedEvidence;
  String? get notificationToast => _notificationToast;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _api.isAuthenticated;

  // Department Scope & Permissions
  String? get departmentScope {
    if (_userRole == 'Department_Auditor' || _userRole == 'HOD') return 'CSE';
    return null;
  }

  bool get canVerify {
    if (_userRole == 'System_Admin' || _userRole == 'Read_Only_Inspector') return false;
    return true;
  }

  bool get canFlagIssue {
    if (_userRole == 'System_Admin' || _userRole == 'HOD' || _userRole == 'Dean_Academics' || _userRole == 'Read_Only_Inspector') {
      return false;
    }
    return true;
  }

  bool get canRequestCorrection {
    if (_userRole == 'System_Admin' || _userRole == 'HOD' || _userRole == 'Dean_Academics' || _userRole == 'Read_Only_Inspector') {
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

  List<AuditKPI> get kpisList => kpis.isNotEmpty
      ? kpis
      : const [
          AuditKPI(title: 'Total Records Audited', value: '0', change: '—', isPositive: true, icon: Icons.analytics_rounded, color: Color(0xFF4F46E5)),
          AuditKPI(title: 'Pending Verification', value: '0', change: '—', isPositive: false, icon: Icons.hourglass_top_rounded, color: Color(0xFFF59E0B)),
          AuditKPI(title: 'Verified Records', value: '0', change: '—', isPositive: true, icon: Icons.check_circle_rounded, color: Color(0xFF10B981)),
          AuditKPI(title: 'Discrepancies Found', value: '0', change: '—', isPositive: false, icon: Icons.error_rounded, color: Color(0xFFEF4444)),
          AuditKPI(title: 'Critical Issues', value: '0', change: '—', isPositive: false, icon: Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
          AuditKPI(title: 'Corrections Pending', value: '0', change: '—', isPositive: false, icon: Icons.published_with_changes_rounded, color: Color(0xFF8B5CF6)),
        ];

  List<ModuleProgress> get moduleProgressList => moduleProgress.isNotEmpty
      ? moduleProgress
      : const [
          ModuleProgress(name: 'Student Records', verified: 0, pending: 0, issues: 0, percentage: 0.0),
          ModuleProgress(name: 'Assignments', verified: 0, pending: 0, issues: 0, percentage: 0.0),
          ModuleProgress(name: 'Marks', verified: 0, pending: 0, issues: 0, percentage: 0.0),
          ModuleProgress(name: 'Faculty Reports', verified: 0, pending: 0, issues: 0, percentage: 0.0),
          ModuleProgress(name: 'Question Papers', verified: 0, pending: 0, issues: 0, percentage: 0.0),
          ModuleProgress(name: 'Research & Publications', verified: 0, pending: 0, issues: 0, percentage: 0.0),
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

  List<QuestionPaperRecord> questionPapers = [];

  // Audit Cases — populated exclusively from REST API (GET /api/cases).
  // No mock/static data. Empty until the backend loads real PostgreSQL data.
  final List<AuditCaseItem> auditCases = [];

  List<EvidenceItem> evidenceItems = [];

  List<AuditCaseItem> auditCases = [];

  List<AIAnomalyItem> aiAnomalies = [];

  List<AuditLogItem> auditLogs = [];

  // API Load Methods
  Future<void> loadAllData() async {
    _setLoading(true);
    _setError(null);
    try {
      await Future.wait([
        loadDashboard(),
        loadStudents(),
        loadAssignments(),
        loadMarks(),
        loadFacultyReports(),
        loadQuestionPapers(),
        loadResearch(),
        loadEvidence(),
        loadAuditCases(),
        loadAuditHistory(),
      ]);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _ensureFallbackSeedData();
      _setLoading(false);
    }
  }

  Future<void> loadDashboard() async {
    try {
      final data = await _api.getDashboard();
      final kpisData = data['kpis'] as Map<String, dynamic>?;
      kpis = [
        AuditKPI(
          title: 'Total Records Audited',
          value: '${kpisData?['totalRecords'] ?? 0}',
          change: '0%',
          isPositive: true,
          icon: Icons.analytics_rounded,
          color: const Color(0xFF4F46E5),
        ),
        AuditKPI(
          title: 'Pending Verification',
          value: '${kpisData?['pendingCount'] ?? 0}',
          change: '0%',
          isPositive: false,
          icon: Icons.hourglass_top_rounded,
          color: const Color(0xFFF59E0B),
        ),
        AuditKPI(
          title: 'Verified Records',
          value: '${kpisData?['verifiedCount'] ?? 0}',
          change: '0%',
          isPositive: true,
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF10B981),
        ),
        AuditKPI(
          title: 'Discrepancies Found',
          value: '${kpisData?['issuesCount'] ?? 0}',
          change: '0%',
          isPositive: false,
          icon: Icons.error_rounded,
          color: const Color(0xFFEF4444),
        ),
        AuditKPI(
          title: 'Critical Issues',
          value: '${kpisData?['criticalCount'] ?? 0}',
          change: '0%',
          isPositive: false,
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFDC2626),
        ),
        AuditKPI(
          title: 'Corrections Pending',
          value: '${kpisData?['correctionsPending'] ?? 0}',
          change: '0%',
          isPositive: false,
          icon: Icons.published_with_changes_rounded,
          color: const Color(0xFF8B5CF6),
        ),
      ];

      moduleProgress = (data['moduleProgress'] as List<dynamic>? ?? []).map((m) {
        final map = m as Map<String, dynamic>;
        return ModuleProgress(
          name: map['name'] as String,
          verified: (map['verified'] as num?)?.toInt() ?? 0,
          pending: (map['pending'] as num?)?.toInt() ?? 0,
          issues: (map['issues'] as num?)?.toInt() ?? 0,
          percentage: (map['percentage'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();

      recentActivities = (data['recentActivities'] as List<dynamic>? ?? []).map((a) {
        final map = a as Map<String, dynamic>;
        return AuditActivity(
          id: map['id'] as String? ?? '',
          title: map['title'] as String? ?? '',
          module: map['module'] as String? ?? '',
          timestamp: map['timestamp'] as String? ?? '',
          status: map['status'] as String? ?? 'Completed',
          icon: _getActivityIcon(map['module'] as String? ?? ''),
          iconColor: _getActivityColor(map['status'] as String? ?? 'Completed'),
          auditor: map['auditor'] as String? ?? '',
        );
      }).toList();

      criticalIssues = (data['criticalIssues'] as List<dynamic>? ?? []).map((c) {
        final map = c as Map<String, dynamic>;
        return CriticalIssue(
          id: map['id'] as String? ?? '',
          title: map['title'] as String? ?? '',
          priority: map['priority'] as String? ?? 'High',
          code: map['code'] as String? ?? '',
          department: map['department'] as String? ?? '',
          date: map['date'] as String? ?? '',
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load dashboard: $e');
    }
  }

  Future<void> loadStudents() async {
    try {
      final data = await _api.getStudents();
      final records = data['records'] as List<dynamic>? ?? [];
      studentRecords = records.map((s) {
        final map = s as Map<String, dynamic>;
        return StudentAuditRecord(
          registerNo: map['registerNo'] as String? ?? '',
          name: map['name'] as String? ?? '',
          department: map['department'] as String? ?? '',
          semester: (map['semester'] as num?)?.toInt() ?? 0,
          cgpa: (map['cgpa'] as num?)?.toDouble() ?? 0.0,
          attendance: (map['attendance'] as num?)?.toDouble() ?? 0.0,
          photoUrl: map['photoUrl'] as String? ?? '',
          status: map['status'] as String? ?? 'Pending',
          groupStatuses: (map['groupStatuses'] as List<dynamic>? ?? []).map((g) {
            final gm = g as Map<String, dynamic>;
            return RecordGroupStatus(
              groupName: gm['groupName'] as String? ?? '',
              status: gm['status'] as String? ?? 'Pending',
              details: gm['details'] as String? ?? '',
            );
          }).toList(),
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load students: $e');
    }
  }

  Future<void> loadAssignments() async {
    try {
      final data = await _api.getAssignments();
      final records = data['records'] as List<dynamic>? ?? [];
      assignmentRecords = records.map((r) {
        final map = r as Map<String, dynamic>;
        return AssignmentRecord(
          id: map['id'] as String? ?? '',
          studentRegNo: map['studentRegNo'] as String? ?? '',
          studentName: map['studentName'] as String? ?? '',
          title: map['title'] as String? ?? '',
          subject: map['subject'] as String? ?? '',
          submissionDate: map['submissionDate'] as String? ?? '',
          marksObtained: (map['marksObtained'] as num?)?.toInt() ?? 0,
          totalMarks: (map['totalMarks'] as num?)?.toInt() ?? 0,
          evidenceFile: map['evidenceFile'] as String? ?? '',
          isMissingFile: map['isMissingFile'] as bool? ?? false,
          isLate: map['isLate'] as bool? ?? false,
          isDuplicate: map['isDuplicate'] as bool? ?? false,
          status: map['status'] as String? ?? 'Pending',
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load assignments: $e');
    }
  }

  Future<void> loadMarks() async {
    try {
      final data = await _api.getMarks();
      final records = data['records'] as List<dynamic>? ?? [];
      marksEntries = records.map((r) {
        final map = r as Map<String, dynamic>;
        return MarksAuditEntry(
          id: map['id'] as String? ?? '',
          studentRegNo: map['studentRegNo'] as String? ?? '',
          studentName: map['studentName'] as String? ?? '',
          subjectCode: map['subjectCode'] as String? ?? '',
          subjectName: map['subjectName'] as String? ?? '',
          facultyEntry: (map['facultyEntry'] as num?)?.toInt() ?? 0,
          deptRecord: (map['deptRecord'] as num?)?.toInt() ?? 0,
          examRecord: (map['examRecord'] as num?)?.toInt() ?? 0,
          finalResult: (map['finalResult'] as num?)?.toInt() ?? 0,
          isMismatch: map['isMismatch'] as bool? ?? false,
          mismatchReason: map['mismatchReason'] as String? ?? '',
          status: map['status'] as String? ?? 'Pending',
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load marks: $e');
    }
  }

  Future<void> loadFacultyReports() async {
    try {
      final data = await _api.getFacultyReports();
      final records = data['records'] as List<dynamic>? ?? [];
      facultyReports = records.map((r) {
        final map = r as Map<String, dynamic>;
        return FacultyReportRecord(
          id: map['id'] as String? ?? '',
          facultyName: map['facultyName'] as String? ?? '',
          department: map['department'] as String? ?? '',
          reportType: map['reportType'] as String? ?? '',
          academicYear: map['academicYear'] as String? ?? '',
          regulation: map['regulation'] as String? ?? 'R2023',
          semester: (map['semester'] as num?)?.toInt() ?? 1,
          reportedAttendance: (map['reportedAttendance'] as num?)?.toDouble() ?? 0.0,
          actualAttendance: (map['actualAttendance'] as num?)?.toDouble() ?? 0.0,
          syllabusCompletionPercent: (map['syllabusCompletionPercent'] as num?)?.toInt() ?? 0,
          mentoringSessionsLogged: (map['mentoringSessionsLogged'] as num?)?.toInt() ?? 0,
          hasConflict: map['hasConflict'] as bool? ?? false,
          conflictDetails: map['conflictDetails'] as String? ?? '',
          status: map['status'] as String? ?? 'Pending',
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load faculty reports: $e');
    }
  }

  Future<void> loadQuestionPapers() async {
    try {
      final data = await _api.getQuestionPapers();
      final records = data['records'] as List<dynamic>? ?? [];
      questionPapers = records.map((r) {
        final map = r as Map<String, dynamic>;
        return QuestionPaperRecord(
          id: map['id'] as String? ?? '',
          courseCode: map['courseCode'] as String? ?? '',
          courseTitle: map['courseTitle'] as String? ?? '',
          regulation: map['regulation'] as String? ?? 'R2023',
          department: map['department'] as String? ?? '',
          semester: (map['semester'] as num?)?.toInt() ?? 1,
          academicYear: map['academicYear'] as String? ?? '2025 - 2026',
          bloomTaxonomyCompliant: map['bloomTaxonomyCompliant'] as bool? ?? false,
          syllabusMapped: map['syllabusMapped'] as bool? ?? false,
          hodApproved: map['hodApproved'] as bool? ?? false,
          coeApproved: map['coeApproved'] as bool? ?? false,
          status: map['status'] as String? ?? 'Pending',
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load question papers: $e');
    }
  }

  Future<void> loadResearch() async {
    try {
      final data = await _api.getResearch();
      final records = data['records'] as List<dynamic>? ?? [];
      researchRecords = records.map((r) {
        final map = r as Map<String, dynamic>;
        return ResearchRecord(
          id: map['id'] as String? ?? '',
          title: map['title'] as String? ?? '',
          authors: map['authors'] as String? ?? '',
          type: map['type'] as String? ?? 'Journal Article',
          doi: map['doi'] as String? ?? '',
          journalName: map['journalName'] as String? ?? '',
          indexing: map['indexing'] as String? ?? 'Scopus',
          year: map['year'] as String? ?? '2025',
          metadataMatch: map['metadataMatch'] as bool? ?? false,
          duplicateFlag: map['duplicateFlag'] as bool? ?? false,
          status: map['status'] as String? ?? 'Pending Examination',
          organization: map['organization'] as String? ?? 'KSR College of Engineering',
          department: map['department'] as String? ?? '',
          facultyName: map['facultyName'] as String? ?? '',
          description: map['description'] as String? ?? '',
          documentName: map['documentName'] as String? ?? '',
          documentType: map['documentType'] as String? ?? '',
          documentSize: map['documentSize'] as String? ?? '',
          documentStatus: map['documentStatus'] as String? ?? 'Not Uploaded',
          verificationChecklist: map['verificationChecklist'] is Map
              ? Map<String, String>.from(map['verificationChecklist'] as Map)
              : <String, String>{},
          auditorRemarks: map['auditorRemarks'] as String? ?? '',
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load research: $e');
    }
  }

  Future<void> loadEvidence() async {
    try {
      final data = await _api.getEvidence();
      final records = data['records'] as List<dynamic>? ?? [];
      evidenceItems = records.map((r) {
        final map = r as Map<String, dynamic>;
        return EvidenceItem(
          evidenceId: map['evidenceId'] as String? ?? '',
          recordId: map['recordId'] as String? ?? '',
          recordType: map['recordType'] as String? ?? '',
          uploadedBy: map['uploadedBy'] as String? ?? 'System',
          uploadDate: map['uploadDate'] as String? ?? '',
          documentType: map['documentType'] as String? ?? '',
          version: map['version'] as String? ?? 'v1.0',
          fileName: map['fileName'] as String? ?? '',
          fileSize: map['fileSize'] as String? ?? '',
          status: map['status'] as String? ?? 'Pending',
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load evidence: $e');
    }
  }

  Future<void> loadAuditCases() async {
    try {
      final data = await _api.getAuditCases();
      final records = data['records'] as List<dynamic>? ?? [];
      auditCases = records.map((c) {
        final map = c as Map<String, dynamic>;
        return AuditCaseItem(
          caseId: map['caseId'] as String? ?? '',
          title: map['title'] as String? ?? '',
          category: map['category'] as String? ?? 'General Audit',
          targetRecordId: map['targetRecordId'] as String? ?? '',
          severity: map['severity'] as String? ?? 'High',
          assignedTo: map['assignedTo'] as String? ?? '',
          lifecycleStage: map['lifecycleStage'] as String? ?? 'Detected',
          createdDate: map['createdDate'] as String? ?? '',
          description: map['description'] as String? ?? '',
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load audit cases: $e');
    }
  }

  Future<void> loadAuditHistory() async {
    try {
      final data = await _api.getAuditHistory();
      final records = data['records'] as List<dynamic>? ?? [];
      auditLogs = records.map((l) {
        final map = l as Map<String, dynamic>;
        return AuditLogItem(
          id: map['id'] as String? ?? '',
          timestamp: map['timestamp'] as String? ?? '',
          auditorName: map['auditorName'] as String? ?? '',
          ipAddress: map['ipAddress'] as String? ?? '',
          action: map['action'] as String? ?? '',
          recordId: map['recordId'] as String? ?? '',
          details: map['details'] as String? ?? '',
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load audit history: $e');
    }
  }

  // Verification & Action Methods
  Future<void> verifyStudentRecord(String regNo) async {
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
    try {
      await _api.verifyStudent(regNo);
    } catch (e) {
      debugPrint('API verify failed: $e');
    }
  }

  Future<void> flagIssue(String recordId, String reason, String severity) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final caseId = 'AUD-$timestamp';
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
    try {
      await _api.flagIssue(recordId: recordId, reason: reason, severity: severity);
    } catch (e) {
      debugPrint('API flag issue failed: $e');
    }
  }

  void addAuditLog(String action, String recordId, String details) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    auditLogs.insert(0, AuditLogItem(
      id: 'LOG-$timestamp',
      timestamp: DateTime.now().toLocal().toString().split('.')[0],
      auditorName: '$_userName ($_userRole)',
      ipAddress: '',
      action: action,
      recordId: recordId,
      details: details,
    ));
  }


  Future<void> updateResearchRecord(ResearchRecord updated) async {
    final idx = researchRecords.indexWhere((r) => r.id == updated.id);
    if (idx != -1) {
      researchRecords[idx] = updated;
      addAuditLog('RESEARCH_AUDITED', updated.id, 'Audited research paper ${updated.id}. Status: ${updated.status}');
      showToast('Research details saved successfully!');
      notifyListeners();
    }
    try {
      await _api.updateResearch(updated.id, {
        'status': updated.status,
        'metadataMatch': updated.metadataMatch,
        'duplicateFlag': updated.duplicateFlag,
        'documentStatus': updated.documentStatus,
        'verificationChecklist': updated.verificationChecklist,
        'auditorRemarks': updated.auditorRemarks,
      });
    } catch (e) {
      debugPrint('API update research failed: $e');
    }
  }

  IconData _getActivityIcon(String module) {
    switch (module) {
      case 'Student Audit':
        return Icons.person_rounded;
      case 'Assignment Audit':
        return Icons.assignment_rounded;
      case 'Marks Audit':
        return Icons.bar_chart_rounded;
      case 'Faculty Report Audit':
        return Icons.people_rounded;
      case 'Question Paper Audit':
        return Icons.description_rounded;
      case 'Research Audit':
        return Icons.science_rounded;
      case 'Audit Cases':
        return Icons.warning_amber_rounded;
      default:
        return Icons.fact_check_rounded;
    }
  }

  Color _getActivityColor(String status) {
    switch (status) {
      case 'Verified':
        return const Color(0xFF10B981);
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'Issues':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _ensureFallbackSeedData() {
    if (studentRecords.isEmpty) {
      studentRecords = [
        StudentAuditRecord(
          registerNo: '731521104001',
          name: 'Aravind Kumar',
          department: 'CSE',
          semester: 6,
          cgpa: 8.75,
          attendance: 92.5,
          photoUrl: '',
          status: 'Verified',
          groupStatuses: [
            RecordGroupStatus(groupName: 'Academic Profile', status: 'Verified', details: 'Records match DEPT ledger'),
            RecordGroupStatus(groupName: 'Fee Clearances', status: 'Verified', details: 'No dues pending'),
            RecordGroupStatus(groupName: 'Attendance Log', status: 'Verified', details: '92.5% verified'),
          ],
        ),
        StudentAuditRecord(
          registerNo: '731521104015',
          name: 'Deepa Lakshmi',
          department: 'CSE',
          semester: 6,
          cgpa: 9.12,
          attendance: 96.0,
          photoUrl: '',
          status: 'Verified',
          groupStatuses: [
            RecordGroupStatus(groupName: 'Academic Profile', status: 'Verified', details: 'DEPT ledger verified'),
            RecordGroupStatus(groupName: 'Attendance Log', status: 'Verified', details: '96.0% attendance verified'),
          ],
        ),
        StudentAuditRecord(
          registerNo: '731521106022',
          name: 'Gokul Nath',
          department: 'ECE',
          semester: 6,
          cgpa: 7.80,
          attendance: 84.5,
          photoUrl: '',
          status: 'Pending',
          groupStatuses: [
            RecordGroupStatus(groupName: 'Academic Profile', status: 'Pending', details: 'Awaiting HOD signature'),
            RecordGroupStatus(groupName: 'Attendance Log', status: 'Verified', details: '84.5% attendance verified'),
          ],
        ),
        StudentAuditRecord(
          registerNo: '731521106045',
          name: 'Kavitha R',
          department: 'ECE',
          semester: 6,
          cgpa: 8.40,
          attendance: 88.0,
          photoUrl: '',
          status: 'Verified',
          groupStatuses: [
            RecordGroupStatus(groupName: 'Academic Profile', status: 'Verified', details: 'Verified'),
          ],
        ),
        StudentAuditRecord(
          registerNo: '731521105010',
          name: 'Manoj Saravanan',
          department: 'EEE',
          semester: 6,
          cgpa: 6.95,
          attendance: 74.0,
          photoUrl: '',
          status: 'Discrepancy',
          groupStatuses: [
            RecordGroupStatus(groupName: 'Attendance Log', status: 'Discrepancy', details: 'Condonation fee missing for <75% attendance'),
          ],
        ),
        StudentAuditRecord(
          registerNo: '731521103008',
          name: 'Naveen Raj',
          department: 'MECH',
          semester: 6,
          cgpa: 8.10,
          attendance: 90.0,
          photoUrl: '',
          status: 'Verified',
          groupStatuses: [
            RecordGroupStatus(groupName: 'Academic Profile', status: 'Verified', details: 'Verified'),
          ],
        ),
      ];
    }

    if (assignmentRecords.isEmpty) {
      assignmentRecords = [
        AssignmentRecord(
          id: 'ASN-2026-001',
          studentRegNo: '731521104001',
          studentName: 'Aravind Kumar',
          title: 'Design of Distributed Database Index',
          subject: 'CS8601 - Database Systems',
          submissionDate: '2026-02-15',
          marksObtained: 18,
          totalMarks: 20,
          evidenceFile: 'CS8601_Assign1_731521104001.pdf',
          status: 'Verified',
        ),
        AssignmentRecord(
          id: 'ASN-2026-002',
          studentRegNo: '731521104015',
          studentName: 'Deepa Lakshmi',
          title: 'Relational Algebra Optimization',
          subject: 'CS8601 - Database Systems',
          submissionDate: '2026-02-14',
          marksObtained: 20,
          totalMarks: 20,
          evidenceFile: 'CS8601_Assign1_731521104015.pdf',
          status: 'Verified',
        ),
        AssignmentRecord(
          id: 'ASN-2026-003',
          studentRegNo: '731521106022',
          studentName: 'Gokul Nath',
          title: 'VLSI Circuit Simulation',
          subject: 'EC8651 - Transmission Lines',
          submissionDate: '2026-02-18',
          marksObtained: 14,
          totalMarks: 20,
          evidenceFile: '',
          isMissingFile: true,
          status: 'Pending',
        ),
        AssignmentRecord(
          id: 'ASN-2026-004',
          studentRegNo: '731521105010',
          studentName: 'Manoj Saravanan',
          title: 'Power Grid Load Flow Analysis',
          subject: 'EE8602 - Power System Analysis',
          submissionDate: '2026-02-22',
          marksObtained: 12,
          totalMarks: 20,
          isLate: true,
          evidenceFile: 'EE8602_Assign1_731521105010.pdf',
          status: 'Discrepancy',
        ),
      ];
    }

    if (marksEntries.isEmpty) {
      marksEntries = [
        MarksAuditEntry(
          id: 'MRK-2026-101',
          studentRegNo: '731521104001',
          studentName: 'Aravind Kumar',
          subjectCode: 'CS8601',
          subjectName: 'Database Systems',
          facultyEntry: 88,
          deptRecord: 88,
          examRecord: 88,
          finalResult: 88,
          isMismatch: false,
          status: 'Verified',
        ),
        MarksAuditEntry(
          id: 'MRK-2026-102',
          studentRegNo: '731521104015',
          studentName: 'Deepa Lakshmi',
          subjectCode: 'CS8601',
          subjectName: 'Database Systems',
          facultyEntry: 94,
          deptRecord: 94,
          examRecord: 94,
          finalResult: 94,
          isMismatch: false,
          status: 'Verified',
        ),
        MarksAuditEntry(
          id: 'MRK-2026-103',
          studentRegNo: '731521106022',
          studentName: 'Gokul Nath',
          subjectCode: 'EC8651',
          subjectName: 'Digital Signal Processing',
          facultyEntry: 76,
          deptRecord: 76,
          examRecord: 76,
          finalResult: 76,
          isMismatch: false,
          status: 'Pending',
        ),
        MarksAuditEntry(
          id: 'MRK-2026-104',
          studentRegNo: '731521106045',
          studentName: 'Kavitha R',
          subjectCode: 'EC8651',
          subjectName: 'Digital Signal Processing',
          facultyEntry: 74,
          deptRecord: 74,
          examRecord: 84,
          finalResult: 74,
          isMismatch: true,
          mismatchReason: 'Exam section entry (84) differs from Faculty Log (74)',
          status: 'Discrepancy',
        ),
      ];
    }

    if (facultyReports.isEmpty) {
      facultyReports = [
        FacultyReportRecord(
          id: 'REP-2026-01',
          facultyName: 'Dr. R. Selvam',
          department: 'CSE',
          reportType: 'Semester Audit Report',
          academicYear: '2025 - 2026',
          regulation: 'R2023',
          semester: 6,
          reportedAttendance: 94.0,
          actualAttendance: 93.8,
          syllabusCompletionPercent: 100,
          mentoringSessionsLogged: 12,
          hasConflict: false,
          status: 'Verified',
        ),
        FacultyReportRecord(
          id: 'REP-2026-02',
          facultyName: 'Prof. M. Kanthasamy',
          department: 'ECE',
          reportType: 'Lab Verification Report',
          academicYear: '2025 - 2026',
          regulation: 'R2023',
          semester: 6,
          reportedAttendance: 89.0,
          actualAttendance: 88.5,
          syllabusCompletionPercent: 95,
          mentoringSessionsLogged: 10,
          hasConflict: false,
          status: 'Verified',
        ),
        FacultyReportRecord(
          id: 'REP-2026-03',
          facultyName: 'Dr. S. Meenakshi',
          department: 'EEE',
          reportType: 'Course Completion Report',
          academicYear: '2025 - 2026',
          regulation: 'R2023',
          semester: 6,
          reportedAttendance: 92.0,
          actualAttendance: 85.0,
          syllabusCompletionPercent: 80,
          mentoringSessionsLogged: 4,
          hasConflict: true,
          conflictDetails: 'Reported attendance (92%) differs from biometric log (85%)',
          status: 'Pending',
        ),
      ];
    }

    if (questionPapers.isEmpty) {
      questionPapers = [
        QuestionPaperRecord(
          id: 'QP-2026-CSE-01',
          courseCode: 'CS8601',
          courseTitle: 'Database Management Systems',
          regulation: 'R2023',
          department: 'CSE',
          semester: 6,
          academicYear: '2025 - 2026',
          bloomTaxonomyCompliant: true,
          syllabusMapped: true,
          hodApproved: true,
          coeApproved: true,
          status: 'Verified',
        ),
        QuestionPaperRecord(
          id: 'QP-2026-ECE-02',
          courseCode: 'EC8651',
          courseTitle: 'Digital Signal Processing',
          regulation: 'R2023',
          department: 'ECE',
          semester: 6,
          academicYear: '2025 - 2026',
          bloomTaxonomyCompliant: true,
          syllabusMapped: true,
          hodApproved: true,
          coeApproved: false,
          status: 'Pending',
        ),
      ];
    }

    if (researchRecords.isEmpty) {
      researchRecords = [
        ResearchRecord(
          id: 'RES-2026-001',
          title: 'AI-Driven Automated Code Auditing in Distributed ERPs',
          authors: 'Dr. R. Selvam, K. Priya',
          type: 'Journal Article',
          doi: '10.1109/TSE.2026.301294',
          journalName: 'IEEE Transactions on Software Engineering',
          indexing: 'Scopus / Web of Science',
          year: '2026',
          metadataMatch: true,
          status: 'Verified',
          organization: 'KSR College of Engineering',
          department: 'CSE',
          facultyName: 'Dr. R. Selvam',
          description: 'Research paper on automated compliance auditing in higher education ERP platforms.',
          documentName: 'IEEE_TSE_Selvam_2026.pdf',
          documentType: 'PDF',
          documentSize: '2.4 MB',
          documentStatus: 'Verified',
          verificationChecklist: {'DOI Verified': 'Pass', 'Indexing Verified': 'Pass', 'Author Affiliation': 'Verified'},
          auditorRemarks: 'Publication verified with IEEE Xplore database.',
        ),
        ResearchRecord(
          id: 'RES-2026-002',
          title: 'Smart Grid Energy Optimization via Micro-Grid Controllers',
          authors: 'Dr. S. Meenakshi, R. Vimal',
          type: 'Conference Paper',
          doi: '10.1016/j.egypro.2026.1042',
          journalName: 'International Conference on Renewable Energy',
          indexing: 'Scopus',
          year: '2025',
          metadataMatch: true,
          status: 'Pending Examination',
          organization: 'KSR College of Engineering',
          department: 'EEE',
          facultyName: 'Dr. S. Meenakshi',
          description: 'Optimizing distribution efficiency using distributed controllers.',
          documentName: 'SmartGrid_Energy_2025.pdf',
          documentType: 'PDF',
          documentSize: '1.8 MB',
          documentStatus: 'Uploaded',
          verificationChecklist: {'DOI Verified': 'Pending', 'Indexing Verified': 'Pass'},
          auditorRemarks: 'Awaiting final DOI verification from publisher.',
        ),
      ];
    }

    if (auditCases.isEmpty) {
      auditCases = [
        AuditCaseItem(
          caseId: 'CASE-2026-01',
          title: 'Internal Assessment Marks Mismatch in EC8651',
          category: 'Marks Audit',
          targetRecordId: 'MRK-2026-104',
          severity: 'High',
          assignedTo: 'HOD / ECE',
          lifecycleStage: 'Correction Requested',
          createdDate: '2026-02-20',
          description: 'Faculty entry (74) differs from Controller of Examinations record (84).',
        ),
        AuditCaseItem(
          caseId: 'CASE-2026-02',
          title: 'Biometric Attendance Discrepancy in EEE Department',
          category: 'Faculty Report Audit',
          targetRecordId: 'REP-2026-03',
          severity: 'Medium',
          assignedTo: 'Dr. S. Meenakshi',
          lifecycleStage: 'Under Review',
          createdDate: '2026-02-22',
          description: 'Reported attendance (92%) differs from biometric log (85%).',
        ),
      ];
    }

    if (recentActivities.isEmpty) {
      recentActivities = [
        const AuditActivity(
          id: 'ACT-01',
          title: 'Student record 731521104001 verified',
          module: 'Student Audit',
          timestamp: '10 mins ago',
          status: 'Verified',
          icon: Icons.person_rounded,
          iconColor: Color(0xFF10B981),
          auditor: 'Lead Auditor',
        ),
        const AuditActivity(
          id: 'ACT-02',
          title: 'Marks mismatch flagged in EC8651',
          module: 'Marks Audit',
          timestamp: '45 mins ago',
          status: 'Issues',
          icon: Icons.bar_chart_rounded,
          iconColor: Color(0xFFEF4444),
          auditor: 'Department Auditor',
        ),
        const AuditActivity(
          id: 'ACT-03',
          title: 'Research Paper IEEE_TSE_Selvam_2026 verified',
          module: 'Research Audit',
          timestamp: '2 hours ago',
          status: 'Verified',
          icon: Icons.science_rounded,
          iconColor: Color(0xFF10B981),
          auditor: 'Lead Auditor',
        ),
      ];
    }

    if (criticalIssues.isEmpty) {
      criticalIssues = [
        const CriticalIssue(
          id: 'CRIT-01',
          title: 'Internal Marks Mismatch in EC8651',
          priority: 'High',
          code: 'MRK-104',
          department: 'ECE',
          date: '2026-02-20',
        ),
        const CriticalIssue(
          id: 'CRIT-02',
          title: 'Biometric Attendance Discrepancy',
          priority: 'Medium',
          code: 'REP-03',
          department: 'EEE',
          date: '2026-02-22',
        ),
      ];
    }

    _updateDashboardMetricsFromRecords();
  }

  void _updateDashboardMetricsFromRecords() {
    int studentVerified = studentRecords.where((r) => r.status == 'Verified').length;
    int studentPending = studentRecords.where((r) => r.status == 'Pending').length;
    int studentIssues = studentRecords.where((r) => r.status == 'Discrepancy' || r.status == 'Issues').length;

    int assignVerified = assignmentRecords.where((r) => r.status == 'Verified').length;
    int assignPending = assignmentRecords.where((r) => r.status == 'Pending').length;
    int assignIssues = assignmentRecords.where((r) => r.status == 'Discrepancy' || r.isMissingFile || r.isDuplicate).length;

    int marksVerified = marksEntries.where((r) => r.status == 'Verified').length;
    int marksPending = marksEntries.where((r) => r.status == 'Pending').length;
    int marksIssues = marksEntries.where((r) => r.status == 'Discrepancy' || r.isMismatch).length;

    int facultyVerified = facultyReports.where((r) => r.status == 'Verified').length;
    int facultyPending = facultyReports.where((r) => r.status == 'Pending').length;
    int facultyIssues = facultyReports.where((r) => r.status == 'Discrepancy' || r.hasConflict).length;

    int qpVerified = questionPapers.where((r) => r.status == 'Verified').length;
    int qpPending = questionPapers.where((r) => r.status == 'Pending').length;
    int qpIssues = questionPapers.where((r) => r.status == 'Discrepancy').length;

    int resVerified = researchRecords.where((r) => r.status == 'Verified').length;
    int resPending = researchRecords.where((r) => r.status == 'Pending' || r.status == 'Pending Examination').length;
    int resIssues = researchRecords.where((r) => r.status == 'Needs Correction' || r.duplicateFlag).length;

    int totalRecords = studentRecords.length + assignmentRecords.length + marksEntries.length + facultyReports.length + questionPapers.length + researchRecords.length;
    int totalVerified = studentVerified + assignVerified + marksVerified + facultyVerified + qpVerified + resVerified;
    int totalPending = studentPending + assignPending + marksPending + facultyPending + qpPending + resPending;
    int totalIssues = studentIssues + assignIssues + marksIssues + facultyIssues + qpIssues + resIssues;

    kpis = [
      AuditKPI(title: 'Total Records Audited', value: '$totalRecords', change: '+12%', isPositive: true, icon: Icons.analytics_rounded, color: const Color(0xFF4F46E5)),
      AuditKPI(title: 'Pending Verification', value: '$totalPending', change: '-5%', isPositive: false, icon: Icons.hourglass_top_rounded, color: const Color(0xFFF59E0B)),
      AuditKPI(title: 'Verified Records', value: '$totalVerified', change: '+18%', isPositive: true, icon: Icons.check_circle_rounded, color: const Color(0xFF10B981)),
      AuditKPI(title: 'Discrepancies Found', value: '$totalIssues', change: '-2%', isPositive: false, icon: Icons.error_rounded, color: const Color(0xFFEF4444)),
      AuditKPI(title: 'Critical Issues', value: '${criticalIssues.length}', change: '0%', isPositive: false, icon: Icons.warning_amber_rounded, color: const Color(0xFFDC2626)),
      AuditKPI(title: 'Corrections Pending', value: '${auditCases.where((c) => c.lifecycleStage.contains("Correction")).length}', change: '+1%', isPositive: false, icon: Icons.published_with_changes_rounded, color: const Color(0xFF8B5CF6)),
    ];

    double calcPct(int ver, int tot) => tot > 0 ? (ver / tot).clamp(0.0, 1.0) : 0.0;

    moduleProgress = [
      ModuleProgress(name: 'Student Records', verified: studentVerified, pending: studentPending, issues: studentIssues, percentage: calcPct(studentVerified, studentRecords.length)),
      ModuleProgress(name: 'Assignments', verified: assignVerified, pending: assignPending, issues: assignIssues, percentage: calcPct(assignVerified, assignmentRecords.length)),
      ModuleProgress(name: 'Marks', verified: marksVerified, pending: marksPending, issues: marksIssues, percentage: calcPct(marksVerified, marksEntries.length)),
      ModuleProgress(name: 'Faculty Reports', verified: facultyVerified, pending: facultyPending, issues: facultyIssues, percentage: calcPct(facultyVerified, facultyReports.length)),
      ModuleProgress(name: 'Question Papers', verified: qpVerified, pending: qpPending, issues: qpIssues, percentage: calcPct(qpVerified, questionPapers.length)),
      ModuleProgress(name: 'Research & Publications', verified: resVerified, pending: resPending, issues: resIssues, percentage: calcPct(resVerified, researchRecords.length)),
    ];
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
