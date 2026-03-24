// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cardio_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardioLog _$CardioLogFromJson(Map<String, dynamic> json) => CardioLog(
  id: json['id'] as String?,
  type: $enumDecode(_$CardioTypeEnumMap, json['type']),
  sets: (json['sets'] as List<dynamic>?)
      ?.map((e) => CardioSet.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  memo: json['memo'] as String?,
);

Map<String, dynamic> _$CardioLogToJson(CardioLog instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$CardioTypeEnumMap[instance.type]!,
  'sets': instance.sets,
  'createdAt': instance.createdAt.toIso8601String(),
  'memo': instance.memo,
};

const _$CardioTypeEnumMap = {
  CardioType.walking: 'walking',
  CardioType.running: 'running',
  CardioType.cycling: 'cycling',
  CardioType.swimming: 'swimming',
};
