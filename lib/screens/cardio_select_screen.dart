import 'package:flutter/material.dart';
import '../model/cardio_log.dart';

class CardioSelectScreen extends StatelessWidget{
  const CardioSelectScreen({super.key});

  final Map<CardioType,String> _typeDisplayNames = const {
    CardioType.walking:'ウォーキング',
    CardioType.running:'ランニング',
    CardioType.cycling:'バイク',
    CardioType.swimming:'スイミング',
  };

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor:Color(0xFF000020),
      appBar:AppBar(
        title:const Text('有酸素種目選択',style:TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold)),
        backgroundColor: Colors.orange.withOpacity(0.9),
        iconTheme: const IconThemeData(color:Colors.white),
      ),
      body:ListView(
        padding:const EdgeInsets.symmetric(horizontal:16, vertical:4),
        children:CardioType.values.map((type){
          return Padding(
            padding:const EdgeInsets.symmetric(horizontal:16, vertical:4),
            child:Card(
              shape:RoundedRectangleBorder(
                borderRadius:BorderRadius.circular(12.0),
              ),
              clipBehavior:Clip.antiAlias,  //これのよって、中身がはみ出さなくて良くなる。
              child:ListTile(
                shape:const Border(),
                iconColor:Colors.black,
                title:Text(
                  _typeDisplayNames[type]!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onTap:()=>Navigator.pop(context,type),
              ),
            ),
          );
        }).toList(),
      ),
    );  
  }
}