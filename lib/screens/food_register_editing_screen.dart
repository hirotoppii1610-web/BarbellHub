import 'package:flutter/material.dart';
import 'package:muscle_one/model/food_item.dart';
import 'package:uuid/uuid.dart';


class FoodRegisterEditingScreen extends StatefulWidget{
  final FoodItem? existingFood;
  const FoodRegisterEditingScreen({super.key, this.existingFood});

  @override
  State<FoodRegisterEditingScreen> createState() => _FoodRegisterEditingScreenState();
}  

class _FoodRegisterEditingScreenState extends State<FoodRegisterEditingScreen>{
  final _formKey=GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _carbsController;
  late TextEditingController _sugarController;
  late TextEditingController _fiberController;

  bool get _isEditing => widget.existingFood != null;

  @override
  void initState(){
    super.initState();
    _nameController=TextEditingController(text: widget.existingFood?.name ?? '');
    _caloriesController=TextEditingController(text: widget.existingFood?.calories.toString() ?? '');
    _proteinController=TextEditingController(text: widget.existingFood?.protein.toString() ?? '');
    _fatController=TextEditingController(text: widget.existingFood?.fat.toString() ?? '');
    _carbsController=TextEditingController(text: widget.existingFood?.carbs.toString() ?? '');
    _sugarController=TextEditingController(text: widget.existingFood?.sugar.toString() ?? '');
    _fiberController=TextEditingController(text: widget.existingFood?.fiber.toString() ?? '');
  }

  @override
  void dispose(){
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    _sugarController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  void _saveAndPop(){
    if(!_formKey.currentState!.validate()){   //意味合いは？
      return;
    }
    final newFood=FoodItem(
      id: widget.existingFood?.id ?? const Uuid().v4(),
      name: _nameController.text,
      calories: double.tryParse(_caloriesController.text) ?? 0.0,
      protein: double.tryParse(_proteinController.text) ?? 0.0,
      fat: double.tryParse(_fatController.text) ?? 0.0,
      carbs:double.tryParse(_carbsController.text) ?? 0.0,
      sugar:double.tryParse(_sugarController.text) ?? 0.0,
      fiber:double.tryParse(_fiberController.text) ?? 0.0,
    );

    Navigator.pop(context, newFood);
  }

  Widget _buildNutritionInpoutRow({
    required String label,
    required TextEditingController controller,
    required String? unit,
  }){
    return TextFormField(
      controller: controller,
      style:const TextStyle(color:Colors.white),
      keyboardType: unit != null 
          ? const TextInputType.numberWithOptions(decimal:true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText:label,
        labelStyle: const TextStyle(color:Colors.white),
        suffixText: unit,
        hintStyle: const TextStyle(color:Colors.white),
        enabledBorder: OutlineInputBorder(borderSide:BorderSide(color:Colors.white54)),
        focusedBorder: OutlineInputBorder(borderSide:BorderSide(color:Colors.green)),
      ),
      validator: (value){       //検証の機械のような扱い
        if (value==null || value.isEmpty){
          return '値を入力してください';
        }
        if (unit !=null && double.tryParse(value)==null){
          return '数値を入力してください';
        }
        return null;
      },
    );    
  }

  @override
  Widget build(BuildContext content){
    return Scaffold(
      backgroundColor:Color(0xFF000020),
      appBar: AppBar(
        title: _isEditing 
          ? Text('食品を編集',style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color:Colors.white),)
          : Text('食品を追加',style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color:Colors.white),),
        backgroundColor: Colors.green,
        leading:IconButton(
          onPressed:()=>Navigator.pop(context),
          icon:const Icon(Icons.close, color:Colors.white),
        ),
        actions:[
          IconButton(
            icon:const Icon(Icons.check, color:Colors.white),
            onPressed:(){_saveAndPop();},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding:const EdgeInsets.all(16.0),
        child:Form(
          key: _formKey,
          child:Column(
            children:[
              _buildNutritionInpoutRow(controller: _nameController, label:'食品名 (例: 鶏胸肉100g)', unit:null),
              const SizedBox(height:8),
              _buildNutritionInpoutRow(controller: _caloriesController, label: 'カロリー', unit:'kcal'),
              const SizedBox(height:8),
              _buildNutritionInpoutRow(controller: _proteinController, label: 'タンパク質', unit:'g'),
              const SizedBox(height:8),
              _buildNutritionInpoutRow(controller: _fatController, label: '脂質', unit:'g'),
              const SizedBox(height:8),
              _buildNutritionInpoutRow(controller: _carbsController, label: '炭水化物', unit:'g'),
              const SizedBox(height:8),
              _buildNutritionInpoutRow(controller: _sugarController, label: '糖質', unit:'g'),
              const SizedBox(height:8),
              _buildNutritionInpoutRow(controller: _fiberController, label: '食物繊維', unit:'g'),
            ]
          ),
        ),
      ),
    );
  }
}