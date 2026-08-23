import 'package:flutter/material.dart';
import '../models/models.dart';

class AuditState extends ChangeNotifier {
  String _activeModule = 'Dashboard';
  String _selectedAcademicYear = '2025 - 2026';
  String _globalSearchQuery = '';
  String _userRole = 'Lead Auditor';
  final String _userName = 'Auditor User';
  
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

  // Dashboard Stats
  final List<AuditKPI> kpis = const [
    AuditKPI(
      title: 'Total Records Audited',
      value: '12,450',
      change: '↑ 12.5% from last month',
      isPositive: true,
      icon: Icons.assignment_turned_in_rounded,
      color: Color(0xFF6366F1),
    ),
    AuditKPI(
      title: 'Pending Verification',
      value: '1,284',
      change: '↓ 8.3% from last month',
      isPositive: true,
      icon: Icons.hourglass_top_rounded,
      color: Color(0xFFF59E0B),
    ),
    AuditKPI(
      title: 'Verified',
      value: '9,840',
      change: '↑ 15.2% from last month',
      isPositive: true,
      icon: Icons.check_circle_rounded,
      color: Color(0xFF10B981),
    ),
    AuditKPI(
      title: 'Issues Found',
      value: '936',
      change: '↓ 3.1% from last month',
      isPositive: false,
      icon: Icons.error_rounded,
      color: Color(0xFFEF4444),
    ),
    AuditKPI(
      title: 'Critical Issues',
      value: '47',
      change: '↓ 6.0% from last month',
      isPositive: false,
      icon: Icons.flag_rounded,
      color: Color(0xFFDC2626),
    ),
    AuditKPI(
      title: 'Corrections Pending',
      value: '343',
      change: '↓ 9.4% from last month',
      isPositive: true,
      icon: Icons.published_with_changes_rounded,
      color: Color(0xFF3B82F6),
    ),
  ];

  final List<ModuleProgress> moduleProgress = const [
    ModuleProgress(name: 'Student Records', verified: 2850, pending: 285, issues: 120, percentage: 0.91),
    ModuleProgress(name: 'Assignments', verified: 2450, pending: 320, issues: 98, percentage: 0.88),
    ModuleProgress(name: 'Marks', verified: 2150, pending: 410, issues: 150, percentage: 0.81),
    ModuleProgress(name: 'Faculty Reports', verified: 1980, pending: 210, issues: 95, percentage: 0.90),
    ModuleProgress(name: 'Question Papers', verified: 920, pending: 120, issues: 40, percentage: 0.85),
    ModuleProgress(name: 'Research & Publications', verified: 1490, pending: 190, issues: 55, percentage: 0.89),
  ];

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

  // Student Audit Mock Data
  final List<StudentAuditRecord> studentRecords = [
    StudentAuditRecord(
      registerNo: '23CS001',
      name: 'Adithya V',
      department: 'Computer Science & Engineering',
      semester: 5,
      cgpa: 8.84,
      attendance: 94.2,
      photoUrl: '',
      status: 'Verified',
      groupStatuses: [
        RecordGroupStatus(groupName: 'Personal Info', status: 'Verified', details: 'Aadhaar & Birth Cert Verified'),
        RecordGroupStatus(groupName: 'Attendance', status: 'Verified', details: '94.2% bio-attendance log matched'),
        RecordGroupStatus(groupName: 'Internal Marks', status: 'Verified', details: 'CAT 1 & 2 verified with answer sheets'),
        RecordGroupStatus(groupName: 'Assignments', status: 'Verified', details: '5 of 5 assignments uploaded and evaluated'),
        RecordGroupStatus(groupName: 'End-Sem Results', status: 'Verified', details: 'CoE ledger match verified'),
        RecordGroupStatus(groupName: 'Projects', status: 'Verified', details: 'Mini project code & report attached'),
      ],
    ),
    StudentAuditRecord(
      registerNo: '23CS0456',
      name: 'John Doe',
      department: 'Computer Science & Engineering',
      semester: 5,
      cgpa: 8.12,
      attendance: 88.5,
      photoUrl: '',
      status: 'Verified',
      groupStatuses: [
        RecordGroupStatus(groupName: 'Personal Info', status: 'Verified', details: 'Identity records verified'),
        RecordGroupStatus(groupName: 'Attendance', status: 'Verified', details: '88.5% log verified'),
        RecordGroupStatus(groupName: 'Internal Marks', status: 'Verified', details: 'Internal marks verified'),
        RecordGroupStatus(groupName: 'Assignments', status: 'Verified', details: 'Submissions verified'),
        RecordGroupStatus(groupName: 'End-Sem Results', status: 'Verified', details: 'Results verified'),
        RecordGroupStatus(groupName: 'Projects', status: 'Verified', details: 'Project documentation verified'),
      ],
    ),
    StudentAuditRecord(
      registerNo: '23IT045',
      name: 'Priya Sharma',
      department: 'Information Technology',
      semester: 5,
      cgpa: 9.10,
      attendance: 74.0,
      photoUrl: '',
      status: 'Discrepancy',
      groupStatuses: [
        RecordGroupStatus(groupName: 'Personal Info', status: 'Verified', details: 'Address mismatch flagged'),
        RecordGroupStatus(groupName: 'Attendance', status: 'Discrepancy', details: 'Attendance < 75% threshold without condonation letter'),
        RecordGroupStatus(groupName: 'Internal Marks', status: 'Verified', details: 'Marks match faculty entry'),
        RecordGroupStatus(groupName: 'Assignments', status: 'Discrepancy', details: 'Assignment 3 file missing'),
        RecordGroupStatus(groupName: 'End-Sem Results', status: 'Verified', details: 'CoE grades match'),
        RecordGroupStatus(groupName: 'Projects', status: 'Pending', details: 'Review pending'),
      ],
    ),
  ];

