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
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.existingResume != null ? 'Edit Profile' : 'New Resume'),
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
          _buildField(_profileNameCtrl, 'Profile Name', Icons.badge_outlined),
          _buildField(_fullNameCtrl, 'Full Name', Icons.person_outline),
          _buildField(_emailCtrl, 'Email Address', Icons.email_outlined),
          _buildField(_phoneCtrl, 'Phone Number', Icons.phone_outlined),
          _buildField(_addressCtrl, 'Location', Icons.location_on_outlined),
          _buildField(_objectiveCtrl, 'Career Objective', Icons.info_outline, maxLines: 4),
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
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
        ),
        validator: (v) => v!.isEmpty ? 'Field required' : null,
      ),
    );
  }

  Widget _buildEducationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._educationList.asMap().entries.map((e) => GlassCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(e.value.degree, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(e.value.institution),
            trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() => _educationList.removeAt(e.key))),
          ),
        )),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _addEducation(),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Education'),
        ),
      ],
    );
  }

  void _addEducation() {
    // Simplified for demo, in real use show dialog
    setState(() => _educationList.add(Education(degree: 'Degree Name', institution: 'University', year: '2024')));
  }

  Widget _buildSkillsTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: TextFormField(controller: _skillCtrl, decoration: const InputDecoration(hintText: 'Enter skill...'))),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: () {
                if (_skillCtrl.text.isNotEmpty) {
                  setState(() => _skills.add(_skillCtrl.text.trim()));
                  _skillCtrl.clear();
                }
              }, child: const Icon(Icons.add_rounded)),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skills.map((s) => Chip(
              label: Text(s),
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
        ..._experiences.asMap().entries.map((e) => GlassCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(e.value.role, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(e.value.company),
            trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() => _experiences.removeAt(e.key))),
          ),
        )),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _addExperience(),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Experience'),
        ),
      ],
    );
  }

  void _addExperience() {
    setState(() => _experiences.add(Experience(company: 'Company Name', role: 'Job Role', duration: '1 Year')));
  }
}
