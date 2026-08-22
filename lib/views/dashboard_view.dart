import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../models/models.dart';
import '../widgets/kpi_card.dart';
import '../widgets/responsive_row.dart';
import '../widgets/audit_detail_modal.dart';

class DashboardView extends StatelessWidget {
  final AuditState state;

  const DashboardView({super.key, required this.state});

  void _openKpiDetailModal(BuildContext context, int index, AuditKPI kpi) {
    String title = kpi.title;
    String subtitle = 'All auditable records belonging to ${kpi.title}';
    String statusCategory = 'ALL';

    if (index == 0) {
      title = 'Total Records Audited';
      subtitle = 'Complete 360° audit ledger across all ERP modules';
      statusCategory = 'ALL';
    } else if (index == 1) {
      title = 'Pending Verification Records';
      subtitle = 'Auditable entries currently awaiting auditor verification & sign-off';
      statusCategory = 'PENDING';
    } else if (index == 2) {
      title = 'Verified Records';
      subtitle = 'Auditable entries with 100% verified integrity & digital signature';
      statusCategory = 'VERIFIED';
    } else if (index == 3) {
      title = 'Discrepancies & Issues Found';
      subtitle = 'Records flagged with data mismatches or validation errors';
      statusCategory = 'ISSUES';
    } else if (index == 4) {
      title = 'High-Priority Critical Issues';
      subtitle = 'Urgent audit cases requiring immediate escalation & HOD action';
      statusCategory = 'CRITICAL';
    } else if (index == 5) {
      title = 'Corrections Pending Verification';
      subtitle = 'Records sent back for department correction and re-audit';
      statusCategory = 'CORRECTIONS';
    }

    showDialog(
      context: context,
      builder: (ctx) => AuditDetailModal(
        state: state,
        title: title,
        subtitle: subtitle,
        icon: kpi.icon,
        themeColor: kpi.color,
        statusCategory: statusCategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // 6 Top KPI Cards Row
        LayoutBuilder(
          builder: (context, constraints) {
            final count = constraints.maxWidth > 1200 ? 6 : (constraints.maxWidth > 800 ? 3 : 2);
            final double cellWidth = (constraints.maxWidth - (count - 1) * 16) / count;
            final double aspectRatio = count == 6
                ? (cellWidth / 115)
                : (count == 3 ? cellWidth / 125 : cellWidth / 120);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: count,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: aspectRatio,
              ),
              itemCount: state.kpis.length,
              itemBuilder: (context, index) {
                final kpi = state.kpis[index];
                return KPICard(
                  kpi: kpi,
                  onTap: () => _openKpiDetailModal(context, index, kpi),
                );
              },
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

                    // Module completion table — custom layout (zero overflow)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 580,
                        child: Column(
                          children: [
                            // Header Row
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Row(
                                children: [
                                  SizedBox(width: 160, child: Text('Module', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary))),
                                  SizedBox(width: 70, child: Text('Verified', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF10B981)))),
                                  SizedBox(width: 70, child: Text('Pending', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFF59E0B)))),
                                  SizedBox(width: 70, child: Text('Issues', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFEF4444)))),
                                  Expanded(child: Text('Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Data Rows
                            ...state.moduleProgress.map((m) => Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 160,
                                    child: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  ),
                                  // Interactive Verified
                                  SizedBox(
                                    width: 70,
                                    child: GestureDetector(
                                      onTap: () => showDialog(
                                        context: context,
                                        builder: (ctx) => AuditDetailModal(
                                          state: state,
                                          title: '${m.name} — Verified Records',
                                          subtitle: 'Verified records in ${m.name} module',
                                          icon: Icons.check_circle_rounded,
                                          themeColor: const Color(0xFF10B981),
                                          targetModule: m.name,
                                          statusCategory: 'VERIFIED',
                                        ),
                                      ),
                                      child: Tooltip(
                                        message: 'Click to view ${m.verified} verified records',
                                        child: Text(
                                          m.verified.toString(),
                                          style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.underline),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Interactive Pending
                                  SizedBox(
                                    width: 70,
                                    child: GestureDetector(
                                      onTap: () => showDialog(
                                        context: context,
                                        builder: (ctx) => AuditDetailModal(
                                          state: state,
                                          title: '${m.name} — Pending Verification',
                                          subtitle: 'Pending entries in ${m.name} module',
                                          icon: Icons.hourglass_top_rounded,
                                          themeColor: const Color(0xFFF59E0B),
                                          targetModule: m.name,
                                          statusCategory: 'PENDING',
                                        ),
                                      ),
                                      child: Tooltip(
                                        message: 'Click to view ${m.pending} pending records',
                                        child: Text(
                                          m.pending.toString(),
                                          style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.underline),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Interactive Issues
                                  SizedBox(
                                    width: 70,
                                    child: GestureDetector(
                                      onTap: () => showDialog(
                                        context: context,
                                        builder: (ctx) => AuditDetailModal(
                                          state: state,
                                          title: '${m.name} — Flagged Issues',
                                          subtitle: 'Discrepancy flags in ${m.name} module',
                                          icon: Icons.error_rounded,
                                          themeColor: const Color(0xFFEF4444),
                                          targetModule: m.name,
                                          statusCategory: 'ISSUES',
                                        ),
                                      ),
                                      child: Tooltip(
                                        message: 'Click to view ${m.issues} issue flags',
                                        child: Text(
                                          m.issues.toString(),
                                          style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.underline),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Interactive Progress Bar
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => showDialog(
                                        context: context,
                                        builder: (ctx) => AuditDetailModal(
                                          state: state,
                                          title: '${m.name} — All Records',
                                          subtitle: 'Complete audit records in ${m.name} (${(m.percentage * 100).toInt()}% done)',
                                          icon: Icons.bar_chart_rounded,
                                          themeColor: const Color(0xFF4F46E5),
                                          targetModule: m.name,
                                          statusCategory: 'ALL',
                                        ),
                                      ),
                                      child: Tooltip(
                                        message: 'Click to inspect all ${m.name} records',
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
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary, decoration: TextDecoration.underline),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
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
