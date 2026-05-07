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

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _profileNameCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _objectiveCtrl = TextEditingController();

  List<Education> _educationList = [];
  List<String> _skills = [];
  final _skillCtrl = TextEditingController();
  List<Experience> _experiences = [];

  // Local state for inline forms
  int? _editingEduIndex; // -1 for new, null for none, index for editing
  int? _editingExpIndex;
  
  final _eduDegreeCtrl = TextEditingController();
  final _eduInstCtrl = TextEditingController();
  final _eduYearCtrl = TextEditingController();
  
  final _expRoleCtrl = TextEditingController();
  final _expCompCtrl = TextEditingController();
  final _expDurCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    if (widget.existingResume != null) {
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
    _eduDegreeCtrl.dispose();
    _eduInstCtrl.dispose();
    _eduYearCtrl.dispose();
    _expRoleCtrl.dispose();
    _expCompCtrl.dispose();
    _expDurCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }
    setState(() => _isLoading = true);
    
    try {
      final provider = context.read<ResumeProvider>();
      if (widget.existingResume != null) {
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
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.existingResume != null ? 'Edit Resume' : 'New Resume'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _save,
            icon: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Icon(Icons.check_circle_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          tabs: const [
            Tab(text: 'Basic'),
            Tab(text: 'Education'),
            Tab(text: 'Skills'),
            Tab(text: 'Experience'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicTab(),
            _buildEducationTab(),
            _buildSkillsTab(),
            _buildExperienceTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildField(_profileNameCtrl, 'Profile Name (e.g. My Primary Resume)', Icons.badge_outlined),
          _buildField(_fullNameCtrl, 'Full Name', Icons.person_outline),
          _buildField(_emailCtrl, 'Email Address', Icons.email_outlined),
          _buildField(_phoneCtrl, 'Phone Number', Icons.phone_outlined),
          _buildField(_addressCtrl, 'City, Country', Icons.location_on_outlined),
          _buildField(_objectiveCtrl, 'Professional Objective', Icons.info_outline, maxLines: 4),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
        ),
        validator: (v) => v!.isEmpty ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildEducationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_editingEduIndex == -1) _buildEduForm(isNew: true),
        ..._educationList.asMap().entries.map((e) {
          if (_editingEduIndex == e.key) return _buildEduForm(index: e.key);
          return GlassCard(
            margin: const EdgeInsets.only(bottom: 12),
            onTap: () => setState(() {
              _editingEduIndex = e.key;
              _eduDegreeCtrl.text = e.value.degree;
              _eduInstCtrl.text = e.value.institution;
              _eduYearCtrl.text = e.value.year;
            }),
            child: ListTile(
              title: Text(e.value.degree, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              subtitle: Text('${e.value.institution} (${e.value.year})'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.rejected),
                onPressed: () => setState(() => _educationList.removeAt(e.key)),
              ),
            ),
          );
        }),
        if (_editingEduIndex == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => setState(() {
                  _editingEduIndex = -1;
                  _eduDegreeCtrl.clear();
                  _eduInstCtrl.clear();
                  _eduYearCtrl.clear();
                }),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Education Details'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEduForm({int? index, bool isNew = false}) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      borderColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isNew ? 'New Education' : 'Edit Education', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: _eduDegreeCtrl, decoration: const InputDecoration(labelText: 'Degree / Certificate', hintText: 'e.g. B.Tech Computer Science')),
          const SizedBox(height: 12),
          TextField(controller: _eduInstCtrl, decoration: const InputDecoration(labelText: 'Institution', hintText: 'e.g. Harvard University')),
          const SizedBox(height: 12),
          TextField(controller: _eduYearCtrl, decoration: const InputDecoration(labelText: 'Year', hintText: 'e.g. 2024')),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => setState(() => _editingEduIndex = null), child: const Text('Cancel')),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  if (_eduDegreeCtrl.text.trim().isEmpty) return;
                  final edu = Education(
                    degree: _eduDegreeCtrl.text.trim(),
                    institution: _eduInstCtrl.text.trim(),
                    year: _eduYearCtrl.text.trim(),
                  );
                  setState(() {
                    if (index != null) _educationList[index] = edu;
                    else _educationList.add(edu);
                    _editingEduIndex = null;
                  });
                },
                child: const Text('Confirm Entry'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _skillCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(hintText: 'Add a skill (e.g. Flutter)'),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  if (_skillCtrl.text.isNotEmpty) {
                    setState(() => _skills.add(_skillCtrl.text.trim()));
                    _skillCtrl.clear();
                  }
                },
                child: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _skills.map((s) => Chip(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              label: Text(s, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              onDeleted: () => setState(() => _skills.remove(s)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_editingExpIndex == -1) _buildExpForm(isNew: true),
        ..._experiences.asMap().entries.map((e) {
          if (_editingExpIndex == e.key) return _buildExpForm(index: e.key);
          return GlassCard(
            margin: const EdgeInsets.only(bottom: 12),
            onTap: () => setState(() {
              _editingExpIndex = e.key;
              _expRoleCtrl.text = e.value.role;
              _expCompCtrl.text = e.value.company;
              _expDurCtrl.text = e.value.duration;
            }),
            child: ListTile(
              title: Text(e.value.role, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              subtitle: Text('${e.value.company} (${e.value.duration})'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.rejected),
                onPressed: () => setState(() => _experiences.removeAt(e.key)),
              ),
            ),
          );
        }),
        if (_editingExpIndex == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => setState(() {
                  _editingExpIndex = -1;
                  _expRoleCtrl.clear();
                  _expCompCtrl.clear();
                  _expDurCtrl.clear();
                }),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Experience Details'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExpForm({int? index, bool isNew = false}) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      borderColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isNew ? 'New Experience' : 'Edit Experience', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: _expRoleCtrl, decoration: const InputDecoration(labelText: 'Job Role', hintText: 'e.g. Senior Developer')),
          const SizedBox(height: 12),
          TextField(controller: _expCompCtrl, decoration: const InputDecoration(labelText: 'Company', hintText: 'e.g. Google')),
          const SizedBox(height: 12),
          TextField(controller: _expDurCtrl, decoration: const InputDecoration(labelText: 'Duration', hintText: 'e.g. 2021 - Present')),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => setState(() => _editingExpIndex = null), child: const Text('Cancel')),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  if (_expRoleCtrl.text.trim().isEmpty) return;
                  final exp = Experience(
                    role: _expRoleCtrl.text.trim(),
                    company: _expCompCtrl.text.trim(),
                    duration: _expDurCtrl.text.trim(),
                  );
                  setState(() {
                    if (index != null) _experiences[index] = exp;
                    else _experiences.add(exp);
                    _editingExpIndex = null;
                  });
                },
                child: const Text('Confirm Entry'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
