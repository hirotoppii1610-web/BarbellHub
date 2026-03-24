import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import '../model/body_weight_log.dart';
import '../model/user_profile.dart';


class BodyWeightLogScreen extends StatefulWidget{
  final BodyWeightLog bodyWeightLogData;
  final Function(BodyWeightLog) onBodyWeightLogUpdated;
  final UserProfile userProfile;
  final List<BodyWeightLog> weeklyWeightLog;

  const BodyWeightLogScreen({
    super.key, 
    required this.bodyWeightLogData,
    required this.onBodyWeightLogUpdated,
    required this.userProfile,
    required this.weeklyWeightLog,
  });

  @override
  State<BodyWeightLogScreen> createState()=> _BodyWeightLogScreenState();
}

class _BodyWeightLogScreenState extends State<BodyWeightLogScreen>{

  late BodyWeightLog _logCopy;
  
  late final TextEditingController _weightController;
  late final TextEditingController _fatController;
  late final TextEditingController _muscleController;
  late final TextEditingController _visceralFatController;
  late final TextEditingController _bmrController;
  late final TextEditingController _waterController;
  late final TextEditingController _boneController;
  late final TextEditingController _bmiController;

  late final FocusNode _weightFocusNode;
  late final FocusNode _fatFocusNode;
  late final FocusNode _muscleFocusNode;
  late final FocusNode _visceralFatFocusNode;
  late final FocusNode _bmrFocusNode;
  late final FocusNode _waterFocusNode;
  late final FocusNode _boneFocusNode;
  late final FocusNode _bmiFocusNode;

  bool isSameDay(DateTime a, DateTime b){
    return a.year==b.year && a.month==b.month && a.day==b.day;
  }


