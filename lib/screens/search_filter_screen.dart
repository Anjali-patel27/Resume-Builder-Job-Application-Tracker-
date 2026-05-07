import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/application_provider.dart';
import '../models/job_application.dart';
import '../utils/app_colors.dart';
import '../widgets/status_badge.dart';
import '../widgets/glass_card.dart';
import 'application_detail_screen.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final _searchCtrl = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicationProvider>();
    final filtered = provider.filteredApplications;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Column(
          children: [
            _buildHeader(context, provider),
            if (_showFilters) _buildFilterPanel(context, provider),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmpty(provider)
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) =>
                          _buildApplicationCard(context, filtered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ApplicationProvider provider) {
    final hasActiveFilters = provider.filterStatus != null ||
        provider.searchQuery.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1040), Color(0xFF0F0E17)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppGradients.primary.createShader(bounds),
                    child: const Text(
                      'Search & Filter',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (hasActiveFilters)
                    TextButton(
                      onPressed: () {
                        provider.clearFilters();
                        _searchCtrl.clear();
                      },
                      child: const Text(
                        'Clear All',
                        style: TextStyle(color: AppColors.accent, fontSize: 13),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Search bar
              TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                onChanged: provider.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search company or role...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppColors.textHint),
                          onPressed: () {
                            _searchCtrl.clear();
                            provider.setSearchQuery('');
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              // Filter toggles
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _showFilters = !_showFilters),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _showFilters
                            ? AppColors.primary.withOpacity(0.2)
                            : AppColors.inputFill,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _showFilters ? AppColors.primary : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_list_rounded,
                            color: _showFilters ? AppColors.primary : AppColors.textHint,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Filters',
                            style: TextStyle(
                              color: _showFilters ? AppColors.primary : AppColors.textHint,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${provider.filteredApplications.length} result${provider.filteredApplications.length != 1 ? 's' : ''}',
                    style: const TextStyle(color: AppColors.textHint, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPanel(BuildContext context, ApplicationProvider provider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Status',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // All chip
                GestureDetector(
                  onTap: () => provider.setFilterStatus(null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: provider.filterStatus == null
                          ? AppColors.primary
                          : AppColors.inputFill,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: provider.filterStatus == null
                            ? AppColors.primary
                            : AppColors.cardBorder,
                      ),
                    ),
                    child: Text(
                      'All',
                      style: TextStyle(
                        color: provider.filterStatus == null
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                ...ApplicationStatus.values.map((s) {
                  final isSelected = provider.filterStatus == s;
                  return GestureDetector(
                    onTap: () => provider.setFilterStatus(s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.statusColor(s.index).withOpacity(0.2)
                            : AppColors.inputFill,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.statusColor(s.index)
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Text(
                        _shortLabel(s),
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.statusColor(s.index)
                              : AppColors.textHint,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
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

  Widget _buildEmpty(ApplicationProvider provider) {
    final hasFilters = provider.filterStatus != null || provider.searchQuery.isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, color: AppColors.textHint, size: 60),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No results found' : 'No applications yet',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting your search or filters'
                : 'Add job applications from the Dashboard',
            style: const TextStyle(color: AppColors.textHint, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
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
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app.jobRole,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: app.status, compact: true),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.fingerprint_rounded, color: AppColors.textHint, size: 14),
              const SizedBox(width: 4),
              Text(
                app.applicationId,
                style: const TextStyle(color: AppColors.textHint, fontSize: 11),
              ),
              const Spacer(),
              const Icon(Icons.calendar_today_rounded, color: AppColors.textHint, size: 14),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM dd, yyyy').format(app.dateApplied),
                style: const TextStyle(color: AppColors.textHint, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
