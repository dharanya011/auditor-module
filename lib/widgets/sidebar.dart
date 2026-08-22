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

          // Bottom Help Container (Interactive Contact Support Trigger)
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: InkWell(
              onTap: () {
                if (Scaffold.of(context).isDrawerOpen) {
                  Navigator.pop(context);
                }
                _showHelpSupportDialog(context);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B4B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF4F46E5)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x334F46E5), blurRadius: 8, offset: Offset(0, 2)),
                  ],
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
                    const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFA5B4FC), size: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _HelpSupportModal(state: state),
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
          onTap: () {
            state.setActiveModule(title);
            if (Scaffold.of(context).isDrawerOpen) {
              Navigator.pop(context);
            }
          },
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

class _HelpSupportModal extends StatefulWidget {
  final AuditState state;

  const _HelpSupportModal({required this.state});

  @override
  State<_HelpSupportModal> createState() => _HelpSupportModalState();
}

class _HelpSupportModalState extends State<_HelpSupportModal> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'Data Discrepancy Question';

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 650 ? 580.0 : screenWidth * 0.92;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.headset_mic_rounded, color: Color(0xFF4F46E5), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KSRCE Auditor Help Desk',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Direct support for academic audit verifications & system issues.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  ),
                ],
              ),

              const Divider(height: 28),

              // Contact Channels Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.phone_in_talk_rounded, size: 16, color: Color(0xFF4F46E5)),
                        const SizedBox(width: 8),
                        const Text('Support Hotline: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const Expanded(
                          child: Text('+91 4288 274741 (Ext: 402 / 405)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3730A3))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.mark_email_read_rounded, size: 16, color: Color(0xFF4F46E5)),
                        const SizedBox(width: 8),
                        const Text('Official Email: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const Expanded(
                          child: Text('auditor-support@ksrce.ac.in', style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: Color(0xFF3730A3))),
                        ),
                        InkWell(
                          onTap: () => widget.state.showToast('Support email copied to clipboard!'),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(Icons.copy_rounded, size: 14, color: Color(0xFF4F46E5)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.badge_rounded, size: 16, color: Color(0xFF4F46E5)),
                        const SizedBox(width: 8),
                        const Text('Head of Academic Audit: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const Expanded(
                          child: Text('Dr. M. Audit Rajan (Admin Block, Room 204)', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Documentation PDF Download
              OutlinedButton.icon(
                onPressed: () => widget.state.showToast('Downloading KSRCE Auditor User Manual v2.4 (PDF)...'),
                icon: const Icon(Icons.menu_book_rounded, size: 16, color: AppColors.accent),
                label: const Text('Download Auditor User Manual v2.4 (PDF)', style: TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  side: const BorderSide(color: AppColors.accent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

              const SizedBox(height: 20),

              // Submit Quick Support Ticket
              const Text('RAISE A SUPPORT TICKET', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8)),
              const SizedBox(height: 10),

              // Category dropdown
              const Text('Issue Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    isDense: true,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    items: const [
                      DropdownMenuItem(value: 'Data Discrepancy Question', child: Text('Data Discrepancy Question')),
                      DropdownMenuItem(value: 'Technical System Issue', child: Text('Technical System Issue')),
                      DropdownMenuItem(value: 'Access & Permission Request', child: Text('Access & Permission Request')),
                      DropdownMenuItem(value: 'Report Generation Query', child: Text('Report Generation Query')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Subject input
              TextField(
                controller: _subjectController,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  labelText: 'Subject',
                  hintText: 'Brief summary of your support request...',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),

              const SizedBox(height: 10),

              // Message input
              TextField(
                controller: _messageController,
                maxLines: 3,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  labelText: 'Description / Details',
                  hintText: 'Describe the issue or record ID in detail...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),

              const SizedBox(height: 20),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      final sub = _subjectController.text.trim();
                      if (sub.isEmpty) {
                        widget.state.showToast('Support ticket #SUP-2026-889 created successfully!');
                      } else {
                        widget.state.showToast('Support ticket "$sub" submitted!');
                      }
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.send_rounded, size: 14),
                    label: const Text('Submit Support Ticket', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
