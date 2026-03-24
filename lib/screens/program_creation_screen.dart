import 'package:flutter/material.dart';
import 'package:muscle_one/model/workout_log.dart';
import 'package:uuid/uuid.dart';
import '../model/workout_program.dart';
import '../model/program_week.dart';
import '../model/program_day.dart';
import 'day_detail_screen.dart';

class ProgramCreationScreen extends StatefulWidget{
  final WorkoutProgram existingProgram;
  final Map<String,List<String>> exerciseMenu;
  final Function(Map<String,List<String>>) onExerciseMenuUpdated;
  final Function(WorkoutProgram) onProgramUpdated;

  const ProgramCreationScreen({
    super.key, 
    required this.existingProgram,
    required this.exerciseMenu,
    required this.onExerciseMenuUpdated,
    required this.onProgramUpdated,
  });

  @override
  State<ProgramCreationScreen> createState()=>_ProgramCreationScreenState();
}

class _ProgramCreationScreenState extends State<ProgramCreationScreen>{
  final TextEditingController nameController=TextEditingController();
  late WorkoutProgram _program;
  bool  _isModelSelected=false;  //週の有無が指定されているかどうかのチェッカー

  @override
  void initState(){
    super.initState();
    _program=widget.existingProgram.copyWith();
    if(_program.programName != '新規プログラム'){
      _isModelSelected=true;
    }else{
      nameController.text='';   //新規作成の場合は、名称を'新規プログラム'から、''(空)に変更する。
    }
    //この操作で、新規プログラムの場合は週の選択がまだ、というようなロジックに変更
    if(_isModelSelected){
      nameController.text=_program.programName;
    }
  }

  void _notifyParentAndSave(){
    _program.programName= nameController.text;
    widget.onProgramUpdated(_program);
  }

