import 'package:flutter/material.dart';
import '../model/history_log.dart';

class HistoryTabView extends StatelessWidget{
  final List<HistoryLog> historyList;    //受け取った履歴データ
  final Function(HistoryLog) onFoodTap;  //タップされたときの処理

  const HistoryTabView({
    super.key,
    required this.historyList,
    required this.onFoodTap,
  });

  @override
  Widget build(BuildContext context){
    if (historyList.isEmpty){
    return const Center(child:Text('履歴がありません', style:TextStyle(color:Colors.white)),);
    }
    return ListView.builder(
      itemCount: historyList.length,
      itemBuilder: (context,index){
        final historyFood=historyList[index];
        final food=historyFood.foodLog.foodItem;
        
        return ListTile(
          title: Text(food.name, style:const TextStyle(color:Colors.white)),
          subtitle: Text('${food.calories.toStringAsFixed(0)}kcal', style:const TextStyle(color:Colors.white70)),
          onTap: () => onFoodTap(historyFood),
        );
      }
    );
  }
}