import 'package:json_annotation/json_annotation.dart';
import '../model/cardio_log.dart';

part 'cardio_set.g.dart';

@JsonSerializable()
class CardioSet{
  String intensity;
  int? durationInMinutes;
  double? distanceInKm;
  int? steps;

  CardioSet({
    this.intensity='普通',  //新規作成時のデフォルト強度
    this.durationInMinutes,
    this.distanceInKm,
    this.steps,
  });

  double calculateCalories(CardioType type, double userWeight){
    if(userWeight<=0) return 0;
    final typeName=type.toString().split('.').last;
    final mets=CardioLog.metsTable[typeName]?[intensity] ?? 0.0;
    double durationHours=0;

    //優先順位１：時間が入力されている場合
    if(durationInMinutes != null && durationInMinutes! >0){
      durationHours=durationInMinutes! /60.0;
    }
    //優先順位２：距離しかない場合
    else if(distanceInKm != null && distanceInKm! >0){
      final speed=CardioLog.speedTable[typeName]?[intensity];
      if(speed !=null && speed>0){
        durationHours=distanceInKm! /speed;   //距離と、メッツから大まかな時速を割り出し、運動時間を概算
      }
    }
    print('[DEBUG] Set Calc: weight=$userWeight, mets=$mets, duration(h)=$durationHours, intensity=$intensity');
    if(mets==0.0 || durationHours==0) return 0;
    return mets * userWeight * durationHours * 1.05;
  }

  bool get isEmpty => durationInMinutes==null && distanceInKm==null && steps==null;

  CardioSet copyWith({
    String? intensity,
    int? durationInMinutes,
    double? distanceInKm,
    int? steps,
  }){
    return CardioSet(
      intensity: intensity ?? this.intensity,
      durationInMinutes: durationInMinutes ?? this.durationInMinutes,
      distanceInKm: distanceInKm ?? this.distanceInKm,
      steps: steps ?? this.steps,
    );
  }

  factory CardioSet.fromJson(Map<String,dynamic> json) => _$CardioSetFromJson(json);
  Map<String,dynamic> toJson()=> _$CardioSetToJson(this);
}