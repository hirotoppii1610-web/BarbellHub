import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;

class GoogleAuthService {
  //シングルトンパターンで同じインスタンスを返す
  GoogleAuthService._internal();
  static final GoogleAuthService _instance=GoogleAuthService._internal();
  factory GoogleAuthService()=>_instance;

  //バックアップのファイル名
  static const String _backupFileName='barbell_hub_backup_json';

  //Google Driveのアプリ専用フォルダにアクセスするための権限（スコープ）
  final _googleSignIn=GoogleSignIn(scopes: [drive.DriveApi.driveAppdataScope]);

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;

  //アプリ起動時にログイン済みかを静かに確認する。
  Future<void> signInSilently()async{
    _currentUser = await _googleSignIn.signInSilently();
    print('サイレントログイン結果: ${_currentUser?.email}');
  }

  Future<bool> signIn()async{
    try{
      _currentUser=await _googleSignIn.signIn();
      print('サインイン成功: ${_currentUser?.email}');
      return _currentUser != null;
    }catch(error){
      print('サインイン中にエラー発生: $error');
      return false;
    }
  }

  Future<void> signOut()async{
    await _googleSignIn.disconnect();
    _currentUser=null;
    print('サインアウトしました。');
  }

  //Httpを取得(APIアクセスのために必要)
  Future<auth.AuthClient?> _getHttpClient()async{
    final headers=await _currentUser?.authHeaders;
    if(headers==null){
      print('認証ヘッダーが取得できませんでした。');
      return null;
    }

    final credentials=auth.AccessCredentials(
      auth.AccessToken(
        'Bearer',  // この部分は'type'ですが、google_sign_inではヘッダー名が異なります
        headers['Authorization']!.substring(7),  // 'Bearer 'トークン部分を抽出
        DateTime.now().toUtc().add(const Duration(hours: 1)), // おおよその有効期限
      ),
      null,
      _googleSignIn.scopes,
    );

    return auth.authenticatedClient(
      http.Client(), 
      credentials
    );
  }

  Future<void> uploadBackup(String jsonData)async{
    final client=await _getHttpClient();
    if(client==null){
      throw Exception('Google認証のクライアントの取得に失敗しました');
    }

    final driveApi=drive.DriveApi(client);

    final Map<String ,dynamic> wrapper={
      'timestamp': DateTime.now().toIso8601String(),
      'data': jsonDecode(jsonData),
    };

    final String wrappedJsonString=jsonEncode(wrapper);
    final List<int> encodedJsonData=utf8.encode(wrappedJsonString);
    
    final media=drive.Media(
      Stream.value(encodedJsonData),
      encodedJsonData.length,
      contentType: 'application/json',
    );

    //既存ファイルがある確認
    final fileList=await driveApi.files.list(
      spaces: 'appDataFolder',
      q: "name = '$_backupFileName'",
      $fields: 'files(id,name)',
    );

    if(fileList.files!=null && fileList.files!.isNotEmpty){
      //ファイルを更新
      final existingFieldId=fileList.files!.first.id!;
      print('既存のバックアップファイルを作成します。id:$existingFieldId');
      await driveApi.files.update(drive.File(), existingFieldId, uploadMedia: media);
      print('ファイル更新が完了しました');
    }else{
      print('バックアップファイルが見つかりません。新規作成します。');
      final fileMetaData=drive.File()
        ..name=_backupFileName
        ..parents=['appDataFolder'];
        final createFile=await driveApi.files.create(fileMetaData, uploadMedia: media);
        print('新規バックアップファイルを作成しました。id:${createFile.id}');
    }
  }

  Future<Map<String, dynamic>?> downloadBackup()async{
    final client=await _getHttpClient();
    if(client==null){
      throw Exception('Google認証のクライアントの取得に失敗しました');
    }

    final driveApi=drive.DriveApi(client);
    final fileList=await driveApi.files.list(
      spaces: 'appDataFolder',
      q: "name = '$_backupFileName'",
    );
    if(fileList.files!=null && fileList.files!.isNotEmpty){
      final fileId=fileList.files!.first.id!;
      print('ファイルをダウンロードします(ID: $fileId)');
      final media=await driveApi.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      final content=await media.stream
        .transform(utf8.decoder)
        .join();
      try{
        final Map<String, dynamic> wrapper=jsonDecode(content);
        if(wrapper.containsKey('timestamp') && wrapper.containsKey('data')){
          return{
            'timestamp':DateTime.parse(wrapper['timestamp']),
            'jsonData':jsonEncode(wrapper['data']),
          };
        }else{
          return {
            'timestamp':null,
            'jsonData':content,
          };
        }
      }catch(e){
        print('JSON解析エラー');
        return null;
      }
    }else{
      print('ダウンロード対象のバックアップファイルが見つかりませんでした。');
      return null;
    }
  }
}