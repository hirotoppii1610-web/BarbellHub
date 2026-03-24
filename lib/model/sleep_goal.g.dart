// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SleepGoal _$SleepGoalFromJson(Map<String, dynamic> json) => SleepGoal(
  id: json['id'] as String?,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  hours: (json['hours'] as num).toDouble(),
);

Map<String, dynamic> _$SleepGoalToJson(SleepGoal instance) => <String, dynamic>{
  'id': instance.id,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'hours': instance.hours,
};
