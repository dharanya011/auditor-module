import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';

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
                color: AppColors.accent.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
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
                            color: const Color(0xFF10B981).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5)),
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
              // Action Button on right of banner
              ElevatedButton.icon(
                onPressed: () => state.showToast('Opening account settings...'),
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
          ),
        ),

        const SizedBox(height: 24),

        // KPI Cards
        Row(
          children: [
            _buildKpiCard('Total Actions', '8,452', Icons.task_alt_rounded, Colors.blue),
            const SizedBox(width: 16),
            _buildKpiCard('Pending Tasks', '14', Icons.pending_actions_rounded, Colors.orange),
            const SizedBox(width: 16),
            _buildKpiCard('Accuracy Score', '99.8%', Icons.track_changes_rounded, Colors.green),
            const SizedBox(width: 16),
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
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(AppColors.tableHeaderBg),
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

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
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
                color: color.withOpacity(0.1),
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
      ),
    );
  }
}
