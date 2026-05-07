import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/job_application.dart';
import '../providers/application_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/status_badge.dart';
import '../widgets/glass_card.dart';

class ApplicationDetailScreen extends StatelessWidget {
  final JobApplication application;

  const ApplicationDetailScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Application Details'),
        actions: [
          IconButton(
            onPressed: () => _showDeleteConfirm(context),
            icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.rejected),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildStatusTracker(context),
            const SizedBox(height: 32),
            _buildInfoGrid(),
            const SizedBox(height: 32),
            if (application.notes.isNotEmpty) _buildNotesSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              application.companyName[0].toUpperCase(),
              style: const TextStyle(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                application.companyName,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                application.jobRole,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTracker(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TRACKING STATUS', style: TextStyle(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ApplicationStatus.values.map((s) {
              final isCompleted = s.index <= application.status.index;
              final isCurrent = s == application.status;
              return GestureDetector(
                onTap: () => context.read<ApplicationProvider>().updateApplicationStatus(application.id, s),
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted ? AppColors.getStatusColor(s.index) : AppColors.cardBorder,
                        shape: BoxShape.circle,
                        border: isCurrent ? Border.all(color: Colors.white, width: 2) : null,
                      ),
                      child: Icon(
                        isCompleted ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: isCompleted ? AppColors.textPrimary : AppColors.textHint,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Center(child: StatusBadge(status: application.status)),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _InfoItem(label: 'DATE APPLIED', value: DateFormat('MMM dd, yyyy').format(application.dateApplied)),
        _InfoItem(label: 'RESUME USED', value: application.resumeProfileName),
        _InfoItem(label: 'ID', value: application.id.substring(0, 8).toUpperCase()),
        _InfoItem(label: 'PLATFORM', value: 'Manual Entry'),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('NOTES', style: TextStyle(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
          child: Text(application.notes, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
        ),
      ],
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Application?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<ApplicationProvider>().deleteApplication(application.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rejected),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
