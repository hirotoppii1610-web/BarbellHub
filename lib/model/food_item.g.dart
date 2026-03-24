// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodItem _$FoodItemFromJson(Map<String, dynamic> json) => FoodItem(
  id: json['id'] as String,
  name: json['name'] as String,
  calories: (json['calories'] as num?)?.toDouble() ?? 0,
  protein: (json['protein'] as num?)?.toDouble() ?? 0,
  fat: (json['fat'] as num?)?.toDouble() ?? 0,
  carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
  sugar: (json['sugar'] as num?)?.toDouble() ?? 0,
  fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$FoodItemToJson(FoodItem instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'calories': instance.calories,
  'protein': instance.protein,
  'fat': instance.fat,
  'carbs': instance.carbs,
  'sugar': instance.sugar,
  'fiber': instance.fiber,
};
