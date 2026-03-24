import 'dart:convert';
import 'package:muscle_one/model/nutrition_goal.dart';
import 'package:muscle_one/model/workout_program.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/review_workout.dart';
import '../model/food_item.dart';
import '../model/daily_nutrition.dart';
import '../model/sleep_log.dart';
import '../model/body_weight_log.dart';
import '../model/history_log.dart';
import '../model/user_profile.dart';
import '../model/sleep_goal.dart';
import '../model/workout_goal.dart';

class DatabaseService {

  static const String _workoutsKey='workouts_Data';
  static const String _exerciseMenuKey='all_exercise_menu_data';
  static const String _workoutProgramKey='workout_program_data';
  static const String _myFoodsKey='my_foods_key';
  static const String _nutritionKey='all_daily_nutrition_data';
  static const String _nutritionGoalsKey='nutriton_goals_data';
  static const String _sleepLogKey='all_sleep_log_data';
  static const String _bodyWeightLogKey='all_body_weight_log_data';
  static const String _userProfileKey='user_profile_data';
  static const String _sleepGoalKey='sleep_goal_data';
  static const String _workoutGoalKey='workout_goal_data';
  static const String _showBackupDialogKey='dont_show_backup_dialog';


  //トレ記録の保存
  Future<void> saveWorkouts(List<ReviewWorkout> workouts) async{
    final prefs=await SharedPreferences.getInstance();

    // MapのListをJson形式にしておく
    final List<Map<String, dynamic>> workoutMaps=workouts.map((s)=>s.toJson()).toList();
    //それをJsonコードに変換00
    final String jsonString=jsonEncode(workoutMaps);
    print('トレ記録保存中:${jsonString}');
    await prefs.setString(_workoutsKey, jsonString);
    print('トレ記録の保存が完了したので、これから保存の確認をします。');
    final String? savedData=prefs.getString(_workoutsKey);
    print('保存されている内容:${savedData}');
  } 

  //トレ記録の読み込み
  Future<List<ReviewWorkout>> loadWorkouts() async{
    final prefs= await SharedPreferences.getInstance();

    //保存してあるJsonコードを読み込む
    final String? jsonString=prefs.getString(_workoutsKey);
    print('トレ記録を読み込み中:${jsonString}');

    //何もないときは空を返す
    if (jsonString ==null){
      return [];
    }

    //JsonコードをMapのListに戻す
    final List<dynamic> workoutMaps=jsonDecode(jsonString);
    return workoutMaps.map((map)=>ReviewWorkout.fromJson(map as Map<String,dynamic>)).toList();

  }

  //トレーニング種目の保存
  Future<void> saveExerciseMenu(Map<String,List<String>> menu) async{
    final prefs=await SharedPreferences.getInstance();
    //Map<String,List<String>> menuはそのままJsonにできないので、少し工夫をする
    final Map<String,dynamic> jsonMap=Map.from(menu);
    final String jsonString=jsonEncode(jsonMap);
    print('種目情報を保存しています:${jsonString}');
    await prefs.setString(_exerciseMenuKey, jsonString);
    print('保存が完了したので、これから保存の確認をします。');
    final String? savedData=prefs.getString(_exerciseMenuKey);
    print('保存されている内容:${savedData}');
  }

  Future<Map<String,List<String>>> loadExerciseMenu()async{
    final prefs=await SharedPreferences.getInstance();
    final String? jsonString=prefs.getString(_exerciseMenuKey);
    print('種目情報を読み込み中:${jsonString}');
    if (jsonString !=null){
      final Map<String,dynamic> jsonMap=jsonDecode(jsonString);
      final Map<String,List<String>> exerciseMenu=jsonMap.map(
        (key,value)=>MapEntry(key, List<String>.from(value))
      );
      return exerciseMenu;
    }
    return{};  //←もし何もないなら、空のMapを返す
  }

  
  //トレーニングプログラムの保存
  Future<void> saveWorkoutProgram(List<WorkoutProgram> program)async{
    final prefs=await SharedPreferences.getInstance();

    final List<Map<String,dynamic>> programMap=program.map((f)=>f.toJson()).toList();
    final String jsonString=jsonEncode(programMap);
    print('トレーニングプログラムを保存中:${jsonString}');
    await prefs.setString(_workoutProgramKey, jsonString);
    print('トレーニングプログラムの保存が完了したので、これから保存の確認をします。');
    final String? savedData=prefs.getString(_workoutProgramKey);
    print('保存されている内容:${savedData}');
  }