  // Marks Audit Entries
  final List<MarksAuditEntry> marksEntries = [
    MarksAuditEntry(
      id: 'MRK-2025-01',
      studentRegNo: '23CS001',
      studentName: 'Adithya V',
      subjectCode: '23CS201',
      subjectName: 'Data Structures',
      facultyEntry: 84,
      deptRecord: 84,
      examRecord: 84,
      finalResult: 84,
      isMismatch: false,
      status: 'Verified',
    ),
    MarksAuditEntry(
      id: 'MRK-2025-02',
      studentRegNo: '23CS0456',
      studentName: 'John Doe',
      subjectCode: '23CS201',
      subjectName: 'Data Structures',
      facultyEntry: 88,
      deptRecord: 88,
      examRecord: 72,
      finalResult: 72,
      isMismatch: true,
      mismatchReason: 'Exam record (72) does not match Faculty Entry (88). Post-approval modification detected.',
      status: 'Discrepancy',
    ),
    MarksAuditEntry(
      id: 'MRK-2025-03',
      studentRegNo: '23IT045',
      studentName: 'Priya Sharma',
      subjectCode: '23IT204',
      subjectName: 'DBMS',
      facultyEntry: 92,
      deptRecord: 92,
      examRecord: 92,
      finalResult: 92,
      isMismatch: false,
      status: 'Verified',
    ),
  ];

  // Assignment Records
  final List<AssignmentRecord> assignmentRecords = [
    AssignmentRecord(
      id: 'ASN-101',
      studentRegNo: '23CS001',
      studentName: 'Adithya V',
      title: 'B-Tree Implementation in C++',
      subject: '23CS201 Data Structures',
      submissionDate: '2026-08-10 14:30',
      marksObtained: 20,
      totalMarks: 20,
      evidenceFile: 'EVD-8891_Adithya_Assignment1.pdf',
      status: 'Verified',
    ),
    AssignmentRecord(
      id: 'ASN-102',
      studentRegNo: '23IT045',
      studentName: 'Priya Sharma',
      title: 'ER Diagram & Relational Schema',
      subject: '23IT204 DBMS',
      submissionDate: '2026-08-15 23:59',
      marksObtained: 18,
      totalMarks: 20,
      evidenceFile: '',
      isMissingFile: true,
      status: 'Missing Evidence File',
    ),
    AssignmentRecord(
      id: 'ASN-103',
      studentRegNo: '23EC106',
      studentName: 'Rohan Kumar',
      title: 'Amplifier Circuit Simulation',
      subject: '23EC106 Analog Electronics',
      submissionDate: '2026-08-18 09:12',
      marksObtained: 15,
      totalMarks: 20,
      evidenceFile: 'EVD-8894_Circuit_Simulation.pdf',
      isLate: true,
      status: 'Submitted Late',
    ),
  ];

