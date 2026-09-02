import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/models.dart';
import '../providers/audit_state.dart';
import '../widgets/status_badge.dart';

class ExamineDocumentModal extends StatefulWidget {
  final ResearchRecord record;
  final AuditState state;

  const ExamineDocumentModal({
    super.key,
    required this.record,
    required this.state,
  });

  @override
  State<ExamineDocumentModal> createState() => _ExamineDocumentModalState();
}

class _ExamineDocumentModalState extends State<ExamineDocumentModal> {
  late Map<String, String> _checklist;
  late String _auditStatus;
  late TextEditingController _remarksController;
  int _currentPage = 1;
  final int _totalPages = 0;

  final List<String> _checklistItems = [
    'Paper Title',
    'Authors',
    'Faculty Affiliation',
    'Department',
    'Publication Details',
    'DOI',
    'Journal / Conference',
    'Indexing Information',
  ];

  final List<String> _auditStatusOptions = [
    'Pending Examination',
    'Under Review',
    'Verified',
    'Needs Correction',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _checklist = Map<String, String>.from(widget.record.verificationChecklist);
    _auditStatus = widget.record.status;
    _remarksController = TextEditingController(text: widget.record.auditorRemarks);
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _saveDetails() {
    String docStatus = 'Under Examination';
    if (_auditStatus == 'Verified') {
      docStatus = 'Verified';
    } else if (_auditStatus == 'Needs Correction') {
      docStatus = 'Needs Correction';
    } else if (_auditStatus == 'Rejected') {
      docStatus = 'Needs Correction';
    }

    final updatedRecord = ResearchRecord(
      id: widget.record.id,
      organization: widget.record.organization,
      department: widget.record.department,
      facultyName: widget.record.facultyName,
      title: widget.record.title,
      authors: widget.record.authors,
      type: widget.record.type,
      doi: widget.record.doi,
      journalName: widget.record.journalName,
      indexing: widget.record.indexing,
      year: widget.record.year,
      description: widget.record.description,
      documentName: widget.record.documentName,
      documentType: widget.record.documentType,
      documentSize: widget.record.documentSize,
      documentStatus: docStatus,
      metadataMatch: widget.record.metadataMatch,
      duplicateFlag: widget.record.duplicateFlag,
      status: _auditStatus,
      verificationChecklist: _checklist,
      auditorRemarks: _remarksController.text.trim(),
    );

    widget.state.updateResearchRecord(updatedRecord);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.all(isMobile ? 8 : 24),
      backgroundColor: Colors.white,
      child: Container(
        width: isMobile ? double.infinity : 1100,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Top Title Bar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.find_in_page_rounded, color: AppColors.accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Document Examination — ${widget.record.id}',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(status: _auditStatus, isCompact: true),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.record.facultyName} • ${widget.record.department}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 20),

            // Scrollable Examination Content
            Flexible(
              child: SingleChildScrollView(
                child: isMobile
                    ? Column(
                        children: [
                          _buildDocumentPreviewPane(),
                          const SizedBox(height: 16),
                          _buildResearchDetailsPane(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: _buildDocumentPreviewPane()),
                          const SizedBox(width: 20),
                          Expanded(flex: 6, child: _buildResearchDetailsPane()),
                        ],
                      ),
              ),
            ),

            const Divider(height: 20),

            // Bottom Action Footer (Responsive for Mobile)
            if (isMobile) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Record ID: ${widget.record.id} • DOI: ${widget.record.doi}',
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontFamily: 'monospace'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _saveDetails,
                          icon: const Icon(Icons.save_rounded, size: 16),
                          label: const Text('Save Research Details'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Record ID: ${widget.record.id} • DOI: ${widget.record.doi}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'monospace'),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _saveDetails,
                        icon: const Icon(Icons.save_rounded, size: 16),
                        label: const Text('Save Research Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // LEFT SIDE: DOCUMENT PREVIEW COMPONENT
  Widget _buildDocumentPreviewPane() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Header Info Bar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.record.documentName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${widget.record.documentType} • ${widget.record.documentSize} • $_totalPages Pages',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary, size: 20),
                onSelected: (val) => widget.state.showToast('Action $val triggered for ${widget.record.documentName}'),
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'view', child: Text('Open Fullscreen View')),
                  const PopupMenuItem(value: 'download', child: Text('Download Document PDF')),
                  const PopupMenuItem(value: 'verify_hash', child: Text('Verify Digital Signature')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Document Viewer Navigation Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Page $_currentPage of $_totalPages',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _currentPage < _totalPages ? () => setState(() => _currentPage++) : null,
                    ),
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () => widget.state.showToast('Simulated Document Downloaded: ${widget.record.documentName}'),
                      child: const Row(
                        children: [
                          Icon(Icons.download_rounded, size: 14, color: AppColors.accent),
                          SizedBox(width: 4),
                          Text('Download', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Simulated Manuscript View Page
          Container(
            height: 440,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Journal Header watermark line
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.record.journalName.toUpperCase(),
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'VOL. ${widget.record.year} • ISSUE 04',
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Divider(height: 16),

                // DOI Watermark Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'DOI: ${widget.record.doi} • Indexing: ${widget.record.indexing}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accent, fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 14),

                // Manuscript Paper Title
                Text(
                  widget.record.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), height: 1.3),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Authors & Affiliations
                Text(
                  widget.record.authors,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent),
                ),
                const SizedBox(height: 2),
                Text(
                  'Department of ${widget.record.department}, ${widget.record.organization}',
                  style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),

                // Abstract Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: const Border(left: BorderSide(color: AppColors.accent, width: 3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ABSTRACT',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.record.description,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Document stamp footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.verified_user_rounded, size: 14, color: Color(0xFF10B981)),
                          SizedBox(width: 6),
                          Text('ERP Institutional Repository Sealed Document', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                        ],
                      ),
                      Text('VERIFIED COPY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // RIGHT SIDE: RESEARCH DETAILS, VERIFICATION CHECKLIST & REMARKS
  Widget _buildResearchDetailsPane() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Research Record Summary Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: AppColors.accent),
                  SizedBox(width: 6),
                  Text('Research Metadata Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                ],
              ),
              const Divider(height: 16),
              _detailRow('Organization', widget.record.organization),
              _detailRow('Department', widget.record.department),
              _detailRow('Faculty / Author', widget.record.facultyName),
              _detailRow('Publication Title', widget.record.title),
              _detailRow('Authors', widget.record.authors),
              _detailRow('Publication Type', widget.record.type),
              _detailRow('Year', widget.record.year),
              _detailRow('Journal / Conf.', widget.record.journalName),
              _detailRow('DOI Reference', widget.record.doi, isMonospace: true),
              _detailRow('Indexing', widget.record.indexing),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // VERIFICATION CHECKLIST SECTION
        Container(
          padding: const EdgeInsets.all(14),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.fact_check_rounded, size: 16, color: AppColors.accent),
                      SizedBox(width: 6),
                      Text('Auditor Verification Checklist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        for (var item in _checklistItems) {
                          _checklist[item] = 'Verified';
                        }
                      });
                    },
                    child: const Text('Mark All Verified', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Divider(height: 12),
              Column(
                children: _checklistItems.map((item) => _buildChecklistItem(item)).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // AUDITOR REMARKS & AUDIT STATUS SELECTION
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.rate_review_rounded, size: 16, color: AppColors.accent),
                  SizedBox(width: 6),
                  Text('Auditor Remarks & Audit Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Auditor Remarks', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              TextField(
                controller: _remarksController,
                maxLines: 2,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Enter observation details (e.g., Paper details match uploaded document. DOI verified against CrossRef)...',
                  hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Final Audit Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _auditStatusOptions.map((opt) {
                  final isSelected = _auditStatus == opt;
                  return ChoiceChip(
                    label: Text(opt),
                    selected: isSelected,
                    selectedColor: _getStatusBgColor(opt),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? _getStatusFgColor(opt) : AppColors.textPrimary,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _auditStatus = opt);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(String item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              item,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
          Row(
            children: [
              _buildStatusOptionChip(item, 'Verified', '✓ Verified', const Color(0xFFECFDF5), const Color(0xFF059669)),
              const SizedBox(width: 4),
              _buildStatusOptionChip(item, 'Needs Correction', '⚠ Needs Correction', const Color(0xFFFEE2E2), const Color(0xFFDC2626)),
              const SizedBox(width: 4),
              _buildStatusOptionChip(item, 'Pending', '○ Pending', const Color(0xFFF1F5F9), const Color(0xFF64748B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOptionChip(String item, String optionValue, String label, Color bg, Color fg) {
    final isSelected = (_checklist[item] ?? 'Pending') == optionValue;
    return InkWell(
      onTap: () {
        setState(() {
          _checklist[item] = optionValue;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? bg : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? fg : AppColors.border, width: isSelected ? 1.5 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? fg : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isMonospace = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: isMonospace ? 'monospace' : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusBgColor(String status) {
    if (status == 'Verified') return const Color(0xFFECFDF5);
    if (status == 'Needs Correction' || status == 'Rejected') return const Color(0xFFFEE2E2);
    if (status == 'Under Review' || status == 'Pending Examination') return const Color(0xFFFEF3C7);
    return const Color(0xFFEFF6FF);
  }

  Color _getStatusFgColor(String status) {
    if (status == 'Verified') return const Color(0xFF059669);
    if (status == 'Needs Correction' || status == 'Rejected') return const Color(0xFFDC2626);
    if (status == 'Under Review' || status == 'Pending Examination') return const Color(0xFFD97706);
    return const Color(0xFF2563EB);
  }
}
