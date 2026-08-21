import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../widgets/status_badge.dart';

class GlobalSearchView extends StatefulWidget {
  final AuditState state;

  const GlobalSearchView({super.key, required this.state});

  @override
  State<GlobalSearchView> createState() => _GlobalSearchViewState();
}

class _GlobalSearchViewState extends State<GlobalSearchView> {
  late TextEditingController _searchController;
  String _selectedDept = 'All Departments';
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
                children: [
                  Icon(Icons.search_rounded, color: Color(0xFF38BDF8), size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Global Audit Search Engine',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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

        // Faceted Filters (Responsive Wrap)
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DropdownButton<String>(
              value: _selectedDept,
              items: const [
                DropdownMenuItem(value: 'All Departments', child: Text('All Departments')),
                DropdownMenuItem(value: 'CSE', child: Text('Computer Science')),
                DropdownMenuItem(value: 'IT', child: Text('Information Tech')),
                DropdownMenuItem(value: 'ECE', child: Text('Electronics & Comm')),
              ],
              onChanged: (v) => setState(() => _selectedDept = v!),
            ),
            DropdownButton<String>(
              value: _selectedRecordType,
              items: const [
                DropdownMenuItem(value: 'All Records', child: Text('All Record Types')),
                DropdownMenuItem(value: 'Students', child: Text('Students')),
                DropdownMenuItem(value: 'Assignments', child: Text('Assignments')),
                DropdownMenuItem(value: 'Marks', child: Text('Marks')),
                DropdownMenuItem(value: 'Faculty Reports', child: Text('Faculty Reports')),
                DropdownMenuItem(value: 'Question Papers', child: Text('Question Papers')),
                DropdownMenuItem(value: 'Research', child: Text('Research Publications')),
              ],
              onChanged: (v) => setState(() => _selectedRecordType = v!),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Search Results List
        const Text('Search Results', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),

        // Mock result cards
        _buildResultCard(
          context,
          title: 'Adithya V (Register No: 23CS001)',
          subtitle: 'Student Profile • Computer Science & Engg • Semester 5 • CGPA: 8.84 • Attendance: 94.2%',
          type: 'Student Audit',
          status: 'Verified',
          onTap: () => widget.state.setActiveModule('Student Audit'),
        ),
        const SizedBox(height: 12),
        _buildResultCard(
          context,
          title: 'Marks Record — 23CS201 Data Structures (Student: 23CS0456)',
          subtitle: 'Marks Mismatch • Faculty Entry: 88 vs Exam Record: 72 • Case AUD-2026-001245',
          type: 'Marks Audit',
          status: 'Discrepancy Flagged',
          onTap: () => widget.state.setActiveModule('Marks Audit'),
        ),
        const SizedBox(height: 12),
        _buildResultCard(
          context,
          title: 'Research Paper — AI in Higher Education (Dr. S. Meena)',
          subtitle: 'DOI: 10.1016/j.compedu.2025.104921 • IEEE Transactions • Scopus Indexed',
          type: 'Research Audit',
          status: 'Verified',
          onTap: () => widget.state.setActiveModule('Research Audit'),
        ),
        const SizedBox(height: 12),
        _buildResultCard(
          context,
          title: 'Question Paper — 23IT204 Database Management Systems',
          subtitle: 'Regulation R2023 • IT Dept • CO-PO Mapped • CoE Approval Pending',
          type: 'Question Paper Audit',
          status: 'Pending Verification',
          onTap: () => widget.state.setActiveModule('Question Paper Audit'),
        ),
      ],
    );
  }

  Widget _buildResultCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String type,
    required String status,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.description_rounded, color: AppColors.accent),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(status: status),
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
                      child: const Text('Audit Record'),
                    ),
                  ],
                ),
              ],
            );
          }
          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.description_rounded, color: AppColors.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              StatusBadge(status: status),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
                child: const Text('Audit Record'),
              ),
            ],
          );
        },
      ),
    );
  }
}
