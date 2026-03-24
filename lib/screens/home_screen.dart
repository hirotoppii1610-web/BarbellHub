import 'package:flutter/material.dart';
import 'package:muscle_one/model/body_weight_log.dart';
import 'package:muscle_one/screens/body_weight_log_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';
import 'daily_log_screen.dart';
import 'daily_nutrition_screen.dart';
import 'sleep_log_screen.dart';
import 'analysis_screen.dart';
import 'goal_setting_screen.dart';
import '../model/review_workout.dart';
import '../model/daily_nutrition.dart';
import '../model/sleep_log.dart';
import '../model/food_item.dart';
import '../model/history_log.dart';
import '../model/nutrition_goal.dart';
import '../model/workout_program.dart';
import '../model/user_profile.dart';



class HomeScreen extends StatefulWidget{
  final List<ReviewWorkout> allWorkouts;
  final List<DailyNutrition> allDailyNutrition;
  final List<SleepLog> allSleepLogs;
  final List<FoodItem> allMyFoods;
  final List<NutritionGoal> allNutritionGoals;
  final List<WorkoutProgram> allPrograms;
  final List<BodyWeightLog> allBodyWeightLogs;
  final Map<String,List<String>> exerciseMenu;
  final Function (ReviewWorkout) onWorkoutUpdated;
  final Function (DailyNutrition) onNutritionUpdated;
  final Future<List<HistoryLog>> Function() onHistoryReloadRequested;
  final Function (SleepLog) onSleepUpdated;
  final Function (List<FoodItem>) onMyFoodsUpdated;
  final Function (List<NutritionGoal>) onNutritionGoalsUpdated;
  final Function (List<WorkoutProgram>) onProgramsUpdated;
  final Function (Map<String,List<String>>) onExerciseMenuUpdated;
  final Function (BodyWeightLog) onBodyWeightLogUpdated;
  final List<HistoryLog> historyList;
  final UserProfile userProfile;

  const HomeScreen({
    super.key,
    required this.allWorkouts,
    required this.allDailyNutrition,
    required this.allSleepLogs,
    required this.allMyFoods,
    required this.allNutritionGoals,
    required this.allPrograms,
    required this.allBodyWeightLogs,
    required this.exerciseMenu,
    required this.onWorkoutUpdated,
    required this.onNutritionUpdated,
    required this.onHistoryReloadRequested,
    required this.onSleepUpdated,
    required this.onMyFoodsUpdated,
    required this.onNutritionGoalsUpdated,
    required this.onProgramsUpdated,
    required this.onExerciseMenuUpdated,
    required this.onBodyWeightLogUpdated,
    required this.historyList,
    required this.userProfile,
  });


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  DateTime _focusedDay=DateTime.now();
  DateTime?  _selectedDay;
  late List<ReviewWorkout> _allWorkouts;
  late List<DailyNutrition> _allDailyNutrition;
  late List<SleepLog> _allSleepLogs;
  late UserProfile _userProfile;

  @override
  void initState(){
    super.initState();
    _selectedDay=_focusedDay;
    _allWorkouts=List.of(widget.allWorkouts);
    _allDailyNutrition=List.of(widget.allDailyNutrition);
    _allSleepLogs=List.of(widget.allSleepLogs);
    _userProfile=widget.userProfile.copyWith();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget){
    super.didUpdateWidget(oldWidget);
    if(widget.allWorkouts != oldWidget.allWorkouts){
      _allWorkouts=List.of(widget.allWorkouts);
    }
    if(widget.allDailyNutrition != oldWidget.allDailyNutrition){
      _allDailyNutrition=List.of(widget.allDailyNutrition);
    }
    if(widget.allSleepLogs != oldWidget.allSleepLogs){
      _allSleepLogs=List.of(widget.allSleepLogs);
    }
    if(widget.userProfile != oldWidget.userProfile){
      print("✅ 3. [HomeScreen] 新しいプロフィールを受信しました。");
      print("      旧: ${oldWidget.userProfile}");
      print("      新: ${widget.userProfile}");
      setState((){
        _userProfile=widget.userProfile.copyWith();
      });
    }
  }

