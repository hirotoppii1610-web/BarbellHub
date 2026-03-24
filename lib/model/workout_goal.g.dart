// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutGoal _$WorkoutGoalFromJson(Map<String, dynamic> json) => WorkoutGoal(
  id: json['id'] as String?,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  goalType: $enumDecode(_$WorkoutGoalTypeEnumMap, json['goalType']),
  value: (json['value'] as num).toDouble(),
);

Map<String, dynamic> _$WorkoutGoalToJson(WorkoutGoal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'goalType': _$WorkoutGoalTypeEnumMap[instance.goalType]!,
      'value': instance.value,
    };

const _$WorkoutGoalTypeEnumMap = {
  WorkoutGoalType.exerciseCount: 'exerciseCount',
  WorkoutGoalType.totalVolume: 'totalVolume',
  WorkoutGoalType.totalSets: 'totalSets',
};
