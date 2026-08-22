import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';

class Header extends StatelessWidget {
  final AuditState state;
  final bool showHamburger;

  const Header({
    super.key,
    required this.state,
    this.showHamburger = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Drawer Hamburger Menu Button on Mobile/Tablet
          if (showHamburger) ...[
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: 'Open Navigation Drawer',
              ),
            ),
            const SizedBox(width: 4),
          ],

          // View title & welcome subtitle
          Flexible(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.activeModule,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isMobile ? 16 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isMobile) ...[
                    const SizedBox(height: 2),
                    const Text(
                      'Welcome back, Auditor',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const Spacer(),

          // Right-side controls (responsive, no horizontal scrolling required)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Academic Year Dropdown
              Container(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isMobile ? 'AY: ' : 'Academic Year : ',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: state.selectedAcademicYear,
                        isDense: true,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        items: const [
                          DropdownMenuItem(value: '2025 - 2026', child: Text('2025 - 2026')),
                          DropdownMenuItem(value: '2024 - 2025', child: Text('2024 - 2025')),
                          DropdownMenuItem(value: '2023 - 2024', child: Text('2023 - 2024')),
                        ],
                        onChanged: (val) {
                          if (val != null) state.setSelectedAcademicYear(val);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: isMobile ? 4 : 10),

              // 2. Search button trigger
              IconButton(
                onPressed: () {
                  state.setActiveModule('Global Search');
                },
                icon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                tooltip: 'Global Search',
              ),

              // 3. Notifications Bell Popover
              PopupMenuButton<String>(
                tooltip: 'Audit Notifications',
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.notifications_none_rounded, color: AppColors.textSecondary),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '5',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: SizedBox(
                      width: 320,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Audit Alerts (5 Unread)',
                            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          TextButton(
                            onPressed: () {
                              state.showToast('All notifications marked as read');
                              Navigator.pop(context);
                            },
                            child: const Text('Mark all read', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const PopupMenuDivider(),
                  _buildNotificationItem(
                    context,
                    title: 'Marks mismatch in 23CS201',
                    subtitle: 'High Priority • AUD-2025-00145',
                    time: '2m ago',
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.red,
                    targetModule: 'Marks Audit',
                  ),
                  _buildNotificationItem(
                    context,
                    title: 'Missing assignment evidence',
                    subtitle: '12 Students • 23IT304',
                    time: '15m ago',
                    icon: Icons.assignment_late_rounded,
                    iconColor: Colors.orange,
                    targetModule: 'Assignment Audit',
                  ),
                  _buildNotificationItem(
                    context,
                    title: 'Question paper not approved',
                    subtitle: 'High Priority • 23IT204 DBMS',
                    time: '1h ago',
                    icon: Icons.description_outlined,
                    iconColor: Colors.red,
                    targetModule: 'Question Paper Audit',
                  ),
                  _buildNotificationItem(
                    context,
                    title: 'Faculty report data inconsistency',
                    subtitle: 'Medium Priority • CSE Dept',
                    time: '2h ago',
                    icon: Icons.badge_outlined,
                    iconColor: Colors.amber.shade800,
                    targetModule: 'Faculty Report Audit',
                  ),
                  _buildNotificationItem(
                    context,
                    title: 'Research DOI mismatch',
                    subtitle: 'Medium Priority • 2 Records',
                    time: '3h ago',
                    icon: Icons.science_outlined,
                    iconColor: Colors.purple,
                    targetModule: 'Research Audit',
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    onTap: () => state.setActiveModule('Audit Cases'),
                    child: const Center(
                      child: Text(
                        'View All Audit Cases & Alerts →',
                        style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(width: isMobile ? 4 : 10),

              // 4. Auditor User Profile Pill (Clickable -> Navigates to Auditor Profile)
              InkWell(
                onTap: () => state.setActiveModule('Auditor Profile'),
                borderRadius: BorderRadius.circular(20),
                child: Tooltip(
                  message: 'View Auditor Profile & Account Settings',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: state.activeModule == 'Auditor Profile'
                          ? AppColors.accent.withValues(alpha: 0.1)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: state.activeModule == 'Auditor Profile'
                            ? AppColors.accent
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: const Color(0xFF818CF8),
                          child: Text(
                            state.userName.substring(0, 2).toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                        if (!isMobile) ...[
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.userName,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                state.userRole,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_right_rounded, size: 16, color: AppColors.textSecondary),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildNotificationItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color iconColor,
    required String targetModule,
  }) {
    return PopupMenuItem<String>(
      onTap: () => state.setActiveModule(targetModule),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
