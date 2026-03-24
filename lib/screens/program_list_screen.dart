import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:muscle_one/screens/program_creation_screen.dart';
import 'package:muscle_one/screens/day_detail_screen.dart';
import '../model/workout_program.dart';
import '../model/program_week.dart';
import '../model/program_day.dart';

class ProgramListScreen extends StatefulWidget{
  final List<WorkoutProgram> allPrograms;
  final Map<String,List<String>> exerciseMenu;
  final Function(List<WorkoutProgram>) onProgramsUpdated;
  final Function(Map<String,List<String>>) onExerciseMenuUpdated;
  final bool isForSelection;

  const ProgramListScreen({
    super.key,
    required this.allPrograms,
    required this.exerciseMenu,
    required this.onProgramsUpdated,
    required this.onExerciseMenuUpdated,
    this.isForSelection = false,
  });
  
  @override
  State<ProgramListScreen> createState() => _ProgramListScreenState();
}

class _ProgramListScreenState extends State<ProgramListScreen> {
  late List<WorkoutProgram> _programs;

  @override
  void initState() {
    super.initState();
    _programs=List.of(widget.allPrograms);
  }

  @override
  void didUpdateWidget(ProgramListScreen oldWidget){
    super.didUpdateWidget(oldWidget);
    if(widget.allPrograms != oldWidget.allPrograms){
      setState((){
        _programs=widget.allPrograms;
      });
    }
  }

  void _showDeleteConfirmDialog(WorkoutProgram programToDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除の確認'),
        content: Text('「${programToDelete.programName}」を本当に削除しますか？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
          TextButton(
            onPressed: () {
              setState(() {
                _programs.removeWhere((p) => p.id == programToDelete.id);
              });
              widget.onProgramsUpdated(_programs);
              Navigator.pop(context); 
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToCreationScreen({WorkoutProgram? existingProgram})async{
    bool isNew = existingProgram == null;
    WorkoutProgram programToEdit;

    if(isNew){
      programToEdit=WorkoutProgram(
        id: const Uuid().v4(),
        programName: '新規プログラム',
      );
      setState((){
        _programs.add(programToEdit);
      });
      widget.onProgramsUpdated(_programs);
    }else{
      programToEdit = existingProgram!;
    }

    final result= await Navigator.push(
      context,
      MaterialPageRoute(
        builder:(context)=>ProgramCreationScreen(
          existingProgram:programToEdit,
          exerciseMenu:widget.exerciseMenu,
          onExerciseMenuUpdated:widget.onExerciseMenuUpdated,
          onProgramUpdated: (updatedProgram){
            setState((){
              final index=_programs.indexWhere((p) => p.id == updatedProgram.id);
              if(index !=-1){
                _programs[index]=updatedProgram;
              }
            });
            widget.onProgramsUpdated(_programs);
          }
        )
      )
    );


    if(result is WorkoutProgram){
      //保存で戻ってきた場合
      setState((){
        final index=_programs.indexWhere((p) => p.id == result.id);
        if(index != -1){
          _programs[index]=result;
        }
      });
      widget.onProgramsUpdated(_programs);
    }else if(isNew){
      //キャンセルかつ、新規作成の場合、
      setState((){
        _programs.removeWhere((p) => p.id == programToEdit.id);
      });
      widget.onProgramsUpdated(_programs);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(0xFF000020),
      appBar: AppBar(
        title: Text(
          widget.isForSelection ? 'プログラムを選択'  :'マイプログラム一覧',
          style:const TextStyle(fontSize:18, fontWeight:FontWeight.bold, color:Colors.white)),
        backgroundColor: Colors.orange.withOpacity(0.9),
        iconTheme:const IconThemeData(color:Colors.white),
        leading:IconButton(
          onPressed: ()=>Navigator.pop(context),
          icon:const Icon(Icons.arrow_back),
        ),
      ),
      body: _programs.isEmpty
          ? const Center(child: Text('保存されているプログラムはありません。',style:TextStyle(fontSize:18, color:Colors.white70)))
          : ListView.builder(
              itemCount: _programs.length,
              itemBuilder: (context, index) {
                final program = _programs[index];
                return Padding(
                  padding:const EdgeInsets.symmetric(vertical:8.0),
                  child:Card(
                    shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12.0)),
                    clipBehavior:Clip.antiAlias,
                    child: ExpansionTile(
                      shape:const Border(),
                      collapsedShape:const Border(),
                      collapsedIconColor:Colors.black,
                      trailing: const SizedBox.shrink(),
                      title: Row(
                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                        children:[
                          Expanded(
                            child:Text(
                              program.programName,
                              style:const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              overflow:TextOverflow.ellipsis,
                            ),
                          ),
                          //編集削除ボタンを右端に配置
                          Row(
                            children:[
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _navigateToCreationScreen(existingProgram: program),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: (){
                                  _showDeleteConfirmDialog(program);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      subtitle: Text(
                        program.isWeekBased
                          ? '${program.wholeProgram.length}週間のプログラム'
                          : '${program.days.length}日間のプログラム'
                      ),
                      children: program.isWeekBased
                          ? program.wholeProgram.map((week){
                            return ExpansionTile(
                              tilePadding: const EdgeInsets.only(left:32, right:16),
                              collapsedShape:const Border(),
                              collapsedIconColor:Colors.black,
                              title: Text(week.weekName),
                              children: week.weeklyProgramDays.map((day){
                                return ListTile(
                                  contentPadding:const EdgeInsets.only(left:48),
                                  title:Text(day.dayName),
                                  onTap:(){
                                    if(widget.isForSelection){
                                      Navigator.pop(context,day);
                                    }else{
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:(context)=>DayDetailScreen(
                                            programDay:day,
                                            exerciseMenu:widget.exerciseMenu,
                                            onExerciseMenuUpdated:widget.onExerciseMenuUpdated,
                                            onDayUpdated:(updatedDay){                            //navigator.pushで保存の関数を渡しているため、即時保存ができる。
                                              setState((){
                                                final dayIndex=week.weeklyProgramDays.indexWhere((d)=> d.id==updatedDay.id);
                                                if(dayIndex!=-1){
                                                  week.weeklyProgramDays[dayIndex]=updatedDay;
                                                }
                                              });
                                              widget.onProgramsUpdated(_programs);
                                            }
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                );
                              }).toList(),
                            );
                          }).toList()
                          : program.days.map((day){
                            return ListTile(
                              contentPadding:const EdgeInsets.only(left:32),
                              title:Text(day.dayName),
                              onTap:(){
                                if(widget.isForSelection){
                                  Navigator.pop(context, day);
                                }else{
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:(context)=>DayDetailScreen(
                                        programDay:day,
                                        exerciseMenu:widget.exerciseMenu,
                                        onExerciseMenuUpdated:widget.onExerciseMenuUpdated,
                                        onDayUpdated:(updatedDay){                            //navigator.pushで保存の関数を渡しているため、即時保存ができる。
                                          setState((){
                                            final dayIndex=program.days.indexWhere((d)=> d.id==updatedDay.id);
                                            if(dayIndex!=-1){
                                              program.days[dayIndex]=updatedDay;
                                            }
                                          });
                                          widget.onProgramsUpdated(_programs);
                                        }
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          }).toList(),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreationScreen(),
        backgroundColor: Colors.orange.withOpacity(0.9),
        child: const Icon(Icons.add, color:Colors.white),
      ),
    );
  }
}