import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  //常にアプリ内で同一の処理を行うためのコード
  NotificationService._internal();
  static final NotificationService _instance=NotificationService._internal();
  factory NotificationService()=>_instance;

  final FlutterLocalNotificationsPlugin _plugin=FlutterLocalNotificationsPlugin();

  //初期化処理
  Future<void> init()async{
    //タイムゾーンの初期化
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));//日本時間に設定

    const DarwinInitializationSettings iosSettings=DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings=InitializationSettings(
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details){
        print('Notification Tapped: ${details.payload}');
      }
    );
  }

  //シンプルな通知機能
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  })async{
    const NotificationDetails details= NotificationDetails(
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(id, title, body, details);
  }

  //毎日同じ時間に通知をするメソッド
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  })async{
    final tz.TZDateTime now=tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate=tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    //もし指定した時間がもう過ぎていたら、次の日にセット
    if(scheduledDate.isBefore(now)){
      scheduledDate=scheduledDate.add(const Duration(days:1));
    }

    await _plugin.zonedSchedule(
      id, 
      title, 
      body, 
      scheduledDate, 
      const NotificationDetails(
        iOS: DarwinNotificationDetails(),
      ), 
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, 
      //毎日同じ時間に繰り返す
    );
  }

  Future<void> cancelAllNotification()async{
    await _plugin.cancelAll();
  }
}