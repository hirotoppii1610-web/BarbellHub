import UIKit
import Flutter
import UserNotifications // iOSの通知機能フレームワークをインポート

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    
    // ✅ チャンネル名をあなたのアプリに合わせて変更
    let permissionChannel = FlutterMethodChannel(name: "com.hirotoy.MuscleOne/permission",
                                                 binaryMessenger: controller.binaryMessenger)

    permissionChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      switch call.method {
      case "getNotificationStatus":
        // --- 状態を確認する処理 ---
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            var statusString: String
            switch settings.authorizationStatus {
            case .authorized:
                statusString = "granted"
            case .denied:
                statusString = "denied"
            case .notDetermined:
                statusString = "notDetermined"
            default:
                statusString = "unknown"
            }
            result(statusString)
        }
      case "requestNotificationPermission":
        // --- 許可をリクエストする処理 ---
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                result(FlutterError(code: "UNAUTHORIZED", message: "Permission request error", details: error.localizedDescription))
                return
            }
            result(granted) // 許可されたか(true)されなかったか(false)を返す
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}