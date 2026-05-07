import 'package:hive/hive.dart';

part 'job_application.g.dart';

@HiveType(typeId: 3)
enum ApplicationStatus {
  @HiveField(0)
  applied,
  @HiveField(1)
  shortlisted,
  @HiveField(2)
  interviewScheduled,
  @HiveField(3)
  rejected,
  @HiveField(4)
  selected,
}

@HiveType(typeId: 4)
class JobApplication {
  @HiveField(0)
  String id;
  @HiveField(1)
  String applicationId;
  @HiveField(2)
  String companyName;
  @HiveField(3)
  String jobRole;
  @HiveField(4)
  DateTime dateApplied;
  @HiveField(5)
  String resumeId;
  @HiveField(6)
  String resumeProfileName;
  @HiveField(7)
  int statusIndex;
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
    required this.statusIndex,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  ApplicationStatus get status => ApplicationStatus.values[statusIndex];
  set status(ApplicationStatus value) => statusIndex = value.index;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'applicationId': applicationId,
      'companyName': companyName,
      'jobRole': jobRole,
      'dateApplied': dateApplied.toIso8601String(),
      'resumeId': resumeId,
      'resumeProfileName': resumeProfileName,
      'statusIndex': statusIndex,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
