# ストアド と バッチ処理

## 1. プロジェクト概要

このプロジェクトは、SQLとバッチ処理のスキル向上を目的としています。
Eコマースサイトにおける日次売上データの処理という、簡易なビジネスシナリオを模擬しています。

あなたのミッションは、以下の機能を持つバッチ処理システムを作成することです。

1.  ランダムなテスト用売上データを生成する。
2.  日次の売上データを集計するPL/pgSQL関数を実行する。
3.  集計したデータを中間テーブル（ワークテーブル）に保存する。
4.  集計データをCSVファイルに出力する。
5.  シェルスクリプトで一連の処理を実行できるようにする。

このプロジェクトではPostgreSQLとシェルスクリプトを利用し、環境全体をDockerで管理します。これにより、簡単なセットアップと一貫した実行環境を実現できます。

## 2. データベーススキーマ

データベースは以下のテーブルで構成されます。これはdockerで起動したPostgreSQLコンテナ内に自動でセットアップされるため、手動設定は不要です。

### `products` テーブル

すべての商品マスタデータを格納します。

| カラム名 | データ型 | 制約 | 説明 |
| :--- | :--- | :--- | :--- |
| `product_id` | `SERIAL` | `PRIMARY KEY` | 商品のユニークな識別子。 |
| `product_name` | `VARCHAR(255)` | `NOT NULL` | 商品名。 |
| `price` | `INTEGER` | `NOT NULL` | 商品の単価。 |

### `orders` テーブル

注文情報を格納します。

| カラム名 | データ型 | 制約 | 説明 |
| :--- | :--- | :--- | :--- |
| `order_id` | `SERIAL` | `PRIMARY KEY` | 注文のユニークな識別子。 |
| `order_datetime` | `TIMESTAMP` | `NOT NULL` | 注文が行われた日時。 |

### `order_details` テーブル

各注文の明細情報を格納します。

| カラム名 | データ型 | 制約 | 説明 |
| :--- | :--- | :--- | :--- |
| `order_detail_id` | `SERIAL` | `PRIMARY KEY` | 注文明細のユニークな識別子。 |
| `order_id` | `INTEGER` | `FOREIGN KEY (orders.order_id)` | 関連する注文。 |
| `product_id` | `INTEGER` | `FOREIGN KEY (products.product_id)` | 関連する商品。 |
| `quantity` | `INTEGER` | `NOT NULL` | 注文された商品の数量。 |

### `daily_sales_summary` テーブル (ワークテーブル)

日次売上バッチ処理の集計結果を格納するための中間テーブルです。

| カラム名 | データ型 | 制約 | 説明 |
| :--- | :--- | :--- | :--- |
| `summary_date` | `DATE` | `NOT NULL` | 売上集計の対象日。 |
| `product_id` | `INTEGER` | `NOT NULL` | 商品の識別子。 |
| `total_quantity_sold` | `INTEGER` | `NOT NULL` | 対象日に販売された商品の合計数量。 |
| `total_sales_amount` | `INTEGER` | `NOT NULL` | 対象日の商品別売上合計額。 |
| `PRIMARY KEY` | (`summary_date`, `product_id`) | | 複合主キー。 |

## 3. 課題の進め方

1.  このREADMEと`question/assignment.md`の課題内容をよく読んでください。
2.  `answer`フォルダ内のシェルスクリプトやSQLファイルを編集して、課題を解いてください（ファイルの中身は空の状態で提供されています）。
3.  PostgreSQL環境はこのプロジェクトで用意したもの（Docker）を利用してください。
4.  テストデータ生成や集計を行うPL/pgSQL関数、バッチ処理用のシェルスクリプトを作成してください。

課題の詳細やヒントは`question/assignment.md`や`question/pgadmin_guide.md`に記載されていますので、必ず参照してください。
