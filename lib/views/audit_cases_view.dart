import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../widgets/status_badge.dart';

class AuditCasesView extends StatelessWidget {
  final AuditState state;

  const AuditCasesView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Audit Case Management & Discrepancy Tracking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Track audit cases through their complete lifecycle: Detected → Under Review → Correction Requested → Corrected → Re-verified → Closed', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        
        const SizedBox(height: 20),

        // KPI Cards
        Row(
          children: [
            _buildKpiCard('Total Active Cases', '3', Icons.folder_open, Colors.blue),
            const SizedBox(width: 16),
            _buildKpiCard('High Severity', '1', Icons.warning_amber_rounded, Colors.red),
            const SizedBox(width: 16),
            _buildKpiCard('Under Review', '1', Icons.pending_actions, Colors.orange),
            const SizedBox(width: 16),
            _buildKpiCard('Correction Requested', '1', Icons.edit_note, Colors.purple),
          ],
        ),

        const SizedBox(height: 24),

        // Toolbar
        Row(
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
                  decoration: InputDecoration(
                    hintText: 'Search by Case ID, Target Record, Assigned To...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.filter_list, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Text('All Cases', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
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
              rows: state.auditCases.map((c) {
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
                              state.showToast('Inspecting Audit Case timeline for ${c.caseId}');
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
    return Expanded(
      child: Container(
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
      ),
    );
  }
}
