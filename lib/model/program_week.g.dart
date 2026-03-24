// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_week.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgramWeek _$ProgramWeekFromJson(Map<String, dynamic> json) => ProgramWeek(
  weekName: json['weekName'] as String,
  weeklyProgramDays: (json['weeklyProgramDays'] as List<dynamic>?)
      ?.map((e) => ProgramDay.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ProgramWeekToJson(ProgramWeek instance) =>
    <String, dynamic>{
      'weeklyProgramDays': instance.weeklyProgramDays
          .map((e) => e.toJson())
          .toList(),
      'weekName': instance.weekName,
    };
