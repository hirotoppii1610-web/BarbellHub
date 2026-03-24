import 'package:uuid/uuid.dart';
import '../model/cardio_set.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cardio_log.g.dart';

enum CardioType{
  walking,
  running,
  cycling,
  swimming,
}

@JsonSerializable()
class CardioLog{
  final String id;
  final CardioType type;
  final List<CardioSet> sets;
  final DateTime createdAt;
  final String? memo;

  CardioLog({
    String? id,
    required this.type,
    List<CardioSet>? sets,
    DateTime? createdAt,
    this.memo,
  })  : id = id ?? const Uuid().v4(),
        sets = sets ?? [CardioSet()],
        createdAt = createdAt ?? DateTime.now();

  static const Map<String,Map<String,double>> metsTable={
    'walking':{'ゆっくり':2.8, '普通':3.8, '速歩き':4.8}, //済み
    'running':{'ジョギング':6.5, '普通':10.5, '高強度':11.8}, //済み
    'cycling':{'ゆっくり':3.3, '普通':6.5, '高強度':10.0}, //済み
    'swimming':{'ゆっくり':5.8, '普通':8.0, '高強度':10.5}, //済み
  };

  static const Map<String,Map<String,double>> speedTable={
    'walking':{'ゆっくり':3.5, '普通':5.0, '速歩き':6.0}, 
    'running':{'ジョギング':6.6, '普通':10.9, '高強度':12.2}, 
    'cycling':{'ゆっくり':11.1, '普通':18.3, '高強度':24.0}, 
    'swimming':{'ゆっくり':2.0, '普通':2.7, '高強度':3.6}, 
  };      //単位はどれもkm/h

  double totalCaloriesBurned(double userWeight){
    if(userWeight<=0) return 0;
    return sets.fold(0.0, (sum,set)=> sum+set.calculateCalories(type, userWeight));
  }

  int get totalDurationInMinutes{
    return sets.fold(0, (sum,set) => sum+(set.durationInMinutes ?? 0));
  }

  double get totalDistanceInKm{
    return sets.fold(0.0, (sum,set)=> sum+(set.distanceInKm ?? 0.0));
  }

  CardioLog copyWith({
    String? id,
    CardioType? type,
    List<CardioSet>? sets,
    DateTime? createdAt,
    String? memo,
  }){
    return CardioLog(
      id: id ?? this.id,
      type: type ?? this.type,
      sets: sets ?? this.sets,
      createdAt: createdAt ?? this.createdAt,
      memo: memo ?? this.memo,
    );
  }

  factory CardioLog.fromJson(Map<String, dynamic> json) => _$CardioLogFromJson(json);
  Map<String,dynamic> toJson() => _$CardioLogToJson(this);
}