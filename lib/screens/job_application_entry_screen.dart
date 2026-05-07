import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/application_provider.dart';
import '../providers/resume_provider.dart';
import '../models/resume.dart';
import '../utils/app_colors.dart';
import 'resume_builder_screen.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';

class JobApplicationEntryScreen extends StatefulWidget {
  const JobApplicationEntryScreen({super.key});

  @override
  State<JobApplicationEntryScreen> createState() => _JobApplicationEntryScreenState();
}

class _JobApplicationEntryScreenState extends State<JobApplicationEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  Resume? _selectedResume;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final resumes = context.watch<ResumeProvider>().resumes;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Application')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputLabel('COMPANY DETAILS'),
              const SizedBox(height: 12),
              _buildField(_companyCtrl, 'Company Name', Icons.business_rounded),
              _buildField(_roleCtrl, 'Job Role / Title', Icons.work_outline_rounded),
              
              const SizedBox(height: 24),
              _buildInputLabel('APPLICATION DATE'),
              const SizedBox(height: 12),
              _buildDatePicker(context),
              
              const SizedBox(height: 24),
              _buildInputLabel('SELECT RESUME PROFILE'),
              const SizedBox(height: 12),
              _buildResumePicker(resumes),
              
              const SizedBox(height: 24),
              _buildInputLabel('ADDITIONAL NOTES'),
              const SizedBox(height: 12),
              _buildField(_notesCtrl, 'Key points, contact person, etc.', Icons.notes_rounded, maxLines: 4),
              
              const SizedBox(height: 40),
              GradientButton(
                label: 'Save Application',
                isLoading: _isSaving,
                onPressed: _selectedResume == null ? null : _handleSave,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2));
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
        ),
        validator: (v) => v!.isEmpty ? 'Field required' : null,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (d != null) setState(() => _selectedDate = d);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 16),
              Text(DateFormat('MMMM dd, yyyy').format(_selectedDate), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            ],
          ),
          const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textHint),
        ],
      ),
    );
  }

  Widget _buildResumePicker(List<Resume> resumes) {
    if (resumes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.rejected.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.rejected.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            const Text(
              'No resume profiles found.',
              style: TextStyle(color: AppColors.rejected, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ResumeBuilderScreen()),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create Your First Resume'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rejected.withOpacity(0.1),
                foregroundColor: AppColors.rejected,
                elevation: 0,
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: resumes.length,
        itemBuilder: (context, i) {
          final r = resumes[i];
          final isSelected = _selectedResume?.id == r.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedResume = r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_rounded, color: isSelected ? AppColors.primary : AppColors.textHint, size: 24),
                  const SizedBox(height: 8),
                  Text(r.profileName, style: TextStyle(color: isSelected ? AppColors.textPrimary : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await context.read<ApplicationProvider>().addApplication(
        companyName: _companyCtrl.text.trim(),
        jobRole: _roleCtrl.text.trim(),
        dateApplied: _selectedDate,
        resumeId: _selectedResume!.id,
        resumeProfileName: _selectedResume!.profileName,
        notes: _notesCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
