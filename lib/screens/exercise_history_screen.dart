import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muscle_one/model/workout_log.dart';
import '../model/review_workout.dart';
import '../widget/workout_card.dart';

class ExerciseHistoryScreen extends StatelessWidget{
  final String exerciseName;
  final List<ReviewWorkout> allWorkoutHistory;

  const ExerciseHistoryScreen({
    super.key,
    required this.exerciseName,
    required this.allWorkoutHistory,
  });

  @override
  Widget build(BuildContext context){
    final List<Map<String,dynamic>> exerciseHistory=[];
    for (var dailyLog in allWorkoutHistory){
      for (var workoutLog in dailyLog.ListOftodayLog){
        if(workoutLog.exerciseName==exerciseName){    //この右辺のexerciseNameはclass2行目のやつ
          exerciseHistory.add({
            'date':dailyLog.date,
            'log':workoutLog});
        }
      }
    }
    //日付順に並べ替え
    exerciseHistory.sort((a,b)=>(b['date'] as DateTime).compareTo(a['date'] as DateTime));
    
    return Scaffold(
      backgroundColor:Color(0xFF000020),
      appBar: AppBar(
        title: Text('${exerciseName}の過去記録',style:TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold)),
        backgroundColor:Colors.orange.withOpacity(0.9),
      ),
      body:ListView.builder(
        itemCount: exerciseHistory.length,
        itemBuilder: (context,index){
          final historyItem=exerciseHistory[index];
          final DateTime date=historyItem['date'];
          final workoutRecord=historyItem['log'] as WorkoutLog;
          final formattedDate=DateFormat('y年 M月d日 (E)', 'ja_JP').format(date);
          return WorkoutCard(
            headerText:formattedDate,
            log:workoutRecord,
          );
        }
      ),
    );
  }
}