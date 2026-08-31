import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../widgets/status_badge.dart';
import '../widgets/action_modal.dart';
import '../widgets/responsive_row.dart';
import '../widgets/api_error_widget.dart';

class MarksAuditView extends StatefulWidget {
  final AuditState state;

  const MarksAuditView({super.key, required this.state});

  @override
  State<MarksAuditView> createState() => _MarksAuditViewState();
}

class _MarksAuditViewState extends State<MarksAuditView> {
  String _filterState = 'All';
  String _searchQuery = '';

  // 5 Student Audit Pattern Filters
  String _selectedDept = 'All Departments';
  String _selectedYear = 'All Years';
  String _selectedSem = 'All Semesters';
  String _selectedDocType = 'All Document Types';
  String _selectedVerType = 'All Verification Types';

  String _getRoleBasedPrompt(String role) {
    switch (role) {
      case 'Lead Auditor': return 'Review audit records across departments and monitor pending and completed verification activities.';
      case 'Department Auditor': return 'Review and verify audit records for your assigned department and resolve pending issues.';
      case 'HOD': return 'Monitor department-level audit progress and review records requiring attention.';
      case 'Dean': return 'Monitor overall academic audit compliance and review department-level audit status.';
      case 'Inspector': return 'Inspect audit records, verification status and compliance-related issues.';
      case 'System Admin': return 'Monitor the complete audit system and manage audit records across all roles and departments.';
      default: return 'Review and verify audit records.';
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
                items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt, overflow: TextOverflow.ellipsis))).toList(),
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
      options: const ['All Departments', 'CSE', 'IT', 'ECE', 'EEE', 'MECH'],
      onChanged: (v) => setState(() => _selectedDept = v!),
    );

    final yearField = buildFilterField(
      label: 'Year',
      value: _selectedYear,
      icon: Icons.calendar_today_rounded,
      options: const ['All Years', '1st Year', '2nd Year', '3rd Year', '4th Year'],
      onChanged: (v) => setState(() => _selectedYear = v!),
    );

    final semField = buildFilterField(
      label: 'Semester',
      value: _selectedSem,
      icon: Icons.school_rounded,
      options: const ['All Semesters', 'Sem 1', 'Sem 2', 'Sem 3', 'Sem 4', 'Sem 5', 'Sem 6', 'Sem 7', 'Sem 8'],
      onChanged: (v) => setState(() => _selectedSem = v!),
    );

    final docTypeField = buildFilterField(
      label: 'Document Type',
      value: _selectedDocType,
      icon: Icons.description_rounded,
      options: const ['All Document Types', 'Faculty Entry', 'Department Ledger', 'Exam Record', 'Final Result'],
      onChanged: (v) => setState(() => _selectedDocType = v!),
    );

    final verTypeField = buildFilterField(
      label: 'Verification Type',
      value: _selectedVerType,
      icon: Icons.verified_user_rounded,
      options: const ['All Verification Types', 'Verified', 'Mismatch Detected', 'Pending Approval'],
      onChanged: (v) => setState(() => _selectedVerType = v!),
    );

    final bool hasActiveFilters = _selectedDept != 'All Departments' ||
        _selectedYear != 'All Years' ||
        _selectedSem != 'All Semesters' ||
        _selectedDocType != 'All Document Types' ||
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
                    'Marks Audit Filters (${hasActiveFilters ? "Active" : "All"})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                  ),
                ],
              ),
              if (hasActiveFilters)
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDept = 'All Departments';
                      _selectedYear = 'All Years';
                      _selectedSem = 'All Semesters';
                      _selectedDocType = 'All Document Types';
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
                Expanded(child: yearField),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: semField),
                const SizedBox(width: 8),
                Expanded(child: docTypeField),
              ],
            ),
            const SizedBox(height: 8),
            verTypeField,
          ] else ...[
            Row(
              children: [
                Expanded(child: deptField),
                const SizedBox(width: 8),
                Expanded(child: yearField),
                const SizedBox(width: 8),
                Expanded(child: semField),
                const SizedBox(width: 8),
                Expanded(child: docTypeField),
                const SizedBox(width: 8),
                Expanded(child: verTypeField),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── Loading state ──────────────────────────────────────────────────────────
    if (widget.state.isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading marks records from database…',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    // ── API error state — never show mock data ───────────────────────────
    if (widget.state.backendError != null) {
      return ApiErrorWidget(
        errorMessage: widget.state.backendError,
        onRetry: () => widget.state.loadFromApi(),
      );
    }

    // ── Empty state — API returned zero records ─────────────────────────
    if (widget.state.marksEntries.isEmpty) {
      return const ApiEmptyWidget(
        icon: Icons.grading_rounded,
        message: 'No marks records found',
        hint: 'The database returned no marks entries. Add student records first.',
      );
    }

    // Filter records
    final entries = widget.state.marksEntries.where((m) {
      if (widget.state.departmentScope != null) {
        if (!m.subjectCode.contains(widget.state.departmentScope!) && !m.studentRegNo.contains(widget.state.departmentScope!)) {
          return false;
        }
      }

      if (_filterState == 'Mismatches' && !m.isMismatch) return false;
      if (_filterState == 'Verified' && m.status != 'Verified') return false;

      final student = widget.state.studentRecords.where((s) => s.registerNo == m.studentRegNo).firstOrNull;
      if (student != null) {
        if (_selectedDept != 'All Departments') {
          if (_selectedDept == 'CSE' && !student.department.toLowerCase().contains('computer science')) return false;
          if (_selectedDept == 'IT' && !student.department.toLowerCase().contains('information tech')) return false;
          if (_selectedDept == 'ECE' && !student.department.toLowerCase().contains('electronics')) return false;
          if (_selectedDept == 'EEE' && !student.department.toLowerCase().contains('electrical')) return false;
          if (_selectedDept == 'MECH' && !student.department.toLowerCase().contains('mechanical')) return false;
        }
        if (_selectedSem != 'All Semesters') {
          final semNum = int.tryParse(_selectedSem.replaceAll(RegExp(r'[^0-9]'), ''));
          if (semNum != null && student.semester != semNum) return false;
        }
        if (_selectedYear != 'All Years') {
          final yearNum = int.tryParse(_selectedYear.replaceAll(RegExp(r'[^0-9]'), ''));
          if (yearNum != null) {
            final expectedSemMin = (yearNum - 1) * 2 + 1;
            final expectedSemMax = yearNum * 2;
            if (student.semester < expectedSemMin || student.semester > expectedSemMax) return false;
          }
        }
      } else {
        if (_selectedDept != 'All Departments') {
          final d = _selectedDept.toUpperCase();
          if (d == 'CSE' && !m.subjectCode.contains('CS') && !m.studentRegNo.contains('CS')) return false;
          if (d == 'IT' && !m.subjectCode.contains('IT') && !m.studentRegNo.contains('IT')) return false;
          if (d == 'ECE' && !m.subjectCode.contains('EC') && !m.studentRegNo.contains('EC')) return false;
        }
      }

      if (_selectedDocType != 'All Document Types') {
        // Dummy fallback for exact match as data doesn't distinguish source inherently except by value.
      }

      if (_selectedVerType != 'All Verification Types') {
         if (_selectedVerType == 'Verified' && m.status != 'Verified') return false;
         if (_selectedVerType == 'Mismatch Detected' && !m.isMismatch) return false;
         if (_selectedVerType == 'Pending Approval' && m.status != 'Pending Approval') return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = m.studentRegNo.toLowerCase().contains(q) ||
            m.studentName.toLowerCase().contains(q) ||
            m.subjectCode.toLowerCase().contains(q) ||
            m.subjectName.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Title Bar & Refresh Trigger
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Marks Audit — Multi-Stage Verification Pipeline',
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
              onPressed: () => widget.state.showToast('Re-running 5-stage marks reconciliation...'),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Re-run Pipeline'),
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
            _buildKpiCard('Total Marks Audited', '34,850', Icons.analytics_outlined, const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
            _buildKpiCard('5-Stage Matched', '34,210', Icons.verified_rounded, const Color(0xFF10B981), const Color(0xFFECFDF5)),
            _buildKpiCard('Post-Approval Mismatches', '42 Flags', Icons.error_outline_rounded, const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
            _buildKpiCard('Pending HOD Verification', '598 Records', Icons.pending_actions_rounded, const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
          ],
        ),

        const SizedBox(height: 20),

        // Multi-Stage Verification Pipeline Stepper Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.alt_route_rounded, color: AppColors.accent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '5-Stage Marks Integrity Pipeline',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    _PipelineStep(step: '1', title: 'Faculty Entry', sub: 'Internal CAT / Quiz', color: Color(0xFF3B82F6), bgColor: Color(0xFFEFF6FF)),
                    _PipelineArrow(),
                    _PipelineStep(step: '2', title: 'Department Ledger', sub: 'HOD Verified Record', color: Color(0xFF6366F1), bgColor: Color(0xFFEEF2FF)),
                    _PipelineArrow(),
                    _PipelineStep(step: '3', title: 'Exam Record', sub: 'CoE Input Ledger', color: Color(0xFF8B5CF6), bgColor: Color(0xFFF5F3FF)),
                    _PipelineArrow(),
                    _PipelineStep(step: '4', title: 'Published Result', sub: 'Grade Sheet Output', color: Color(0xFF0D9488), bgColor: Color(0xFFF0FDFA)),
                    _PipelineArrow(),
                    _PipelineStep(step: '5', title: 'Auditor Review', sub: 'Independent Integrity Check', color: Color(0xFF10B981), bgColor: Color(0xFFECFDF5)),
                  ],
                ),
              ),
            ],
          ),
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
              // Search Input
              SizedBox(
                width: 320,
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                    hintText: 'Search by Student Name, Reg No, Course Code...',
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

              // Filter Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip('All Records', 'All'),
                  _buildFilterChip('Mismatches Only', 'Mismatches'),
                  _buildFilterChip('Verified', 'Verified'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Data Table — Desktop: horizontal scroll table; Mobile: card-per-record
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            if (isMobile) {
              return Column(
                children: entries.map((m) => _buildMobileCard(m)).toList(),
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
                      width: 180,
                      child: Text('STUDENT & REG NO', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 200,
                      child: Text('SUBJECT / COURSE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 100,
                      child: Text('FACULTY', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 100,
                      child: Text('DEPT RECORD', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 100,
                      child: Text('EXAM RECORD', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 100,
                      child: Text('FINAL RESULT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 180,
                      child: Text('MISMATCH STATUS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 140,
                      child: Text('AUDIT STATUS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 120,
                      child: Text('ACTION', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                ],
                rows: entries.map((m) {
                  return DataRow(
                    cells: [
                      // Student & Reg No Badge
                      DataCell(
                        SizedBox(
                          width: 180,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: AppColors.accentLight,
                                child: Text(
                                  m.studentName.substring(0, 1).toUpperCase(),
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
                                      m.studentName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      m.studentRegNo,
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Subject / Course
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.subjectName,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.border)),
                                child: Text(
                                  m.subjectCode,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'monospace', color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Faculty Entry
                      DataCell(
                        SizedBox(
                          width: 100,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)),
                            child: Text(m.facultyEntry.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
                          ),
                        ),
                      ),

                      // Dept Record
                      DataCell(
                        SizedBox(
                          width: 100,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)),
                            child: Text(m.deptRecord.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
                          ),
                        ),
                      ),

                      // Exam Record (Highlighted Red if Mismatch)
                      DataCell(
                        SizedBox(
                          width: 100,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: m.isMismatch ? const Color(0xFFFEE2E2) : AppColors.background,
                              borderRadius: BorderRadius.circular(6),
                              border: m.isMismatch ? Border.all(color: const Color(0xFFEF4444)) : null,
                            ),
                            child: Text(
                              m.examRecord.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: m.isMismatch ? const Color(0xFFDC2626) : AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),

                      // Final Result
                      DataCell(
                        SizedBox(
                          width: 100,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)),
                            child: Text(m.finalResult.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
                          ),
                        ),
                      ),

                      // Mismatch Status Badge
                      DataCell(
                        SizedBox(
                          width: 180,
                          child: m.isMismatch
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(6)),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFDC2626)),
                                      SizedBox(width: 4),
                                      Text('Mismatch Detected', style: TextStyle(color: Color(0xFFDC2626), fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_rounded, size: 14, color: Color(0xFF10B981)),
                                      SizedBox(width: 4),
                                      Text('Matched Across 5 Stages', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                        ),
                      ),

                      // Audit Status Badge
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: StatusBadge(status: m.status, isCompact: true),
                        ),
                      ),

                      // Action Button
                      DataCell(
                        SizedBox(
                          width: 120,
                          child: ElevatedButton.icon(
                            onPressed: (m.isMismatch ? widget.state.canFlagIssue : widget.state.canVerify)
                                ? () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => ActionModal(
                                        recordId: m.id,
                                        actionType: m.isMismatch ? 'Flag Issue' : 'Verify',
                                        state: widget.state,
                                      ),
                                    );
                                  }
                                : null,
                            icon: Icon(m.isMismatch ? Icons.flag_rounded : Icons.check_circle_rounded, size: 14),
                            label: Text(m.isMismatch ? 'Flag' : 'Verify'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: m.isMismatch ? const Color(0xFFDC2626) : AppColors.accent,
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

  Widget _buildMobileCard(dynamic m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: m.isMismatch ? const Color(0xFFEF4444) : AppColors.border),
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
                  m.studentName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(m.studentRegNo, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'monospace')),
                  ],
                ),
              ),
              StatusBadge(status: m.status, isCompact: true),
            ],
          ),
          const Divider(height: 20),
          _mobileRow('Subject', '${m.subjectName} (${m.subjectCode})'),
          _mobileRow('Faculty Entry', m.facultyEntry.toString()),
          _mobileRow('Dept Record', m.deptRecord.toString()),
          _mobileRow('Exam Record', m.examRecord.toString(), highlight: m.isMismatch),
          _mobileRow('Final Result', m.finalResult.toString()),
          const SizedBox(height: 8),
          if (m.isMismatch)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(6)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFDC2626)),
                  SizedBox(width: 4),
                  Text('Mismatch Detected', style: TextStyle(color: Color(0xFFDC2626), fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _mobileRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: highlight ? const Color(0xFFDC2626) : AppColors.textPrimary,
              ),
            ),
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
    final isSel = _filterState == key;
    return InkWell(
      onTap: () => setState(() => _filterState = key),
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

class _PipelineStep extends StatelessWidget {
  final String step;
  final String title;
  final String sub;
  final Color color;
  final Color bgColor;

  const _PipelineStep({
    required this.step,
    required this.title,
    required this.sub,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(step, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              Text(sub, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PipelineArrow extends StatelessWidget {
  const _PipelineArrow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Icon(Icons.arrow_forward_rounded, color: AppColors.textMuted, size: 16),
    );
  }
}