  Future<List<WorkoutProgram>> loadWorkoutProgram()async{
    final prefs=await SharedPreferences.getInstance();
    final String? jsonString=prefs.getString(_workoutProgramKey);
    print('トレーニングプログラムを読み込み中:${jsonString}');
    if (jsonString == null)return[];

    final List<dynamic> loadWorkoutProgramMap=jsonDecode(jsonString);
    return loadWorkoutProgramMap.map((map)=>WorkoutProgram.fromJson(map as Map<String,dynamic>)).toList();
  }



  //ユーザー登録の食品情報の保存
  Future<void> saveMyFoodsinfo(List<FoodItem> myFoods)async{
    final prefs=await SharedPreferences.getInstance();
    final List<Map<String,dynamic>> foodMaps=myFoods.map((f)=>f.toJson()).toList();
    final String jsonString=jsonEncode(foodMaps);
    print('食品情報を保存中:${jsonString}');
    await prefs.setString(_myFoodsKey, jsonString);
    print('myFoodsリストの保存が完了したので、これから保存の確認をします。');
    final String? savedData=prefs.getString(_myFoodsKey);
    print('保存されている内容:${savedData}');
  }

  Future<List<FoodItem>> loadmyFoodsItem()async{
    final prefs=await SharedPreferences.getInstance();
    final String? jsonString=prefs.getString(_myFoodsKey);
    print('食品情報を読み込み中:${jsonString}');
    if (jsonString == null)return[];
    final List<dynamic> foodMaps=jsonDecode(jsonString);
    return foodMaps.map((map)=>FoodItem.fromJson(map as Map<String,dynamic>)).toList();
  }


  //一日の食事情報の記録
  Future<void> saveDailynutrition(List<DailyNutrition> allDailyNutritionData) async{
    final prefs=await SharedPreferences.getInstance();
    final List<Map<String,dynamic>> nutritiondataMaps=
        allDailyNutritionData.map((a)=>a.toJson()).toList();
    final String jsonString=jsonEncode(nutritiondataMaps);
    print('食事記録を保存中:${jsonString}');
    await prefs.setString(_nutritionKey, jsonString);
    print('食事記録の保存が完了したので、これから保存の確認をします。');
    final String? savedData=prefs.getString(_nutritionKey);
    print('保存されている内容:${savedData}');
  }

  Future<List<DailyNutrition>> loadallnutritionData()async{
    final prefs=await SharedPreferences.getInstance();
    final String? jsonString=prefs.getString(_nutritionKey);
    print('食事記録を読み込み中:${jsonString}');
    if(jsonString == null)return [];
    final List<dynamic> loadallnutritionData=jsonDecode(jsonString);
    return loadallnutritionData.map((map)=>DailyNutrition.fromJson(map as Map<String,dynamic>)).toList();
  }

  //食事管理目標の保存
  Future<void> saveNutritionGoals(List<NutritionGoal> goals) async{
    final prefs= await SharedPreferences.getInstance();
    final List<Map<String,dynamic>> goalMaps=goals.map((g)=>g.toJson()).toList();
    final String jsonString=jsonEncode(goalMaps);
    await prefs.setString(_nutritionGoalsKey, jsonString);
    print('食事目標の保存が完了したので、これから保存の確認をします。');
    final String? savedData = prefs.getString(_nutritionGoalsKey);
    print('保存されたデータ: ${savedData}');
  }

