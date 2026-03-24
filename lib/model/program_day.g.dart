// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgramDay _$ProgramDayFromJson(Map<String, dynamic> json) => ProgramDay(
  id: json['id'] as String?,
  dayName: json['dayName'] as String,
  todayProgram: (json['todayProgram'] as List<dynamic>?)
      ?.map((e) => WorkoutLog.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ProgramDayToJson(ProgramDay instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dayName': instance.dayName,
      'todayProgram': instance.todayProgram.map((e) => e.toJson()).toList(),
    };
