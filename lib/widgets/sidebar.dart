import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';

class Sidebar extends StatelessWidget {
  final AuditState state;

  const Sidebar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          // Logo & Branding
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'KSR',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KSRCE ERP',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Auditor Module',
                        style: TextStyle(
                          color: AppColors.sidebarText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Nav Items List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                _buildSectionLabel('MAIN'),
                _buildNavItem(context, 'Dashboard', Icons.dashboard_rounded),
                _buildNavItem(context, 'Audit Work Queue', Icons.assignment_outlined, badge: '124'),
                _buildNavItem(context, 'Global Search', Icons.search_rounded),

                const SizedBox(height: 16),
                _buildSectionLabel('AUDIT MODULES'),
                _buildNavItem(context, 'Student Audit', Icons.person_search_rounded),
                _buildNavItem(context, 'Assignment Audit', Icons.assignment_turned_in_outlined),
                _buildNavItem(context, 'Marks Audit', Icons.analytics_outlined),
                _buildNavItem(context, 'Faculty Report Audit', Icons.badge_outlined),
                _buildNavItem(context, 'Question Paper Audit', Icons.description_outlined),
                _buildNavItem(context, 'Research Audit', Icons.science_outlined),

                const SizedBox(height: 16),
                _buildSectionLabel('SUPPORTING MODULES'),
                _buildNavItem(context, 'Evidence Repository', Icons.folder_zip_outlined),
                _buildNavItem(context, 'Audit Cases', Icons.rule_folder_outlined),
                _buildNavItem(context, 'Audit History', Icons.history_rounded),
                _buildNavItem(context, 'AI-Assisted Audit', Icons.auto_awesome_rounded, isNew: true),

                const SizedBox(height: 16),
                _buildSectionLabel('REPORTS'),
                _buildNavItem(context, 'Audit Reports', Icons.insert_chart_outlined_rounded),

                const SizedBox(height: 16),
                _buildSectionLabel('SYSTEM'),
                _buildNavItem(context, 'Auditor Profile', Icons.admin_panel_settings_outlined),
              ],
            ),
          ),

          // Bottom Help Container (matching screenshot)
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B4B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF3730A3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need Help?',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          'Click here to contact support',
                          style: TextStyle(color: Color(0xFFA5B4FC), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 8, bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, {String? badge, bool isNew = false}) {
    final isActive = state.activeModule == title;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => state.setActiveModule(title),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF4F46E5) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isActive ? Colors.white : AppColors.sidebarText,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.sidebarText,
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
