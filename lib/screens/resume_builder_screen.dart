import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/resume_provider.dart';
import '../models/resume.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_card.dart';

class ResumeBuilderScreen extends StatefulWidget {
  final Resume? existingResume;

  const ResumeBuilderScreen({super.key, this.existingResume});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Personal Details
  final _profileNameCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _objectiveCtrl = TextEditingController();

  // Education
  List<Education> _educationList = [];

  // Skills
  List<String> _skills = [];
  final _skillCtrl = TextEditingController();

  // Experience
  List<Experience> _experiences = [];

  bool get isEditing => widget.existingResume != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    if (isEditing) {
      final r = widget.existingResume!;
      _profileNameCtrl.text = r.profileName;
      _fullNameCtrl.text = r.fullName;
      _emailCtrl.text = r.email;
      _phoneCtrl.text = r.phone;
      _addressCtrl.text = r.address;
      _objectiveCtrl.text = r.objective;
      _educationList = List.from(r.education);
      _skills = List.from(r.skills);
      _experiences = List.from(r.experiences);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _profileNameCtrl.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _objectiveCtrl.dispose();
    _skillCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }
    if (_educationList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one education entry'),
          backgroundColor: AppColors.rejected,
        ),
      );
      _tabController.animateTo(1);
      return;
    }
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one skill'),
          backgroundColor: AppColors.rejected,
        ),
      );
      _tabController.animateTo(2);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final provider = context.read<ResumeProvider>();
      if (isEditing) {
        final r = widget.existingResume!;
        r.profileName = _profileNameCtrl.text.trim();
        r.fullName = _fullNameCtrl.text.trim();
        r.email = _emailCtrl.text.trim();
        r.phone = _phoneCtrl.text.trim();
        r.address = _addressCtrl.text.trim();
        r.objective = _objectiveCtrl.text.trim();
        r.education = _educationList;
        r.skills = _skills;
        r.experiences = _experiences;
        await provider.updateResume(r);
      } else {
        await provider.createResume(
          profileName: _profileNameCtrl.text.trim(),
          fullName: _fullNameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          objective: _objectiveCtrl.text.trim(),
          education: _educationList,
          skills: _skills,
          experiences: _experiences,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Resume updated!' : 'Resume created!'),
            backgroundColor: AppColors.selected,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.rejected,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Column(
          children: [
            // Custom App Bar
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1040), Color(0xFF0F0E17)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              isEditing ? 'Edit Resume' : 'Build Resume',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading ? null : _save,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : const Text(
                                    'Save',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textHint,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 2,
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      tabs: const [
                        Tab(icon: Icon(Icons.person_rounded, size: 20), text: 'Personal'),
                        Tab(icon: Icon(Icons.school_rounded, size: 20), text: 'Education'),
                        Tab(icon: Icon(Icons.psychology_rounded, size: 20), text: 'Skills'),
                        Tab(icon: Icon(Icons.work_rounded, size: 20), text: 'Experience'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Tab Content
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPersonalTab(),
                    _buildEducationTab(),
                    _buildSkillsTab(),
                    _buildExperienceTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildField(
            controller: _profileNameCtrl,
            label: 'Profile Name *',
            hint: 'e.g. Software Engineer Resume',
            icon: Icons.badge_rounded,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Profile name is required' : null,
          ),
          _buildField(
            controller: _fullNameCtrl,
            label: 'Full Name *',
            hint: 'Your full name',
            icon: Icons.person_rounded,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Full name is required' : null,
          ),
          _buildField(
            controller: _emailCtrl,
            label: 'Email *',
            hint: 'your@email.com',
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          _buildField(
            controller: _phoneCtrl,
            label: 'Phone *',
            hint: '+91 9876543210',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Phone is required' : null,
          ),
          _buildField(
            controller: _addressCtrl,
            label: 'Address',
            hint: 'City, State, Country',
            icon: Icons.location_on_rounded,
          ),
          _buildField(
            controller: _objectiveCtrl,
            label: 'Career Objective',
            hint: 'Brief professional summary...',
            icon: Icons.lightbulb_rounded,
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Next: Education'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ..._educationList.asMap().entries.map((entry) {
            final i = entry.key;
            final edu = entry.value;
            return GlassCard(
              margin: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          edu.degree,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_rounded, color: AppColors.rejected, size: 20),
                        onPressed: () => setState(() => _educationList.removeAt(i)),
                      ),
                    ],
                  ),
                  Text(edu.institution, style: const TextStyle(color: AppColors.textSecondary)),
                  Text('${edu.year}  •  ${edu.grade}', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                ],
              ),
            );
          }),
          GlassCard(
            borderColor: AppColors.primary.withOpacity(0.3),
            onTap: () => _showEducationDialog(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Add Education',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _tabController.animateTo(0),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.cardBorder),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(2),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Skills'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEducationDialog([Education? existing, int? index]) {
    final degreeCtrl = TextEditingController(text: existing?.degree ?? '');
    final institutionCtrl = TextEditingController(text: existing?.institution ?? '');
    final yearCtrl = TextEditingController(text: existing?.year ?? '');
    final gradeCtrl = TextEditingController(text: existing?.grade ?? '');
    final key = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          existing == null ? 'Add Education' : 'Edit Education',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Form(
          key: key,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(degreeCtrl, 'Degree / Course *', validator: (v) =>
                    v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 10),
                _dialogField(institutionCtrl, 'Institution *', validator: (v) =>
                    v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 10),
                _dialogField(yearCtrl, 'Year (e.g. 2024)', validator: (v) =>
                    v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 10),
                _dialogField(gradeCtrl, 'Grade / CGPA'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textHint)),
          ),
          ElevatedButton(
            onPressed: () {
              if (key.currentState!.validate()) {
                final edu = Education(
                  degree: degreeCtrl.text.trim(),
                  institution: institutionCtrl.text.trim(),
                  year: yearCtrl.text.trim(),
                  grade: gradeCtrl.text.trim(),
                );
                setState(() {
                  if (index != null) {
                    _educationList[index] = edu;
                  } else {
                    _educationList.add(edu);
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _skillCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Enter a skill (e.g. Flutter)',
                    prefixIcon: Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                  ),
                  onFieldSubmitted: (v) {
                    if (v.trim().isNotEmpty) {
                      setState(() {
                        _skills.add(v.trim());
                        _skillCtrl.clear();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  if (_skillCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _skills.add(_skillCtrl.text.trim());
                      _skillCtrl.clear();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                child: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_skills.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Text(
                'No skills added yet.\nType a skill above and press Add.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textHint),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.asMap().entries.map((entry) {
                return Chip(
                  label: Text(entry.value),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => setState(() => _skills.removeAt(entry.key)),
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                  labelStyle: const TextStyle(color: AppColors.primaryLight, fontSize: 13),
                  deleteIconColor: AppColors.textHint,
                );
              }).toList(),
            ),
          const SizedBox(height: 20),
          // Suggested skills
          const Text(
            'Suggested Skills',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Flutter', 'Dart', 'Python', 'Java', 'React', 'Node.js',
              'SQL', 'Git', 'Firebase', 'REST API', 'Machine Learning', 'Communication',
            ].map((s) {
              final alreadyAdded = _skills.contains(s);
              return InkWell(
                onTap: alreadyAdded ? null : () => setState(() => _skills.add(s)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: alreadyAdded
                        ? AppColors.cardBorder
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    s,
                    style: TextStyle(
                      color: alreadyAdded ? AppColors.textHint : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _tabController.animateTo(1),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.cardBorder),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(3),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Experience'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ..._experiences.asMap().entries.map((entry) {
            final i = entry.key;
            final exp = entry.value;
            return GlassCard(
              margin: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          exp.role,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_rounded, color: AppColors.rejected, size: 20),
                        onPressed: () => setState(() => _experiences.removeAt(i)),
                      ),
                    ],
                  ),
                  Text(exp.company, style: const TextStyle(color: AppColors.textSecondary)),
                  Text(exp.duration, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                  if (exp.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(exp.description, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                    ),
                ],
              ),
            );
          }),
          GlassCard(
            borderColor: AppColors.accentGold.withOpacity(0.3),
            onTap: _showExperienceDialog,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_rounded, color: AppColors.accentGold),
                const SizedBox(width: 8),
                const Text(
                  'Add Experience (Optional)',
                  style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _tabController.animateTo(2),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.cardBorder),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _save,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(isEditing ? 'Update' : 'Save Resume'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExperienceDialog() {
    final companyCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final key = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Experience', style: TextStyle(color: AppColors.textPrimary)),
        content: Form(
          key: key,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(companyCtrl, 'Company Name *', validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 10),
                _dialogField(roleCtrl, 'Role / Designation *', validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 10),
                _dialogField(durationCtrl, 'Duration (e.g. Jan 2023 – Dec 2023)', validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 10),
                _dialogField(descCtrl, 'Description (optional)', maxLines: 3),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textHint)),
          ),
          ElevatedButton(
            onPressed: () {
              if (key.currentState!.validate()) {
                setState(() {
                  _experiences.add(Experience(
                    company: companyCtrl.text.trim(),
                    role: roleCtrl.text.trim(),
                    duration: durationCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: AppColors.textPrimary),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: AppColors.primary, size: 20) : null,
        ),
      ),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String label, {
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