  List<BodyWeightLog> _getWeeklyWeightLogs(DateTime date){
    final endDate=DateTime(date.year, date.month, date.day);
    final startDate=endDate.subtract(const Duration(days:6));

    return widget.allBodyWeightLogs.where((log){
      final logDate=DateTime(log.date.year, log.date.month, log.date.day);
      //startdate<=logDate<=endDateの範囲で抽出
      return !logDate.isBefore(startDate) && !logDate.isAfter(endDate);
    }).toList();
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor:Color(0xFF000020),
      body:SingleChildScrollView(
        child:Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:8.0),
              child:TableCalendar(
                locale: 'ja_JP',
                firstDay: DateTime.utc(2020,1, 1),
                lastDay:DateTime.utc(2035,12,31),
                daysOfWeekHeight:30,
                focusedDay: _focusedDay,
                selectedDayPredicate: (day){
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay,focusedDay){
                  setState(() {
                    _selectedDay=selectedDay;
                    _focusedDay=focusedDay;
                  });
                },
                //カレンダーのヘッダー（年月表示の編集）
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,   //このボタンがあると、1か月と二週間に一週間のカレンダーというように切れ替えができる。
                  titleCentered: true,  //ヘッダーを真ん中に配置
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
                  leftChevronIcon: Icon(Icons.chevron_left, color:Colors.white),
                  rightChevronIcon:Icon(Icons.chevron_right, color:Colors.white),
                ),
                //曜日の文字スタイル
                daysOfWeekStyle:const DaysOfWeekStyle(
                  decoration:BoxDecoration(border:Border(bottom: BorderSide(color:Colors.white24, width:1.0),),),
                ),
                calendarBuilders:CalendarBuilders(
                  dowBuilder:(context, day){
                    //曜日を日本語で
                    const dayOfWeek={
                      1:'月',
                      2:'火',
                      3:'水',
                      4:'木',
                      5:'金',
                      6:'土',
                      7:'日',
                    };
                    final text=dayOfWeek[day.weekday]!;
                    final textColor=  Colors.white;
                    return Center(
                      child:Padding(
                        padding:EdgeInsets.only(bottom:6.0),
                        child:Text(text,style:TextStyle(color:textColor),),
                      ),
                    );
                  },
                ),
                //カレンダーの日付の文字スタイル
                calendarStyle:CalendarStyle(
                  defaultTextStyle:const TextStyle(color:Colors.white),
                  weekendTextStyle:const TextStyle(color:Colors.white),
                  outsideTextStyle:TextStyle(color:Colors.white.withOpacity(0.4)),
                  //今日の日付のハイライト
                  todayDecoration:BoxDecoration(
                    color:Colors.white.withOpacity(0.2),
                    shape:BoxShape.circle,
                  ),
                  todayTextStyle:const TextStyle(color:Colors.white),
                  //選択した日付のハイライト
                  selectedDecoration: const BoxDecoration(
                    color:Colors.blueAccent,
                    shape:BoxShape.circle,
                  ),
                  selectedTextStyle:const TextStyle(color:Colors.white, fontWeight:FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildRecordButton(
              text:'トレーニング記録',
              icon:Icons.fitness_center,
              color:Colors.orange,
              onPressed: () async{
                final selected=_selectedDay;
                if (selected !=null){
                  final workoutForDay=_allWorkouts.firstWhere(
                    (w)=>isSameDay(w.date, _selectedDay),
                    orElse: ()=>ReviewWorkout(date: _selectedDay!),
                  );         //この上の{}では、_selectedDayの日に、ReviewWorkoutからトレ履歴のリストを参照する。
                              //なければトレ履歴となる空のログを作成する
                  
                  //画面遷移後は、トレ履歴が変わっている可能性があり、
                  //その結果リストの中身が変わっている可能性がある。
                  final ReviewWorkout? returnedWorkout=await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:(context)=> DailyLogScreen(
                        logData: workoutForDay,
                        allBodyWeightLogs: widget.allBodyWeightLogs,
                        allWorkoutHistory:_allWorkouts,
                        allPrograms:widget.allPrograms,
                        exerciseMenu:widget.exerciseMenu,
                        onProgramsUpdated:widget.onProgramsUpdated,
                        onWorkoutUpdated:widget.onWorkoutUpdated,
                        onExerciseMenuUpdated:widget.onExerciseMenuUpdated,
                      ),
                    ),
                  );

                  //中身が変わっていた場合↓
                  if (returnedWorkout != null){
                    widget.onWorkoutUpdated(returnedWorkout);
                    print('トレ記録をちゃんと保存できました。');
                  }
                }            
              },
            ),
            _buildRecordButton(
              text:'食事記録',
              icon:Icons.restaurant,
              color:Colors.green,
              onPressed: ()async{
                final selected=_selectedDay;
                if (selected != null){
                  final nutritionForDay=_allDailyNutrition.firstWhere(
                    (n)=> isSameDay(n.day, selected),
                    orElse: ()=>DailyNutrition(day: selected),
                  );
                  final DailyNutrition? returnedNutrition=await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context)=>DailyNutritionScreen(
                        nutritiondata: nutritionForDay,
                        allMyFoods: widget.allMyFoods,
                        allNutritionGoals: widget.allNutritionGoals,
                        onNutritionUpdated: widget.onNutritionUpdated,
                        onHistoryReloadRequested:widget.onHistoryReloadRequested,
                        onMyFoodsUpdated: widget.onMyFoodsUpdated,
                        onNutritionGoalsUpdated: widget.onNutritionGoalsUpdated,
                        historyList:widget.historyList,
                      ),
                    ),
                  );
                  if (returnedNutrition!=null){
                    final index=_allDailyNutrition.indexWhere((n)=>isSameDay(n.day, selected));
                    if (index !=-1){
                      _allDailyNutrition[index]=returnedNutrition;
                    } else{
                      _allDailyNutrition.add(returnedNutrition);
                    }
                    //await _dbService.saveDailynutrition(_allDailyNutrition);
                    widget.onNutritionUpdated(returnedNutrition);
                    setState((){});
                    print('食事データを保存しました。');
                  }
                }
              },
            ),
            _buildRecordButton(
              text:'睡眠記録',
              icon:Icons.bedtime,
              color:Colors.blue,
              onPressed: ()async{
                final selected=_selectedDay;
                if(selected != null){
                  final sleepLogForDay=_allSleepLogs.firstWhere(
                    (n)=> isSameDay(n.date, selected),
                    orElse: () => SleepLog(
                      date: selected,
                      sleepInTime: selected,
                      wakeUpTime: selected,
                    ),
                  );
                  final SleepLog? returnedSleepLog=await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context)=>SleepLogScreen(
                        sleepLogData: sleepLogForDay,
                        onSleepUpdated:widget.onSleepUpdated,
                      ),
                    ),
                  );
                }
              }, 
            ),
            _buildRecordButton(
              text:'体重記録',
              icon: Icons.monitor_weight,
              color:Colors.teal,
              onPressed:(){
                final selected=_selectedDay;
                if(selected!=null){
                  final logForDay= widget.allBodyWeightLogs.firstWhere(
                    (log)=> isSameDay(log.date, selected), orElse:()=> BodyWeightLog(date:selected, bodyWeight:0),
                  );
                  final weeklyWeightLog=_getWeeklyWeightLogs(selected);
                  print("✅ 4. [HomeScreen] 体重画面へ遷移します。渡すプロフィールは\n$_userProfile");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:(context)=>BodyWeightLogScreen(
                        bodyWeightLogData:logForDay,
                        onBodyWeightLogUpdated:widget.onBodyWeightLogUpdated,
                        userProfile:_userProfile,
                        weeklyWeightLog:weeklyWeightLog,
                      ),
                    ),
                  );
                }
              }
            ),
          ]
        ),
      ),
    );
  }

  Widget _buildRecordButton({required String text, required IconData icon,
    required Color color,required VoidCallback onPressed}){
      
      return Padding(
        padding:const EdgeInsets.symmetric(horizontal:20.0, vertical:8.0),
        child: ElevatedButton.icon(
          icon:Icon(icon, color:Colors.white),
          label:Text(text, style:const TextStyle(fontSize:18,color:Colors.white), ),
          style:ElevatedButton.styleFrom(
            backgroundColor:color.withOpacity(0.8),
            minimumSize: const Size(250, 40), //横幅いっぱいで高さは５０
            shape:RoundedRectangleBorder(
              borderRadius:BorderRadius.circular(12),
            ),
          ),
          onPressed:_selectedDay==null ?null :onPressed,  //日付がない場合は無効化
        )
      );
  }

}