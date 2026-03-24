import 'package:json_annotation/json_annotation.dart';

part 'body_weight_log.g.dart';

@JsonSerializable()
class BodyWeightLog {
  final DateTime date;
  final double bodyWeight;  //体重
  final double? bodyFatPercentage;  //体脂肪
  final double? muscleMass;   //筋肉量
  final double? visceralFatLevel;   //内臓脂肪レベル
  final double? basalMetabolicRate; //基礎代謝量
  final double? bodyWaterPercentage;  //体水分率
  final double? boneMass;   //推定骨量
  final double? bmi;    //BMI

  BodyWeightLog({
    required this.date,
    required this.bodyWeight,
    this.bodyFatPercentage,
    this.muscleMass,
    this.visceralFatLevel,
    this.basalMetabolicRate,
    this.bodyWaterPercentage,
    this.boneMass,
    this.bmi,
  });

  BodyWeightLog copyWith({
    DateTime? date,
    double? bodyWeight,
    double? bodyFatPercentage,
    double? muscleMass,
    double? visceralFatLevel,
    double? basalMetabolicRate,
    double? bodyWaterPercentage,
    double? boneMass,
    double? bmi,
  }){
    return BodyWeightLog(
      date: date ?? this.date,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      muscleMass: muscleMass ?? this.muscleMass,
      visceralFatLevel: visceralFatLevel ?? this.visceralFatLevel,
      basalMetabolicRate: basalMetabolicRate ?? this.basalMetabolicRate,
      bodyWaterPercentage: bodyWaterPercentage ?? this.bodyWaterPercentage,
      boneMass: boneMass ?? this.boneMass,
      bmi: bmi ?? this.bmi,
    );
  }

  factory BodyWeightLog.fromJson(Map<String,dynamic> json)=>_$BodyWeightLogFromJson(json);
  Map<String,dynamic> toJson()=>_$BodyWeightLogToJson(this);
}