// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  id: json['id'] as String?,
  name: json['name'] as String? ?? 'New User',
  height: (json['height'] as num?)?.toDouble(),
  birthDate: json['birthDate'] == null
      ? null
      : DateTime.parse(json['birthDate'] as String),
  gender: json['gender'] as String?,
  activityLevel: json['activityLevel'] as String?,
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'height': instance.height,
      'birthDate': instance.birthDate?.toIso8601String(),
      'gender': instance.gender,
      'activityLevel': instance.activityLevel,
    };
