import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muscle_one/model/workout_log.dart';
import '../model/review_workout.dart';

class WorkoutCard extends StatelessWidget{
  final String headerText;
  final WorkoutLog log;

  @override
  const WorkoutCard({
    super.key,
    required this.headerText,
    required this.log,
  });

  @override
  Widget build(BuildContext context){
    return Card(
      margin: const EdgeInsets.symmetric(horizontal:16.0, vertical: 8.0),
      child:Padding(
        padding: const EdgeInsets.all(16.0),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Text(
              headerText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
              overflow:TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            const Divider(color:Colors.black),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width:60,child:Center(child:Text('セット数'),),),
                SizedBox(width:80,child:Center(child:Text('重さ(kg)'),),),
                SizedBox(width:4),
                SizedBox(width:80,child:Center(child:Text('回数'),),),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(right: 4),
                  child:Text('1RM(kg)'),
                ),
              ],
            ),
            const Divider(color:Colors.black),
            ListView.builder(
              shrinkWrap: true,   //Column内でListViewを使うためのお約束の文言
              physics: const NeverScrollableScrollPhysics(),   //Column内でListViewを使うためのお約束の文言2
              itemCount: log.set.length,
              itemBuilder: (context, index){
                final currentSet=log.set[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  child: 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          SizedBox(width:70,child:Center(child:Text('${index+1}'),),),
                          SizedBox(
                            width: 70,
                            child:Center(child:Text(currentSet.weight.toString(),),),
                          ),
                          const SizedBox(width:2),
                          const Text('kg'),
                          SizedBox(
                            width: 70,
                            child:Center(child:Text(currentSet.reps.toString(),),),
                          ),
                          const SizedBox(width:2),
                          const Text('回'),
                          SizedBox(
                            width: 70,
                            child: Center(child: Text(currentSet.estimate1RM.toStringAsFixed(2)),),
                          ),
                        ],
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}