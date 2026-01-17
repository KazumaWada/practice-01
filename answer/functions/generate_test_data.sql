 -- 指定された期間（開始日と終了日）の注文および注文明細のテストデータを生成するPL/pgSQL関数を作成してください。

-- 返り値の型変えた場合用とか
DROP FUNCTION IF EXISTS generate_test_data(DATE, DATE);

CREATE OR REPLACE FUNCTION generate_test_data(start_date DATE, end_date DATE)
RETURNS void 
LANGUAGE plpgsql
AS $$
DECLARE
  random_product_id  INTEGER;
  random_quantity  INTEGER;
  random_offset  INTEGER;
  random_date  DATE;
  random_index  INTEGER;
  added_order_id INTEGER;
BEGIN

  -- RAISE NOTICE '--- DEBUG ---';
  -- RAISE NOTICE 'product_id: %, quantity: %, offset: %, date: %, index: %',
  --     random_product_id, random_quantity, random_offset, random_date, random_index;


random_index := (random() * 50 +1)::int;

FOR i  IN 1..random_index LOOP

random_product_id := floor(random() * 5 + 1)::int;
random_quantity := (random() * 1000 +1)::int;
random_offset := floor(random() * (end_date - start_date + 1));
random_date := start_date + random_offset;

INSERT INTO orders (order_datetime)
VALUES(random_date)
RETURNING order_id INTO added_order_id;

INSERT INTO order_details (order_id, product_id, quantity)
VALUES(added_order_id, random_product_id, random_quantity);

END LOOP;

RAISE NOTICE '%件のテストデータを挿入しました', random_index;

END;
$$ ;



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


--------------------------------------------------------
-- memo
-- orders: 注文が確定した一通信(同じ日が複数レコードにあることもある)で一つ増える。
-- order_details: そのorder_idの商品分、レコードが増える。
-- loop内で日付順にしたほうがいいと思ったけど、取ってくる時にorder_byだから関係ないのかも、、




-- -- random_product_id('idが1~5までをloopしている変数')を作成する[ドメイン側で指定]
-- random_product_id := (random() * 5 + 1)::int;
-- -- random_quantity('データベースの容量的にふさわしい範囲内で1~xxまでをloopする変数')を作成する[ドメイン側で指定]
-- random_quantity := (random() * 1000 +1)::int;
-- -- random_days('取得時にorder_byするから関係ない')
-- -- DATE型で入り、pgSQLではinterval型として認識される
-- random_offset := floor(random() * (end_date - start_date + 1));
-- random_date := start_date + random_offset;

-- random_index := (random() * 50 +1)::int;


--------------------------------------------------------------
-- FOR i IN 1..random_index LOOP
-- --- これ自体が一回の通信で起きること。これらが全て同じ範囲でloopされる(購入したい分だけ実行される。けど日数を昇順にしなければいけない。ここ課題)---
-- -- 注文が確定した通信
-- INSERT INTO orders (order_id, order_datatime) -- 自動採番だったらここで指定しないけど自動採番なのかも分からない。
-- VALUES('自動採番', '引数から取得したランダムな日数');
-- -- ordersの後にそれを参照しながら追加されるカラム
-- INSERT INTO order_details(order_detail_id, order_id, product_id, quantity)
-- VALUES('自動採番', orders.order_id, random_product_id, random_quantity)
-- ---
-- END LOOP;

-- 続き　まずは変数だけループさせてみて、ちゃんと表示されるか確かめてみる。
-- そっから関数を一つづつ実行してターミナルで確認してみる。
