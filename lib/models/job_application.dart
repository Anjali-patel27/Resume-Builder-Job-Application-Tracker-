import 'package:hive/hive.dart';

part 'job_application.g.dart';

enum ApplicationStatus {
  applied,
  shortlisted,
  interviewScheduled,
  rejected,
  selected,
}

@HiveType(typeId: 3)
class JobApplication extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String applicationId; // unique generated ID

  @HiveField(2)
  String companyName;

  @HiveField(3)
  String jobRole;

  @HiveField(4)
  DateTime dateApplied;

  @HiveField(5)
  String resumeId; // linked resume

  @HiveField(6)
  String resumeProfileName;

  @HiveField(7)
  int statusIndex; // maps to ApplicationStatus enum

  @HiveField(8)
  String notes;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  JobApplication({
    required this.id,
    required this.applicationId,
    required this.companyName,
    required this.jobRole,
    required this.dateApplied,
    required this.resumeId,
    required this.resumeProfileName,
    this.statusIndex = 0,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  ApplicationStatus get status => ApplicationStatus.values[statusIndex];

  set status(ApplicationStatus s) => statusIndex = s.index;

  String get statusLabel {
    switch (status) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.interviewScheduled:
        return 'Interview Scheduled';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.selected:
        return 'Selected';
    }
  }
}
