# Задание по Hadoop и Hive

Этот проект реализует контейнеризованное решение для работы с Apache Hadoop 3.3.6 и Apache Hive 3.1.3, включая построение аналитических витрин данных на новых наборах `airports.csv` и `flights.csv`.

### Структура проекта:
```
02/
├── Dockerfile          # Docker-файл для создания образа
├── hadoop-config/      # Конфигурационные файлы Hadoop
├── hive-config/        # Конфигурационные файлы Hive
├── data/               # CSV файлы с данными о полетах
├── scripts/            # SQL скрипты и bash скрипт выполнения
└── results/            # Директория с результатами
```

### Запуск:

1. **Загрузить базовый образ:**
   ```bash
   docker pull eclipse-temurin:8-jre
   ```

2. **Собрать кастомный образ с Hadoop и Hive:**
   ```bash
   docker build --pull -t hadoop-hive-hw2:3.3.6 .
   ```

3. **Поднять кластер и выполнить задания:**
   ```bash
   docker run --rm --hostname any -e HADOOP_USER_NAME=hdfs hadoop-hive-hw2:3.3.6
   ```

### Описание данных:

В заданиях использовался следующий набор данных: https://www.kaggle.com/tylerx/flights-and-airports-data
Он представляет собой два csv-файла:
* `airports.csv` – информация об аэропортах (id, город, штат, название)
* `flights.csv` – информация о рейсах (день, перевозчик, аэропорты вылета/прилета, задержки вылета/прилета)

### Описание витрин:

1. **mart_flights_by_day_of_week** — Количество рейсов по дням недели
   - Использует WHERE, COUNT, GROUP BY, ORDER BY
   - Показывает пики нагрузки по дням недели
   - Помогает планировать расписание и ресурсы

2. **mart_top_origin_airports** — Топ аэропортов отправления
   - Использует JOIN, GROUP BY, ORDER BY
   - Ранжирует аэропорты по количеству исходящих рейсов
   - Помогает определить ключевые транспортные узлы

3. **mart_carrier_delays** — Статистика задержек по авиакомпаниям
   - Использует WHERE, COUNT, GROUP BY, HAVING, ORDER BY
   - Считает средние и максимальные задержки отправления и прибытия по авиакомпаниям
   - Используется для оценки качества обслуживания

4. **mart_popular_routes** — Популярные маршруты между аэропортами
   - Использует JOIN, COUNT, GROUP BY, ORDER BY
   - Выявляет самые востребованные направления
   - Помогает оптимизировать маршрутную сеть

5. **mart_delay_statistics** — Объединенная статистика задержек отправления и прибытия
   - Использует WHERE, GROUP BY, UNION ALL
   - Сравнивает распределение задержек отправления и прибытия
   - Показывает общую картину задержек

6. **mart_airport_ranking** — Полный рейтинг аэропортов
   - Использует оконные функции ROW_NUMBER, RANK, DENSE_RANK
   - Ранжирует аэропорты по общему количеству рейсов
   - Используется для сравнительного анализа аэропортов

### Проверка результатов:

1. Для проверки результатов применяются следующие команды:
```bash
# Список таблиц в базе данных
hive -e "USE flights_db; SHOW TABLES;"

# Количество записей в таблице flights
hive -e "USE flights_db; SELECT COUNT(*) FROM flights;"

# Содержимое витрины mart_flights_by_day_of_week
hive -e "USE flights_db; SELECT * FROM mart_flights_by_day_of_week;"

# Содержимое витрины mart_top_origin_airports
hive -e "USE flights_db; SELECT * FROM mart_top_origin_airports LIMIT 10;"

# Содержимое витрины mart_carrier_delays
hive -e "USE flights_db; SELECT * FROM mart_carrier_delays;"

Содержимое витрины mart_popular_routes
hive -e "USE flights_db; SELECT * FROM mart_popular_routes LIMIT 10;"

# Содержимое витрины mart_delay_statistics
hive -e "USE flights_db; SELECT * FROM mart_delay_statistics;"

# Содержимое витрины mart_airport_ranking
hive -e "USE flights_db; SELECT * FROM mart_airport_ranking;"
```

2. Логи проверки результата сохранены в файл `results/output.txt`.