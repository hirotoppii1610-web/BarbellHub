import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:health/health.dart';
import 'package:muscle_one/widget/sleep_clock_painter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widget/sleep_clock_painter.dart';
import '../model/sleep_log.dart';
import 'package:intl/intl.dart';

class SleepLogScreen extends StatefulWidget{
  final SleepLog sleepLogData;
  final Function(SleepLog) onSleepUpdated;
  const SleepLogScreen({
    super.key, 
    required this.sleepLogData,
    required this.onSleepUpdated,
  });

  @override
  State<SleepLogScreen> createState()=> _SleepLogScreenState();
}

class _SleepLogScreenState extends State<SleepLogScreen>{
  final Health _health=Health();
  late SleepLog _sleepLogCopy;
  bool _isAuthorized=false;
  //睡眠時間が0分以上なのかを示すゲッター
  bool get _hasValidLog => _sleepLogCopy.hasData;

  @override
  void initState(){
    super.initState();
    _sleepLogCopy=widget.sleepLogData;
  }


  Future<void> _syncSleepData()async{   
    final health=Health();
    final types=[HealthDataType.SLEEP_IN_BED, HealthDataType.SLEEP_ASLEEP];

    final permissions=[HealthDataAccess.READ_WRITE, HealthDataAccess.READ_WRITE];
    bool _isAuthorized=await health.hasPermissions(types, permissions: permissions) ?? false;

    if(!_isAuthorized){  //意味合いでいうと、notAuthorizedならば、という意味合い
      try{
        _isAuthorized= await _health.requestAuthorization(types, permissions: permissions);
      }catch(e){
        print('権限リクエスト中にエラー発生: $e');
      } 
    }          

    if(_isAuthorized){
      final thisDate =_sleepLogCopy.date;
      final startTime=DateTime(thisDate.year,thisDate.month,thisDate.day-1, 12);
      final endTime=DateTime(thisDate.year,thisDate.month,thisDate.day, 12);
      try{
        final healthData = await _health.getHealthDataFromTypes(
          types: types,
          startTime: startTime, 
          endTime: endTime,
        );

        if(healthData.isEmpty)return;
        if(healthData.isNotEmpty){
          final uniqueData=health.removeDuplicates(healthData);
          final sleepInBedData=uniqueData.where((p)=>p.type == HealthDataType.SLEEP_IN_BED).toList();
          final sleepAsleepData=uniqueData.where((p)=>p.type==HealthDataType.SLEEP_ASLEEP).toList();
            
          DateTime? goToBedTime, getOutBedTime;
          if(sleepInBedData.isNotEmpty){
            goToBedTime=sleepInBedData.first.dateFrom;
            getOutBedTime=sleepInBedData.last.dateTo;
          }

          DateTime? sleepInTime, wakeUpTime;
          if(sleepAsleepData.isNotEmpty){
            sleepInTime=sleepAsleepData.first.dateFrom;
            wakeUpTime=sleepAsleepData.last.dateTo;
          }
            
          if(mounted){
            setState(() {
              _sleepLogCopy=_sleepLogCopy.copyWith(
                goToBedTime: goToBedTime,
                sleepInTime: sleepInTime,
                wakeUpTime: wakeUpTime,
                getOutBedTime: getOutBedTime,
              );
            });
          }
          widget.onSleepUpdated(_sleepLogCopy);

          if(_sleepLogCopy.hasData){
            await health.writeHealthData(
              value: 1,
              type: HealthDataType.SLEEP_ASLEEP,
              startTime: _sleepLogCopy.sleepInTime,
              endTime:  _sleepLogCopy.wakeUpTime,
            );
          }
        }
      } catch(e){
          print('ヘルスケアからのデータ取得エラー:$e');
      }
    }
  }
  
