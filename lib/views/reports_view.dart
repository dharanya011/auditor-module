import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';

class ReportsView extends StatelessWidget {
  final AuditState state;

  const ReportsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Institutional Audit Reports & Export Center', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Generate comprehensive institutional, department-wise, and semester-wise audit compliance reports.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),

        const SizedBox(height: 20),

        // KPI Cards
        LayoutBuilder(
          builder: (context, constraints) {
            final count = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: count,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.6,
              children: [
                _buildKpiCard('Total Generated', '1,420', Icons.analytics_rounded, Colors.blue),
                _buildKpiCard('Scheduled Jobs', '8 Active', Icons.schedule_rounded, Colors.orange),
                _buildKpiCard('Export Templates', '12 Custom', Icons.format_paint_rounded, Colors.purple),
                _buildKpiCard('Data Storage', '2.4 GB', Icons.storage_rounded, Colors.green),
              ],
            );
          },
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
                    hintText: 'Search report templates...',
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
                  Text('All Categories', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),

        // Report Cards Grid (Responsive: 1 col mobile, 2 tablet, 3 desktop)
        LayoutBuilder(
          builder: (context, constraints) {
            final count = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
            return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: count,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.3,
          children: [
            _buildReportCard(context, 'Student Audit Report', 'Student-wise, department-wise, and semester-wise verification status.', Icons.school_rounded, Colors.blue),
            _buildReportCard(context, 'Academic Marks Audit Report', 'Internal CAT marks, assignment marks, and CoE ledger verification summary.', Icons.analytics_rounded, Colors.purple),
            _buildReportCard(context, 'Faculty Audit Report', 'Faculty submitted course completion reports, mentoring logs, and attendance checks.', Icons.badge_rounded, Colors.orange),
            _buildReportCard(context, 'Research & Publication Report', 'Faculty and student publications, DOI verifications, grants, and patents.', Icons.science_rounded, Colors.teal),
            _buildReportCard(context, 'Issue & Discrepancy Report', 'Critical, high, medium, and low severity findings and HOD resolution status.', Icons.warning_amber_rounded, Colors.red),
            _buildReportCard(context, 'Audit Completion Report', 'Overall audit completion progress by department, module, and academic year.', Icons.pie_chart_rounded, Colors.green),
          ],
        );
          },
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

  Widget _buildReportCard(BuildContext context, String title, String desc, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildExportBtn(Icons.picture_as_pdf_rounded, 'PDF', Colors.red, () => state.showToast('Exporting $title as PDF...')),
                _buildExportBtn(Icons.table_chart_rounded, 'Excel', Colors.green, () => state.showToast('Exporting $title as Excel...')),
                _buildExportBtn(Icons.insert_drive_file_rounded, 'CSV', Colors.blue, () => state.showToast('Exporting $title as CSV...')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
