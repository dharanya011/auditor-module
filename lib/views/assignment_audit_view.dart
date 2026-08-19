import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../models/models.dart';
import '../widgets/status_badge.dart';
import '../widgets/evidence_modal.dart';
import '../widgets/action_modal.dart';

class AssignmentAuditView extends StatefulWidget {
  final AuditState state;

  const AssignmentAuditView({super.key, required this.state});

  @override
  State<AssignmentAuditView> createState() => _AssignmentAuditViewState();
}

class _AssignmentAuditViewState extends State<AssignmentAuditView> {
  String _filterFlag = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Filter records
    final records = widget.state.assignmentRecords.where((a) {
      if (_filterFlag == 'Missing File' && !a.isMissingFile) return false;
      if (_filterFlag == 'Late' && !a.isLate) return false;
      if (_filterFlag == 'Verified' && a.status != 'Verified') return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = a.studentRegNo.toLowerCase().contains(q) ||
            a.studentName.toLowerCase().contains(q) ||
            a.title.toLowerCase().contains(q) ||
            a.subject.toLowerCase().contains(q);
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
                  'Assignment Audit — Submission Verification',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Automated audit of assignment PDF file hashes, submission deadlines, and grading integrity.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => widget.state.showToast('Assignment audit rules refreshed'),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh Audit'),
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

        // KPI Summary Stat Cards Row
        Row(
          children: [
            _buildKpiCard('Total Audited Submissions', '1,420', Icons.assignment_outlined, const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
            const SizedBox(width: 14),
            _buildKpiCard('Verified Submissions', '1,280', Icons.check_circle_outline_rounded, const Color(0xFF10B981), const Color(0xFFECFDF5)),
            const SizedBox(width: 14),
            _buildKpiCard('Missing Evidence Files', '84 Flags', Icons.error_outline_rounded, const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
            const SizedBox(width: 14),
            _buildKpiCard('Late Submissions', '56 Flags', Icons.schedule_rounded, const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
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
                    hintText: 'Search by Student Name, Reg No, Assignment Title, Course...',
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
                  _buildFilterChip('All Submissions', 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Missing Files', 'Missing File'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Late Submissions', 'Late'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Verified Only', 'Verified'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Executive Data Table Container (Minimum Width 1350px with Generous Column Spacing = ZERO OVERLAPS)
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
                      width: 180,
                      child: Text('STUDENT & REG NO', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 220,
                      child: Text('ASSIGNMENT TITLE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 180,
                      child: Text('SUBJECT / COURSE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 140,
                      child: Text('SUBMISSION DATE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 80,
                      child: Text('MARKS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 140,
                      child: Text('RED FLAGS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 160,
                      child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 100,
                      child: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                ],
                rows: records.map((a) {
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
                                  a.studentName.substring(0, 1).toUpperCase(),
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
                                      a.studentName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      a.studentRegNo,
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Assignment Title
                      DataCell(
                        SizedBox(
                          width: 220,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.title,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                a.evidenceFile.isEmpty ? 'No PDF File Attached' : 'File: ${a.evidenceFile}',
                                style: TextStyle(color: a.evidenceFile.isEmpty ? Colors.red : AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Subject / Course
                      DataCell(
                        SizedBox(
                          width: 180,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              a.subject,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),

                      // Submission Date
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: Text(a.submissionDate, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ),
                      ),

                      // Marks
                      DataCell(
                        SizedBox(
                          width: 80,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${a.marksObtained} / ${a.totalMarks}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.accent),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),

                      // Red Flags Badge
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: _buildFlags(a),
                        ),
                      ),

                      // Status Badge
                      DataCell(
                        SizedBox(
                          width: 160,
                          child: StatusBadge(status: a.status, isCompact: true),
                        ),
                      ),

                      // Actions Row
                      DataCell(
                        SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.accent, size: 20),
                                tooltip: 'Inspect Evidence PDF',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => EvidenceModal(
                                      item: EvidenceItem(
                                        evidenceId: 'EVD-${a.id}',
                                        recordId: a.id,
                                        recordType: 'Assignment PDF',
                                        uploadedBy: a.studentName,
                                        uploadDate: a.submissionDate,
                                        documentType: 'PDF Submission',
                                        version: 'v1.0',
                                        fileName: a.evidenceFile.isEmpty ? 'MISSING_FILE.pdf' : a.evidenceFile,
                                        fileSize: a.evidenceFile.isEmpty ? '0 KB' : '2.4 MB',
                                        status: a.isMissingFile ? 'Rejected' : 'Accepted',
                                      ),
                                      onClose: () => Navigator.pop(ctx),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.flag_outlined, color: Colors.red, size: 20),
                                tooltip: 'Request Correction',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => ActionModal(
                                      recordId: a.id,
                                      actionType: 'Request Correction',
                                      state: widget.state,
                                    ),
                                  );
                                },
                              ),
                            ],
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
    final isSel = _filterFlag == key;
    return InkWell(
      onTap: () => setState(() => _filterFlag = key),
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

  Widget _buildFlags(AssignmentRecord a) {
    if (a.isMissingFile) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(6)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 12, color: Colors.red),
            SizedBox(width: 4),
            Text('Missing File', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    if (a.isLate) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time_rounded, size: 12, color: Color(0xFFD97706)),
            SizedBox(width: 4),
            Text('Late Submission', style: TextStyle(color: Color(0xFFD97706), fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 12, color: Color(0xFF10B981)),
          SizedBox(width: 4),
          Text('Clean', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
