import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muscle_one/model/cardio_log.dart';
import '../model/review_workout.dart';
import '../widget/cardio_card.dart';

class CardioHistoryScreen extends StatelessWidget{
  final CardioType cardioType;
  final List<ReviewWorkout> allWorkoutHistory;

  static const Map<CardioType,String> _typeDisplayNames={
    CardioType.walking:'ウォーキング',
    CardioType.running:'ランニング',
    CardioType.cycling:'バイク',
    CardioType.swimming:'スイミング',
  };

  const CardioHistoryScreen({
    super.key,
    required this.cardioType,
    required this.allWorkoutHistory,
  });

  @override
  Widget build(BuildContext context){
    final List<Map<String,dynamic>> cardioHistory=[];
    for (var dailyLog in allWorkoutHistory){
      for (var cardioLog in dailyLog.cardioLogs){
        if(cardioLog.type==cardioType){    //この右辺のexerciseNameはclass2行目のやつ
          cardioHistory.add({
            'date':dailyLog.date,
            'log':cardioLog});
        }
      }
    }
    //日付順に並べ替え
    cardioHistory.sort((a,b)=>(b['date'] as DateTime).compareTo(a['date'] as DateTime));
    
    return Scaffold(
      backgroundColor:Color(0xFF000020),
      appBar: AppBar(
        title: Text('${cardioType}の過去記録',style:TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold)),
        backgroundColor:Colors.orange.withOpacity(0.9),
        leading:IconButton(
          onPressed:()=>Navigator.pop(context),
          icon:const Icon(Icons.arrow_back, color:Colors.white),
        ),
      ),
      body:ListView.builder(
        itemCount: cardioHistory.length,
        itemBuilder: (context,index){
          final historyItem=cardioHistory[index];
          final DateTime date=historyItem['date'];
          final cardioRecord=historyItem['log'] as CardioLog;
          final formattedDate=DateFormat('y年 M月d日 (E)', 'ja_JP').format(date);
          return CardioCard(
            headerText:formattedDate,
            log:cardioRecord,
          );
        }
      ),
    );
  }
}