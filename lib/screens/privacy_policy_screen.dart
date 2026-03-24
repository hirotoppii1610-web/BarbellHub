import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildSection(String title, String content) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            content.trim().replaceAll('・', '  • '), // 箇条書きを見やすく
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('プライバシーポリシー', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0), // パディングを少し調整しました
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '当方が提供するフィットネスアプリケーション「Barbell Hub」（以下、「本アプリ」といいます。）における、利用者に関する情報（以下、「利用者情報」といいます。）の取扱いについて、以下のとおりプライバシーポリシー（以下、「本ポリシー」といいます。）を定めます。',
                      style: TextStyle(fontSize: 16, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    buildSection(
                      '1. 取得する利用者情報と取得方法',
                      '''当方は、本アプリの提供にあたり、以下の利用者情報を取得します。

(1) 利用者から直接ご提供いただく情報
・プロフィール情報： 性別、身長、年齢、体重、活動レベルなど、本アプリの計算機能を利用するために必要な情報
・アカウント情報： Googleログインを利用する場合の認証情報（メールアドレス、ユーザーID等）

(2) 本アプリのご利用に伴い自動的に取得する情報
・健康・トレーニング関連データ： トレーニング記録、食事記録、睡眠記録、体重記録など、利用者が本アプリに入力する全ての情報
・端末情報： ご利用の端末のOSバージョン、機種名、プッシュ通知用トークンなど、本アプリのサービス維持および不具合改善に必要な情報
・広告ID： 広告配信事業者が提供する広告ID（IDFA / AAID）

(3) 第三者サービスから取得する情報
利用者が外部サービスとの連携を許可した場合に、以下の情報を取得します。
・ヘルスケアデータ： Apple社のHealthKitまたはGoogle社のGoogle Fitから、利用者の同意を得た上で歩数、睡眠、体重などのデータを取得します。
・食品情報： OpenFoodFacts APIを利用し、バーコードから食品情報を取得します。''',
                    ),
                    buildSection(
                      '2. 利用目的',
                      '''当方は、取得した利用者情報を以下の目的で利用します。
・本アプリのサービス提供、運営、改善のため（BMR、TDEE等の計算、記録の表示など）
・データのクラウドバックアップおよび機種変更時のデータ引き継ぎのため
・プッシュ通知によるリマインダーや重要なお知らせの送信のため
・本人確認、お問い合わせ対応のため
・個人を特定できない形での統計データを作成し、本アプリの品質向上やマーケティングに利用するため
・利用者の興味関心に合わせた広告配信のため（※将来的な実装の可能性を含む）
・不正行為の防止、調査、対応のため''',
                    ),
                    buildSection(
                      '3. 第三者提供と外部送信',
                      '''当方は、以下の場合を除き、取得した利用者情報を第三者に提供することはありません。
・利用者本人の同意がある場合
・法令に基づく場合
・人の生命、身体または財産の保護のために必要がある場合
・認証およびデータ管理のため、Google (Firebase) などのクラウドサービスを利用する場合
・統計情報など、個人を識別できない形で提供する場合''',
                    ),
                    buildSection(
                      '4. 利用者情報の管理',
                      '当方は、利用者情報の漏えい、滅失またはき損の防止その他の利用者情報の安全管理のために、必要かつ適切な措置を講じます。',
                    ),
                    buildSection(
                      '5. HealthKit / Google Fitから取得した情報の取扱い',
                      '本アプリがHealthKitおよびGoogle Fit APIから受け取った情報は、広告目的での利用や販売を行わず、Google API Services User Data Policyの「Limited Use requirements」を含む、適用されるすべてのポリシーを遵守します。',
                    ),
                    buildSection(
                      '6. プライバシーポリシーの変更',
                      '当方は、法令の改正や事業内容の変更等に応じて、本ポリシーを改定することがあります。重要な変更がある場合には、本アプリ内での通知など、分かりやすい方法でお知らせします。',
                    ),
                    buildSection(
                      '7. お問い合わせ',
                      '本ポリシーに関するご意見、ご質問、その他利用者情報の取扱いに関するお問い合わせは、以下の窓口までお願いいたします。\n[お問い合わせ先：https://forms.gle/VXFjps23i3S1dX159]',
                    ),
                    buildSection(
                      '附則',
                      '''制定日：2025年9月10日
改定日：2025年11月20日''', // 改定日を追加
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}