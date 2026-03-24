import 'workout_log.dart';
import 'cardio_log.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_workout.g.dart';

@JsonSerializable(explicitToJson: true)
class ReviewWorkout {
  //1日ごとのトレをメモ
  final DateTime date;
  final List<WorkoutLog> ListOftodayLog;
  final List<CardioLog> cardioLogs;

  ReviewWorkout({
    required this.date,
    List<WorkoutLog>? ListOftodayLog,
    List<CardioLog>? cardioLogs,
  })  : ListOftodayLog = ListOftodayLog ?? [],
        cardioLogs = cardioLogs ?? [];

  double get totalVolume{
    if(ListOftodayLog.isEmpty){
      return 0;
    }
    return ListOftodayLog.fold(0, (previousValue, log) => previousValue+log.totalVolume);
  }

  double get totalSets{
    if(ListOftodayLog.isEmpty){
      return 0;
    }
    return ListOftodayLog.fold(0, (previousValue, log) => previousValue+log.set.length);
  }

  //追加部分
  ReviewWorkout copyWith({
    DateTime? date,
    List<WorkoutLog>? ListOftodayLog,
    List<CardioLog>? cardioLogs,
  }) {
    return ReviewWorkout(
      date: date ?? this.date,
      ListOftodayLog: ListOftodayLog ?? this.ListOftodayLog,
      cardioLogs: cardioLogs ?? this.cardioLogs,
    );
  }

  factory ReviewWorkout.fromJson(Map<String,dynamic> json) => _$ReviewWorkoutFromJson(json);
  Map<String,dynamic> toJson() => _$ReviewWorkoutToJson(this);
}