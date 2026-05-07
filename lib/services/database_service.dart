import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/resume.dart';
import '../models/job_application.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('resume_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE resumes (
        id $idType,
        profileName $textType,
        fullName $textType,
        email $textType,
        phone $textType,
        address $textType,
        objective $textType,
        education $textType,
        skills $textType,
        experiences $textType,
        createdAt $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE applications (
        id $idType,
        applicationId $textType,
        companyName $textType,
        jobRole $textType,
        dateApplied $textType,
        resumeId $textType,
        resumeProfileName $textType,
        statusIndex $intType,
        notes $textType,
        createdAt $textType,
        updatedAt $textType
      )
    ''');
  }

  // Resume CRUD
  Future<void> createResume(Resume resume) async {
    final db = await instance.database;
    await db.insert('resumes', resume.toMap());
  }

  Future<List<Resume>> readAllResumes() async {
    final db = await instance.database;
    final result = await db.query('resumes', orderBy: 'createdAt DESC');
    return result.map((json) => Resume.fromMap(json)).toList();
  }

  Future<void> updateResume(Resume resume) async {
    final db = await instance.database;
    await db.update(
      'resumes',
      resume.toMap(),
      where: 'id = ?',
      whereArgs: [resume.id],
    );
  }

  Future<void> deleteResume(String id) async {
    final db = await instance.database;
    await db.delete(
      'resumes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Job Application CRUD
  Future<void> createApplication(JobApplication app) async {
    final db = await instance.database;
    await db.insert('applications', app.toMap());
  }

  Future<List<JobApplication>> readAllApplications() async {
    final db = await instance.database;
    final result = await db.query('applications', orderBy: 'createdAt DESC');
    return result.map((json) => JobApplication.fromMap(json)).toList();
  }

  Future<void> updateApplication(JobApplication app) async {
    final db = await instance.database;
    await db.update(
      'applications',
      app.toMap(),
      where: 'id = ?',
      whereArgs: [app.id],
    );
  }

  Future<void> deleteApplication(String id) async {
    final db = await instance.database;
    await db.delete(
      'applications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
