import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import 'status_badge.dart';

class AuditDetailModal extends StatefulWidget {
  final AuditState state;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color themeColor;
  final String? targetModule;
  final String statusCategory;

  const AuditDetailModal({
    super.key,
    required this.state,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.themeColor,
    this.targetModule,
    required this.statusCategory,
  });

  @override
  State<AuditDetailModal> createState() => _AuditDetailModalState();
}

class _AuditDetailModalState extends State<AuditDetailModal> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_RecordItem> _buildAllRecords() {
    final list = <_RecordItem>[];

    // 1. Students
    for (final s in widget.state.studentRecords) {
      list.add(_RecordItem(
        id: s.registerNo,
        title: s.name,
        module: 'Student Records',
        targetViewModule: 'Student Audit',
        department: s.department,
        status: s.status,
        details: 'Sem ${s.semester} • CGPA: ${s.cgpa} • Attendance: ${s.attendance}%',
      ));
    }

    // 2. Marks
    for (final m in widget.state.marksEntries) {
      list.add(_RecordItem(
        id: m.studentRegNo,
        title: '${m.subjectCode} ${m.subjectName} (${m.studentName})',
        module: 'Marks',
        targetViewModule: 'Marks Audit',
        department: m.studentRegNo.contains('CS') ? 'CSE' : (m.studentRegNo.contains('IT') ? 'IT' : 'ECE'),
        status: m.status,
        details: 'Faculty Entry: ${m.facultyEntry} • Dept: ${m.deptRecord} • Exam: ${m.examRecord} ${m.mismatchReason.isNotEmpty ? "• " + m.mismatchReason : ""}',
      ));
    }

    // 3. Assignments
    for (final a in widget.state.assignmentRecords) {
      list.add(_RecordItem(
        id: a.id,
        title: '${a.title} (${a.studentName})',
        module: 'Assignments',
        targetViewModule: 'Assignment Audit',
        department: a.subject,
        status: a.status,
        details: 'Submitted: ${a.submissionDate} • Score: ${a.marksObtained}/${a.totalMarks} ${a.evidenceFile.isNotEmpty ? "• Hash: " + a.evidenceFile : ""}',
      ));
    }

    // 4. Faculty Reports
    for (final f in widget.state.facultyReports) {
      list.add(_RecordItem(
        id: f.id,
        title: '${f.facultyName} — ${f.reportType}',
        module: 'Faculty Reports',
        targetViewModule: 'Faculty Report Audit',
        department: f.department,
        status: f.status,
        details: 'Reported Att: ${f.reportedAttendance}% vs Biometric: ${f.actualAttendance}%',
      ));
    }

    // 5. Question Papers
    for (final q in widget.state.questionPapers) {
      list.add(_RecordItem(
        id: q.id,
        title: '${q.courseCode} ${q.courseTitle}',
        module: 'Question Papers',
        targetViewModule: 'Question Paper Audit',
        department: q.department,
        status: q.status,
        details: 'Regulation ${q.regulation} • Bloom Compliant: ${q.bloomTaxonomyCompliant} • Mapped: ${q.syllabusMapped}',
      ));
    }

    // 6. Research
    for (final r in widget.state.researchRecords) {
      list.add(_RecordItem(
        id: r.id,
        title: r.title,
        module: 'Research & Publications',
        targetViewModule: 'Research Audit',
        department: r.journalName,
        status: r.status,
        details: 'Authors: ${r.authors} • DOI: ${r.doi} (${r.indexing})',
      ));
    }

