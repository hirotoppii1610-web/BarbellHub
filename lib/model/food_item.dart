import 'package:json_annotation/json_annotation.dart';

part 'food_item.g.dart';

@JsonSerializable()
class FoodItem {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final double sugar;
  final double fiber;

  FoodItem({
    required this.id, 
    required this.name,
    this.calories=0,
    this.protein=0,
    this.fat=0,
    this.carbs=0,
    this.sugar=0,
    this.fiber=0
  });

  FoodItem copyWith({
    String? id,
    String? name,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
    double? sugar,
    double? fiber,
  }){
    return FoodItem(
      id: id ?? this.id, 
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      sugar: sugar ?? this.sugar,
      fiber: fiber ?? this.fiber,
    );
  }

  factory FoodItem.fromJson(Map<String,dynamic> json)
    => _$FoodItemFromJson(json);
  
  Map<String, dynamic> toJson()
    => _$FoodItemToJson(this);
}