// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SleepLog _$SleepLogFromJson(Map<String, dynamic> json) => SleepLog(
  date: DateTime.parse(json['date'] as String),
  goToBedTime: json['goToBedTime'] == null
      ? null
      : DateTime.parse(json['goToBedTime'] as String),
  sleepInTime: DateTime.parse(json['sleepInTime'] as String),
  wakeUpTime: DateTime.parse(json['wakeUpTime'] as String),
  getOutBedTime: json['getOutBedTime'] == null
      ? null
      : DateTime.parse(json['getOutBedTime'] as String),
);

Map<String, dynamic> _$SleepLogToJson(SleepLog instance) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'goToBedTime': instance.goToBedTime?.toIso8601String(),
  'sleepInTime': instance.sleepInTime.toIso8601String(),
  'wakeUpTime': instance.wakeUpTime.toIso8601String(),
  'getOutBedTime': instance.getOutBedTime?.toIso8601String(),
};
