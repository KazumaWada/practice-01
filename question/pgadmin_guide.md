# pgAdmin開発ガイド

pgAdminはPostgreSQLのための高機能なGUI管理ツールです。クエリの実行だけでなく、ストアドプロシージャやストアドファンクション(以降、「関数」と記述します)の開発、デバッグ、管理を効率的に行うことができます。
なお、PostgreSQLの開発にはpgAdmin以外にも、A5:SQL Mk-2やDBeaverなどのGUIツール、あるいはVSCodeに拡張機能（例: PostgreSQL拡張）を導入して利用するケースもあります。ご自身の好みに合わせてツールを選択してください。

## 1. データベースへの接続

1.  pgAdminを起動します。※各自調べてインストールしてください
2.  左側のブラウザツリーで「Servers」を右クリックし、「Register」→「Server...」を選択します。
3.  「General」タブで、接続に任意の名前を付けます（例: `sql-batch-practice-db`）。
4.  「Connection」タブに切り替え、Dockerで起動したPostgreSQLコンテナの接続情報を入力します。※以下は汎用サンプルです。今回はdocker-compose.ymlを参照して設定してください。
    -   **Host name/address**: `localhost` (DockerホストのIPアドレス)
    -   **Port**: `5432` (docker-compose.ymlでマッピングしたポート)
    -   **Maintenance database**: `postgres` (デフォルト)
    -   **Username**: `postgres` (docker-compose.ymlで設定したユーザー名)
    -   **Password**: 設定したパスワードを入力し、「Save password?」をオンにすると便利です。
5.  「Save」をクリックして接続を保存し、接続します。

## 2. Query Toolでの開発

最も基本的な開発方法は、SQLエディタである「Query Tool」を使うことです。

1.  ブラウザツリーで、接続したサーバー > Databases > (対象のデータベース) を選択します。
2.  上部のメニューバーから「Tools」→「Query Tool」を選択するか、データベースを右クリックして「Query Tool」を選択します。
3.  開いたエディタに直接PL/pgSQLのコードを記述します。

```sql
-- 例: 整数を加算する関数の作成
CREATE OR REPLACE FUNCTION add(a integer, b integer)
RETURNS integer AS $$
BEGIN
    RETURN a + b;
END;
$$ LANGUAGE plpgsql;
```

4.  コードを記述したら、F5キーを押すか、上部の「Execute」ボタンをクリックして関数を作成・更新します。

**Query Toolで開発するメリット:**
-   使い慣れたエディタのように、自由にコードを記述・実行できる
-   `SELECT`文などを追記すれば、関数作成直後にすぐ動作確認ができる
-   SQLやPL/pgSQLのエラー内容がその場で確認でき、素早く修正できる
-   複数のSQLや関数を一括で実行・管理しやすい

## 3. GUIでの関数作成・編集

pgAdminには、関数の作成と編集をサポートする専用のGUIダイアログもあります。

1.  ブラウザツリーで、対象のデータベース > Schemas > public > Functions を右クリックし、「Create」→「Function...」を選択します。
2.  **Generalタブ**: 関数の名前（例: `summarize_daily_sales`）を入力します。
3.  **Definitionタブ**: `RETURNS`句（戻り値の型）や言語（`plpgsql`）を選択します。
4.  **Codeタブ**: `BEGIN ... END;` の間の、実際の処理コードを記述します。
5.  **Parametersタブ**: 引数を追加します。`Name`, `Data type`, `Direction` (IN/OUT/INOUT) を設定します。
6.  「Save」をクリックすると関数が作成されます。

**メリット:**
-   関数のシグネチャ（名前、引数、戻り値）をダイアログで管理できるため、構文エラーが減る。
-   既存の関数を右クリックして「Properties」を選択すれば、同じダイアログで簡単に編集できる。

## 4. デバッグのヒント: `RAISE NOTICE`

PL/pgSQLには本格的なステップ実行デバッガが標準で備わっているわけではありませんが、`RAISE NOTICE`を使うことで、変数の内容や処理の通過点をコンソールに出力し、簡易的なデバッグを行うことができます。

```sql
CREATE OR REPLACE FUNCTION summarize_daily_sales(target_date DATE)
RETURNS void AS $$
DECLARE
    -- 変数宣言
    product_record RECORD;
BEGIN
    RAISE NOTICE 'Batch processing started for date: %', target_date;

    FOR product_record IN SELECT product_id FROM products LOOP
        RAISE NOTICE 'Processing product_id: %', product_record.product_id;

        -- ここに集計処理を記述

    END LOOP;

    RAISE NOTICE 'Batch processing finished for date: %', target_date;
END;
$$ LANGUAGE plpgsql;
```

この関数をQuery Toolで `SELECT summarize_daily_sales('2025-07-01');` のように実行すると、「Messages」タブに`RAISE NOTICE`で指定したメッセージが表示されます。これにより、処理の流れや変数の状態を追跡できます。

## 5. おすすめの開発フロー

1.  **Query Toolで試作**: まずはQuery Toolを開き、`SELECT`文や`INSERT`文を単体で実行しながら、中心となるSQLクエリを組み立てます。
2.  **関数化**: クエリが完成したら、`CREATE OR REPLACE FUNCTION`で囲み、引数や変数、ループ処理などを追加して関数化します。
3.  **`RAISE NOTICE`でデバッグ**: 複雑なロジックの部分に`RAISE NOTICE`を仕込み、意図通りに動作しているかを確認します。
4.  **GUIで管理**: 作成した関数は、ブラウザツリーからいつでも確認・編集できます。関数の引数を変更したい場合などは、GUIを使うと便利です。

このフローにより、SQLクエリの正確性を確保しつつ、効率的にPL/pgSQL関数の開発を進めることができます。
