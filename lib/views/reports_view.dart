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
            final childAspectRatio = count == 4 ? 2.6 : (count == 2 ? 2.4 : 2.8);
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: count,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
              children: [
                _buildKpiCard('Total Generated', '—', Icons.analytics_rounded, Colors.blue),
                _buildKpiCard('Scheduled Jobs', '—', Icons.schedule_rounded, Colors.orange),
                _buildKpiCard('Export Templates', '—', Icons.format_paint_rounded, Colors.purple),
                _buildKpiCard('Data Storage', '—', Icons.storage_rounded, Colors.green),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        // Toolbar
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            if (isMobile) {
              return Column(
                children: [
                  Container(
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
                  const SizedBox(height: 10),
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
              );
            }
            return Row(
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
            );
          },
        ),
        
        const SizedBox(height: 16),

        // Report Cards Grid (Responsive 3-col desktop, 2-col tablet, 1-col mobile)
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 950;
            final isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 950;

            final cards = [
              _buildReportCard(context, 'Student Audit Report', 'Student-wise, department-wise, and semester-wise verification status.', Icons.school_rounded, Colors.blue),
              _buildReportCard(context, 'Academic Marks Audit Report', 'Internal CAT marks, assignment marks, and CoE ledger verification summary.', Icons.analytics_rounded, Colors.purple),
              _buildReportCard(context, 'Faculty Audit Report', 'Faculty submitted course completion reports, mentoring logs, and attendance checks.', Icons.badge_rounded, Colors.orange),
              _buildReportCard(context, 'Research & Publication Report', 'Faculty and student publications, DOI verifications, grants, and patents.', Icons.science_rounded, Colors.teal),
              _buildReportCard(context, 'Issue & Discrepancy Report', 'Critical, high, medium, and low severity findings and HOD resolution status.', Icons.warning_amber_rounded, Colors.red),
              _buildReportCard(context, 'Audit Completion Report', 'Overall audit completion progress by department, module, and academic year.', Icons.pie_chart_rounded, Colors.green),
            ];

            if (isDesktop) {
              // 3 Columns Layout with natural content height
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        cards[0],
                        const SizedBox(height: 14),
                        cards[3],
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      children: [
                        cards[1],
                        const SizedBox(height: 14),
                        cards[4],
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      children: [
                        cards[2],
                        const SizedBox(height: 14),
                        cards[5],
                      ],
                    ),
                  ),
                ],
              );
            } else if (isTablet) {
              // 2 Columns Layout
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        cards[0],
                        const SizedBox(height: 14),
                        cards[2],
                        const SizedBox(height: 14),
                        cards[4],
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      children: [
                        cards[1],
                        const SizedBox(height: 14),
                        cards[3],
                        const SizedBox(height: 14),
                        cards[5],
                      ],
                    ),
                  ),
                ],
              );
            } else {
              // 1 Column Layout (Mobile)
              return Column(
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    cards[i],
                    if (i < cards.length - 1) const SizedBox(height: 14),
                  ],
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, String title, String desc, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, height: 1.35),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
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
      borderRadius: BorderRadius.circular(6),
      hoverColor: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
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
