import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/main_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await Future.wait([
    SharedPreferences.getInstance(),
    initializeDateFormatting('ja_JP', null),
  ]);
  print('各種セット完了');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muscle One',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}