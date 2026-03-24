import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../model/food_item.dart';

class FoodListView extends StatelessWidget{
  final List<FoodItem> searchResults;
  final Function(FoodItem) onFoodTap;
  //コールバック用の関数
  final Function(FoodItem)? onEdit;
  final Function(FoodItem)? onDelete;
  final Function(FoodItem)? onAddFavorite;
  final Set<String>? savedFoodIds;
  final bool enableSlide;

  const FoodListView({
    super.key,
    required this.searchResults,
    required this.onFoodTap,
    this.onEdit,
    this.onDelete,
    this.onAddFavorite,
    this.savedFoodIds,
    this.enableSlide=true,
  });

  @override
  Widget build(BuildContext context){
    return Expanded(
      child: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context,index){
          final food = searchResults[index];
          final bool isSaved=savedFoodIds?.contains(food.id) ?? false;//お気に入り登録済みかチェック
          final listTile=ListTile(
            title:Text(food.name, style:TextStyle(color:Colors.white)),
            subtitle: Text('${food.calories.toStringAsFixed(0)}kcal', style:TextStyle(color:Colors.white70)),
            onTap:() {
              onFoodTap(food);
            },
            trailing: onAddFavorite!=null
              ? IconButton(
                onPressed: ()=>onAddFavorite!(food), 
                icon: Icon(
                  isSaved ? Icons.star : Icons.star_border,
                  color: isSaved? Colors.white :Colors.white70
                )
              )
              : null,
          );
          if(!enableSlide){
            return listTile;
          }
          return Slidable(
            key:ValueKey(food.id),
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              children:[
                SlidableAction(
                  onPressed: (context){
                    if(onEdit!=null) {
                      onEdit!(food);
                    }
                  },
                  backgroundColor:Colors.green.withOpacity(0.6),
                  foregroundColor:Colors.grey,
                  icon:Icons.edit,
                ),
                SlidableAction(
                  onPressed: (context){
                    if(onDelete!=null){
                      onDelete!(food);
                    };
                  },
                  backgroundColor:Colors.red.withOpacity(0.6),
                  foregroundColor:Colors.grey,
                  icon:Icons.delete,
                ),
              ],
            ),
            child:listTile,
          );
        }
      ),
    );
  }
}