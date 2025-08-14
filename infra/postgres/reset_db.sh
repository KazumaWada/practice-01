#!/bin/bash
# DBリセットスクリプト: 全テーブルtruncate & 初期データ再投入
# ホスト側から実行し、docker-composeで起動したコンテナに接続します。
set -e

# コンテナ名・DB情報
CONTAINER=sql-batch-practice-db
DB_USER=postgres
DB_NAME=practice_db

# テーブル名を取得
TABLES=$(docker exec -i $CONTAINER psql -U $DB_USER -d $DB_NAME -Atc "SELECT tablename FROM pg_tables WHERE schemaname='public';")

# truncate all tables
for t in $TABLES; do
  docker exec -i $CONTAINER psql -U $DB_USER -d $DB_NAME -c "TRUNCATE TABLE \"$t\" RESTART IDENTITY CASCADE;"
done

# 初期データ再投入
cat /docker-entrypoint-initdb.d/02_master_data.sql | docker exec -i $CONTAINER psql -U $DB_USER -d $DB_NAME

echo "DBリセット完了"
