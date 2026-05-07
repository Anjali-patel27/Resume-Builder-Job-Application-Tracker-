import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/job_application.dart';

class ApplicationProvider extends ChangeNotifier {
  static const String _boxName = 'applications_v3';
  List<JobApplication> _applications = [];
  bool _isLoading = false;

  List<JobApplication> get allApplications => List.unmodifiable(_applications);
  bool get isLoading => _isLoading;

  List<JobApplication> get recentApplications {
    final sorted = _applications.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  int get totalApplications => _applications.length;

  Map<ApplicationStatus, int> get statusDistribution {
    final map = <ApplicationStatus, int>{};
    for (final s in ApplicationStatus.values) {
      map[s] = _applications.where((a) => a.status == s).length;
    }
    return map;
  }

  Future<void> init() async {
    await _loadApplications();
  }

  Future<void> _loadApplications() async {
    _isLoading = true;
    notifyListeners();
    final box = await Hive.openBox<JobApplication>(_boxName);
    _applications = box.values.toList();
    _isLoading = false;
    notifyListeners();
  }

  String _generateApplicationId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    final random = const Uuid().v4().split('-').first.toUpperCase();
    return 'APP-$timestamp-$random';
  }

  Future<JobApplication> addApplication({
    required String companyName,
    required String jobRole,
    required DateTime dateApplied,
    required String resumeId,
    required String resumeProfileName,
    String notes = '',
  }) async {
    final now = DateTime.now();
    final app = JobApplication(
      id: const Uuid().v4(),
      applicationId: _generateApplicationId(),
      companyName: companyName,
      jobRole: jobRole,
      dateApplied: dateApplied,
      resumeId: resumeId,
      resumeProfileName: resumeProfileName,
      statusIndex: 0,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    final box = await Hive.openBox<JobApplication>(_boxName);
    await box.put(app.id, app);
    await _loadApplications();
    return app;
  }

  Future<void> updateApplicationStatus(String id, ApplicationStatus newStatus) async {
    final app = _applications.firstWhere((a) => a.id == id);
    app.status = newStatus;
    app.updatedAt = DateTime.now();
    final box = await Hive.openBox<JobApplication>(_boxName);
    await box.put(app.id, app);
    await _loadApplications();
  }

  Future<void> updateApplication(JobApplication app) async {
    app.updatedAt = DateTime.now();
    final box = await Hive.openBox<JobApplication>(_boxName);
    await box.put(app.id, app);
    await _loadApplications();
  }

  Future<void> deleteApplication(String id) async {
    final box = await Hive.openBox<JobApplication>(_boxName);
    await box.delete(id);
    await _loadApplications();
  }

  List<JobApplication> searchAndFilter(String query, ApplicationStatus? status) {
    var list = _applications.toList();
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((a) => 
        a.companyName.toLowerCase().contains(q) || 
        a.jobRole.toLowerCase().contains(q)
      ).toList();
    }
    if (status != null) {
      list = list.where((a) => a.status == status).toList();
    }
    return list;
  }

  List<JobApplication> getApplicationsByResume(String resumeId) {
    return _applications.where((a) => a.resumeId == resumeId).toList();
  }
}
