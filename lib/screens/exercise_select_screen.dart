import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';


class ExerciseSelectScreen extends StatefulWidget{
  final Map<String,List<String>> exerciseMenu;
  final Function(Map<String,List<String>>) onExerciseMenuUpdated;

  const ExerciseSelectScreen({
    super.key,
    required this.exerciseMenu,
    required this.onExerciseMenuUpdated,
  });

  @override
  State<ExerciseSelectScreen> createState() => _ExerciseSelectScreenState();
}

class _ExerciseSelectScreenState extends State<ExerciseSelectScreen>{
  late Map<String, List<String>> _exerciseMenu;

  @override
  void initState(){
    super.initState();
    _exerciseMenu= widget.exerciseMenu.map((key,value) => MapEntry(key, List.of(value)));   //これでコピーを作成。
  }

  void _addExerciseName(String part){
    final TextEditingController exerciseNameController=TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext build){
        return AlertDialog(
          title: Text('${part}に種目を追加'),
          content:TextField(
            controller: exerciseNameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            Row(
              children:[
                TextButton(
                  onPressed: () =>Navigator.pop(context),
                  child: const Text('キャンセル'),
                ),
                TextButton(
                  onPressed: (){
                    final newMenu=exerciseNameController.text;
                    if(newMenu.isNotEmpty){
                      setState((){
                        _exerciseMenu[part]?.add(newMenu);
                      });
                      widget.onExerciseMenuUpdated(_exerciseMenu);
                    }      
                    Navigator.pop(context);
                  },
                  child: const Text('種目を追加'),
                ),
              ],
            ),
          ],
        );
      }
    );
  }

  void _showEditingConfirmDialog(
    BuildContext parentContext, String part, String oldName){
      final TextEditingController exerciseNameController=TextEditingController(text:oldName);
      showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            backgroundColor:Color(0xFF1e3a5f),
            title: const Text('名称の変更', style:TextStyle(color:Colors.white)),
            content:TextField(
              controller: exerciseNameController, 
              autofocus: true,
              style:const TextStyle(color:Colors.white),
              decoration:const InputDecoration(
                enabledBorder:UnderlineInputBorder(borderSide:BorderSide(color:Colors.white)),
                focusedBorder:UnderlineInputBorder(borderSide:BorderSide(color:Colors.white)),
              ),
            ),
            actions:[
              TextButton(
                child: const Text('キャンセル',style:TextStyle(color:Colors.white70)),
                onPressed:(){
                  Navigator.pop(context);
                }
              ),
              TextButton(
                onPressed: (){
                  final newName=exerciseNameController.text;
                  if(newName.isNotEmpty && newName != oldName){
                    setState(() {
                      final list=_exerciseMenu[part]!;
                      final index=list.indexOf(oldName);
                      if(index !=-1){
                        list[index]=newName;
                      }
                    });
                    widget.onExerciseMenuUpdated(_exerciseMenu);
                  }
                  Navigator.pop(context);
                }, 
                child: Text('更新'))
            ]
          );
        }
      );
    }

  void _showDeleteConfirmDialog(
    BuildContext parentContext, String part, String exerciseName){
      showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: const Text('確認',style:TextStyle(color:Colors.white)),
            content:Text('${exerciseName}を本当に削除しますか？',style:const TextStyle(color:Colors.white70)),
            actions:[
              TextButton(
                child: Text('キャンセル',style:TextStyle(color:Colors.white70)),
                onPressed:(){
                  Navigator.pop(context);
                }
              ),
              TextButton(
                onPressed: (){
                  setState(() {
                    _exerciseMenu[part]?.remove(exerciseName);
                  });
                  widget.onExerciseMenuUpdated(_exerciseMenu);
                  Navigator.pop(context);
                }, 
                child: Text('削除',style:TextStyle(color:Colors.white))
              ),
            ]
          );
        }
      );
}
  


  @override
  Widget build(BuildContext context) {

    final bodyParts=_exerciseMenu.keys.toList();  //部位だけをリスト化

    return Scaffold(
      backgroundColor:Color(0xFF000020),
      appBar:AppBar(
        title:const Text('種目選択',style:TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold)),
        backgroundColor: Colors.orange.withOpacity(0.9),
        iconTheme: const IconThemeData(color:Colors.white),
      ),
      body:ListView.builder(
        itemCount: bodyParts.length,
        itemBuilder: (context, index){
          final part=bodyParts[index];  //部位を変数partで表す
          final exercises=_exerciseMenu[part]!;  //各部位のメニュー全体を変数exercisesで表す。
          //→indexが変わる→それに基づく部位のメニューも変化
          return Padding(
            padding:EdgeInsets.symmetric(horizontal:16, vertical:4),
            child:Card(
              shape:RoundedRectangleBorder(
                borderRadius:BorderRadius.circular(12.0),
              ),
              clipBehavior:Clip.antiAlias,  //これのよって、中身がはみ出さなくて良くなる。
              child:ExpansionTile(
                shape:const Border(),
                collapsedShape:const Border(),
                collapsedIconColor: Colors.black,
                iconColor:Colors.black,
                title:Row( 
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    Text(
                        part,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: (){
                             _addExerciseName(part);
                          },
                          icon: Icon(Icons.add_circle_outline,color: Colors.green[300],)
                        ),
                        //IconButton(
                          //onPressed: (){
                            //_editExerciseName(part);
                          //},
                          //icon: Icon(Icons.edit_note_outlined, color: Colors.blueGrey),)
                      ],
                    ),
                  ]
                ),
                children:exercises.map((exerciseName){  
                    //ここでのexerciseNameは変数で、exercise内の変数の代わり→種目名のindexとしてふるまう
                  return Slidable(
                    key:ValueKey(part + exerciseName),
                    endActionPane:ActionPane(
                      motion: const StretchMotion(),
                      children:[
                        SlidableAction(
                          onPressed:(context) => _showEditingConfirmDialog(context,part,exerciseName),
                          backgroundColor:Colors.grey,
                          foregroundColor:Colors.orange.withOpacity(0.9),
                          icon:Icons.edit_note_outlined,
                        ),
                        SlidableAction(
                          onPressed:(context) => _showDeleteConfirmDialog(context,part, exerciseName),
                          backgroundColor:Colors.red.withOpacity(0.9),
                          foregroundColor:Colors.white,
                          icon:Icons.delete_outlined,
                        )
                      ],
                    ),
                    child:Column(
                      children:[
                        ListTile(
                          title: Text(exerciseName),
                          onTap: (){
                            print('${exerciseName}が選択されました。');
                            Navigator.pop(context, exerciseName);
                          },
                        ),
                        if (exercises.last != exerciseName)const Divider(),
                      ]
                    )
                  );
                }).toList(),
              ),
            ),
          );
        }
      ),
    );  
  }
}