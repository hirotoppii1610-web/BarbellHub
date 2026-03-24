// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_program.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutProgram _$WorkoutProgramFromJson(Map<String, dynamic> json) =>
    WorkoutProgram(
      id: json['id'] as String,
      programName: json['programName'] as String,
      isWeekBased: json['isWeekBased'] as bool? ?? true,
      wholeProgram: (json['wholeProgram'] as List<dynamic>?)
          ?.map((e) => ProgramWeek.fromJson(e as Map<String, dynamic>))
          .toList(),
      days: (json['days'] as List<dynamic>?)
          ?.map((e) => ProgramDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WorkoutProgramToJson(WorkoutProgram instance) =>
    <String, dynamic>{
      'id': instance.id,
      'programName': instance.programName,
      'isWeekBased': instance.isWeekBased,
      'wholeProgram': instance.wholeProgram,
      'days': instance.days,
    };
