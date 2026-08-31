import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../widgets/status_badge.dart';
import '../widgets/action_modal.dart';
import '../services/api_service.dart';
import '../widgets/api_error_widget.dart';

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

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, String>> _allTasks = [];

  @override
  void initState() {
    super.initState();
    _loadQueueFromApi();
  }

  Future<void> _loadQueueFromApi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rawTasks = await ApiService.instance.fetchWorkQueue();
      if (mounted) {
        setState(() {
          _allTasks = rawTasks.map((t) => {
            'id': (t['id'] ?? '').toString(),
            'target': (t['target'] ?? '').toString(),
            'module': (t['module'] ?? '').toString(),
            'dept': (t['dept'] ?? '').toString(),
            'priority': (t['priority'] ?? 'Normal').toString(),
            'status': (t['status'] ?? 'Pending Verification').toString(),
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading work queue tasks from PostgreSQL database...', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return ApiErrorWidget(
        errorMessage: _errorMessage!,
        onRetry: () => _loadQueueFromApi(),
      );
    }

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
        // Horizontally Scrollable Status Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
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
        ),

        const SizedBox(height: 20),

        // Clean Full-Width Task Table Container (Responsive Scroll)
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
                    const Flexible(
                      child: Text(
                        'Auditor Work Queue Tasks',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                            _selectedDept == 'All Departments' ? 'Filter Dept' : 'Dept: $_selectedDept',
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
                          textAlign: TextAlign.center,
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
            ],
          ),
        ),
      ],
    );
  }
}
