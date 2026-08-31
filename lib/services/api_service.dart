import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl.endsWith('/') ? envUrl.substring(0, envUrl.length - 1) : envUrl;
    }
    if (kIsWeb) return 'http://13.204.53.209:5000/api';
    return 'http://10.0.2.2:5000/api';
  }
  static const Duration timeout = Duration(seconds: 30);

  String? _token;

  String? get token => _token;
  bool get isAuthenticated => _token != null;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers).timeout(timeout);
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http
        .post(uri, headers: _headers, body: jsonEncode(body))
        .timeout(timeout);
    return _handleResponse(response);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http
        .patch(uri, headers: _headers, body: jsonEncode(body))
        .timeout(timeout);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    final status = response.statusCode;
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (status >= 200 && status < 300) {
      return body;
    }

    final message = body is Map && body['error'] != null
        ? body['error'] as String
        : 'Request failed with status $status';

    throw Exception(message);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await post('/auth/login', {'email': email, 'password': password});
    final token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;
    _token = token;
    return {'token': token, 'user': user};
  }

  Future<void> logout() async {
    try {
      await post('/auth/logout', {});
    } finally {
      clearToken();
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    final data = await get('/auth/me');
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDashboard() async {
    final data = await get('/dashboard');
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStudents({
    String department = 'All Departments',
    String semester = 'All Semesters',
    String search = '',
    String status = 'All',
  }) async {
    final params = <String, String>{};
    if (department != 'All Departments') params['department'] = department;
    if (semester != 'All Semesters') params['semester'] = semester;
    if (search.isNotEmpty) params['search'] = search;
    if (status != 'All') params['status'] = status;
    final data = await get('/students', queryParams: params);
    return data as Map<String, dynamic>;
  }

  Future<void> verifyStudent(String regNo) async {
    await post('/students/$regNo/verify', {});
  }

  Future<Map<String, dynamic>> getAssignments({
    String department = 'All Departments',
    String search = '',
    String status = 'All',
  }) async {
    final params = <String, String>{};
    if (department != 'All Departments') params['department'] = department;
    if (search.isNotEmpty) params['search'] = search;
    if (status != 'All') params['status'] = status;
    final data = await get('/assignments', queryParams: params);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMarks({
    String department = 'All Departments',
    String search = '',
    String status = 'All',
  }) async {
    final params = <String, String>{};
    if (department != 'All Departments') params['department'] = department;
    if (search.isNotEmpty) params['search'] = search;
    if (status != 'All') params['status'] = status;
    final data = await get('/marks', queryParams: params);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getFacultyReports({
    String department = 'All Departments',
    String search = '',
    String status = 'All',
  }) async {
    final params = <String, String>{};
    if (department != 'All Departments') params['department'] = department;
    if (search.isNotEmpty) params['search'] = search;
    if (status != 'All') params['status'] = status;
    final data = await get('/faculty-reports', queryParams: params);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getQuestionPapers({
    String department = 'All Departments',
    String search = '',
    String status = 'All Statuses',
    String regulation = 'All Regulations',
  }) async {
    final params = <String, String>{};
    if (department != 'All Departments') params['department'] = department;
    if (search.isNotEmpty) params['search'] = search;
    if (status != 'All Statuses') params['status'] = status;
    if (regulation != 'All Regulations') params['regulation'] = regulation;
    final data = await get('/question-papers', queryParams: params);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getResearch({
    String department = 'All',
    String faculty = 'All',
    String status = 'All',
    String type = 'All',
    String search = '',
  }) async {
    final params = <String, String>{};
    if (department != 'All') params['department'] = department;
    if (faculty != 'All') params['faculty'] = faculty;
    if (status != 'All') params['status'] = status;
    if (type != 'All') params['type'] = type;
    if (search.isNotEmpty) params['search'] = search;
    final data = await get('/research', queryParams: params);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createResearch(Map<String, dynamic> body) async {
    final data = await post('/research', body);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateResearch(String id, Map<String, dynamic> body) async {
    final data = await patch('/research/$id', body);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getEvidence({
    String search = '',
    String docType = 'All',
  }) async {
    final params = <String, String>{};
    if (search.isNotEmpty) params['search'] = search;
    if (docType != 'All') params['docType'] = docType;
    final data = await get('/evidence', queryParams: params);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAuditCases({
    String search = '',
    String category = 'All Cases',
  }) async {
    final params = <String, String>{};
    if (search.isNotEmpty) params['search'] = search;
    if (category != 'All Cases') params['category'] = category;
    final data = await get('/audit-cases', queryParams: params);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAuditHistory({
    String search = '',
    String action = 'All Actions',
  }) async {
    final params = <String, String>{};
    if (search.isNotEmpty) params['search'] = search;
    if (action != 'All Actions') params['action'] = action;
    final data = await get('/audit-history', queryParams: params);
    return data as Map<String, dynamic>;
  }

  Future<List<dynamic>> globalSearch(String query) async {
    final params = <String, String>{'q': query};
    final data = await get('/search', queryParams: params);
    final records = data['records'] as List<dynamic>;
    return records;
  }

  Future<Map<String, dynamic>> flagIssue({
    required String recordId,
    required String reason,
    required String severity,
    String assignedRole = 'HOD / Department',
  }) async {
    final data = await post('/flag-issue', {
      'recordId': recordId,
      'reason': reason,
      'severity': severity,
      'assignedRole': assignedRole,
    });
    return data as Map<String, dynamic>;
  }
}
