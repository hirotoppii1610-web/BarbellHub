import 'package:flutter/material.dart';
import '../model/review_workout.dart';
import '../model/cardio_log.dart';
import '../model/cardio_set.dart';

class CardioLogFilling extends StatefulWidget{
  final CardioLog log;
  final double? userWeight;
  final ReviewWorkout entireWorkout;
  final Function(ReviewWorkout) onUpdated;
  final VoidCallback onDelete;
  final VoidCallback onShowHistory;
  final VoidCallback onShowBest;

  const CardioLogFilling({
    super.key,
    required this.log,
    required this.userWeight,
    required this.entireWorkout,
    required this.onUpdated,
    required this.onDelete,
    required this.onShowHistory,
    required this.onShowBest,
  });

  @override
  State<CardioLogFilling> createState()=>_CardioLogFillingState();
}

class _CardioLogFillingState extends State<CardioLogFilling>{

  late List<TextEditingController> _durationControllers;
  late List<TextEditingController> _distanceControllers;
  late List<TextEditingController> _stepsControllers;

  late List<FocusNode> _durationFocusNodes;
  late List<FocusNode> _distanceFocusNodes;
  late List<FocusNode> _stepsFocusNodes;

  late TextEditingController _memoController;
  bool _isMemoVisible=false;

  final Map<CardioType,String> _typeDisplayNames={
    CardioType.walking:'ウォーキング',
    CardioType.running:'ランニング',
    CardioType.cycling:'バイク',
    CardioType.swimming:'スイミング',
  };

  final Map<CardioType,List<String>> _intensityOptions = const {
    CardioType.walking:['ゆっくり', '普通', '速歩き'],
    CardioType.running:['ジョギング', '普通', '高強度'],
    CardioType.cycling:['ゆっくり', '普通', '高強度'],
    CardioType.swimming:['ゆっくり', '普通', '高強度'],
  };

  final Map<CardioType,List<String>> _intensityDisplayNames = const {
    CardioType.walking:['ゆっくり  (3-4km/時)', '普通 (4.5-5.5km/時)', '速歩き (5.7-6.3km/時)'],
    CardioType.running:['ジョギング', '普通 (6分/km程度)', '高強度 (5分/km程度)'],
    CardioType.cycling:['ゆっくり', '普通', '高強度'],
    CardioType.swimming:['ゆっくり', '普通', '高強度'],
  };

  @override
  void initState(){
    super.initState();
    _initializeControllersAndFocusNodes();
    _memoController=TextEditingController(text: widget.log.memo ?? '');
    _memoController.addListener(_onMemochanged);
    if(widget.log.memo!=null && widget.log.memo!.isNotEmpty){
      _isMemoVisible=true;
    }
  }

  @override
  void didUpdateWidget(covariant CardioLogFilling oldWidget){
    super.didUpdateWidget(oldWidget);
    if(widget.log.sets.length != oldWidget.log.sets.length){
      _disposeControllersAndNodes(isDisposing:false);
      _initializeControllersAndFocusNodes();
    }
  }

  void _initializeControllersAndFocusNodes(){
    _durationControllers=widget.log.sets.map((s)=>TextEditingController(text: s.durationInMinutes?.toString() ?? '')).toList();
    _distanceControllers=widget.log.sets.map((s)=>TextEditingController(text: s.distanceInKm?.toString() ?? '')).toList();
    _stepsControllers=widget.log.sets.map((s)=>TextEditingController(text: s.steps?.toString() ?? '')).toList();

    for(var c in _durationControllers){ c.addListener(_onControllerChanged); }
    for(var c in _distanceControllers){ c.addListener(_onControllerChanged); }
    for(var c in _stepsControllers){ c.addListener(_onControllerChanged); }

    _durationFocusNodes=List.generate(widget.log.sets.length, (_)=>FocusNode());
    _distanceFocusNodes=List.generate(widget.log.sets.length, (_)=>FocusNode());
    _stepsFocusNodes=List.generate(widget.log.sets.length, (_)=>FocusNode());
  }

  void _onControllerChanged(){
    setState((){});
    _updateAllSets();
  }

  void _onMemochanged(){
    final newMemo=_memoController.text;
    if(widget.log.memo!=newMemo){
      final updatedLogData=widget.log.copyWith(memo: newMemo);
      _notifyParent(updatedLogData);
    }
  }

