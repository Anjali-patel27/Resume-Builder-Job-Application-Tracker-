import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/resume_provider.dart';
import '../models/resume.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_card.dart';
import 'resume_builder_screen.dart';

class ResumeListScreen extends StatelessWidget {
  const ResumeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResumeProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, provider),
          if (provider.resumes.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(context))
          else
            SliverPadding(
              padding: const EdgeInsets.only(top: 16, bottom: 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final resume = provider.resumes[i];
                    return AnimationConfiguration.staggeredList(
                      position: i,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 30,
                        child: FadeInAnimation(child: _ResumeCard(resume: resume)),
                      ),
                    );
                  },
                  childCount: provider.resumes.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResumeBuilderScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create New', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ResumeProvider provider) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('My Resumes', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.shortlisted.withOpacity(0.1), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80, color: AppColors.textHint.withOpacity(0.3)),
          const SizedBox(height: 24),
          const Text(
            'No Resumes Created',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your professional profile to\nstart applying for jobs.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResumeBuilderScreen())),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  final Resume resume;
  const _ResumeCard({required this.resume});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResumeBuilderScreen(existingResume: resume))),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.article_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(resume.profileName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(resume.fullName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ],
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textHint),
                color: AppColors.surface,
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.rejected))),
                ],
                onSelected: (v) {
                  if (v == 'delete') _showDeleteDialog(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _Tag(icon: Icons.school_outlined, label: '${resume.education.length} Edu'),
              const SizedBox(width: 8),
              _Tag(icon: Icons.psychology_outlined, label: '${resume.skills.length} Skills'),
              const SizedBox(width: 8),
              _Tag(icon: Icons.work_outline_rounded, label: '${resume.experiences.length} Exp'),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Resume?'),
        content: const Text('This will remove the resume profile permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<ResumeProvider>().deleteResume(resume.id);
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

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Tag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBorder.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 14),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
