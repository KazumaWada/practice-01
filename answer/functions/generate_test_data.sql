 -- 指定された期間（開始日と終了日）の注文および注文明細のテストデータを生成するPL/pgSQL関数を作成してください。

-- なんか最初にINTEGER型を返してからvoidに変えたら、型変えるなら一度dropしろと言われたから。
-- DROP FUNCTION IF EXISTS test_notice(integer, integer);

CREATE OR REPLACE FUNCTION test_notice(start_date INTEGER, end_date INTEGER)
RETURNS void  -- 一応、戻り値が違うというエラーが出ている。
LANGUAGE plpgsql
AS $$
DECLARE
  index INTEGER := 10;
  random_date INTEGER;
  random_days INTEGER;
BEGIN
  RAISE NOTICE 'Hello from function!';

  -- 引数内の日程で、ランダムな日程を生成する。(多分、shで正確なvalidationができている事が前提になる)
  random_days := floor(random() * (end_date - start_date + 1)); 
  random_date := start_date + random_date;
  RAISE NOTICE 'random_date = %', random_date;

  -- volumesでDDLとマスタが作成されてあるから、ここではテーブルにデータを挿入するところからスタートでok
  -- テストデータを挿入する。
  FOR i IN 1..index LOOP
     INSERT INTO orders(order_id, order_datetime)
     VALUES(i, "start_endのランダムな日数を格納した変数");
  END LOOP;
  

  -- INSERT INTO orders(
  --   -- idを任意の数だけ入れて、datetimeを引数の間でランダムに入れる処理とかを書く感じかな。
  --   -- ハードコードするのはloopの回数の部分だけ。

  -- )
  -- かつ、この開始日と終了日のdate型のレコードもalter tableで挿入する

  RAISE NOTICE '% レコード分のテストデータを挿入しました。', index;
END;
$$ ;

SELECT test_notice(2025-07-01, 2025-07-05);



---------------------------------------------------------------
-- 公式っぽいもの: https://www.postgresql.jp/document/9.2/html/plpgsql.html
-- LANGUAGE plpgsql以外にも、if等を使わない、LANGUAGE sqlが存在する。
-- 戻り値は、引数がいくつあっても1つ(スカラー関数の場合)
-- AS && ... $$: これだったら、シンプルなロジック. psqlでも必須。
-- BEGIN ... END: ifで制御をしたり複雑なロジックを扱う場合. language sqlでは使用できない。
-- DECLARE: その関数内で定義される変数を書く場所だから、引数をまたそこで宣言する必要はない。
-- FOR i IN 1..index: 1からindex分までloopが実行されるという意味。

-- RETURN:
-- 今回は、テストデータの挿入のみなので、何かを返すというよりかは、RAISE NOTICEでメッセージを返したほうがいいのかもしれない「何件のテストデータを挿入しました！」みたいに。
-- 関数の最初で、"RETURN 戻り値"を設定して、最後に"RETURN 値"を設定する。静的型付け言語に近いような発想。