  void _notifyParent(CardioLog updatedLog){
    final logIndex=widget.entireWorkout.cardioLogs.indexWhere((l)=>l.id==widget.log.id);
    if(logIndex!=-1){
      final updatedCardioLogs=List<CardioLog>.from(widget.entireWorkout.cardioLogs);
      updatedCardioLogs[logIndex]=updatedLog;
      final updatedWorkouts=widget.entireWorkout.copyWith(cardioLogs: updatedCardioLogs);
      widget.onUpdated(updatedWorkouts);
    }
  }

  void _updateAllSets(){
    bool hasChanged=false;
    final updatedSets=List<CardioSet>.from(widget.log.sets);
    for(int i=0; i<updatedSets.length; i++){
      final set=updatedSets[i];
      final newDuration=int.tryParse(_durationControllers[i].text);
      final newDistance=double.tryParse(_distanceControllers[i].text);
      final newSteps=int.tryParse(_stepsControllers[i].text);

      if(set.durationInMinutes != newDuration || set.distanceInKm != newDistance || set.steps != newSteps){
        updatedSets[i]=set.copyWith(
          durationInMinutes: newDuration,
          distanceInKm: newDistance,
          steps:newSteps,
        );
        hasChanged=true;
      }
    }
    if(hasChanged){
      final updatedLogData=widget.log.copyWith(sets:updatedSets);
      final logIndex=widget.entireWorkout.cardioLogs.indexWhere((l)=> l.id==widget.log.id);
      if(logIndex!=-1){
        final updatedCardioLogs=List<CardioLog>.from(widget.entireWorkout.cardioLogs);
        updatedCardioLogs[logIndex]=updatedLogData;

        final updatedWorkouts=widget.entireWorkout.copyWith(cardioLogs:updatedCardioLogs);
        widget.onUpdated(updatedWorkouts);
      }
    }
  }

  void _disposeControllersAndNodes({bool isDisposing=true}){
    for(var c in _durationControllers){ c.removeListener(_onControllerChanged); c.dispose();}
    for(var c in _distanceControllers){ c.removeListener(_onControllerChanged); c.dispose();}
    for(var c in _stepsControllers){c.removeListener(_onControllerChanged); c.dispose();}
    if(isDisposing){
      for(var n in _durationFocusNodes){ n.dispose();}
      for(var n in _distanceFocusNodes){ n.dispose();}
      for(var n in _stepsFocusNodes){ n.dispose();}
    }
  }

  @override
  void dispose(){
    _memoController.removeListener(_onMemochanged);
    _memoController.dispose();
    _disposeControllersAndNodes();
    super.dispose();
  }

  void _addSet(){
    setState((){
      widget.log.sets.add(CardioSet());
      _disposeControllersAndNodes();
      _initializeControllersAndFocusNodes();
    });
    WidgetsBinding.instance.addPostFrameCallback((_){
      FocusScope.of(context).requestFocus(_durationFocusNodes.last);
    });
  }

  void _removeSet(int index){
    if(widget.log.sets.length > 1){
      final updatedSets = List<CardioSet>.from(widget.log.sets)..removeAt(index);
      final updatedLog = widget.log.copyWith(sets:updatedSets);
      final logIndex = widget.entireWorkout.cardioLogs.indexWhere((l)=> l.id==widget.log.id);

      if(logIndex != -1){
        final updatedCardioLogs = List<CardioLog>.from(widget.entireWorkout.cardioLogs);
        updatedCardioLogs[logIndex]= updatedLog;
        final updatedWorkout=widget.entireWorkout.copyWith(cardioLogs: updatedCardioLogs);
        widget.onUpdated(updatedWorkout);
      }
    }
  }

  void _copySet(int index){
    if(index < widget.log.sets.length-1){
      final updatedSets = List<CardioSet>.from(widget.log.sets);
      updatedSets[index+1]=updatedSets[index].copyWith();
      final updatedLog = widget.log.copyWith(sets:updatedSets);
      final logIndex = widget.entireWorkout.cardioLogs.indexWhere((l)=> l.id==widget.log.id);
      if(logIndex != -1){
        final updatedCardioLogs = List<CardioLog>.from(widget.entireWorkout.cardioLogs);
        updatedCardioLogs[logIndex]= updatedLog;
        final updatedWorkout=widget.entireWorkout.copyWith(cardioLogs: updatedCardioLogs);
        widget.onUpdated(updatedWorkout);
      }
    }
  }

