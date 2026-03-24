import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muscle_one/model/nutrition_goal.dart';
import 'package:uuid/uuid.dart';

class GoalSettingScreen extends StatefulWidget{
  final List<NutritionGoal> allNutritionGoals;
  final Function(List<NutritionGoal>) onNutritionGoalsUpdated;
  const GoalSettingScreen({
    super.key, 
    required this.allNutritionGoals,
    required this.onNutritionGoalsUpdated,
  });

  @override
  State<GoalSettingScreen> createState()=> _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen>{
  late List<NutritionGoal> _goals;

  @override
  void initState(){
    super.initState();
    _goals=List.of(widget.allNutritionGoals);
    _goals.sort((a,b)=>b.startDate.compareTo(a.startDate));
  }

  void _handlePop(){
    widget.onNutritionGoalsUpdated(_goals);
    Navigator.pop(context);
  }
  
  void _showGoalDialog({NutritionGoal? existingGoal})async{
    final isEditing=existingGoal !=null;

    DateTime startDate=existingGoal?.startDate?? DateTime.now();
    DateTime? endDate=existingGoal?.endDate;

    final _caloriesController=TextEditingController(text:existingGoal?.calories.toStringAsFixed(0));
    final _proteinController=TextEditingController(text:existingGoal?.protein.toStringAsFixed(0));
    final _fatController=TextEditingController(text:existingGoal?.fat.toStringAsFixed(0));
    final _carbsController=TextEditingController(text:existingGoal?.carbs.toStringAsFixed(0));
    final _sugarController=TextEditingController(text:existingGoal?.sugar.toStringAsFixed(0));
    final _fiberController=TextEditingController(text:existingGoal?.fiber.toStringAsFixed(0));

    final GlobalKey<State> dialogStateKey=GlobalKey<State>();

    final savedGoal=await showDialog<NutritionGoal>(
      context: context,
      builder: (context){
        return StatefulBuilder(
          key:dialogStateKey,
          builder: (context,setDialogState){
            return AlertDialog(
              title: Text(isEditing ?'目標を編集'  :'新しい目標を追加'),
              content: SingleChildScrollView(
                child:Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text('開始日:${DateFormat('yyyy/MM/dd').format(startDate)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: ()async{
                        final DateTime? picked=await showDatePicker(
                          context: context, 
                          initialDate: startDate,
                          firstDate: DateTime(2023), 
                          lastDate: DateTime(2040)
                        );
                        if(picked!=null){
                          setDialogState((){
                            startDate=picked;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: Text(endDate==null   
                        ? '終了日: 設定しない' 
                        : '終了日: ${DateFormat('yyyy/MM/dd').format(endDate!)}'
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: ()async{
                        final DateTime? picked=await showDatePicker(
                          context: context,
                          initialDate: endDate?? startDate,
                          firstDate: startDate,
                          lastDate: DateTime(2040),
                        );
                        setDialogState((){
                          endDate=picked;
                        });
                      },
                      onLongPress: (){
                        setDialogState((){
                          endDate=null;
                        });
                      }
                    ),
                    TextField(controller: _caloriesController, decoration: const InputDecoration(labelText: 'カロリー(kcal)'),),
                    TextField(controller: _proteinController, decoration: const InputDecoration(labelText: 'タンパク質(g)'),),
                    TextField(controller: _fatController, decoration: const InputDecoration(labelText: '脂質(g)'),),
                    TextField(controller: _carbsController, decoration: const InputDecoration(labelText: '炭水化物(g)'),),
                    TextField(controller: _sugarController, decoration: const InputDecoration(labelText: '糖質(g)'),),
                    TextField(controller: _fiberController, decoration: const InputDecoration(labelText: '食物繊維(g)'),)
                  ],
                )
              ),
              actions: [
                TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('キャンセル')),
                TextButton(
                  onPressed: (){
                    final goal=NutritionGoal(
                      id: existingGoal?.id ?? const Uuid().v4(), 
                      startDate: startDate, 
                      endDate: endDate,
                      calories: double.tryParse(_caloriesController.text)??0, 
                      protein: double.tryParse(_proteinController.text)??0, 
                      fat: double.tryParse(_fatController.text)??0, 
                      carbs: double.tryParse(_carbsController.text)??0, 
                      sugar: double.tryParse(_sugarController.text)??0, 
                      fiber: double.tryParse(_fiberController.text)??0,
                    );
                    Navigator.pop(context,goal);
                  }, 
                  child: const Text('保存'),
                ),
              ],
            );
          }
        );
      }
    );

    if(savedGoal!=null){
      setState(() {
        if(existingGoal != null){
          final index=_goals.indexWhere((g)=>g.id==savedGoal.id);
          if(index!=-1)_goals[index]=savedGoal;
        }else{
          _goals.add(savedGoal);
        }
        _goals.sort((a,b)=>b.startDate.compareTo(a.startDate));
      });
      widget.onNutritionGoalsUpdated(_goals);
    }
  }

  @override
  Widget build(BuildContext context){
    return PopScope(
      canPop:false,
      onPopInvoked:(didpop){
        if(didpop)return;
        _handlePop();
      },
      child:Scaffold(
        backgroundColor:Color(0xFF000020),
        appBar: AppBar(
          title: const Text('過去の栄養素の目標一覧', style:TextStyle(color:Colors.white)),
          leading:IconButton(
            icon:const Icon(Icons.arrow_back, color:Colors.white),
            onPressed:_handlePop,
          ),
          backgroundColor:Colors.green.withOpacity(0.9),
        ),
        body:_goals.isEmpty
          ? const Center(child: Text('目標が設定されていません',style:TextStyle(color:Colors.white)))
          : ListView.builder(
            itemCount: _goals.length,
            itemBuilder: (context,index){
              final goal=_goals[index];
              return Card(
                margin:const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  title: Text('${DateFormat('yyyy/MM/dd').format(goal.startDate)}からの目標'),
                  subtitle: Text('P:${goal.protein.toStringAsFixed(0)}g, F:${goal.fat.toStringAsFixed(0)}g, C:${goal.carbs.toStringAsFixed(0)}g, ....'),
                  onTap: ()=>_showGoalDialog(existingGoal: goal),
                ),
              );
            }
          ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showGoalDialog,
          backgroundColor: Colors.green.withOpacity(0.9),
          child: const Icon(Icons.add, color:Colors.white),
        ),
      ),
    );
  }

  TextFormField  _buildTextField({
    required TextEditingController controller,
    required String label,
    required String suffix,
  }){
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
      validator: (value){
        if (value==null || value.isEmpty){
          return '値を入力してください';
        }
        if (double.tryParse(value)==null){
          return '数値を入力してください';
        }
        return null;
      },
    );
  }
}