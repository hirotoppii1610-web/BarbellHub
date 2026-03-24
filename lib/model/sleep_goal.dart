import 'package:uuid/uuid.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sleep_goal.g.dart';

@JsonSerializable()
class SleepGoal{
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final double hours;

  SleepGoal({
    String? id,
    required this.startDate,
    this.endDate,
    required this.hours,
  })  : id=id ?? const Uuid().v4();

  SleepGoal copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    bool? isEndDateNull,
    double? hours,
  }){
    return SleepGoal(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: isEndDateNull==true
          ? null
          : (endDate ?? this.endDate),
      hours: hours ?? this.hours,
    );
  }

  factory SleepGoal.fromJson(Map<String,dynamic> json)=> _$SleepGoalFromJson(json);
  Map<String,dynamic> toJson()=> _$SleepGoalToJson(this);
}