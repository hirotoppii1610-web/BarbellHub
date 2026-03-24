import 'package:flutter/material.dart';
import '../model/food_item.dart';
import '../model/logged_food.dart';
import '../model/history_log.dart';
import '../screens/food_register_editing_screen.dart';
import '../data/food_items_data.dart';
import '../widget/search_bar.dart';
import '../widget/food_list_view.dart';
import '../widget/history_tab_view.dart';
import '../widget/barcode_scan_widget.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class FoodSelectScreen extends StatefulWidget{
  final List<FoodItem> allMyFoods;
  final Function(List<FoodItem>) onMyFoodsUpdated;
  final List<HistoryLog> historyList;
  const FoodSelectScreen({
    super.key,
    required this.allMyFoods,
    required this.onMyFoodsUpdated,
    required this.historyList,
  });

  @override
  State<FoodSelectScreen> createState() => _FoodSelectScreenState();
}

class _FoodSelectScreenState extends State<FoodSelectScreen>{
  //買い物かご
  final List<LoggedFood> _shoppingCart=[];

  //検索機能のために追加
  final TextEditingController _searchController=TextEditingController();
  List<FoodItem> _searchResults=[];
  List<FoodItem> _allSearchableFoods=[];
  bool _isSearching=false;
  late List<FoodItem> _myFoodsCopy;

  @override
  void initState(){
    super.initState();
    _allSearchableFoods=[...defaultFoodItems, ...widget.allMyFoods];
    _myFoodsCopy=List.of(widget.allMyFoods);
    _searchResults=List.from(_allSearchableFoods);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant FoodSelectScreen oldWidget){
    super.didUpdateWidget(oldWidget);
    print('【3】didUpdateWidgetが呼ばれました。');
    print('   - 古いリストの長さ: ${oldWidget.allMyFoods.length}');
    print('   - 新しいリストの長さ: ${widget.allMyFoods.length}');
      //親から貰うマイリストが変更されたらこの画面でも変更する　元々瞬時に保存されるから、瞬時に作動するはず。
    if(widget.allMyFoods.length != oldWidget.allMyFoods.length){
      print('【4】リストの長さが違うことを検知! 画面を更新します。');
      _allSearchableFoods=[...defaultFoodItems, ...widget.allMyFoods];
      _onSearchChanged();
    }
  }

