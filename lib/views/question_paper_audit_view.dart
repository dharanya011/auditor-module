import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../widgets/status_badge.dart';

class QuestionPaperAuditView extends StatefulWidget {
  final AuditState state;

  const QuestionPaperAuditView({super.key, required this.state});

  @override
  State<QuestionPaperAuditView> createState() => _QuestionPaperAuditViewState();
}

class _QuestionPaperAuditViewState extends State<QuestionPaperAuditView> {
  String _filterDept = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final papers = widget.state.questionPapers.where((q) {
      if (_filterDept != 'All' && q.department != _filterDept) return false;
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Question Paper & Exam Document Audit',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Auditing course codes, R2023 regulation compliance, Bloom Taxonomy distribution, and CoE/HOD approvals.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => widget.state.showToast('Re-verifying Bloom Taxonomy distributions...'),
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

        // KPI Summary Cards Row
        Row(
          children: [
            _buildKpiCard('Total Question Papers', '420 Papers', Icons.description_outlined, const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
            const SizedBox(width: 14),
            _buildKpiCard('Regulation R2023 Passed', '398 Papers', Icons.verified_rounded, const Color(0xFF10B981), const Color(0xFFECFDF5)),
            const SizedBox(width: 14),
            _buildKpiCard('Bloom Taxonomy Gaps', '14 Flags', Icons.error_outline_rounded, const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
            const SizedBox(width: 14),
            _buildKpiCard('CoE Approval Pending', '8 Papers', Icons.pending_actions_rounded, const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
          ],
        ),

        const SizedBox(height: 20),

        // Filter Toolbar Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              // Search Input
              Expanded(
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
              const SizedBox(width: 16),

              // Filter Chips
              Row(
                children: [
                  _buildFilterChip('All Departments', 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('MECH Dept', 'MECH'),
                  const SizedBox(width: 8),
                  _buildFilterChip('IT Dept', 'IT'),
                  const SizedBox(width: 8),
                  _buildFilterChip('CSE Dept', 'CSE'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Executive Data Table Container (Minimum Width 1350px = ZERO OVERLAPS)
        Container(
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
        ),
      ],
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
    return Expanded(
      child: Container(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
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
