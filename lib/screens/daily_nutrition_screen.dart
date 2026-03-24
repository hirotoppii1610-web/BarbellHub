import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../model/daily_nutrition.dart';
import '../model/logged_food.dart';
import '../model/nutrition_goal.dart';
import '../model/food_item.dart';
import '../model/history_log.dart';
import 'food_select_screen.dart'; 
import 'goal_setting_screen.dart';

class DailyNutritionScreen extends StatefulWidget{
  final DailyNutrition nutritiondata;
  final List<FoodItem> allMyFoods;
  final List<NutritionGoal> allNutritionGoals;
  final Function(DailyNutrition) onNutritionUpdated;
  final Future<List<HistoryLog>> Function() onHistoryReloadRequested;
  final Function(List<FoodItem>) onMyFoodsUpdated;
  final Function(List<NutritionGoal>) onNutritionGoalsUpdated;
  final List<HistoryLog> historyList;

  const DailyNutritionScreen({
    super.key, 
    required this.nutritiondata,
    required this.allMyFoods,
    required this.allNutritionGoals,
    required this.onNutritionUpdated,
    required this.onHistoryReloadRequested,
    required this.onMyFoodsUpdated,
    required this.onNutritionGoalsUpdated,
    required this.historyList,
  });

  @override
  State<DailyNutritionScreen> createState() => _DailyNutritionScreenState();
}

class _DailyNutritionScreenState extends State<DailyNutritionScreen>{

  late List<LoggedFood> _todayNutritionCopy;
  late List<FoodItem> _myFoodsCopy;
  late List<NutritionGoal> _allNutritionGoalsCopy;
  late List<HistoryLog> _historyListCopy;
  NutritionGoal? _activeGoal;

  //食事記録出力ボタンの判定チェッカー
  bool _showFoodList=false;

  @override
  void initState(){
    super.initState();
    _todayNutritionCopy=List.of(widget.nutritiondata.todaysTotalLoggedFoods);
    _myFoodsCopy=List.of(widget.allMyFoods);
    _allNutritionGoalsCopy=List.of(widget.allNutritionGoals);
    _historyListCopy=List.of(widget.historyList);
    _determineActiveGoal();
  }

  @override
  void didUpdateWidget(covariant DailyNutritionScreen oldWidget){
    super.didUpdateWidget(oldWidget);
    if(widget.allNutritionGoals != oldWidget.allNutritionGoals){
      setState((){
        _allNutritionGoalsCopy=List.of(widget.allNutritionGoals);
        _determineActiveGoal();
      });
    }
  }

  void _handlePop(){
    final updatedNutrition=widget.nutritiondata.copyWith(
      todaysTotalLoggedFoods:_todayNutritionCopy,
    );
    Navigator.pop(context, updatedNutrition);
  }

  void _addFoodsFromCart() async{
    //食品選択画面に行って「かご」が帰ってくるのを待つ。
    final List<LoggedFood>? shoppingCart=await Navigator.push(
      context,
      MaterialPageRoute(builder: (context)=> FoodSelectScreen(
        allMyFoods:_myFoodsCopy,
        onMyFoodsUpdated:(updatedMyFoods){
          widget.onMyFoodsUpdated(updatedMyFoods);
          setState((){
            _myFoodsCopy=updatedMyFoods;
          });
        },
        historyList:_historyListCopy,
      )),
    );
    if (shoppingCart != null && shoppingCart.isNotEmpty){      //一個目の条件は、そもそも買い物かごがあるのか、
      setState(() {                                           //二個目の条件は、その中身が空かどうか
        _todayNutritionCopy.addAll(shoppingCart);
      });
      _notifyParentWithUpdates();
    }
  }

