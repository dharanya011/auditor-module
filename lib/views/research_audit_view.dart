import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/models.dart';
import '../providers/audit_state.dart';
import '../widgets/status_badge.dart';
import '../widgets/responsive_row.dart';
import '../widgets/add_research_paper_dialog.dart';
import '../widgets/examine_document_modal.dart';
import '../widgets/api_error_widget.dart';

class ResearchAuditView extends StatefulWidget {
  final AuditState state;

  const ResearchAuditView({super.key, required this.state});

  @override
  State<ResearchAuditView> createState() => _ResearchAuditViewState();
}

class _ResearchAuditViewState extends State<ResearchAuditView> {
  String _selectedOrg = 'All';
  String _selectedDept = 'All';
  String _selectedFaculty = 'All';
  String _filterType = 'All';
  String _selectedAuditStatus = 'All';
  String _searchQuery = '';

  static const TextStyle _headerStyle = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 11,
    letterSpacing: 0.6,
    color: AppColors.textSecondary,
  );

  final List<String> _organizations = [
    'All',
    'KSR College of Engineering',
    'KSR Institute for Engineering and Technology',
  ];

  final List<String> _departments = [
    'All',
    'Computer Science and Engineering',
    'Information Technology',
    'Electronics and Communication Engineering',
    'Mechanical Engineering',
  ];

  final List<String> _faculties = [
    'All',
    'Dr. R. Kumar',
    'Dr. S. Meena',
    'Dr. A. Priya',
    'Dr. M. Arun',
  ];

  final List<String> _types = [
    'All',
    'Journal Article',
    'Conference Paper',
    'Book Chapter',
    'Other',
  ];

  final List<String> _auditStatuses = [
    'All',
    'Pending Examination',
    'Under Review',
    'Verified',
    'Needs Correction',
    'Rejected',
  ];

  void _openAddPaperDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AddResearchPaperDialog(state: widget.state),
    );
  }

  void _openExamineModal(ResearchRecord record) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ExamineDocumentModal(record: record, state: widget.state),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading research audit records from database...', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    if (widget.state.backendError != null) {
      return ApiErrorWidget(
        errorMessage: widget.state.backendError!,
        onRetry: () => widget.state.loadFromApi(),
      );
    }

    final allRecords = widget.state.researchRecords;

    // Filtered Records
    final records = allRecords.where((r) {
      if (_selectedOrg != 'All' && r.organization != _selectedOrg) return false;
      if (_selectedDept != 'All' && r.department != _selectedDept) return false;
      if (_selectedFaculty != 'All' && r.facultyName != _selectedFaculty) return false;
      if (_filterType != 'All' && r.type != _filterType) return false;
      if (_selectedAuditStatus != 'All' && r.status != _selectedAuditStatus) return false;

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final match = r.id.toLowerCase().contains(query) ||
            r.title.toLowerCase().contains(query) ||
            r.authors.toLowerCase().contains(query) ||
            r.facultyName.toLowerCase().contains(query) ||
            r.department.toLowerCase().contains(query) ||
            r.doi.toLowerCase().contains(query) ||
            r.journalName.toLowerCase().contains(query) ||
            r.documentName.toLowerCase().contains(query);
        if (!match) return false;
      }
      return true;
    }).toList();

    // Dynamic Calculated KPI Counts
    final totalCount = allRecords.length;
    final uploadedCount = allRecords.where((r) => r.documentStatus != 'Not Uploaded').length;
    final pendingCount = allRecords.where((r) => r.status == 'Pending Examination' || r.status == 'Under Review').length;
    final verifiedCount = allRecords.where((r) => r.status == 'Verified').length;
    final needsCorrectionCount = allRecords.where((r) => r.status == 'Needs Correction' || r.status == 'Discrepancy Flagged').length;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Header Title & Primary Actions
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 650;
            return isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Research, Publications & Grants Audit',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Research professor submissions, uploaded documents examination, and auditor details verification workflow.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _openAddPaperDialog,
                            icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                            label: const Text('Add Research Paper'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 2,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: widget.state.canVerify ? () => widget.state.showToast('Syncing DOI metadata with CrossRef API...') : null,
                            icon: const Icon(Icons.sync_rounded, size: 16),
                            label: const Text('Sync CrossRef DOI'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Research, Publications & Grants Audit',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Research professor submissions, uploaded documents examination, and auditor details verification workflow.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _openAddPaperDialog,
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                        label: const Text('Add Research Paper'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: widget.state.canVerify ? () => widget.state.showToast('Syncing DOI metadata with CrossRef API...') : null,
                        icon: const Icon(Icons.sync_rounded, size: 16),
                        label: const Text('Sync CrossRef DOI'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  );
          },
        ),

        const SizedBox(height: 20),

        // Dynamic KPI Cards
        ResponsiveRow(
          spacing: 14,
          children: [
            _buildKpiCard('Total Publications', '$totalCount Records', Icons.science_outlined, const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
            _buildKpiCard('Documents Uploaded', '$uploadedCount Uploaded', Icons.cloud_done_rounded, const Color(0xFF0284C7), const Color(0xFFE0F2FE)),
            _buildKpiCard('Pending Examination', '$pendingCount Papers', Icons.hourglass_top_rounded, const Color(0xFFD97706), const Color(0xFFFEF3C7)),
            _buildKpiCard('Verified Publications', '$verifiedCount Verified', Icons.verified_rounded, const Color(0xFF10B981), const Color(0xFFECFDF5)),
            _buildKpiCard('Needs Correction', '$needsCorrectionCount Papers', Icons.error_outline_rounded, const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
          ],
        ),

        const SizedBox(height: 20),

        // Filter & Search Toolbar (Single Horizontal Row on Desktop Matching Reference Image)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 900;

              if (isMobile) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 18),
                          hintText: 'Search title, faculty, dept, DOI, file name...',
                          hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          isDense: true,
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    _buildSelectFilter('Organization', _organizations, _selectedOrg, (val) => setState(() => _selectedOrg = val!), width: 160),
                    _buildSelectFilter('Department', _departments, _selectedDept, (val) => setState(() => _selectedDept = val!), width: 150),
                    _buildSelectFilter('Research Faculty', _faculties, _selectedFaculty, (val) => setState(() => _selectedFaculty = val!), width: 140),
                    _buildSelectFilter('Publication Type', _types, _filterType, (val) => setState(() => _filterType = val!), width: 140),
                    _buildSelectFilter('Audit Status', _auditStatuses, _selectedAuditStatus, (val) => setState(() => _selectedAuditStatus = val!), width: 140),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: const Text('Search', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _selectedOrg = 'All';
                              _selectedDept = 'All';
                              _selectedFaculty = 'All';
                              _filterType = 'All';
                              _selectedAuditStatus = 'All';
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Reset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                );
              }

              // Desktop: Single horizontal row matching reference image exactly
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 1. Search Box
                    SizedBox(
                      width: 230,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 38,
                            child: TextField(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 18),
                                hintText: 'Search title, faculty, dept, DOI, file name...',
                                hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                isDense: true,
                                filled: true,
                                fillColor: AppColors.background,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 2. Organization Filter
                    _buildSelectFilter('Organization', _organizations, _selectedOrg, (val) => setState(() => _selectedOrg = val!), width: 170),
                    const SizedBox(width: 8),

                    // 3. Department Filter
                    _buildSelectFilter('Department', _departments, _selectedDept, (val) => setState(() => _selectedDept = val!), width: 140),
                    const SizedBox(width: 8),

                    // 4. Faculty Filter
                    _buildSelectFilter('Research Faculty', _faculties, _selectedFaculty, (val) => setState(() => _selectedFaculty = val!), width: 130),
                    const SizedBox(width: 8),

                    // 5. Publication Type Filter
                    _buildSelectFilter('Publication Type', _types, _filterType, (val) => setState(() => _filterType = val!), width: 130),
                    const SizedBox(width: 8),

                    // 6. Audit Status Filter
                    _buildSelectFilter('Audit Status', _auditStatuses, _selectedAuditStatus, (val) => setState(() => _selectedAuditStatus = val!), width: 130),
                    const SizedBox(width: 12),

                    // 7. Search Button
                    SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () => setState(() {}),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text('Search', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 8. Reset Button
                    SizedBox(
                      height: 38,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedOrg = 'All';
                            _selectedDept = 'All';
                            _selectedFaculty = 'All';
                            _filterType = 'All';
                            _selectedAuditStatus = 'All';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Reset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // Table / Mobile Cards Area
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 800;

            if (records.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    const Text(
                      'No research papers found matching search/filter criteria.',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Try resetting filters or adding a new research paper.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _selectedOrg = 'All';
                          _selectedDept = 'All';
                          _selectedFaculty = 'All';
                          _filterType = 'All';
                          _selectedAuditStatus = 'All';
                        });
                      },
                      icon: const Icon(Icons.restart_alt_rounded, size: 16),
                      label: const Text('Reset All Filters'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.background,
                        foregroundColor: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (isMobile) {
              return Column(
                children: records.map((r) => _buildMobileCard(r)).toList(),
              );
            }

            // DESKTOP RESPONSIVE TABLE (100% VISIBLE ACTIONS COLUMN - ZERO HORIZONTAL SCROLLING!)
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(
                      color: AppColors.tableHeaderBg,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                      border: Border(bottom: BorderSide(color: AppColors.border)),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 14, child: Text('FACULTY / DEPT', style: _headerStyle)),
                        SizedBox(width: 8),
                        Expanded(flex: 22, child: Text('PUBLICATION TITLE & AUTHORS', style: _headerStyle)),
                        SizedBox(width: 8),
                        Expanded(flex: 10, child: Text('TYPE', style: _headerStyle)),
                        SizedBox(width: 8),
                        Expanded(flex: 13, child: Text('DOI REFERENCE', style: _headerStyle)),
                        SizedBox(width: 8),
                        Expanded(flex: 13, child: Text('JOURNAL / INDEXING', style: _headerStyle)),
                        SizedBox(width: 8),
                        Expanded(flex: 11, child: Text('DOCUMENT', style: _headerStyle)),
                        SizedBox(width: 8),
                        Expanded(flex: 11, child: Text('STATUS', style: _headerStyle)),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 105,
                          child: Text('ACTIONS', style: _headerStyle, textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),

                  // Table Rows
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final r = records[index];
                      final isVerified = r.status == 'Verified';

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 1. Faculty / Department
                            Expanded(
                              flex: 14,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    r.facultyName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    r.department,
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 2. Publication Title & Authors
                            Expanded(
                              flex: 22,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    r.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary, height: 1.25),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Authors: ${r.authors}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 3. Type
                            Expanded(
                              flex: 10,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(6)),
                                  child: Text(
                                    r.type,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.accent),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 4. DOI Reference
                            Expanded(
                              flex: 13,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    r.doi,
                                    style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'monospace'),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 5. Journal / Indexing
                            Expanded(
                              flex: 13,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    r.journalName,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textPrimary),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Indexing: ${r.indexing}',
                                    style: const TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold, fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 6. Document
                            Expanded(
                              flex: 11,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.picture_as_pdf_rounded, size: 12, color: Color(0xFFEF4444)),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          r.documentName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.textPrimary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getDocumentBadgeBg(r.documentStatus),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      r.documentStatus == 'Uploaded' ? '✓ Uploaded' : r.documentStatus,
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _getDocumentBadgeFg(r.documentStatus)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 7. Audit Status
                            Expanded(
                              flex: 11,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: StatusBadge(status: r.status, isCompact: true),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 8. Actions (FIXED WIDTH ON FAR RIGHT — 100% VISIBLE!)
                            SizedBox(
                              width: 105,
                              child: Center(
                                child: ElevatedButton.icon(
                                  onPressed: () => _openExamineModal(r),
                                  icon: Icon(
                                    isVerified ? Icons.visibility_rounded : Icons.find_in_page_rounded,
                                    size: 13,
                                  ),
                                  label: Text(isVerified ? 'View' : 'Examine'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isVerified ? const Color(0xFF059669) : AppColors.accent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // MOBILE CARD WIDGET
  Widget _buildMobileCard(ResearchRecord r) {
    final isVerified = r.status == 'Verified';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Faculty & Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.facultyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                    Text('${r.organization} • ${r.department}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              StatusBadge(status: r.status, isCompact: true),
            ],
          ),
          const Divider(height: 20),

          // Publication Title & Authors
          Text(
            r.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary, height: 1.3),
          ),
          const SizedBox(height: 4),
          Text('Authors: ${r.authors}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),

          const SizedBox(height: 10),

          // Meta Info Rows
          _mobileRow('Type', r.type),
          _mobileRow('DOI', r.doi),
          _mobileRow('Journal', r.journalName),
          _mobileRow('Indexing', r.indexing),
          _mobileRow('Document', '${r.documentName} (${r.documentStatus})'),

          const SizedBox(height: 14),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openExamineModal(r),
              icon: Icon(isVerified ? Icons.visibility_rounded : Icons.find_in_page_rounded, size: 16),
              label: Text(isVerified ? 'View Research Details' : 'Examine Document & Verify Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isVerified ? const Color(0xFF059669) : AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectFilter(
    String label,
    List<String> options,
    String currentValue,
    ValueChanged<String?> onChanged, {
    double width = 140,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: options.contains(currentValue) ? currentValue : options.first,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSecondary),
                style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                selectedItemBuilder: (BuildContext context) {
                  return options.map((opt) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        opt,
                        style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList();
                },
                items: options.map((opt) {
                  return DropdownMenuItem<String>(
                    value: opt,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        opt,
                        style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        softWrap: false,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDocumentBadgeBg(String status) {
    if (status == 'Verified') return const Color(0xFFECFDF5);
    if (status == 'Needs Correction') return const Color(0xFFFEE2E2);
    if (status == 'Under Examination') return const Color(0xFFFEF3C7);
    return const Color(0xFFEEF2FF);
  }

  Color _getDocumentBadgeFg(String status) {
    if (status == 'Verified') return const Color(0xFF059669);
    if (status == 'Needs Correction') return const Color(0xFFDC2626);
    if (status == 'Under Examination') return const Color(0xFFD97706);
    return const Color(0xFF4F46E5);
  }
}
