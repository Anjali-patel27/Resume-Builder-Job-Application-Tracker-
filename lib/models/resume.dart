import 'package:hive/hive.dart';

part 'resume.g.dart';

@HiveType(typeId: 0)
class Resume extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String profileName;

  @HiveField(2)
  String fullName;

  @HiveField(3)
  String email;

  @HiveField(4)
  String phone;

  @HiveField(5)
  String address;

  @HiveField(6)
  String objective;

  @HiveField(7)
  List<Education> education;

  @HiveField(8)
  List<String> skills;

  @HiveField(9)
  List<Experience> experiences;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime updatedAt;

  Resume({
    required this.id,
    required this.profileName,
    required this.fullName,
    required this.email,
    required this.phone,
    this.address = '',
    this.objective = '',
    required this.education,
    required this.skills,
    required this.experiences,
    required this.createdAt,
    required this.updatedAt,
  });
}

@HiveType(typeId: 1)
class Education extends HiveObject {
  @HiveField(0)
  String degree;

  @HiveField(1)
  String institution;

  @HiveField(2)
  String year;

  @HiveField(3)
  String grade;

  Education({
    required this.degree,
    required this.institution,
    required this.year,
    this.grade = '',
  });
}

@HiveType(typeId: 2)
class Experience extends HiveObject {
  @HiveField(0)
  String company;

  @HiveField(1)
  String role;

  @HiveField(2)
  String duration;

  @HiveField(3)
  String description;

  Experience({
    required this.company,
    required this.role,
    required this.duration,
    this.description = '',
  });
}
