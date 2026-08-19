import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isCompact;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData? icon;

    final lower = status.toLowerCase();

    if (lower.contains('verified') || lower.contains('accepted') || lower.contains('closed') || lower.contains('completed')) {
      bg = const Color(0xFFECFDF5);
      fg = const Color(0xFF059669);
      icon = Icons.check_circle_rounded;
    } else if (lower.contains('pending') || lower.contains('review') || lower.contains('under')) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
      icon = Icons.hourglass_bottom_rounded;
    } else if (lower.contains('discrepancy') || lower.contains('missing') || lower.contains('conflict') || lower.contains('flagged') || lower.contains('correction')) {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFDC2626);
      icon = Icons.error_rounded;
    } else if (lower.contains('rejected') || lower.contains('high') || lower.contains('critical')) {
      bg = const Color(0xFFFEF2F2);
      fg = const Color(0xFF991B1B);
      icon = Icons.warning_rounded;
    } else if (lower.contains('medium')) {
      bg = const Color(0xFFFFF7ED);
      fg = const Color(0xFFEA580C);
      icon = Icons.remove_circle_outline_rounded;
    } else {
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF2563EB);
      icon = Icons.info_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ] else ...[
            Icon(icon, size: isCompact ? 12 : 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            status,
            style: TextStyle(
              color: fg,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