  Future<List<NutritionGoal>> loadNutritionGoals() async{
    final prefs=await SharedPreferences.getInstance();
    final String? jsonString=prefs.getString(_nutritionGoalsKey);
    print('食事目標の情報を取得しています。');
    if(jsonString==null){
      return[];
    }
    final List<dynamic>goalMaps=jsonDecode(jsonString);
    return goalMaps.map((map)=>NutritionGoal.fromJson(map as Map<String,dynamic>)).toList();
  }

  //睡眠記録の保存
  Future<void> saveSleepLogs(List<SleepLog> logs) async{
    final prefs= await SharedPreferences.getInstance();
    final List<Map<String,dynamic>> sleeplogMaps=
    logs.map((log)=>log.toJson()).toList();
    final String jsonString=jsonEncode(sleeplogMaps);
    print('睡眠情報を取得しています:${jsonString}');
    await prefs.setString(_sleepLogKey, jsonString);
    print('睡眠記録が完了したので、これから保存の確認をします。');
    final String? savedData = prefs.getString(_sleepLogKey);
    print('保存されたデータ: ${savedData}');
  }

  Future<List<SleepLog>> loadSleepLogs() async{
    final prefs=await SharedPreferences.getInstance();
    final String? jsonString=prefs.getString(_sleepLogKey);
    print('睡眠情報を取得しています。');
    if(jsonString==null)return[];
    final List<dynamic>sleepLogmaps=jsonDecode(jsonString);
    return sleepLogmaps.map((map)=>SleepLog.fromJson(map as Map<String,dynamic>)).toList();
  }

  //体重記録の保存
  Future<void> saveBodyWeightLogs(List<BodyWeightLog> logs) async{
    final prefs= await SharedPreferences.getInstance();
    final List<Map<String,dynamic>> logMaps=
    logs.map((log)=>log.toJson()).toList();
    final String jsonString=jsonEncode(logMaps);
    print('体重情報を取得しています:${jsonString}');
    await prefs.setString(_bodyWeightLogKey, jsonString);
    print('体重記録が完了したので、これから保存の確認をします。');
    final String? savedData = prefs.getString(_bodyWeightLogKey);
    print('保存されたデータ: ${savedData}');
  }

  Future<List<BodyWeightLog>> loadBodyWeightLogs() async{
    final prefs=await SharedPreferences.getInstance();
    final String? jsonString=prefs.getString(_bodyWeightLogKey);
    print('体重情報を取得しています。');
    if(jsonString==null)return[];
    final List<dynamic>logmaps=jsonDecode(jsonString);
    return logmaps.map((map)=>BodyWeightLog.fromJson(map as Map<String,dynamic>)).toList();
  }

  Future<List<HistoryLog>> loadhistoryLogs()async{
    final allNutritionData=await loadallnutritionData();
    if (allNutritionData.isEmpty) return[];

    allNutritionData.sort((a,b)=>b.day.compareTo(a.day)); //日付の新しい順に並べ替え

    final allHistoryFoods=<HistoryLog>[];
    for(var dailyData in allNutritionData){
      for(var food in dailyData.todaysTotalLoggedFoods){
        allHistoryFoods.add(
          HistoryLog(foodLog:food, date:dailyData.day),
        );
      }                                   //この操作で並べ替えた食品履歴をリストにした。
    }
    final limitedLogs= allHistoryFoods.take(500).toList();    //最新500件に絞る
    final uniqueHistoryMap= <String, HistoryLog>{};
    for(var log in limitedLogs){
      uniqueHistoryMap.putIfAbsent(log.foodLog.foodItem.id, ()=>log);
    }                                                   //この操作で、重複をなくす。=>載っける。
    return uniqueHistoryMap.values.toList();
  }

  Future<void> saveUserProfile(UserProfile userProfile)async{
    final prefs=await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(userProfile.toJson());
    await prefs.setString(_userProfileKey, jsonString);
    print('ユーザープロフィールを保存しました');
  }

