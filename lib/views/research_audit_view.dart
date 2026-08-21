import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../widgets/status_badge.dart';

class ResearchAuditView extends StatefulWidget {
  final AuditState state;

  const ResearchAuditView({super.key, required this.state});

  @override
  State<ResearchAuditView> createState() => _ResearchAuditViewState();
}

class _ResearchAuditViewState extends State<ResearchAuditView> {
  String _filterType = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final records = widget.state.researchRecords.where((r) {
      if (_filterType != 'All' && r.type != _filterType) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final match = r.id.toLowerCase().contains(query) ||
            r.title.toLowerCase().contains(query) ||
            r.authors.toLowerCase().contains(query) ||
            r.doi.toLowerCase().contains(query) ||
            r.journalName.toLowerCase().contains(query);
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
                  'Research, Publications, Patents & Grants Audit',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Verifying paper titles, author affiliations, CrossRef DOI metadata, and Scopus/Web of Science indexing.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: widget.state.canVerify ? () => widget.state.showToast('Verifying DOIs against CrossRef REST API...') : null,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Sync CrossRef DOI'),
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

        // KPI Summary Cards Row
        Row(
          children: [
            _buildKpiCard('Total Publications Audited', '1,120 Papers', Icons.science_outlined, const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
            const SizedBox(width: 14),
            _buildKpiCard('CrossRef DOI Verified', '1,048 Papers', Icons.verified_rounded, const Color(0xFF10B981), const Color(0xFFECFDF5)),
            const SizedBox(width: 14),
            _buildKpiCard('DOI Metadata Mismatches', '24 Flags', Icons.error_outline_rounded, const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
            const SizedBox(width: 14),
            _buildKpiCard('Scopus / WoS Indexed', '980 Papers', Icons.auto_awesome_rounded, const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)),
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
                    hintText: 'Search by Paper Title, Author Name, DOI, Journal Name...',
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
                  _buildFilterChip('All Types', 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Journal Articles', 'Journal Article'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Conference Papers', 'Conference Paper'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Executive Data Table Container (Minimum Width 1350px = ZERO OVERLAPS)
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
                dataRowMinHeight: 76,
                dataRowMaxHeight: 76,
                horizontalMargin: 24,
                columnSpacing: 36,
                columns: const [
                  DataColumn(
                    label: SizedBox(
                      width: 280,
                      child: Text('PUBLICATION TITLE & AUTHORS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 140,
                      child: Text('TYPE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 200,
                      child: Text('DOI REFERENCE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 200,
                      child: Text('JOURNAL / INDEXING', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 140,
                      child: Text('DOI METADATA MATCH', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 140,
                      child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 120,
                      child: Text('ACTION', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8, color: AppColors.textSecondary)),
                    ),
                  ),
                ],
                rows: records.map((r) {
                  return DataRow(
                    cells: [
                      // Publication Title & Authors
                      DataCell(
                        SizedBox(
                          width: 280,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                r.authors,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Type Badge
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              r.type,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.accent),
                            ),
                          ),
                        ),
                      ),

                      // DOI Reference
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
                            child: Text(
                              r.doi,
                              style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),

                      // Journal / Indexing
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.journalName,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Indexing: ${r.indexing}',
                                style: const TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // DOI Metadata Match Status
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: r.metadataMatch ? const Color(0xFFECFDF5) : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(r.metadataMatch ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded, size: 12, color: r.metadataMatch ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                                const SizedBox(width: 4),
                                Text(
                                  r.metadataMatch ? '100% DOI Match' : 'Mismatch',
                                  style: TextStyle(color: r.metadataMatch ? const Color(0xFF10B981) : const Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Status Badge
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: StatusBadge(status: r.status, isCompact: true),
                        ),
                      ),

                      // Action Button
                      DataCell(
                        SizedBox(
                          width: 120,
                          child: ElevatedButton.icon(
                            onPressed: widget.state.canVerify
                                ? () {
                                    widget.state.showToast('Verifying DOI metadata against CrossRef for ${r.id}...');
                                  }
                                : null,
                            icon: const Icon(Icons.link_rounded, size: 14),
                            label: const Text('Verify DOI'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    final isSel = _filterType == key;
    return InkWell(
      onTap: () => setState(() => _filterType = key),
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
