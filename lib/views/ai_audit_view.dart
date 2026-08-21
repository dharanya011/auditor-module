import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../providers/audit_state.dart';
import '../widgets/status_badge.dart';

class AIAuditView extends StatelessWidget {
  final AuditState state;

  const AIAuditView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: Color(0xFF818CF8), size: 28),
                  SizedBox(width: 12),
                  Text(
                    'AI-Assisted ERP Audit & Anomaly Detection',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'AI acts as a detection layer: identifying unusual grade patterns, missing submission hash links, faculty report conflicts, and post-approval grade changes.',
                style: TextStyle(color: Color(0xFFA5B4FC), fontSize: 13),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text('Active AI Anomalies & Recommendations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.aiAnomalies.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final anomaly = state.aiAnomalies[index];
            return Container(
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.psychology_rounded, color: Colors.purple),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(anomaly.anomalyTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('Category: ${anomaly.category} • Target: ${anomaly.recordReference}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      StatusBadge(status: anomaly.severity),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Reason: ${anomaly.detectionReason}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text('AI Recommendation: ${anomaly.recommendation}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: state.canFlagIssue
                            ? () {
                                state.flagIssue(anomaly.recordReference, anomaly.detectionReason, anomaly.severity);
                              }
                            : null,
                        icon: const Icon(Icons.flag_rounded, size: 16),
                        label: const Text('Accept & Flag Case'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
