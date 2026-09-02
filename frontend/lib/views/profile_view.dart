import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';

import '../widgets/responsive_row.dart';

class ProfileView extends StatelessWidget {
  final AuditState state;

  const ProfileView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Premium Profile Banner
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;
              if (isMobile) {
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.accent,
                      child: Text(
                        state.userName.substring(0, 2).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.userName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Role: ${state.userRole} • KSRCE ERP Auditor Portal',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAccountSettingsDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.settings_rounded, size: 18),
                      label: const Text('Settings'),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.accent,
                      child: Text(
                        state.userName.substring(0, 2).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.userName,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Role: ${state.userRole} • KSRCE ERP Auditor Portal',
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 14),
                                  SizedBox(width: 6),
                                  Text(
                                    'Authorized Independent Auditor',
                                    style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAccountSettingsDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.settings_rounded, size: 18),
                    label: const Text('Settings'),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        // KPI Cards
        ResponsiveRow(
          children: [
            _buildKpiCard('Total Actions', '8,452', Icons.task_alt_rounded, Colors.blue),
            _buildKpiCard('Pending Tasks', '14', Icons.pending_actions_rounded, Colors.orange),
            _buildKpiCard('Accuracy Score', '99.8%', Icons.track_changes_rounded, Colors.green),
            _buildKpiCard('Audit Level', 'Tier-1', Icons.shield_rounded, Colors.purple),
          ],
        ),

        const SizedBox(height: 32),

        // Permission Model Section (Strict Read-Only Verification Enforcement)
        const Text('Auditor Security & Permission Matrix', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Core Security Principle: Auditors verify records, flag issues, and request corrections, but cannot alter audited data directly.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 16),

        Container(
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
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.tableHeaderBg),
              columnSpacing: 10,
              horizontalMargin: 20,
              columns: const [
                DataColumn(label: SizedBox(width: 250, child: Text('ACTION / OPERATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                DataColumn(label: SizedBox(width: 150, child: Text('AUDITOR PERMISSION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                DataColumn(label: SizedBox(width: 450, child: Text('SECURITY DESCRIPTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
              ],
              rows: [
                _buildPermissionRow('View Student & Faculty Records', true, 'Full read-only inspection access across all auditable ERP modules.'),
                _buildPermissionRow('Search Records (Global Search)', true, 'Cross-ERP search engine discovery.'),
                _buildPermissionRow('Verify / Reject Records', true, 'Submit verification decisions and remarks.'),
                _buildPermissionRow('Flag Issue & Create Audit Case', true, 'Route discrepancies to HOD / Dean for correction.'),
                _buildPermissionRow('Direct Edit Student Personal Data', false, 'Strictly prohibited. Auditor cannot alter audited database records.'),
                _buildPermissionRow('Direct Edit Marks & Grades', false, 'Strictly prohibited. Only faculty/CoE can edit marks via correction workflow.'),
                _buildPermissionRow('Modify Audit History Logs', false, 'Strictly prohibited. Audit log history is cryptographically immutable.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildPermissionRow(String action, bool isAllowed, String desc) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 250,
            child: Text(action, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ),
        DataCell(
          SizedBox(
            width: 150,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAllowed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: isAllowed ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isAllowed ? 'ALLOWED' : 'NOT ALLOWED',
                  style: TextStyle(
                    color: isAllowed ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 450,
            child: Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  void _showAccountSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _AccountSettingsModal(state: state),
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
                Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSettingsModal extends StatefulWidget {
  final AuditState state;

  const _AccountSettingsModal({required this.state});

  @override
  State<_AccountSettingsModal> createState() => _AccountSettingsModalState();
}

class _AccountSettingsModalState extends State<_AccountSettingsModal> {
  bool _emailAlerts = true;
  bool _dailyDigest = true;
  bool _compactMode = false;
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.state.userRole;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 650 ? 600.0 : screenWidth * 0.92;

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
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.settings_applications_rounded, color: AppColors.accent, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auditor Account Settings',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Configure portal preferences, alerts, and security options.',
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

              // Profile Credentials Section
              const Text('ACCOUNT INFORMATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.accent),
                        const SizedBox(width: 10),
                        const Text('Auditor Name:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 8),
                        Text(widget.state.userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined, size: 18, color: AppColors.accent),
                        const SizedBox(width: 10),
                        const Text('Auditor Role:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 8),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRole,
                            isDense: true,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 12),
                            items: const [
                              DropdownMenuItem(value: 'Lead_Auditor', child: Text('Lead Auditor')),
                              DropdownMenuItem(value: 'Department_Auditor', child: Text('Department Auditor')),
                              DropdownMenuItem(value: 'HOD', child: Text('HOD')),
                              DropdownMenuItem(value: 'Dean_Academics', child: Text('Dean Academics')),
                              DropdownMenuItem(value: 'System_Admin', child: Text('System Admin')),
                              DropdownMenuItem(value: 'Read_Only_Inspector', child: Text('Read-Only Inspector')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedRole = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 18, color: AppColors.accent),
                        const SizedBox(width: 10),
                        const Text('Official Email:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 8),
                        Text(widget.state.userEmail, style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Notification Toggles
              const Text('AUDIT NOTIFICATION ALERTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('Email Alerts on Critical Discrepancies', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: const Text('Receive instant notifications when high-priority flags are raised.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                value: _emailAlerts,
                activeThumbColor: AppColors.accent,
                onChanged: (val) => setState(() => _emailAlerts = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('Daily Work Queue Digest', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: const Text('Daily summary email of pending audit verifications.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                value: _dailyDigest,
                activeThumbColor: AppColors.accent,
                onChanged: (val) => setState(() => _dailyDigest = val),
              ),

              const SizedBox(height: 12),

              // Interface Settings
              const Text('DISPLAY & PREFERENCES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8)),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('Compact Table Rows', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: const Text('Reduce padding in data tables to view more audit rows at once.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                value: _compactMode,
                activeThumbColor: AppColors.accent,
                onChanged: (val) => setState(() => _compactMode = val),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      widget.state.setUserRole(_selectedRole);
                      widget.state.showToast('Account settings saved successfully!');
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_circle_rounded, size: 16),
                    label: const Text('Save Settings', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
