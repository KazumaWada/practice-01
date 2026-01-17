#このシェルスクリプトファイルは、バッチ処理で叩くためのファイル。

#!/bin/bash

# テストデータを生成を実行するファイル
# docker execまでは採点者が移動すると思うから、psqlコマンドでログインするところからスタートだと思う。

# どこかでエラーが起こったら終了させる。
set -e

# $0: スクリプト名, $1: 引数01, $2: 引数01

START_DATE="$1"
END_DATE="$2"

# -z: zero, つまり空文字だったら.("["と-zの間にスペースがなければエラーになる。閉じタグも同じ。)
# &: これがくっついていたら、値を取り出すことができる

# NOTE: 日程がstart < end になっているかとかを確かめる制御が存在していない。
if [ -z "$START_DATE" ] || [ -z "$END_DATE" ]; then
 echo "Usage: $0 <start_date> <end_date>"
 exit 1
fi

# TODO: 現実的な日程か、end dateの方がstart dateよりも前になっていないかなどの例外処理

# これで.sqlにあるCREATE FUNCTIONを実行していると思っているが、ただ定義されているだけで、関数の中身は実行されていない。
# SELECT generate_test_data(2025-07-01, 2025-07-05); で実行される。
# psql -U postgres -d practice_db \
#  -v start_date="$START_DATE" \
#  -v end_date="$END_DATE" \
#  -f functions/generate_test_data.sql


# こうやって呼び出すことができる。
# psql -U ユーザー名 -d データベース名 -c "SELECT generate_test_data($START_DATE, $END_DATE);"
psql -U postgres -d practice_db -f /workspace/answer/functions/generate_test_data.sql
psql -U postgres -d practice_db -c "SELECT generate_test_data('$START_DATE'::DATE, '$END_DATE'::DATE);"