import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';

class GlobalSearchView extends StatefulWidget {
  final AuditState state;

  const GlobalSearchView({super.key, required this.state});

  @override
  State<GlobalSearchView> createState() => _GlobalSearchViewState();
}

class _GlobalSearchViewState extends State<GlobalSearchView> {
  late TextEditingController _searchController;
  String _selectedRecordType = 'All Records';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.state.globalSearchQuery);
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
                  setState(() {});
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
                if (v != null) setState(() => _selectedRecordType = v);
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

        if (widget.state.globalSearchQuery.isEmpty)
          Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                SizedBox(height: 12),
                Text(
                  'Enter a search query to find audit records.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                ),
                SizedBox(height: 4),
                Text(
                  'Search by register number, faculty name, DOI, paper title, or case ID.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                SizedBox(height: 12),
                Text(
                  'No search results found.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                ),
                SizedBox(height: 4),
                Text(
                  'Try adjusting your search query or filters.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
