import 'package:uuid/uuid.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_goal.g.dart';

enum WorkoutGoalType{
  exerciseCount,  //種目数
  totalVolume,  //トレーニングボリューム
  totalSets,  //セット数
}

@JsonSerializable()
class WorkoutGoal{
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final WorkoutGoalType goalType;
  final double value;

  WorkoutGoal({
    String? id,
    required this.startDate,
    this.endDate,
    required this.goalType,
    required this.value,
  })  :id=id ?? const Uuid().v4();

  WorkoutGoal copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    bool? isEndDateNull,
    WorkoutGoalType? goalType,
    double? value,
  }){
    return WorkoutGoal(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: isEndDateNull==true
          ? null
          : (endDate ?? this.endDate),
      goalType: goalType ?? this.goalType,
      value: value ?? this.value,
    );
  }

  factory WorkoutGoal.fromJson(Map<String,dynamic> json)=>_$WorkoutGoalFromJson(json);
  Map<String,dynamic> toJson()=>_$WorkoutGoalToJson(this);
}