  @override
  void initState() {
    super.initState();
    print("✅ 5. [BodyWeightLogScreen] 初期化完了。受け取ったプロフィールは\n${widget.userProfile}");
    _logCopy=widget.bodyWeightLogData;
    //コントローラとフォーカスノードを初期化
    _weightController =TextEditingController(text: _logCopy.bodyWeight > 0 ? _logCopy.bodyWeight.toStringAsFixed(2) :'');
    _weightController.addListener(_caluculateBmrOnWeightChange);
    _fatController =TextEditingController(text: _logCopy.bodyFatPercentage?.toStringAsFixed(1) ?? '');
    _muscleController =TextEditingController(text: _logCopy.muscleMass?.toStringAsFixed(1) ?? '');
    _visceralFatController =TextEditingController(text: _logCopy.visceralFatLevel?.toStringAsFixed(1) ?? '');
    _bmrController =TextEditingController(text: _logCopy.basalMetabolicRate?.toStringAsFixed(1) ?? '');
    _waterController =TextEditingController(text: _logCopy.bodyWaterPercentage?.toStringAsFixed(1) ?? '');
    _boneController =TextEditingController(text: _logCopy.boneMass?.toStringAsFixed(1) ?? '');
    _bmiController =TextEditingController(text: _logCopy.bmi?.toStringAsFixed(1) ?? '');

    _weightFocusNode =FocusNode();
    _fatFocusNode =FocusNode();
    _muscleFocusNode =FocusNode();
    _visceralFatFocusNode =FocusNode();
    _bmrFocusNode =FocusNode();
    _waterFocusNode =FocusNode();
    _boneFocusNode =FocusNode();
    _bmiFocusNode =FocusNode();
    //フォーカスノードにリスナーを設定
    _weightFocusNode.addListener(_onFocusChange);
    _fatFocusNode.addListener(_onFocusChange);
    _muscleFocusNode.addListener(_onFocusChange);
    _visceralFatFocusNode.addListener(_onFocusChange);
    _bmrFocusNode.addListener(_onFocusChange);
    _waterFocusNode.addListener(_onFocusChange);
    _boneFocusNode.addListener(_onFocusChange);
    _bmiFocusNode.addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_){
      if(mounted){
        _caluculateBmrOnWeightChange();
      }
    });
  }

  @override
  void didUpdateWidget(covariant BodyWeightLogScreen oldWidget){
    super.didUpdateWidget(oldWidget);
    print("✅ 5. [BodyWeightLogScreen] 新しいプロフィールを受信しました。\n${widget.userProfile}");
    if(widget.userProfile != oldWidget.userProfile){
      _caluculateBmrOnWeightChange();
    }
  }

  void _onFocusChange(){
    //このコードはフォーカスの当たった時と外れた時の両方で呼ばれるので、外れた時のみの更新とする。
    if( !_weightFocusNode.hasFocus &&
        !_fatFocusNode.hasFocus &&
        !_muscleFocusNode.hasFocus &&
        !_visceralFatFocusNode.hasFocus &&
        !_bmrFocusNode.hasFocus &&
        !_waterFocusNode.hasFocus &&
        !_boneFocusNode.hasFocus &&
        !_bmiFocusNode.hasFocus){
      _updateAndSave();
    }
  }

  void _updateAndSave(){
    final updatedBodyWeightLog= _logCopy.copyWith(
      bodyWeight: double.tryParse(_weightController.text) ?? 0.0,
      bodyFatPercentage: double.tryParse(_fatController.text),
      muscleMass: double.tryParse(_muscleController.text),
      visceralFatLevel: double.tryParse(_visceralFatController.text),
      basalMetabolicRate: double.tryParse(_bmrController.text),
      bodyWaterPercentage: double.tryParse(_waterController.text),
      boneMass: double.tryParse(_boneController.text),
      bmi: double.tryParse(_bmiController.text),
    );
    if(updatedBodyWeightLog.toJson().toString() != _logCopy.toJson().toString()){
      setState((){
        _logCopy=updatedBodyWeightLog;
      });
      widget.onBodyWeightLogUpdated(updatedBodyWeightLog);
      print('体重・体組成データを自動保存しました。');
    }
  }
  
  void dispose(){
    _weightController.dispose();
    _weightController.removeListener(_caluculateBmrOnWeightChange);
    _fatController.dispose();
    _muscleController.dispose();
    _visceralFatController.dispose();
    _bmrController.dispose();
    _waterController.dispose();
    _boneController.dispose();
    _bmiController.dispose();

    _weightFocusNode.removeListener(_onFocusChange);
    _fatFocusNode.removeListener(_onFocusChange);
    _muscleFocusNode.removeListener(_onFocusChange);
    _visceralFatFocusNode.removeListener(_onFocusChange);
    _bmrFocusNode.removeListener(_onFocusChange);
    _waterFocusNode.removeListener(_onFocusChange);
    _boneFocusNode.removeListener(_onFocusChange);
    _bmiFocusNode.removeListener(_onFocusChange);

    _weightFocusNode.dispose();
    _fatFocusNode.dispose();
    _muscleFocusNode.dispose();
    _visceralFatFocusNode.dispose();
    _bmrFocusNode.dispose();
    _waterFocusNode.dispose();
    _boneFocusNode.dispose();
    _bmiFocusNode.dispose();
    super.dispose();
  }

  void _handlepop(){
    _updateAndSave();
    Navigator.pop(context);
  }

  void _showDeleteConfirmDialog(BodyWeightLog logToDelete){
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: const Text('削除の確認'),
          content: Text('${DateFormat('yyyy/MM/dd').format(logToDelete.date)}の体重を本当に削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('キャンセル')
            ),
            TextButton(
              onPressed: (){
                setState(() {
                  
                });
                Navigator.pop(context);
              },
              child: Text('削除'),)
          ],
        );
      }
    );
  }

  void _caluculateBmrOnWeightChange(){
    print("--- ⚙️ BMR計算開始 ⚙️ ---");
    print("① 使用するプロフィール: ${widget.userProfile}");
    final currentWeight = double.tryParse(_weightController.text);
    if(currentWeight==null || currentWeight <= 0){
      print("体重が無効なため計算を中止します。");
      print("--- BMR計算終了 ---");
     return;}
    //平均体重の算出のためのリスト作り
    final pastWeights = widget.weeklyWeightLog
        .where((log)=>!isSameDay(log.date, widget.bodyWeightLogData.date))  //今日の日は除く
        .map((log)=>log.bodyWeight)
        .where((w)=> w>0)   //０kg以下は除外
        .toList();
    final weeklyAvarageBodyWeightList=[currentWeight, ...pastWeights];
    if(weeklyAvarageBodyWeightList.isEmpty){
      print("平均体重の計算ができないため中止します。");
      print("--- BMR計算終了 ---");
      return;
    }
    //平均計算
    final weeklyAvarageBodyWeight = weeklyAvarageBodyWeightList.reduce((a,b)=>a+b) / weeklyAvarageBodyWeightList.length;
    print("③ 計算に使用する平均体重: $weeklyAvarageBodyWeight");
    //BMR計算
    final bmr=widget.userProfile.calculateBMR(weeklyAvarageBodyWeight);
    print("④ 計算結果のBMR: $bmr");
    if(bmr!=null){
      print("⑤ BMRフィールドのフォーカス状態: ${_bmrFocusNode.hasFocus}");
      if(!_bmrFocusNode.hasFocus){
        print("🚀 BMRフィールドを「${bmr.toStringAsFixed(1)}」に更新します。");
        setState((){
          _bmrController.text = bmr.toStringAsFixed(1);
        });
      }else{
        print("📝 BMRフィールドがフォーカス中のため、UIの更新をスキップしました。");
      }
    }else{
      print("⚠️ BMRがnullのため、フィールドは更新されません。UserProfileモデルのcalculateBMRメソッドと、プロフィール情報（身長、性別、生年月日）が正しいか確認してください。");
    }
    print("--- BMR計算終了 ---");
  }

  Future<void> _syncHealthData()async{
    //ヘルスケアプラグインを初期化
    final health=Health();
    //読み込みたいデータを定義
    final types=[
      HealthDataType.WEIGHT,
      HealthDataType.BODY_FAT_PERCENTAGE,
    ];
    final permissions=[HealthDataAccess.READ_WRITE, HealthDataAccess.READ_WRITE];

    //現在の権限状態をチェック
    bool isAuthorized= await health.hasPermissions(types, permissions: permissions) ?? false;

    if(!isAuthorized){
      try{
        isAuthorized=await health.requestAuthorization(types, permissions: permissions);
      }
      catch(e){
        print('権限リクエスト中にエラー発生: $e');
      }    
    }

    if(isAuthorized){
      try{
        //今日のデータを取得
        final now=DateTime.now();
        final midNight=DateTime(now.year,now.month, now.day);

        List<HealthDataPoint> healthData=await health.getHealthDataFromTypes(
          startTime: midNight,
          endTime: now,
          types: types,
        );
        //重複を外して、各タイプで最新データ身のみを取得
        final uniqueData = health.removeDuplicates(healthData);
        final Set<HealthDataType> fetchedTypes={};  //読み取ったデータを記憶しておく
        if(uniqueData.isNotEmpty && mounted){
          //取得したデータをコントローラに反映
          setState(() {
            for(var dataPoint in uniqueData){
              final value=(dataPoint.value as NumericHealthValue).numericValue.toDouble();
              fetchedTypes.add(dataPoint.type); //読み取ったデータのみを記録
              switch(dataPoint.type){
                case HealthDataType.WEIGHT:
                  _weightController.text = value.toStringAsFixed(2);
                  break;
                case HealthDataType.BODY_FAT_PERCENTAGE:
                  _fatController.text = (value*100).toStringAsFixed(1);
                  break;

                default:
                  break;
              }
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ヘルスケアと今日のデータを連携しました。')),
            );
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('本日、まだヘルスケアにはデータが記録されていません。記録の連携のみ行います。')),
          );
        }

        print('これからヘルスケアに体重を書き込みます。');
        final weightToSave=double.tryParse(_weightController.text);
        if(weightToSave !=null && !fetchedTypes.contains(HealthDataType.WEIGHT)){
          print('体重データをヘルスケアに書き込みます: $weightToSave');
          await health.writeHealthData(
            value: weightToSave, 
            type: HealthDataType.WEIGHT, 
            startTime: now.subtract(const Duration(seconds: 1)),
            endTime: now,
          );
        }else{
          print('記録なしのため、書き込みを中止します。');
        }

        print('これからヘルスケアに体脂肪率を書き込みます。');
        final fatToSave=double.tryParse(_fatController.text);
        if(fatToSave !=null && !fetchedTypes.contains(HealthDataType.BODY_FAT_PERCENTAGE)){
          print('体脂肪データをヘルスケアに書き込みます: $fatToSave');
          final fatValue=fatToSave/100; //体脂肪率を(0.0~1.0)に戻して書き込む
          await health.writeHealthData(
            value: fatValue, 
            type: HealthDataType.BODY_FAT_PERCENTAGE, 
            startTime: now.subtract(const Duration(seconds: 1)),
            endTime: now,
          );
        }else{
          print('記録なしのため、書き込みを中止します。');
        }

        _caluculateBmrOnWeightChange();
        _updateAndSave();
      }catch(e){
        print('ヘルスケアのデータ取得に失敗しました。');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ヘルスケアのデータ取得に失敗しました')),
        );
      }
    }else{
      print('ヘルスケアのアクセスが許可されず、失敗しました。');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ヘルスケアのアクセスに失敗しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context){
    return PopScope(
      canPop:false,
      onPopInvoked:(didPop){
        if (didPop) return;
        _handlepop();
      },
      child:Scaffold(
        backgroundColor:Color(0xFF000020),
        appBar: AppBar(
          title: Text(
            '${DateFormat('M月d日 (E)', 'ja_JP').format(_logCopy.date)}',
            style:const TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold),
          ),
          leading:IconButton(
            icon:const Icon(Icons.arrow_back, color:Colors.white),
            onPressed:_handlepop,
          ),
          backgroundColor: Colors.teal.withOpacity(0.9),
        ),
        body:GestureDetector(
          onTap:()=>FocusScope.of(context).unfocus(),   //画面のどこかしらをタップしたら、キーボードが閉じる
          child:SingleChildScrollView(
            padding:const EdgeInsets.all(24.0),
            child:Column(
              children:[
                Row(
                  mainAxisAlignment:MainAxisAlignment.center,
                  children:[
                    const Icon(Icons.monitor_weight_outlined, size:64, color:Colors.tealAccent),
                    const SizedBox(width:10),
                    const Text('体重記録', style:TextStyle(color:Colors.white, fontSize:24, fontWeight:FontWeight.bold)),
                  ]
                ),
                const SizedBox(height:16),
                TextButton.icon(
                  onPressed: _syncHealthData, 
                  label: Text('ヘルスケアと連動', style: TextStyle(color:Colors.white70),),
                  icon: const Icon(Icons.sync, color:Colors.white70)
                ),
                const Divider(color:Colors.white24),
                const SizedBox(height:4),
                _buildEditableTile(controller:_weightController, focusNode:_weightFocusNode, label:'体重', suffix:'kg'),
                const SizedBox(height:8),
                _buildEditableTile(controller:_fatController, focusNode:_fatFocusNode, label:'体脂肪率', suffix:'%'),
                const SizedBox(height:8),
                _buildEditableTile(controller:_muscleController, focusNode:_muscleFocusNode, label:'筋肉量', suffix:'kg'),
                const SizedBox(height:8),
                _buildEditableTile(controller:_visceralFatController, focusNode:_visceralFatFocusNode, label:'内臓脂肪レベル', suffix:'Lv'),
                const SizedBox(height:8),
                _buildEditableTile(controller:_bmrController, focusNode:_bmrFocusNode, label:'基礎代謝', suffix:'kcal'),
                const SizedBox(height:8),
                _buildEditableTile(controller:_waterController, focusNode:_waterFocusNode, label:'体水分率', suffix:'%'),
                const SizedBox(height:8),
                _buildEditableTile(controller:_boneController, focusNode:_boneFocusNode, label:'推定骨量', suffix:'kg'),
                const SizedBox(height:8),
                _buildEditableTile(controller:_bmiController, focusNode:_bmiFocusNode, label:'BMI', suffix:''),
                _buildBmrInfoSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableTile({
    required TextEditingController controller, 
    required FocusNode focusNode,
    required String label,
    required String suffix,
  }){
    return TextFormField(
      controller:controller,
      focusNode:focusNode,
      style: const TextStyle(color:Colors.white),
      textAlign:TextAlign.end,
      keyboardType: const TextInputType.numberWithOptions(decimal:true),
      decoration:InputDecoration(
        prefixIcon:Padding(
          padding:const EdgeInsets.only(left:8.0),
          child: Text(label, style:TextStyle(color:Colors.white70)),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth:0, minHeight:0),
        suffixText:suffix,
        suffixStyle:const TextStyle(color:Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color:Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:BorderRadius.circular(8),
          borderSide: const BorderSide(color:Colors.teal, width:2),
        ),
      ),
    );
  }

  Widget _buildBmrInfoSection(){
    final weight=double.tryParse(_weightController.text);
    if(weight==null){
      return const SizedBox.shrink();
    }
    final bmr=widget.userProfile.calculateBMR(weight);
    if(bmr==null){
      return Column(
        mainAxisAlignment:MainAxisAlignment.center,
        children:[
          const Divider(color:Colors.white24),
          const SizedBox(height:4),
          Container(
            padding:EdgeInsets.all(16.0),
            decoration:BoxDecoration(
              color:Colors.teal.withOpacity(0.9),
              borderRadius:BorderRadius.circular(12),
            ),
            child: const Center(
              child:Text(
                '今日の体重\nプロフィール欄の"基本プロフィール情報"\nの入力で基礎代謝が自動計算されます',
                style:TextStyle(color:Colors.white70, height:1.5),
                textAlign:TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }
    //BMRが計算されたとき
    final tdee=widget.userProfile.calculateTDEE(weight);
    return Column(
      mainAxisAlignment:MainAxisAlignment.center,
      children:[
        const SizedBox(height:24),
        const Divider(color:Colors.white24),
        const SizedBox(height:16),
        Container(
          padding:EdgeInsets.all(16.0),
          decoration:BoxDecoration(
            color:Colors.teal.withOpacity(0.9),
            borderRadius:BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment:CrossAxisAlignment.stretch,
            children:[
              const Row(
                children:[
                  Padding(
                    padding:EdgeInsets.only(left:20),
                    child:Text('基礎代謝(BMR)', style:TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold)),
                  ),
                  SizedBox(width:16),
                  Text('生命維持に必要な最低限のエネルギー',style:TextStyle(color:Colors.white70, fontSize:12),),
                ],
              ),
              Center(
                child:Row(
                  mainAxisAlignment:MainAxisAlignment.center,
                  children:[
                    Text(bmr.toStringAsFixed(0), style:const TextStyle(color:Colors.tealAccent, fontSize:36, fontWeight:FontWeight.bold)),
                    const SizedBox(width:8),
                    const Text('kcal', style:TextStyle(color:Colors.white, fontSize:16,)),
                  ],
                ),
              ),
              const SizedBox(height:24),
              const Row(
                children:[
                  Padding(
                    padding:EdgeInsets.only(left:20),
                    child:Text('総消費カロリー(TDEE)', style:TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold)),
                  ),
                  SizedBox(width:16),
                  Text('活動レベルを考慮した\n1日の消費目安',style:TextStyle(color:Colors.white70, fontSize:12),),
                ],
              ),
              Center(
                child: tdee!=null
                  ? Row(
                    mainAxisAlignment:MainAxisAlignment.center,
                      children:[
                        Text(tdee.toStringAsFixed(0), style:const TextStyle(color:Colors.tealAccent, fontSize:36, fontWeight:FontWeight.bold)),
                        const SizedBox(width:8),
                        const Text('kcal', style:TextStyle(color:Colors.white, fontSize:16,)),
                      ],
                    )
                  : const Text('活動レベルをプロフィール欄から設定してください', style:TextStyle(color:Colors.white, fontSize:16,)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}