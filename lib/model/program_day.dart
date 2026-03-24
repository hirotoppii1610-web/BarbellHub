import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import '../model/workout_log.dart';

part 'program_day.g.dart';

@JsonSerializable(explicitToJson: true)
class ProgramDay {
  final String id;
  String dayName;
  List<WorkoutLog> todayProgram;

  ProgramDay({String? id, required this.dayName, List<WorkoutLog>? todayProgram})
      : id = id ?? const Uuid().v4(),
        todayProgram = todayProgram ?? [];

  ProgramDay copyWith({
    String? id,
    String? dayName,
    List<WorkoutLog>? todayProgram,
  }){
    return ProgramDay(
      id: id?? this.id,
      dayName: dayName?? this.dayName, 
      todayProgram: todayProgram?? this.todayProgram.map((log)=>log.copyWith()).toList(),
    );
  }

  factory ProgramDay.fromJson(Map<String,dynamic> json)=>_$ProgramDayFromJson(json);
  Map<String,dynamic> toJson()=> _$ProgramDayToJson(this);
}