  // Faculty Report Records
  final List<FacultyReportRecord> facultyReports = [
    FacultyReportRecord(
      id: 'REP-CSE-101',
      facultyName: 'Dr. R. Kumar',
      department: 'Computer Science & Engineering',
      reportType: 'Course Completion Report',
      academicYear: '2025 - 2026',
      regulation: 'R2023',
      semester: 5,
      reportedAttendance: 95.0,
      actualAttendance: 82.5,
      syllabusCompletionPercent: 100,
      mentoringSessionsLogged: 12,
      hasConflict: true,
      conflictDetails: 'Reported attendance (95%) conflicts with biometric classroom logs (82.5%).',
      status: 'Rejected',
    ),
    FacultyReportRecord(
      id: 'REP-IT-202',
      facultyName: 'Dr. S. Meena',
      department: 'Information Technology',
      reportType: 'Academic Performance Report',
      academicYear: '2025 - 2026',
      regulation: 'R2023',
      semester: 5,
      reportedAttendance: 91.2,
      actualAttendance: 91.2,
      syllabusCompletionPercent: 98,
      mentoringSessionsLogged: 16,
      hasConflict: false,
      status: 'Verified',
    ),
    FacultyReportRecord(
      id: 'REP-ECE-303',
      facultyName: 'Prof. A. Vijay',
      department: 'Electronics & Communication Engineering',
      reportType: 'Course Completion Report',
      academicYear: '2025 - 2026',
      regulation: 'R2021',
      semester: 3,
      reportedAttendance: 88.5,
      actualAttendance: 88.5,
      syllabusCompletionPercent: 95,
      mentoringSessionsLogged: 10,
      hasConflict: false,
      status: 'Verified',
    ),
    FacultyReportRecord(
      id: 'REP-EEE-404',
      facultyName: 'Dr. L. Prathap',
      department: 'Electrical & Electronics Engineering',
      reportType: 'Mentoring & Student Progress Report',
      academicYear: '2025 - 2026',
      regulation: 'R2021',
      semester: 7,
      reportedAttendance: 78.0,
      actualAttendance: 69.5,
      syllabusCompletionPercent: 88,
      mentoringSessionsLogged: 6,
      hasConflict: true,
      conflictDetails: 'Reported attendance (78%) vs biometric log (69.5%). Condonation cases unresolved.',
      status: 'Under Review',
    ),
    FacultyReportRecord(
      id: 'REP-MECH-505',
      facultyName: 'Dr. K. Suresh',
      department: 'Mechanical Engineering',
      reportType: 'Lab Utilisation Report',
      academicYear: '2024 - 2025',
      regulation: 'R2021',
      semester: 6,
      reportedAttendance: 92.0,
      actualAttendance: 92.0,
      syllabusCompletionPercent: 100,
      mentoringSessionsLogged: 14,
      hasConflict: false,
      status: 'Verified',
    ),
    FacultyReportRecord(
      id: 'REP-CSE-606',
      facultyName: 'Dr. P. Anand',
      department: 'Computer Science & Engineering',
      reportType: 'Academic Performance Report',
      academicYear: '2024 - 2025',
      regulation: 'R2021',
      semester: 8,
      reportedAttendance: 85.0,
      actualAttendance: 85.0,
      syllabusCompletionPercent: 100,
      mentoringSessionsLogged: 18,
      hasConflict: false,
      status: 'Verified',
    ),
    FacultyReportRecord(
      id: 'REP-IT-707',
      facultyName: 'Ms. R. Divya',
      department: 'Information Technology',
      reportType: 'Course Completion Report',
      academicYear: '2024 - 2025',
      regulation: 'R2021',
      semester: 2,
      reportedAttendance: 96.0,
      actualAttendance: 89.0,
      syllabusCompletionPercent: 92,
      mentoringSessionsLogged: 8,
      hasConflict: true,
      conflictDetails: 'Attendance overreported by 7%. ERP entry not matching physical attendance register.',
      status: 'Rejected',
    ),
    FacultyReportRecord(
      id: 'REP-ECE-808',
      facultyName: 'Prof. M. Rajan',
      department: 'Electronics & Communication Engineering',
      reportType: 'Research Integration Report',
      academicYear: '2025 - 2026',
      regulation: 'R2023',
      semester: 4,
      reportedAttendance: 89.5,
      actualAttendance: 89.5,
      syllabusCompletionPercent: 97,
      mentoringSessionsLogged: 11,
      hasConflict: false,
      status: 'Verified',
    ),
    FacultyReportRecord(
      id: 'REP-MECH-909',
      facultyName: 'Dr. N. Balamurugan',
      department: 'Mechanical Engineering',
      reportType: 'Mentoring & Student Progress Report',
      academicYear: '2025 - 2026',
      regulation: 'R2023',
      semester: 1,
      reportedAttendance: 80.0,
      actualAttendance: 75.0,
      syllabusCompletionPercent: 84,
      mentoringSessionsLogged: 4,
      hasConflict: true,
      conflictDetails: 'Syllabus completion below 85% threshold. Mentoring sessions fewer than minimum required.',
      status: 'Under Review',
    ),
    FacultyReportRecord(
      id: 'REP-EEE-010',
      facultyName: 'Prof. C. Kavitha',
      department: 'Electrical & Electronics Engineering',
      reportType: 'Course Completion Report',
      academicYear: '2024 - 2025',
      regulation: 'R2023',
      semester: 6,
      reportedAttendance: 93.5,
      actualAttendance: 93.5,
      syllabusCompletionPercent: 99,
      mentoringSessionsLogged: 15,
      hasConflict: false,
      status: 'Verified',
    ),
  ];

