import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme/app_colors.dart';
import 'providers/audit_state.dart';
import 'widgets/sidebar.dart';
import 'widgets/header.dart';

import 'views/dashboard_view.dart';
import 'views/work_queue_view.dart';
import 'views/global_search_view.dart';
import 'views/student_audit_view.dart';
import 'views/assignment_audit_view.dart';
import 'views/marks_audit_view.dart';
import 'views/faculty_report_audit_view.dart';
import 'views/question_paper_audit_view.dart';
import 'views/research_audit_view.dart';
import 'views/evidence_repository_view.dart';
import 'views/audit_cases_view.dart';
import 'views/audit_history_view.dart';
import 'views/ai_audit_view.dart';
import 'views/reports_view.dart';
import 'views/profile_view.dart';

void main() {
  runApp(const KSRCEAuditorApp());
}

class KSRCEAuditorApp extends StatefulWidget {
  const KSRCEAuditorApp({super.key});

  @override
  State<KSRCEAuditorApp> createState() => _KSRCEAuditorAppState();
}

class _KSRCEAuditorAppState extends State<KSRCEAuditorApp> {
  final AuditState _auditState = AuditState();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _auditState,
      builder: (context, child) {
        return MaterialApp(
          title: 'KSRCE ERP - Auditor Module',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.accent,
              surface: AppColors.surface,
            ),
            textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
            scaffoldBackgroundColor: AppColors.background,
          ),
          home: Scaffold(
            body: Stack(
              children: [
                Row(
                  children: [
                    // Sidebar Navigation Shell
                    Sidebar(state: _auditState),

                    // Main Right Content Canvas
                    Expanded(
                      child: Column(
                        children: [
                          // Top Header
                          Header(state: _auditState),

                          // Dynamic View Router Canvas
                          Expanded(
                            child: _buildActiveView(_auditState),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Floating Toast Notification Overlay
                if (_auditState.notificationToast != null)
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Color(0xFF38BDF8), size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _auditState.notificationToast!,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveView(AuditState state) {
    switch (state.activeModule) {
      case 'Dashboard':
        return DashboardView(state: state);
      case 'Audit Work Queue':
        return WorkQueueView(state: state);
      case 'Global Search':
        return GlobalSearchView(state: state);
      case 'Student Audit':
        return StudentAuditView(state: state);
      case 'Assignment Audit':
        return AssignmentAuditView(state: state);
      case 'Marks Audit':
        return MarksAuditView(state: state);
      case 'Faculty Report Audit':
        return FacultyReportAuditView(state: state);
      case 'Question Paper Audit':
        return QuestionPaperAuditView(state: state);
      case 'Research Audit':
        return ResearchAuditView(state: state);
      case 'Evidence Repository':
        return EvidenceRepositoryView(state: state);
      case 'Audit Cases':
        return AuditCasesView(state: state);
      case 'Audit History':
        return AuditHistoryView(state: state);
      case 'AI-Assisted Audit':
        return AIAuditView(state: state);
      case 'Audit Reports':
        return ReportsView(state: state);
      case 'Auditor Profile':
        return ProfileView(state: state);
      default:
        return DashboardView(state: state);
    }
  }
}
