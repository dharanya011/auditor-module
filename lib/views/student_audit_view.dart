import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../widgets/status_badge.dart';
import '../widgets/action_modal.dart';
import '../widgets/evidence_modal.dart';
import '../models/models.dart';

class StudentAuditView extends StatefulWidget {
  final AuditState state;

  const StudentAuditView({super.key, required this.state});

  @override
  State<StudentAuditView> createState() => _StudentAuditViewState();
}

class _StudentAuditViewState extends State<StudentAuditView> {
  int _selectedStudentIndex = 0;
  String _activeTab = '360° Verification Modules';

  @override
  Widget build(BuildContext context) {
    final student = widget.state.studentRecords[_selectedStudentIndex];
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;

    return ListView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      children: [
        // Title Bar & Student Selector Dropdown
        if (!isMobile)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Student Audit — 360° Record Verification',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Comprehensive 360-degree verification of student personal, academic, attendance, and result records.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Student Dropdown Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_search_rounded, color: AppColors.accent, size: 18),
                    const SizedBox(width: 8),
                    const Text('Select Student: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedStudentIndex,
                        isDense: true,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 12),
                        items: List.generate(widget.state.studentRecords.length, (idx) {
                          final s = widget.state.studentRecords[idx];
                          return DropdownMenuItem(
                            value: idx,
                            child: Text('${s.registerNo} - ${s.name}'),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedStudentIndex = val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Student Audit — 360° Verification',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_search_rounded, color: AppColors.accent, size: 18),
                    const SizedBox(width: 8),
                    const Text('Student: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedStudentIndex,
                          isDense: true,
                          isExpanded: true,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 12),
                          items: List.generate(widget.state.studentRecords.length, (idx) {
                            final s = widget.state.studentRecords[idx];
                            return DropdownMenuItem(
                              value: idx,
                              child: Text('${s.registerNo} - ${s.name}', overflow: TextOverflow.ellipsis),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedStudentIndex = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

        const SizedBox(height: 12),

        // Executive Student Profile Header Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              student.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              StatusBadge(status: student.status, isCompact: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Dept of ${student.department} • Sem ${student.semester}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStatMetricCard(
                          label: 'CGPA',
                          value: '${student.cgpa} / 10.0',
                          icon: Icons.grade_rounded,
                          color: const Color(0xFF4F46E5),
                          bgColor: const Color(0xFFEEF2FF),
                        ),
                        _buildStatMetricCard(
                          label: 'Attendance',
                          value: '${student.attendance}%',
                          icon: Icons.fingerprint_rounded,
                          color: student.attendance >= 75 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          bgColor: student.attendance >= 75 ? const Color(0xFFECFDF5) : const Color(0xFFFEE2E2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.state.canVerify
                                ? () => widget.state.verifyStudentRecord(student.registerNo)
                                : null,
                            icon: const Icon(Icons.check_circle_rounded, size: 16),
                            label: const Text('Verify Record', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: widget.state.canFlagIssue
                              ? () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => ActionModal(
                                      recordId: student.registerNo,
                                      actionType: 'Flag Issue',
                                      state: widget.state,
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.flag_rounded, size: 14, color: Color(0xFFDC2626)),
                          label: const Text('Flag', style: TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFDC2626))),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Column 1: Student Avatar Circle
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          student.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Column 2: Name & Details & Metrics Chips
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                student.name,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              StatusBadge(status: student.status, isCompact: true),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  'Reg No: ${student.registerNo}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace', color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dept of ${student.department} • Semester ${student.semester} (AY 2025-2026)',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 12),

                          // Metric Chips Row
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildStatMetricCard(
                                label: 'CGPA Score',
                                value: '${student.cgpa} / 10.0',
                                icon: Icons.grade_rounded,
                                color: const Color(0xFF4F46E5),
                                bgColor: const Color(0xFFEEF2FF),
                              ),
                              _buildStatMetricCard(
                                label: 'Biometric Attendance',
                                value: '${student.attendance}% Logged',
                                icon: Icons.fingerprint_rounded,
                                color: student.attendance >= 75 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                bgColor: student.attendance >= 75 ? const Color(0xFFECFDF5) : const Color(0xFFFEE2E2),
                              ),
                              _buildStatMetricCard(
                                label: 'Earned Credits',
                                value: '124 / 160 Credits',
                                icon: Icons.stars_rounded,
                                color: const Color(0xFF3B82F6),
                                bgColor: const Color(0xFFEFF6FF),
                              ),
                              _buildStatMetricCard(
                                label: 'Standing Backlogs',
                                value: '0 Active Backlogs',
                                icon: Icons.verified_rounded,
                                color: const Color(0xFF059669),
                                bgColor: const Color(0xFFECFDF5),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Column 3: Action Buttons
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: widget.state.canVerify
                              ? () => widget.state.verifyStudentRecord(student.registerNo)
                              : null,
                          icon: const Icon(Icons.check_circle_rounded, size: 16),
                          label: const Text('Verify Entire 360° Record'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: widget.state.canFlagIssue
                              ? () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => ActionModal(
                                      recordId: student.registerNo,
                                      actionType: 'Flag Issue',
                                      state: widget.state,
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.flag_rounded, size: 14, color: Color(0xFFDC2626)),
                          label: const Text('Flag Discrepancy', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            side: const BorderSide(color: Color(0xFFDC2626)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextButton.icon(
                          onPressed: () {
                            widget.state.showToast('Generating 360° Audit PDF report for ${student.registerNo}...');
                          },
                          icon: const Icon(Icons.picture_as_pdf_rounded, size: 14, color: AppColors.textSecondary),
                          label: const Text('Download 360° Audit Report', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        ),
                      ],
                    ),
                  ],
                ),
        ),

        const SizedBox(height: 12),

        // Navigation Tabs Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['360° Verification Modules', 'Attendance Log Timeline', 'Internal Marks Breakdown', 'Evidence Attachments'].map((tab) {
              final isSel = _activeTab == tab;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(tab),
                  selected: isSel,
                  onSelected: (val) {
                    if (val) setState(() => _activeTab = tab);
                  },
                  selectedColor: AppColors.accent,
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                    fontSize: 12,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        // Active Tab View Content
        _buildActiveTabContent(student),
      ],
    );
  }

  Widget _buildActiveTabContent(StudentAuditRecord student) {
    switch (_activeTab) {
      case 'Attendance Log Timeline':
        return _buildAttendanceTab(student);
      case 'Internal Marks Breakdown':
        return _buildMarksTab(student);
      case 'Evidence Attachments':
        return _buildEvidenceTab(student);
      case '360° Verification Modules':
      default:
        return _buildModulesGrid(student);
    }
  }

  Widget _buildModulesGrid(StudentAuditRecord student) {
    final modules = [
      {
        'title': 'Personal & Institutional Records',
        'subtitle': 'Aadhaar, Birth Certificate, Admission Quota, and Caste Category records verified with registrar database.',
        'status': 'Verified',
        'icon': Icons.badge_outlined,
        'iconBg': const Color(0xFFEEF2FF),
        'iconColor': const Color(0xFF4F46E5),
        'evidenceName': 'EVD-8890_Identity_Verification.pdf',
      },
      {
        'title': 'Biometric Attendance Logs',
        'subtitle': '${student.attendance}% biometric classroom attendance matched with hostel & institutional gate logs.',
        'status': student.attendance >= 75 ? 'Verified' : 'Discrepancy',
        'icon': Icons.fingerprint_rounded,
        'iconBg': student.attendance >= 75 ? const Color(0xFFECFDF5) : const Color(0xFFFEE2E2),
        'iconColor': student.attendance >= 75 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        'evidenceName': 'EVD-8892_Biometric_Log_S5.pdf',
      },
      {
        'title': 'Internal Assessment Marks (CAT 1 & 2)',
        'subtitle': 'CAT 1 & CAT 2 internal marks cross-checked with scanned raw answer sheets and COE mark registers.',
        'status': 'Verified',
        'icon': Icons.analytics_outlined,
        'iconBg': const Color(0xFFEFF6FF),
        'iconColor': const Color(0xFF3B82F6),
        'evidenceName': 'EVD-8891_CAT1_AnswerSheet_Scan.pdf',
      },
      {
        'title': 'Assignments & Laboratory Reports',
        'subtitle': '5 of 5 assignment submissions evaluated with cryptographic S3 file hash verification.',
        'status': student.registerNo == '23IT045' ? 'Discrepancy' : 'Verified',
        'icon': Icons.assignment_turned_in_outlined,
        'iconBg': student.registerNo == '23IT045' ? const Color(0xFFFEE2E2) : const Color(0xFFECFDF5),
        'iconColor': student.registerNo == '23IT045' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        'evidenceName': 'EVD-8894_Assignment_Submissions.pdf',
      },
      {
        'title': 'Semester End Results & CoE Ledger',
        'subtitle': 'Controller of Examinations result ledger verified against published grade sheet and university portal.',
        'status': 'Verified',
        'icon': Icons.description_outlined,
        'iconBg': const Color(0xFFFEF3C7),
        'iconColor': const Color(0xFFD97706),
        'evidenceName': 'EVD-8895_CoE_GradeLedger.pdf',
      },
      {
        'title': 'Mini Projects & Certificates',
        'subtitle': 'Mini project source code repository, viva evaluation report, and industry internship certificates.',
        'status': 'Verified',
        'icon': Icons.folder_zip_outlined,
        'iconBg': const Color(0xFFF5F3FF),
        'iconColor': const Color(0xFF8B5CF6),
        'evidenceName': 'EVD-8896_MiniProject_CodeReport.pdf',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 850;
        if (isWide) {
          // 2-Column Responsive Layout with tight content height
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    for (int i = 0; i < modules.length; i += 2) ...[
                      _buildModuleCard(
                        title: modules[i]['title'] as String,
                        subtitle: modules[i]['subtitle'] as String,
                        status: modules[i]['status'] as String,
                        icon: modules[i]['icon'] as IconData,
                        iconBg: modules[i]['iconBg'] as Color,
                        iconColor: modules[i]['iconColor'] as Color,
                        evidenceName: modules[i]['evidenceName'] as String,
                      ),
                      if (i + 2 < modules.length) const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    for (int i = 1; i < modules.length; i += 2) ...[
                      _buildModuleCard(
                        title: modules[i]['title'] as String,
                        subtitle: modules[i]['subtitle'] as String,
                        status: modules[i]['status'] as String,
                        icon: modules[i]['icon'] as IconData,
                        iconBg: modules[i]['iconBg'] as Color,
                        iconColor: modules[i]['iconColor'] as Color,
                        evidenceName: modules[i]['evidenceName'] as String,
                      ),
                      if (i + 2 < modules.length) const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ],
          );
        } else {
          // 1-Column Responsive Mobile/Tablet Layout
          return Column(
            children: [
              for (int i = 0; i < modules.length; i++) ...[
                _buildModuleCard(
                  title: modules[i]['title'] as String,
                  subtitle: modules[i]['subtitle'] as String,
                  status: modules[i]['status'] as String,
                  icon: modules[i]['icon'] as IconData,
                  iconBg: modules[i]['iconBg'] as Color,
                  iconColor: modules[i]['iconColor'] as Color,
                  evidenceName: modules[i]['evidenceName'] as String,
                ),
                if (i < modules.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }
      },
    );
  }

  Widget _buildAttendanceTab(StudentAuditRecord student) {
    final logs = [
      {'month': 'August 2026', 'held': 48, 'attended': 46, 'pct': '95.8%', 'status': 'Verified'},
      {'month': 'July 2026', 'held': 52, 'attended': 49, 'pct': '94.2%', 'status': 'Verified'},
      {'month': 'June 2026', 'held': 44, 'attended': 41, 'pct': '93.1%', 'status': 'Verified'},
      {'month': 'May 2026', 'held': 50, 'attended': 47, 'pct': '94.0%', 'status': 'Verified'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.tableHeaderBg),
          columnSpacing: 20,
          horizontalMargin: 20,
          columns: const [
            DataColumn(label: Text('MONTH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('CLASSES HELD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('ATTENDED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('PERCENTAGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('BIOMETRIC MATCH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ],
          rows: logs.map((l) {
            return DataRow(
              cells: [
                DataCell(Text(l['month'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                DataCell(Text('${l['held']} Hours', style: const TextStyle(fontSize: 12))),
                DataCell(Text('${l['attended']} Hours', style: const TextStyle(fontSize: 12))),
                DataCell(Text(l['pct'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981), fontSize: 12))),
                DataCell(StatusBadge(status: l['status'].toString(), isCompact: true)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMarksTab(StudentAuditRecord student) {
    final marks = [
      {'subject': '23CS501 Data Structures', 'cat1': '88 / 100', 'cat2': '92 / 100', 'assignment': '10 / 10', 'grade': 'O (Outstanding)', 'status': 'Verified'},
      {'subject': '23CS502 Database Systems', 'cat1': '82 / 100', 'cat2': '85 / 100', 'assignment': '9 / 10', 'grade': 'A+ (Excellent)', 'status': 'Verified'},
      {'subject': '23CS503 Operating Systems', 'cat1': '78 / 100', 'cat2': '84 / 100', 'assignment': '9 / 10', 'grade': 'A+ (Excellent)', 'status': 'Verified'},
      {'subject': '23CS504 Web Engineering', 'cat1': '90 / 100', 'cat2': '94 / 100', 'assignment': '10 / 10', 'grade': 'O (Outstanding)', 'status': 'Verified'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.tableHeaderBg),
          columnSpacing: 20,
          horizontalMargin: 20,
          columns: const [
            DataColumn(label: Text('SUBJECT CODE & TITLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('CAT 1 MARKS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('CAT 2 MARKS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('ASSIGNMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('PREDICTED GRADE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('AUDIT STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ],
          rows: marks.map((m) {
            return DataRow(
              cells: [
                DataCell(Text(m['subject'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                DataCell(Text(m['cat1'].toString(), style: const TextStyle(fontSize: 12))),
                DataCell(Text(m['cat2'].toString(), style: const TextStyle(fontSize: 12))),
                DataCell(Text(m['assignment'].toString(), style: const TextStyle(fontSize: 12))),
                DataCell(Text(m['grade'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent, fontSize: 12))),
                DataCell(StatusBadge(status: m['status'].toString(), isCompact: true)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEvidenceTab(StudentAuditRecord student) {
    final evidences = [
      {'id': 'EVD-8890', 'type': 'Identity & Caste Certificate', 'file': 'EVD-8890_Identity_Verification.pdf', 'size': '2.4 MB', 'status': 'Verified'},
      {'id': 'EVD-8892', 'type': 'Biometric Classroom Logs', 'file': 'EVD-8892_Biometric_Log_S5.pdf', 'size': '4.1 MB', 'status': 'Verified'},
      {'id': 'EVD-8891', 'type': 'CAT Answer Sheets Scan', 'file': 'EVD-8891_CAT1_AnswerSheet_Scan.pdf', 'size': '8.2 MB', 'status': 'Verified'},
      {'id': 'EVD-8895', 'type': 'CoE Official Grade Sheet', 'file': 'EVD-8895_CoE_GradeLedger.pdf', 'size': '1.8 MB', 'status': 'Verified'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.tableHeaderBg),
          columnSpacing: 20,
          horizontalMargin: 20,
          columns: const [
            DataColumn(label: Text('EVIDENCE ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('DOCUMENT TYPE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('FILE NAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('SIZE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(label: Text('ACTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ],
          rows: evidences.map((e) {
            return DataRow(
              cells: [
                DataCell(Text(e['id'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent, fontFamily: 'monospace'))),
                DataCell(Text(e['type'].toString(), style: const TextStyle(fontSize: 12))),
                DataCell(Text(e['file'].toString(), style: const TextStyle(fontSize: 12, fontFamily: 'monospace'))),
                DataCell(Text(e['size'].toString(), style: const TextStyle(fontSize: 12))),
                DataCell(StatusBadge(status: e['status'].toString(), isCompact: true)),
                DataCell(
                  OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => EvidenceModal(
                          item: EvidenceItem(
                            evidenceId: e['id'].toString(),
                            recordId: student.registerNo,
                            recordType: e['type'].toString(),
                            uploadedBy: 'ERP Academic Registrar',
                            uploadDate: '2026-08-18 10:00',
                            documentType: 'PDF Evidence',
                            version: 'v1.0',
                            fileName: e['file'].toString(),
                            fileSize: e['size'].toString(),
                            status: e['status'].toString(),
                          ),
                          onClose: () => Navigator.pop(ctx),
                        ),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 14),
                    label: const Text('View PDF', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
              Text(value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String subtitle,
    required String status,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String evidenceName,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    StatusBadge(status: status, isCompact: true),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.35),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => EvidenceModal(
                      item: EvidenceItem(
                        evidenceId: 'EVD-8890',
                        recordId: widget.state.studentRecords[_selectedStudentIndex].registerNo,
                        recordType: title,
                        uploadedBy: 'ERP Academic Registrar',
                        uploadDate: '2026-08-18 10:00',
                        documentType: 'PDF Evidence',
                        version: 'v1.0',
                        fileName: evidenceName,
                        fileSize: '3.4 MB',
                        status: status,
                      ),
                      onClose: () => Navigator.pop(ctx),
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 14),
                label: const Text('View Evidence PDF', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: widget.state.canVerify
                    ? () => widget.state.showToast('$title verified successfully!')
                    : null,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 14),
                label: const Text('Verify Module', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