  // Question Paper Audit Records
  final List<QuestionPaperRecord> questionPapers = [
    QuestionPaperRecord(
      id: 'QP-23CS201',
      courseCode: '23CS201',
      courseTitle: 'Data Structures',
      regulation: 'R2023',
      department: 'CSE',
      semester: 3,
      academicYear: '2025 - 2026',
      bloomTaxonomyCompliant: true,
      syllabusMapped: true,
      hodApproved: true,
      coeApproved: true,
      status: 'Verified',
    ),
    QuestionPaperRecord(
      id: 'QP-23IT204',
      courseCode: '23IT204',
      courseTitle: 'Database Management Systems',
      regulation: 'R2023',
      department: 'IT',
      semester: 4,
      academicYear: '2025 - 2026',
      bloomTaxonomyCompliant: true,
      syllabusMapped: false,
      hodApproved: true,
      coeApproved: false,
      status: 'Missing Approval',
    ),
    QuestionPaperRecord(
      id: 'QP-21EC301',
      courseCode: '21EC301',
      courseTitle: 'Analog Electronics',
      regulation: 'R2021',
      department: 'ECE',
      semester: 5,
      academicYear: '2025 - 2026',
      bloomTaxonomyCompliant: true,
      syllabusMapped: true,
      hodApproved: true,
      coeApproved: true,
      status: 'Verified',
    ),
    QuestionPaperRecord(
      id: 'QP-21EE401',
      courseCode: '21EE401',
      courseTitle: 'Power Systems Analysis',
      regulation: 'R2021',
      department: 'EEE',
      semester: 7,
      academicYear: '2025 - 2026',
      bloomTaxonomyCompliant: false,
      syllabusMapped: true,
      hodApproved: true,
      coeApproved: false,
      status: 'Missing Approval',
    ),
    QuestionPaperRecord(
      id: 'QP-21ME501',
      courseCode: '21ME501',
      courseTitle: 'Thermodynamics',
      regulation: 'R2021',
      department: 'MECH',
      semester: 6,
      academicYear: '2024 - 2025',
      bloomTaxonomyCompliant: true,
      syllabusMapped: true,
      hodApproved: true,
      coeApproved: true,
      status: 'Verified',
    ),
    QuestionPaperRecord(
      id: 'QP-23CS401',
      courseCode: '23CS401',
      courseTitle: 'Machine Learning',
      regulation: 'R2023',
      department: 'CSE',
      semester: 8,
      academicYear: '2024 - 2025',
      bloomTaxonomyCompliant: true,
      syllabusMapped: true,
      hodApproved: false,
      coeApproved: false,
      status: 'Under Review',
    ),
    QuestionPaperRecord(
      id: 'QP-23IT102',
      courseCode: '23IT102',
      courseTitle: 'Programming in Python',
      regulation: 'R2023',
      department: 'IT',
      semester: 2,
      academicYear: '2024 - 2025',
      bloomTaxonomyCompliant: false,
      syllabusMapped: false,
      hodApproved: false,
      coeApproved: false,
      status: 'Rejected',
    ),
    QuestionPaperRecord(
      id: 'QP-21EC102',
      courseCode: '21EC102',
      courseTitle: 'Circuit Theory',
      regulation: 'R2021',
      department: 'ECE',
      semester: 1,
      academicYear: '2024 - 2025',
      bloomTaxonomyCompliant: true,
      syllabusMapped: true,
      hodApproved: true,
      coeApproved: true,
      status: 'Verified',
    ),
    QuestionPaperRecord(
      id: 'QP-23EE201',
      courseCode: '23EE201',
      courseTitle: 'Electrical Machines',
      regulation: 'R2023',
      department: 'EEE',
      semester: 4,
      academicYear: '2025 - 2026',
      bloomTaxonomyCompliant: true,
      syllabusMapped: true,
      hodApproved: true,
      coeApproved: true,
      status: 'Verified',
    ),
    QuestionPaperRecord(
      id: 'QP-21ME301',
      courseCode: '21ME301',
      courseTitle: 'Engineering Materials',
      regulation: 'R2021',
      department: 'MECH',
      semester: 3,
      academicYear: '2025 - 2026',
      bloomTaxonomyCompliant: false,
      syllabusMapped: true,
      hodApproved: true,
      coeApproved: false,
      status: 'Under Review',
    ),
    QuestionPaperRecord(
      id: 'QP-23CS101',
      courseCode: '23CS101',
      courseTitle: 'Problem Solving & C Programming',
      regulation: 'R2023',
      department: 'CSE',
      semester: 1,
      academicYear: '2025 - 2026',
      bloomTaxonomyCompliant: true,
      syllabusMapped: true,
      hodApproved: true,
      coeApproved: true,
      status: 'Verified',
    ),
    QuestionPaperRecord(
      id: 'QP-21IT601',
      courseCode: '21IT601',
      courseTitle: 'Cloud Computing',
      regulation: 'R2021',
      department: 'IT',
      semester: 6,
      academicYear: '2024 - 2025',
      bloomTaxonomyCompliant: true,
      syllabusMapped: false,
      hodApproved: true,
      coeApproved: false,
      status: 'Missing Approval',
    ),
  ];

