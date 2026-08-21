import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../widgets/kpi_card.dart';
import '../widgets/responsive_row.dart';

class DashboardView extends StatelessWidget {
  final AuditState state;

  const DashboardView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // 6 Top KPI Cards Row
        LayoutBuilder(
          builder: (context, constraints) {
            final count = constraints.maxWidth > 1200 ? 6 : (constraints.maxWidth > 800 ? 3 : 2);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: count,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.55,
              ),
              itemCount: state.kpis.length,
              itemBuilder: (context, index) => KPICard(kpi: state.kpis[index]),
            );
          },
        ),

        const SizedBox(height: 24),

        // Row 2: Audit Progress Overview (Donut Chart & Table) & Recent Audit Activity
        ResponsiveRow(
          flexValues: const [3, 2],
          children: [
            // Left Column: Audit Progress Overview
            Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Audit Progress Overview',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        // FLChart Donut Chart
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(
                                  color: const Color(0xFF10B981),
                                  value: 92,
                                  title: '92%',
                                  radius: 26,
                                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                                PieChartSectionData(
                                  color: const Color(0xFFF59E0B),
                                  value: 8,
                                  title: '8%',
                                  radius: 24,
                                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                                PieChartSectionData(
                                  color: const Color(0xFFEF4444),
                                  value: 5,
                                  title: '5%',
                                  radius: 22,
                                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Legend
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLegendItem(const Color(0xFF10B981), 'Verified'),
                              const SizedBox(height: 8),
                              _buildLegendItem(const Color(0xFFF59E0B), 'Pending'),
                              const SizedBox(height: 8),
                              _buildLegendItem(const Color(0xFFEF4444), 'Issues'),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Module completion table
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 24,
                        headingRowHeight: 40,
                        dataRowMinHeight: 40,
                        dataRowMaxHeight: 40,
                        columns: const [
                          DataColumn(label: Text('Module', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Verified', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Pending', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Issues', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Progress', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: state.moduleProgress.map((m) {
                          return DataRow(
                            cells: [
                              DataCell(Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text(m.verified.toString(), style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold))),
                              DataCell(Text(m.pending.toString(), style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold))),
                              DataCell(Text(m.issues.toString(), style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold))),
                              DataCell(
                                SizedBox(
                                  width: 100,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: m.percentage,
                                            backgroundColor: AppColors.background,
                                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                                            minHeight: 6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${(m.percentage * 100).toInt()}%',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          'Recent Audit Activity',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () => state.setActiveModule('Audit History'),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.recentActivities.length,
                    separatorBuilder: (context, index) => const Divider(height: 20, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final act = state.recentActivities[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(act.icon, color: act.iconColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  act.title,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  act.module,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            act.timestamp,
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => state.setActiveModule('Audit Work Queue'),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: const Text('Go to Work Queue'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Row 3: Critical Issues & Work Queue Summary & Quick Search
        ResponsiveRow(
          children: [
            // Critical Issues
            Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Critical Issues',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () => state.setActiveModule('Audit Cases'),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.criticalIssues.length,
                      separatorBuilder: (context, index) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final issue = state.criticalIssues[index];
                        return Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    issue.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  Text(
                                    '${issue.priority} • ${issue.department}',
                                    style: TextStyle(color: Colors.red.shade700, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              issue.id,
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

            // Work Queue Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Audit Work Queue Summary',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => state.setActiveModule('Audit Work Queue'),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildQueueItem(Icons.hourglass_top_rounded, 'Pending Verification', 124, Colors.amber),
                  const Divider(height: 16),
                  _buildQueueItem(Icons.find_in_page_rounded, 'In Review', 32, Colors.blue),
                  const Divider(height: 16),
                  _buildQueueItem(Icons.published_with_changes_rounded, 'Correction Requested', 18, Colors.purple),
                  const Divider(height: 16),
                  _buildQueueItem(Icons.autorenew_rounded, 'Re-verification', 11, Colors.orange),
                  const Divider(height: 16),
                  _buildQueueItem(Icons.check_circle_rounded, 'Completed', 458, Colors.green),
                ],
              ),
            ),

            // Quick Search Card & Popular Tags
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Search',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: 'Search student, faculty, assignment...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                    onSubmitted: (val) {
                      state.setGlobalSearchQuery(val);
                      state.setActiveModule('Global Search');
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Popular Searches',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['23CS001', 'Dr. Kumar', 'AI in Education', 'Data Structures', '23IT045', 'Analog Electronics'].map((tag) {
                      return ActionChip(
                        label: Text(tag, style: const TextStyle(fontSize: 11)),
                        backgroundColor: AppColors.background,
                        onPressed: () {
                          state.setGlobalSearchQuery(tag);
                          state.setActiveModule('Global Search');
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildQueueItem(IconData icon, String title, int count, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
