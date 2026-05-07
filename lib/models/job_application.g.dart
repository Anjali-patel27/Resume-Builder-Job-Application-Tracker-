// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_application.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JobApplicationAdapter extends TypeAdapter<JobApplication> {
  @override
  final int typeId = 4;

  @override
  JobApplication read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JobApplication(
      id: fields[0] as String,
      applicationId: fields[1] as String,
      companyName: fields[2] as String,
      jobRole: fields[3] as String,
      dateApplied: fields[4] as DateTime,
      resumeId: fields[5] as String,
      resumeProfileName: fields[6] as String,
      statusIndex: fields[7] as int,
      notes: fields[8] as String,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, JobApplication obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.applicationId)
      ..writeByte(2)
      ..write(obj.companyName)
      ..writeByte(3)
      ..write(obj.jobRole)
      ..writeByte(4)
      ..write(obj.dateApplied)
      ..writeByte(5)
      ..write(obj.resumeId)
      ..writeByte(6)
      ..write(obj.resumeProfileName)
      ..writeByte(7)
      ..write(obj.statusIndex)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobApplicationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ApplicationStatusAdapter extends TypeAdapter<ApplicationStatus> {
  @override
  final int typeId = 3;

  @override
  ApplicationStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ApplicationStatus.applied;
      case 1:
        return ApplicationStatus.shortlisted;
      case 2:
        return ApplicationStatus.interviewScheduled;
      case 3:
        return ApplicationStatus.rejected;
      case 4:
        return ApplicationStatus.selected;
      default:
        return ApplicationStatus.applied;
    }
  }

  @override
  void write(BinaryWriter writer, ApplicationStatus obj) {
    switch (obj) {
      case ApplicationStatus.applied:
        writer.writeByte(0);
        break;
      case ApplicationStatus.shortlisted:
        writer.writeByte(1);
        break;
      case ApplicationStatus.interviewScheduled:
        writer.writeByte(2);
        break;
      case ApplicationStatus.rejected:
        writer.writeByte(3);
        break;
      case ApplicationStatus.selected:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicationStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