  void _showWeekCreationDialog(){
    showDialog(
      context:context,
      builder:(context)=>AlertDialog(
        backgroundColor:const Color(0xFF1e3a5f),
        title:const Text('プログラムの形式', style:TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold)),
        content:const Text('複数週にわたるプログラムを作成しますか？\nまたは、曜日や部位のみで管理しますか？', style:TextStyle(color:Colors.white)),
        actions:[
          TextButton(
            onPressed:(){
              Navigator.pop(context);
              _addWeek();
            },
            child:const Text('複数週のプログラム',style:TextStyle(color:Colors.white)),
          ),
          TextButton(
            onPressed:(){
              setState((){
                _program.isWeekBased=false;
                _isModelSelected=true;
              });
              _notifyParentAndSave();
              Navigator.pop(context);
            },
            child:const Text('週なしで作成', style:TextStyle(color:Colors.white)),
          ),
        ],
      ),
    );
  }

  void _addWeek(){
    final TextEditingController weekNameController=TextEditingController();
    showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        backgroundColor: const Color(0xFF1e3a5f),
        title: const Text('新しい週を追加', style:TextStyle(color:Colors.white)),
        content: TextField(
          controller: weekNameController,
          autofocus: true,
          style:const TextStyle(color:Colors.white),
          decoration: InputDecoration(hintText: '例:Week1',hintStyle:TextStyle(color:Colors.white30)),
        ),
        actions: [
          TextButton(
            onPressed: ()=>Navigator.pop(context),
            child: const Text('キャンセル', style:TextStyle(color:Colors.white)),
          ),
          TextButton(
            onPressed: (){
              if (weekNameController.text.isNotEmpty){
                setState(() {
                  _program.isWeekBased=true;
                  _isModelSelected=true;
                  _program.wholeProgram.add(ProgramWeek(weekName: weekNameController.text));
                });
                _notifyParentAndSave();
              }
              Navigator.pop(context);
            },
            child: const Text('追加', style:TextStyle(color:Colors.white)),
          ),
        ],
      )
    );
  }

  void _addDayDirectly(){
    final TextEditingController dayNameController=TextEditingController();
    showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        backgroundColor:const Color(0xFF1e3a5f),
        title: Text('新しくDayを追加',style:TextStyle(color:Colors.white)),
        content: TextField(
          controller: dayNameController,
          autofocus: true,
          style:const TextStyle(color:Colors.white),
          decoration: const InputDecoration(hintText: '例:胸の日',hintStyle:TextStyle(color:Colors.white30)),
        ),
        actions: [
          TextButton(
            onPressed: ()=>Navigator.pop(context),
            child: const Text('キャンセル',style:TextStyle(color:Colors.white)),
          ),
          TextButton(
            onPressed: (){
              if (dayNameController.text.isNotEmpty){
                setState(() {
                  _program.days.add(ProgramDay(dayName: dayNameController.text));
                });
                _notifyParentAndSave();
              }
              Navigator.pop(context);
            },
            child: const Text('追加',style:TextStyle(color:Colors.white)),
          ),
        ],
      )
    );
  }

  void _addDay(ProgramWeek week){
    final TextEditingController dayNameController=TextEditingController();
    showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        backgroundColor:const Color(0xFF1e3a5f),
        title: Text('${week.weekName}に新しくDayを追加',style:TextStyle(color:Colors.white)),
        content: TextField(
          controller: dayNameController,
          autofocus: true,
          style:const TextStyle(color:Colors.white),
          decoration: const InputDecoration(hintText: '例:胸の日',hintStyle:TextStyle(color:Colors.white30)),
        ),
        actions: [
          TextButton(
            onPressed: ()=>Navigator.pop(context),
            child: const Text('キャンセル',style:TextStyle(color:Colors.white)),
          ),
          TextButton(
            onPressed: (){
              if (dayNameController.text.isNotEmpty){
                setState(() {
                  week.weeklyProgramDays.add(ProgramDay(dayName: dayNameController.text));
                });
                _notifyParentAndSave();
              }
              Navigator.pop(context);
            },
            child: const Text('追加',style:TextStyle(color:Colors.white)),
          ),
        ],
      )
    );
  }


  void _saveProgramAndPop()async{
    if(nameController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('プログラム名を入力してください。'),backgroundColor:Colors.redAccent),
      );
      return;
    }
    _program.programName=nameController.text;
    Navigator.pop(context, _program);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor:Color(0xFF000020),
      appBar: AppBar(
        title: Text(
          widget.existingProgram.programName.isEmpty || widget.existingProgram.programName == '新規プログラム' 
            ? 'プログラム新規作成' : 'プログラム編集',
          style: const TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange.withOpacity(0.9),
        leading:IconButton(
          icon:const Icon(Icons.arrow_back, color:Colors.white),
          onPressed: ()=>Navigator.pop(context),
        ),
        actions:[
          TextButton(
            onPressed:_saveProgramAndPop,
            child:const Text('保存', style:TextStyle(color:Colors.white)),
          ),
        ],
      ),
      body:Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Focus(
              onFocusChange: (hasFocus){
                if(!hasFocus){
                  _notifyParentAndSave();
                }
              },
              child:TextField(
                controller: nameController,
                style:const TextStyle(color:Colors.white),
                decoration: const InputDecoration(
                  labelText: 'プログラム名',
                  labelStyle: TextStyle(color:Colors.white70),
                  enabledBorder:OutlineInputBorder(borderSide:BorderSide(color:Colors.white24)),
                  focusedBorder:OutlineInputBorder(borderSide:BorderSide(color:Colors.white)),
                ),
              ),
            ),
            const SizedBox(height:20),
            //まだプログラムの分岐が決まっていない場合
            if(!_isModelSelected)
              SizedBox(
                width:double.infinity,
                child:ElevatedButton.icon(
                  onPressed:_showWeekCreationDialog,
                  icon:const Icon(Icons.lan_outlined),
                  label:const Text('プログラムの形式を選択'),
                ),
              ),
            //形式が選択された後
            if(_isModelSelected)
              Expanded(
                child:_program.isWeekBased
                          ? _buildWeekBasedUI()
                          : _buildDayOnlyUI(),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToDayDetail(ProgramDay day)async{
    final updatedExercises= await Navigator.push(
      context,
      MaterialPageRoute(
        builder:(context)=>DayDetailScreen(
          programDay: day.copyWith(),
          exerciseMenu:widget.exerciseMenu,
          onExerciseMenuUpdated:widget.onExerciseMenuUpdated,
          onDayUpdated:(updatedDay){                            //navigator.pushで保存の関数を渡しているため、即時保存ができる。
            setState((){
              day.dayName= updatedDay.dayName;
              day.todayProgram= updatedDay.todayProgram;
            });
            _notifyParentAndSave();
          }
        ),
      ),
    );

    if(updatedExercises != null){                                //navigator.pushの戻り値でも保存を行う。
      setState((){
        day.todayProgram= updatedExercises;
      });
      _notifyParentAndSave();
    }
  }

  Widget _buildWeekBasedUI(){
    return Expanded(
      child:Column(
        children:[
          SizedBox(
            width: double.infinity,
            child:ElevatedButton.icon(
              onPressed: _addWeek,
              icon:const Icon(Icons.add),
              label:const  Text('週を追加'),
            ),
          ),
          const Divider(color:Colors.white24, height:32),
          Expanded(
            child: ListView.builder(
              itemCount: _program.wholeProgram.length,
              itemBuilder: (context,index){
                final week=_program.wholeProgram[index];
                return Card(
                  elevation:0,
                  color:Colors.transparent,
                  shape:RoundedRectangleBorder(
                    borderRadius:BorderRadius.circular(12.0),
                    side:const BorderSide(color:Colors.white70, width:1.0),
                  ),
                  child: ExpansionTile(
                    collapsedIconColor:Colors.white,
                    iconColor:Colors.white,
                    title: Text(week.weekName,style: const TextStyle(fontWeight: FontWeight.bold, color:Colors.white),),
                    children: [
                      for (final day in week.weeklyProgramDays)
                        ListTile(
                          title: Text(day.dayName,style:TextStyle(color:Colors.white)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: ()=>_navigateToDayDetail(day),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child:TextButton.icon(
                            onPressed: ()=>_addDay(week), 
                            label: const Text('Dayを追加'),
                            icon:Icon(Icons.add),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ]
      )
    );
  }

  Widget _buildDayOnlyUI(){
    return Expanded(
      child:Column(
        children:[
          SizedBox(
            width: double.infinity,
            child:ElevatedButton.icon(
              onPressed: _addDayDirectly,
              icon:const Icon(Icons.add),
              label:const  Text('Dayを追加'),
            ),
          ),
          const Divider(color:Colors.white24, height:32),
          Expanded(
            child:ListView.builder(
              itemCount: _program.days.length,
              itemBuilder: (context,index){
                final day=_program.days[index];
                return Card(
                  elevation:0,
                  color:Colors.transparent,
                  shape:RoundedRectangleBorder(
                    borderRadius:BorderRadius.circular(12.0),
                    side:const BorderSide(color:Colors.white70, width:1.0),
                  ),
                  child: ListTile(
                    title:Text(day.dayName, style:const TextStyle(color:Colors.white)),
                    trailing:const Icon(Icons.chevron_right, color:Colors.white70),
                    onTap:()=>_navigateToDayDetail(day),
                  )
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}