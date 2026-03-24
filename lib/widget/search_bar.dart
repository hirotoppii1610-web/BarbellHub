import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget{
  final TextEditingController controller;

  const SearchBarWidget({super.key,required this.controller});

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        style:const TextStyle(color:Colors.white),
        decoration: InputDecoration(
          labelText: '食品名で検索',
          labelStyle: const TextStyle(color:Colors.white),
          hintText: '例:鶏むね肉(皮なし) 100gあたり、白米(炊飯後) 100gあたり',
          hintStyle: const TextStyle(color:Colors.white),
          prefixIcon: const Icon(Icons.search, color:Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0)
          ),
          //検索をクリアボタンの表示も含める
          suffixIcon: controller.text.isNotEmpty
            ? IconButton(
              onPressed:(){controller.clear();},
              icon: Icon(Icons.delete, color:Colors.white70),)
            :null,
        ),
      )
    );
  }
}