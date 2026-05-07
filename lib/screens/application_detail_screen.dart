import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/application_provider.dart';
import '../models/job_application.dart';
import '../utils/app_colors.dart';
import '../widgets/status_badge.dart';
import '../widgets/glass_card.dart';

class ApplicationDetailScreen extends StatelessWidget {
  final JobApplication application;

  const ApplicationDetailScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // App ID Header
                  _buildIdBanner(context),
                  const SizedBox(height: 8),
                  // Status Stepper
                  _buildStatusStepper(context),
                  const SizedBox(height: 16),
                  // Info Cards
                  _buildInfoSection(context),
                  const SizedBox(height: 16),
                  // Resume Link
                  _buildResumeLink(context),
                  const SizedBox(height: 16),
                  // Notes
                  if (application.notes.isNotEmpty)
                    _buildNotes(context),
                  const SizedBox(height: 16),
                  // Danger Zone
                  _buildDeleteButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            application.companyName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            application.jobRole,
            style: const TextStyle(color: AppColors.textHint, fontSize: 12),
          ),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1040), Color(0xFF0F0E17)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Application ID',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                application.applicationId,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          StatusBadge(status: application.status),
        ],
      ),
    );
  }

  Widget _buildStatusStepper(BuildContext context) {
    final statusList = ApplicationStatus.values;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Update Status',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ...statusList.asMap().entries.map((entry) {
            final idx = entry.key;
            final status = entry.value;
            final isCurrent = application.statusIndex == idx;
            final isPast = application.statusIndex > idx;

            return GestureDetector(
              onTap: () {
                context.read<ApplicationProvider>().updateStatus(
                      application.id,
                      status,
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Status updated to ${application.statusLabel}'),
                    backgroundColor: AppColors.statusColor(idx),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Circle indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCurrent || isPast
                            ? AppColors.statusColor(idx)
                            : AppColors.inputFill,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrent || isPast
                              ? AppColors.statusColor(idx)
                              : AppColors.cardBorder,
                          width: isCurrent ? 3 : 1,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: AppColors.statusColor(idx).withOpacity(0.4),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: isCurrent || isPast
                          ? const Icon(Icons.check, color: Colors.white, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _statusFullLabel(status),
                        style: TextStyle(
                          color: isCurrent
                              ? AppColors.statusColor(idx)
                              : isPast
                                  ? AppColors.textSecondary
                                  : AppColors.textHint,
                          fontWeight:
                              isCurrent ? FontWeight.w700 : FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.statusColor(idx).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Current',
                          style: TextStyle(
                            color: AppColors.statusColor(idx),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _statusFullLabel(ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.interviewScheduled:
        return 'Interview Scheduled';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.selected:
        return 'Selected 🎉';
    }
  }

  Widget _buildInfoSection(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Details',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _infoRow(Icons.business_rounded, 'Company', application.companyName),
          const Divider(color: AppColors.divider, height: 20),
          _infoRow(Icons.work_outline_rounded, 'Role', application.jobRole),
          const Divider(color: AppColors.divider, height: 20),
          _infoRow(
            Icons.calendar_today_rounded,
            'Date Applied',
            DateFormat('MMMM dd, yyyy').format(application.dateApplied),
          ),
          const Divider(color: AppColors.divider, height: 20),
          _infoRow(
            Icons.access_time_rounded,
            'Added On',
            DateFormat('MMM dd, yyyy  hh:mm a').format(application.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.textHint, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResumeLink(BuildContext context) {
    return GlassCard(
      borderColor: AppColors.accentGold.withOpacity(0.3),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppGradients.gold,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resume Used',
                  style: TextStyle(color: AppColors.textHint, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  application.resumeProfileName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.link_rounded, color: AppColors.accentGold),
        ],
      ),
    );
  }

  Widget _buildNotes(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.note_alt_rounded, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Notes',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            application.notes,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _confirmDelete(context),
          icon: const Icon(Icons.delete_rounded, color: AppColors.rejected),
          label: const Text(
            'Delete Application',
            style: TextStyle(color: AppColors.rejected),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.rejected),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Application?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textHint)),
          ),
          TextButton(
            onPressed: () {
              context.read<ApplicationProvider>().deleteApplication(application.id);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Application deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.rejected)),
          ),
        ],
      ),
    );
  }
}
