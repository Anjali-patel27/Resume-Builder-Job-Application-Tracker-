import 'package:flutter/material.dart';
import '../models/job_application.dart';
import '../utils/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final ApplicationStatus status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getStatusColor(status.index);
    final label = _getLabel(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 14,
        vertical: compact ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _getLabel(ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.applied: return 'Applied';
      case ApplicationStatus.shortlisted: return 'Shortlisted';
      case ApplicationStatus.interviewScheduled: return 'Interview';
      case ApplicationStatus.rejected: return 'Rejected';
      case ApplicationStatus.selected: return 'Selected';
    }
  }
}
