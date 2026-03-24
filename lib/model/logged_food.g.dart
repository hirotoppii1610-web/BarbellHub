// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logged_food.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoggedFood _$LoggedFoodFromJson(Map<String, dynamic> json) => LoggedFood(
  foodItem: FoodItem.fromJson(json['foodItem'] as Map<String, dynamic>),
  percentage: (json['percentage'] as num).toDouble(),
);

Map<String, dynamic> _$LoggedFoodToJson(LoggedFood instance) =>
    <String, dynamic>{
      'foodItem': instance.foodItem,
      'percentage': instance.percentage,
    };
