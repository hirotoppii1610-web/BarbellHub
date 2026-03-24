import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:collection/collection.dart';
import 'package:muscle_one/model/program_day.dart';
import 'package:muscle_one/model/program_week.dart';
import 'package:muscle_one/model/workout_log.dart';
import 'package:muscle_one/model/review_workout.dart';
import 'package:muscle_one/model/workout_program.dart';
import 'package:muscle_one/model/workout_set.dart';
import 'package:muscle_one/model/cardio_set.dart';
import 'package:muscle_one/model/body_weight_log.dart';
import 'package:muscle_one/model/cardio_log.dart';
import 'package:muscle_one/screens/exercise_select_screen.dart';
import 'package:muscle_one/screens/cardio_select_screen.dart';
import 'package:muscle_one/screens/program_list_screen.dart';
import 'package:muscle_one/screens/exercise_history_screen.dart';
import 'package:muscle_one/screens/cardio_history_screen.dart';
import 'package:muscle_one/widget/workout_log_filling.dart';
import 'package:muscle_one/widget/cardio_log_filling.dart';

class DailyLogScreen extends StatefulWidget{
  final ReviewWorkout logData;
  final List<BodyWeightLog> allBodyWeightLogs;
  final List<ReviewWorkout> allWorkoutHistory;
  final List<WorkoutProgram> allPrograms;
  final Map<String,List<String>> exerciseMenu;
  final Function(ReviewWorkout) onWorkoutUpdated;
  final Function(List<WorkoutProgram>) onProgramsUpdated;
  final Function(Map<String,List<String>>) onExerciseMenuUpdated;
  
  const DailyLogScreen({
    super.key, 
    required this.logData, 
    required this.allBodyWeightLogs,
    required this.allWorkoutHistory,
    required this.allPrograms,
    required this.exerciseMenu,
    required this.onWorkoutUpdated,
    required this.onProgramsUpdated,
    required this.onExerciseMenuUpdated,
  });

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}


class _DailyLogScreenState extends State<DailyLogScreen>{
  //この画面が管理するトレーニング種目のリスト
  late ReviewWorkout _logCopy;
  late List<WorkoutProgram> _programs;
  late List<dynamic> _allTodaysActivities;
  final ScrollController _scrollController = ScrollController();
  bool _showFab=false;
  
  @override
  void initState(){
    super.initState();
    _logCopy=widget.logData.copyWith();
    _updatedActivityList();
    _programs=List.of(widget.allPrograms);
    _scrollController.addListener(_scrollListener);                 
  }

