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
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 500),
                  childAnimationBuilder: (widget) => FadeInAnimation(
                    child: SlideAnimation(verticalOffset: 20, child: widget),
                  ),
                  children: [
                    _buildOverviewCards(appProvider, resumeProvider),
                    const SizedBox(height: 24),
                    if (appProvider.totalApplications > 0) ...[
                      _buildChartSection(context, appProvider),
                      const SizedBox(height: 24),
                    ],
                    _buildSectionHeader('Recent Activity', () {
                      // Navigate to search/list
                    }),
                    if (appProvider.recentApplications.isEmpty)
                      _buildEmptyState()
                    else
                      ...appProvider.recentApplications.map((app) => _buildApplicationTile(context, app)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const JobApplicationEntryScreen()),
        ),
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Add Job', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        backgroundColor: AppColors.primary,
        elevation: 4,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withOpacity(0.15), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, MMM d').format(DateTime.now()),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Career Dashboard',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.surface,
                          child: Icon(Icons.person_rounded, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards(ApplicationProvider appProvider, ResumeProvider resumeProvider) {
    final dist = appProvider.statusDistribution;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: [
          _StatCard(
            label: 'Applications',
            value: appProvider.totalApplications.toString(),
            icon: Icons.work_rounded,
            color: AppColors.primary,
          ),
          _StatCard(
            label: 'Resumes',
            value: resumeProvider.resumes.length.toString(),
            icon: Icons.description_rounded,
            color: AppColors.shortlisted,
          ),
          _StatCard(
            label: 'Interviews',
            value: (dist[ApplicationStatus.interviewScheduled] ?? 0).toString(),
            icon: Icons.video_call_rounded,
            color: AppColors.interview,
          ),
          _StatCard(
            label: 'Success Rate',
            value: appProvider.totalApplications == 0 
                ? '0%' 
                : '${((dist[ApplicationStatus.selected] ?? 0) / appProvider.totalApplications * 100).toInt()}%',
            icon: Icons.trending_up_rounded,
            color: AppColors.selected,
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(BuildContext context, ApplicationProvider provider) {
    final dist = provider.statusDistribution;
    final total = provider.totalApplications;

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Distribution',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
                    sections: ApplicationStatus.values.map((s) {
                      final val = dist[s] ?? 0;
                      return PieChartSectionData(
                        color: AppColors.getStatusColor(s.index),
                        value: val.toDouble(),
                        title: '',
                        radius: 20,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: ApplicationStatus.values.take(3).map((s) {
                    final val = dist[s] ?? 0;
                    final pct = total == 0 ? 0 : (val / total * 100).toInt();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ChartLegendItem(status: s, count: val, percentage: pct),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAction) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          TextButton(
            onPressed: onAction,
            child: const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationTile(BuildContext context, JobApplication app) {
    return GlassCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ApplicationDetailScreen(application: app)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                app.companyName.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.companyName,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  app.jobRole,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(status: app.status, compact: true),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.rocket_launch_rounded, size: 64, color: AppColors.primary.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text(
              'No applications found',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ready to land your dream job? Start by\nadding your first application.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartLegendItem extends StatelessWidget {
  final ApplicationStatus status;
  final int count;
  final int percentage;

  const _ChartLegendItem({required this.status, required this.count, required this.percentage});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getStatusColor(status.index);
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            status.name.substring(0, 1).toUpperCase() + status.name.substring(1),
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
        Text(
          '$percentage%',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
