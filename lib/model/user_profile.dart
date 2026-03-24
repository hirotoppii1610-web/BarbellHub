import 'package:uuid/uuid.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile{
   String id;
   String name;
   double? height;
   DateTime? birthDate;
   String? gender;
   String? activityLevel;

   UserProfile({
      String? id,
      this.name= 'New User',
      this.height,
      this.birthDate,
      this.gender,
      this.activityLevel,
   })  :  id = id ?? const Uuid().v4();

   //年齢計算の便利なgetter
   int? get age{
       if(birthDate==null) return null;
       final today = DateTime.now();
       int age = today.year - birthDate!.year;
       if(today.month < birthDate!.month || (today.month == birthDate!.month && today.day < birthDate!.day)){
         age--;
       }
       return age;
   }

   double get _activityMultiplier{
      switch(activityLevel){
         case 'ほぼ運動しない': return 1.5;
         case '週1-2回': return 1.625;
         case '週3-5回': return 1.75;
         case '週6-7回': return 1.875;
         case '毎日ハードに': return 2.0;
         default: return 1.5;
      }
   }

  
   UserProfile copyWith({
      String? id,
      String? name,
      double? height,
      DateTime? birthDate,
      String? gender,
      String? activityLevel,
   }){
      return UserProfile(
         id: id ?? this.id,
         name: name ?? this.name,
         height: height ?? this.height,
         birthDate: birthDate ?? this.birthDate,
         gender: gender ?? this.gender,
         activityLevel: activityLevel ?? this.activityLevel,
      );
   }

   double? calculateBMR(double weight){
      if(height == null || age==null || gender==null || weight <= 0) {return null;}
      if(gender=='男性' || gender=='その他'){
         return (0.1238 + (0.0481 * weight) + (0.0234 * height!) - (0.0138 * age!) - (0.5473 * 1))*(1000/4.186);
      }else if(gender=='女性'){
         return (0.1238 + (0.0481 * weight) + (0.0234 * height!) - (0.0138 * age!) - (0.5473 * 2))*(1000/4.186);
      }
      return null;
   }

   double? calculateTDEE(double weight){
      final bmr=calculateBMR(weight);
      if(bmr==null)return null;
      return bmr*_activityMultiplier;
   }

   @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, birthDate: $birthDate, height: $height, gender: $gender, activityLevel: $activityLevel)';
  }

   factory UserProfile.fromJson(Map<String,dynamic> json) => _$UserProfileFromJson(json);
   Map<String,dynamic> toJson()=> _$UserProfileToJson(this);
}