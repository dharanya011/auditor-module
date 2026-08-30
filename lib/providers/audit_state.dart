import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuditState extends ChangeNotifier {
  String _activeModule = 'Dashboard';
  String _selectedAcademicYear = '2025 - 2026';
  String _globalSearchQuery = '';
  String _userRole = 'Lead_Auditor';
  String _userName = 'Auditor User';

  final ApiService _api = ApiService();

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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    try {
      final result = await _api.login(email, password);
      final user = result['user'] as Map<String, dynamic>;
      _userRole = user['role'] as String? ?? 'Lead_Auditor';
      _userName = user['fullName'] as String? ?? 'Auditor User';
      notifyListeners();
      await loadAllData();
    } catch (e) {
      debugPrint('Sign in failed: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _api.logout();
    notifyListeners();
  }

  // Data Lists — initialized with zero-value defaults so cards always render
  List<AuditKPI> kpis = [
    AuditKPI(title: 'Total Records Audited', value: '0', change: '—', isPositive: true, icon: Icons.analytics_rounded, color: const Color(0xFF4F46E5)),
    AuditKPI(title: 'Pending Verification', value: '0', change: '—', isPositive: false, icon: Icons.hourglass_top_rounded, color: const Color(0xFFF59E0B)),
    AuditKPI(title: 'Verified Records', value: '0', change: '—', isPositive: true, icon: Icons.check_circle_rounded, color: const Color(0xFF10B981)),
    AuditKPI(title: 'Discrepancies Found', value: '0', change: '—', isPositive: false, icon: Icons.error_rounded, color: const Color(0xFFEF4444)),
    AuditKPI(title: 'Critical Issues', value: '0', change: '—', isPositive: false, icon: Icons.warning_amber_rounded, color: const Color(0xFFDC2626)),
    AuditKPI(title: 'Corrections Pending', value: '0', change: '—', isPositive: false, icon: Icons.published_with_changes_rounded, color: const Color(0xFF8B5CF6)),
  ];

  List<ModuleProgress> moduleProgress = [
    ModuleProgress(name: 'Student Records', verified: 0, pending: 0, issues: 0, percentage: 0.0),
    ModuleProgress(name: 'Assignments', verified: 0, pending: 0, issues: 0, percentage: 0.0),
    ModuleProgress(name: 'Marks', verified: 0, pending: 0, issues: 0, percentage: 0.0),
    ModuleProgress(name: 'Faculty Reports', verified: 0, pending: 0, issues: 0, percentage: 0.0),
    ModuleProgress(name: 'Question Papers', verified: 0, pending: 0, issues: 0, percentage: 0.0),
    ModuleProgress(name: 'Research & Publications', verified: 0, pending: 0, issues: 0, percentage: 0.0),
  ];

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

  List<AuditActivity> recentActivities = [];

  List<CriticalIssue> criticalIssues = [];

  List<StudentAuditRecord> studentRecords = [];

  List<MarksAuditEntry> marksEntries = [];

  List<AssignmentRecord> assignmentRecords = [];

  List<FacultyReportRecord> facultyReports = [];

  List<QuestionPaperRecord> questionPapers = [];

  List<ResearchRecord> researchRecords = [];

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

  Future<void> addResearchRecord(ResearchRecord record) async {
    researchRecords.insert(0, record);
    addAuditLog('RESEARCH_SUBMITTED', record.id, 'New research paper "${record.title}" submitted by ${record.facultyName} (${record.department})');
    showToast('Research paper submitted successfully! Status: Pending Examination');
    notifyListeners();
    try {
      await _api.createResearch({
        'title': record.title,
        'authors': record.authors,
        'type': record.type,
        'doi': record.doi,
        'journalName': record.journalName,
        'indexing': record.indexing,
        'year': record.year,
        'organization': record.organization,
        'departmentId': null,
        'facultyName': record.facultyName,
        'description': record.description,
        'documentName': record.documentName,
        'documentType': record.documentType,
        'documentSize': record.documentSize,
      });
    } catch (e) {
      debugPrint('API create research failed: $e');
    }
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
}
