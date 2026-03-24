import 'package:json_annotation/json_annotation.dart';
part 'sleep_log.g.dart';

@JsonSerializable()
class SleepLog {
  final DateTime date;
  final DateTime? goToBedTime;
  final DateTime sleepInTime;
  final DateTime wakeUpTime;
  final DateTime? getOutBedTime;

  SleepLog copyWith({
    DateTime? date,
    DateTime? goToBedTime,
    DateTime? sleepInTime,
    DateTime? wakeUpTime,
    DateTime? getOutBedTime
  }){
    return SleepLog(
      date: date?? this.date, 
      goToBedTime: goToBedTime ?? this.goToBedTime,
      sleepInTime: sleepInTime?? this.sleepInTime, 
      wakeUpTime: wakeUpTime?? this.wakeUpTime,
      getOutBedTime: getOutBedTime ?? this.getOutBedTime,
    );
  }

  SleepLog({
    required this.date,
    this.goToBedTime,
    required this.sleepInTime,
    required this.wakeUpTime,
    this.getOutBedTime,
  });

  int get sleepDurationInMimutes{
    return wakeUpTime.difference(sleepInTime).inMinutes;
    //睡眠時間の合計を分単位で返す
  }

  int? get inBedDurationInMinutes{
    if(goToBedTime == null || getOutBedTime ==null) return null;
    return getOutBedTime!.difference(goToBedTime!).inMinutes;
  }

  double? get sleepEfficiency{
    if(inBedDurationInMinutes==null || inBedDurationInMinutes! <=0 || sleepDurationInMimutes <= 0) return null;
    return (sleepDurationInMimutes/inBedDurationInMinutes!)*100;
  }

  String get sleepDurationAsString{
    final duration=wakeUpTime.difference(sleepInTime);
    final hours=duration.inHours;
    final minutes=duration.inMinutes%60;
    return '${hours}時間 ${minutes}分';
  }

  String? get inBedDurationAsString{
    if(goToBedTime == null || getOutBedTime ==null) return null;
    final duration=getOutBedTime!.difference(goToBedTime!);
    final hours=duration.inHours;
    final minutes=duration.inMinutes%60;
    return '${hours}時間 ${minutes}分';
  }

  bool get hasData => sleepDurationInMimutes>0;

  factory SleepLog.fromJson(Map<String,dynamic> json)=>
    _$SleepLogFromJson(json);
  Map<String,dynamic> toJson()=>_$SleepLogToJson(this);
}