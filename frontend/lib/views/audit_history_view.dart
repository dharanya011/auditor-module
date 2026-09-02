import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../widgets/responsive_row.dart';

class AuditHistoryView extends StatefulWidget {
  final AuditState state;

  const AuditHistoryView({super.key, required this.state});

  @override
  State<AuditHistoryView> createState() => _AuditHistoryViewState();
}

class _AuditHistoryViewState extends State<AuditHistoryView> {
  String _searchQuery = '';
  String _selectedDateFilter = 'All Time';
  String _selectedActionFilter = 'All Actions';

  final List<String> _dateFilters = ['All Time', 'Last 7 Days', 'Today'];
  final List<String> _actionFilters = [
    'All Actions',
    'VERIFY_RECORD',
    'FLAG_DISCREPANCY',
    'CORRECTION_REQ',
    'LOG_SYSTEM',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredLogs = widget.state.auditLogs.where((l) {
      final matchesSearch = _searchQuery.isEmpty ||
          l.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.auditorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.ipAddress.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.action.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.recordId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.details.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesAction = _selectedActionFilter == 'All Actions' ||
          l.action.toLowerCase() == _selectedActionFilter.toLowerCase();

      return matchesSearch && matchesAction;
    }).toList();

    final totalLogsCount = widget.state.auditLogs.length;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 4,
          children: const [
            Text('Immutable Audit Ledger Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Security Guarantee: Audit logs are cryptographically timestamped & immutable.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        
        const SizedBox(height: 20),

        // KPI Cards
        ResponsiveRow(
          children: [
            _buildKpiCard('Total Audit Logs', '$totalLogsCount Logs', Icons.history_rounded, Colors.blue),
            _buildKpiCard('Security Level', 'AES-256 Secured', Icons.security_rounded, Colors.green),
            _buildKpiCard('Last Sync', '—', Icons.sync_rounded, Colors.orange),
            _buildKpiCard('Active Auditors', '—', Icons.admin_panel_settings_rounded, Colors.purple),
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
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search by Log ID, Target Record, IP Address, Action Code...',
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
                  const Icon(Icons.date_range, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDateFilter,
                      isDense: true,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                      items: _dateFilters.map((df) {
                        return DropdownMenuItem(
                          value: df,
                          child: Text(df),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDateFilter = val);
                      },
                    ),
                  ),
                ],
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
                      value: _selectedActionFilter,
                      isDense: true,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                      items: _actionFilters.map((af) {
                        return DropdownMenuItem(
                          value: af,
                          child: Text(af),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedActionFilter = val);
                      },
                    ),
                  ),
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
                DataColumn(label: SizedBox(width: 100, child: Text('LOG ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                DataColumn(label: SizedBox(width: 130, child: Text('TIMESTAMP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                DataColumn(label: SizedBox(width: 160, child: Text('AUDITOR USER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                DataColumn(label: SizedBox(width: 130, child: Text('IP ADDRESS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                DataColumn(label: SizedBox(width: 160, child: Text('ACTION CODE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                DataColumn(label: SizedBox(width: 130, child: Text('TARGET RECORD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                DataColumn(label: SizedBox(width: 320, child: Text('AUDIT DETAILS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
              ],
              rows: filteredLogs.map((l) {
                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 100,
                        child: Text(l.id, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent, fontFamily: 'monospace')),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 130,
                        child: Text(l.timestamp, style: const TextStyle(fontSize: 11)),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 160,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.grey[200],
                              child: Text(l.auditorName.substring(0, 1), style: const TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(l.auditorName, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 130,
                        child: Text(l.ipAddress, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 160,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(4)),
                            child: Text(l.action, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 130,
                        child: Text(l.recordId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 320,
                        child: Text(l.details, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
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
                Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
