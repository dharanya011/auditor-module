import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../widgets/status_badge.dart';
import '../widgets/action_modal.dart';
import '../widgets/responsive_row.dart';
import '../widgets/api_error_widget.dart';

class FacultyReportAuditView extends StatefulWidget {
  final AuditState state;

  const FacultyReportAuditView({super.key, required this.state});

  @override
  State<FacultyReportAuditView> createState() => _FacultyReportAuditViewState();
}

class _FacultyReportAuditViewState extends State<FacultyReportAuditView> {
  String _filterStatus = 'All';
  String _searchQuery = '';

  // 5 Audit Pattern Filters
  String _selectedDept = 'All Departments';
  String _selectedYear = 'All Years';
  String _selectedSem = 'All Semesters';
  String _selectedDocType = 'All Document Types';
  String _selectedVerType = 'All Verification Types';

  String _getRoleBasedPrompt(String role) {
    switch (role) {
      case 'Lead_Auditor':
        return 'Review faculty reports and question papers across departments, monitor compliance with regulations, and verify pending audit records.';
      case 'Department_Auditor':
        return 'Review faculty reports and question papers for your assigned department and verify records that are pending audit.';
      case 'HOD':
        return 'Monitor faculty report and question paper audits for your department and review records requiring verification or corrective action.';
      case 'Dean_Academics':
        return 'Monitor faculty report and question paper compliance across departments and review overall audit progress.';
      case 'Read_Only_Inspector':
        return 'Inspect faculty reports and question papers for regulatory compliance, quality standards, and verification status.';
      case 'System_Admin':
        return 'Monitor the complete Faculty Audit system, manage audit records, and review verification activity across departments.';
      default:
        return 'Review faculty reports and question papers across departments and verify records that are pending audit.';
    }
  }

