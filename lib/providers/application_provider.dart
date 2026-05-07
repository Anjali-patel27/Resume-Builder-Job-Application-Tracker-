import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/job_application.dart';

class ApplicationProvider extends ChangeNotifier {
  static const String _boxName = 'applications';
  late Box<JobApplication> _box;
  List<JobApplication> _applications = [];
  bool _isLoading = false;

  // Search & filter state
  String _searchQuery = '';
  ApplicationStatus? _filterStatus;
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;

  List<JobApplication> get allApplications => List.unmodifiable(_applications);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  ApplicationStatus? get filterStatus => _filterStatus;

  List<JobApplication> get filteredApplications {
    var list = _applications.toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where(
            (a) =>
                a.companyName.toLowerCase().contains(q) ||
                a.jobRole.toLowerCase().contains(q),
          )
          .toList();
    }
    if (_filterStatus != null) {
      list = list.where((a) => a.status == _filterStatus).toList();
    }
    if (_filterDateFrom != null) {
      list = list
          .where((a) => a.dateApplied.isAfter(_filterDateFrom!))
          .toList();
    }
    if (_filterDateTo != null) {
      list = list
          .where((a) => a.dateApplied.isBefore(_filterDateTo!))
          .toList();
    }
    return list;
  }

  // Dashboard stats
  int get totalApplications => _applications.length;

  Map<ApplicationStatus, int> get statusDistribution {
    final map = <ApplicationStatus, int>{};
    for (final s in ApplicationStatus.values) {
      map[s] = _applications.where((a) => a.status == s).length;
    }
    return map;
  }

  List<JobApplication> get recentApplications {
    final sorted = _applications.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  Future<void> init() async {
    _box = await Hive.openBox<JobApplication>(_boxName);
    _loadApplications();
  }

  void _loadApplications() {
    _applications = _box.values.toList();
    _applications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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

    await _box.put(app.id, app);
    _loadApplications();
    return app;
  }

  Future<void> updateStatus(String id, ApplicationStatus newStatus) async {
    final app = _box.get(id);
    if (app != null) {
      app.status = newStatus;
      app.updatedAt = DateTime.now();
      await app.save();
      _loadApplications();
    }
  }

  Future<void> updateApplication(JobApplication app) async {
    app.updatedAt = DateTime.now();
    await _box.put(app.id, app);
    _loadApplications();
  }

  Future<void> deleteApplication(String id) async {
    await _box.delete(id);
    _loadApplications();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(ApplicationStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setDateRange(DateTime? from, DateTime? to) {
    _filterDateFrom = from;
    _filterDateTo = to;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterStatus = null;
    _filterDateFrom = null;
    _filterDateTo = null;
    notifyListeners();
  }

  List<JobApplication> getApplicationsByResume(String resumeId) {
    return _applications.where((a) => a.resumeId == resumeId).toList();
  }
}
