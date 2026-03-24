import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:googleapis/metastore/v1.dart';
import 'package:muscle_one/screens/analysis_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../database/database_service.dart';
import '../model/review_workout.dart';
import '../model/daily_nutrition.dart';
import '../model/sleep_log.dart';
import '../model/body_weight_log.dart';
import '../model/nutrition_goal.dart';
import '../model/food_item.dart';
import '../model/history_log.dart';
import '../model/workout_program.dart';
import '../model/user_profile.dart';
import '../model/sleep_goal.dart';
import '../model/workout_goal.dart';
import '../data/exercise_data.dart';
import '../services/google_auth_service.dart';
import 'home_screen.dart';
import 'dashboard_screen.dart';
import 'daily_log_screen.dart';
import 'daily_nutrition_screen.dart';
import 'sleep_log_screen.dart';
import 'body_weight_log_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget{
  const MainScreen({super.key});

  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>{

  final DatabaseService _dbService=DatabaseService(); 
  List<ReviewWorkout> _allWorkouts=[];  //すべての日のトレを記録するリスト
  List<DailyNutrition> _allDailyNutrition=[];
  List<SleepLog> _allSleepLogs=[];
  List<BodyWeightLog> _allBodyWeightLogs=[];
  List<NutritionGoal> _allNutritionGoals=[];
  List<FoodItem> _allMyFoods=[];
  List<HistoryLog> _historyList=[];
  List<WorkoutProgram> _allPrograms=[];
  Map<String,List<String>> _allExerciseMenu={};
  UserProfile _userProfile= UserProfile();      //プロフィールを管理する状態管理変数
  List<SleepGoal> _allSleepGoals=[];
  List<WorkoutGoal> _allWorkoutGoals=[];

  int _selectIndex=0;  //現在選択されている画面のインデクスを一旦定義。

  final GoogleAuthService _googleAuthService=GoogleAuthService();
  GoogleSignInAccount? _googleUser;


  bool isSameDay(DateTime a, DateTime b){
    return a.year==b.year && a.month==b.month && a.day==b.day;
  }


  void _onItemTapped(int index){
    setState(() {
      _selectIndex=index;
    });
  }

  @override
  void initState(){           //画面が表示されたときに今日の日付を選択
    super.initState();
    _loadAllData();
    _handleInitioalSignIn().then((_){
      _performAutoBackupIfNeeded();
    });
  }

  void _loadAllData() async{
    _allWorkouts=await _dbService.loadWorkouts();
    _allDailyNutrition=await _dbService.loadallnutritionData();
    _allSleepLogs=await _dbService.loadSleepLogs();
    _allBodyWeightLogs=await _dbService.loadBodyWeightLogs();
    _allNutritionGoals=await _dbService.loadNutritionGoals();
    _allMyFoods=await _dbService.loadmyFoodsItem();
    _historyList=await _dbService.loadhistoryLogs();
    _allPrograms=await _dbService.loadWorkoutProgram();
    //1.デフォルトメニュー
    final Map<String, List<String>> defaultMenu=
        defaultExerciseMenu.map((key,value)=>MapEntry(key, List<String>.from(value)));
    //2.マイメニュー
    final Map<String, List<String>> savedMenu = await _dbService.loadExerciseMenu();
    //3.統合する
    savedMenu.forEach((part,exercises){
      if(defaultMenu.containsKey(part)){
        for(var exercise in exercises){
          if(!defaultMenu[part]!.contains(exercise)){
            defaultMenu[part]!.add(exercise);
          }
        }
      }else{
        defaultMenu[part]=exercises;
      }
    });
    _allExerciseMenu=defaultMenu;
    
    _allSleepGoals=await _dbService.loadSleepGoals();
    _allWorkoutGoals=await _dbService.loadWorkoutGoals();
    final loadedProfile=await _dbService.loadUserProfile();
    if(loadedProfile != null){
      _userProfile=loadedProfile;
    }

    if(mounted){
      setState((){});
    }
  }

  Future<void> _handleInitioalSignIn()async{
    await _googleAuthService.signInSilently();
    if(mounted){
      setState(() {
        _googleUser=_googleAuthService.currentUser;
      });
    }
  }

  //コールバック関数=>子スクリーンが呼び出す保存、読み込み、等の関数
  void _onWorkoutUpdated(ReviewWorkout updatedWorkouts) {
    setState((){
      final index=_allWorkouts.indexWhere((w)=>isSameDay(w.date, updatedWorkouts.date));
      if(index!=-1){
        _allWorkouts[index]=updatedWorkouts;
      }else{
        _allWorkouts.add(updatedWorkouts);
      }
    });
    _dbService.saveWorkouts(_allWorkouts);
    print('main_screenでトレ記録が保存されました。');
  }

  void _onNutritionUpdated(DailyNutrition updatedNutrition) {
    _dbService.loadhistoryLogs().then((newHistory){
      if(mounted){
        setState((){
           _historyList=newHistory;
          final index=_allDailyNutrition.indexWhere((d)=> isSameDay(d.day, updatedNutrition.day));
          if(index!=-1){
            _allDailyNutrition[index]=updatedNutrition;
          }else{
            _allDailyNutrition.add(updatedNutrition);
          }
        });
      }
    });
    _dbService.saveDailynutrition(_allDailyNutrition);
    print('main_screenで食事記録が保存されました。');
  }

  Future<List<HistoryLog>> _reloadHistory()async{
    final newHistory=await _dbService.loadhistoryLogs();
    if(mounted){
      setState((){
        _historyList=newHistory;
      });
    }
    return newHistory;
  }

  void _onSleepUpdated(SleepLog updatedSleepLogs) {
    setState((){
      final index=_allSleepLogs.indexWhere((l)=>isSameDay(l.date, updatedSleepLogs.date));
      if(index!=-1){
        _allSleepLogs[index]=updatedSleepLogs;
      }else{
        _allSleepLogs.add(updatedSleepLogs);
      }
    });
    _dbService.saveSleepLogs(_allSleepLogs);
    print('main_screenで睡眠記録が保存されました。');
  }

  void _onMyFoodsUpdated(List<FoodItem> updatedMyFoods){
    print('【5】MainScreenがデータ更新を受け取りました ');
    setState((){
      _allMyFoods=updatedMyFoods;
    });
    _dbService.saveMyFoodsinfo(updatedMyFoods);
    print('main_screenでユーザー登録の食品情報が保存されました。');
  }

  void _onNutritionGoalsUpdated(List<NutritionGoal> updatedNutritionGoals){
    print('栄養目標の更新を検知しました。');
    setState((){
      _allNutritionGoals=updatedNutritionGoals;
    });
    _dbService.saveNutritionGoals(updatedNutritionGoals);
    print('main_screenで栄養目標が保存されました。');
  }

  void _onProgramsUpdated(List<WorkoutProgram> updatedPrograms){
    setState((){
      _allPrograms=updatedPrograms;
    });
    _dbService.saveWorkoutProgram(updatedPrograms);
  }

  void _onExerciseMenuUpdated(Map<String,List<String>> updatedExerciseMenu){
    setState((){
      _allExerciseMenu=updatedExerciseMenu;
    });
    _dbService.saveExerciseMenu(updatedExerciseMenu);
  }

  void _onBodyWeightLogUpdated(BodyWeightLog updatedBodyWeightLog){
    setState((){
      final index=_allBodyWeightLogs.indexWhere((l)=>isSameDay(l.date, updatedBodyWeightLog.date));
      if(index!=-1){
        _allBodyWeightLogs[index]=updatedBodyWeightLog;
      }else{
        _allBodyWeightLogs.add(updatedBodyWeightLog);
      }
      _allBodyWeightLogs.sort((a,b)=>b.date.compareTo(a.date));   //日付順に並べ替え
    });
    _dbService.saveBodyWeightLogs(_allBodyWeightLogs);
    print('main_screenで体重記録が更新されました。');
  }

  void _onProfileUpdated(UserProfile newProfile){
    setState((){
      _userProfile=newProfile;
      print("✅ 2. [MainScreen] 通知を受信。Stateを更新しました。\n$_userProfile");
    });
    _dbService.saveUserProfile(newProfile);
  }

  void _onSleepGoalsUpdated(List<SleepGoal> updatedSleepGoals){
    setState((){
      _allSleepGoals=updatedSleepGoals;
    });
    _dbService.saveSleepGoals(updatedSleepGoals);
    print('main_screenで睡眠目標が保存されました。');
  }

  void _onWorkoutGoalsUpdated(List<WorkoutGoal> updatedWorkoutGoals){
    setState((){
      _allWorkoutGoals=updatedWorkoutGoals;
    });
    _dbService.saveWorkoutGoals(updatedWorkoutGoals);
    print('main_screenで栄養目標が保存されました。');
  }

  void _showAddDialog(){
    showGeneralDialog(
      context:context,
      barrierDismissible:true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor:Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds:200),
      //pageBuilderでダイヤログの中身を定義
      pageBuilder:(context, animation, secondaryAnimation){
        return Stack(
          alignment:Alignment.bottomCenter,
          children:[
            Padding(
              padding: EdgeInsetsGeometry.only(bottom: 90), 
              child:Material(
                type:MaterialType.transparency,
                child:SimpleDialog(
                  backgroundColor:Color(0xFF1e3a5f).withOpacity(0.5),
                  shape:RoundedRectangleBorder(
                    borderRadius:BorderRadius.circular(16),
                  ),
                  title:const Center(child:Text('今日の記録を追加',style:TextStyle(color:Colors.white)),),
                  children:[
                    _buildDialogOption('トレーニング', Icons.fitness_center, Colors.orange.withOpacity(0.9), ()=>_navigateToDailyLogForToday()),
                    _buildDialogOption('食事', Icons.restaurant, Colors.green.withOpacity(0.9), ()=>_navigateToNutritionForToday()),
                    _buildDialogOption('睡眠', Icons.bedtime, Colors.blueAccent.withOpacity(0.9), ()=>_navigateToSleepForToday()),
                    _buildDialogOption('体重', Icons.monitor_weight, Colors.teal.withOpacity(0.9), ()=>_navigateToBodyWeightForToday()),
                  ],
                )
              )
            ),
          ],
        );
      },
      transitionBuilder:(context, animation, secondaryAnimation, child){
        return SlideTransition(
          position:Tween<Offset>(
            begin:const Offset(0,1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child:child,
        );
      }
    );
  }

  Widget _buildDialogOption(String title, IconData icon, Color color, VoidCallback onTap){
    return SimpleDialogOption(
      onPressed:onTap,
      child: Row(
        children:[
          Icon(icon, color:color),
          const SizedBox(width:16),
          Text(title, style:const TextStyle(color:Colors.white, fontSize:16,)),
        ],
      ),
    );
  }

  void _navigateToDailyLogForToday()async{
    Navigator.pop(context);
    final today=DateTime.now();
    final logForToday=_allWorkouts.firstWhere((w)=>isSameDay(w.date, today), orElse:()=>ReviewWorkout(date:today));
    final ReviewWorkout? returnedWorkout= await Navigator.push(
      context,
      MaterialPageRoute(
        builder:(context)=>DailyLogScreen(
          logData:logForToday, 
          allBodyWeightLogs: _allBodyWeightLogs,
          allWorkoutHistory: _allWorkouts,
          allPrograms:_allPrograms,
          exerciseMenu:_allExerciseMenu,
          onProgramsUpdated:_onProgramsUpdated,
          onWorkoutUpdated:_onWorkoutUpdated,
          onExerciseMenuUpdated:_onExerciseMenuUpdated,
        ),
      ),
    );
    if (returnedWorkout!=null){                                  //変更点があればそれだけを変更して更新、変更がなければそのまま全部をnewListに定義し直していく
      _onWorkoutUpdated(returnedWorkout);       //これでメイン画面に報告して、おしまい！
    }
  }

  void _navigateToNutritionForToday()async{
    Navigator.pop(context);
    final today=DateTime.now();
    final nutritionForDay=_allDailyNutrition.firstWhere((n)=>isSameDay(n.day, today), orElse:()=> DailyNutrition(day:today));
    final DailyNutrition? returnedNutrition= await Navigator.push(
      context,
      MaterialPageRoute(
        builder:(context)=>DailyNutritionScreen(
          nutritiondata:nutritionForDay,
          allMyFoods:_allMyFoods,
          allNutritionGoals:_allNutritionGoals,
          onNutritionUpdated:_onNutritionUpdated,
          onHistoryReloadRequested:_reloadHistory,
          onMyFoodsUpdated:_onMyFoodsUpdated,
          onNutritionGoalsUpdated:_onNutritionGoalsUpdated,
          historyList:_historyList,
        ),
      ),
    );
    if(returnedNutrition!=null) _onNutritionUpdated(returnedNutrition);
  }

  void _navigateToSleepForToday()async{
    Navigator.pop(context);
    final today=DateTime.now();
    final sleepLogForDay=_allSleepLogs.firstWhere((s)=>isSameDay(s.date, today), orElse:()=>SleepLog(date:today, sleepInTime:today, wakeUpTime:today));
    SleepLog? returnedSleepLog=await Navigator.push(
      context,
      MaterialPageRoute(
        builder:(context)=>SleepLogScreen(
          sleepLogData: sleepLogForDay,
          onSleepUpdated:_onSleepUpdated,
        ),
      ),
    );
    if(returnedSleepLog!=null) _onSleepUpdated(returnedSleepLog);
  }

  List<BodyWeightLog> _getWeeklyWeightLogs(DateTime date){
    final endDate=DateTime(date.year, date.month, date.day);
    final startDate=endDate.subtract(const Duration(days:6));

    return _allBodyWeightLogs.where((log){
      final logDate=DateTime(log.date.year, log.date.month, log.date.day);
      //startdate<=logDate<=endDateの範囲で抽出
      return !logDate.isBefore(startDate) && !logDate.isAfter(endDate);
    }).toList();
  }

  void _navigateToBodyWeightForToday()async{
    Navigator.pop(context);
    final today=DateTime.now();
    final bodyWeightLogForDay=_allBodyWeightLogs.firstWhere((log)=>isSameDay(log.date, today), orElse:()=>BodyWeightLog(date:today, bodyWeight:0));
    final weeklyWeightLog=_getWeeklyWeightLogs(today);
    BodyWeightLog? returnedBodyWeightLog= await Navigator.push(
      context,
      MaterialPageRoute(
        builder:(context)=>BodyWeightLogScreen(
          bodyWeightLogData:bodyWeightLogForDay,
          onBodyWeightLogUpdated:_onBodyWeightLogUpdated,
          userProfile:_userProfile,
          weeklyWeightLog:weeklyWeightLog,
        ),
      ),
    );
  }

  Future<void> _handleBackupTapRequest()async{
    //Googleアカウントのログインをチェック
    bool isSignIn=_googleUser != null;
      //ログインしていないならログイン処理を呼び出す
      if(!isSignIn){
        isSignIn=await _googleAuthService.signIn();
      }
      //ログイン済みならバックアップを行う
      if(isSignIn){
        //ここはメイン画面から持ってくることにする。
        final bool dontShowAgain= await _dbService.loadDontShowBackupDialog();

        if(dontShowAgain){
          //今後表示しない=>諸々も処理をスキップしてバックアップ
          print('確認をスキップしてバックアップ処理を開始');
          performBackUp();
        }else{
          //今後表示しないわけではない=>確認ダイヤログを表示
          final backupConfirmed=await showDialog<bool>(
            context: context, 
            builder: (context){
              bool checkBoxValue=false;
              return StatefulBuilder(builder: (context, setDialogState){
                return AlertDialog(
                  backgroundColor: const Color(0xff1e3a5f),
                  title: Row(
                    children: [
                      Center(
                        child: const Text('バックアップの確認', style: TextStyle(color: Colors.white),),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: ()=>Navigator.pop(context,false), 
                        icon: const Icon(Icons.close, color: Colors.white70,)
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('記録されたデータをGoogle Driveに保存します。よろしいですか？', style: TextStyle(color: Colors.white70),),
                      const SizedBox(height: 16,),
                      CheckboxListTile(
                        value: checkBoxValue, 
                        onChanged: (bool? value){
                          setDialogState((){
                            checkBoxValue = value ?? false;
                          });
                        },
                        title:const Text('今後この確認を表示しない', style: TextStyle(color:Colors.white70),),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: Colors.blueAccent.withOpacity(0.7),
                        checkColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: ()async{
                        //チェックボックスがオンなら、その設定を保存
                        if(checkBoxValue){
                          await _dbService.setDontShowBackupDialog(true);
                        }
                        Navigator.pop(context,true);
                      }, 
                      child: const Text('実行', style: TextStyle(color: Colors.white70),)
                    ),
                  ],
                );
              });
            }
          );
          if(backupConfirmed==true){
            print('バックアップ処理開始');
            performBackUp(showSuccessMessage: true);
          };
        }
      }
  }

  Future<void> performBackUp({bool showSuccessMessage=true})async{
    print('main_screenでバックアップを実行します。');
    try{
      final String backupToJson=await _dbService.exportAllDataToJson();
      print('バックアップ用のJsonコードが生成されました。');
      await _googleAuthService.uploadBackup(backupToJson);

      final now = DateTime.now();
      final dateStr = "${now.year}/${now.month}/${now.day} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";
      print('バックアップ完了時刻: $dateStr'); // ログに出力

      //ユーザーに成功を通知
      if(mounted && showSuccessMessage){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('バックアップが完了しました。')),

        );
        print('バックアップ完了時刻: $dateStr');
      }
    }catch(e,s){
      print('バックアップに失敗しました。エラー: $e'); // エラー内容を出力
      print('スタックトレース: $s'); // より詳細な情報を出力
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('バックアップに失敗しました。')),
        );
      }
    }
  }

  Future<void> performRestore()async{
    print('main_screenにて、バックアップを読み込みます。');
    try{
      //GoogleAPIからダウンロード
      final Map<String,dynamic>? result = await _googleAuthService.downloadBackup();

      if(result!=null && result.isNotEmpty){
        final String backupJson=result['jsonData'];
        final DateTime? backupTime=result['timestamp'];
        await _dbService.importAllDataFromJson(backupJson);
        _loadAllData();
        if(mounted){
          String message='データの復元が完了しました。';
          if(backupTime!=null){
            final dateStr="${backupTime.toLocal().year}/{${backupTime.toLocal().month}/${backupTime.toLocal().day} ${backupTime.toLocal().hour}:${backupTime.toLocal().minute.toString().padLeft(2, '0')}";
            message='$dateStr のデータを復元しました';
            print(message);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('データの復元が完了しました。')),
          );
        }else{
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('復元できるデータが見つかりませんでした。')),
            );
          }
        }
      }
    }catch(e){
      print('バックアップ取得に失敗しました。');
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('データの復元に失敗しました。')),
        );
      }
    }
  }

  Future<void> _performAutoBackupIfNeeded()async{
    //ログイン情報を確認
    if(_googleUser==null){
      print('自動バックアップ:ログインしていないためスキップします。');
      return;
    }
    try{
      final prefs=await SharedPreferences.getInstance();
      //最後のバックアップの日時を取得
      final lastBackupMillis=prefs.getInt('last_auto_backup_timestamp') ?? 0;
      final lastBackupDate=DateTime.fromMillisecondsSinceEpoch(lastBackupMillis);
      if(DateTime.now().difference(lastBackupDate).inHours >= 24){
        print('最終バックアップから24時間経過、バックアップを作成します。');
        await performBackUp(showSuccessMessage: false);
        await prefs.setInt('last_auto_backup_timestamp', DateTime.now().millisecondsSinceEpoch);
        print('自動バックアップを行い時刻を記録しました。');
      }else{
        print('自動バックアップは前回のバックアップから24時間経過していないためスキップします。');
      }
    }catch(e){
      print('自動バックアップエラーが発生しました。: $e');
    }
  }

  @override
  Widget build(BuildContext context){
    Widget currentScreen;
    switch(_selectIndex){
      case 0:
        currentScreen=DashboardScreen(
          allWorkouts: _allWorkouts,
          allDailyNutrition: _allDailyNutrition,
          allSleepLogs: _allSleepLogs,
          allMyFoods:_allMyFoods,
          allBodyWeightLogs:_allBodyWeightLogs,
          allNutritionGoals:_allNutritionGoals,
          allWorkoutGoals:_allWorkoutGoals,
          allSleepGoals:_allSleepGoals,
          allPrograms:_allPrograms,
          historyList:_historyList,
          exerciseMenu:_allExerciseMenu,
          userProfile:_userProfile,
          onWorkoutUpdated: _onWorkoutUpdated,
          onNutritionUpdated:_onNutritionUpdated,
          onHistoryReloadRequested:_reloadHistory,
          onSleepUpdated: _onSleepUpdated,
          onBodyWeightLogUpdated:_onBodyWeightLogUpdated,
          onNutritionGoalsUpdated: _onNutritionGoalsUpdated,
          onSleepGoalsUpdated:_onSleepGoalsUpdated,
          onWorkoutGoalsUpdated:_onWorkoutGoalsUpdated,
          onMyFoodsUpdated:_onMyFoodsUpdated,
          onProgramsUpdated:_onProgramsUpdated,
          onExerciseMenuUpdated:_onExerciseMenuUpdated,
        );
        break;
      case 1:
        currentScreen=HomeScreen(
          allWorkouts: _allWorkouts,
          allDailyNutrition:_allDailyNutrition,
          allSleepLogs: _allSleepLogs,
          allMyFoods:_allMyFoods,
          allNutritionGoals:_allNutritionGoals,
          allPrograms:_allPrograms,
          allBodyWeightLogs:_allBodyWeightLogs,
          historyList:_historyList,
          exerciseMenu:_allExerciseMenu,
          userProfile:_userProfile,
          onWorkoutUpdated: _onWorkoutUpdated,
          onNutritionUpdated: _onNutritionUpdated,
          onHistoryReloadRequested:_reloadHistory,
          onSleepUpdated: _onSleepUpdated,  
          onMyFoodsUpdated:_onMyFoodsUpdated,
          onNutritionGoalsUpdated:_onNutritionGoalsUpdated,
          onProgramsUpdated:_onProgramsUpdated,
          onExerciseMenuUpdated:_onExerciseMenuUpdated,
          onBodyWeightLogUpdated:_onBodyWeightLogUpdated
          //こうやってコールバック関数を渡した事で、他の画面でも保存ができるようになる。
        );
        break;
      case 2:
        currentScreen=Container();
        break;

      case 3:
        currentScreen=AnalysisScreen(
          allWorkouts:_allWorkouts,
          exerciseMenu:_allExerciseMenu,
          allDailyNutrition:_allDailyNutrition,
          allBodyWeightLogs:_allBodyWeightLogs,
          allSleepLogs:_allSleepLogs,
          userProfile:_userProfile,
        );
        break;

      case 4:
        currentScreen=ProfileScreen(
          allNutritionGoals:_allNutritionGoals,
          allPrograms:_allPrograms,
          exerciseMenu:_allExerciseMenu,
          onNutritionGoalsUpdated:_onNutritionGoalsUpdated,
          onProgramsUpdated:_onProgramsUpdated,
          onExerciseMenuUpdated:_onExerciseMenuUpdated,
          userProfile: _userProfile,
          onProfileUpdated: _onProfileUpdated,
          allWorkoutGoals:_allWorkoutGoals,
          allSleepGoals:_allSleepGoals,
          onSleepGoalsUpdated:_onSleepGoalsUpdated,
          onWorkoutGoalsUpdated:_onWorkoutGoalsUpdated,
          onBackupRequested: _handleBackupTapRequest,
          googleUser:_googleUser,
          onSignIn:()async{
            try{
              await _googleAuthService.signIn();
              if(mounted){
                setState(() {
                  _googleUser = _googleAuthService.currentUser;
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ログインしました。')));
              }
            }catch(e){
              print('ログインに失敗しました。');
              if(mounted){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ログインに失敗しました。再度お試しください。')));
              }
            }
          },
          onSignOut:()async{
            try{
              await _googleAuthService.signOut();
              if(mounted){
                setState(() {
                  _googleUser = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ログアウトしました。')));
              }
            }catch(e){
              print('ログアウトに失敗しました。');
              if(mounted){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ログアウトに失敗しました。再度お試しください。')));
              }
            }
          },
        );
        break;
      
      default:
        currentScreen=DashboardScreen(
          allWorkouts: _allWorkouts,
          allDailyNutrition: _allDailyNutrition,
          allSleepLogs: _allSleepLogs,
          allMyFoods:_allMyFoods,
          allBodyWeightLogs:_allBodyWeightLogs,
          allNutritionGoals:_allNutritionGoals,
          allWorkoutGoals:_allWorkoutGoals,
          allSleepGoals:_allSleepGoals,
          allPrograms:_allPrograms,
          historyList:_historyList,
          exerciseMenu:_allExerciseMenu,
          userProfile:_userProfile,
          onWorkoutUpdated: _onWorkoutUpdated,
          onNutritionUpdated:_onNutritionUpdated,
          onHistoryReloadRequested:_reloadHistory,
          onSleepUpdated: _onSleepUpdated,
          onBodyWeightLogUpdated:_onBodyWeightLogUpdated,
          onNutritionGoalsUpdated: _onNutritionGoalsUpdated,
          onSleepGoalsUpdated:_onSleepGoalsUpdated,
          onWorkoutGoalsUpdated:_onWorkoutGoalsUpdated,
          onMyFoodsUpdated:_onMyFoodsUpdated,
          onProgramsUpdated:_onProgramsUpdated,
          onExerciseMenuUpdated:_onExerciseMenuUpdated,
        );
    }

    return Scaffold(
      body: Center(
        child: currentScreen,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'カレンダー',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check,),
            label: '今日の記録',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: '分析',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'プロフィールと設定',
          ),
        ],
        currentIndex: _selectIndex,
        selectedItemColor: Color(0xFF4169E1),
        unselectedItemColor: Colors.grey,
        onTap: (index){
          if (index==2){
            _showAddDialog();
          }else{
            _onItemTapped(index);
          }
        },
        type: BottomNavigationBarType.fixed,   //タブが４つ以上でもレイアウトは固定しておく。
      ),
    );
  }
}