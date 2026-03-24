// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutLog _$WorkoutLogFromJson(Map<String, dynamic> json) => WorkoutLog(
  id: json['id'] as String?,
  exerciseName: json['exerciseName'] as String,
  set: (json['set'] as List<dynamic>?)
      ?.map((e) => WorkoutSet.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  memo: json['memo'] as String?,
);

Map<String, dynamic> _$WorkoutLogToJson(WorkoutLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseName': instance.exerciseName,
      'set': instance.set.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt.toIso8601String(),
      'memo': instance.memo,
    };
