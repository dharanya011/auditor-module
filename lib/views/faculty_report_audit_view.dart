import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../widgets/status_badge.dart';
import '../widgets/action_modal.dart';
import '../widgets/responsive_row.dart';

class FacultyReportAuditView extends StatefulWidget {
  final AuditState state;

  const FacultyReportAuditView({super.key, required this.state});

  @override
  State<FacultyReportAuditView> createState() => _FacultyReportAuditViewState();
}

class _FacultyReportAuditViewState extends State<FacultyReportAuditView> {
  String _filterStatus = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Filter records
    final reports = widget.state.facultyReports.where((f) {
      if (_filterStatus == 'Conflict' && !f.hasConflict) return false;
      if (_filterStatus == 'Verified' && f.status != 'Verified') return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = f.id.toLowerCase().contains(q) ||
            f.facultyName.toLowerCase().contains(q) ||
            f.department.toLowerCase().contains(q) ||
            f.reportType.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Title Bar & Action Trigger
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Faculty Report & Performance Audit',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cross-verifying faculty academic reports against biometric classroom logs and syllabus completion metrics.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => widget.state.showToast('Re-checking biometric attendance against faculty logs...'),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Re-check Biometrics'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // KPI Summary Cards Row (Responsive)
        ResponsiveRow(
          spacing: 14,
          children: [
            _buildKpiCard('Total Reports Audited', '840', Icons.badge_outlined, const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
            _buildKpiCard('Verified Reports', '780', Icons.check_circle_outline_rounded, const Color(0xFF10B981), const Color(0xFFECFDF5)),
            _buildKpiCard('Biometric Conflicts', '42 Flags', Icons.fingerprint_rounded, const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
            _buildKpiCard('Syllabus Gaps Flagged', '18 Reports', Icons.error_outline_rounded, const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
          ],
        ),

        const SizedBox(height: 20),

        // Filter Toolbar Card (Responsive Wrap)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 320,
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                    hintText: 'Search by Faculty Name, Report ID, Department...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip('All Reports', 'All'),
                  _buildFilterChip('Biometric Conflicts', 'Conflict'),
                  _buildFilterChip('Verified Only', 'Verified'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Data Table — Desktop scroll table; Mobile card-per-record
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            if (isMobile) {
              return Column(
                children: reports.map((f) => _buildMobileCard(f)).toList(),
              );
            }
            return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 1350,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.tableHeaderBg),
                headingRowHeight: 52,
                dataRowMinHeight: 72,
                dataRowMaxHeight: 72,
                horizontalMargin: 24,
                columnSpacing: 36,
                columns: const [
                  DataColumn(
                    label: SizedBox(
                      width: 200,
                      child: Text('REPORT ID & FACULTY', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 160,
                      child: Text('DEPARTMENT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 180,
                      child: Text('REPORT TYPE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 200,
                      child: Text('REPORTED VS BIOMETRIC', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 140,
                      child: Text('SYLLABUS COVERAGE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 120,
                      child: Text('MENTORING LOGS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 140,
                      child: Text('CONFLICT STATUS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 120,
                      child: Text('ACTION', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                ],
                rows: reports.map((f) {
                  return DataRow(
                    cells: [
                      // Report ID & Faculty Name
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: AppColors.accentLight,
                                child: Text(
                                  f.facultyName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      f.facultyName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      f.id,
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Department
                      DataCell(
                        SizedBox(
                          width: 160,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              f.department,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),

                      // Report Type
                      DataCell(
                        SizedBox(
                          width: 180,
                          child: Text(f.reportType, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        ),
                      ),

                      // Reported vs Biometric Attendance
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: f.hasConflict ? const Color(0xFFFEE2E2) : const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                              border: f.hasConflict ? Border.all(color: const Color(0xFFEF4444)) : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  f.hasConflict ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                                  size: 14,
                                  color: f.hasConflict ? const Color(0xFFDC2626) : const Color(0xFF10B981),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${f.reportedAttendance}% vs ${f.actualAttendance}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: f.hasConflict ? const Color(0xFFDC2626) : const Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Syllabus Coverage Percent
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: f.syllabusCompletionPercent / 100.0,
                                    backgroundColor: AppColors.border,
                                    color: f.syllabusCompletionPercent >= 95 ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('${f.syllabusCompletionPercent}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),

                      // Mentoring Sessions Logged
                      DataCell(
                        SizedBox(
                          width: 120,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              '${f.mentoringSessionsLogged} Sessions',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.accent),
                            ),
                          ),
                        ),
                      ),

                      // Conflict Status Badge
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: StatusBadge(status: f.status, isCompact: true),
                        ),
                      ),

                      // Action Button
                      DataCell(
                        SizedBox(
                          width: 120,
                          child: ElevatedButton.icon(
                            onPressed: (f.hasConflict ? widget.state.canFlagIssue : widget.state.canVerify)
                                ? () {
                                    if (f.hasConflict) {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => ActionModal(recordId: f.id, actionType: 'Flag Issue', state: widget.state),
                                      );
                                    } else {
                                      widget.state.showToast('Faculty report ${f.id} verified!');
                                    }
                                  }
                                : null,
                            icon: Icon(f.hasConflict ? Icons.warning_rounded : Icons.check_circle_rounded, size: 14),
                            label: Text(f.hasConflict ? 'Inspect' : 'Verify'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: f.hasConflict ? const Color(0xFFDC2626) : AppColors.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
          },
        ),
      ],
    );
  }

  Widget _buildMobileCard(dynamic f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: f.hasConflict ? const Color(0xFFEF4444) : AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.accentLight,
                child: Text(
                  f.facultyName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.facultyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(f.id, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'monospace')),
                  ],
                ),
              ),
              StatusBadge(status: f.status, isCompact: true),
            ],
          ),
          const Divider(height: 20),
          _mobileRow('Department', f.department),
          _mobileRow('Report Type', f.reportType),
          _mobileRow('Attendance', '${f.reportedAttendance}% reported / ${f.actualAttendance}% biometric', highlight: f.hasConflict),
          _mobileRow('Syllabus', '${f.syllabusCompletionPercent}% complete'),
          _mobileRow('Mentoring', '${f.mentoringSessionsLogged} sessions'),
        ],
      ),
    );
  }

  Widget _mobileRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600))),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: highlight ? const Color(0xFFDC2626) : AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String key) {
    final isSel = _filterStatus == key;
    return InkWell(
      onTap: () => setState(() => _filterStatus = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? AppColors.accent : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSel ? AppColors.accent : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSel ? Colors.white : AppColors.textPrimary,
            fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
