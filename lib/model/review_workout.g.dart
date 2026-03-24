// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_workout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewWorkout _$ReviewWorkoutFromJson(Map<String, dynamic> json) =>
    ReviewWorkout(
      date: DateTime.parse(json['date'] as String),
      ListOftodayLog: (json['ListOftodayLog'] as List<dynamic>?)
          ?.map((e) => WorkoutLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      cardioLogs: (json['cardioLogs'] as List<dynamic>?)
          ?.map((e) => CardioLog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReviewWorkoutToJson(ReviewWorkout instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'ListOftodayLog': instance.ListOftodayLog.map((e) => e.toJson()).toList(),
      'cardioLogs': instance.cardioLogs.map((e) => e.toJson()).toList(),
    };