    // 7. Critical Issues
    for (final c in widget.state.criticalIssues) {
      list.add(_RecordItem(
        id: c.id,
        title: c.title,
        module: 'Critical Issues',
        targetViewModule: 'Audit Cases',
        department: c.department,
        status: c.priority,
        details: 'Subject Code: ${c.code} • Reported Date: ${c.date}',
      ));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    final allItems = _buildAllRecords();

    final filteredList = allItems.where((item) {
      // 1. Module Filter
      if (widget.targetModule != null && widget.targetModule != 'All') {
        final target = widget.targetModule!.toLowerCase();
        final itemMod = item.module.toLowerCase();
        if (!itemMod.contains(target) && !target.contains(itemMod)) {
          return false;
        }
      }

      // 2. Status Category Filter
      final st = item.status.toLowerCase();
      final cat = widget.statusCategory.toUpperCase();

      if (cat == 'PENDING') {
        if (!st.contains('pending') && !st.contains('review') && !st.contains('under')) {
          return false;
        }
      } else if (cat == 'VERIFIED') {
        if (!st.contains('verified') && !st.contains('approved') && !st.contains('completed') && !st.contains('matched') && !st.contains('passed')) {
          return false;
        }
      } else if (cat == 'ISSUES') {
        if (!st.contains('discrepancy') && !st.contains('flagged') && !st.contains('missing') && !st.contains('conflict') && !st.contains('issue') && !st.contains('mismatch')) {
          return false;
        }
      } else if (cat == 'CRITICAL') {
        if (!st.contains('high') && !st.contains('critical') && !st.contains('discrepancy') && !st.contains('flagged')) {
          return false;
        }
      } else if (cat == 'CORRECTIONS') {
        if (!st.contains('correction') && !st.contains('re-verification') && !st.contains('requested') && !st.contains('action')) {
          return false;
        }
      }

      // 3. Search Box Text Filter
      final q = _searchController.text.trim().toLowerCase();
      if (q.isNotEmpty) {
        final mTitle = item.title.toLowerCase().contains(q);
        final mId = item.id.toLowerCase().contains(q);
        final mDept = item.department.toLowerCase().contains(q);
        final mDetails = item.details.toLowerCase().contains(q);
        if (!mTitle && !mId && !mDept && !mDetails) {
          return false;
        }
      }

      return true;
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: isMobile ? 16 : 24),
      child: Container(
        width: size.width > 900 ? 820 : size.width * 0.95,
        height: size.height > 650 ? 620 : size.height * 0.88,
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.themeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: widget.themeColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.themeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.themeColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${filteredList.length} Records',
                    style: TextStyle(
                      color: widget.themeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 14),

            // Search Bar & Filter Summary Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded, size: 18),
                      hintText: 'Filter records by ID, Name, Department, Details...',
                      hintStyle: const TextStyle(fontSize: 12),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Records List View
            Expanded(
              child: filteredList.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.inbox_rounded, size: 44, color: AppColors.textMuted),
                          SizedBox(height: 10),
                          Text(
                            'No matching records found in this category.',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Try adjusting your search criteria or resetting filters.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x05000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: isMobile
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: AppColors.border),
                                          ),
                                          child: Text(
                                            item.id,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              fontFamily: 'monospace',
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        StatusBadge(status: item.status, isCompact: true),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Module: ${item.module} • Dept: ${item.department}',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.details,
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          widget.state.setActiveModule(item.targetViewModule);
                                        },
                                        icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                                        label: const Text('Audit Record', style: TextStyle(fontSize: 11)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.accent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: Text(
                                        item.id,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${item.module} • Dept: ${item.department} • ${item.details}',
                                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    StatusBadge(status: item.status, isCompact: true),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        widget.state.setActiveModule(item.targetViewModule);
                                      },
                                      icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                                      label: const Text('Audit Record', style: TextStyle(fontSize: 11)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.accent,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                  ],
                                ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 14),

            // Modal Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    widget.state.showToast('Exported ${filteredList.length} records to Excel report');
                  },
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Export Details', style: TextStyle(fontSize: 12)),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close View', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordItem {
  final String id;
  final String title;
  final String module;
  final String targetViewModule;
  final String department;
  final String status;
  final String details;

  _RecordItem({
    required this.id,
    required this.title,
    required this.module,
    required this.targetViewModule,
    required this.department,
    required this.status,
    required this.details,
  });
}