  Future<UserProfile?> loadUserProfile()async{
    final prefs=await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_userProfileKey);
    if(jsonString == null) return null;
    return UserProfile.fromJson(jsonDecode(jsonString));
  }

  Future<void> saveSleepGoals(List<SleepGoal> goals)async{
    final prefs= await SharedPreferences.getInstance();
    final List<Map<String,dynamic>> logMaps=
    goals.map((log)=>log.toJson()).toList();
    final String jsonString=jsonEncode(logMaps);
    print('睡眠目標を取得しています:${jsonString}');
    await prefs.setString(_sleepGoalKey, jsonString);
    print('睡眠目標の登録が完了したので、これから保存の確認をします。');
    final String? savedData = prefs.getString(_sleepGoalKey);
    print('保存されたデータ: ${savedData}');
  }

  Future<List<SleepGoal>> loadSleepGoals()async{
    final prefs=await SharedPreferences.getInstance();
    final String? jsonString=prefs.getString(_sleepGoalKey);
    print('睡眠目標を取得しています。');
    if(jsonString==null)return[];
    final List<dynamic>logmaps=jsonDecode(jsonString);
    return logmaps.map((map)=>SleepGoal.fromJson(map as Map<String,dynamic>)).toList();
  }

  Future<void> saveWorkoutGoals(List<WorkoutGoal> goals)async{
    final prefs= await SharedPreferences.getInstance();
    final List<Map<String,dynamic>> logMaps=
    goals.map((log)=>log.toJson()).toList();
    final String jsonString=jsonEncode(logMaps);
    print('トレーニング目標を取得しています:${jsonString}');
    await prefs.setString(_workoutGoalKey, jsonString);
    print('トレーニング目標の登録が完了したので、これから保存の確認をします。');
    final String? savedData = prefs.getString(_workoutGoalKey);
    print('保存されたデータ: ${savedData}');
  }

  Future<List<WorkoutGoal>> loadWorkoutGoals()async{
    final prefs=await SharedPreferences.getInstance();
    final String? jsonString=prefs.getString(_workoutGoalKey);
    print('体重情報を取得しています。');
    if(jsonString==null)return[];
    final List<dynamic>logmaps=jsonDecode(jsonString);
    return logmaps.map((map)=>WorkoutGoal.fromJson(map as Map<String,dynamic>)).toList();
  }

  Future<void> setDontShowBackupDialog(bool value)async{
    final prefs=await SharedPreferences.getInstance();
    await prefs.setBool(_showBackupDialogKey, value);
  }

  Future<bool> loadDontShowBackupDialog()async{
    final prefs=await SharedPreferences.getInstance();
    return prefs.getBool(_showBackupDialogKey) ?? false;
  }

  Future<String> exportAllDataToJson()async{
    final prefs=await SharedPreferences.getInstance();
    //全部のキーを呼び出して、全データを取得
    final allKeys=prefs.getKeys();
    final Map<String,dynamic> allData={};
    for(String key in allKeys){
      allData[key]=prefs.get(key);
    }
    //Jsonで返す
    return jsonEncode(allData);
  }

  Future<void> importAllDataFromJson(String jsonString)async{
    final prefs=await SharedPreferences.getInstance();
    //一旦前データ削除してからインポートデータを読み込む
    await prefs.clear();
    final Map<String, dynamic> allData=jsonDecode(jsonString);
    //全データを各キー値ごとに書き込む
    for(String key in allData.keys){
      final value=allData[key];
      if(value is bool){
        await prefs.setBool(key, value);
      }else if(value is int){
        await prefs.setInt(key, value);
      }else if(value is double){
        await prefs.setDouble(key, value);
      }else if(value is String){
        await prefs.setString(key, value);
      }
      // List<String>はSharedPreferencesの標準では扱えないため、
      // もし必要なら別途処理を追加しますが、現在のコードでは不要です。
    }
  }
}