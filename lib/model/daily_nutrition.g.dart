// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_nutrition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyNutrition _$DailyNutritionFromJson(Map<String, dynamic> json) =>
    DailyNutrition(
      day: DateTime.parse(json['day'] as String),
      todaysTotalLoggedFoods: (json['todaysTotalLoggedFoods'] as List<dynamic>?)
          ?.map((e) => LoggedFood.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DailyNutritionToJson(DailyNutrition instance) =>
    <String, dynamic>{
      'day': instance.day.toIso8601String(),
      'todaysTotalLoggedFoods': instance.todaysTotalLoggedFoods,
    };