  @override
  void dispose(){
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener(){
    if(_scrollController.offset >=300 && !_showFab){
      setState(()=>_showFab=true);
    }else if(_scrollController.offset <300 && _showFab){
      setState(()=>_showFab=false);
    }
  }

  void _updatedActivityList(){
    setState((){
      List<dynamic> combinedList = [..._logCopy.ListOftodayLog, ..._logCopy.cardioLogs];
      //時系列順に
      combinedList.sort((a,b)=>a.createdAt.compareTo(b.createdAt));
      _allTodaysActivities=combinedList;
    });
  }

  double? _getWeightForDate(DateTime date){
    final todayLog=widget.allBodyWeightLogs.firstWhereOrNull(
      (log)=>isSameDay(log.date, date) && log.bodyWeight>0
    );
    if(todayLog!=null) return todayLog.bodyWeight;

    final pastLogs=widget.allBodyWeightLogs.where((log)=>log.date.isBefore(date) && log.bodyWeight>0).toList();
    if(pastLogs.isNotEmpty) return pastLogs.first.bodyWeight;

    final futureLogs=widget.allBodyWeightLogs.where((log)=>log.date.isAfter(date) && log.bodyWeight>0).toList();
    if(futureLogs.isNotEmpty) return futureLogs.last.bodyWeight;

    return null;
  }

  bool isSameDay(DateTime a, DateTime b){
    return a.year==b.year && a.month==b.month && a.day==b.day;
  }

  double _calculateWeightTrainingCalories(){
    final weight=_getWeightForDate(widget.logData.date) ?? 60.0;
    print('[DEBUG] Body Weight For Calc: $weight'); // 体重をコンソールに表示
    if(weight==null || weight<0) return 0;
    const mets=3.5;
    final totalSets=_logCopy.totalSets;
    final estimatedMinutes = totalSets*3.5;
    return mets * weight * (estimatedMinutes/60) * 1.05;
  }

  double _calculateCardioCalories(){
    final weight=_getWeightForDate(widget.logData.date) ?? 60.0;
    if(weight==null || weight<0) return 0;
    return _logCopy.cardioLogs.fold(0.0, (sum,log){
      final caloriesForThisLog = log.totalCaloriesBurned(weight);
      print('[DEBUG] Calories for ${log.type}: $caloriesForThisLog'); // 各有酸素種目のカロリー
      return sum+log.totalCaloriesBurned(weight);
    });
  }

  void _handleUpdated(ReviewWorkout updatedLog){
    if(!mounted)return;
    setState((){
      _logCopy=updatedLog;
      _updatedActivityList();
    });
    widget.onWorkoutUpdated(updatedLog);
  }

  void _handlePop(){
    _logCopy.ListOftodayLog.forEach((log)=>log.set.removeWhere((s)=>s.isEmpty));
    _logCopy.ListOftodayLog.removeWhere((log)=>log.set.isEmpty);

    _logCopy.cardioLogs.forEach((log)=>log.sets.removeWhere((s)=>s.isEmpty));
    _logCopy.cardioLogs.removeWhere((log)=>log.sets.isEmpty);
    
    widget.onWorkoutUpdated(_logCopy);
    Navigator.pop(context);
  }
  
  void goToStartWorkout()async{
    final selectedExerciseName= await Navigator.push(
      context,
      MaterialPageRoute(builder: (context)=>ExerciseSelectScreen(
        exerciseMenu:widget.exerciseMenu,
        onExerciseMenuUpdated:widget.onExerciseMenuUpdated,
      )),
    );

    if (selectedExerciseName != null){
      final newLog=WorkoutLog(exerciseName: selectedExerciseName);
      _logCopy.ListOftodayLog.add(newLog);
      _handleUpdated(_logCopy.copyWith(ListOftodayLog: _logCopy.ListOftodayLog));

      WidgetsBinding.instance.addPostFrameCallback((_){
        if (_scrollController.hasClients){
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut
          );
        }
      });
    }
  }

