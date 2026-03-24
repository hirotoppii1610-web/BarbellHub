import 'package:flutter/material.dart';
import 'package:muscle_one/model/workout_log.dart';
import 'package:muscle_one/model/workout_set.dart';
import 'package:muscle_one/screens/exercise_select_screen.dart';
import 'package:muscle_one/widget/program_exercise_editor.dart';
import '../model/review_workout.dart';
import '../model/program_day.dart';

class DayDetailScreen extends StatefulWidget{
  final ProgramDay programDay;
  final Map<String,List<String>> exerciseMenu;
  final Function(Map<String,List<String>>) onExerciseMenuUpdated;
  final Function(ProgramDay) onDayUpdated;
  
  DayDetailScreen({
    super.key, 
    required this.programDay,
    required this.exerciseMenu,
    required this.onExerciseMenuUpdated,
    required this.onDayUpdated,
  });

  @override
  State<DayDetailScreen> createState()=> _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen>{
  late ProgramDay _editableProgramDay;

  @override
  void initState(){
    super.initState();
    _editableProgramDay=widget.programDay.copyWith();
  }

  void _saveAndPop(){
    Navigator.pop(context, _editableProgramDay.todayProgram);
  }

  Future<void> _addExercise()async{
    final String selectedExerciseName=await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context)=> ExerciseSelectScreen(
          exerciseMenu:widget.exerciseMenu,
          onExerciseMenuUpdated:widget.onExerciseMenuUpdated,
        ),
      ),
    );

    if(selectedExerciseName!=null){
      setState((){
        _editableProgramDay.todayProgram.add(
          WorkoutLog(exerciseName: selectedExerciseName),
        );
      });
      _notifyParent();
    }
  }

  void _deleteExercise(WorkoutLog logToDelete){
    setState((){
      _editableProgramDay.todayProgram.remove(logToDelete);
    });
    _notifyParent();
  }

  void _notifyParent(){
    widget.onDayUpdated(_editableProgramDay);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor:const Color(0xFF000020),
      appBar: AppBar(
        backgroundColor:Colors.orange.withOpacity(0.9),
        iconTheme:const IconThemeData(color:Colors.white),
        title: 
            Text('${_editableProgramDay.dayName}のトレーニング', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color:Colors.white),),
        leading:IconButton(
          onPressed: ()=>Navigator.pop(context),
          icon:const Icon(Icons.close),
        ),
        actions:[
          TextButton(
            onPressed:_saveAndPop,
            child:const Text('保存', style:TextStyle(color:Colors.white)),
          ),
        ],
      ),
      body:Column(
        children:[
          Expanded(
            child: _editableProgramDay.todayProgram.isEmpty
              ? const Center(
                  child:Text('まだ種目が追加されていません', style:TextStyle(color:Colors.white)),
                )
              : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal:0.0),
                itemCount:_editableProgramDay.todayProgram.length,
                itemBuilder: (context, index){
                  final workoutLog = _editableProgramDay.todayProgram[index];
                  return ProgramExerciseEditor(
                    key:ValueKey(workoutLog.hashCode),
                    workoutLog:workoutLog,
                    onDelete:()=>_deleteExercise(workoutLog),
                    onSetUpdated: _notifyParent,
                  );
                }
              ),
          ),
          Padding(
            padding:const EdgeInsets.all(16.0),
            child:SizedBox(
              width:250,
              child:ElevatedButton.icon(
                onPressed:_addExercise,
                icon:const Icon(Icons.add),
                label:const Text('メニューを追加')
              ),
            ),
          ),
          SizedBox(height: 40,),
        ],
      ),
    );
  }
}