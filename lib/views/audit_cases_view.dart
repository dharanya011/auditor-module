import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../widgets/status_badge.dart';
import '../widgets/responsive_row.dart';

class AuditCasesView extends StatefulWidget {
  final AuditState state;

  const AuditCasesView({super.key, required this.state});

  @override
  State<AuditCasesView> createState() => _AuditCasesViewState();
}

class _AuditCasesViewState extends State<AuditCasesView> {
  String _searchQuery = '';
  String _selectedCategory = 'All Cases';

  final List<String> _categories = [
    'All Cases',
    'High Severity',
    'Under Review',
    'Correction Requested',
    'Closed',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredCases = widget.state.auditCases.where((c) {
      final matchesSearch = _searchQuery.isEmpty ||
          c.caseId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.targetRecordId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.assignedTo.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All Cases' ||
          c.severity.toLowerCase() == _selectedCategory.toLowerCase() ||
          c.lifecycleStage.toLowerCase() == _selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();

    final totalCases = widget.state.auditCases.length;
    final highSeverity = widget.state.auditCases.where((c) => c.severity.toLowerCase() == 'high' || c.severity.toLowerCase() == 'critical').length;
    final underReview = widget.state.auditCases.where((c) => c.lifecycleStage.toLowerCase() == 'under review').length;
    final correctionReq = widget.state.auditCases.where((c) => c.lifecycleStage.toLowerCase() == 'correction requested').length;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Audit Case Management & Discrepancy Tracking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Track audit cases through their complete lifecycle: Detected → Under Review → Correction Requested → Corrected → Re-verified → Closed', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        
        const SizedBox(height: 20),

        // KPI Cards
        ResponsiveRow(
          children: [
            _buildKpiCard('Total Active Cases', '$totalCases', Icons.folder_open, Colors.blue),
            _buildKpiCard('High Severity', '$highSeverity', Icons.warning_amber_rounded, Colors.red),
            _buildKpiCard('Under Review', '$underReview', Icons.pending_actions, Colors.orange),
            _buildKpiCard('Correction Requested', '$correctionReq', Icons.edit_note, Colors.purple),
          ],
        ),

        const SizedBox(height: 24),

        // Toolbar
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            if (isMobile) {
              return Column(
                children: [
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search by Case ID, Target Record...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                        prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isDense: true,
                              isExpanded: true,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                              items: _categories.map((cat) {
                                return DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedCategory = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search by Case ID, Target Record, Assigned To...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                        prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isDense: true,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                          items: _categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        
        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.tableHeaderBg),
              columnSpacing: 10,
              horizontalMargin: 20,
              columns: const [
                DataColumn(label: SizedBox(width: 200, child: Text('CASE ID & TITLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                DataColumn(label: SizedBox(width: 120, child: Text('TARGET RECORD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                DataColumn(label: SizedBox(width: 100, child: Text('SEVERITY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                DataColumn(label: SizedBox(width: 150, child: Text('ASSIGNED TO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                DataColumn(label: SizedBox(width: 140, child: Text('LIFECYCLE STAGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                DataColumn(label: SizedBox(width: 100, child: Text('CREATED DATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                DataColumn(label: SizedBox(width: 120, child: Text('ACTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
              ],
              rows: filteredCases.map((c) {
                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accentLight.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(c.caseId, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent, fontSize: 11, fontFamily: 'monospace')),
                            ),
                            const SizedBox(height: 4),
                            Text(c.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                    DataCell(SizedBox(width: 120, child: Text(c.targetRecordId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)))),
                    DataCell(SizedBox(width: 100, child: StatusBadge(status: c.severity, isCompact: true))),
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.grey[200],
                              child: Text(c.assignedTo.substring(0, 1), style: const TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(c.assignedTo, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                    ),
                    DataCell(SizedBox(width: 140, child: StatusBadge(status: c.lifecycleStage, isCompact: true))),
                    DataCell(SizedBox(width: 100, child: Text(c.createdDate, style: const TextStyle(fontSize: 12)))),
                    DataCell(
                      SizedBox(
                        width: 120,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () {
                              widget.state.showToast('Inspecting Audit Case timeline for ${c.caseId}');
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.accentLight,
                              foregroundColor: AppColors.accent,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            icon: const Icon(Icons.manage_search, size: 16),
                            label: const Text('Manage', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
