import 'package:flutter/material.dart';
import 'package:muscle_one/model/workout_log.dart';
import 'package:muscle_one/model/workout_set.dart';
import 'package:muscle_one/model/review_workout.dart';

class WorkoutLogFilling extends StatefulWidget{
  final WorkoutLog log;
  final ReviewWorkout entireWorkout;
  final VoidCallback onShowRecords;   //こいつは自己ベストの情報
  final Function(ReviewWorkout) onSetUpdated;
  final VoidCallback onDelete;
  final VoidCallback onShowHistory;

  const WorkoutLogFilling({
    super.key, 
    required this.log,
    required this.entireWorkout,
    required this.onShowRecords,
    required this.onSetUpdated,
    required this.onDelete,
    required this.onShowHistory,
  });
  
  @override
  State<WorkoutLogFilling> createState() => _WorkoutLogFillingState();
}

class _WorkoutLogFillingState extends State<WorkoutLogFilling>{

  late List<TextEditingController> _weightController;
  late List<TextEditingController> _repsController;
  //focusを監視するメソッド
  late List<FocusNode> _weightFocusNodes;
  late List<FocusNode> _repsFocusNodes;

  late TextEditingController _memoController;
  bool _isMemoVisible=false;

  void _addset(){
    setState(() {
      widget.log.set.add(WorkoutSet());
      _initializeControllersAndFocusNodes();
    });
    WidgetsBinding.instance.addPostFrameCallback((_){
      FocusScope.of(context).requestFocus(_weightFocusNodes.last);
    });
  }

  void _removeset(){
    if (widget.log.set.length >1){
      setState(() {
        widget.log.set.removeLast();
        _initializeControllersAndFocusNodes();
      });
    }
  }

  @override
  void initState(){
    super.initState();
    _initializeControllersAndFocusNodes();
    _memoController=TextEditingController(text: widget.log.memo ?? '');
    if(widget.log.memo != null && widget.log.memo!.isNotEmpty){
      _isMemoVisible=true;
    }
    _memoController.addListener(_onMemoChanged);
  }

  @override
  void didUpdateWidget(covariant WorkoutLogFilling oldWidget){
    super.didUpdateWidget(oldWidget);
    if(widget.log.set.length != oldWidget.log.set.length){
      _disposeControllersAndNodes(isDisposing: false);
      _initializeControllersAndFocusNodes();
    }
  }

  void _initializeControllersAndFocusNodes(){
    _weightController=widget.log.set.map(
      (s)=>TextEditingController(
        text: s.weight== 0 ? '' :s.weight.toString())
    ).toList();
    _repsController=widget.log.set.map(
      (s)=>TextEditingController(
        text: s.reps== 0 ? '' :s.reps.toString())
    ).toList();

    //コントローラーにリスナーをセットして、即時保存ができるように
    for (var c in _weightController){ c.addListener(_onControllerChanged); }
    for (var c in _repsController){ c.addListener(_onControllerChanged); }

    //focusNodeをリセットして、リスナーをセット
    _weightFocusNodes=List.generate(widget.log.set.length, (index)=>FocusNode());
    _repsFocusNodes=List.generate(widget.log.set.length, (index)=>FocusNode());
  }

  void _onControllerChanged(){
    setState((){});
    _updateSetData();
  }

  void _onMemoChanged(){
    final newMemo=_memoController.text;
    if(widget.log.memo!=newMemo){
      final updatedLogData=widget.log.copyWith(memo: newMemo);
      _notifyParent(updatedLogData);
    }
  }

  void _notifyParent(WorkoutLog updatedLog){
    final logIndex=widget.entireWorkout.ListOftodayLog.indexWhere((l)=> l.id==widget.log.id);
      if(logIndex!=-1){
        final updatedWorkoutLogs=List<WorkoutLog>.from(widget.entireWorkout.ListOftodayLog);
        updatedWorkoutLogs[logIndex]=updatedLog;
        final updatedWorkouts=widget.entireWorkout.copyWith(ListOftodayLog:updatedWorkoutLogs);
        widget.onSetUpdated(updatedWorkouts);
      }
  }

  void _updateSetData(){
    bool hasChanged=false;
    final updatedSets= List<WorkoutSet>.from(widget.log.set);

    for(int i=0; i<updatedSets.length; i++){
      final weight=double.tryParse(_weightController[i].text) ?? 0;
      final reps=int.tryParse(_repsController[i].text) ?? 0;

      if(updatedSets[i].weight != weight || updatedSets[i].reps != reps){
        updatedSets[i] = updatedSets[i].copyWith(weight:weight, reps:reps);
        hasChanged=true;
      }
    }
    if(hasChanged){
      final updatedLogData=widget.log.copyWith(set:updatedSets);
      _notifyParent(updatedLogData);
    }
  }

  @override
  void dispose(){
    _disposeControllersAndNodes();
    _memoController.dispose();
    super.dispose();
  }

  void _disposeControllersAndNodes({bool isDisposing=true}){
    for(var controller in _weightController){
      controller.removeListener(_onControllerChanged);
      controller.dispose();
    }
    for(var controller in _repsController){
      controller.removeListener(_onControllerChanged);
      controller.dispose();
    }
    if(isDisposing){
      for(var node in _weightFocusNodes){
        node.dispose();
      }
      for(var node in _repsFocusNodes){
        node.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext build){
    return Card(
      //color:const Color(0xFF1e3a5f),
      margin: const EdgeInsets.symmetric(horizontal:16.0, vertical: 8.0),
      child:Padding(
        padding: const EdgeInsets.all(16),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child:Text(
                    widget.log.exerciseName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                    overflow:TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed:widget.onShowRecords, 
                  child: Text('自己ベスト',style: TextStyle(fontSize: 12),),
                ),
                TextButton.icon(
                  icon:const Icon(Icons.history),
                  onPressed:widget.onShowHistory,
                  label:const Text('履歴',style: TextStyle(fontSize: 12),),
                  style:TextButton.styleFrom(
                    foregroundColor:Colors.grey,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                IconButton(
                  icon:const Icon(Icons.delete),
                  onPressed:widget.onDelete,
                )
              ],
            ),
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
              itemCount: widget.log.set.length,
              itemBuilder: (context, index){
                final currentSet=widget.log.set[index];
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
            SizedBox(
              child:Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _removeset,
                          icon: const Icon(Icons.remove_circle_outline,),
                        ),
                        IconButton(
                          onPressed: _addset,
                          icon: const Icon(Icons.add_circle_outline,),
                        ),
                        TextButton(
                          onPressed: (){
                            setState(() {
                              _isMemoVisible=!_isMemoVisible;
                            });
                          }, 
                          child: Text(_isMemoVisible ? 'メモを閉じる' : '+メモ'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if(_isMemoVisible)
              Padding(
                padding: const EdgeInsets.only(top:8),
                child: TextField(
                  controller: _memoController,
                  decoration: const InputDecoration(
                    labelText: 'メモ',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: 20,
                  minLines: 1,
                  onChanged: (value){},
                )
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
    bool isLastSet = index == widget.log.set.length-1 ;
    if(isLastSet){
      return const SizedBox.shrink();
    }
    return IconButton(
      icon:const Icon(Icons.keyboard_double_arrow_down_sharp),
      onPressed:(){
        //1.現在のデータを取得
        final String weightToCopy=_weightController[index].text;
        final String repsToCopy=_repsController[index].text;
        //3.次のセットの入力欄も更新
        _weightController[index+1].text=weightToCopy;
        _repsController[index+1].text=repsToCopy;
        //以上のデータの更新、UIの更新セットで行わなければ、バグの原因となる。
      }
    );
  }
}