  //自己ベストを計算するもの→種目の記入欄に飛んだ時に受け渡す
  void _showPersnalRecord(String exerciseName){
    final List<WorkoutSet> history=[];
    for (var dailyLog in widget.allWorkoutHistory){
      for (var workoutLog in dailyLog.ListOftodayLog){
        if (workoutLog.exerciseName==exerciseName){  //ここの右辺のexerciseNameはvoid1行目の変数
          history.addAll(workoutLog.set);
        }
      }
    }//↑これが完了すると、ある種目に関しての記録が全部抜き出せている状況
    if (history.isEmpty){
      showDialog(
        context:context,
        builder:(context)=>AlertDialog(
          backgroundColor:const Color(0xFF1e3a5f),
          title:Text('${exerciseName}の自己ベスト', style: const TextStyle(color:Colors.white)),
          content:const Text('トレーニング記録がありません', style:TextStyle(color:Colors.white70)),
          actions:[
            TextButton(
              onPressed:()=>Navigator.pop(context),
              child:const Text('閉じる', style:TextStyle(color:Colors.white)),
            ),
          ]
        ),
      );
      return;                      //記録がないなら抜ける
    }
    
    //記録があった場合はRMmax計算
    double max1RM=0;
    DateTime? max1RMDate;
    double maxweight=0;
    DateTime? maxweightDate;
    for (var dailyLog in widget.allWorkoutHistory){
      for (var workoutLog in dailyLog.ListOftodayLog){
        if (workoutLog.exerciseName==exerciseName){  //ここの右辺のexerciseNameはvoid1行目の変数
          for(var aSet in workoutLog.set){
            if(aSet.estimate1RM>max1RM){
              max1RM=aSet.estimate1RM; 
              max1RMDate=dailyLog.date;
            }
            if(aSet.weight>maxweight){
              maxweight=aSet.weight;
              maxweightDate=dailyLog.date;
            }
          }
        }
      }
    }//↑これが完了すると、ある種目に関しての記録が全部抜き出せている状況
    //計算結果をダイヤログで出力
    showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        backgroundColor: const Color(0xFF1e3a5f),
        title: Text('${exerciseName}の自己ベスト', style:const TextStyle(color:Colors.white,fontSize:18),),
        content: SizedBox(
          height: 70,
          width:300,
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Max1RM: ${max1RM.toStringAsFixed(2)} kg (${DateFormat('y年 M月d日 (E)', 'ja_JP').format(max1RMDate!)})', style:const TextStyle(color:Colors.white70),),
              const SizedBox(height:10),
              Text('Max重量: ${maxweight.toStringAsFixed(0)} kg (${DateFormat('y年 M月d日 (E)', 'ja_JP').format(maxweightDate!)})', style:const TextStyle(color:Colors.white70),),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: ()=>Navigator.pop(context), 
            child: const Text('閉じる', style:TextStyle(color:Colors.white),),
          ),
        ],
      )
    );
  }

  void _loadProgramAsTemplate()async{
    final selectedDay = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:(context)=>ProgramListScreen(
          allPrograms:_programs,
          exerciseMenu:widget.exerciseMenu,
          onProgramsUpdated:(updatedPrograms){
            widget.onProgramsUpdated(updatedPrograms);
            setState((){
              _programs=updatedPrograms;
            });
          },
          onExerciseMenuUpdated:widget.onExerciseMenuUpdated,
          isForSelection: true, //選択モード
        ),
      ),
    );

    if(selectedDay!=null){
      final updatedLogs=List<WorkoutLog>.from(_logCopy.ListOftodayLog);
      //プログラムをコピーして、それを追加
      for(final logTemplate in selectedDay.todayProgram){
        updatedLogs.add(logTemplate.copyWith());
      }
      //即時保存
      _handleUpdated(_logCopy.copyWith(ListOftodayLog: updatedLogs));
    }
  }

  void goToStartCardio()async{
    final selectedCardioType= await Navigator.push(
      context,
      MaterialPageRoute(builder:(context)=>CardioSelectScreen()),
    );
    if(selectedCardioType!=null){
      final existingLogIndex=_logCopy.cardioLogs.indexWhere((log)=>log.type==selectedCardioType);
      final updatedCardioLogs = List<CardioLog>.from(_logCopy.cardioLogs);
      if(existingLogIndex!=-1){
        final existingLog = updatedCardioLogs[existingLogIndex];
        final updatedSets = List<CardioSet>.from(existingLog.sets)..add(CardioSet());
        updatedCardioLogs[existingLogIndex] = existingLog.copyWith(sets: updatedSets);
      }else{
        updatedCardioLogs.add(CardioLog(type: selectedCardioType));
      }
      _handleUpdated(_logCopy.copyWith(cardioLogs: updatedCardioLogs));

      WidgetsBinding.instance.addPostFrameCallback((_){
        if (_scrollController.hasClients){
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut
          );
        }
      });
    }
  }

  void _showBeforeStartWorkout()async{
    final List<Widget> dialogOption=[];
    showDialog(
      context: context, 
      builder: (context)=>SimpleDialog(
        backgroundColor:const Color(0xFF1e3a5f),
        title: const Text('トレーニングの方法を選択', style:const TextStyle(color:Colors.white, fontWeight:FontWeight.bold),),
        children: [
          SimpleDialogOption(
            onPressed: (){
              Navigator.pop(context);
              goToStartWorkout();
            },
            child: const Text('ウェイトトレーニング', style:TextStyle(color:Colors.white)),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _loadProgramAsTemplate();
            },
            child: const Text('マイプログラムを行う', style:TextStyle(color:Colors.white)),
          ),
          SimpleDialogOption(
            onPressed: (){
              Navigator.pop(context);
              goToStartCardio();
            },
            child: const Text('有酸素運動', style:TextStyle(color:Colors.white)),
          ),
        ]
      ),
    );
  }

  void _showCardioPersonalBest(CardioType type){
    double maxDistance=0;
    DateTime? maxDistanceDate;
    int maxDuration=0;
    DateTime? maxDurationDate;
    for (var dailyLog in widget.allWorkoutHistory){
      for (var cardioLog in dailyLog.cardioLogs){
        if (cardioLog.type==type){  //ここの右辺のexerciseNameはvoid1行目の変数
          for(var set in cardioLog.sets){
            if(set.distanceInKm!=null && set.distanceInKm! > maxDistance){
              maxDistance=set.distanceInKm!;
              maxDistanceDate=dailyLog.date;
            }else{
              maxDistance=0;
              maxDistanceDate=DateTime.now();
            }
            if(set.durationInMinutes!=null && set.durationInMinutes! > maxDuration){
              maxDuration=set.durationInMinutes!;
              maxDurationDate=dailyLog.date;
            }else{
              maxDuration=0;
              maxDurationDate=DateTime.now();
            }
          }
        }
      }
    }//↑これが完了すると、ある種目に関しての記録が全部抜き出せている状況

    showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        backgroundColor: const Color(0xFF1e3a5f),
        title: Center(child:Text('自己ベスト', style:const TextStyle(color:Colors.white, fontSize:18),),),
        content: SizedBox(
          height: 70,
          width:300,
          child:(maxDistance!=0 && maxDuration!=0)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize:MainAxisSize.min,
                children: [
                  Text('最長距離: ${maxDistance.toStringAsFixed(2)} km ${DateFormat('y年 M月d日 (E)', 'ja_JP').format(maxDistanceDate!)}', style:const TextStyle(color:Colors.white70),),
                  Text('最長時間: ${maxDuration.toStringAsFixed(0)} 分 ${DateFormat('y年 M月d日 (E)', 'ja_JP').format(maxDurationDate!)}', style:const TextStyle(color:Colors.white70),),
                ],
              )
            : Center(child:Text('まだ記録がありません', style:const TextStyle(color:Colors.white, fontSize:18),),),
        ),
        actions: [
          TextButton(
            onPressed: ()=>Navigator.pop(context), 
            child: const Text('閉じる', style:TextStyle(color:Colors.white),),
          ),
        ],
      )
    );
  }


  @override
  Widget build(BuildContext context){
    print('[DEBUG] DailyLogScreen build running... Cardio Logs: ${_logCopy.cardioLogs.length}');
    final weightForCalc = _getWeightForDate(widget.logData.date);
    final weightTrainingCalories = _calculateWeightTrainingCalories();
    final cardioCalories = _calculateCardioCalories();
    final totalCalories = weightTrainingCalories + cardioCalories;
    final weightTrainingRatio = totalCalories>0 
          ?   weightTrainingCalories/totalCalories
          :   0.0;

    //ここからWillPopScopeで画面に戻った時の処理をカスタマイズ
    return PopScope(
      canPop: false,
      onPopInvoked:(bool didpop){
        if (didpop)return;
        _handlePop();
      },
      child: Scaffold(
          backgroundColor:Color(0xFF000020),
          appBar: AppBar(
            title: Text(
              DateFormat('M月d日 (E)', 'ja_JP').format(widget.logData.date),
              style: const TextStyle(fontSize: 18, fontWeight:FontWeight.bold ,color: Colors.white),
            ),
            backgroundColor: Colors.orange.withOpacity(0.9),
            automaticallyImplyLeading: false,
            leading:IconButton(
              icon:const Icon(Icons.arrow_back, color:Colors.white),
              onPressed:_handlePop,
            ),
            actions:[
              TextButton(
                onPressed:()async{
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:(context)=>ProgramListScreen(
                        allPrograms:_programs,
                        exerciseMenu:widget.exerciseMenu,
                        onProgramsUpdated:(updatedPrograms){
                          widget.onProgramsUpdated(updatedPrograms);
                          setState((){
                            _programs=updatedPrograms;
                          });
                        },
                        onExerciseMenuUpdated:widget.onExerciseMenuUpdated,
                        isForSelection:false, //編集モードで開く。
                      ),
                    ),
                  );
                  setState(() {});
                },
                child:const Text('マイプログラム', style:TextStyle(color:Colors.white)),
              ),
            ],
          ),
          body:Column(
            children:[
              Expanded(
                child:CustomScrollView(
                  controller:_scrollController,
                  slivers:[
                    SliverToBoxAdapter(
                      child:Padding(
                        padding:const EdgeInsets.all(16.0),
                        child:Row(
                          mainAxisAlignment:MainAxisAlignment.center,
                          mainAxisSize:MainAxisSize.min,
                          children:[
                            SizedBox(
                              width:110,
                              child:Card(
                                elevation: 0,     //影を削除
                                color:const Color(0xFF000020),
                                child:CircularPercentIndicator(
                                  radius: 50.0,
                                  lineWidth: 10.0,
                                  percent: weightTrainingRatio.clamp(0.0, 1.0),
                                  center: Text(
                                    '${totalCalories.toInt()}',
                                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color:Colors.white),
                                  ),
                                  footer: Text('kcal',style: const TextStyle(fontSize: 20, color:Colors.white),),
                                  progressColor: Colors.orange,
                                  backgroundColor: Colors.orange.withOpacity(0.5),
                                  circularStrokeCap: CircularStrokeCap.round,
                                  animation:true,
                                ),
                              ),
                            ),
                            SizedBox(
                                height:130, 
                                width: 210,
                                child:Card(
                                  elevation: 0,     //影を削除
                                  color:const Color(0xFF000020),
                                  child:Padding(
                                    padding: EdgeInsets.symmetric(vertical:8, horizontal:4),
                                    child: Column( 
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Center(child:Text('消費カロリー',style:const TextStyle(color:Colors.white, fontSize:20, fontWeight:FontWeight.bold)),),
                                        SizedBox(height:8),
                                        Row(
                                          children:[
                                            const Icon(Icons.fitness_center, color:Colors.orange, size:30,),
                                            Text('トレーニング : ${weightTrainingCalories.toInt()}kcal',style:const TextStyle(color:Colors.white,fontSize:14)),
                                          ],
                                        ),
                                        const SizedBox(height:8),
                                        Row(
                                          children:[
                                            Icon(Icons.directions_run, color:Colors.orange.withOpacity(0.5), size:30,),
                                            Text('  有酸素運動  : ${cardioCalories.toInt()}kcal',style:const TextStyle(color:Colors.white,fontSize:14)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    _allTodaysActivities.isEmpty
                        ? SliverFillRemaining(
                          child: const Center(
                            child:Text('トレーニング記録はありません。', textAlign:TextAlign.center, style:TextStyle(color:Colors.white70, fontSize:18),),
                          ),
                        )
                        :SliverList(
                          delegate:SliverChildBuilderDelegate(
                            (context,index){
                              final log=_allTodaysActivities[index];
                              if(log is WorkoutLog){
                                return WorkoutLogFilling(
                                  log: log,  //ここの右側のlogは上の行の変数
                                  entireWorkout:_logCopy,
                                  onShowRecords:()=>_showPersnalRecord(log.exerciseName),  //ここの右側のlogは上の行の変数
                                  onSetUpdated:_handleUpdated,
                                  onDelete:(){
                                    final updatedLogs=List<WorkoutLog>.from(_logCopy.ListOftodayLog)..remove(log);
                                    _logCopy.ListOftodayLog.remove(log);
                                    _handleUpdated(_logCopy.copyWith(ListOftodayLog: updatedLogs));
                                  },
                                  onShowHistory:(){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:(context)=>ExerciseHistoryScreen(
                                          exerciseName:log.exerciseName,
                                          allWorkoutHistory:widget.allWorkoutHistory,
                                        ),
                                      ),
                                    );
                                  }
                                ); 
                              }else if(log is CardioLog){
                                return CardioLogFilling(
                                  log:log,
                                  entireWorkout:_logCopy,
                                  userWeight:weightForCalc,
                                  onUpdated:_handleUpdated,
                                  onDelete:(){
                                    final updatedLogs=List<CardioLog>.from(_logCopy.cardioLogs)..remove(log);
                                    _handleUpdated(_logCopy.copyWith(cardioLogs: updatedLogs));
                                  },
                                  onShowHistory:(){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:(context)=>CardioHistoryScreen(
                                          cardioType:log.type,
                                          allWorkoutHistory:widget.allWorkoutHistory,
                                        ),
                                      ),
                                    );
                                  },
                                  onShowBest:()=>_showCardioPersonalBest(log.type),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                            childCount: _allTodaysActivities.length,
                          ),
                        ),
                  ],
                ),
              ),     
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child:ElevatedButton.icon(
                  onPressed: ()=>_showBeforeStartWorkout(),
                  label: const Text('トレーニングを追加', style:TextStyle(fontSize:18, color:Colors.white)),
                  icon: const Icon(Icons.add, color:Colors.white),
                  style:ElevatedButton.styleFrom(
                    backgroundColor:Colors.orange.withOpacity(0.9),
                    minimumSize: const Size(250, 50),
                    shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height:42),
            ]
          ),
          floatingActionButton: Visibility(
            visible: _showFab,
            child:SizedBox(
              width: 40,
              height: 40,
              child:FloatingActionButton(
                onPressed:(){
                  _scrollController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                backgroundColor:Colors.orange.withOpacity(0.8),
                child:const Icon(Icons.keyboard_double_arrow_up_sharp, color:Colors.white),
              ),
            ),
          ),
      ),
    );
  }
}