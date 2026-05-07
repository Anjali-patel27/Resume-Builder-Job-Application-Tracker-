import 'dart:convert';

class Education {
  String degree;
  String institution;
  String year;
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

class Experience {
  String role;
  String company;
  String duration;
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

class Resume {
  String id;
  String profileName;
  String fullName;
  String email;
  String phone;
  String address;
  String objective;
  List<Education> education;
  List<String> skills;
  List<Experience> experiences;
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
      'education': jsonEncode(education.map((e) => e.toMap()).toList()),
      'skills': jsonEncode(skills),
      'experiences': jsonEncode(experiences.map((e) => e.toMap()).toList()),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Resume.fromMap(Map<String, dynamic> map) {
    return Resume(
      id: map['id'],
      profileName: map['profileName'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      objective: map['objective'] ?? '',
      education: (jsonDecode(map['education'] ?? '[]') as List)
          .map((e) => Education.fromMap(e))
          .toList(),
      skills: List<String>.from(jsonDecode(map['skills'] ?? '[]')),
      experiences: (jsonDecode(map['experiences'] ?? '[]') as List)
          .map((e) => Experience.fromMap(e))
          .toList(),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
