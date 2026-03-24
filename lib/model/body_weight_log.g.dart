// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_weight_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BodyWeightLog _$BodyWeightLogFromJson(Map<String, dynamic> json) =>
    BodyWeightLog(
      date: DateTime.parse(json['date'] as String),
      bodyWeight: (json['bodyWeight'] as num).toDouble(),
      bodyFatPercentage: (json['bodyFatPercentage'] as num?)?.toDouble(),
      muscleMass: (json['muscleMass'] as num?)?.toDouble(),
      visceralFatLevel: (json['visceralFatLevel'] as num?)?.toDouble(),
      basalMetabolicRate: (json['basalMetabolicRate'] as num?)?.toDouble(),
      bodyWaterPercentage: (json['bodyWaterPercentage'] as num?)?.toDouble(),
      boneMass: (json['boneMass'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BodyWeightLogToJson(BodyWeightLog instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'bodyWeight': instance.bodyWeight,
      'bodyFatPercentage': instance.bodyFatPercentage,
      'muscleMass': instance.muscleMass,
      'visceralFatLevel': instance.visceralFatLevel,
      'basalMetabolicRate': instance.basalMetabolicRate,
      'bodyWaterPercentage': instance.bodyWaterPercentage,
      'boneMass': instance.boneMass,
      'bmi': instance.bmi,
    };