  //手入力のためのピッカー表示関数
  Future<void> _showRefindEntryDialog()async{
    final logDate = _sleepLogCopy.date;
    DateTime tempSleepIn = _hasValidLog
        ? _sleepLogCopy.sleepInTime
        : DateTime(logDate.year, logDate.month, logDate.day-1, 23, 0);
    DateTime tempWakeUp = _hasValidLog
        ? _sleepLogCopy.wakeUpTime
        : DateTime(logDate.year, logDate.month, logDate.day, 7, 0);

    //cupertinoを呼び出す。
    Future<DateTime?> _showCupertinoDateTimePicker({required DateTime initialDate, required String title}){
      DateTime? tempPickedDate = initialDate;
      return showModalBottomSheet<DateTime>(
        context:context,
        backgroundColor:Colors.transparent,
        builder:(BuildContext builder){
          return Container(
            height:300,
            decoration:const BoxDecoration(
              color:Color.fromARGB(255,39,53,75),
              borderRadius:BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child:Column(
              children:[
                Container(
                  color:const Color.fromARGB(255,59,73,95),
                  child:Stack(
                    alignment:Alignment.center,
                    children:[
                      //中央のボタン
                      Text(title, style:const TextStyle(color:Colors.white, fontSize:16, fontWeight:FontWeight.bold)),
                      //両端のボタン
                      Row(
                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                        children:[
                          CupertinoButton(
                            child:const Text('キャンセル', style:TextStyle(color:Colors.white70)),
                            onPressed: ()=> Navigator.pop(context),
                          ),
                          CupertinoButton(
                            child:const Text('保存', style:TextStyle(color:Colors.white)),
                            onPressed: ()=> Navigator.pop(context, tempPickedDate),
                          ),
                        ],
                      ),
                    ]
                  ),
                ),
                const Divider(height:1, color:Colors.white),
                Expanded(
                  child:CupertinoTheme(
                    data:const CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(color:Colors.white, fontSize:18), //ピッカーの文字色
                      ),
                    ),
                    child:CupertinoDatePicker(
                      mode:CupertinoDatePickerMode.dateAndTime,
                      initialDateTime:initialDate,
                      use24hFormat:true,
                      onDateTimeChanged:(DateTime newDate){
                        tempPickedDate=newDate;
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      );
    }
  

    final bool? confirmed=await showDialog<bool>(
      context:context,
      builder:(context){
        return StatefulBuilder(
          builder:(context, setDialogState){
            return AlertDialog(
              backgroundColor:const Color(0xFF1e3a5f),
              title:const Text('睡眠時間を入力', style:TextStyle(color:Colors.white70)),
              content:Column(
                mainAxisSize:MainAxisSize.min,
                children:[
                  ListTile(
                    title:const Text('就寝', style:TextStyle(color:Colors.white70)),
                    subtitle:Text(
                      DateFormat('M月d日 (E) HH:mm', 'ja_JP').format(tempSleepIn),
                      style:const TextStyle(color:Colors.white),
                    ),
                    onTap:()async{
                      final picked=await _showCupertinoDateTimePicker(initialDate: tempSleepIn, title:'就寝時刻を選択');
                      if(picked != null){
                        setDialogState(() => tempSleepIn=picked);
                      }
                    }
                  ),
                  ListTile(
                    title:const Text('起床', style:TextStyle(color:Colors.white70)),
                    subtitle:Text(
                      DateFormat('M月d日 (E) HH:mm', 'ja_JP').format(tempWakeUp),
                      style:const TextStyle(color:Colors.white),
                    ),
                    onTap:()async{
                      final picked=await _showCupertinoDateTimePicker(initialDate: tempWakeUp, title:'起床時刻を選択');
                      if(picked != null){
                        setDialogState(() => tempWakeUp=picked);
                      }
                    }
                  ),
                ],
              ),
              actions:[
                TextButton(
                  onPressed:()=>Navigator.pop(context),
                  child:const Text('キャンセル', style:TextStyle(color:Colors.white70))
                ),
                TextButton(
                  onPressed:(){
                    if(tempWakeUp.isBefore(tempSleepIn)){ return; }
                    Navigator.pop(context, true);
                  },
                  child:const Text('保存', style:TextStyle(color:Colors.white70)),
                )
              ]
            );
          }
        );
      }
    );

    if(confirmed==true){
      setState((){
        _sleepLogCopy=SleepLog(
          date:_sleepLogCopy.date,
          sleepInTime:tempSleepIn,
          wakeUpTime:tempWakeUp,
        );
      });
      widget.onSleepUpdated(_sleepLogCopy);
    }
  }

  void _showDeleteConfirmDialog(){
    showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        backgroundColor:const Color(0xFF1e3a5f),
        title:const Text('本当にこの日の睡眠記録を削除しますか？', style:TextStyle(color:Colors.white, fontSize:16)),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
           child: const Text('キャンセル', style:TextStyle(color:Colors.white70))
          ),
          TextButton(
            onPressed: (){
              setState(() {
                final date=_sleepLogCopy.date;
                //一旦からのデータで上書き
                _sleepLogCopy=SleepLog(date: date,sleepInTime: date, wakeUpTime: date);
              });
              widget.onSleepUpdated(_sleepLogCopy);
              Navigator.pop(context);
            }, child: const Text('削除', style:TextStyle(color:Colors.white70)),
          ),
        ],
      )
    );
  }

  void _handlepop(){
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context){
    return PopScope(
      canPop:false,
      onPopInvoked: (didPop){
        if(didPop)return;
        _handlepop();
      },
      child: Scaffold(
        backgroundColor:Color(0xFF000020),
        appBar: AppBar(
          title:Text('${DateFormat('M月d日 (E)', 'ja_JP').format(_sleepLogCopy.date)}',style: TextStyle(color: Colors.white, fontSize:18, fontWeight:FontWeight.bold),),
          leading: IconButton(
            onPressed: _handlepop, 
            icon:const Icon(Icons.arrow_back, color:Colors.white),
          ),
          backgroundColor: Colors.blueAccent,
        ),
        body:SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _hasValidLog
                ?Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16,),
                    const Text('睡眠時間', style: TextStyle(color:Colors.white, fontSize: 24),),
                    const SizedBox(height: 16,),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          const SizedBox(width: 32,),
                          Center(
                            child: Text(
                              _sleepLogCopy.sleepDurationAsString,
                              style:Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color:Colors.white,
                                fontWeight:FontWeight.bold,
                                fontSize: 38,
                              ),
                            ),
                          ),
                          IconButton(
                            icon:Icon(Icons.edit, color: Colors.white70,size: 24,),
                            onPressed: _showRefindEntryDialog,
                          ),
                          IconButton(
                            onPressed: _showDeleteConfirmDialog,
                            icon:Icon(Icons.delete_outline, color: Colors.white70,size: 24,),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16,),
                    
                    CustomPaint(
                      size: const Size(250, 250),
                      painter: SleepClockPainter(
                        sleepInTime: _sleepLogCopy.sleepInTime, 
                        wakeUpTime: _sleepLogCopy.wakeUpTime,
                      ),
                    ),
                    
                    const SizedBox(height: 8,),
                    _buildSleepDetailsCard(),
                    const SizedBox(height: 32,),
                    TextButton.icon(
                          icon: const Icon(Icons.sync),
                          onPressed: _syncSleepData,
                          label: const Text('ヘルスケアと連動'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                        ),
                    const SizedBox(height:8),
                  ])
                :Center(
                  child:Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        const SizedBox(height: 180,),
                        const Icon(Icons.nights_stay_outlined, size:64, color: Colors.grey,),
                        const SizedBox(height: 16,),
                        const Text('この日の睡眠記録はまだありません',style:TextStyle(color:Colors.white)),
                        const SizedBox(height: 32,),
                        const SizedBox(height: 20,),
                        //const Divider(),
                        //const SizedBox(height: 20,),
                          //ヘルスケア読み込みボタン
                        ElevatedButton.icon(
                          icon: const Icon(Icons.sync),
                          onPressed: _syncSleepData,
                          label: const Text('ヘルスケアと連動'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                        ),
                        const SizedBox(height: 20,),
                        ElevatedButton.icon(
                          icon:const Icon(Icons.edit_note),
                          onPressed: _showRefindEntryDialog,
                          label: const Text('手入力で睡眠記録を追加'),
                        ),
                      ]
                    ),
                ),
              ],
            ),
          
        ),
      ),
    );
  }    

  Widget _buildSleepDetailsCard(){
    return Card(
      color:const Color(0xFF0a1931),
      child: Center(
        child: Padding(
          padding: EdgeInsetsGeometry.all(16),
          child:Column(
            children: [
              (_sleepLogCopy.goToBedTime != null)
                  ? _buildDetailRow( 
                    label: '就寝時間', 
                    value: DateFormat('HH:mm').format(_sleepLogCopy.goToBedTime!),
                  )
                  : SizedBox(height: 0,),
              _buildDetailRow(label: '入眠時間', value: DateFormat('HH:mm').format(_sleepLogCopy.sleepInTime)),
              _buildDetailRow(label: '覚醒時間', value: DateFormat('HH:mm').format(_sleepLogCopy.wakeUpTime)),
              (_sleepLogCopy.getOutBedTime != null)
                  ? _buildDetailRow( 
                    label: '起床時間', 
                    value: DateFormat('HH:mm').format(_sleepLogCopy.getOutBedTime!),
                  )
                  : SizedBox(height: 0,),
              (_sleepLogCopy.sleepEfficiency != null)
                  ? _buildDetailRow( 
                    label: '睡眠効率', 
                    value: '${_sleepLogCopy.sleepEfficiency!.toStringAsFixed(1)} %',
                  )
                  : SizedBox(height: 0,),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}){
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(width: 16,),
          Text(value, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}