  void _determineActiveGoal(){
    final allGoals= _allNutritionGoalsCopy;
    NutritionGoal? newActiveGoal;
    if (allGoals.isNotEmpty){
      allGoals.sort((a,b)=>b.startDate.compareTo(a.startDate));
      final today = widget.nutritiondata.day;
      final todayAtMidnight = DateTime(today.year, today.month, today.day);
      newActiveGoal=allGoals.firstWhereOrNull(
        (goal){
          final startDateAtMidnight = DateTime(goal.startDate.year, goal.startDate.month, goal.startDate.day);
          final isAfterStartDate = !todayAtMidnight.isBefore(startDateAtMidnight);
          bool isBeforeEndDate = true;
          if(goal.endDate != null){
            final endDateAtMidnight = DateTime(goal.endDate!.year, goal.endDate!.month, goal.endDate!.day);
            isBeforeEndDate = !todayAtMidnight.isAfter(endDateAtMidnight);
          }
          return isAfterStartDate && isBeforeEndDate;
        }
      );
    }
    setState(() {
      _activeGoal=newActiveGoal;
    });
  }

  void _notifyParentWithUpdates()async{            //こいつは知らせるだけのメソッド、組み換えは各機能（編集と削除）内で行われてから、こいつを呼び出す。
    final updatedNutritionForDay=widget.nutritiondata.copyWith(
      todaysTotalLoggedFoods: _todayNutritionCopy,
    );
    widget.onNutritionUpdated(updatedNutritionForDay);
    final newHistory= await widget.onHistoryReloadRequested();
    setState((){
      _historyListCopy= newHistory;
    });
  } 

