#!/usr/bin/env bash

# первоначальная настройка HDFS
echo "127.0.0.1 namenode" >> /etc/hosts
echo "127.0.0.1 resourcemanager" >> /etc/hosts

hdfs namenode -format -force -nonInteractive

hdfs --daemon start namenode
hdfs --daemon start datanode
yarn --daemon start resourcemanager
yarn --daemon start nodemanager

# Функция ожидания доступности HDFS
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

# Функция ожидания доступности YARN
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

# ожидаем доступности сервисов
wait_for_hdfs
wait_for_yarn

# переходим к заданиям
echo ""
echo "=========================================="
echo "Текущее состояние HDFS перед выполнением задач:"
echo "=========================================="
hdfs dfs -ls /

# 1) создать директорию /createme
echo ""
echo "=========================================="
echo "ЗАДАНИЕ 1: Создание директории /createme"
echo "=========================================="
hdfs dfs -mkdir -p /createme
if [ $? -eq 0 ]; then
    echo "Директория /createme создана"
    hdfs dfs -ls / | grep createme
else
    echo "Ошибка при создании директории /createme"
fi

# 2) удалить директорию /delme
echo ""
echo "=========================================="
echo "ЗАДАНИЕ 2: Удаление директории /delme"
echo "=========================================="
hdfs dfs -rm -r -f /delme || true
if [ $? -eq 0 ]; then
    echo "Директория /delme удалена"
else
    echo "Ошибка при удалении директории /delme"
fi

# 3) создать файл /nonnull.txt
echo ""
echo "=========================================="
echo "ЗАДАНИЕ 3: Создание файла /nonnull.txt"
echo "=========================================="
echo "Lorem ipsum dolor sit amet" | hdfs dfs -put -f - /nonnull.txt

if [ $? -eq 0 ]; then
    echo "Файл /nonnull.txt создан"
else
    echo "Ошибка при создании файла /nonnull.txt"
fi

# 4) создать файл /shadow.txt
echo ""
echo "=========================================="
echo "ЗАДАНИЕ 4.1: Создание файла /shadow.txt"
echo "=========================================="
cat > /opt/shadow.txt <<'TXT'
The old lighthouse keeper had heard the rumors about Innsmouth long before he accepted the posting. They said Innsmouth was a dying town where the fish had stopped biting and the people had grown strange. When he finally arrived at Innsmouth on a gray October morning, the smell of brine and decay hung heavy in the air.

The natives of Innsmouth watched him from shadowed doorways, their eyes reflecting an odd, greenish light. He tried to tell himself that Innsmouth was just another coastal town fallen on hard times, but the whispers that echoed through the streets at night told a different story. By his third week in Innsmouth he understood why no keeper had lasted more than a month—and why he wouldn't either.
TXT
hdfs dfs -put -f /opt/shadow.txt /shadow.txt
if [ $? -eq 0 ]; then
    echo "Файл /shadow.txt создан"
else
    echo "Ошибка при создании файла /shadow.txt"
fi

# 4.2) выполнить wordcount для /shadow.txt
echo ""
echo "=========================================="
echo "ЗАДАНИЕ 4.2: Выполнение MapReduce WordCount"
echo "=========================================="
OUT=/wordcount_output
EX_JAR="$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar"
yarn jar "$EX_JAR" wordcount /shadow.txt "$OUT"

# 5) записать число вхождений 'Innsmouth'
echo ""
echo "=========================================="
echo "ЗАДАНИЕ 5: Запись числа вхождений 'Innsmouth'"
echo "=========================================="
CNT=$(hdfs dfs -cat $OUT/part-* | grep -i "^Innsmouth" | awk '{sum+=$2} END {print sum+0}')
printf "%s\n" "$CNT" | hdfs dfs -put -f - /whataboutinsmouth.txt

if [ $? -eq 0 ]; then
    echo "Число вхождений 'Innsmouth' записано в /whataboutinsmouth.txt"
else
    echo "Ошибка при записи числа вхождений 'Innsmouth' в /whataboutinsmouth.txt"
fi

# валидация результата
echo ""
echo "=========================================="
echo "Валидация результата"
echo "=========================================="
echo "Текущие файлы в HDFS:"
hdfs dfs -ls /
echo ""
echo "Содержимое файла /whataboutinsmouth.txt:"
hdfs dfs -cat /whataboutinsmouth.txt
echo ""
echo "MR wordcount результаты:"
hdfs dfs -cat "$OUT"/part-* | head -n 50
echo ""