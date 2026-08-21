import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../widgets/status_badge.dart';
import '../widgets/action_modal.dart';

class WorkQueueView extends StatefulWidget {
  final AuditState state;

  const WorkQueueView({super.key, required this.state});

  @override
  State<WorkQueueView> createState() => _WorkQueueViewState();
}

class _WorkQueueViewState extends State<WorkQueueView> {
  String _activeTab = 'All Tasks';
  String _selectedDept = 'All Departments';
  String _selectedPriority = 'All Priorities';

  final List<Map<String, String>> _allTasks = [
    {
      'id': 'AUD-2026-001245',
      'target': 'MRK-2025-02 (23CS0456)',
      'module': 'Marks Audit',
      'dept': 'CSE',
      'priority': 'High',
      'status': 'Correction Requested',
    },
    {
      'id': 'AUD-2026-001244',
      'target': 'ASN-MECH-301 (Thermal Engg)',
      'module': 'Assignment Audit',
      'dept': 'MECH',
      'priority': 'High',
      'status': 'Correction Requested',
    },
    {
      'id': 'AUD-2026-001243',
      'target': 'QP-23ME202 (Fluid Mech)',
      'module': 'Question Paper',
      'dept': 'MECH',
      'priority': 'Medium',
      'status': 'Pending Verification',
    },
    {
      'id': 'AUD-2026-001242',
      'target': 'REP-CSE-101 (Dr. R. Kumar)',
      'module': 'Faculty Report',
      'dept': 'CSE',
      'priority': 'Medium',
      'status': 'Under Review',
    },
    {
      'id': 'AUD-2026-001241',
      'target': 'MRK-MECH-108 (CAD/CAM)',
      'module': 'Marks Audit',
      'dept': 'MECH',
      'priority': 'High',
      'status': 'Under Review',
    },
    {
      'id': 'AUD-2026-001240',
      'target': 'REP-MECH-405 (Mentoring)',
      'module': 'Faculty Report',
      'dept': 'MECH',
      'priority': 'Normal',
      'status': 'Completed',
    },
    {
      'id': 'AUD-2026-001239',
      'target': 'QP-23IT204',
      'module': 'Question Paper',
      'dept': 'IT',
      'priority': 'Low',
      'status': 'Pending Verification',
    },
    {
      'id': 'AUD-2026-001238',
      'target': 'RES-MECH-2025 (Solar Paper)',
      'module': 'Research Audit',
      'dept': 'MECH',
      'priority': 'Medium',
      'status': 'Re-verification',
    },
    {
      'id': 'AUD-2026-001235',
      'target': 'ASN-102 (Priya Sharma)',
      'module': 'Assignment Audit',
      'dept': 'IT',
      'priority': 'High',
      'status': 'Correction Requested',
    },
    {
      'id': 'AUD-2026-001230',
      'target': 'RES-2025-02',
      'module': 'Research Audit',
      'dept': 'ECE',
      'priority': 'Medium',
      'status': 'Re-verification',
    },
    {
      'id': 'AUD-2026-001210',
      'target': '23CS001 (Adithya V)',
      'module': 'Student Audit',
      'dept': 'CSE',
      'priority': 'Normal',
      'status': 'Completed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter tasks
    final filteredTasks = _allTasks.where((task) {
      if (_activeTab != 'All Tasks') {
        final status = task['status']!;
        if (_activeTab == 'Pending Verification' && status != 'Pending Verification') return false;
        if (_activeTab == 'In Review' && status != 'Under Review') return false;
        if (_activeTab == 'Correction Requested' && status != 'Correction Requested') return false;
        if (_activeTab == 'Re-verification' && status != 'Re-verification') return false;
        if (_activeTab == 'Completed' && status != 'Completed') return false;
      }
      if (_selectedDept != 'All Departments' && task['dept'] != _selectedDept) return false;
      if (_selectedPriority != 'All Priorities' && task['priority'] != _selectedPriority) return false;
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Tabs
        Row(
          children: ['All Tasks', 'Pending Verification', 'In Review', 'Correction Requested', 'Re-verification', 'Completed'].map((tab) {
            final isSel = _activeTab == tab;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(tab),
                selected: isSel,
                onSelected: (val) {
                  if (val) setState(() => _activeTab = tab);
                },
                selectedColor: const Color(0xFF4F46E5),
                labelStyle: TextStyle(
                  color: isSel ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // Clean Full-Width Task Table Container (Matching Reference Wireframe)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    const Text('Auditor Work Queue Tasks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                    const Spacer(),
                    // Department Filter Popup
                    PopupMenuButton<String>(
                      initialValue: _selectedDept,
                      tooltip: 'Filter by Department',
                      onSelected: (val) => setState(() => _selectedDept = val),
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'All Departments', child: Text('All Departments')),
                        PopupMenuItem(value: 'CSE', child: Text('CSE Department')),
                        PopupMenuItem(value: 'IT', child: Text('IT Department')),
                        PopupMenuItem(value: 'ECE', child: Text('ECE Department')),
                        PopupMenuItem(value: 'MECH', child: Text('MECH Department')),
                      ],
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list_rounded, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            _selectedDept == 'All Departments' ? 'Filter by Priority / Dept' : 'Dept: $_selectedDept',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              if (filteredTasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 36, color: AppColors.textMuted),
                        const SizedBox(height: 10),
                        Text(
                          'No tasks found matching status "$_activeTab" and department "$_selectedDept"',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _activeTab = 'All Tasks';
                              _selectedDept = 'All Departments';
                              _selectedPriority = 'All Priorities';
                            });
                          },
                          child: const Text('Reset Filters'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 300,
                    child: DataTable(
                      columnSpacing: 28,
                      horizontalMargin: 20,
                      columns: const [
                        DataColumn(label: Text('Task / Case ID', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                        DataColumn(label: Text('Target Record', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                        DataColumn(label: Text('Module', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                        DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                        DataColumn(label: Text('Priority', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                        DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                        DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                      ],
                      rows: filteredTasks.map((t) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                t['id']!,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), fontSize: 13),
                              ),
                            ),
                            DataCell(Text(t['target']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                            DataCell(Text(t['module']!)),
                            DataCell(Text(t['dept']!)),
                            DataCell(StatusBadge(status: t['priority']!, isCompact: true, showDot: false)),
                            DataCell(StatusBadge(status: t['status']!, isCompact: true, showDot: false)),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_red_eye_outlined, size: 20, color: Color(0xFF4F46E5)),
                                    tooltip: 'Review Task',
                                    onPressed: () {
                                      widget.state.setActiveModule(t['module']!);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.flag_outlined, size: 20, color: Color(0xFFDC2626)),
                                    tooltip: 'Flag Discrepancy',
                                    onPressed: widget.state.canFlagIssue
                                        ? () {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => ActionModal(recordId: t['target']!, actionType: 'Flag Issue', state: widget.state),
                                            );
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
