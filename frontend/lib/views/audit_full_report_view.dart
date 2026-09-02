import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../models/models.dart';

// ============================================================
// AUDIT FULL REPORT VIEW
// Dashboard → View Full Report → This Page
// ============================================================
class AuditFullReportView extends StatefulWidget {
  final AuditState state;
  const AuditFullReportView({super.key, required this.state});

  @override
  State<AuditFullReportView> createState() => _AuditFullReportViewState();
}

class _AuditFullReportViewState extends State<AuditFullReportView> {
  _DrillDownTarget? _drillDown;

  void _openDrillDown(_DrillDownTarget target) => setState(() => _drillDown = target);
  void _closeDrillDown() => setState(() => _drillDown = null);

  @override
  Widget build(BuildContext context) {
    if (_drillDown != null) {
      return _DrillDownPage(state: widget.state, target: _drillDown!, onBack: _closeDrillDown);
    }
    return _ModuleSummaryPage(state: widget.state, onDrillDown: _openDrillDown);
  }
}

// ============================================================
// MODULE SUMMARY PAGE
// ============================================================
class _ModuleSummaryPage extends StatelessWidget {
  final AuditState state;
  final void Function(_DrillDownTarget) onDrillDown;
  const _ModuleSummaryPage({required this.state, required this.onDrillDown});

  @override
  Widget build(BuildContext context) {
    final modules = state.moduleProgress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breadcrumb header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              InkWell(
                onTap: () => state.setActiveModule('Dashboard'),
                borderRadius: BorderRadius.circular(6),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.dashboard_rounded, size: 16, color: AppColors.accent),
                  SizedBox(width: 4),
                  Text('Dashboard',
                      style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondary),
              ),
              const Text('Audit Full Report',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Module-wise Audit Progress Report',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(
                          'Academic Year: ${state.selectedAcademicYear}  •  Tap any status count to view detailed records.',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => state.setActiveModule('Audit Reports'),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 14),
                    label: const Text('Export Reports', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Summary KPIs
              LayoutBuilder(builder: (ctx, cs) {
                final cols = cs.maxWidth > 700 ? 4 : 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: cols,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: cols == 4 ? 2.8 : 2.2,
                  children: [
                    _kpiCard('Total Records', '11,840', Icons.assignment_rounded, const Color(0xFF6366F1)),
                    _kpiCard('Verified', '9,840', Icons.check_circle_rounded, const Color(0xFF10B981)),
                    _kpiCard('Pending', '1,535', Icons.hourglass_top_rounded, const Color(0xFFF59E0B)),
                    _kpiCard('Issues', '558', Icons.warning_amber_rounded, const Color(0xFFEF4444)),
                  ],
                );
              }),
              const SizedBox(height: 20),

              // Module cards
              LayoutBuilder(builder: (ctx, cs) {
                final isDesktop = cs.maxWidth > 680;
                return Column(
                  children: modules.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: isDesktop
                        ? _ModuleCard(module: m, onDrillDown: onDrillDown)
                        : _ModuleCardMobile(module: m, onDrillDown: onDrillDown),
                  )).toList(),
                );
              }),
              const SizedBox(height: 12),

              // Info note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF4F46E5)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap Verified, Pending, or Issues to view corresponding detailed records. '
                        'Tap Progress or "View Details" to see full module progress.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF3730A3)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MODULE CARD — Desktop
// ============================================================
class _ModuleCard extends StatelessWidget {
  final ModuleProgress module;
  final void Function(_DrillDownTarget) onDrillDown;
  const _ModuleCard({required this.module, required this.onDrillDown});

