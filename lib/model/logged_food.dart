import 'package:muscle_one/model/food_item.dart';
import 'package:json_annotation/json_annotation.dart';

part 'logged_food.g.dart';

@JsonSerializable()
class LoggedFood {
  final FoodItem foodItem;
  final double percentage;

  LoggedFood({required this.foodItem, required this.percentage});

  LoggedFood copyWith({
    FoodItem? foodItem,
    double? percentage,
  }){
    return LoggedFood(
      foodItem: foodItem ?? this.foodItem,
      percentage: percentage ?? this.percentage,
    );
  }

  factory LoggedFood.fromJson(Map<String,dynamic> json)
    => _$LoggedFoodFromJson(json);

  Map<String,dynamic> toJson()
    => _$LoggedFoodToJson(this);
}