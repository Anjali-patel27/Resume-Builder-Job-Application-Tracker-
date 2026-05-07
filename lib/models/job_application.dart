enum ApplicationStatus {
  applied,
  shortlisted,
  interviewScheduled,
  rejected,
  selected,
}

class JobApplication {
  String id;
  String applicationId;
  String companyName;
  String jobRole;
  DateTime dateApplied;
  String resumeId;
  String resumeProfileName;
  int statusIndex;
  String notes;
  DateTime createdAt;
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

  factory JobApplication.fromMap(Map<String, dynamic> map) {
    return JobApplication(
      id: map['id'],
      applicationId: map['applicationId'] ?? '',
      companyName: map['companyName'] ?? '',
      jobRole: map['jobRole'] ?? '',
      dateApplied: DateTime.parse(map['dateApplied']),
      resumeId: map['resumeId'] ?? '',
      resumeProfileName: map['resumeProfileName'] ?? '',
      statusIndex: map['statusIndex'] ?? 0,
      notes: map['notes'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