  void _handleEditFoodLog(LoggedFood foodToEdit){
    final percentagecontroller= TextEditingController(text: foodToEdit.percentage.toString());
    showDialog(
      context:context,
      builder:(context)=>AlertDialog(
        backgroundColor:const Color(0xFF1e3a5f),
        title:Text(foodToEdit.foodItem.name, style:const TextStyle(color:Colors.white)),
        content:TextFormField(
          controller:percentagecontroller,
          autofocus:true,
          style:const TextStyle(color:Colors.white),
          decoration: const InputDecoration(
            labelText:'食べた量',
            labelStyle:const TextStyle(color:Colors.white),
          ),
          keyboardType: TextInputType.number,
        ),
        actions:[
            TextButton(
              onPressed:()=>Navigator.pop(context),
              child:const Text('キャンセル', style:TextStyle(color:Colors.white),),
            ),
            TextButton(
              child:const Text('更新', style:TextStyle(color:Colors.white)),
              onPressed:(){
                final newPercentage=double.tryParse(percentagecontroller.text) ?? foodToEdit.percentage;
                setState((){
                  final index=_todayNutritionCopy.indexOf(foodToEdit);
                  if (index!=-1){
                    _todayNutritionCopy[index]=foodToEdit.copyWith(percentage: newPercentage);
                  }
                });
                _notifyParentWithUpdates();
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }

  void _handleDeleteFoodLog(LoggedFood foodToDelete){
    showDialog(
      context:context,
      builder:(context)=>AlertDialog(
        backgroundColor:const Color(0xFF1e3a5f),
        title:const Text('確認', style:TextStyle(color: Colors.white)),
        content:Text("${foodToDelete.foodItem.name}を削除しますか？", style:const TextStyle(color:Colors.white)),
        actions:[
          TextButton(
            onPressed:()=>Navigator.pop(context),
            child:const Text('キャンセル', style:TextStyle(color:Colors.white),),
          ),
          TextButton(
            child:const Text('削除', style:TextStyle(color:Colors.white)),
            onPressed:(){
              setState((){
                _todayNutritionCopy.remove(foodToDelete);
              });
              _notifyParentWithUpdates();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    final displayedDate=DateFormat('M月d日 (E)', 'ja_JP').format(widget.nutritiondata.day);
    final bool isDefaultGoal=_activeGoal==null;  //設定済みの目標がありますか？という質問全体が、isDefaultGoal
    //trueなら、目標なし。falseなら目標が設定されている。
    final NutritionGoal defaultGoal=_activeGoal ?? NutritionGoal(
      id: 'default', 
      startDate: DateTime.now(), 
      endDate: DateTime(2040),
      calories: 2200, 
      protein: 100, 
      fat: 73.3, 
      carbs: 285, 
      sugar: 270, 
      fiber: 10,
    );
    final currentNutritionState=DailyNutrition(
      day:widget.nutritiondata.day,
      todaysTotalLoggedFoods:_todayNutritionCopy,
    );

    //アニメーション計算ようの画面サイズ
    final screenSize=MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvoked: (didpop){
        if (didpop)return;
        _handlePop();
      },
      child:Scaffold(
        backgroundColor:const Color(0xFF000020),
        appBar: AppBar(
          leading: IconButton(
            onPressed:_handlePop,
            icon:Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: Text('${displayedDate}', style:const TextStyle(color:Colors.white, fontSize:18 ,fontWeight:FontWeight.bold)),
          backgroundColor: Colors.green.withOpacity(0.9),
          actions: [
            IconButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> GoalSettingScreen(
                    allNutritionGoals:_allNutritionGoalsCopy,
                    onNutritionGoalsUpdated:(updatedNutritionGoals){
                      widget.onNutritionGoalsUpdated(updatedNutritionGoals);
                      setState((){
                        _allNutritionGoalsCopy=updatedNutritionGoals;
                      });
                      _determineActiveGoal();
                    }
                  )),
                );
              }, 
              icon: Icon(Icons.settings, color:Colors.white),
            ),
          ],
        ),
        body:Stack(
            children:[
              AnimatedAlign(
                alignment: _showFoodList 
                              ? Alignment.topCenter
                              : Alignment.center,
                duration: const Duration(milliseconds:400),
                curve:Curves.easeInOut,
                child:SingleChildScrollView(
                  child:Column(
                    mainAxisSize:MainAxisSize.min,
                    children:[
                      Padding(
                        padding:const EdgeInsets.only(top:16, left:8, right:8),
                        child:Row(
                          mainAxisSize:MainAxisSize.min,
                          children:[
                            SizedBox(
                              width:180, 
                              child: _buildCalorieCard(defaultGoal,isDefaultGoal, currentNutritionState),
                            ),
                            Expanded(
                              child: SizedBox(
                                height:300,
                                child: _buildPfcCard(defaultGoal,isDefaultGoal, currentNutritionState),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //食事記録表示ボタン　表示するwidgetを切り替えるよう設定。
                      AnimatedSwitcher(
                        duration:const Duration(milliseconds:400),
                        transitionBuilder:(child, animation){
                          return SizeTransition(sizeFactor: animation, child: child);
                        },
                        child: _showFoodList
                                  ? _buildFoodList()
                                  : _buildShowListButton(),
                      ),
                    ]
                  ),
                ),
              ),
            ],
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.all(16.0),
          child: TextButton(
            onPressed: _addFoodsFromCart, 
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              '食事を追加',
              style: TextStyle( fontSize: 16,),
            )
          )
        ),
      ),
    );
  }
        

  Widget _buildCalorieCard(NutritionGoal goal,bool isDefaultGoal, DailyNutrition currentNutrition){
    final total=currentNutrition.totalCalories;
    final percent=goal.calories>0 ? (total/goal.calories).clamp(0.0,1.0) : 0.0;

    return Card(
      elevation: 0,     //影を削除
      color:const Color(0xFF000020),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            const Text(
              'カロリー',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color:Colors.white),
            ),
            const SizedBox(height: 12,),
            CircularPercentIndicator(
              radius: 90.0,
              lineWidth: 15.0,
              percent: percent,
              center: Text(
                total.toStringAsFixed(0),
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color:Colors.white),
              ),
              footer: Text(
                isDefaultGoal 
                    ? 'kcal' 
                    : '${total.toStringAsFixed(0)} / ${goal.calories.toStringAsFixed(0)} kcal',
                style: const TextStyle(fontSize: 20, color:Colors.white),
              ),
              progressColor: Colors.green,
              backgroundColor: Colors.grey.shade300,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPfcCard(NutritionGoal goal, bool isDefaultGoal, DailyNutrition currentNutrition){
    return Card(
      elevation: 0,    //影を削除
      color:const Color(0xFF000020),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column( 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4,),
            Center(child:const Text('PFCバランス', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color:Colors.white),),),
            const SizedBox(height: 16,),
            _buildLinearProgress('タンパク質',currentNutrition.totalProtein, goal.protein, 'g', Colors.green, isDefaultGoal, Colors.white),
            const SizedBox(height: 4,),
            _buildLinearProgress('脂質',currentNutrition.totalFat, goal.fat, 'g', Colors.green, isDefaultGoal, Colors.white),
            const SizedBox(height: 4,),
            _buildLinearProgress('炭水化物',currentNutrition.totalCarbs, goal.carbs, 'g', Colors.green, isDefaultGoal, Colors.white),
            const SizedBox(height: 4,),
            _buildLinearProgress('糖質',currentNutrition.totalSugar, goal.sugar, 'g', Colors.green, isDefaultGoal, Colors.white),
            const SizedBox(height: 4,),
            _buildLinearProgress('食物繊維',currentNutrition.totalFiber, goal.fiber, 'g', Colors.green, isDefaultGoal, Colors.white),
            const SizedBox(height: 12,),
          ],
        ),
      ),
    );
  }

  Widget _buildLinearProgress(
    String title, 
    double currentValue, 
    double goalValue, 
    String unit, 
    Color progressColor,
    bool isDefaultGoal,
    Color backgroundColor,
    ){
      final percentage=goalValue > 0 ? (currentValue/goalValue).clamp(0.0,1.0) : 0.0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color:Colors.white, fontWeight: FontWeight.bold),),
              Text(isDefaultGoal
                ? '${currentValue.toStringAsFixed(1)} $unit'
                : '${currentValue.toStringAsFixed(1)} / ${goalValue.toStringAsFixed(1)} $unit',
                style:const TextStyle(color:Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 4,),
          LinearPercentIndicator(
            percent: percentage,
            lineHeight: 10.0,
            progressColor: progressColor,
            backgroundColor: backgroundColor,
            barRadius: const Radius.circular(5),
          )
        ],
      );
  }

  Widget _buildShowListButton(){
    return Padding(
      padding:const EdgeInsets.only(top:24),
      key:const ValueKey('showButton'),
      child:Center(
        child:ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor:Colors.green, shape:const StadiumBorder()),
          onPressed:(){
            setState((){
              _showFoodList=true;
            });
          },
          child:const Text('食事記録を表示', style:TextStyle(color:Colors.white)),
        ),
      ),
    );
  }

  Widget _buildFoodList(){
    return Container(
      padding:const EdgeInsets.only(top:16),
      key:const ValueKey('foodList'),
      child:Column(
        children:[
          const Divider(height: 40, color:Colors.white24),
          ElevatedButton(
            style:ElevatedButton.styleFrom(backgroundColor:Colors.green),
            onPressed:(){
              setState((){
                _showFoodList=false;
              });
            },
            child: const Text('表示を閉じる', style:TextStyle(color:Colors.white)),
          ),
          const SizedBox(height:8),
          if(_todayNutritionCopy.isEmpty)
            Padding(
              padding:const EdgeInsets.symmetric(vertical:24),
              child:const Text('今日の食事記録はありません', style: const TextStyle(color:Colors.white))
            )
          else
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,    //画面全体の４割を占めますよ、という意味
              child: ListView.builder(
                padding:const EdgeInsets.only(top:8),
                itemCount: _todayNutritionCopy.length,
                itemBuilder: (context, index){
                  final loggedFood=_todayNutritionCopy[index];
                  return Slidable(
                    key: ValueKey(loggedFood.foodItem.id+ loggedFood.hashCode.toString()),
                    endActionPane:ActionPane(
                      motion:const StretchMotion(),
                      children:[
                        SlidableAction(
                          onPressed:(content)=>_handleEditFoodLog(loggedFood),
                          backgroundColor:Colors.green.withOpacity(0.9),
                          foregroundColor:Colors.grey,
                          icon:Icons.edit,
                        ),
                        SlidableAction(
                          onPressed:(content)=>_handleDeleteFoodLog(loggedFood),
                          backgroundColor:Colors.red.withOpacity(0.9),
                          foregroundColor:Colors.grey,
                          icon:Icons.delete,
                        ),
                      ],
                    ),
                    child:ListTile(
                      dense:true,   //リストをつめつめに配置
                      title:Text(loggedFood.foodItem.name, style:const TextStyle(color:Colors.white)),
                      subtitle:Text('${loggedFood.percentage.toStringAsFixed(0)}%', style:const TextStyle(color:Colors.white)),
                      trailing: Text('${loggedFood.foodItem.calories}kcal', style:const TextStyle(color:Colors.white)),
                    )
                  );
                }
              ),
            ),
        ],
      ),
    );
  }
}
