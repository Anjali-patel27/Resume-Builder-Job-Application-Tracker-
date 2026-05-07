import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../providers/application_provider.dart';
import '../providers/resume_provider.dart';
import '../models/job_application.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/status_badge.dart';
import 'job_application_entry_screen.dart';
import 'application_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<ApplicationProvider>();
    final resumeProvider = context.watch<ResumeProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: AnimationLimiter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 400),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 30,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      const SizedBox(height: 8),
                      _buildStatsRow(context, appProvider, resumeProvider),
                      const SizedBox(height: 16),
                      if (appProvider.totalApplications > 0) ...[
                        _buildSectionHeader('Application Status', context),
                        _buildPieChart(context, appProvider),
                        const SizedBox(height: 8),
                        _buildStatusLegend(context, appProvider),
                        const SizedBox(height: 16),
                      ],
                      _buildSectionHeader('Recent Applications', context),
                      if (appProvider.recentApplications.isEmpty)
                        _buildEmptyRecent(context)
                      else
                        ...appProvider.recentApplications
                            .map((app) => _buildApplicationCard(context, app)),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const JobApplicationEntryScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Application'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1040), Color(0xFF0F0E17)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Good Morning! 👋',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppGradients.primary.createShader(bounds),
                    child: const Text(
                      'ResumeTrack Pro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Track your career journey',
                    style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        collapseMode: CollapseMode.pin,
        title: const Text(
          'ResumeTrack Pro',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    ApplicationProvider appProvider,
    ResumeProvider resumeProvider,
  ) {
    final dist = appProvider.statusDistribution;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Total Applications',
              value: '${appProvider.totalApplications}',
              icon: Icons.work_outline_rounded,
              gradient: AppGradients.primary,
              glowColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              label: 'Resumes Built',
              value: '${resumeProvider.resumes.length}',
              icon: Icons.description_outlined,
              gradient: AppGradients.gold,
              glowColor: AppColors.accentGold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              label: 'Interviews',
              value: '${dist[ApplicationStatus.interviewScheduled] ?? 0}',
              icon: Icons.calendar_today_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB74D), Color(0xFFFF8F00)],
              ),
              glowColor: AppColors.interviewScheduled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, ApplicationProvider provider) {
    final dist = provider.statusDistribution;
    final total = provider.totalApplications;
    if (total == 0) return const SizedBox.shrink();

    final sections = <PieChartSectionData>[];
    for (final entry in dist.entries) {
      if (entry.value == 0) continue;
      final pct = (entry.value / total * 100).toStringAsFixed(0);
      sections.add(
        PieChartSectionData(
          value: entry.value.toDouble(),
          color: AppColors.statusColor(entry.key.index),
          radius: 55,
          title: '$pct%',
          titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 45,
          sectionsSpace: 3,
          pieTouchData: PieTouchData(enabled: true),
        ),
      ),
    );
  }

  Widget _buildStatusLegend(BuildContext context, ApplicationProvider provider) {
    final dist = provider.statusDistribution;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: ApplicationStatus.values.map((s) {
          final count = dist[s] ?? 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.statusColor(s.index).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.statusColor(s.index).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.statusColor(s.index),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$count ${_shortLabel(s)}',
                  style: TextStyle(
                    color: AppColors.statusColor(s.index),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _shortLabel(ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.interviewScheduled:
        return 'Interview';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.selected:
        return 'Selected';
    }
  }

  Widget _buildEmptyRecent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GlassCard(
        child: Column(
          children: [
            const Icon(
              Icons.inbox_rounded,
              color: AppColors.textHint,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'No applications yet',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap + to add your first job application',
              style: TextStyle(color: AppColors.textHint, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context, JobApplication app) {
    return GlassCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ApplicationDetailScreen(application: app),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                app.companyName.isNotEmpty
                    ? app.companyName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.companyName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  app.jobRole,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(app.dateApplied),
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(status: app.status, compact: true),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final Color glowColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E35), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.textHint, fontSize: 10),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
