import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/websecurityscanner/v1.dart';
import 'package:intl/intl.dart';
import 'package:muscle_one/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/user_profile.dart';
import '../model/nutrition_goal.dart';
import '../model/sleep_goal.dart';
import '../model/workout_goal.dart';
import '../model/workout_program.dart';
import 'program_list_screen.dart';
import 'terms_of_service_screen.dart';
import 'privacy_policy_screen.dart';

class ProfileScreen extends StatefulWidget{ 
    final UserProfile userProfile;
    final Function(UserProfile) onProfileUpdated;
    final List<NutritionGoal> allNutritionGoals;
    final List<SleepGoal> allSleepGoals;
    final List<WorkoutGoal> allWorkoutGoals;
    final Function(List<NutritionGoal>) onNutritionGoalsUpdated;
    final Function(List<SleepGoal>) onSleepGoalsUpdated;
    final Function(List<WorkoutGoal>) onWorkoutGoalsUpdated;
    final List<WorkoutProgram> allPrograms;
    final Map<String,List<String>> exerciseMenu;
    final Function(List<WorkoutProgram>) onProgramsUpdated;
    final Function(Map<String,List<String>>) onExerciseMenuUpdated;
    final VoidCallback onBackupRequested;
    final GoogleSignInAccount? googleUser;
    final VoidCallback onSignIn;
    final VoidCallback onSignOut;

    const ProfileScreen({
        super.key,
        required this.userProfile,
        required this.onProfileUpdated,
        required this.allNutritionGoals,
        required this.allSleepGoals,
        required this.allWorkoutGoals,
        required this.onNutritionGoalsUpdated,
        required this.onSleepGoalsUpdated,
        required this.onWorkoutGoalsUpdated,
        required this.allPrograms,
        required this.exerciseMenu,
        required this.onProgramsUpdated,
        required this.onExerciseMenuUpdated,
        required this.onBackupRequested,
        required this.googleUser,
        required this.onSignIn,
        required this.onSignOut,
    });