  @override
  Widget build(BuildContext context){
    return Card(
      margin: const EdgeInsets.symmetric(horizontal:16.0, vertical: 8.0),
      child:Padding(
        padding: const EdgeInsets.all(16),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize:MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child:Text(
                    _typeDisplayNames[widget.log.type]!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                    overflow:TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed:widget.onShowBest, 
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
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap:true,
              physics:const NeverScrollableScrollPhysics(),
              itemCount:widget.log.sets.length,
              itemBuilder:(context, index){
                return _buildSetRow(index);
              },
            ),
            const SizedBox(height:10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: ()=>_removeSet(widget.log.sets.length-1),
                  icon: const Icon(Icons.remove_circle_outline,),
                ),
                IconButton(
                  onPressed: _addSet,
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
          ]
        ),
      ),
    );
  }

  Widget _buildSetRow(int index){
    final set=widget.log.sets[index];
    final bool isWalkRun = widget.log.type==CardioType.walking || widget.log.type==CardioType.running;

    final options=_intensityOptions[widget.log.type]!;
    final displayNames=_intensityDisplayNames[widget.log.type]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child:Column(
        crossAxisAlignment:CrossAxisAlignment.start,
        mainAxisSize:MainAxisSize.min,
        children:[
          const Divider(color:Colors.black),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              Text('${index+1}セッション目',style:TextStyle(fontSize:16, fontWeight:FontWeight.bold, color:Colors.black87)),
              if(index<widget.log.sets.length-1)
                IconButton(icon:const Icon(Icons.keyboard_double_arrow_down_sharp, color:Colors.grey), onPressed:()=>_copySet(index)),
            ],
          ),
          const SizedBox(height:16),
          SizedBox(
            width:260,
            child:DropdownButtonFormField<String>(
              value:set.intensity,
              items: List.generate(options.length, (i){
                return DropdownMenuItem(
                  value:options[i],
                  child:Center(child:Text(displayNames[i]),),
                );
              }),
              onChanged:(value){
                if(value!=null){
                  setState(()=>set.intensity=value);
                  _updateAllSets();
                }
              },
              borderRadius:BorderRadius.circular(12.0),
              decoration:InputDecoration(
                labelText:'運動強度',
                prefixIcon:Icon(Icons.speed),
                border:OutlineInputBorder(
                  borderRadius:BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          const SizedBox(height:16),
          Row(
            children:[
              Expanded(
                child:TextField(
                  controller:_distanceControllers[index],
                  focusNode:_distanceFocusNodes[index],
                  decoration:InputDecoration(
                    labelText:'距離', 
                    labelStyle: TextStyle(fontSize: 13),
                    suffixText:'km',
                    prefixIcon:Icon(Icons.map_outlined),
                    border:OutlineInputBorder(
                      borderRadius:BorderRadius.circular(8.0),
                    ),
                  ),
                  keyboardType:const TextInputType.numberWithOptions(decimal:true),
                ),
              ),
              const SizedBox(width:8),
              Expanded(
                child:TextField(
                  controller:_durationControllers[index],
                  focusNode:_durationFocusNodes[index],
                  decoration:InputDecoration(
                    labelText:'時間', 
                    labelStyle: TextStyle(fontSize: 13),
                    suffixText:'分',
                    prefixIcon:Icon(Icons.timer_outlined),
                    border:OutlineInputBorder(
                      borderRadius:BorderRadius.circular(8.0),
                    ),
                  ),
                  keyboardType:TextInputType.number,
                ),
              ),
              if(isWalkRun)...[
                const SizedBox(width:8),
                Expanded(
                  child:TextField(
                    controller:_stepsControllers[index],
                    focusNode:_stepsFocusNodes[index],
                    decoration:InputDecoration(
                      labelText:'歩数', 
                      labelStyle: TextStyle(fontSize: 13),
                      suffixText:'歩',
                      prefixIcon:Icon(Icons.map_outlined),
                    border:OutlineInputBorder(
                      borderRadius:BorderRadius.circular(8.0),
                    ),
                    ),
                    keyboardType:const TextInputType.numberWithOptions(decimal:true),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height:8),
          const Center(child:Text('help : 距離と時間の少なくとも一方は記録してください。', style:TextStyle(fontSize:12, color:Colors.grey)),),
          const SizedBox(height:8),
          Align(
            alignment:Alignment.center,
            child:Text(
              '消費カロリー: ${set.calculateCalories(widget.log.type, widget.userWeight ?? 60.00).toStringAsFixed(1)} kcal',
              style:TextStyle(fontSize:16, fontWeight:FontWeight.bold, color:Colors.orange[800]),
            )
          ),
        ],
      ),
    );
  }
} 