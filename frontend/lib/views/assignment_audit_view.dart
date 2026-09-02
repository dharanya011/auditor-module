import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../widgets/status_badge.dart';
import '../widgets/action_modal.dart';
import '../widgets/responsive_row.dart';
import '../widgets/api_error_widget.dart';

class AssignmentAuditView extends StatefulWidget {
  final AuditState state;

  const AssignmentAuditView({super.key, required this.state});

  @override
  State<AssignmentAuditView> createState() => _AssignmentAuditViewState();
}

class _AssignmentAuditViewState extends State<AssignmentAuditView> {
  String _filterStatus = 'All';
  String _searchQuery = '';

  // 5 Student Audit Pattern Filters
  String _selectedDept = 'All Departments';
  String _selectedYear = 'All Years';
  String _selectedSem = 'All Semesters';
  String _selectedDocType = 'All Document Types';
  String _selectedVerType = 'All Verification Types';

  String _getRoleBasedPrompt(String role) {
    switch (role) {
      case 'Lead_Auditor': return 'Review audit records across departments and monitor pending and completed verification activities.';
      case 'Department_Auditor': return 'Review and verify audit records for your assigned department and resolve pending issues.';
      case 'HOD': return 'Monitor department-level audit progress and review records requiring attention.';
      case 'Dean_Academics': return 'Monitor overall academic audit compliance and review department-level audit status.';
      case 'Read_Only_Inspector': return 'Inspect audit records, verification status and compliance-related issues.';
      case 'System_Admin': return 'Monitor the complete audit system and manage audit records across all roles and departments.';
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
      options: const ['All Document Types', 'Assignments', 'Continuous Assessment', 'Project Evidence'],
      onChanged: (v) => setState(() => _selectedDocType = v!),
    );

    final verTypeField = buildFilterField(
      label: 'Verification Type',
      value: _selectedVerType,
      icon: Icons.verified_user_rounded,
      options: const ['All Verification Types', 'Verified', 'Missing Evidence', 'Submitted Late'],
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
                    'Assignment Audit Filters (${hasActiveFilters ? "Active" : "All"})',
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
    if (widget.state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading assignment audit records from database...', style: TextStyle(color: AppColors.textSecondary)),
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

    // Filter assignments using actual AssignmentRecord fields
    final assignments = widget.state.assignmentRecords.where((a) {
      if (widget.state.departmentScope != null) {
        if (!a.subject.contains(widget.state.departmentScope!) && !a.studentRegNo.contains(widget.state.departmentScope!)) {
          return false;
        }
      }

      if (_filterStatus == 'Missing Evidence' && !a.isMissingFile) return false;
      if (_filterStatus == 'Verified' && a.status != 'Verified') return false;

      final student = widget.state.studentRecords.where((s) => s.registerNo == a.studentRegNo).firstOrNull;
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
          if (d == 'CSE' && !a.subject.contains('CS') && !a.studentRegNo.contains('CS')) return false;
          if (d == 'IT' && !a.subject.contains('IT') && !a.studentRegNo.contains('IT')) return false;
          if (d == 'ECE' && !a.subject.contains('EC') && !a.studentRegNo.contains('EC')) return false;
        }
      }

      if (_selectedDocType != 'All Document Types') {
         if (_selectedDocType == 'Assignments' && !a.title.toLowerCase().contains('assignment')) return false;
         if (_selectedDocType == 'Continuous Assessment' && !a.title.toLowerCase().contains('assessment')) return false;
      }

      if (_selectedVerType != 'All Verification Types') {
         if (_selectedVerType == 'Verified' && a.status != 'Verified') return false;
         if (_selectedVerType == 'Missing Evidence' && !a.isMissingFile) return false;
         if (_selectedVerType == 'Submitted Late' && a.status != 'Submitted Late') return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = a.id.toLowerCase().contains(q) ||
            a.title.toLowerCase().contains(q) ||
            a.studentName.toLowerCase().contains(q) ||
            a.studentRegNo.toLowerCase().contains(q) ||
            a.subject.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileScreen = screenWidth < 700;

    return ListView(
      padding: EdgeInsets.all(isMobileScreen ? 16 : 24),
      children: [
        // Header Title Bar
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isMobileScreen ? screenWidth - 32 : 650),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assignment & Continuous Assessment Audit',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getRoleBasedPrompt(widget.state.userRole),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: widget.state.canVerify ? () => widget.state.showToast('Re-verifying LMS submission hashes...') : null,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Re-verify Hashes'),
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

        // KPI Summary Cards Row (Responsive Layout)
        ResponsiveRow(
          spacing: 14,
          children: [
            _buildKpiCard('Total Audited', '${widget.state.assignmentRecords.length} Assignments', Icons.assignment_outlined, const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
            _buildKpiCard('Evidence Verified', '${widget.state.assignmentRecords.where((a) => a.status == "Verified").length} Verified', Icons.check_circle_outline_rounded, const Color(0xFF10B981), const Color(0xFFECFDF5)),
            _buildKpiCard('Missing Link Flags', '${widget.state.assignmentRecords.where((a) => a.isMissingFile).length} Flags', Icons.link_off_rounded, const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
            _buildKpiCard('Pending Verification', '${widget.state.assignmentRecords.where((a) => a.status != "Verified").length} Records', Icons.warning_amber_rounded, const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
          ],
        ),

        const SizedBox(height: 20),

        // 5 Pattern Filters
        _buildFilterCard(isMobileScreen),

        // Filter Toolbar Card
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
              // Search Input (Adaptive width to prevent mobile overflow)
              SizedBox(
                width: screenWidth < 420 ? double.infinity : 300,
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                    hintText: 'Search Title, Student Name, Reg No, ID...',
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
                  _buildFilterChip('All Assignments', 'All'),
                  _buildFilterChip('Missing Evidence', 'Missing Evidence'),
                  _buildFilterChip('Verified', 'Verified'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        if (assignments.isEmpty)
          const ApiEmptyWidget(
            message: 'No Assignment Audit Records Found',
            hint: 'The PostgreSQL database returned 0 assignment audit entries.',
          ),

        // Data Table Container (Responsive: horizontal scroll desktop / tablet, cards on mobile)
        if (assignments.isNotEmpty)
          LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 650;
            if (isMobile) {
              return Column(
                children: assignments.map((a) => _buildMobileCard(a)).toList(),
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.tableHeaderBg),
                    headingRowHeight: 52,
                    dataRowMinHeight: 68,
                    dataRowMaxHeight: 68,
                    horizontalMargin: 20,
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('ASSIGNMENT ID & TITLE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary))),
                      DataColumn(label: Text('STUDENT NAME & REG', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary))),
                      DataColumn(label: Text('SUBJECT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary))),
                      DataColumn(label: Text('MARKS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary))),
                      DataColumn(label: Text('EVIDENCE FILE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary))),
                      DataColumn(label: Text('SUBMISSION DATE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary))),
                      DataColumn(label: Text('AUDIT STATUS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary))),
                      DataColumn(label: Text('ACTION', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary))),
                    ],
                    rows: assignments.map((a) {
                      final isMissing = a.isMissingFile;
                      return DataRow(
                        cells: [
                          // ID & Title
                          DataCell(
                            SizedBox(
                              width: 190,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    a.id,
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Student Name & Reg
                          DataCell(
                            SizedBox(
                              width: 170,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.studentName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    a.studentRegNo,
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'monospace'),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Subject
                          DataCell(
                            SizedBox(
                              width: 150,
                              child: Text(
                                a.subject,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                          // Marks
                          DataCell(
                            SizedBox(
                              width: 85,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(6)),
                                child: Text(
                                  '${a.marksObtained}/${a.totalMarks}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.accent),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),

                          // Evidence File
                          DataCell(
                            SizedBox(
                              width: 190,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isMissing ? const Color(0xFFFEE2E2) : AppColors.background,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: isMissing ? const Color(0xFFEF4444) : AppColors.border),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isMissing ? Icons.link_off_rounded : Icons.insert_drive_file_outlined,
                                      size: 14,
                                      color: isMissing ? const Color(0xFFDC2626) : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        a.evidenceFile,
                                        style: TextStyle(
                                          color: isMissing ? const Color(0xFFDC2626) : AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Date
                          DataCell(
                            SizedBox(
                              width: 95,
                              child: Text(a.submissionDate, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ),
                          ),

                          // Audit Status
                          DataCell(
                            SizedBox(
                              width: 135,
                              child: StatusBadge(status: a.status, isCompact: true),
                            ),
                          ),

                          // Action Button
                          DataCell(
                            SizedBox(
                              width: 120,
                              child: ElevatedButton.icon(
                                onPressed: (isMissing ? widget.state.canFlagIssue : widget.state.canVerify)
                                    ? () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => ActionModal(
                                            recordId: a.id,
                                            actionType: isMissing ? 'Flag Issue' : 'Verify',
                                            state: widget.state,
                                          ),
                                        );
                                      }
                                    : null,
                                icon: Icon(isMissing ? Icons.flag_rounded : Icons.check_circle_rounded, size: 14),
                                label: Text(isMissing ? 'Flag' : 'Verify'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isMissing ? const Color(0xFFDC2626) : AppColors.accent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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

  Widget _buildMobileCard(dynamic a) {
    final isMissing = a.isMissingFile;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isMissing ? const Color(0xFFEF4444) : AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('${a.studentName} (${a.studentRegNo})', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              StatusBadge(status: a.status, isCompact: true),
            ],
          ),
          const Divider(height: 20),
          _mobileRow('Subject', a.subject),
          _mobileRow('Marks', '${a.marksObtained} / ${a.totalMarks}'),
          _mobileRow('Evidence', a.evidenceFile, highlight: isMissing),
          _mobileRow('Submitted On', a.submissionDate),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (isMissing ? widget.state.canFlagIssue : widget.state.canVerify)
                  ? () {
                      showDialog(
                        context: context,
                        builder: (ctx) => ActionModal(
                          recordId: a.id,
                          actionType: isMissing ? 'Flag Issue' : 'Verify',
                          state: widget.state,
                        ),
                      );
                    }
                  : null,
              icon: Icon(isMissing ? Icons.flag_rounded : Icons.check_circle_rounded, size: 14),
              label: Text(isMissing ? 'Flag Discrepancy' : 'Verify Assignment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isMissing ? const Color(0xFFDC2626) : AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
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
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600))),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: highlight ? const Color(0xFFDC2626) : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
                Text(
                  value,
                  style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