  // Research Records
  final List<ResearchRecord> researchRecords = [
    ResearchRecord(
      id: 'RES-2025-01',
      title: 'AI in Higher Education: Machine Learning Models for Student Performance Prediction',
      authors: 'Dr. S. Meena, Adithya V',
      type: 'Journal Publication',
      doi: '10.1016/j.compedu.2025.104921',
      journalName: 'IEEE Transactions on Learning Technologies',
      indexing: 'Scopus / Web of Science',
      year: '2025',
      metadataMatch: true,
      status: 'Verified',
    ),
    ResearchRecord(
      id: 'RES-2025-02',
      title: 'Automated ERP Ledger Audit Framework using Distributed Immutable Systems',
      authors: 'Dr. R. Kumar',
      type: 'Conference Proceeding',
      doi: '10.1109/ICERP.2025.998231',
      journalName: 'International Conference on ERP Technologies',
      indexing: 'Scopus',
      year: '2025',
      metadataMatch: false,
      duplicateFlag: true,
      status: 'Discrepancy Flagged',
    ),
  ];

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

  // Audit Cases
  final List<AuditCaseItem> auditCases = [
    AuditCaseItem(
      caseId: 'AUD-2026-001245',
      title: 'Marks mismatch in 23CS201 Data Structures',
      category: 'Marks Audit',
      targetRecordId: 'MRK-2025-02 (Student 23CS0456)',
      severity: 'High',
      assignedTo: 'HOD - Computer Science',
      lifecycleStage: 'Correction Requested',
      createdDate: '2026-08-18',
      description: 'Exam record marks (72) do not match faculty entry (88). Clarification requested from HOD.',
    ),
    AuditCaseItem(
      caseId: 'AUD-2026-001242',
      title: 'Faculty report attendance conflict - Dr. R. Kumar',
      category: 'Faculty Report',
      targetRecordId: 'REP-CSE-101',
      severity: 'Medium',
      assignedTo: 'Dean Academics',
      lifecycleStage: 'Under Review',
      createdDate: '2026-08-17',
      description: 'Reported attendance 95% vs actual 82.5% in classroom biometric device.',
    ),
    AuditCaseItem(
      caseId: 'AUD-2026-001239',
      title: 'Question Paper missing Bloom Taxonomy mapping',
      category: 'Question Paper',
      targetRecordId: 'QP-23IT204',
      severity: 'Low',
      assignedTo: 'Controller of Examinations',
      lifecycleStage: 'Detected',
      createdDate: '2026-08-16',
      description: 'CO-PO mapping missing in section C question 14.',
    ),
  ];

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
}
