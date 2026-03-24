import 'package:flutter/material.dart';
import 'package:muscle_one/model/workout_log.dart';
import 'package:muscle_one/model/workout_set.dart';

class ProgramExerciseEditor extends StatefulWidget{
  final WorkoutLog workoutLog;
  final VoidCallback onDelete;
  final VoidCallback onSetUpdated;

  const ProgramExerciseEditor({
    super.key, 
    required this.workoutLog,
    required this.onDelete,
    required this.onSetUpdated,
  });
  
  @override
  State<ProgramExerciseEditor> createState() => _ProgramExerciseEditorState();
}

class _ProgramExerciseEditorState extends State<ProgramExerciseEditor>{

  late List<TextEditingController> _weightController;
  late List<TextEditingController> _repsController;
  //focusを監視するメソッド
  late List<FocusNode> _weightFocusNodes;
  late List<FocusNode> _repsFocusNodes;

  void _addSet(){
    setState(() {
      widget.workoutLog.set.add(WorkoutSet());
    });
    widget.onSetUpdated();
  }

  void _removeSet(){
    if (widget.workoutLog.set.length >1){
      setState(() {
        widget.workoutLog.set.removeLast();
      });
      widget.onSetUpdated();
    }
  }

  @override
  void initState(){
    super.initState();
    _initializeControllersAndFocusNodes();
  }

  void _initializeControllersAndFocusNodes(){
    _weightController=widget.workoutLog.set.map(
      (s)=>TextEditingController(
        text: s.weight== 0 ? '' :s.weight.toString())
    ).toList();
    _repsController=widget.workoutLog.set.map(
      (s)=>TextEditingController(
        text: s.reps== 0 ? '' :s.reps.toString())
    ).toList();
   for(var c in _weightController){
    c.addListener(_onControllerChanged);
   }
   for(var c in _repsController){
    c.addListener(_onControllerChanged);
   }
   _weightFocusNodes=List.generate(widget.workoutLog.set.length, (index)=>FocusNode());
   _repsFocusNodes=List.generate(widget.workoutLog.set.length, (index)=>FocusNode());
  }

  @override
  void didUpdateWidget(covariant ProgramExerciseEditor oldWidget){
    super.didUpdateWidget(oldWidget);
    if(widget.workoutLog.set.length != oldWidget.workoutLog.set.length){
        _disposeControllersAndFocusNodes(isDisposing:false);
        _initializeControllersAndFocusNodes();
    }
  }

  void _updateSetData(){
    for(int i=0; i<widget.workoutLog.set.length; i++){
      widget.workoutLog.set[i].weight=double.tryParse(_weightController[i].text) ?? 0;
      widget.workoutLog.set[i].reps=int.tryParse(_repsController[i].text) ?? 0;
      widget.onSetUpdated();
    }
  }

  void _disposeControllersAndFocusNodes({bool isDisposing = true}){
    for(var controller in _weightController){
      controller.removeListener(_onControllerChanged);
      controller.dispose();
    }
    for(var controller in _repsController){
      controller.removeListener(_onControllerChanged);
      controller.dispose();
    }
    for(var node in _weightFocusNodes){
        node.dispose();
    }
    for(var node in _repsFocusNodes){
        node.dispose();
    }
  }

  void _onControllerChanged(){
    _updateSetData();
    setState(() {});
    widget.onSetUpdated();
  }

  @override
  void dispose(){
    _disposeControllersAndFocusNodes();
    super.dispose();
  }


  @override
  Widget build(BuildContext context){
    return Card(
      //color:const Color(0xFF1e3a5f),
      margin: const EdgeInsets.symmetric(horizontal:16.0, vertical: 8.0),
      child:Padding(
        padding: const EdgeInsets.all(16.0),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child:Text(
                    widget.workoutLog.exerciseName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                    overflow:TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon:const Icon(Icons.delete),
                  onPressed:widget.onDelete,
                )
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color:Colors.black),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width:60,child:Center(child:Text('セット数'),),),
                SizedBox(width:90,child:Center(child:Text('重さ'),),),
                SizedBox(width:4),
                SizedBox(width:80,child:Center(child:Text('回数'),),),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(right:4),
                  child:Text('1RM(kg)'),
                ),
              ],
            ),
            const Divider(color:Colors.black),
            ListView.builder(
              shrinkWrap: true,   //Column内でListViewを使うためのお約束の文言
              physics: const NeverScrollableScrollPhysics(),   //Column内でListViewを使うためのお約束の文言2
              itemCount: widget.workoutLog.set.length,
              itemBuilder: (context, index){
                final currentSet=widget.workoutLog.set[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  child: 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          SizedBox(width:70,child:Center(child:Text('${index+1}'),),),
                          SizedBox(
                            width: 60,
                            child:_buildTextField(_weightController[index],_weightFocusNodes[index])
                          ),
                          const SizedBox(width:2),
                          const Text('kg'),
                          SizedBox(
                            width: 60,
                            child:_buildTextField(_repsController[index],_repsFocusNodes[index]),
                          ),
                          const SizedBox(width:2),
                          const Text('回'),
                          SizedBox(
                            width:40,
                            child:_buildCopyButton(index),
                          ),
                          SizedBox(
                            width: 60,
                            child: Center(child: Text(currentSet.estimate1RM.toStringAsFixed(2)),),
                          ),
                        ],
                  ),
                );
              }
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _removeSet,
                  icon: const Icon(Icons.remove_circle_outline,),
                ),
                IconButton(
                  onPressed: _addSet,
                  icon: const Icon(Icons.add_circle_outline,),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller,FocusNode focusNode){
    return TextFormField(
      controller:controller,
      focusNode:focusNode,
      textAlign:TextAlign.center,
      style:const TextStyle(),
      keyboardType: const TextInputType.numberWithOptions(decimal:true),
      decoration:InputDecoration(
        isDense:true,
        contentPadding: const EdgeInsets.symmetric(vertical:8.0),
        //focusedBorder: UnderlineInputBorder(borderSide:BorderSide(color:Colors.white24)),
      ),
    );
  }

  Widget _buildCopyButton(int index){
    bool isLastSet = index == widget.workoutLog.set.length-1 ;
    if(isLastSet){
      return const SizedBox.shrink();
    }
    return IconButton(
      icon:const Icon(Icons.keyboard_double_arrow_down_sharp),
      onPressed:(){
        _onControllerChanged();
        setState((){
          //2.今のセットデータを次セットのデータにコピーして入力
          widget.workoutLog.set[index+1]=widget.workoutLog.set[index].copyWith();
          //3.次のセットの入力欄も更新
          _weightController[index+1].text=_weightController[index].text;
          _repsController[index+1].text=_repsController[index].text;
          //以上のデータの更新、UIの更新セットで行わなければ、バグの原因となる。
        });
        widget.onSetUpdated();
      }
    );
  }
}