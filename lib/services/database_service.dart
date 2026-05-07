import 'package:hive_flutter/hive_flutter.dart';
import '../models/resume.dart';
import '../models/job_application.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  
  static const String _resumeBoxName = 'resumes_v2';
  static const String _appBoxName = 'applications_v2';
  
  late Box _resumeBox;
  late Box _appBox;

  DatabaseService._init();

  Future<void> init() async {
    await Hive.initFlutter();
    _resumeBox = await Hive.openBox(_resumeBoxName);
    _appBox = await Hive.openBox(_appBoxName);
  }

  // Resume CRUD
  Future<void> createResume(Resume resume) async {
    await _resumeBox.put(resume.id, resume.toMap());
  }

  Future<List<Resume>> readAllResumes() async {
    return _resumeBox.values.map((map) => Resume.fromMap(Map<String, dynamic>.from(map))).toList();
  }

  Future<void> updateResume(Resume resume) async {
    await _resumeBox.put(resume.id, resume.toMap());
  }

  Future<void> deleteResume(String id) async {
    await _resumeBox.delete(id);
  }

  // Job Application CRUD
  Future<void> createApplication(JobApplication app) async {
    await _appBox.put(app.id, app.toMap());
  }

  Future<List<JobApplication>> readAllApplications() async {
    return _appBox.values.map((map) => JobApplication.fromMap(Map<String, dynamic>.from(map))).toList();
  }

  Future<void> updateApplication(JobApplication app) async {
    await _appBox.put(app.id, app.toMap());
  }

  Future<void> deleteApplication(String id) async {
    await _appBox.delete(id);
  }
}
