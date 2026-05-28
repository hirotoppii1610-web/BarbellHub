# muscle_one

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



# Barbell Hub 🏋️‍♂️

[![Flutter](https://img.shields.io/badge/Flutter-v3.22+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-v3.4+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Desktop-blue)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Barbell Hub（バーベルハブ）**は、本格的なトレーニー、パワーリフター、ボディビルダーの要求に応えるために設計された、オープンソースの**オールインワン・フィットネス統合管理アプリケーション**です。

既存のアプリにありがちな「筋トレ記録」「食事管理」「ライフログ」の分断を解消し、筋力向上とボディメイクに必要なすべての変数（ボリューム、マクロ、体重推移、睡眠クオリティ）を一元管理。データ駆動型のハイパフォーマンスなトレーニングライフをサポートします。

---

## 🎯 コア機能 (Core Features)

### 1. ワークアウト＆プログラム管理システム
* **ピリオダイゼーション対応プログラムビルダー:** 週間（`ProgramWeek`）および日別（`ProgramDay`）のカスタムメニューを事前に設計し、ルーティン化可能。
* **構造化されたロギング:** 重量・レップ数・セットごとのステータスを細かくトラッキング（`WorkoutSet`）。
* **有酸素運動（Cardio）の完全統合:** 筋力トレーニングと並行してカーディオセッションの距離・時間を記録し、総消費エネルギーやリカバリーへの影響を計算。

### 2. インテリジェント栄養・食事マネジメント
* **PFCマクロ・カロリートラッキング:** ユーザーの目標（増量・減量・維持）に合わせたマクロ栄養素ターゲットを自動算出し、日々の進捗を可視化。
* **高速食品データベース検索:** 初期搭載された食品データに加え、カスタム食品の登録・編集に対応。
* **バーコードスキャン機能:** `barcode_scan_widget` を搭載し、市販食品のJANコードをカメラで読み取ることで、入力コストを極限まで削減。

### 3. アスリートコンディション・アナリティクス
* **バイオメトリクス・ロギング:** 日々の体重推移（`BodyWeightLog`）と、筋肉合成・回復に直結する睡眠クオリティ（`SleepLog`）を記録。
* **カスタム時計型UI（Sleep Clock Painter）:** 直感的な円形スライダーUIにより、就寝・起床時刻と睡眠時間をグラフィカルに入力可能（`sleep_clock_painter.dart`）。
* **多角的な進捗分析:** 総トレーニングボリュームの推移、体重および睡眠の相関を視覚化する統合アナリティクス画面。

### 4. アカウント連携 ＆ インフラサービス
* **Google Authによるセキュア認証:** `google_auth_service` を介した堅牢な認証フロー。
* **プッシュ通知によるリマインダー:** `notification_service` によるローカル通知システムを搭載。筋トレの記録忘れや食事タイミングをインテリジェントにリマインド。

---

## 🛠 技術スタック (Technical Stack)

| レイヤー | 技術 / ライブラリ | 役割 |
| :--- | :--- | :--- |
| **Framework** | Flutter (Dart SDK 3.4+) | クロスプラットフォームUIの一元構築 |
| **Database** | SQLite / Local Database Service | ローカル環境への高速かつセキュアなログ永続化 |
| **Authentication** | Google Sign-In SDK | OAuth 2.0 に基づくセキュアなユーザー認証 |
| **CodeGen** | `json_serializable` / `build_runner` | イミュータブルなデータモデルおよびJSONシリアライズの自動生成 |
| **Architecture** | モジュール化された役割分散設計 | 画面（UI）、ビジネスロジック（Service）、データ（Model）の明確な分離 |

---

## 📂 ディレクトリ構造 (Architecture Overview)

本プロジェクトは、保守性とスケーラビリティを担保するため、ドメインおよび役割ごとに綺麗に分離されたレイヤードアーキテクチャを採用しています。

```text
lib/
├── data/               # マスター定数データ（初期エクササイズリスト、食品マスターなど）
├── database/           # データベースの接続、マイグレーション、CRUD共通処理
├── model/              # ビジネスロジックを内包するドメインモデル群
│   ├── *.dart          # エンティティ定義（WorkoutLog, DailyNutrition, SleepLog など）
│   └── *.g.dart        # build_runner によって自動生成されたシリアライズロジック
├── screens/            # プレゼンテーション層（各タブ画面・設定・動的編集フォーム）
├── services/           # 外部システム（Google Auth、ローカル通知）と通信するインフラ層
└── widget/             # 再利用性の高いカスタムUIコンポーネント（チャート、スキャンUI、カスタムPainter）