  @override
  void dispose(){
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  //検索クエリが変更になったときに呼ばれる=>クエリとは、今回では検索欄の文字で、親元にリクエストするもののこと
  void _onSearchChanged(){
    final query=_searchController.text.toLowerCase().replaceAll(RegExp(r'\s+'), '');   //toLowerCase()は大文字でも全部小文字で表現するよ
    setState(() {
      //クエリが空なら全件表示                                 これで入力によって、結果が変わらないようにする
      if (query.isEmpty){   
        _isSearching=false;                               //例 Appleとapple
        _searchResults=List.from(_allSearchableFoods);
        return;
      }else{
        //Myリスト内を部分一致で検索
        _isSearching=true;
        _searchResults=_allSearchableFoods.where((food){
          final foodName=food.name.toLowerCase().replaceAll(RegExp(r'\s+'), '');
          return _isFuzzyMatch(foodName, query);   //リスト内の文字を全部小文字にして、
        }).toList();                       //.contains(query)=>クエリに部分的にも該当しているものはないか、それらを集めて新たなリストにする
        //リストが検索欄の下に表示されていく。
      }
    });
  }

  //一文字でもあってたら反映するためのロジック　ファジー検索っていうらしい
  bool _isFuzzyMatch(String text, String query){
    int queryIndex=0;
    for(int i=0; i<text.length; i++){
      if(queryIndex<query.length && text[i]== query[queryIndex]){
        queryIndex++;
      }
    }
    // 検索ワードの全ての文字が見つかったら true
    return queryIndex==query.length;
  }

  //食べた量％を入力するダイアログ
  void _showPercentageDialog(FoodItem food){
    final percentController=TextEditingController();
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          backgroundColor: const Color(0xFF1e3a5f),
          title:Text('食べた量[%]を入力', style:const TextStyle(color:Colors.white)),
          content:TextFormField(
            controller: percentController,
            autofocus: true,
            style: const TextStyle(color:Colors.white),
            decoration: InputDecoration(
              labelText: '食べた量[%]',
              labelStyle: const TextStyle(color:Colors.white70),
              hintText: '数値のみで入力してください',
              hintStyle: const TextStyle(color:Colors.white54),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color:Colors.white))
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: ()=>Navigator.pop(context),
              child: Text('キャンセル', style:const TextStyle(color:Colors.white54))
            ),
            TextButton(
              onPressed: () {
                final percentage=double.tryParse(percentController.text)??0;
                if (percentage>0){
                  setState(() {
                    _shoppingCart.add(LoggedFood(foodItem: food, percentage: percentage));
                  });
                }
                Navigator.pop(context);
              },
              child:Text('保存', style:const TextStyle(color:Colors.white)),
            ),
          ],
        );
      }
    );
  }

  //バーコードを読み込んで情報を取得するコード
  Future<void> _processBarcode(String barcode)async{
    if (barcode == '-1' || !mounted) return;
    print('スキャンされたバーコード: $barcode');

    try{
      //API問い合わせのセッティング
      final ProductQueryConfiguration config= ProductQueryConfiguration(
        barcode,
        language: OpenFoodFactsLanguage.JAPANESE,  //情報の言語指定
        fields: [ProductField.ALL],
        version: ProductQueryVersion.v3,  //データは全部下さいという意味
      );          //config=>発注票になる

      //バーコードの内容をAPI問い合わせる
      final ProductResultV3 result =await OpenFoodAPIClient.getProductV3(config);
      
      //4.結果を処理
      if (result.status == ProductResultV3.statusSuccess && result.product!=null){
        final Product product=result.product!;  //productNameがあるか確認
        if (product!=null && product.productName !=null){
          print('[API成功]: ${product.productName}');
          print('[栄養情報]: ${product.nutriments?.toJson()}');
          
          //Nutrimentsから情報を収集して、FoodItemに変換
          final nutriments = product.nutriments;
          final calories = nutriments?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams) ??0;
          final protein = nutriments?.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ??0;
          final fat = nutriments?.getValue(Nutrient.fat, PerSize.oneHundredGrams) ??0;
          final carbs = nutriments?.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams) ??0;
          final sugar = nutriments?.getValue(Nutrient.sugars, PerSize.oneHundredGrams) ??0;
          final fiber = nutriments?.getValue(Nutrient.fiber, PerSize.oneHundredGrams) ??0;

          //新規のFoodItemを作成
          final FoodItem scannedFood=FoodItem(
            id:barcode,
            name:product.productName!,
            calories: calories,
            protein: protein,
            fat:fat,
            carbs: carbs,
            sugar: sugar,
            fiber: fiber,
          );

          //scannedFoodをmyFoodに追加
          final bool alreadyExists =widget.allMyFoods.any((food)=>food.id==barcode);
          if (!alreadyExists){
              final newList=List.of(widget.allMyFoods)..add(scannedFood);
              widget.onMyFoodsUpdated(newList);
            print('新しい商品${scannedFood.name}をMy食品リストに登録しました。');
          }
          

          //摂取％を入力をしてもらい、買い物かごに入れる。
          if(!mounted)return;
          {_showPercentageDialog(scannedFood);}

        } else {
          print('商品名が見つかりませんでした。');
        }
      } else {
        print('商品が見つかりませんでした。');
      }
    }catch (e){
      print('スキャン中にエラーが発生しました: $e');
    }
  }

  void _showAddFoodOption(){
    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          backgroundColor: const Color(0xFF1e3a5f),
          title:const Text('食品の追加方法を選択',style:TextStyle(color:Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit,color:Colors.white),
                title:const Text('手入力で食品を登録',style:TextStyle(color:Colors.white)),
                onTap: ()async{
                  Navigator.pop(context);
                  //FoodRegisterEditingScreenから新しいfoodItemが帰ってくるのを待つ。
                  final FoodItem? newFoodItem=await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context)=>const FoodRegisterEditingScreen()),
                  );
                  if (newFoodItem != null){
                    print('【1】新規食品を受け取りました: ${newFoodItem.name}');
                    final newList=List.of(widget.allMyFoods)..add(newFoodItem);
                    widget.onMyFoodsUpdated(newList);
                    print('【2】親(MainScreen)へ更新を通知しました。新しいリストの要素数: ${newList.length}');
                    setState((){
                      _myFoodsCopy.add(newFoodItem);
                      _allSearchableFoods.add(newFoodItem);
                      _onSearchChanged();
                    });
                  }else{
                    print('【1】新規食品はnullでした。');
                    showDialog(context: context, builder: (context){
                      return AlertDialog(
                        backgroundColor: const Color(0xFF1e3a5f),
                        content: Text('この食品は、データベースに存在しませんでした。',style:TextStyle(color:Colors.white)),);
                    });
                  }
                }
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner, color:Colors.white),
                title:Text('商品のバーコードで読み取り',style:TextStyle(color:Colors.white)),
                onTap:()async{
                  Navigator.pop(context);
                  final result=await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context)=>const BarcodeScanWidget())
                  );
                  if(result!=null && result is String){
                    _processBarcode(result);
                  }
                },
              )
            ],),
        );
    });
  }

  void _handlePop(){
    Navigator.pop(context, _shoppingCart);
  }

  void _handleEditFood(FoodItem foodToEdit)async{
    final FoodItem? updatedFood=await Navigator.push(
      context,
      MaterialPageRoute(builder:(context)=>FoodRegisterEditingScreen(existingFood: foodToEdit)),
    );
    if(updatedFood!=null){
      final newList=List.of(widget.allMyFoods);
      final index=newList.indexWhere((food)=>food.id==updatedFood.id);
      if(index!=-1){
        newList[index]=updatedFood;
        widget.onMyFoodsUpdated(newList);
      }
    }
  }

  void _handleDeleteFood(FoodItem foodToDelete){
    showDialog(
      context:context,
      builder:(context)=>AlertDialog(
        backgroundColor:const Color(0xFF1e3a5f),
        title:const Text('確認', style:TextStyle(color:Colors.white)),
        content:Text('${foodToDelete.name}を本当に削除しますか？', style:TextStyle(color:Colors.white)),
        actions:[
          TextButton(
            onPressed:()=>Navigator.pop(context),
            child:const Text('キャンセル', style:TextStyle(color:Colors.white)),
          ),
          TextButton(
            onPressed:(){
              final newList=List.of(widget.allMyFoods)..removeWhere((food)=>food.id==foodToDelete.id);
              widget.onMyFoodsUpdated(newList);
              Navigator.pop(context);
            },
            child:const Text('削除', style:TextStyle(color:Colors.white)),
          ),
        ],
      ),
    );
  }

  void _addDefaultFoodToMyFoods(FoodItem food){
    final bool alreadyExists=_myFoodsCopy.any((item)=>item.name==food.name);
    List<FoodItem> newList;
    String message;

    if(alreadyExists){
      newList=List.of(widget.allMyFoods)..removeWhere((item)=>item.id==food.id);
      message='${food.name} をMyリストから削除しました。';
      setState(() {
        _myFoodsCopy.removeWhere((item)=>item.id==food.id);
      });
    }else{
      final newfood=food.copyWith();
      newList=List.of(widget.allMyFoods)..add(newfood);
      message='${food.name} をMyリストに登録しました。';
      setState(() {
        _myFoodsCopy.add(newfood);
      });
    }
    widget.onMyFoodsUpdated(newList);
    

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,style: TextStyle(color:Colors.white),),
        duration: const Duration(seconds:2),
      )
    );
  }

  @override
  Widget build(BuildContext content){
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor:Color(0xFF000020),
        appBar: AppBar(
          leading: IconButton(
            onPressed: (){_handlePop();}, 
            icon: Icon(Icons.arrow_back, color:Colors.white),
          ),
          title:Text('食品を選択', style: TextStyle(color: Colors.white, fontSize:18,),),
          backgroundColor: Colors.green.withOpacity(0.9),
          actions:[
            TextButton(
              onPressed: _handlePop,
              child: Text(
                '${_shoppingCart.length}品  完了',
                style:const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text:'検索'),
              Tab(text:'履歴'),
              Tab(text:'マイ食品リスト'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,  //下線の色
          ),
        ),
        body:TabBarView(
          children: [
            Column(
              children: [
                //1.検索欄の表示
                SearchBarWidget(controller: _searchController,),

                //2.検索結果がない場合の表示
                if (_searchResults.isEmpty && _isSearching)
                  const Expanded(
                    child: Center(
                      child: Text('一致する商品は見つかりませんでした。',style: TextStyle(color: Colors.white),),
                    ),
                ),
                
                //3.検索欄がある場合の表示
                if (_searchResults.isNotEmpty)
                  Expanded(
                    child:FoodListView(
                      searchResults: _searchResults,
                      onFoodTap: (food){
                        //食品がタップされたときの処理をこれで返す。
                        _showPercentageDialog(food);
                      },
                      enableSlide: false,
                      savedFoodIds: _myFoodsCopy.map((e)=>e.id).toSet(),
                      onAddFavorite: (food){
                        _addDefaultFoodToMyFoods(food);
                      },
                    ),
                  ),
              ],
            ),
            HistoryTabView(
              historyList:widget.historyList,
              onFoodTap: (food){
                _showPercentageDialog(food.foodLog.foodItem);
              }
            ),
            FoodListView(
              searchResults: _myFoodsCopy,
              onFoodTap: _showPercentageDialog,
              onEdit: _handleEditFood,
              onDelete: _handleDeleteFood,
              enableSlide: true,
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.all(16.0),
          child: TextButton(
            onPressed: _showAddFoodOption, 
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              '食品を登録',
              style: TextStyle( fontSize: 16,),
            ),
          ),
        ),
      ),
    );
  }
}