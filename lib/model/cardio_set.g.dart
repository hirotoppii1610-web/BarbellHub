// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cardio_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardioSet _$CardioSetFromJson(Map<String, dynamic> json) => CardioSet(
  intensity: json['intensity'] as String? ?? '普通',
  durationInMinutes: (json['durationInMinutes'] as num?)?.toInt(),
  distanceInKm: (json['distanceInKm'] as num?)?.toDouble(),
  steps: (json['steps'] as num?)?.toInt(),
);

Map<String, dynamic> _$CardioSetToJson(CardioSet instance) => <String, dynamic>{
  'intensity': instance.intensity,
  'durationInMinutes': instance.durationInMinutes,
  'distanceInKm': instance.distanceInKm,
  'steps': instance.steps,
};