    @override
    State<ProfileScreen> createState()=>_ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver{
    late UserProfile _userProfileCopy;
    late List<WorkoutProgram> _programs;
    late List<SleepGoal> _sleepGoalsCopy;
    late List<NutritionGoal> _nutritionGoalsCopy;
    late List<WorkoutGoal> _workoutGoalsCopy;

    static const platform=MethodChannel('com.hirotoy.MuscleOne/permission');
    bool _isNotificationGranted=false;
    bool _wasNotificationGrantedPreviously=false;

    @override
    void initState(){
        super.initState();
        _userProfileCopy = widget.userProfile.copyWith();
        _programs=List.of(widget.allPrograms); 
        _sleepGoalsCopy=List.of(widget.allSleepGoals);
        _nutritionGoalsCopy=List.of(widget.allNutritionGoals);
        _workoutGoalsCopy=List.of(widget.allWorkoutGoals);
        WidgetsBinding.instance.addObserver(this);
        _checkNotificationStatus();
    }

    Future<void> _checkNotificationStatus()async{
        String statusString='denied';
        try{
            statusString = await platform.invokeMethod('getNotificationStatus');
        }catch(e){
            print('呼び出しに失敗: $e');
        }
        print('ネイティブ経由で湯得した最新情報: $statusString');
        final bool isGranted=statusString=='granted';

        if(isGranted){
            await _scheduleNotification();
            print('通知をセットしました。完璧！');
        }else{
            await NotificationService().cancelAllNotification();
        }
        if(mounted){
            setState(() {
              _isNotificationGranted=isGranted;
            });
        }
    }

    @override
    void dispose(){
      WidgetsBinding.instance.removeObserver(this);
      super.dispose();
    }

    @override
    void didChangeAppLifecycleState(AppLifecycleState state){
      super.didChangeAppLifecycleState(state);
      //アプリがバックグラウンドから戻ってきた時
      if(state==AppLifecycleState.resumed){
        print('アプリが復帰しました。通知設定を再チェックします。');
        Future.delayed(
            const Duration(milliseconds: 500),
            (){_checkNotificationStatus();},
        );
      }
    }

    Future<void> _checkPermissionAndUpdateState()async{
        String statusString='denied';
        try{
            statusString=await platform.invokeMethod('getNotificationStatus');
        }catch(e){
            print('現在のステータスの取得失敗: $e');
        }
        print('ネイティブ経由で取得した現在のステータス: $statusString');
        final bool isCurrentlyGranted = statusString=='granted';

        if(isCurrentlyGranted && !_wasNotificationGrantedPreviously){
            print('ONからOFFに切り替わったので、通知セットをします。');
            await _scheduleNotification();
            if(mounted){
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('リマインダーをセットしました')),
                );
            }
        }
        if(!isCurrentlyGranted){
            await NotificationService().cancelAllNotification();
        }
        if(mounted){
            setState(() {
              _isNotificationGranted=isCurrentlyGranted;
            });
        }
        _wasNotificationGrantedPreviously=isCurrentlyGranted;
    }

    Future<void> _onSwitchTapped(bool value)async{
        await AppSettings.openAppSettings(type:AppSettingsType.notification);
    }

    Future<void> _scheduleNotification()async{
        await NotificationService().cancelAllNotification();
        await NotificationService().scheduleDailyNotification(
            id: 0, 
            title: 'おはようございます！', 
            body: '今日も体重と睡眠を記録して、いい日のスターを切りましょう！', 
            hour: 6, 
            minute: 0
        );

        await NotificationService().scheduleDailyNotification(
            id: 1, 
            title: '今日も1日お疲れ様でした', 
            body: '食事記録はつけれましたか？明日も応援しています！', 
            hour: 22, 
            minute: 0
        );
    }

    @override
    void didUpdateWidget(covariant ProfileScreen oldWidget){
        super.didUpdateWidget(oldWidget);
        if(widget.userProfile != oldWidget.userProfile){
            setState((){
                _userProfileCopy=widget.userProfile.copyWith();
            });
        }
        if(widget.allSleepGoals != oldWidget.allSleepGoals){
            setState((){
                _sleepGoalsCopy=List.of(widget.allSleepGoals);
            });
        }
        if(widget.allNutritionGoals != oldWidget.allNutritionGoals){
            setState((){
                _nutritionGoalsCopy=List.of(widget.allNutritionGoals);
            });
        }
        if(widget.allWorkoutGoals != oldWidget.allWorkoutGoals){
            setState((){
                _workoutGoalsCopy=List.of(widget.allWorkoutGoals);
            });
        }
        if(widget.allPrograms != oldWidget.allPrograms){
            setState((){
                _programs=List.of(widget.allPrograms);
            });
        }
    }

    void _editName(){
        final controller = TextEditingController(text: widget.userProfile.name);
        showDialog(
            context:context,
            builder:(context)=>AlertDialog(
                backgroundColor: const Color(0xFF1e3a5f),
                title:const Text('ユーザーネームを編集', style:TextStyle(color:Colors.white70)),
                content: TextField(controller:controller, autofocus:true, style:const TextStyle(color:Colors.white)),
                actions:[
                    TextButton(
                        onPressed:()=>Navigator.pop(context),
                        child:const Text('キャンセル', style:TextStyle(color:Colors.white70)),
                    ),
                    TextButton(
                        onPressed:(){
                            final newProfile= _userProfileCopy.copyWith(name: controller.text);
                            print("✅ 1. [ProfileScreen] 変更を通知します。\n$newProfile");
                            widget.onProfileUpdated(newProfile);
                            Navigator.pop(context);
                        },
                        child:const Text('保存', style:TextStyle(color:Colors.white70)),
                    ),
                ],
            ),
        );
    }

    void _editBirthDate()async{
        final pickedDate= await _showCupertinoDateTimePicker(
            initialDate: _userProfileCopy.birthDate ?? DateTime(2000),
            title:'生年月日を選択',
        );
        if (pickedDate != null) {
            final newProfile = _userProfileCopy.copyWith(birthDate: pickedDate);
            print("✅ 1. [ProfileScreen] 変更を通知します。\n$newProfile");
            widget.onProfileUpdated(newProfile);
        }
    }

    void _editHeight(){
        final controller = TextEditingController(text:widget.userProfile.height?.toString() ?? '');
        showDialog(
            context:context,
            builder:(context)=>AlertDialog(
                backgroundColor: const Color(0xFF1e3a5f),
                title: const Text('身長を入力', style:TextStyle(color:Colors.white)),
                content:Row(
                    children:[
                        Expanded(
                            child:TextField(
                                controller:controller,
                                autofocus:true,
                                textAlign:TextAlign.end,
                                keyboardType: TextInputType.number, 
                                style:const TextStyle(color:Colors.white),
                            ),
                        ),
                        const Text('cm', style:TextStyle(color:Colors.white)),
                    ],
                ),
                actions:[
                    TextButton(
                        onPressed:()=>Navigator.pop(context),
                        child:const Text('キャンセル', style:TextStyle(color:Colors.white)),
                    ),
                    TextButton(
                        onPressed:(){
                            final newHeight= double.tryParse(controller.text);
                            final newProfile= _userProfileCopy.copyWith(height:newHeight);
                            print("✅ 1. [ProfileScreen] 変更を通知します。\n$newProfile");
                            widget.onProfileUpdated(newProfile);
                            Navigator.pop(context);
                        },
                        child:const Text('保存', style:TextStyle(color:Colors.white)),
                    ),
                ],
            ),
        );
    }

    void _editGender(){
        _showSelectionDialog(
            '性別を選択',
            ['男性', '女性', 'その他',],
            (selectedValue){
                final newProfile =_userProfileCopy.copyWith(gender:selectedValue);
                print("✅ 1. [ProfileScreen] 変更を通知します。\n$newProfile");
                widget.onProfileUpdated(newProfile);
            }
        );
    }

    void _editActivityLevel(){
        _showSelectionDialog(
            '運動の頻度を選択',
            ['ほぼ運動しない', '週1-2回', '週3-5回', '週6-7回', '毎日ハードに'],
            (selectedValue){
                final newProfile =_userProfileCopy.copyWith(activityLevel:selectedValue);
                print("✅ 1. [ProfileScreen] 変更を通知します。\n$newProfile");
                widget.onProfileUpdated(newProfile);
            }
        );
    }

    void _showSelectionDialog(String title, List<String> options, Function(String) onSelected){
        showDialog(
            context:context,
            builder:(context)=>SimpleDialog(
                backgroundColor: const Color(0xFF1e3a5f),
                title: Text(title, style:const TextStyle(color:Colors.white)),
                children: options.map((option)=>SimpleDialogOption(
                    onPressed:(){
                        onSelected(option);
                        Navigator.pop(context);
                    },
                    child:Text(option, style:const TextStyle(color:Colors.white, fontSize:16)),
                )).toList(),
            ),
        );
    }

    bool isSameDay(DateTime a, DateTime b){
        return a.year==b.year && a.month==b.month && a.day==b.day;
    }

    Future<DateTime?> _showCupertinoDateTimePicker({required DateTime initialDate,required String title}){
        DateTime? tempPickedDate=initialDate;
        return showModalBottomSheet<DateTime>(
            context:context,
            backgroundColor:Colors.transparent,
            builder:(BuildContext builder){
                return Container(
                    height:350,
                    decoration:BoxDecoration(
                        color:Color.fromARGB(255,39,53,75),
                        borderRadius:BorderRadius.only(
                            topLeft:Radius.circular(20.0),
                            topRight:Radius.circular(20.0),
                        ),
                    ),
                    child:Column(
                        children:[
                            SizedBox(
                                height:54,
                                child:Stack(
                                    alignment:Alignment.center,
                                    children:[
                                        Text(title, style:const TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold)),
                                        Row(
                                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                            children:[
                                                CupertinoButton(
                                                    child: const Text('キャンセル', style:TextStyle(color:Colors.white70, fontSize:16)),
                                                    onPressed:()=>Navigator.pop(context),
                                                ),
                                                CupertinoButton(
                                                    child: const Text('完了', style:TextStyle(color:Colors.white70, fontSize:16)),
                                                    onPressed:()=>Navigator.pop(context,tempPickedDate),
                                                ),
                                            ],
                                        ),
                                    ],      
                                ),
                            ),
                            const Divider(height:1, color:Colors.white24),
                            Expanded(
                                child:CupertinoTheme(
                                    data:const CupertinoThemeData(
                                        textTheme:CupertinoTextThemeData(
                                            dateTimePickerTextStyle:TextStyle(color:Colors.white, fontSize:16),
                                        ),
                                    ),
                                    child:CupertinoDatePicker(
                                        mode:CupertinoDatePickerMode.date,
                                        initialDateTime:initialDate,
                                        onDateTimeChanged:(DateTime newDate){
                                            tempPickedDate=newDate;
                                        }
                                    ),
                                ),
                            ),
                        ],
                    ),
                );
            }
        );
    }

    void _showNutritionGoalDialog(){
        showDialog(
            context:context,
            builder:(context){
                //ダイヤログ内の変数とコントローラー
                DateTime startDate=DateTime.now();
                DateTime? endDate;
                bool isEndDateEnabled=false;
                final _caloriesController=TextEditingController();
                final _proteinController=TextEditingController();
                final _fatController=TextEditingController();
                final _carbsController=TextEditingController();
                final _sugarController=TextEditingController();
                final _fiberController=TextEditingController();

                final Map<String,double> defaultValues= _userProfileCopy.gender=='女性'
                    ?   {'calories':1600, 'protein':75, 'fat':40, 'carbs':235, 'sugar':220, 'fiber':15,}
                    :   {'calories':2400, 'protein':150, 'fat':60, 'carbs':315, 'sugar':300, 'fiber':15,};

                void initialLoad(){
                    //目標が存在していたかを確認
                    final dayAtMidnight = DateTime(startDate.year,startDate.month, startDate.day);
                    final existingGoal= _nutritionGoalsCopy.firstWhere(
                        (goal){
                            final startDateAtMidnight = DateTime(goal.startDate.year, goal.startDate.month, goal.startDate.day);
                            if(goal.endDate==null){
                                return !dayAtMidnight.isBefore(startDateAtMidnight);
                            }
                            final endDateAtMidnight = DateTime(goal.endDate!.year, goal.endDate!.month, goal.endDate!.day);
                            return !dayAtMidnight.isBefore(startDateAtMidnight) && !dayAtMidnight.isAfter(endDateAtMidnight);
                        },
                        orElse:()=>NutritionGoal(
                            id:'', startDate:startDate, endDate:null, calories:0, protein:0, fat:0, carbs:0, sugar:0, fiber:0,
                        ),
                    );
                    //検出された値、もしくはorElseで設定した空のデータセットで、目標があったと更新！
                    isEndDateEnabled = existingGoal.endDate != null;
                    endDate=existingGoal.endDate;
                    _caloriesController.text = existingGoal.calories >0 ? existingGoal.calories.toStringAsFixed(0) : '';
                    _proteinController.text = existingGoal.protein >0 ? existingGoal.protein.toStringAsFixed(0) : '';
                    _fatController.text = existingGoal.fat >0 ? existingGoal.fat.toStringAsFixed(0) : '';
                    _carbsController.text = existingGoal.carbs >0 ? existingGoal.carbs.toStringAsFixed(0) : '';
                    _sugarController.text = existingGoal.sugar >0 ? existingGoal.sugar.toStringAsFixed(0) : '';
                    _fiberController.text = existingGoal.fiber >0 ? existingGoal.fiber.toStringAsFixed(0) : '';
                }

                //初回表示時に今日のデータで初期化
                initialLoad();

                return StatefulBuilder(
                    builder:(context, setDialogState){

                        void resetToDefaults(){
                           _caloriesController.text = defaultValues['calories']!.toStringAsFixed(0);
                            _proteinController.text = defaultValues['protein']!.toStringAsFixed(0);
                            _fatController.text = defaultValues['fat']!.toStringAsFixed(0);
                            _carbsController.text = defaultValues['carbs']!.toStringAsFixed(0);
                            _sugarController.text = defaultValues['sugar']!.toStringAsFixed(0);
                            _fiberController.text = defaultValues['fiber']!.toStringAsFixed(0);
                        }

                        void applyDefaultsIfEmpty(){
                            if(_caloriesController.text.isEmpty)_caloriesController.text = defaultValues['calories']!.toStringAsFixed(0);
                            if(_proteinController.text.isEmpty)_proteinController.text = defaultValues['protein']!.toStringAsFixed(0);
                            if(_fatController.text.isEmpty)_fatController.text = defaultValues['fat']!.toStringAsFixed(0);
                            if(_carbsController.text.isEmpty)_carbsController.text = defaultValues['carbs']!.toStringAsFixed(0);
                            if(_sugarController.text.isEmpty)_sugarController.text = defaultValues['sugar']!.toStringAsFixed(0);
                            if(_fiberController.text.isEmpty)_fiberController.text = defaultValues['fiber']!.toStringAsFixed(0);
                        }

                        return AlertDialog(
                            backgroundColor: const Color(0xFF1e3a5f),
                            title: const Text('栄養目標を設定', style:TextStyle(color:Colors.white)),
                            content:SizedBox(
                                width:432,
                                height: 400,
                                child:Column(
                                    mainAxisSize:MainAxisSize.min,
                                    children:[
                                        ListTile(
                                            title: const Text('開始日を設定', style:TextStyle(color:Colors.white)),
                                            trailing:Text(DateFormat('yyyy/MM/dd').format(startDate), style:const TextStyle(color:Colors.white)),
                                            onTap:()async{
                                                final picked=await _showCupertinoDateTimePicker(initialDate:startDate, title:'開始日を選択');
                                                if(picked!=null){
                                                    setDialogState((){
                                                        startDate=picked;
                                                        initialLoad();
                                                    });
                                                }
                                            },
                                        ),
                                        ListTile(
                                            title:const Text('目標日を設定', style:TextStyle(color:Colors.white)),
                                            trailing:Switch(
                                                value:isEndDateEnabled,
                                                onChanged:(value){
                                                    setDialogState((){
                                                        isEndDateEnabled=value;
                                                        if(!value)endDate=null;     //OFFの場合は、endDateをnullに
                                                    });
                                                },
                                            ),
                                        ),
                                        Visibility(
                                            visible: isEndDateEnabled,
                                            child:ListTile(
                                                trailing:Text(endDate!=null 
                                                    ? DateFormat('yyyy/MM/dd').format(endDate!)   
                                                    :'日付を選択',
                                                    style:const TextStyle(color:Colors.white),
                                                ),
                                                onTap:()async{
                                                    final picked=await _showCupertinoDateTimePicker(initialDate:endDate ?? startDate, title:'終了日を選択');
                                                    if(picked!=null && !picked.isBefore(startDate)){
                                                        setDialogState(()=> endDate=picked);
                                                    }
                                                },
                                            ),
                                        ),
                                        const Divider(color:Colors.white24),
                                        Expanded(
                                            flex: 3,
                                            child:SingleChildScrollView(
                                                child: Column(
                                                    children: [
                                                        TextField(controller:_caloriesController, decoration:const InputDecoration(labelText:'カロリー (kcal)', labelStyle: TextStyle(color:Colors.white70)), keyboardType:TextInputType.number, style:const TextStyle(color:Colors.white)),
                                                        TextField(controller:_proteinController, decoration:const InputDecoration(labelText:'タンパク質 (g)', labelStyle: TextStyle(color:Colors.white70)), keyboardType:TextInputType.number, style:const TextStyle(color:Colors.white)),
                                                        TextField(controller:_fatController, decoration:const InputDecoration(labelText:'脂質 (g)', labelStyle: TextStyle(color:Colors.white70)), keyboardType:TextInputType.number, style:const TextStyle(color:Colors.white)),
                                                        TextField(controller:_carbsController, decoration:const InputDecoration(labelText:'炭水化物 (g)', labelStyle: TextStyle(color:Colors.white70)), keyboardType:TextInputType.number, style:const TextStyle(color:Colors.white)),
                                                        TextField(controller:_sugarController, decoration:const InputDecoration(labelText:'糖質 (g)', labelStyle: TextStyle(color:Colors.white70)), keyboardType:TextInputType.number, style:const TextStyle(color:Colors.white)),
                                                        TextField(controller:_fiberController, decoration:const InputDecoration(labelText:'食物繊維 (g)', labelStyle: TextStyle(color:Colors.white70)), keyboardType:TextInputType.number, style:const TextStyle(color:Colors.white)),    
                                                    ],
                                                ),
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                            actions:[
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children:[
                                        TextButton(
                                            onPressed:(){
                                                setDialogState(resetToDefaults);
                                            },
                                            child:const Text('標準値',style:TextStyle(color:Colors.white)),
                                        ),
                                        TextButton(
                                            onPressed:()=>Navigator.pop(context),
                                            child:const Text('キャンセル',style:TextStyle(color:Colors.white)),
                                        ),
                                        ElevatedButton(
                                            onPressed:(){
                                                applyDefaultsIfEmpty(); //保存前にデフォルト値で空欄を埋める。

                                                //日付を正規化
                                                final cleanStartDate = DateTime(startDate.year, startDate.month, startDate.day);
                                                final cleanEndDate = isEndDateEnabled && endDate!=null
                                                    ? DateTime(endDate!.year, endDate!.month, endDate!.day)
                                                    : null;

                                                final newGoal=NutritionGoal(
                                                    id: const Uuid().v4(),
                                                    startDate: cleanStartDate,
                                                    endDate: cleanEndDate,
                                                    calories:double.tryParse(_caloriesController.text) ?? 0,
                                                    protein:double.tryParse(_proteinController.text) ?? 0,
                                                    fat:double.tryParse(_fatController.text) ?? 0,
                                                    carbs:double.tryParse(_carbsController.text) ?? 0,
                                                    sugar:double.tryParse(_sugarController.text) ?? 0,
                                                    fiber:double.tryParse(_fiberController.text) ?? 0,
                                                );

                                                var originalGoals=List.of(widget.allNutritionGoals);
                                                List<NutritionGoal> finalGoals=[];

                                                //既存の目標を１個づつチェック
                                                for(final existingGoal in originalGoals){
                                                    final existingStartDate = DateTime(existingGoal.startDate.year, existingGoal.startDate.month, existingGoal.startDate.day);
                                                    final existingEndDate = existingGoal.endDate != null
                                                        ? DateTime(existingGoal.endDate!.year, existingGoal.endDate!.month, existingGoal.endDate!.day)
                                                        : null;
                                                    
                                                    //期間が重なっているのか判定
                                                    bool startsBeforeNewGoalEnds= cleanEndDate==null || existingStartDate.isBefore(cleanEndDate.add(const Duration(days:1)));
                                                    bool endsAfterNewGoalStarts = existingEndDate == null || existingEndDate.isAfter(cleanStartDate.subtract(const Duration(days: 1)));
                                                    bool hasOverlap = startsBeforeNewGoalEnds && endsAfterNewGoalStarts;

                                                    if(!hasOverlap){
                                                        //期間が重なっていない場合は、既存目標をそのままに
                                                        finalGoals.add(existingGoal);
                                                    }else{
                                                        //1.「前」の部分が存在するのかチェック
                                                        if(existingStartDate.isBefore(cleanStartDate)){
                                                            finalGoals.add(
                                                                existingGoal.copyWith(
                                                                    endDate:cleanStartDate.subtract(const Duration(days:1)),
                                                                    isEndDateNull: false,
                                                                )
                                                            );
                                                        }
                                                        //2.「後」の部分があるかチェック
                                                        if(cleanEndDate!=null && (existingEndDate == null || existingEndDate.isAfter(cleanEndDate))){
                                                            finalGoals.add(
                                                                existingGoal.copyWith(
                                                                    startDate:cleanEndDate.add(const Duration(days:1)),
                                                                )
                                                            );
                                                        }
                                                    } 
                                                }
                                                //最後に新規目標を追加
                                                finalGoals.add(newGoal);
                                                widget.onNutritionGoalsUpdated(finalGoals);
                                                Navigator.pop(context);
                                            },
                                            child:const Text('保存'),
                                        ),
                                    ],
                                ),
                            ],
                        );
                    }
                );
            }
        );
    }

    void _showSleepGoalDialog(){
        showDialog(
            context:context,
            builder:(context){
                //ダイヤログ内の変数とコントローラー
                DateTime startDate=DateTime.now();
                DateTime? endDate;
                bool isEndDateEnabled=false;
                final hoursController=TextEditingController();

                void loadGoalForDate(DateTime date){
                    final existingGoal=_sleepGoalsCopy.firstWhere(
                        (goal)=>date.isAfter(goal.startDate.subtract(const Duration(seconds:1))) &&
                                (goal.endDate==null || date.isBefore(goal.endDate!.add(const Duration(seconds:1)))),
                        orElse:()=>SleepGoal(id: '', startDate: date, endDate:null, hours:0),
                    );
                    isEndDateEnabled=existingGoal.endDate != null;
                    endDate=existingGoal.endDate;
                    hoursController.text=existingGoal.hours >0 ? existingGoal.hours.toStringAsFixed(1) :'';
                }
                
                loadGoalForDate(startDate);

                return StatefulBuilder(
                    builder:(context, setDialogState){
                        return AlertDialog(
                            backgroundColor:const Color(0xFF1e3a5f),
                            title:const Text('睡眠目標を設定', style:TextStyle(color:Colors.white)),
                            content:SizedBox(
                                width:300,
                                child:Column(
                                    mainAxisSize:MainAxisSize.min,
                                    children:[
                                        ListTile(
                                            title: const Text('開始日を設定', style:TextStyle(color:Colors.white)),
                                            trailing:Text(DateFormat('yyyy/MM/dd').format(startDate), style:const TextStyle(color:Colors.white)),
                                            onTap:()async{
                                                final picked=await _showCupertinoDateTimePicker(initialDate:startDate, title:'開始日を選択');
                                                if(picked!=null){
                                                    setDialogState((){
                                                        startDate=picked;
                                                        loadGoalForDate(startDate);
                                                    });
                                                }
                                            },
                                        ),
                                        ListTile(
                                            title:const Text('目標日を設定', style:TextStyle(color:Colors.white)),
                                            trailing:Switch(
                                                value:isEndDateEnabled,
                                                onChanged:(value){
                                                    setDialogState((){
                                                        isEndDateEnabled=value;
                                                        if(!value)endDate=null;     //OFFの場合は、endDateをnullに
                                                    });
                                                },
                                            ),
                                        ),
                                        Visibility(
                                            visible: isEndDateEnabled,
                                            child:ListTile(
                                                trailing:Text(endDate!=null 
                                                    ? DateFormat('yyyy/MM/dd').format(endDate!)   
                                                    :'日付を選択',
                                                    style:const TextStyle(color:Colors.white),
                                                ),
                                                onTap:()async{
                                                    final picked=await _showCupertinoDateTimePicker(initialDate:endDate ?? startDate, title:'終了日を選択');
                                                    if(picked!=null && !picked.isBefore(startDate)){
                                                        setDialogState(()=> endDate=picked);
                                                    }
                                                },
                                            ),
                                        ),
                                        const Divider(color:Colors.white24),
                                        TextField(controller:hoursController, decoration:const InputDecoration(labelText:'睡眠時間 (時間)', labelStyle: TextStyle(color:Colors.white)), keyboardType:TextInputType.number, style:const TextStyle(color:Colors.white)),
                                    ],
                                ),
                            ),
                            actions:[
                                Row(
                                    children:[
                                        TextButton(
                                            onPressed:(){
                                                setDialogState(()=> hoursController.text='7.0');
                                            },
                                            child:const Text('標準値',style:TextStyle(color:Colors.white)),
                                        ),
                                        TextButton(
                                            onPressed:()=>Navigator.pop(context),
                                            child:const Text('キャンセル',style:TextStyle(color:Colors.white)),
                                        ),
                                        ElevatedButton(
                                            onPressed:(){
                                                if(hoursController.text.isEmpty) hoursController.text='7.0';
                                                //日付を正規化
                                                final cleanStartDate = DateTime(startDate.year, startDate.month, startDate.day);
                                                final cleanEndDate = isEndDateEnabled && endDate!=null
                                                    ? DateTime(endDate!.year, endDate!.month, endDate!.day)
                                                    : null;

                                                final newGoal=SleepGoal(
                                                    id: const Uuid().v4(),
                                                    startDate: cleanStartDate,
                                                    endDate: cleanEndDate,
                                                    hours:double.tryParse(hoursController.text) ?? 7.0,
                                                );

                                                var originalGoals=List.of(widget.allSleepGoals);
                                                List<SleepGoal> finalGoals=[];

                                                //既存の目標を１個づつチェック
                                                for(final existingGoal in originalGoals){
                                                    final existingStartDate = DateTime(existingGoal.startDate.year, existingGoal.startDate.month, existingGoal.startDate.day);
                                                    final existingEndDate = existingGoal.endDate != null
                                                        ? DateTime(existingGoal.endDate!.year, existingGoal.endDate!.month, existingGoal.endDate!.day)
                                                        : null;
                                                    
                                                    //期間が重なっているのか判定
                                                    bool startsBeforeNewGoalEnds= cleanEndDate==null || existingStartDate.isBefore(cleanEndDate.add(const Duration(days:1)));
                                                    bool endsAfterNewGoalStarts = existingEndDate == null || existingEndDate.isAfter(cleanStartDate.subtract(const Duration(days: 1)));
                                                    bool hasOverlap = startsBeforeNewGoalEnds && endsAfterNewGoalStarts;

                                                    if(!hasOverlap){
                                                        //期間が重なっていない場合は、既存目標をそのままに
                                                        finalGoals.add(existingGoal);
                                                    }else{
                                                        //期間の重なりがある場合は、重ならない部分だけを残す。
                                                        //1.「前」の部分が存在するのかチェック
                                                        if(existingStartDate.isBefore(cleanStartDate)){
                                                            finalGoals.add(
                                                                existingGoal.copyWith(
                                                                    endDate:cleanStartDate.subtract(const Duration(days:1)),
                                                                    isEndDateNull: false,
                                                                )
                                                            );
                                                        }
                                                        //2.「後」の部分があるかチェック
                                                        if(cleanEndDate!=null && (existingEndDate == null || existingEndDate.isAfter(cleanEndDate))){
                                                            finalGoals.add(
                                                                existingGoal.copyWith(
                                                                    startDate:cleanEndDate.add(const Duration(days:1)),
                                                                )
                                                            );
                                                        }
                                                    } 
                                                }
                                                //最後に新規目標を追加
                                                finalGoals.add(newGoal);
                                                widget.onSleepGoalsUpdated(finalGoals);
                                                Navigator.pop(context);
                                            },
                                            child:const Text('保存'),
                                        ),
                                    ],
                                ),
                            ],
                        );
                    }
                );
            }
        );
    }

    void _showWorkoutGoalDialog(){
        showDialog(
            context:context,
            builder:(context){
                //ダイヤログ内の変数とコントローラー
                DateTime startDate=DateTime.now();
                DateTime? endDate;
                bool isEndDateEnabled=false;
                WorkoutGoalType selectedType=WorkoutGoalType.exerciseCount;
                final valueController=TextEditingController();

                double getDefaultValue(){
                    return _userProfileCopy.gender=='女性'  ?3.0  :4.0 ;
                }

                void loadGoalForDate(DateTime date){
                    final existingGoal=_workoutGoalsCopy.firstWhere(
                        (goal)=>date.isAfter(goal.startDate.subtract(const Duration(seconds:1))) &&
                                (goal.endDate==null || date.isBefore(goal.endDate!.add(const Duration(seconds:1)))),
                        orElse:()=>WorkoutGoal(id: '', startDate: date, endDate:null, goalType:selectedType, value:0),
                    );
                    isEndDateEnabled=existingGoal.endDate != null;
                    endDate=existingGoal.endDate;
                    selectedType=existingGoal.goalType;
                    valueController.text=existingGoal.value >0 ? existingGoal.value.toStringAsFixed(1) :'';
                }
                
                loadGoalForDate(startDate);

                String getUnitForType(WorkoutGoalType type){
                    switch(type){
                        case WorkoutGoalType.exerciseCount: return '合計種目';
                        case WorkoutGoalType.totalVolume: return 'トレーニングボリューム (kg)';
                        case WorkoutGoalType.totalSets: return '合計セット';
                    }
                }

                return StatefulBuilder(
                    builder:(context, setDialogState){
                        return AlertDialog(
                            backgroundColor:const Color(0xFF1e3a5f),
                            title:const Text('トレーニング目標を設定', style:TextStyle(color:Colors.white)),
                            content:SizedBox(
                                width:300,
                                child:SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize:MainAxisSize.min,
                                      children:[
                                          ListTile(
                                              title: const Text('開始日を設定', style:TextStyle(color:Colors.white)),
                                              trailing:Text(DateFormat('yyyy/MM/dd').format(startDate), style:const TextStyle(color:Colors.white)),
                                              onTap:()async{
                                                  final picked=await _showCupertinoDateTimePicker(initialDate:startDate, title:'開始日を選択');
                                                  if(picked!=null){
                                                      setDialogState((){
                                                          startDate=picked;
                                                          loadGoalForDate(startDate);
                                                      });
                                                  }
                                              },
                                          ),
                                          ListTile(
                                              title:const Text('目標日を設定', style:TextStyle(color:Colors.white)),
                                              trailing:Switch(
                                                  value:isEndDateEnabled,
                                                  onChanged:(value){
                                                      setDialogState((){
                                                          isEndDateEnabled=value;
                                                          if(!value)endDate=null;     //OFFの場合は、endDateをnullに
                                                      });
                                                  },
                                              ),
                                          ),
                                          Visibility(
                                              visible: isEndDateEnabled,
                                              child:ListTile(
                                                  trailing:Text(endDate!=null 
                                                      ? DateFormat('yyyy/MM/dd').format(endDate!)   
                                                      :'日付を選択',
                                                      style:const TextStyle(color:Colors.white),
                                                  ),
                                                  onTap:()async{
                                                      final picked=await _showCupertinoDateTimePicker(initialDate:endDate ?? startDate, title:'終了日を選択');
                                                      if(picked!=null && !picked.isBefore(startDate)){
                                                          setDialogState(()=> endDate=picked);
                                                      }
                                                  },
                                              ),
                                          ),
                                          const Divider(color:Colors.white24),
                                          DropdownButton<WorkoutGoalType>(
                                              value:selectedType,
                                              isExpanded:true,
                                              dropdownColor: const Color(0xFF1e3a5f),
                                              borderRadius:BorderRadius.circular(20.0),
                                              style:const TextStyle(color:Colors.white, fontSize:17),
                                              onChanged:(WorkoutGoalType? newValue){
                                                  if(newValue != null){
                                                      setDialogState(()=> selectedType=newValue);
                                                  }
                                              },
                                              items:WorkoutGoalType.values.map<DropdownMenuItem<WorkoutGoalType>>((WorkoutGoalType value){
                                                  final textMap={
                                                      WorkoutGoalType.exerciseCount:'種目数',
                                                      WorkoutGoalType.totalVolume:'総トレーニングボリューム',
                                                      WorkoutGoalType.totalSets:'総セット数',
                                                  };
                                                  return DropdownMenuItem<WorkoutGoalType>(
                                                      value:value,
                                                      child:Text(textMap[value]!),
                                                  );
                                              }).toList(),
                                          ),
                                          TextField(controller:valueController, decoration:InputDecoration(labelText:'${getUnitForType(selectedType)}', labelStyle: TextStyle(color:Colors.white70, fontSize:16)), keyboardType:TextInputType.number, style:const TextStyle(color:Colors.white, fontSize:16)),
                                      ],
                                  ),
                                ),
                            ),
                            actions:[
                                Row(
                                    children:[
                                        TextButton(
                                            onPressed:(){
                                                setDialogState(()=> valueController.text=getDefaultValue().toStringAsFixed(0));
                                            },
                                            child:const Text('標準値',style:TextStyle(color:Colors.white)),
                                        ),
                                        Expanded(child:Container()),
                                        TextButton(
                                            onPressed:()=>Navigator.pop(context),
                                            child:const Text('キャンセル',style:TextStyle(color:Colors.white)),
                                        ),
                                        ElevatedButton(
                                            onPressed:(){
                                                if(valueController.text.isEmpty) valueController.text=getDefaultValue().toStringAsFixed(0);
                                                //日付を正規化
                                                final cleanStartDate = DateTime(startDate.year, startDate.month, startDate.day);
                                                final cleanEndDate = isEndDateEnabled && endDate!=null
                                                    ? DateTime(endDate!.year, endDate!.month, endDate!.day)
                                                    : null;

                                                final newGoal=WorkoutGoal(
                                                    id: const Uuid().v4(),
                                                    startDate: cleanStartDate,
                                                    endDate: cleanEndDate,
                                                    goalType: selectedType,
                                                    value:double.tryParse(valueController.text) ?? getDefaultValue(),
                                                );

                                                var originalGoals=List.of(widget.allWorkoutGoals);
                                                List<WorkoutGoal> finalGoals=[];

                                                //既存の目標を１個づつチェック
                                                for(final existingGoal in originalGoals){
                                                    final existingStartDate = DateTime(existingGoal.startDate.year, existingGoal.startDate.month, existingGoal.startDate.day);
                                                    final existingEndDate = existingGoal.endDate != null
                                                        ? DateTime(existingGoal.endDate!.year, existingGoal.endDate!.month, existingGoal.endDate!.day)
                                                        : null;
                                                    
                                                    //期間が重なっているのか判定
                                                    bool startsBeforeNewGoalEnds= cleanEndDate==null || existingStartDate.isBefore(cleanEndDate.add(const Duration(days:1)));
                                                    bool endsAfterNewGoalStarts = existingEndDate == null || existingEndDate.isAfter(cleanStartDate.subtract(const Duration(days: 1)));
                                                    bool hasOverlap = startsBeforeNewGoalEnds && endsAfterNewGoalStarts;

                                                    if(!hasOverlap){
                                                        //期間が重なっていない場合は、既存目標をそのままに
                                                        finalGoals.add(existingGoal);
                                                    }else{
                                                        //期間の重なりがある場合は、重ならない部分だけを残す。
                                                        //1.「前」の部分が存在するのかチェック
                                                        if(existingStartDate.isBefore(cleanStartDate)){
                                                            finalGoals.add(
                                                                existingGoal.copyWith(
                                                                    endDate:cleanStartDate.subtract(const Duration(days:1)),
                                                                    isEndDateNull: false,
                                                                )
                                                            );
                                                        }
                                                        //2.「後」の部分があるかチェック
                                                        if(cleanEndDate!=null && (existingEndDate == null || existingEndDate.isAfter(cleanEndDate))){
                                                            finalGoals.add(
                                                                existingGoal.copyWith(
                                                                    startDate:cleanEndDate.add(const Duration(days:1)),
                                                                )
                                                            );
                                                        }
                                                    } 
                                                }
                                                //最後に新規目標を追加
                                                finalGoals.add(newGoal);
                                                widget.onWorkoutGoalsUpdated(finalGoals);
                                                Navigator.pop(context);
                                            },
                                            child:const Text('保存'),
                                        ),
                                    ],
                                ),
                            ],
                        );
                    }
                );
            }
        );
    }

    Future<void> _handleBackupTap()async{
      widget.onBackupRequested();
    }

    @override
    Widget build(BuildContext context){
        return Scaffold(
            backgroundColor:const Color(0xFF000020),
            body:SafeArea(
                child:ListView(
                    padding:const EdgeInsets.all(16.0),
                    children:[
                        _buildHeader(),
                        const SizedBox(height:32),

                        //カテゴリ１
                        _buildSelectionHeader('基本プロフィール情報'),
                        _buildProfileListTile(
                            title:'生年月日',
                            value:_userProfileCopy.birthDate != null
                                ? DateFormat('yyyy/MM/dd').format(_userProfileCopy.birthDate!)
                                : '未設定',
                            onTap:_editBirthDate,
                        ),
                        _buildProfileListTile(
                            title:'身長',
                            value:_userProfileCopy.height != null
                                ? '${_userProfileCopy.height}cm'
                                : '未設定',
                            onTap:_editHeight,
                        ),
                        _buildProfileListTile(
                            title:'性別',
                            value:_userProfileCopy.gender ?? '未設定',
                            onTap:_editGender,
                        ),
                        _buildProfileListTile(
                            title:'活動レベル',
                            value:_userProfileCopy.activityLevel ?? '未設定',
                            onTap:_editActivityLevel,
                        ),
                        const SizedBox(height:16),
                        _buildSelectionHeader('目標設定とプログラム編集'),
                        _buildProfileListTile(
                            title:'トレーニング目標',
                            value:'',
                            onTap:(){
                                _showWorkoutGoalDialog();
                                setState((){});
                            },
                        ),
                        _buildProfileListTile(
                            title:'トレーニングプログラム',
                            value:'',
                            onTap:(){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder:(context)=>ProgramListScreen(
                                            allPrograms:_programs,
                                            exerciseMenu:widget.exerciseMenu,
                                            onProgramsUpdated:(updatedPrograms){
                                            widget.onProgramsUpdated(updatedPrograms);
                                            setState((){
                                                _programs=updatedPrograms;
                                            });
                                            },
                                            onExerciseMenuUpdated:widget.onExerciseMenuUpdated,
                                            isForSelection:false, //編集モードで開く。
                                        ),
                                    ),
                                );
                            }
                        ),
                        _buildProfileListTile(
                            title:'栄養目標',
                            value:'',
                            onTap:(){
                                _showNutritionGoalDialog();
                                setState((){});
                            },
                        ),
                        _buildProfileListTile(
                            title:'睡眠目標',
                            value:'',
                            onTap:(){
                                _showSleepGoalDialog();
                                setState((){});
                            },
                        ),
                        const SizedBox(height:16),
                        _buildSelectionHeader('アプリ設定とその他'),
                        Card(
                            color:const Color(0xFF0a1931),
                            margin:const EdgeInsets.only(bottom:8),
                            child:SwitchListTile(
                                title:const Text('通知を許可', style:TextStyle(color:Colors.white, fontSize:16)),
                                value:_isNotificationGranted,
                                onChanged: _onSwitchTapped,
                                activeColor: Colors.blueAccent,
                            ),
                        ),
                        Card(
                            color:const Color(0xFF0a1931),
                            margin:const EdgeInsets.only(bottom:8),
                            child:SizedBox(
                                height:56,
                                child:Padding(
                                    padding:EdgeInsets.symmetric(horizontal:16.0),
                                    child:Row(
                                        children:[
                                            Text('Proプラン', style:TextStyle(color:Colors.white, fontSize:16)),
                                            const Spacer(),
                                            Text('現在無料で開放中', style:TextStyle(color:Colors.white, fontSize:13)),
                                        ],
                                    ),
                                ),
                            ),
                        ),
                        _buildProfileListTile(
                          title: 'データ連携', 
                          value: 'バックアップ', 
                          onTap: _handleBackupTap,
                        ),
                        _buildProfileListTile(
                            title:'利用規約',
                            value:'',
                            onTap:(){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder:(context)=>const TermsOfServiceScreen()),
                                );
                            },
                        ),
                        _buildProfileListTile(
                            title:'プライバシーポリシー',
                            value:'',
                            onTap:(){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder:(context)=>const PrivacyPolicyScreen()),
                                );
                            }
                        ),
                        _buildProfileListTile(
                            title:'お問い合わせ',
                            value:'',
                            onTap:()async{
                                final Uri url=Uri.parse('https://forms.gle/Wu5DwEVJaJvqQc2o8');
                                if(!await launchUrl(url)){
                                    print('URLを開けませんでした。$url');
                                }
                            },
                        ),
                        const SizedBox(height:40),
                    ],
                ),
            ),
        );
    }

    Widget _buildHeader(){
        return Row(
            children:[
                const CircleAvatar(
                    radius:40,
                    backgroundColor:Color(0xFF0a1931),
                    child:Icon(Icons.person, size:50, color:Colors.white70),
                ),
                const SizedBox(width:16),
                GestureDetector(
                    onTap:_editName,
                    child:Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                        children:[
                            Text(
                                _userProfileCopy.name, 
                                style:const TextStyle(color:Colors.white, fontSize:22, fontWeight:FontWeight.bold),
                            ),
                            Text(
                                'ID: ${_userProfileCopy.id.substring(0,10)}',
                                style:const TextStyle(color:Colors.white54, fontSize:14),
                            ),
                        ],
                    ),
                ),
                Spacer(),
                (widget.googleUser != null)
                  ? TextButton(
                        onPressed: (){
                            showDialog(context: context, builder: (context)=>AlertDialog(
                                title:const Text('ログアウト'),
                                content:Text('${widget.googleUser!.email}からログアウトしますか？'),
                                actions: [
                                    TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('キャンセル')),
                                    TextButton(onPressed: (){
                                        widget.onSignOut();
                                        Navigator.pop(context);
                                    }, child: Text('ログアウト')),
                                ],
                            ));
                        }, 
                        child: const Text('googleログイン済'),
                    )
                  : TextButton(onPressed:widget.onSignIn, child: const Text('googleでログイン')),
            ]
        );
    }

    Widget _buildSelectionHeader(String title){
        return Padding(
            padding:const EdgeInsets.only(bottom:10),
            child:Text(
                title,
                style:const TextStyle(color:Colors.white, fontSize:18, fontWeight:FontWeight.bold),
            ),
        );
    }

    Widget _buildProfileListTile({required String title, required String value, required VoidCallback onTap}){
        return Card(
            color:const Color(0xFF0a1931),
            margin:const EdgeInsets.only(bottom:8),
            child:ListTile(
                title: Text(title, style:const TextStyle(color:Colors.white, fontSize:16)),
                trailing:Row(
                    mainAxisSize:MainAxisSize.min,
                    children:[
                        Text(value, style:const TextStyle(color:Colors.white70, fontSize:16)),
                        const SizedBox(width:8),
                        const Icon(Icons.chevron_right, color:Colors.white54),
                    ],
                ),
                onTap:onTap,
            ),
        );
    }
}