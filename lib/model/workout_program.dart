import 'package:json_annotation/json_annotation.dart';
import '../model/program_week.dart';
import '../model/program_day.dart';

part 'workout_program.g.dart';

@JsonSerializable()
class WorkoutProgram {
  final String id;
  String programName;

  bool isWeekBased;
  final List<ProgramWeek> wholeProgram;
  final List<ProgramDay> days;

  WorkoutProgram({
    required this.id,
    required this.programName,
    this.isWeekBased = true,
    List<ProgramWeek>? wholeProgram,
    List<ProgramDay>? days,
  })  :wholeProgram = wholeProgram ?? [], //nullの場合にからのリストをセット
       days = days ?? [];   //nullの場合にからのリストをセット

  WorkoutProgram copyWith({
    String? id,
    String? programName,
    bool? isWeekBased,
    List<ProgramWeek>? wholeProgram,
    List<ProgramDay>? days,
  }){
    return WorkoutProgram(
      id: id ?? this.id, 
      programName: programName ?? this.programName,
      isWeekBased: isWeekBased ?? this.isWeekBased,
      wholeProgram: wholeProgram ?? this.wholeProgram.map((week)=>week.copyWith()).toList(),
      days: days ?? this.days.map((day)=>day.copyWith()).toList(),
    );
  }

  factory WorkoutProgram.fromJson(Map<String,dynamic> json)=>_$WorkoutProgramFromJson(json);
  Map<String,dynamic> toJson()=>_$WorkoutProgramToJson(this);
}