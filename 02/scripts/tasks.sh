#!/usr/bin/env bash

echo "127.0.0.1 namenode" >> /etc/hosts
echo "127.0.0.1 resourcemanager" >> /etc/hosts

hdfs namenode -format -force -nonInteractive

hdfs --daemon start namenode
hdfs --daemon start datanode
yarn --daemon start resourcemanager
yarn --daemon start nodemanager

wait_for_hdfs() {
    echo "Ожидание доступности HDFS..."
    for i in {1..60}; do
        if hdfs dfs -ls / &>/dev/null; then
            echo "HDFS доступен!"
            return 0
        fi
        echo "Попытка $i/60: HDFS недоступен, ожидание..."
        sleep 5
    done
    echo "ОШИБКА: HDFS недоступен после 5 минут ожидания"
    exit 1
}

wait_for_yarn() {
    echo "Ожидание доступности YARN ResourceManager..."
    for i in {1..60}; do
        if yarn node -list &>/dev/null; then
            echo "YARN доступен!"
            return 0
        fi
        echo "Попытка $i/60: YARN недоступен, ожидание..."
        sleep 5
    done
    echo "ОШИБКА: YARN недоступен после 5 минут ожидания"
    exit 1
}

wait_for_hdfs
wait_for_yarn

echo ""
echo "=========================================="
echo "Создание директорий в HDFS"
echo "=========================================="
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -chmod -R 777 /user/hive/warehouse
hdfs dfs -mkdir -p /tmp
hdfs dfs -chmod -R 777 /tmp

echo ""
echo "=========================================="
echo "Загрузка данных в HDFS"
echo "=========================================="
hdfs dfs -mkdir -p /user/hive/warehouse/flights_db.db/airports
hdfs dfs -mkdir -p /user/hive/warehouse/flights_db.db/flights

hdfs dfs -put -f /opt/data/airports.csv /user/hive/warehouse/flights_db.db/airports/
hdfs dfs -put -f /opt/data/flights.csv /user/hive/warehouse/flights_db.db/flights/

echo ""
echo "=========================================="
echo "Инициализация схемы Hive"
echo "=========================================="
$HIVE_HOME/bin/schematool -dbType derby -initSchema

echo ""
echo "=========================================="
echo "Создание базы данных и таблиц"
echo "=========================================="
hive -f /opt/scripts/create_database.sql
hive -f /opt/scripts/create_tables.sql

echo ""
echo "=========================================="
echo "Создание витрин данных"
echo "=========================================="
hive -f /opt/scripts/create_marts.sql

echo ""
echo "=========================================="
echo "Проверка результатов"
echo "=========================================="
echo "Список таблиц в базе данных:"
hive -e "USE flights_db; SHOW TABLES;"

echo ""
echo "Количество записей в таблице flights:"
hive -e "USE flights_db; SELECT COUNT(*) FROM flights;"

echo ""
echo "Содержимое витрины mart_flights_by_day_of_week:"
hive -e "USE flights_db; SELECT * FROM mart_flights_by_day_of_week;"

echo ""
echo "Содержимое витрины mart_top_origin_airports:"
hive -e "USE flights_db; SELECT * FROM mart_top_origin_airports LIMIT 10;"

echo ""
echo "Содержимое витрины mart_carrier_delays:"
hive -e "USE flights_db; SELECT * FROM mart_carrier_delays;"

echo ""
echo "Содержимое витрины mart_popular_routes:"
hive -e "USE flights_db; SELECT * FROM mart_popular_routes LIMIT 10;"

echo ""
echo "Содержимое витрины mart_delay_statistics:"
hive -e "USE flights_db; SELECT * FROM mart_delay_statistics;"

echo ""
echo "Содержимое витрины mart_airport_ranking:"
hive -e "USE flights_db; SELECT * FROM mart_airport_ranking;"
echo ""