  @override
  Widget build(BuildContext context) {
    final pct = (module.percentage * 100).round();
    final color = _moduleColor(module.name);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(_moduleIcon(module.name), color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(module.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ),
              // Progress clickable badge
              InkWell(
                onTap: () => onDrillDown(_DrillDownTarget(module: module.name, status: 'Progress')),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up_rounded, size: 12, color: color),
                      const SizedBox(width: 4),
                      Text('$pct% Complete',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: module.percentage,
              minHeight: 6,
              backgroundColor: AppColors.border,
              color: color,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _statusChip('Verified', _fmt(module.verified), const Color(0xFF10B981),
                  Icons.check_circle_rounded, () => onDrillDown(_DrillDownTarget(module: module.name, status: 'Verified'))),
              const SizedBox(width: 10),
              _statusChip('Pending', _fmt(module.pending), const Color(0xFFF59E0B),
                  Icons.hourglass_top_rounded, () => onDrillDown(_DrillDownTarget(module: module.name, status: 'Pending'))),
              const SizedBox(width: 10),
              _statusChip('Issues', _fmt(module.issues), const Color(0xFFEF4444),
                  Icons.warning_amber_rounded, () => onDrillDown(_DrillDownTarget(module: module.name, status: 'Issues'))),
              const Spacer(),
              InkWell(
                onTap: () => onDrillDown(_DrillDownTarget(module: module.name, status: 'Progress')),
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('View Details',
                        style: TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.accent),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, String count, Color color, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(count, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
                Text(label, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MODULE CARD — Mobile
// ============================================================
class _ModuleCardMobile extends StatelessWidget {
  final ModuleProgress module;
  final void Function(_DrillDownTarget) onDrillDown;
  const _ModuleCardMobile({required this.module, required this.onDrillDown});

  @override
  Widget build(BuildContext context) {
    final pct = (module.percentage * 100).round();
    final color = _moduleColor(module.name);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(7)),
                child: Icon(_moduleIcon(module.name), color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(module.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis),
              ),
              Text('$pct%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: module.percentage,
              minHeight: 5,
              backgroundColor: AppColors.border,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _chip('✓ ${_fmt(module.verified)}', 'Verified', const Color(0xFF10B981),
                  () => onDrillDown(_DrillDownTarget(module: module.name, status: 'Verified')))),
              const SizedBox(width: 6),
              Expanded(child: _chip('⏳ ${_fmt(module.pending)}', 'Pending', const Color(0xFFF59E0B),
                  () => onDrillDown(_DrillDownTarget(module: module.name, status: 'Pending')))),
              const SizedBox(width: 6),
              Expanded(child: _chip('⚠ ${_fmt(module.issues)}', 'Issues', const Color(0xFFEF4444),
                  () => onDrillDown(_DrillDownTarget(module: module.name, status: 'Issues')))),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => onDrillDown(_DrillDownTarget(module: module.name, status: 'Progress')),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('View Details',
                    style: TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.bold)),
                SizedBox(width: 2),
                Icon(Icons.arrow_forward_rounded, size: 13, color: AppColors.accent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String value, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                overflow: TextOverflow.ellipsis),
            Text(label, style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.75))),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DRILL-DOWN TARGET
// ============================================================
class _DrillDownTarget {
  final String module;
  final String status;
  const _DrillDownTarget({required this.module, required this.status});
}

// ============================================================
// DRILL-DOWN PAGE
// ============================================================
class _DrillDownPage extends StatelessWidget {
  final AuditState state;
  final _DrillDownTarget target;
  final VoidCallback onBack;
  const _DrillDownPage({required this.state, required this.target, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final records = _buildRecords();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breadcrumb
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              InkWell(
                onTap: () => state.setActiveModule('Dashboard'),
                borderRadius: BorderRadius.circular(6),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.dashboard_rounded, size: 16, color: AppColors.accent),
                  SizedBox(width: 4),
                  Text('Dashboard',
                      style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondary),
              ),
              InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(6),
                child: const Text('Audit Full Report',
                    style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondary),
              ),
              Expanded(
                child: Text('${target.module} — ${target.status}',
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 14),
                label: const Text('Back', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.accent),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Records
        Expanded(
          child: records.isEmpty
              ? _emptyState()
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${target.module} — ${target.status} Records',
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text(
                                'Showing ${records.length} record${records.length != 1 ? 's' : ''}  •  ${state.selectedAcademicYear}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        _statusBadge(target.status),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ...records.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: r,
                        )),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_rounded, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text('No ${target.status} records found for ${target.module}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 14),
            label: const Text('Back to Audit Report', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.accent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRecords() {
    switch (target.module) {
      case 'Student Records':
        return _studentCards();
      case 'Assignments':
        return _assignmentCards();
      case 'Marks':
        return _marksCards();
      case 'Faculty Reports':
        return _facultyCards();
      case 'Question Papers':
        return _questionPaperCards();
      case 'Research & Publications':
        return _researchCards();
      default:
        return [];
    }
  }

  // ---- Student Records ----
  List<Widget> _studentCards() {
    List<StudentAuditRecord> list;
    final st = target.status;
    if (st == 'Verified') {
      list = state.studentRecords.where((s) => s.status == 'Verified').toList();
    } else if (st == 'Pending') {
      list = state.studentRecords.where((s) => s.status == 'Pending').toList();
    } else if (st == 'Issues') {
      list = state.studentRecords.where((s) => s.status == 'Discrepancy' || s.status == 'Issue').toList();
    } else {
      list = state.studentRecords;
    }
    if (list.isEmpty) return _syntheticCards(st, 'Student');
    return list.map((s) => _BaseRecordCard(
      icon: Icons.school_rounded,
      color: const Color(0xFF6366F1),
      id: s.registerNo,
      title: s.name,
      status: st,
      fields: [
        {'Department': s.department},
        {'Semester': '${s.semester}'},
        {'CGPA': '${s.cgpa}'},
        {'Attendance': '${s.attendance}%'},
        {'Record Status': s.status},
      ],
    )).toList();
  }

  // ---- Assignment Records ----
  List<Widget> _assignmentCards() {
    List<AssignmentRecord> list;
    final st = target.status;
    if (st == 'Verified') {
      list = state.assignmentRecords.where((a) => a.status == 'Verified').toList();
    } else if (st == 'Pending') {
      list = state.assignmentRecords.where((a) => a.status == 'Pending').toList();
    } else if (st == 'Issues') {
      list = state.assignmentRecords.where((a) => a.status != 'Verified' && a.status != 'Pending').toList();
    } else {
      list = state.assignmentRecords;
    }
    if (list.isEmpty) return _syntheticCards(st, 'Assignment');
    return list.map((a) => _BaseRecordCard(
      icon: Icons.assignment_rounded,
      color: const Color(0xFF10B981),
      id: a.id,
      title: a.title,
      status: st,
      fields: [
        {'Student': a.studentName},
        {'Reg No': a.studentRegNo},
        {'Subject': a.subject},
        {'Submitted': a.submissionDate},
        {'Marks': '${a.marksObtained}/${a.totalMarks}'},
        {'Record Status': a.status},
      ],
    )).toList();
  }

  // ---- Marks Records ----
  List<Widget> _marksCards() {
    List<MarksAuditEntry> list;
    final st = target.status;
    if (st == 'Verified') {
      list = state.marksEntries.where((m) => m.status == 'Verified').toList();
    } else if (st == 'Pending') {
      list = state.marksEntries.where((m) => m.status == 'Pending').toList();
    } else if (st == 'Issues') {
      list = state.marksEntries.where((m) => m.isMismatch || m.status == 'Discrepancy').toList();
    } else {
      list = state.marksEntries;
    }
    if (list.isEmpty) return _syntheticCards(st, 'Marks');
    return list.map((m) => _BaseRecordCard(
      icon: Icons.analytics_rounded,
      color: const Color(0xFF8B5CF6),
      id: m.id,
      title: '${m.studentName} — ${m.subjectName}',
      status: st,
      fields: [
        {'Reg No': m.studentRegNo},
        {'Subject Code': m.subjectCode},
        {'Faculty Entry': '${m.facultyEntry}'},
        {'Exam Record': '${m.examRecord}'},
        {'Final Result': '${m.finalResult}'},
        {'Mismatch': m.isMismatch ? 'Yes' : 'No'},
        {'Record Status': m.status},
        {'Note': m.mismatchReason},
      ],
    )).toList();
  }

  // ---- Faculty Reports ----
  List<Widget> _facultyCards() {
    List<FacultyReportRecord> list;
    final st = target.status;
    if (st == 'Verified') {
      list = state.facultyReports.where((f) => f.status == 'Verified').toList();
    } else if (st == 'Pending') {
      list = state.facultyReports.where((f) => f.status == 'Pending').toList();
    } else if (st == 'Issues') {
      list = state.facultyReports.where((f) => f.hasConflict || f.status == 'Rejected').toList();
    } else {
      list = state.facultyReports;
    }
    if (list.isEmpty) return _syntheticCards(st, 'Faculty Report');
    return list.map((f) => _BaseRecordCard(
      icon: Icons.badge_rounded,
      color: const Color(0xFFF59E0B),
      id: f.id,
      title: f.facultyName,
      status: st,
      fields: [
        {'Department': f.department},
        {'Report Type': f.reportType},
        {'Reported Attendance': '${f.reportedAttendance}%'},
        {'Actual Attendance': '${f.actualAttendance}%'},
        {'Syllabus Completion': '${f.syllabusCompletionPercent}%'},
        {'Conflict': f.hasConflict ? 'Yes' : 'No'},
        {'Record Status': f.status},
        {'Conflict Details': f.conflictDetails},
      ],
    )).toList();
  }

  // ---- Question Papers ----
  List<Widget> _questionPaperCards() {
    List<QuestionPaperRecord> list;
    final st = target.status;
    if (st == 'Verified') {
      list = state.questionPapers.where((q) => q.status == 'Verified').toList();
    } else if (st == 'Pending') {
      list = state.questionPapers.where((q) => q.status == 'Pending').toList();
    } else if (st == 'Issues') {
      list = state.questionPapers.where((q) => q.status != 'Verified' && q.status != 'Pending').toList();
    } else {
      list = state.questionPapers;
    }
    if (list.isEmpty) return _syntheticCards(st, 'Question Paper');
    return list.map((q) => _BaseRecordCard(
      icon: Icons.description_rounded,
      color: const Color(0xFF3B82F6),
      id: q.id,
      title: '${q.courseCode} — ${q.courseTitle}',
      status: st,
      fields: [
        {'Regulation': q.regulation},
        {'Department': q.department},
        {'Bloom Taxonomy': q.bloomTaxonomyCompliant ? 'Compliant' : 'Non-compliant'},
        {'Syllabus Mapped': q.syllabusMapped ? 'Yes' : 'No'},
        {'HOD Approved': q.hodApproved ? 'Yes' : 'Pending'},
        {'CoE Approved': q.coeApproved ? 'Yes' : 'Pending'},
        {'Record Status': q.status},
      ],
    )).toList();
  }

  // ---- Research Records ----
  List<Widget> _researchCards() {
    List<ResearchRecord> list;
    final st = target.status;
    if (st == 'Verified') {
      list = state.researchRecords.where((r) => r.status == 'Verified').toList();
    } else if (st == 'Pending') {
      list = state.researchRecords.where((r) => r.status == 'Pending').toList();
    } else if (st == 'Issues') {
      list = state.researchRecords
          .where((r) => r.status == 'Discrepancy Flagged' || r.duplicateFlag)
          .toList();
    } else {
      list = state.researchRecords;
    }
    if (list.isEmpty) return _syntheticCards(st, 'Research');
    return list.map((r) => _BaseRecordCard(
      icon: Icons.science_rounded,
      color: const Color(0xFF0D9488),
      id: r.id,
      title: r.title,
      status: st,
      fields: [
        {'Authors': r.authors},
        {'Type': r.type},
        {'Journal': r.journalName},
        {'Indexing': r.indexing},
        {'DOI': r.doi},
        {'Metadata Match': r.metadataMatch ? 'Yes' : 'No'},
        {'Duplicate Flag': r.duplicateFlag ? 'Flagged' : 'None'},
        {'Record Status': r.status},
      ],
    )).toList();
  }

  // ---- Synthetic placeholder cards ----
  List<Widget> _syntheticCards(String status, String module) {
    final Map<String, List<Map<String, String>>> examples = {
      'Pending': [
        {'id': '$module-PEND-001', 'title': '$module Record — Pending Review', 'note': 'Submitted — awaiting auditor verification'},
        {'id': '$module-PEND-002', 'title': '$module Record — Evidence Pending', 'note': 'Evidence upload required before verification'},
        {'id': '$module-PEND-003', 'title': '$module Record — Under Review', 'note': 'Under active audit review'},
      ],
      'Issues': [
        {'id': '$module-ISS-001', 'title': '$module Record — Discrepancy Detected', 'note': 'Data mismatch flagged — awaiting HOD response'},
        {'id': '$module-ISS-002', 'title': '$module Record — Missing Data', 'note': 'Required fields missing — correction requested'},
      ],
      'Progress': [
        {'id': '$module-PRG-001', 'title': '$module — Verified Records', 'note': 'All verified records included'},
        {'id': '$module-PRG-002', 'title': '$module — Pending Records', 'note': 'Records awaiting verification'},
        {'id': '$module-PRG-003', 'title': '$module — Issue Records', 'note': 'Records with flagged discrepancies'},
      ],
    };
    final data = examples[status] ?? [
      {'id': '$module-001', 'title': '$module Record', 'note': 'Full data available after system sync'},
    ];
    return data.map((d) => _BaseRecordCard(
      icon: Icons.folder_open_rounded,
      color: const Color(0xFF6366F1),
      id: d['id']!,
      title: d['title']!,
      status: status,
      fields: [
        {'Academic Year': state.selectedAcademicYear},
        {'Note': d['note']!},
      ],
    )).toList();
  }
}

// ============================================================
// BASE RECORD CARD
// ============================================================
class _BaseRecordCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String id;
  final String title;
  final List<Map<String, String>> fields;
  final String status;

  const _BaseRecordCard({
    required this.icon,
    required this.color,
    required this.id,
    required this.title,
    required this.fields,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor(status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sc.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: sc.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sc.withValues(alpha: 0.3)),
                ),
                child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: sc)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(id, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: fields.map((f) {
              final k = f.keys.first;
              final v = f.values.first;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$k: ',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  Text(v, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

Color _statusColor(String status) {
  switch (status) {
    case 'Verified':
      return const Color(0xFF10B981);
    case 'Pending':
      return const Color(0xFFF59E0B);
    case 'Issues':
      return const Color(0xFFEF4444);
    default:
      return AppColors.accent;
  }
}

Color _moduleColor(String name) {
  switch (name) {
    case 'Student Records':
      return const Color(0xFF6366F1);
    case 'Assignments':
      return const Color(0xFF10B981);
    case 'Marks':
      return const Color(0xFF8B5CF6);
    case 'Faculty Reports':
      return const Color(0xFFF59E0B);
    case 'Question Papers':
      return const Color(0xFF3B82F6);
    case 'Research & Publications':
      return const Color(0xFF0D9488);
    default:
      return AppColors.accent;
  }
}

IconData _moduleIcon(String name) {
  switch (name) {
    case 'Student Records':
      return Icons.school_rounded;
    case 'Assignments':
      return Icons.assignment_rounded;
    case 'Marks':
      return Icons.analytics_rounded;
    case 'Faculty Reports':
      return Icons.badge_rounded;
    case 'Question Papers':
      return Icons.description_rounded;
    case 'Research & Publications':
      return Icons.science_rounded;
    default:
      return Icons.folder_rounded;
  }
}

String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';

