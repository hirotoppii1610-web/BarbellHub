// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSet _$WorkoutSetFromJson(Map<String, dynamic> json) => WorkoutSet(
  weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
  reps: (json['reps'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$WorkoutSetToJson(WorkoutSet instance) =>
    <String, dynamic>{'weight': instance.weight, 'reps': instance.reps};
