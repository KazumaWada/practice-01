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

# これで.sqlにあるCREATE FUNCTIONを実行していると思っているが、ただ定義されているだけで、関数の中身は実行されていない。
# SELECT test_notice(2025-07-01, 2025-07-05); で実行される。
psql -U postgres -d practice_db \
 -v start_date="$START_DATE" \
 -v end_date="$END_DATE" \
 -f functions/generate_test_data.sql