import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';

class ActionModal extends StatefulWidget {
  final String recordId;
  final String actionType; // 'Flag Issue' | 'Request Correction' | 'Add Remark'
  final AuditState state;

  const ActionModal({
    super.key,
    required this.recordId,
    required this.actionType,
    required this.state,
  });

  @override
  State<ActionModal> createState() => _ActionModalState();
}

class _ActionModalState extends State<ActionModal> {
  final _reasonController = TextEditingController();
  String _selectedSeverity = 'High';
  String _assignedRole = 'HOD - Computer Science';

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 40, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isMobile ? double.infinity : 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.actionType == 'Flag Issue' ? Icons.flag_rounded : Icons.edit_note_rounded,
                  color: widget.actionType == 'Flag Issue' ? Colors.red : AppColors.accent,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${widget.actionType} — Record: ${widget.recordId}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            if (widget.actionType == 'Flag Issue') ...[
              const Text('Severity Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Low', 'Medium', 'High', 'Critical'].map((s) {
                  final isSel = _selectedSeverity == s;
                  return ChoiceChip(
                    label: Text(s),
                    selected: isSel,
                    onSelected: (val) {
                      if (val) setState(() => _selectedSeverity = s);
                    },
                    selectedColor: Colors.red.shade100,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.red.shade900 : AppColors.textPrimary,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Assign Case To', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _assignedRole,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'HOD - Computer Science', child: Text('HOD - Computer Science')),
                  DropdownMenuItem(value: 'HOD - Information Technology', child: Text('HOD - Information Technology')),
                  DropdownMenuItem(value: 'Dean Academics', child: Text('Dean Academics')),
                  DropdownMenuItem(value: 'Controller of Examinations', child: Text('Controller of Examinations')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _assignedRole = val);
                },
              ),
              const SizedBox(height: 16),
            ],

            Text(
              '${widget.actionType} Reason & Auditor Observations',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter detailed verification remarks or correction request details...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    final txt = _reasonController.text.trim();
                    final reason = txt.isEmpty ? 'Discrepancy noted during audit verification.' : txt;
                    widget.state.flagIssue(widget.recordId, reason, _selectedSeverity);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: Text('Submit ${widget.actionType}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.actionType == 'Flag Issue' ? Colors.red : AppColors.accent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
