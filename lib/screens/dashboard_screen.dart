import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:muscle_one/model/daily_nutrition.dart';
import 'package:muscle_one/model/review_workout.dart';
import 'package:muscle_one/model/sleep_log.dart';
import 'package:muscle_one/model/user_profile.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:collection/collection.dart';
import 'dart:math';
import 'daily_log_screen.dart';
import 'daily_nutrition_screen.dart';
import 'sleep_log_screen.dart';
import 'body_weight_log_screen.dart';
import 'goal_setting_screen.dart';
import '../model/food_item.dart';
import '../model/history_log.dart';
import '../model/nutrition_goal.dart';
import '../model/workout_program.dart';
import '../model/workout_goal.dart';
import '../model/sleep_goal.dart';
import '../model/body_weight_log.dart';
//import 'package:table_calendar/table_calendar.dart';

class DashboardRing extends StatelessWidget{
  final IconData icon;
  final double percent;
  final Color color;
  final VoidCallback onTap;

  const DashboardRing({
    super.key,
    required this.icon,
    required this.percent,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap:onTap,
      child:Stack(
        alignment:Alignment.center,
        children:[
          CircularPercentIndicator(
            radius:80.0,
            lineWidth:10.0,
            percent:percent.clamp(0.0, 1.0),
            backgroundColor:Colors.white.withOpacity(0.1),
            progressColor:color,
            circularStrokeCap:CircularStrokeCap.round,      //100%を超えた時はどうなるのか=>リングは一周のみ、%は増え続ける。
            animation:true,
          ),
          Column(
            mainAxisAlignment:MainAxisAlignment.center,
            children:[
              Icon(icon, color:Colors.white, size:30),
              const SizedBox(height:4),
              Text('${(percent*100).toInt()}%', style:TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold),),
            ]
          ),
        ]
      ),
    );
  }
}

class TrianglePainter extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size){
    final paint=Paint()                      //こいつはペンの役割で、..はカスケード記法と言って、定義を追加できる。
    ..color=Colors.white.withOpacity(0.15)    //色と線の太さを決定
    ..strokeWidth=2;

    //三角形の頂点座標を計算
    final path=Path();
    path.moveTo(size.width/2, 0);
    path.moveTo(0, size.height);            //(x,y)で左上を原点に、y軸は逆向き
    path.moveTo(size.width ,size.height);
    path.close();
    //線をかく
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate)=> false;
}

class DashboardScreen extends StatefulWidget{
  final List<ReviewWorkout> allWorkouts;
  final List<DailyNutrition> allDailyNutrition;
  final List<SleepLog> allSleepLogs;
  final List<FoodItem> allMyFoods;
  final List<BodyWeightLog> allBodyWeightLogs;
  final List<NutritionGoal> allNutritionGoals;
  final List<SleepGoal> allSleepGoals;
  final List<WorkoutGoal> allWorkoutGoals;
  final List<WorkoutProgram> allPrograms;
  final UserProfile userProfile;
  final Map<String,List<String>> exerciseMenu;
  final Function(ReviewWorkout) onWorkoutUpdated;
  final Function(DailyNutrition) onNutritionUpdated;
  final Future<List<HistoryLog>> Function() onHistoryReloadRequested;
  final Function(SleepLog) onSleepUpdated;
  final Function(BodyWeightLog) onBodyWeightLogUpdated;
  final Function(List<FoodItem>) onMyFoodsUpdated;
  final Function(List<NutritionGoal>) onNutritionGoalsUpdated;
  final Function(List<SleepGoal>) onSleepGoalsUpdated;
  final Function(List<WorkoutGoal>) onWorkoutGoalsUpdated;
  final Function(List<WorkoutProgram>) onProgramsUpdated;
  final Function(Map<String,List<String>>) onExerciseMenuUpdated;
  final List<HistoryLog> historyList;

