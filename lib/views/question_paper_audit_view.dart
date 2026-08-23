import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../widgets/status_badge.dart';
import '../widgets/responsive_row.dart';

class QuestionPaperAuditView extends StatefulWidget {
  final AuditState state;

  const QuestionPaperAuditView({super.key, required this.state});

  @override
  State<QuestionPaperAuditView> createState() => _QuestionPaperAuditViewState();
}

class _QuestionPaperAuditViewState extends State<QuestionPaperAuditView> {
  String _filterDept = 'All';
  String _searchQuery = '';

  // 5 Standard Dropdown Filters
  String _selectedDept = 'All Departments';
  String _selectedRegulation = 'All Regulations';
  String _selectedYear = 'All Academic Years';
  String _selectedSem = 'All Semesters';
  String _selectedStatus = 'All Statuses';

  String _getRoleBasedPrompt(String role) {
    switch (role) {
      case 'Lead Auditor':
        return 'Review faculty reports and question papers across departments, monitor compliance with regulations, and verify pending audit records.';
      case 'Department Auditor':
        return 'Review faculty reports and question papers for your assigned department and verify records that are pending audit.';
      case 'HOD':
        return 'Monitor faculty report and question paper audits for your department and review records requiring verification or corrective action.';
      case 'Dean':
      case 'Dean Academics':
        return 'Monitor faculty report and question paper compliance across departments and review overall audit progress.';
      case 'Inspector':
      case 'Read-Only Inspector':
        return 'Inspect faculty reports and question papers for regulatory compliance, quality standards, and verification status.';
      case 'System Admin':
        return 'Monitor the complete Faculty Audit system, manage audit records, and review verification activity across departments.';
      default:
        return 'Review faculty reports and question papers for compliance and verification status.';
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
      options: const ['All Departments', 'CSE', 'ECE', 'MECH', 'EEE', 'IT'],
      onChanged: (v) => setState(() => _selectedDept = v!),
    );

    final regField = buildFilterField(
      label: 'Regulation',
      value: _selectedRegulation,
      icon: Icons.gavel_rounded,
      options: const ['All Regulations', 'R2021', 'R2023'],
      onChanged: (v) => setState(() => _selectedRegulation = v!),
    );

    final yearField = buildFilterField(
      label: 'Academic Year',
      value: _selectedYear,
      icon: Icons.calendar_today_rounded,
      options: const ['All Academic Years', '2024–2025', '2025–2026', '2026–2027'],
      onChanged: (v) => setState(() => _selectedYear = v!),
    );

    final semField = buildFilterField(
      label: 'Semester',
      value: _selectedSem,
      icon: Icons.school_rounded,
      options: const ['All Semesters', 'Semester 1', 'Semester 2', 'Semester 3', 'Semester 4', 'Semester 5', 'Semester 6', 'Semester 7', 'Semester 8'],
      onChanged: (v) => setState(() => _selectedSem = v!),
    );

    final statusField = buildFilterField(
      label: 'Verification Status',
      value: _selectedStatus,
      icon: Icons.verified_user_rounded,
      options: const ['All Statuses', 'Verified', 'Rejected', 'Under Review'],
      onChanged: (v) => setState(() => _selectedStatus = v!),
    );

    final bool hasActiveFilters = _selectedDept != 'All Departments' ||
        _selectedRegulation != 'All Regulations' ||
        _selectedYear != 'All Academic Years' ||
        _selectedSem != 'All Semesters' ||
        _selectedStatus != 'All Statuses';

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
                    'Question Paper Audit Filters (${hasActiveFilters ? "Active" : "All"})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                  ),
                ],
              ),
              if (hasActiveFilters)
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDept = 'All Departments';
                      _selectedRegulation = 'All Regulations';
                      _selectedYear = 'All Academic Years';
                      _selectedSem = 'All Semesters';
                      _selectedStatus = 'All Statuses';
                    });
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.refresh_rounded, size: 12, color: AppColors.accent),
                      SizedBox(width: 4),
                      Text('Clear Filters', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent)),
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
                Expanded(child: regField),
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
            statusField,
          ] else ...[
            Row(
              children: [
                Expanded(child: deptField),
                const SizedBox(width: 8),
                Expanded(child: regField),
                const SizedBox(width: 8),
                Expanded(child: yearField),
                const SizedBox(width: 8),
                Expanded(child: semField),
                const SizedBox(width: 8),
                Expanded(child: statusField),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final papers = widget.state.questionPapers.where((q) {
      if (widget.state.departmentScope != null) {
        if (!q.department.toUpperCase().contains(widget.state.departmentScope!.toUpperCase())) {
          return false;
        }
      }

      if (_filterDept != 'All' && q.department != _filterDept) return false;

      if (_selectedDept != 'All Departments') {
        final d = _selectedDept.toUpperCase();
        if (d == 'CSE' && !q.department.toUpperCase().contains('CSE') && !q.department.toLowerCase().contains('computer science')) return false;
        if (d == 'IT' && !q.department.toUpperCase().contains('IT') && !q.department.toLowerCase().contains('information tech')) return false;
        if (d == 'ECE' && !q.department.toUpperCase().contains('ECE') && !q.department.toLowerCase().contains('electronics')) return false;
        if (d == 'EEE' && !q.department.toUpperCase().contains('EEE') && !q.department.toLowerCase().contains('electrical')) return false;
        if (d == 'MECH' && !q.department.toUpperCase().contains('MECH') && !q.department.toLowerCase().contains('mechanical')) return false;
      }

      if (_selectedRegulation != 'All Regulations') {
        if (q.regulation != _selectedRegulation) return false;
      }

      if (_selectedStatus != 'All Statuses') {
        if (_selectedStatus == 'Verified' && q.status != 'Verified') return false;
        if (_selectedStatus == 'Rejected' && q.status != 'Rejected' && q.status != 'Missing Approval') return false;
        if (_selectedStatus == 'Under Review' && q.status != 'Under Review' && q.status != 'Pending' && q.status != 'Missing Approval') return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final match = q.id.toLowerCase().contains(query) ||
            q.courseTitle.toLowerCase().contains(query) ||
            q.regulation.toLowerCase().contains(query) ||
            q.department.toLowerCase().contains(query);
        if (!match) return false;
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Header Title
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Question Paper & Exam Document Audit',
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
              onPressed: widget.state.canVerify ? () => widget.state.showToast('Re-verifying Bloom Taxonomy distributions...') : null,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Re-verify Taxonomy'),
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
            _buildKpiCard('Total Question Papers', '420 Papers', Icons.description_outlined, const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
            _buildKpiCard('Regulation R2023 Passed', '398 Papers', Icons.verified_rounded, const Color(0xFF10B981), const Color(0xFFECFDF5)),
            _buildKpiCard('Bloom Taxonomy Gaps', '14 Flags', Icons.error_outline_rounded, const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
            _buildKpiCard('CoE Approval Pending', '8 Papers', Icons.pending_actions_rounded, const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
          ],
        ),

        const SizedBox(height: 20),

        // 5 Standard Dropdown Filters
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
                    hintText: 'Search by QP Code, Course Title, Regulation...',
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
                  _buildFilterChip('All Departments', 'All'),
                  _buildFilterChip('MECH Dept', 'MECH'),
                  _buildFilterChip('IT Dept', 'IT'),
                  _buildFilterChip('CSE Dept', 'CSE'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        if (papers.isEmpty)
          Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.filter_alt_off_rounded, size: 44, color: AppColors.textSecondary),
                const SizedBox(height: 12),
                const Text(
                  'No Question Paper Records Found',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                const Text(
                  'No question paper records match the selected Department, Regulation, Academic Year, Semester, Verification Status, or Search query.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedDept = 'All Departments';
                      _selectedRegulation = 'All Regulations';
                      _selectedYear = 'All Academic Years';
                      _selectedSem = 'All Semesters';
                      _selectedStatus = 'All Statuses';
                      _searchQuery = '';
                      _filterDept = 'All';
                    });
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reset All Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          )
        else
          // Data Table — Desktop scroll table; Mobile card-per-record
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              if (isMobile) {
                return Column(
                  children: papers.map((q) => _buildMobileCard(q)).toList(),
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
                      width: 220,
                      child: Text('QP ID & COURSE TITLE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 120,
                      child: Text('REGULATION', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 100,
                      child: Text('DEPT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 140,
                      child: Text('BLOOM TAXONOMY', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 140,
                      child: Text('SYLLABUS MAPPED', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 130,
                      child: Text('HOD APPROVAL', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 130,
                      child: Text('COE APPROVAL', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 140,
                      child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 120,
                      child: Text('ACTION', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                ],
                rows: papers.map((q) {
                  return DataRow(
                    cells: [
                      // QP ID & Course Title
                      DataCell(
                        SizedBox(
                          width: 220,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                q.courseTitle,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                q.id,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Regulation Badge
                      DataCell(
                        SizedBox(
                          width: 120,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              q.regulation,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.accent),
                            ),
                          ),
                        ),
                      ),

                      // Department
                      DataCell(
                        SizedBox(
                          width: 100,
                          child: Text(q.department, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),

                      // Bloom Taxonomy Status
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: _buildCheckTag(q.bloomTaxonomyCompliant, 'Pass (60% HOTS)', 'Taxonomy Gap'),
                        ),
                      ),

                      // Syllabus Mapped
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: _buildCheckTag(q.syllabusMapped, '100% Mapped', 'Unmapped COs'),
                        ),
                      ),

                      // HOD Approval
                      DataCell(
                        SizedBox(
                          width: 130,
                          child: _buildCheckTag(q.hodApproved, 'Approved', 'Pending HOD'),
                        ),
                      ),

                      // CoE Approval
                      DataCell(
                        SizedBox(
                          width: 130,
                          child: _buildCheckTag(q.coeApproved, 'Approved', 'Pending CoE'),
                        ),
                      ),

                      // Status Badge
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: StatusBadge(status: q.status, isCompact: true),
                        ),
                      ),

                      // Action Button
                      DataCell(
                        SizedBox(
                          width: 120,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              widget.state.showToast('Inspecting Question Paper document ${q.id}...');
                            },
                            icon: const Icon(Icons.picture_as_pdf_rounded, size: 14),
                            label: const Text('Inspect'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
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

  Widget _buildMobileCard(dynamic q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(q.courseTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              StatusBadge(status: q.status, isCompact: true),
            ],
          ),
          const SizedBox(height: 4),
          Text(q.id, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'monospace')),
          const Divider(height: 20),
          _mobileRow('Department', q.department),
          _mobileRow('Regulation', q.regulation),
          _mobileRow('Bloom Taxonomy', q.bloomTaxonomyCompliant ? '✓ Pass (60% HOTS)' : '✗ Taxonomy Gap'),
          _mobileRow('Syllabus Mapped', q.syllabusMapped ? '✓ 100% Mapped' : '✗ Unmapped COs'),
          _mobileRow('HOD Approval', q.hodApproved ? '✓ Approved' : '✗ Pending HOD'),
          _mobileRow('CoE Approval', q.coeApproved ? '✓ Approved' : '✗ Pending CoE'),
        ],
      ),
    );
  }

  Widget _mobileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildCheckTag(bool isPass, String passText, String failText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPass ? const Color(0xFFECFDF5) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isPass ? Icons.check_circle_outline_rounded : Icons.cancel_outlined, size: 12, color: isPass ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
          const SizedBox(width: 4),
          Text(isPass ? passText : failText, style: TextStyle(color: isPass ? const Color(0xFF10B981) : const Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.bold)),
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
    final isSel = _filterDept == key;
    return InkWell(
      onTap: () => setState(() => _filterDept = key),
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
