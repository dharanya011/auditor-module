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

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Title Bar & Student Selector Dropdown (Aligned cleanly with Constrained Layout)
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
        ),

        const SizedBox(height: 20),

        // Executive Student Profile Header Card (Responsive Layout)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;
              final content = [
                // Avatar & Student Info Row
                Row(
                  children: [
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
                  ],
                ),
                if (!isDesktop) const SizedBox(height: 16),
                // Action Buttons
                Column(
                  crossAxisAlignment: isDesktop ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: widget.state.canVerify
                          ? () {
                              widget.state.verifyStudentRecord(student.registerNo);
                            }
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
              ];

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: content[0]),
                    const SizedBox(width: 16),
                    content[2],
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: content,
                );
              }
            },
          ),
        ),

        const SizedBox(height: 20),

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

        const SizedBox(height: 16),

        // 360° Verification Modules Grid (Flexible Aspect Ratio for Perfect Alignment)
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isWide ? 2 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isWide ? 1.9 : 2.2,
              children: [
                _buildModuleCard(
                  title: 'Personal & Institutional Records',
                  subtitle: 'Aadhaar, Birth Certificate, Admission Quota, and Caste Category records.',
                  status: 'Verified',
                  icon: Icons.badge_outlined,
                  iconBg: const Color(0xFFEEF2FF),
                  iconColor: const Color(0xFF4F46E5),
                  evidenceName: 'EVD-8890_Identity_Verification.pdf',
                ),
                _buildModuleCard(
                  title: 'Biometric Attendance Logs',
                  subtitle: '${student.attendance}% biometric classroom attendance matched with hostel & Gate logs.',
                  status: student.attendance >= 75 ? 'Verified' : 'Discrepancy',
                  icon: Icons.fingerprint_rounded,
                  iconBg: student.attendance >= 75 ? const Color(0xFFECFDF5) : const Color(0xFFFEE2E2),
                  iconColor: student.attendance >= 75 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  evidenceName: 'EVD-8892_Biometric_Log_S5.pdf',
                ),
                _buildModuleCard(
                  title: 'Internal Assessment Marks (CAT 1 & 2)',
                  subtitle: 'CAT 1 & CAT 2 internal marks cross-checked with scanned raw answer sheets.',
                  status: 'Verified',
                  icon: Icons.analytics_outlined,
                  iconBg: const Color(0xFFEFF6FF),
                  iconColor: const Color(0xFF3B82F6),
                  evidenceName: 'EVD-8891_CAT1_AnswerSheet_Scan.pdf',
                ),
                _buildModuleCard(
                  title: 'Assignments & Laboratory Reports',
                  subtitle: '5 of 5 assignment submissions evaluated with cryptographic S3 file hashes.',
                  status: student.registerNo == '23IT045' ? 'Discrepancy' : 'Verified',
                  icon: Icons.assignment_turned_in_outlined,
                  iconBg: student.registerNo == '23IT045' ? const Color(0xFFFEE2E2) : const Color(0xFFECFDF5),
                  iconColor: student.registerNo == '23IT045' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  evidenceName: 'EVD-8894_Assignment_Submissions.pdf',
                ),
                _buildModuleCard(
                  title: 'Semester End Results & CoE Ledger',
                  subtitle: 'Controller of Examinations result ledger verified against published grade sheet.',
                  status: 'Verified',
                  icon: Icons.description_outlined,
                  iconBg: const Color(0xFFFEF3C7),
                  iconColor: const Color(0xFFD97706),
                  evidenceName: 'EVD-8895_CoE_GradeLedger.pdf',
                ),
                _buildModuleCard(
                  title: 'Mini Projects & Certificates',
                  subtitle: 'Mini project source code repository, viva report, and internship certificates.',
                  status: 'Verified',
                  icon: Icons.folder_zip_outlined,
                  iconBg: const Color(0xFFF5F3FF),
                  iconColor: const Color(0xFF8B5CF6),
                  evidenceName: 'EVD-8896_MiniProject_CodeReport.pdf',
                ),
              ],
            );
          },
        ),
      ],
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
      padding: const EdgeInsets.all(16),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    StatusBadge(status: status, isCompact: true),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                icon: const Icon(Icons.folder_open_rounded, size: 14),
                label: const Text('View Evidence PDF', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: widget.state.canVerify
                    ? () {
                        widget.state.showToast('$title verified successfully!');
                      }
                    : null,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 14),
                label: const Text('Verify Module'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
