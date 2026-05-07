import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/resume.dart';

class ResumeProvider extends ChangeNotifier {
  static const String _boxName = 'resumes';
  late Box<Resume> _box;
  List<Resume> _resumes = [];
  bool _isLoading = false;

  List<Resume> get resumes => List.unmodifiable(_resumes);
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _box = await Hive.openBox<Resume>(_boxName);
    _loadResumes();
  }

  void _loadResumes() {
    _resumes = _box.values.toList();
    _resumes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();
  }

  Future<Resume> createResume({
    required String profileName,
    required String fullName,
    required String email,
    required String phone,
    String address = '',
    String objective = '',
    List<Education>? education,
    List<String>? skills,
    List<Experience>? experiences,
  }) async {
    // Check for duplicate profile name
    final exists = _resumes.any(
      (r) => r.profileName.toLowerCase() == profileName.toLowerCase(),
    );
    if (exists) {
      throw Exception('A resume with this profile name already exists.');
    }

    final now = DateTime.now();
    final resume = Resume(
      id: const Uuid().v4(),
      profileName: profileName,
      fullName: fullName,
      email: email,
      phone: phone,
      address: address,
      objective: objective,
      education: education ?? [],
      skills: skills ?? [],
      experiences: experiences ?? [],
      createdAt: now,
      updatedAt: now,
    );

    await _box.put(resume.id, resume);
    _loadResumes();
    return resume;
  }

  Future<void> updateResume(Resume resume) async {
    resume.updatedAt = DateTime.now();
    await _box.put(resume.id, resume);
    _loadResumes();
  }

  Future<void> deleteResume(String id) async {
    await _box.delete(id);
    _loadResumes();
  }

  Resume? getResumeById(String id) {
    try {
      return _resumes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Resume> searchResumes(String query) {
    if (query.isEmpty) return _resumes;
    final q = query.toLowerCase();
    return _resumes
        .where(
          (r) =>
              r.profileName.toLowerCase().contains(q) ||
              r.fullName.toLowerCase().contains(q),
        )
        .toList();
  }
}
