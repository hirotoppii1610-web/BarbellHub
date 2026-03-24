import 'package:flutter/material.dart';
import '../model/cardio_log.dart';

class CardioCard extends StatelessWidget{
  final String headerText;
  final CardioLog log;

  const CardioCard({
    super.key,
    required this.headerText,
    required this.log,
  });

  @override
  Widget build(BuildContext context){
    return Card(
      margin: const EdgeInsets.symmetric(horizontal:32.0, vertical: 8.0),
      child:Padding(
        padding: const EdgeInsets.all(16.0),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize:MainAxisSize.min,
          children:[
            Text(
              headerText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
              overflow:TextOverflow.ellipsis,
            ),
            ListView.builder(
              shrinkWrap:true,
              physics:const NeverScrollableScrollPhysics(),
              itemCount:log.sets.length,
              itemBuilder:(context, index){
                final set=log.sets[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  child:Column(
                    crossAxisAlignment:CrossAxisAlignment.start,
                    mainAxisSize:MainAxisSize.min,
                    children:[
                      const Divider(color:Colors.black),
                      Text('${index+1}セッション目',style:TextStyle(fontSize:16, fontWeight:FontWeight.bold, color:Colors.black87)),
                      const SizedBox(height:16),
                      Text(' 運動強度 : ${set.intensity} '),
                      const SizedBox(height:16),
                      set!=null
                        ? Row(
                          mainAxisAlignment:MainAxisAlignment.center,
                          children:[
                            if(set.distanceInKm !=null)Text(' 距離 : ${set.distanceInKm!} km'),
                            const SizedBox(width:8),
                            if(set.durationInMinutes !=null)Text(' 時間 : ${set.durationInMinutes} 分'),
                            const SizedBox(width:8),
                            if(set.steps !=null)Text(' 歩数 : ${set.steps} 歩'),
                          ],
                        )
                        : const SizedBox(height:1),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}