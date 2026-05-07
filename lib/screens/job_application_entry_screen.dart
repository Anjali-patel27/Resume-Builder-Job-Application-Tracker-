import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/application_provider.dart';
import '../providers/resume_provider.dart';
import '../models/resume.dart';
import '../utils/app_colors.dart';

class JobApplicationEntryScreen extends StatefulWidget {
  const JobApplicationEntryScreen({super.key});

  @override
  State<JobApplicationEntryScreen> createState() =>
      _JobApplicationEntryScreenState();
}

class _JobApplicationEntryScreenState
    extends State<JobApplicationEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _dateApplied = DateTime.now();
  Resume? _selectedResume;
  bool _isLoading = false;

  @override
  void dispose() {
    _companyCtrl.dispose();
    _roleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateApplied,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dateApplied = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedResume == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a resume to link'),
          backgroundColor: AppColors.rejected,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final app = await context.read<ApplicationProvider>().addApplication(
            companyName: _companyCtrl.text.trim(),
            jobRole: _roleCtrl.text.trim(),
            dateApplied: _dateApplied,
            resumeId: _selectedResume!.id,
            resumeProfileName: _selectedResume!.profileName,
            notes: _notesCtrl.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application added! ID: ${app.applicationId}'),
            backgroundColor: AppColors.selected,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.rejected),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resumes = context.watch<ResumeProvider>().resumes;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.background,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'New Application',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
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
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildSectionLabel('Job Details'),
                      _buildTextField(
                        controller: _companyCtrl,
                        label: 'Company Name *',
                        hint: 'e.g. Google, Infosys',
                        icon: Icons.business_rounded,
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Company name is required'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _roleCtrl,
                        label: 'Job Role *',
                        hint: 'e.g. Flutter Developer',
                        icon: Icons.work_outline_rounded,
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Job role is required'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      // Date Picker
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Date Applied',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('MMMM dd, yyyy').format(_dateApplied),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textHint,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionLabel('Link Resume'),
                      const SizedBox(height: 4),
                      if (resumes.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.rejected.withOpacity(0.4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: AppColors.rejected, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'No resumes available. Create a resume first.',
                                  style: TextStyle(color: AppColors.rejected, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...resumes.map((resume) => _ResumePickerCard(
                          resume: resume,
                          isSelected: _selectedResume?.id == resume.id,
                          onTap: () => setState(() => _selectedResume = resume),
                        )),
                      const SizedBox(height: 24),
                      _buildSectionLabel('Additional Notes'),
                      const SizedBox(height: 4),
                      _buildTextField(
                        controller: _notesCtrl,
                        label: 'Notes (optional)',
                        hint: 'Referral, recruiter name, etc...',
                        icon: Icons.note_alt_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _submit,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                          label: const Text('Submit Application'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary),
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.primary, size: 20)
            : null,
      ),
    );
  }
}

class _ResumePickerCard extends StatelessWidget {
  final Resume resume;
  final bool isSelected;
  final VoidCallback onTap;

  const _ResumePickerCard({
    required this.resume,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.primary : null,
          color: isSelected ? null : AppColors.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  resume.profileName[0].toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primary,
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
                    resume.profileName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    resume.fullName,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
