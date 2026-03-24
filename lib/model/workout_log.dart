import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'workout_set.dart';

part 'workout_log.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkoutLog {
  final String id;
  final String exerciseName;
  List<WorkoutSet> set;
  final DateTime createdAt;
  final String? memo;

  WorkoutLog({
    String? id,
    required this.exerciseName, 
    List<WorkoutSet>? set,
    DateTime? createdAt,
    this.memo,
  })  : id = id ?? const Uuid().v4(),
        set= set ?? [WorkoutSet(), WorkoutSet(), WorkoutSet()],
        createdAt = createdAt ?? DateTime.now();

  WorkoutLog copyWith({
    String? id,
    String? exerciseName,
    List<WorkoutSet>? set,
    DateTime? createdAt,
    String? memo,
  }){
    return WorkoutLog(
      id: id ?? this.id,
      exerciseName: exerciseName ?? this.exerciseName,
      set: set ?? this.set.map((s)=>s.copyWith()).toList(),
      createdAt: createdAt ?? this.createdAt,
      memo: memo ?? this.memo,
    );
  }

  bool get isEmpty => set.every((s)=>s.isEmpty);

  double get totalVolume{
    if (set.isEmpty){
      return 0;
    }
    //各セットの重量と回数の積の総和
    return set.fold(0, (previousValue, set) => previousValue+(set.weight*set.reps));
  }

  factory WorkoutLog.fromJson(Map<String,dynamic> json)=> _$WorkoutLogFromJson(json);
  Map<String,dynamic> toJson() => _$WorkoutLogToJson(this);
}