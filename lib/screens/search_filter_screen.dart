import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/application_provider.dart';
import '../models/job_application.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/status_badge.dart';
import 'application_detail_screen.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  String _query = '';
  ApplicationStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicationProvider>();
    final results = provider.searchAndFilter(_query, _filterStatus);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            _buildFilterChips(),
            Expanded(
              child: results.isEmpty 
                  ? _buildEmptyResults() 
                  : _buildResultsList(results),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: TextField(
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: 'Search company or role...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
          suffixIcon: _query.isNotEmpty 
              ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => setState(() => _query = '')) 
              : null,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All'),
              selected: _filterStatus == null,
              onSelected: (s) => setState(() => _filterStatus = null),
            ),
          ),
          ...ApplicationStatus.values.map((status) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(status.name.substring(0, 1).toUpperCase() + status.name.substring(1)),
              selected: _filterStatus == status,
              selectedColor: AppColors.getStatusColor(status.index).withOpacity(0.2),
              labelStyle: TextStyle(color: _filterStatus == status ? AppColors.getStatusColor(status.index) : AppColors.textSecondary),
              onSelected: (s) => setState(() => _filterStatus = s ? status : null),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<JobApplication> results) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: results.length,
        itemBuilder: (context, i) {
          final app = results[i];
          return AnimationConfiguration.staggeredList(
            position: i,
            duration: const Duration(milliseconds: 400),
            child: FadeInAnimation(
              child: SlideAnimation(
                verticalOffset: 20,
                child: _buildResultTile(context, app),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultTile(BuildContext context, JobApplication app) {
    return GlassCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ApplicationDetailScreen(application: app))),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
            child: Center(child: Text(app.companyName[0].toUpperCase(), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app.companyName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                Text(app.jobRole, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          StatusBadge(status: app.status, compact: true),
        ],
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppColors.textHint.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('No matches found', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
