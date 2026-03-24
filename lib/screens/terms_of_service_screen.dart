import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
        title: const Text('利用規約', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSection(
                      '第１条（本規約への同意）',
                      '''この利用規約（以下、「本規約」といいます。）は、当方が提供するフィットネスアプリケーション「Barbell Hub」（以下、「本アプリ」といいます。）の利用条件を定めるものです。
本アプリを利用するすべてのユーザー（以下、「利用者」といいます。）は、本規約の全文をよくお読みいただき、内容に同意の上で本アプリをご利用ください。利用者が本アプリの利用を開始した時点で、本規約に同意したものとみなします。
利用者が未成年者である場合は、親権者等の法定代理人の同意を得てから本アプリをご利用ください。''',
                    ),
                    buildSection(
                      '第２条（本アプリの機能）',
                      '''本アプリは、利用者の筋力トレーニングおよび健康管理（食事・睡眠）をサポートすることを目的とした、オールインワン・フィットネスパートナーです。主な機能は以下の通りです。
・トレーニング記録（種目、重量、回数、セット数）
・食事記録（摂取カロリー、PFCバランスなど）および外食チェーン店等の栄養成分情報の参照
・睡眠記録、体重記録
・Googleアカウントを利用したデータのクラウドバックアップ
・プッシュ通知による各種お知らせ
・プロフィール情報に基づくBMR（基礎代謝量）、TDEE（総消費カロリー）の自動計算
・OpenFoodFacts APIおよび独自データベースを利用した食品情報の検索
・HealthKit（iOS）/ Google Fit（Android）と連携した歩数、睡眠、体重データの取得・同期
・その他、当方が随時提供する機能''',
                    ),
                    buildSection(
                      '第３条（利用者情報の取扱い）',
                      '利用者の個人情報を含む利用者情報の取扱いは、別途定める「Barbell Hub プライバシーポリシー」に従うものとします。利用者は、本アプリを利用するにあたり、当該プライバシーポリシーの内容についても同意するものとします。',
                    ),
                    buildSection(
                      '第４条（禁止事項）',
                      '''利用者は、本アプリの利用にあたり、以下の行為をしてはなりません。
・法令または公序良俗に違反する行為
・犯罪行為に関連する行為
・当方または第三者の著作権、商標権その他の知的財産権を侵害する行為
・当方または第三者のサーバーやネットワークの機能を破壊したり、妨害したりする行為
・本アプリの不具合を意図的に利用する行為
・本アプリによって得られた情報を商業的に利用する行為
・他人に成りすます行為
・当方が意図しない方法で本アプリに関連して利益を得ることを目的とする行為
・その他、当方が不適切と判断する行為''',
                    ),
                    buildSection(
                      '第５条（免責事項）',
                      '''1. 本アプリが提供する情報（トレーニングメニュー、栄養情報、計算結果などを含む）は、利用者の健康増進を目的とするものであり、特定の病気の診断、治療、予防を目的とした医療行為に代わるものではありません。健康上の問題や懸念がある場合は、必ず医師または専門家にご相談ください。
2. アプリ内で提供される外食チェーン店等の食品栄養情報は、各社の公式サイト等で公表された情報を参照しておりますが、情報の完全性、正確性、最新性を保証するものではありません。各社のレシピ変更等により、実際の数値と異なる場合があります。
3. 利用者が本アプリを利用して行うすべてのトレーニングや食事管理は、利用者自身の責任において行うものとします。本アプリの利用に関連して利用者に生じた、いかなる傷害、健康問題、損害についても、当方に故意または重過失がある場合を除き、一切の責任を負いません。
4. 当方は、本アプリの提供に際し、通信回線の障害、サーバーの不具合、API提供元の仕様変更など、当方の責に帰さない事由により利用者に生じた損害について、責任を負わないものとします。''',
                    ),
                    buildSection(
                      '第６条（知的財産権）',
                      '本アプリに関する著作権、商標権その他一切の知的財産権は、当方または当方にライセンスを許諾している者に帰属します。利用者は、法令により認められる私的利用の範囲を超えて、これらの情報を無断で使用（複製、送信、譲渡、二次利用など）することはできません。',
                    ),
                    buildSection(
                      '第７条（有料機能について）',
                      '''当方は、将来的に本アプリの一部機能を、有料サービスとして提供する場合があります。
有料機能の内容、利用料金、支払方法その他の条件については、提供開始時に別途定めるものとし、利用者は同意の上で利用するものとします。''',
                    ),
                    buildSection(
                      '第８条（規約の変更）',
                      '''当方は、必要と判断した場合には、利用者に通知することなく、いつでも本規約を変更することができるものとします。
変更後の利用規約は、本アプリ内に掲示した時点からその効力を生じるものとし、利用者が規約変更後に本アプリを利用した場合は、変更後の規約に同意したものとみなします。''',
                    ),
                    buildSection(
                      '第９条（準拠法・裁判管轄）',
                      '''本規約の解釈にあたっては、日本法を準拠法とします。
本アプリに関して紛争が生じた場合には、[開発者の所在地を管轄する裁判所]を第一審の専属的合意管轄裁判所とします。''',
                    ),
                    buildSection(
                      '附則',
                      '''制定日：2025年9月10日
改定日：2025年11月20日''',
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