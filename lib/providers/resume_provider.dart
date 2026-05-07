import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/resume.dart';
import '../services/database_service.dart';

class ResumeProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
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
    _resumes = await _db.readAllResumes();
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

    await _db.createResume(resume);
    await _loadResumes();
  }

  Future<void> updateResume(Resume resume) async {
    await _db.updateResume(resume);
    await _loadResumes();
  }

  Future<void> deleteResume(String id) async {
    await _db.deleteResume(id);
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
