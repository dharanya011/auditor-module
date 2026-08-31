import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../widgets/status_badge.dart';
import '../services/api_service.dart';
import '../widgets/api_error_widget.dart';

class GlobalSearchView extends StatefulWidget {
  final AuditState state;

  const GlobalSearchView({super.key, required this.state});

  @override
  State<GlobalSearchView> createState() => _GlobalSearchViewState();
}

class _GlobalSearchViewState extends State<GlobalSearchView> {
  late TextEditingController _searchController;
  String _selectedRecordType = 'All Records';

  bool _isSearching = false;
  String? _searchError;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.state.globalSearchQuery);
    if (_searchController.text.trim().isNotEmpty) {
      _performSearch(_searchController.text.trim());
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _searchError = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final results = await ApiService.instance.searchGlobal(query, type: _selectedRecordType);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchError = e.toString();
          _isSearching = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Title banner
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B4B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF3730A3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.search_rounded, color: Color(0xFF38BDF8), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Global Audit Search Engine',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Cross-ERP search engine returning auditable records (Register Number, Faculty Name, DOI, Question Paper, Case ID, Evidence).',
                style: TextStyle(color: Color(0xFFA5B4FC), fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search register no (e.g. 23CS001), faculty name, DOI, paper title...',
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF38BDF8)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      _searchController.clear();
                      widget.state.setGlobalSearchQuery('');
                      setState(() {});
                    },
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                ),
                onChanged: (val) {
                  widget.state.setGlobalSearchQuery(val);
                  _performSearch(val);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Responsive Faceted Filters: Role & Record Type Dropdowns
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 650;
            
            Widget buildDropdownCard({
              required String label,
              required String value,
              required List<DropdownMenuItem<String>> items,
              required ValueChanged<String?> onChanged,
              required IconData icon,
            }) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: AppColors.accent),
                    const SizedBox(width: 10),
                    Text(
                      '$label: ',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: value,
                          isDense: true,
                          isExpanded: true,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 12),
                          items: items,
                          onChanged: onChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final roleDropdown = buildDropdownCard(
              label: 'Role',
              value: widget.state.userRole,
              icon: Icons.admin_panel_settings_rounded,
              items: const [
                DropdownMenuItem(value: 'Lead_Auditor', child: Text('Lead Auditor')),
                DropdownMenuItem(value: 'Department_Auditor', child: Text('Department Auditor')),
                DropdownMenuItem(value: 'HOD', child: Text('HOD')),
                DropdownMenuItem(value: 'Dean_Academics', child: Text('Dean Academics')),
                DropdownMenuItem(value: 'System_Admin', child: Text('System Admin')),
                DropdownMenuItem(value: 'Read_Only_Inspector', child: Text('Read-Only Inspector')),
              ],
              onChanged: (v) {
                if (v != null) widget.state.setUserRole(v);
              },
            );

            final recordTypeDropdown = buildDropdownCard(
              label: 'Record Type',
              value: _selectedRecordType,
              icon: Icons.category_rounded,
              items: const [
                DropdownMenuItem(value: 'All Records', child: Text('All Record Types')),
                DropdownMenuItem(value: 'Students', child: Text('Students')),
                DropdownMenuItem(value: 'Assignments', child: Text('Assignments')),
                DropdownMenuItem(value: 'Marks', child: Text('Marks')),
                DropdownMenuItem(value: 'Faculty Reports', child: Text('Faculty Reports')),
                DropdownMenuItem(value: 'Question Papers', child: Text('Question Papers')),
                DropdownMenuItem(value: 'Research', child: Text('Research Publications')),
              ],
              onChanged: (v) {
                if (v != null) {
                  setState(() => _selectedRecordType = v);
                  _performSearch(_searchController.text);
                }
              },
            );

            if (isMobile) {
              return Column(
                children: [
                  roleDropdown,
                  const SizedBox(height: 12),
                  recordTypeDropdown,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: roleDropdown),
                const SizedBox(width: 16),
                Expanded(child: recordTypeDropdown),
              ],
            );
          },
        ),

        const SizedBox(height: 20),

        // Search Results List
        const Text('Search Results', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),

        if (_isSearching)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Searching real PostgreSQL database records...', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          )
        else if (_searchError != null)
          ApiErrorWidget(
            errorMessage: _searchError!,
            onRetry: () => _performSearch(_searchController.text),
          )
        else if (_searchResults.isEmpty && _searchController.text.trim().isNotEmpty)
          ApiEmptyWidget(
            message: 'No Auditable Records Found',
            hint: 'No PostgreSQL database records matched "${_searchController.text.trim()}".',
          )
        else if (_searchResults.isEmpty)
          const ApiEmptyWidget(
            message: 'Global Audit Search Engine',
            hint: 'Type a Register Number, Student Name, Department, DOI, or Paper Title above to search the PostgreSQL database.',
          )
        else
          ..._searchResults.map(
            (res) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildResultCard(
                context,
                title: (res['title'] ?? '').toString(),
                subtitle: (res['subtitle'] ?? '').toString(),
                type: (res['type'] ?? 'Audit Record').toString(),
                status: (res['status'] ?? 'Verified').toString(),
                onTap: () => widget.state.setActiveModule((res['moduleKey'] ?? 'Dashboard').toString()),
              ),
            ),
          ),
      ],
    );
  }
}