  Widget _buildFilterCard(bool isMobile) {
    Widget buildFilterField({
      required String label,
      required String value,
      required List<String> options,
      required ValueChanged<String?> onChanged,
      required IconData icon,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: AppColors.accent),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isDense: true,
                isExpanded: true,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                selectedItemBuilder: (BuildContext context) {
                  return options.map((opt) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        opt,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList();
                },
                items: options.map((opt) {
                  return DropdownMenuItem<String>(
                    value: opt,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        opt,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        softWrap: false,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      );
    }

    final deptField = buildFilterField(
      label: 'Department',
      value: _selectedDept,
      icon: Icons.business_rounded,
      options: const ['All Departments', 'CSE', 'ECE', 'MECH', 'EEE', 'IT'],
      onChanged: (v) => setState(() => _selectedDept = v!),
    );

    final docTypeField = buildFilterField(
      label: 'Document Type',
      value: _selectedDocType,
      icon: Icons.description_rounded,
      options: const [
        'All Document Types',
        'Faculty Report',
        'Course Completion Report',
        'Academic Performance Report',
        'Question Paper',
        'Syllabus Document',
        'Research/Publication Report',
        'Other',
      ],
      onChanged: (v) => setState(() => _selectedDocType = v!),
    );

    final yearField = buildFilterField(
      label: 'Academic Year',
      value: _selectedYear,
      icon: Icons.calendar_today_rounded,
      options: const ['All Years', '2024 - 2025', '2025 - 2026', '2026 - 2027'],
      onChanged: (v) => setState(() => _selectedYear = v!),
    );

    final semField = buildFilterField(
      label: 'Semester',
      value: _selectedSem,
      icon: Icons.school_rounded,
      options: const ['All Semesters', 'Sem 1', 'Sem 2', 'Sem 3', 'Sem 4', 'Sem 5', 'Sem 6', 'Sem 7', 'Sem 8'],
      onChanged: (v) => setState(() => _selectedSem = v!),
    );

    final verStatusField = buildFilterField(
      label: 'Verification Status',
      value: _selectedVerType,
      icon: Icons.verified_user_rounded,
      options: const ['All Verification Types', 'Verified', 'Rejected', 'Under Review'],
      onChanged: (v) => setState(() => _selectedVerType = v!),
    );

    final bool hasActiveFilters = _selectedDept != 'All Departments' ||
        _selectedDocType != 'All Document Types' ||
        _selectedYear != 'All Years' ||
        _selectedSem != 'All Semesters' ||
        _selectedVerType != 'All Verification Types';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.filter_alt_rounded, size: 16, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Text(
                    'Faculty Report Audit Filters (${hasActiveFilters ? "Active" : "All"})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                  ),
                ],
              ),
              if (hasActiveFilters)
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDept = 'All Departments';
                      _selectedDocType = 'All Document Types';
                      _selectedYear = 'All Years';
                      _selectedSem = 'All Semesters';
                      _selectedVerType = 'All Verification Types';
                    });
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.refresh_rounded, size: 12, color: AppColors.accent),
                      SizedBox(width: 4),
                      Text('Reset Filters', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (isMobile) ...[
            Row(
              children: [
                Expanded(child: deptField),
                const SizedBox(width: 8),
                Expanded(child: docTypeField),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: yearField),
                const SizedBox(width: 8),
                Expanded(child: semField),
              ],
            ),
            const SizedBox(height: 8),
            verStatusField,
          ] else ...[
            Row(
              children: [
                Expanded(child: deptField),
                const SizedBox(width: 8),
                Expanded(child: docTypeField),
                const SizedBox(width: 8),
                Expanded(child: yearField),
                const SizedBox(width: 8),
                Expanded(child: semField),
                const SizedBox(width: 8),
                Expanded(child: verStatusField),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading faculty audit reports from database...', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    if (widget.state.backendError != null) {
      return ApiErrorWidget(
        errorMessage: widget.state.backendError!,
        onRetry: () => widget.state.loadFromApi(),
      );
    }

    // Filter records
    final reports = widget.state.facultyReports.where((f) {
      if (widget.state.departmentScope != null) {
        if (!f.department.toLowerCase().contains(widget.state.departmentScope!.toLowerCase()) &&
            !f.department.toUpperCase().contains(widget.state.departmentScope!.toUpperCase())) {
          return false;
        }
      }

      if (_filterStatus == 'Conflict' && !f.hasConflict) return false;
      if (_filterStatus == 'Verified' && f.status != 'Verified') return false;

      if (_selectedDept != 'All Departments') {
        final dept = f.department.toLowerCase();
        final d = _selectedDept.toUpperCase();
        if (d == 'CSE' && !dept.contains('computer science') && !dept.contains('cse')) return false;
        if (d == 'IT' && !dept.contains('information tech') && !dept.contains(' it')) return false;
        if (d == 'ECE' && !dept.contains('communication') && !dept.contains('ece')) return false;
        if (d == 'EEE' && !dept.contains('electrical') && !dept.contains('eee')) return false;
        if (d == 'MECH' && !dept.contains('mechanical') && !dept.contains('mech')) return false;
      }
      
      if (_selectedDocType != 'All Document Types') {
        final sel = _selectedDocType.toLowerCase();
        final rep = f.reportType.toLowerCase();
        if (_selectedDocType == 'Course Completion Report') {
          if (!rep.contains('course completion') && !rep.contains('completion')) return false;
        } else if (_selectedDocType == 'Academic Performance Report') {
          if (!rep.contains('academic performance') && !rep.contains('performance')) return false;
        } else if (_selectedDocType == 'Faculty Report') {
          if (!rep.contains('report') && !rep.contains('faculty')) return false;
        } else if (_selectedDocType == 'Research/Publication Report') {
          if (!rep.contains('research') && !rep.contains('publication')) return false;
        } else if (_selectedDocType == 'Question Paper') {
          if (!rep.contains('question') && !rep.contains('paper')) return false;
        } else if (_selectedDocType == 'Syllabus Document') {
          if (!rep.contains('syllabus')) return false;
        } else if (_selectedDocType == 'Other') {
          if (rep.contains('completion') || rep.contains('performance') || rep.contains('research')) return false;
        } else {
          if (!rep.contains(sel) && !sel.contains(rep)) return false;
        }
      }

      if (_selectedYear != 'All Years') {
        final ayClean = f.academicYear.replaceAll(' ', '');
        final selAyClean = _selectedYear.replaceAll(' ', '');
        if (!ayClean.contains(selAyClean) && !selAyClean.contains(ayClean)) return false;
      }

      if (_selectedSem != 'All Semesters') {
        final semNum = int.tryParse(_selectedSem.replaceAll(RegExp(r'[^0-9]'), ''));
        if (semNum != null && f.semester != semNum) return false;
      }
      
      if (_selectedVerType != 'All Verification Types') {
        if (_selectedVerType == 'Verified' && f.status != 'Verified') return false;
        if (_selectedVerType == 'Rejected' && f.status != 'Rejected') return false;
        if (_selectedVerType == 'Under Review' && f.status != 'Under Review' && f.status != 'Pending') return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = f.id.toLowerCase().contains(q) ||
            f.facultyName.toLowerCase().contains(q) ||
            f.department.toLowerCase().contains(q) ||
            f.reportType.toLowerCase().contains(q) ||
            f.academicYear.toLowerCase().contains(q);
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Faculty Report & Performance Audit',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getRoleBasedPrompt(widget.state.userRole),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
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
            _buildKpiCard('Total Reports Audited', '${widget.state.facultyReports.length}', Icons.badge_outlined, const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
            _buildKpiCard('Verified Reports', '${widget.state.facultyReports.where((f) => f.status == "Verified").length}', Icons.check_circle_outline_rounded, const Color(0xFF10B981), const Color(0xFFECFDF5)),
            _buildKpiCard('Biometric Conflicts', '${widget.state.facultyReports.where((f) => f.hasConflict).length} Flags', Icons.fingerprint_rounded, const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
            _buildKpiCard('Syllabus Gaps Flagged', '${widget.state.facultyReports.where((f) => f.syllabusCompletionPercent < 85).length} Reports', Icons.error_outline_rounded, const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
          ],
        ),

        const SizedBox(height: 20),

        const SizedBox(height: 20),

        // 5 Pattern Filters
        LayoutBuilder(builder: (context, constraints) => _buildFilterCard(constraints.maxWidth < 600)),

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

        if (reports.isEmpty)
          const ApiEmptyWidget(
            message: 'No Faculty Report Audit Records Found',
            hint: 'The PostgreSQL database returned 0 faculty report audit entries.',
          ),

        // Data Table — Desktop scroll table; Mobile card-per-record
        if (reports.isNotEmpty)
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
                Text(
                  label,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
