import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../widgets/status_badge.dart';
import '../widgets/action_modal.dart';
import '../widgets/responsive_row.dart';

class AssignmentAuditView extends StatefulWidget {
  final AuditState state;

  const AssignmentAuditView({super.key, required this.state});

  @override
  State<AssignmentAuditView> createState() => _AssignmentAuditViewState();
}

class _AssignmentAuditViewState extends State<AssignmentAuditView> {
  String _filterStatus = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Filter assignments using actual AssignmentRecord fields
    final assignments = widget.state.assignmentRecords.where((a) {
      if (_filterStatus == 'Missing Evidence' && !a.isMissingFile) return false;
      if (_filterStatus == 'Verified' && a.status != 'Verified') return false;
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

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Header Title Bar
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Assignment & Continuous Assessment Audit',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Independent verification of internal rubrics, student submissions, and LMS digital evidence hashes.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
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
              // Search Input
              SizedBox(
                width: 320,
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

        // Data Table Container (Responsive: horizontal scroll desktop / tablet, cards on mobile)
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
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
                child: SizedBox(
                  width: 1250,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.tableHeaderBg),
                    headingRowHeight: 52,
                    dataRowMinHeight: 72,
                    dataRowMaxHeight: 72,
                    horizontalMargin: 24,
                    columnSpacing: 28,
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
                              width: 200,
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
                              width: 180,
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
                              width: 160,
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
                              width: 90,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(6)),
                                child: Text(
                                  '${a.marksObtained}/${a.totalMarks}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.accent),
                                ),
                              ),
                            ),
                          ),

                          // Evidence File
                          DataCell(
                            SizedBox(
                              width: 180,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isMissing ? const Color(0xFFFEE2E2) : AppColors.background,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: isMissing ? const Color(0xFFEF4444) : AppColors.border),
                                ),
                                child: Row(
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
                              width: 100,
                              child: Text(a.submissionDate, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ),
                          ),

                          // Audit Status
                          DataCell(
                            SizedBox(
                              width: 130,
                              child: StatusBadge(status: a.status, isCompact: true),
                            ),
                          ),

                          // Action Button
                          DataCell(
                            SizedBox(
                              width: 110,
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
