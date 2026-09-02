import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// ApiService — Flutter HTTP client for the Node.js/Express backend.
///
/// Security rules:
/// - This class NEVER stores or logs DB credentials.
/// - It only knows the backend REST API URL.
/// - All DB access happens on the Node.js server side.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  /// Base URL of the Node.js backend.
  /// Change this to your deployed backend URL when running in production.
  static const String _baseUrl = 'http://localhost:3000/api';

  // ────────────────────────────────────────────────────────────────────────────
  // Health
  // ────────────────────────────────────────────────────────────────────────────

  /// Returns `true` if the backend and DB are reachable.
  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['status'] == 'ok' && data['db'] == 'connected';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Students
  // ────────────────────────────────────────────────────────────────────────────

  /// Fetch all students. Optionally filter by [dept] and/or [status].
  Future<List<Map<String, dynamic>>> fetchStudents({
    String? dept,
    String? status,
    int limit = 100,
    int offset = 0,
  }) async {
    final uri = Uri.parse('$_baseUrl/students').replace(queryParameters: {
      if (dept != null && dept.isNotEmpty) 'dept': dept,
      if (status != null && status.isNotEmpty) 'status': status,
      'limit': limit.toString(),
      'offset': offset.toString(),
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    _checkStatus(response, 'fetchStudents');

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(body['students'] as List);
  }

  /// Fetch a single student by register number / student ID.
  Future<Map<String, dynamic>> fetchStudent(String studentId) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/students/$studentId'))
        .timeout(const Duration(seconds: 10));
    _checkStatus(response, 'fetchStudent');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Marks
  // ────────────────────────────────────────────────────────────────────────────

  /// Fetch marks/audit entries for a specific student.
  Future<List<Map<String, dynamic>>> fetchMarks(String studentId) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/marks/$studentId'))
        .timeout(const Duration(seconds: 10));
    _checkStatus(response, 'fetchMarks');

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(body['marks'] as List);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Attendance
  // ────────────────────────────────────────────────────────────────────────────

  /// Fetch attendance records for a specific student.
  Future<Map<String, dynamic>> fetchAttendance(String studentId) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/attendance/$studentId'))
        .timeout(const Duration(seconds: 10));
    _checkStatus(response, 'fetchAttendance');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Assignments
  // ────────────────────────────────────────────────────────────────────────────

  /// Fetch assignment records (optional studentId or dept filters).
  Future<List<Map<String, dynamic>>> fetchAssignments({String? studentId, String? dept}) async {
    final queryParams = <String, String>{};
    if (studentId != null && studentId.isNotEmpty) queryParams['studentId'] = studentId;
    if (dept != null && dept.isNotEmpty && dept != 'All Departments') queryParams['dept'] = dept;

    final uri = Uri.parse('$_baseUrl/assignments').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    _checkStatus(response, 'fetchAssignments');

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(body['assignments'] as List);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Question Papers
  // ────────────────────────────────────────────────────────────────────────────

  /// Fetch question paper audit records (optional dept filter).
  Future<List<Map<String, dynamic>>> fetchQuestionPapers({String? dept}) async {
    final queryParams = <String, String>{};
    if (dept != null && dept.isNotEmpty && dept != 'All Departments') queryParams['dept'] = dept;

    final uri = Uri.parse('$_baseUrl/question-papers').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    _checkStatus(response, 'fetchQuestionPapers');

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(body['questionPapers'] as List);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Faculty Reports
  // ────────────────────────────────────────────────────────────────────────────

  /// Fetch faculty report audit records (optional dept & docType filters).
  Future<List<Map<String, dynamic>>> fetchFacultyReports({String? dept, String? docType}) async {
    final queryParams = <String, String>{};
    if (dept != null && dept.isNotEmpty && dept != 'All Departments') queryParams['dept'] = dept;
    if (docType != null && docType.isNotEmpty && docType != 'All Document Types') queryParams['docType'] = docType;

    final uri = Uri.parse('$_baseUrl/faculty-reports').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    _checkStatus(response, 'fetchFacultyReports');

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(body['facultyReports'] as List);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Research Records
  // ────────────────────────────────────────────────────────────────────────────

  /// Fetch research records (optional filters).
  Future<List<Map<String, dynamic>>> fetchResearch({String? dept, String? org, String? faculty, String? type, String? status}) async {
    final queryParams = <String, String>{};
    if (dept != null && dept.isNotEmpty && dept != 'All Departments') queryParams['dept'] = dept;
    if (org != null && org.isNotEmpty && org != 'All Organizations') queryParams['org'] = org;
    if (faculty != null && faculty.isNotEmpty && faculty != 'All Research Faculty') queryParams['faculty'] = faculty;
    if (type != null && type.isNotEmpty && type != 'All Types') queryParams['type'] = type;
    if (status != null && status.isNotEmpty && status != 'All Statuses') queryParams['status'] = status;

    final uri = Uri.parse('$_baseUrl/research').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    _checkStatus(response, 'fetchResearch');

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(body['research'] as List);
  }

  /// Create a new research record in PostgreSQL database.
  Future<Map<String, dynamic>> createResearch(Map<String, dynamic> data) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/research'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 10));
    _checkStatus(response, 'createResearch');

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Global Search
  // ────────────────────────────────────────────────────────────────────────────

  /// Perform cross-ERP global search over real PostgreSQL database tables.
  Future<List<Map<String, dynamic>>> searchGlobal(String query, {String? type}) async {
    final queryParams = <String, String>{'q': query};
    if (type != null && type.isNotEmpty && type != 'All Records') {
      queryParams['type'] = type;
    }

    final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: queryParams);
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    _checkStatus(response, 'searchGlobal');

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(body['results'] as List);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Audit Work Queue
  // ────────────────────────────────────────────────────────────────────────────

  /// Fetch auditor work queue tasks from real PostgreSQL database.
  Future<List<Map<String, dynamic>>> fetchWorkQueue() async {
    final uri = Uri.parse('$_baseUrl/work-queue');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    _checkStatus(response, 'fetchWorkQueue');

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(body['tasks'] as List);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Audit Cases
  // ────────────────────────────────────────────────────────────────────────────

  /// Fetch audit cases from real PostgreSQL database.
  Future<List<AuditCaseItem>> fetchAuditCases() async {
    final uri = Uri.parse('$_baseUrl/cases');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    _checkStatus(response, 'fetchAuditCases');

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final rawList = body['cases'] as List;
    return rawList.map((item) {
      final json = item as Map<String, dynamic>;
      return AuditCaseItem(
        caseId: (json['caseId'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        category: (json['category'] ?? 'Audit Case').toString(),
        targetRecordId: (json['targetRecordId'] ?? '').toString(),
        severity: (json['severity'] ?? 'Normal').toString(),
        assignedTo: (json['assignedTo'] ?? 'Unassigned').toString(),
        lifecycleStage: (json['lifecycleStage'] ?? 'Pending Verification').toString(),
        createdDate: (json['createdDate'] ?? '').toString(),
        description: (json['description'] ?? '').toString(),
      );
    }).toList();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────────────────────

  // ────────────────────────────────────────────────────────────────────────────
  // Alias Methods & Compatibility APIs
  // ────────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/dashboard')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {'kpis': {}, 'moduleProgress': [], 'recentActivities': [], 'criticalIssues': []};
  }

  Future<Map<String, dynamic>> getStudents({int limit = 500}) async {
    final list = await fetchStudents(limit: limit);
    return {'records': list};
  }

  Future<Map<String, dynamic>> getAssignments() async {
    final list = await fetchAssignments();
    return {'records': list};
  }

  Future<Map<String, dynamic>> getMarks([String? studentId]) async {
    final list = studentId != null ? await fetchMarks(studentId) : <Map<String, dynamic>>[];
    return {'records': list};
  }

  Future<Map<String, dynamic>> getFacultyReports() async {
    final list = await fetchFacultyReports();
    return {'records': list};
  }

  Future<Map<String, dynamic>> getQuestionPapers() async {
    final list = await fetchQuestionPapers();
    return {'records': list};
  }

  Future<Map<String, dynamic>> getResearch() async {
    final list = await fetchResearch();
    return {'records': list};
  }

  Future<Map<String, dynamic>> getEvidence() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/evidence')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {'records': []};
  }

  Future<Map<String, dynamic>> getAuditCases() async {
    try {
      final list = await fetchAuditCases();
      return {'records': list.map((c) => {
        'caseId': c.caseId,
        'title': c.title,
        'category': c.category,
        'targetRecordId': c.targetRecordId,
        'severity': c.severity,
        'assignedTo': c.assignedTo,
        'lifecycleStage': c.lifecycleStage,
        'createdDate': c.createdDate,
        'description': c.description,
      }).toList()};
    } catch (_) {
      return {'records': []};
    }
  }

  Future<Map<String, dynamic>> getAuditHistory() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/audit-history')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {'records': []};
  }

  Future<Map<String, dynamic>?> getAuditorProfile() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/profile')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['profile'] as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }

  // Read-only safe stubs for write actions (NO database operations executed)
  Future<void> verifyStudent(String regNo) async {}

  Future<void> flagIssue({required String recordId, required String reason, required String severity}) async {}

  Future<void> updateResearch(String id, Map<String, dynamic> data) async {}

  void _checkStatus(http.Response response, String context) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'HTTP ${response.statusCode}';
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        message = body['error']?.toString() ?? message;
      } catch (_) {}
      throw ApiException(context: context, message: message, statusCode: response.statusCode);
    }
  }
}

/// Exception thrown when the backend returns a non-2xx status.
class ApiException implements Exception {
  final String context;
  final String message;
  final int statusCode;

  const ApiException({
    required this.context,
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'ApiException[$context]: $statusCode — $message';
}
