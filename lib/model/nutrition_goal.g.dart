// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutritionGoal _$NutritionGoalFromJson(Map<String, dynamic> json) =>
    NutritionGoal(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      sugar: (json['sugar'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
    );

Map<String, dynamic> _$NutritionGoalToJson(NutritionGoal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'calories': instance.calories,
      'protein': instance.protein,
      'fat': instance.fat,
      'carbs': instance.carbs,
      'sugar': instance.sugar,
      'fiber': instance.fiber,
    };
