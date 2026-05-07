import 'package:hive/hive.dart';

part 'resume.g.dart';

@HiveType(typeId: 0)
class Education {
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

  Map<String, dynamic> toMap() {
    return {
      'degree': degree,
      'institution': institution,
      'year': year,
      'grade': grade,
    };
  }

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      degree: map['degree'] ?? '',
      institution: map['institution'] ?? '',
      year: map['year'] ?? '',
      grade: map['grade'] ?? '',
    );
  }
}

@HiveType(typeId: 1)
class Experience {
  @HiveField(0)
  String role;
  @HiveField(1)
  String company;
  @HiveField(2)
  String duration;
  @HiveField(3)
  String description;

  Experience({
    required this.role,
    required this.company,
    required this.duration,
    this.description = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'company': company,
      'duration': duration,
      'description': description,
    };
  }

  factory Experience.fromMap(Map<String, dynamic> map) {
    return Experience(
      role: map['role'] ?? '',
      company: map['company'] ?? '',
      duration: map['duration'] ?? '',
      description: map['description'] ?? '',
    );
  }
}

@HiveType(typeId: 2)
class Resume {
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

  Resume({
    required this.id,
    required this.profileName,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.objective,
    required this.education,
    required this.skills,
    required this.experiences,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileName': profileName,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'objective': objective,
      'education': education.map((e) => e.toMap()).toList(),
      'skills': skills,
      'experiences': experiences.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
