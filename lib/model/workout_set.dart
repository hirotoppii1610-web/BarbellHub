import 'package:json_annotation/json_annotation.dart';

part 'workout_set.g.dart';

@JsonSerializable()
class WorkoutSet{
  double weight;
  int reps;
  WorkoutSet({this.weight=0.0, this.reps=0});

  bool get isEmpty => weight==0 && reps==0;

  WorkoutSet copyWith({
    double? weight,
    int? reps,
  }){
    return WorkoutSet(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
    );
  }

  double get estimate1RM{
    if(reps==0 || weight==0){
      return 0;
    }
    return weight * (1 + (0.025 * reps));
  }

  factory WorkoutSet.fromJson(Map<String,dynamic> json) => _$WorkoutSetFromJson(json);
  Map<String,dynamic> toJson() => _$WorkoutSetToJson(this);
}