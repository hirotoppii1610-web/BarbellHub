import 'package:json_annotation/json_annotation.dart';

part 'nutrition_goal.g.dart';

@JsonSerializable()
class NutritionGoal {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final double sugar;
  final double fiber;

  NutritionGoal({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.sugar,
    required this.fiber,
  });

  NutritionGoal copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    bool? isEndDateNull,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
    double? sugar,
    double? fiber,
  }){
    return NutritionGoal(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: isEndDateNull==true
          ? null
          :(endDate ?? this.endDate),
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      sugar: sugar ?? this.sugar,
      fiber: fiber ?? this.fiber,
    );
  }

  factory NutritionGoal.fromJson(Map<String,dynamic> json) =>_$NutritionGoalFromJson(json);
  Map<String,dynamic> toJson()=> _$NutritionGoalToJson(this);

}