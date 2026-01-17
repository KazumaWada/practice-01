#!/bin/bash

set -e

SELECTED_DATE="$1"


# psql -U ユーザー名 -d データベース名 -c "SELECT generate_test_data($START_DATE, $END_DATE);"
psql -U postgres -d practice_db -f /workspace/answer/functions/summarize_daily_sales.sql
psql -U postgres -d practice_db -c "SELECT generate_test_data('$SELECTED_DATE'::DATE);"