  const DashboardScreen({
    super.key,
    required this.allWorkouts,
    required this.allDailyNutrition,
    required this.allSleepLogs,
    required this.allMyFoods,
    required this.allBodyWeightLogs,
    required this.allNutritionGoals,
    required this.allSleepGoals,
    required this.allWorkoutGoals,
    required this.allPrograms,
    required this.exerciseMenu,
    required this.userProfile,
    required this.onWorkoutUpdated,
    required this.onNutritionUpdated,
    required this.onHistoryReloadRequested,
    required this.onSleepUpdated,
    required this.onBodyWeightLogUpdated,
    required this.onMyFoodsUpdated,
    required this.onNutritionGoalsUpdated,
    required this.onSleepGoalsUpdated,
    required this.onWorkoutGoalsUpdated,
    required this.onProgramsUpdated,
    required this.onExerciseMenuUpdated,
    required this.historyList,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>{
  late DateTime _displayedDay;
  // final DateTime _initialDay=DateTime.now();
  //_initialDayは今日の日付で固定。 _displayedDayは今現在表示されている画面なので、変化する。

  static const int pageOffset=1000;
  final PageController _pageController=PageController(initialPage: pageOffset);
  bool _isPageScrollable=true;

  late List<NutritionGoal> _nutritionGoalsCopy;
  late List<WorkoutGoal> _workoutGoalsCopy;
  late List<SleepGoal> _sleepGoalsCopy;

  @override
  void initState(){
    super.initState();
    //今日の日付が何番目のページかを計算して初期ページに設定
    _displayedDay=DateTime.now();
    _nutritionGoalsCopy = List.of(widget.allNutritionGoals);
    _workoutGoalsCopy = List.of(widget.allWorkoutGoals);
    _sleepGoalsCopy = List.of(widget.allSleepGoals);
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    //print('Dashboard_screenで、didUpdatedWidgetが呼び出されました。');
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.allNutritionGoals, oldWidget.allNutritionGoals)) {
      setState(() {
        _nutritionGoalsCopy = List.of(widget.allNutritionGoals);
      });
    }
    if (!listEquals(widget.allWorkoutGoals, oldWidget.allWorkoutGoals)) {
      setState(() {
        _workoutGoalsCopy = List.of(widget.allWorkoutGoals);
      });
    }
    if (!listEquals(widget.allSleepGoals, oldWidget.allSleepGoals)) {
      setState(() {
        _sleepGoalsCopy = List.of(widget.allSleepGoals);
      });
    }
  }

  @override
  void dispose(){
    _pageController.dispose();
    super.dispose();
  }

  void _showDatePicker(){
    setState((){
      _isPageScrollable=false;
    });
    showModalBottomSheet(
      context:context,
      isScrollControlled: true,   //サイズをコンテンツに合わせる。
      builder: (BuildContext builder){
        DateTime tempSelectedDate=_displayedDay;

        return StatefulBuilder(
          builder:(BuildContext build, StateSetter setModalState){
            return SizedBox(
              height:300,
              child:Column(
                children:[
                  Padding(
                    padding:const EdgeInsets.symmetric(vertical:8.0 ,horizontal:16.0),
                    child:Stack(
                      alignment:Alignment.center,
                      children:[
                        Align(
                          alignment:Alignment.centerLeft,
                          child:CupertinoButton(
                            child:const Text('今日'),
                            onPressed:(){
                              setModalState((){
                                tempSelectedDate=DateTime.now();
                              });
                            }
                          )
                        ),
                        const Text('日付を選択', style:TextStyle(fontSize:18, fontWeight:FontWeight.bold),),
                        Align(
                          alignment:Alignment.centerRight,
                          child:CupertinoButton(
                              child:const Text('完了'),
                              onPressed:(){
                                final todayAtMidnight=DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                                final cleanSelectedDate=DateTime(tempSelectedDate.year, tempSelectedDate.month, tempSelectedDate.day);
                              
                                final difference=cleanSelectedDate.difference(todayAtMidnight).inDays;
                                final newPageIndex=pageOffset+difference;
                                //jump to the new page
                                _pageController.jumpToPage(newPageIndex);
                                Navigator.pop(context);
                              },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height:1),
                  Expanded(
                    child:CupertinoDatePicker(
                      key:ValueKey(tempSelectedDate),
                      mode:CupertinoDatePickerMode.date,
                      initialDateTime: tempSelectedDate,
                      onDateTimeChanged:(DateTime newDate){
                        setModalState((){
                          tempSelectedDate=newDate;
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    ).then((_){
      setState((){
        _isPageScrollable=true;
      });
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context){

    final screenWidth=MediaQuery.of(context).size.width;
    final screenHeight=MediaQuery.of(context).size.height;
    final ringSize=250.0;
    final triangleSideLength=screenWidth*0.65;
    final triangleHeight=(ringSize * sqrt(3))/2;  //三角形の高さr×√３÷２

    //print('Dashboard_screenでbuildが実行されました。現在の目標のリスト数: ${widget.allNutritionGoals.length}');
    return Scaffold(
      backgroundColor: Color(0xFF000020),
      appBar: null,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          physics:_isPageScrollable
            ? const PageScrollPhysics()
            : const NeverScrollableScrollPhysics(),
          onPageChanged: (index){
            setState(() {
              final todayAtMidnight=DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
              _displayedDay=todayAtMidnight.add(Duration(days: index-pageOffset));
            });
          //後で新規の日付を読み込む処理を追加
          },
          itemBuilder: (context, index){
            final todayAtMidnight=DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
            final day=todayAtMidnight.add(Duration(days: index-pageOffset));

            //print('--- 描画開始: ${DateFormat('MM/dd').format(day)}のページ ---');
            //print('1. Stateが保持する目標リストの数: ${_nutritionGoalsCopy.length}');
            //この日のパーセント計算
            final workoutForDay=widget.allWorkouts.firstWhere(
              (w)=>isSameDay(w.date, day),
              orElse: ()=> ReviewWorkout(date: day)
            );
            final nutritionForDay=widget.allDailyNutrition.firstWhere(
              (w)=>isSameDay(w.day, day),
              orElse: () => DailyNutrition(day: day),
            );
            final sleepLogForDay=widget.allSleepLogs.firstWhere(
              (s)=>isSameDay(s.date, day),
              orElse: () => SleepLog(date: day, sleepInTime: day, wakeUpTime: day),
            );
            final bodyWeightLogForDay=widget.allBodyWeightLogs.firstWhere(
              (log)=> isSameDay(log.date,day),
              orElse:()=> BodyWeightLog(date:day, bodyWeight:0)
            );

            final activeNutritionGoal=_nutritionGoalsCopy.firstWhereOrNull(
              (g)=>day.isAfter(g.startDate.subtract(const Duration(seconds:1))) && (g.endDate==null || day.isBefore(g.endDate!.add(const Duration(seconds:1))))
            );
            //print('2. 有効な目標を検索 → 結果: ${activeNutritionGoal != null ? "${activeNutritionGoal.calories}kcal" : "見つかりません"}');
            final activeWorkoutGoal=_workoutGoalsCopy.firstWhereOrNull(
              (g)=>day.isAfter(g.startDate.subtract(const Duration(seconds:1))) && (g.endDate==null || day.isBefore(g.endDate!.add(const Duration(seconds:1))))
            );
            final activeSleepGoal=_sleepGoalsCopy.firstWhereOrNull(
              (g)=>day.isAfter(g.startDate.subtract(const Duration(seconds:1))) && (g.endDate==null || day.isBefore(g.endDate!.add(const Duration(seconds:1))))
            );


            //記録を参照=>なかったら作成
            final nutritionGoalValue=activeNutritionGoal?.calories ?? 2400;
            //print('3. UI計算に使用する最終的な目標値: $nutritionGoalValue kcal');
            final sleepGoalValue=activeSleepGoal?.hours ?? 7.0;
            double workoutCurrentValue=0;
            double workoutGoalValue=5.0;
            String workoutUnit='種目';

            if(activeWorkoutGoal != null){
              workoutGoalValue = activeWorkoutGoal.value;
              switch(activeWorkoutGoal.goalType){
                case WorkoutGoalType.exerciseCount:
                  workoutCurrentValue = workoutForDay.ListOftodayLog.length.toDouble();
                  workoutUnit = '種目';
                  break;
                case WorkoutGoalType.totalVolume:
                  workoutCurrentValue = workoutForDay.totalVolume;
                  workoutUnit = 'kg';
                  break;
                case WorkoutGoalType.totalSets:
                  workoutCurrentValue = workoutForDay.totalSets.toDouble();
                  workoutUnit = 'セット';
                  break;
              }
            }else{
              workoutCurrentValue = workoutForDay.ListOftodayLog.length.toDouble();
            }

            //ここまでで、目標設定を後々動的に設定できるように改善
            final workoutPercent=(workoutGoalValue>0) ? (workoutCurrentValue / workoutGoalValue) :0.0;//後々トレーニングボリュームを計算できるようにgetterの設定
            final nutritionPercent=(nutritionGoalValue>0) ?(nutritionForDay.totalCalories/nutritionGoalValue) :0.0;
            final sleepDuration=(sleepLogForDay.wakeUpTime.difference(sleepLogForDay.sleepInTime).inHours.toDouble());
            final sleepPercent=(sleepGoalValue>0) ?(sleepDuration/sleepGoalValue)  :0.0;

            return Column(
              children:[
                _buildDateNavigator(),  //日付を表示
                //リングエリア
                Expanded(
                  flex:3,               //残り画面の５割をリングエリアで使いますよと宣言
                  child:Center(
                    child:SizedBox(
                      width:380,
                      height:330,
                      child:Stack(
                        children:[
                          Align(
                            alignment:Alignment.topCenter,
                            child:SizedBox(
                              width:160, 
                              height:160, 
                              child: DashboardRing(
                                icon:Icons.fitness_center, 
                                percent:workoutPercent, 
                                color:Colors.orange,
                                onTap:()=>_navigateToLogScreen(context,workoutForDay),
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          Align(
                            alignment:Alignment.bottomLeft,
                            child:SizedBox(
                              width:160, 
                              height:160, 
                              child: Padding(
                                padding: EdgeInsets.only(left:50),
                                child:DashboardRing(
                                  icon:Icons.restaurant, 
                                  percent:nutritionPercent, 
                                  color:Colors.green,
                                  onTap:()=>_navigateToNutritionScreen(context,nutritionForDay)
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment:Alignment.bottomRight,
                            child:SizedBox(
                              width:160, 
                              height:160, 
                              child: Padding(
                                padding: EdgeInsets.only(right:50),
                                child:DashboardRing(
                                  icon:Icons.bedtime, 
                                  percent:sleepPercent, 
                                  color:Color(0xFF4169E1),
                                  onTap:()=>_navigateToSleepScreen(context,sleepLogForDay),
                                ),
                              ),
                            ),
                          ),
                        ]
                      ),
                    ),
                  ),
                ),
                
                //元カードエリア
                Padding(
                  padding:const EdgeInsets.only(left:40.0, top:16,bottom:40),
                  child:Column(
                    mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment:CrossAxisAlignment.start,
                    children:[
                      _buildSummaryRow(
                        icon:Icons.fitness_center,
                        title:'トレーニング',
                        valueText: workoutForDay.ListOftodayLog.isNotEmpty
                                      ? '${workoutCurrentValue.toStringAsFixed(1)} /  ${workoutGoalValue.toInt()} $workoutUnit'
                                      : '記録なし',
                        onTap: () => _navigateToLogScreen(context, workoutForDay),
                      ),
                      _buildSummaryRow(
                        icon:Icons.restaurant,
                        title:'食事',
                        valueText: nutritionForDay.totalCalories > 0
                                      ? '${nutritionForDay.totalCalories.toStringAsFixed(1)} /  ${nutritionGoalValue.toInt()} kcal'
                                      : '記録なし',
                        onTap:()=>_navigateToNutritionScreen(context,nutritionForDay),
                      ),
                      _buildSummaryRow(
                        icon:Icons.bedtime,
                        title:'睡眠',
                        valueText: sleepDuration > 0
                                      ? '${sleepDuration.toStringAsFixed(1)} /  ${sleepGoalValue.toStringAsFixed(1)} 時間'
                                      : '記録なし',
                        onTap:()=>_navigateToSleepScreen(context,sleepLogForDay),
                      ),
                      _buildSummaryRow(
                        icon:Icons.monitor_weight,
                        title:'体重',
                        valueText: bodyWeightLogForDay.bodyWeight > 0
                                      ? '${bodyWeightLogForDay.bodyWeight.toStringAsFixed(1)} kg'
                                      :'記録なし',
                        onTap: () => _navigateToaBodyWeightScreen(context, bodyWeightLogForDay),
                      ),
                    ]
                  ),
                ),
              ]
            );
          }        
        ),
      ),
    );
  }

  void _navigateToLogScreen(BuildContext context, ReviewWorkout workoutData)async{
    final ReviewWorkout? returnedWorkout=await Navigator.push(
      context,
      MaterialPageRoute(
        builder:(context)=>DailyLogScreen(
          logData:workoutData, 
          allBodyWeightLogs:widget.allBodyWeightLogs,
          allWorkoutHistory: widget.allWorkouts,
          allPrograms:widget.allPrograms,
          exerciseMenu:widget.exerciseMenu,
          onProgramsUpdated:widget.onProgramsUpdated,
          onWorkoutUpdated:widget.onWorkoutUpdated,
          onExerciseMenuUpdated:widget.onExerciseMenuUpdated,
        ),
      ),
    );
    if (returnedWorkout!=null){                                  //変更点があればそれだけを変更して更新、変更がなければそのまま全部をnewListに定義し直していく
      widget.onWorkoutUpdated(returnedWorkout);       //これでメイン画面に報告して、おしまい！
    }
  }

  void _navigateToNutritionScreen(BuildContext context, DailyNutrition nutritionData)async{
    final DailyNutrition? returnedNutrition= await Navigator.push(
      context,
      MaterialPageRoute(
        builder:(context)=>DailyNutritionScreen(
          nutritiondata:nutritionData,
          allMyFoods:widget.allMyFoods,
          allNutritionGoals:widget.allNutritionGoals,
          onNutritionUpdated:widget.onNutritionUpdated,
          onHistoryReloadRequested:widget.onHistoryReloadRequested,
          onMyFoodsUpdated:widget.onMyFoodsUpdated,
          onNutritionGoalsUpdated:widget.onNutritionGoalsUpdated,
          historyList:widget.historyList,
        ),
      ),
    );
    if (returnedNutrition != null){
      final newList=List.of(widget.allDailyNutrition);
      final index=newList.indexWhere((w)=>isSameDay(w.day, returnedNutrition.day));
      if (index!=-1){
        newList[index]=returnedNutrition;
      }else{
        newList.add(returnedNutrition);
      }
      widget.onNutritionUpdated(returnedNutrition);
    }
  }

  void _navigateToSleepScreen(BuildContext context, SleepLog sleepData)async{
    SleepLog? returnedSleepLog=await Navigator.push(
      context,
      MaterialPageRoute(
        builder:(context)=>SleepLogScreen(
          sleepLogData: sleepData,
          onSleepUpdated:widget.onSleepUpdated,
        ),
      ),
    );
  }

  void _navigateToaBodyWeightScreen(BuildContext context, BodyWeightLog logData)async{
    final weeklyWeightLog=_getWeeklyWeightLogs(logData.date);
    final BodyWeightLog? returnedLog=await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context)=>BodyWeightLogScreen(
        bodyWeightLogData: logData, 
        onBodyWeightLogUpdated: widget.onBodyWeightLogUpdated, 
        userProfile: widget.userProfile, 
        weeklyWeightLog: weeklyWeightLog),
      ),
    );
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

  Widget _buildDateNavigator(){
    return  Padding(
              padding: const EdgeInsets.symmetric(vertical:20.0),
              child: TextButton(
                onPressed: _showDatePicker, 
                child: Text(
                  DateFormat('yyyy年 MM月 dd日 (E)','ja_JP').format(_displayedDay),
                  style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color:Colors.white),
                ),
              ),
            );
  }

  Widget _buildSummaryRow({required IconData icon, required String title, required String valueText, VoidCallback? onTap,}){
    return Material(
      color:Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding:const EdgeInsets.symmetric(vertical: 4),
          //child:SizedBox(
            //width:double.infinity,
            child:Row(
              //mainAxisSize:MainAxisSize.min,
              children:[
                Icon(icon, color:Colors.white70,size:24),
                const SizedBox(width:8),
                Text(title, style:const TextStyle(color:Colors.white, fontSize:14)),
                const SizedBox(width:8),
                Text(valueText, style:const TextStyle(color:Colors.white70, fontSize:14), overflow: TextOverflow.ellipsis),
              ],
            ),
        ),
      ),
    );
  }
}