import 'package:json_annotation/json_annotation.dart';
import '../model/program_day.dart';

part 'program_week.g.dart';

@JsonSerializable(explicitToJson: true)
class ProgramWeek {
  final List<ProgramDay> weeklyProgramDays;
  final String weekName;

  ProgramWeek({required this.weekName,List<ProgramDay>? weeklyProgramDays})
      : weeklyProgramDays= weeklyProgramDays??[];

  ProgramWeek copyWith({
    String? weekName,
    List<ProgramDay>? weeklyProgramDays,
  }){
    return ProgramWeek(
      weekName: weekName ?? this.weekName,
      weeklyProgramDays: weeklyProgramDays ?? this.weeklyProgramDays.map((day)=>day.copyWith()).toList(),
    );
  }

  factory ProgramWeek.fromJson(Map<String,dynamic> json)=> _$ProgramWeekFromJson(json);
  Map<String,dynamic> toJson()=>_$ProgramWeekToJson(this);
}