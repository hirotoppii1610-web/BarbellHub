import 'package:muscle_one/model/logged_food.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_nutrition.g.dart';

@JsonSerializable()
class DailyNutrition {
  final DateTime day;
  final List<LoggedFood> todaysTotalLoggedFoods;

  DailyNutrition copyWith({
    DateTime? day,
    List<LoggedFood>? todaysTotalLoggedFoods,
  }){
    return DailyNutrition(
      day: day ?? this.day,
      todaysTotalLoggedFoods: todaysTotalLoggedFoods ?? this.todaysTotalLoggedFoods,
      );
  }

  DailyNutrition({required this.day, List<LoggedFood>? todaysTotalLoggedFoods})
    : todaysTotalLoggedFoods= todaysTotalLoggedFoods ?? [];


     //.foldは、リストの中の全要素の中で、何かの一つの合計値を算出する時に使う。
     //今回は、リストのindex→0から始めて、リストの要素を1個づつ足していく。

    double get totalCalories{                
      return todaysTotalLoggedFoods.fold(0, (sum, item){
        return sum + (item.foodItem.calories*(item.percentage/100.0));
      });
    }
        //ここのitem.foodItem.caloriesは、一日の食事全部が入ったリストの、
        //foodItem(LoggedFoodクラス内の表現で、final FoodItem　foodItem; と記述されている)
        //要は、食品情報をいれるFoodItemを、foodItemとして、
        //LoggedFoodに格納(商品と食べた割合を格納するクラス)

    double get totalProtein{
      return todaysTotalLoggedFoods.fold(0,(sum,item){
        return sum + (item.foodItem.protein*(item.percentage/100.0));
      });
    }

    double get totalFat{
      return todaysTotalLoggedFoods.fold(0,(sum,item){
        return sum + (item.foodItem.fat*(item.percentage/100.0));
      });
    }

    double get totalCarbs{
      return todaysTotalLoggedFoods.fold(0,(sum,item){
        return sum + (item.foodItem.carbs*(item.percentage/100.0));
      });
    }

    double get totalSugar{
      return todaysTotalLoggedFoods.fold(0,(sum,item){
        return sum + (item.foodItem.sugar*(item.percentage/100.0));
      });
    }

    double get totalFiber{
      return todaysTotalLoggedFoods.fold(0,(sum,item){
        return sum + (item.foodItem.fiber*(item.percentage/100.0));
      });
    }

  factory DailyNutrition.fromJson(Map<String,dynamic> json)
    => _$DailyNutritionFromJson(json);

  Map<String,dynamic> toJson()
    => _$DailyNutritionToJson(this);
}