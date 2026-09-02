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
        color: AppColors.sidebarBg,
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Row(
        children: [
          // Drawer Hamburger Menu Button on Mobile/Tablet
          if (showHamburger) ...[
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: 'Open Navigation Drawer',
              ),
            ),
            const SizedBox(width: 4),
          ],

          // View title & welcome subtitle (Desktop & Laptop only; omitted on mobile to prevent title truncation)
          if (!isMobile)
            Flexible(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.activeModule,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Welcome back, Auditor',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Center Search Control (Desktop: full bar; Mobile: centered search trigger)
          if (!isMobile)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 360),
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: InkWell(
                      onTap: () => state.setActiveModule('Global Search'),
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, size: 18, color: Color(0xFF38BDF8)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Search audit records, student ID, subjects...',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.tune_rounded, size: 14, color: Color(0xFF94A3B8)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            // Mobile: Centered Search Trigger between left Hamburger and right controls
            Expanded(
              child: Center(
                child: InkWell(
                  onTap: () => state.setActiveModule('Global Search'),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_rounded, size: 16, color: Color(0xFF38BDF8)),
                        SizedBox(width: 6),
                        Text(
                          'Search...',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Right-side controls (Notifications & Auditor User Profile)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Notifications Bell Popover
              PopupMenuButton<String>(
                tooltip: 'Audit Notifications',
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
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
                            '0',
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
                            'Audit Alerts',
                            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    enabled: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No new notifications',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    ),
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
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: state.activeModule == 'Auditor Profile'
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF334155),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: const Color(0xFF818CF8),
                          child: Text(
                            state.userName.isNotEmpty && state.userName.length >= 2 
                                ? state.userName.substring(0, 2).toUpperCase() 
                                : 'AU',
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                state.userRole,
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_right_rounded, size: 16, color: Color(0xFF94A3B8)),
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

  }
