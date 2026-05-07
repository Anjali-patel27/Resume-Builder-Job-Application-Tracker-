import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/resume.dart';

class ResumeProvider extends ChangeNotifier {
  static const String _boxName = 'resumes_v3';
  List<Resume> _resumes = [];
  bool _isLoading = false;

  List<Resume> get resumes => List.unmodifiable(_resumes);
  bool get isLoading => _isLoading;

  Future<void> init() async {
    await _loadResumes();
  }

  Future<void> _loadResumes() async {
    _isLoading = true;
    notifyListeners();
    final box = await Hive.openBox<Resume>(_boxName);
    _resumes = box.values.toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createResume({
    required String profileName,
    required String fullName,
    required String email,
    required String phone,
    required String address,
    required String objective,
    required List<Education> education,
    required List<String> skills,
    required List<Experience> experiences,
  }) async {
    final resume = Resume(
      id: const Uuid().v4(),
      profileName: profileName,
      fullName: fullName,
      email: email,
      phone: phone,
      address: address,
      objective: objective,
      education: education,
      skills: skills,
      experiences: experiences,
      createdAt: DateTime.now(),
    );

    final box = await Hive.openBox<Resume>(_boxName);
    await box.put(resume.id, resume);
    await _loadResumes();
  }

  Future<void> updateResume(Resume resume) async {
    final box = await Hive.openBox<Resume>(_boxName);
    await box.put(resume.id, resume);
    await _loadResumes();
  }

  Future<void> deleteResume(String id) async {
    final box = await Hive.openBox<Resume>(_boxName);
    await box.delete(id);
    await _loadResumes();
  }

  Resume? getResumeById(String id) {
    try {
      return _resumes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
