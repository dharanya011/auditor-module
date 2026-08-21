import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../widgets/status_badge.dart';
import '../widgets/evidence_modal.dart';

import '../widgets/responsive_row.dart';

class EvidenceRepositoryView extends StatefulWidget {
  final AuditState state;

  const EvidenceRepositoryView({super.key, required this.state});

  @override
  State<EvidenceRepositoryView> createState() => _EvidenceRepositoryViewState();
}

class _EvidenceRepositoryViewState extends State<EvidenceRepositoryView> {
  String _filterDocType = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Filter records
    final items = widget.state.evidenceItems.where((e) {
      if (_filterDocType != 'All' && !e.documentType.contains(_filterDocType)) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final match = e.evidenceId.toLowerCase().contains(query) ||
            e.recordId.toLowerCase().contains(query) ||
            e.fileName.toLowerCase().contains(query) ||
            e.uploadedBy.toLowerCase().contains(query);
        if (!match) return false;
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Title Bar & Action Trigger
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Evidence Repository & Document Management',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cryptographic SHA-256 hash verification backed by AWS S3 Immutable Storage & PostgreSQL Metadata Schema.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: widget.state.canVerify ? () => widget.state.showToast('Re-verifying AWS S3 document hashes...') : null,
              icon: const Icon(Icons.security_rounded, size: 15),
              label: const Text('Verify S3 Hashes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // KPI Summary Cards Row
        ResponsiveRow(
          children: [
            _buildKpiCard('Total Documents Stored', '14,250 Files', Icons.folder_zip_outlined, const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
            _buildKpiCard('AWS S3 Hashes Verified', '14,180 Files', Icons.verified_user_rounded, const Color(0xFF10B981), const Color(0xFFECFDF5)),
            _buildKpiCard('Corrupted Hash Alerts', '12 Flags', Icons.error_outline_rounded, const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
            _buildKpiCard('Version Control Active', 'v1.0 - v2.4', Icons.history_toggle_off_rounded, const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)),
          ],
        ),

        const SizedBox(height: 16),

        // Filter Toolbar Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              // Search Input
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 18),
                    hintText: 'Search by Evidence ID, Record Reference, File Name, Uploader...',
                    hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              const SizedBox(width: 12),

              // Filter Chips
              Row(
                children: [
                  _buildFilterChip('All Files', 'All'),
                  const SizedBox(width: 6),
                  _buildFilterChip('PDF Submissions', 'PDF'),
                  const SizedBox(width: 6),
                  _buildFilterChip('Scans & Certificates', 'Scan'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Executive Data Table Container (Fits 100% inside 1280px screen without ANY cut-offs)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.tableHeaderBg),
              headingRowHeight: 46,
              dataRowMinHeight: 60,
              dataRowMaxHeight: 60,
              horizontalMargin: 14,
              columnSpacing: 10,
              columns: const [
                DataColumn(
                  label: SizedBox(
                    width: 95,
                    child: Text('EVIDENCE ID', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5, color: AppColors.textSecondary)),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 145,
                    child: Text('RECORD ID & TYPE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5, color: AppColors.textSecondary)),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 195,
                    child: Text('FILE NAME', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5, color: AppColors.textSecondary)),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 135,
                    child: Text('UPLOADED BY', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5, color: AppColors.textSecondary)),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 110,
                    child: Text('TIMESTAMP', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5, color: AppColors.textSecondary)),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 60,
                    child: Text('VER', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5, color: AppColors.textSecondary)),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 110,
                    child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5, color: AppColors.textSecondary)),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: 90,
                    child: Text('ACTION', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5, color: AppColors.textSecondary)),
                  ),
                ),
              ],
              rows: items.map((e) {
                return DataRow(
                  cells: [
                    // Evidence ID
                    DataCell(
                      SizedBox(
                        width: 95,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            e.evidenceId,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'monospace', color: AppColors.accent),
                          ),
                        ),
                      ),
                    ),

                    // Record ID & Type
                    DataCell(
                      SizedBox(
                        width: 145,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.recordId,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              e.recordType,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // File Name
                    DataCell(
                      SizedBox(
                        width: 195,
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf_rounded, color: AppColors.accent, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                e.fileName,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Uploaded By
                    DataCell(
                      SizedBox(
                        width: 135,
                        child: Text(
                          e.uploadedBy,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // Timestamp
                    DataCell(
                      SizedBox(
                        width: 110,
                        child: Text(
                          e.uploadDate,
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // Version
                    DataCell(
                      SizedBox(
                        width: 60,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.border)),
                          child: Text(
                            e.version,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'monospace', color: AppColors.textPrimary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                    // Status Badge
                    DataCell(
                      SizedBox(
                        width: 110,
                        child: StatusBadge(status: e.status, isCompact: true),
                      ),
                    ),

                    // Action Button
                    DataCell(
                      SizedBox(
                        width: 90,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => EvidenceModal(
                                item: e,
                                onClose: () => Navigator.pop(ctx),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: const Text('Preview'),
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

  Widget _buildKpiCard(String label, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String key) {
    final isSel = _filterDocType == key;
    return InkWell(
      onTap: () => setState(() => _filterDocType = key),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? AppColors.accent : AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSel ? AppColors.accent : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSel ? Colors.white : AppColors.textPrimary,
            fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
