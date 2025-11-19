USE flights_db;

-- Витрина 1: Количество рейсов по дням недели
CREATE TABLE IF NOT EXISTS mart_flights_by_day_of_week AS
SELECT
    day_of_week,
    COUNT(*) AS total_flights
FROM
    flights
WHERE
    dep_delay IS NOT NULL
GROUP BY
    day_of_week
ORDER BY
    day_of_week;

-- Витрина 2: Топ самых загруженных аэропортов отправления
CREATE TABLE IF NOT EXISTS mart_top_origin_airports AS
SELECT
    a.airport_id,
    a.name AS airport_name,
    a.city,
    a.state,
    COUNT(*) AS total_flights
FROM
    flights f
    JOIN airports a ON f.origin_airport_id = a.airport_id
GROUP BY
    a.airport_id,
    a.name,
    a.city,
    a.state
ORDER BY
    total_flights DESC;

-- Витрина 3: Статистика задержек по авиакомпаниям
CREATE TABLE IF NOT EXISTS mart_carrier_delays AS
SELECT
    carrier,
    COUNT(*) AS total_flights,
    COUNT(
        CASE
            WHEN dep_delay > 0 THEN 1
        END
    ) AS delayed_departures,
    COUNT(
        CASE
            WHEN arr_delay > 0 THEN 1
        END
    ) AS delayed_arrivals,
    AVG(dep_delay) AS avg_dep_delay,
    AVG(arr_delay) AS avg_arr_delay,
    MAX(dep_delay) AS max_dep_delay,
    MAX(arr_delay) AS max_arr_delay
FROM
    flights
WHERE
    dep_delay IS NOT NULL
    AND arr_delay IS NOT NULL
GROUP BY
    carrier
HAVING
    COUNT(*) > 1000
ORDER BY
    avg_dep_delay;

-- Витрина 4: Популярные маршруты между аэропортами
CREATE TABLE IF NOT EXISTS mart_popular_routes AS
SELECT
    o.name AS origin_airport,
    o.city AS origin_city,
    o.state AS origin_state,
    d.name AS dest_airport,
    d.city AS dest_city,
    d.state AS dest_state,
    COUNT(*) AS route_count
FROM
    flights f
    JOIN airports o ON f.origin_airport_id = o.airport_id
    JOIN airports d ON f.dest_airport_id = d.airport_id
GROUP BY
    o.name,
    o.city,
    o.state,
    d.name,
    d.city,
    d.state
ORDER BY
    route_count DESC;

-- Витрина 5: Объединенная статистика по задержкам отправления и прибытия
CREATE TABLE IF NOT EXISTS mart_delay_statistics AS
SELECT
    'departure' AS delay_type,
    CASE
        WHEN dep_delay < 0 THEN 'early'
        WHEN dep_delay = 0 THEN 'on_time'
        WHEN dep_delay > 0
        AND dep_delay <= 15 THEN 'small_delay'
        WHEN dep_delay > 15 THEN 'large_delay'
    END AS delay_category,
    COUNT(*) AS flight_count
FROM
    flights
WHERE
    dep_delay IS NOT NULL
GROUP BY
    CASE
        WHEN dep_delay < 0 THEN 'early'
        WHEN dep_delay = 0 THEN 'on_time'
        WHEN dep_delay > 0
        AND dep_delay <= 15 THEN 'small_delay'
        WHEN dep_delay > 15 THEN 'large_delay'
    END
UNION
ALL
SELECT
    'arrival' AS delay_type,
    CASE
        WHEN arr_delay < 0 THEN 'early'
        WHEN arr_delay = 0 THEN 'on_time'
        WHEN arr_delay > 0
        AND arr_delay <= 15 THEN 'small_delay'
        WHEN arr_delay > 15 THEN 'large_delay'
    END AS delay_category,
    COUNT(*) AS flight_count
FROM
    flights
WHERE
    arr_delay IS NOT NULL
GROUP BY
    CASE
        WHEN arr_delay < 0 THEN 'early'
        WHEN arr_delay = 0 THEN 'on_time'
        WHEN arr_delay > 0
        AND arr_delay <= 15 THEN 'small_delay'
        WHEN arr_delay > 15 THEN 'large_delay'
    END
ORDER BY
    delay_type,
    delay_category;

-- Витрина 6: Рейтинг аэропортов с использованием оконных функций
CREATE TABLE IF NOT EXISTS mart_airport_ranking AS
SELECT
    airport_id,
    airport_name,
    city,
    state,
    total_flights,
    ROW_NUMBER() OVER (
        ORDER BY
            total_flights DESC
    ) AS row_num,
    RANK() OVER (
        ORDER BY
            total_flights DESC
    ) AS rank_by_flights,
    DENSE_RANK() OVER (
        ORDER BY
            total_flights DESC
    ) AS dense_rank_by_flights
FROM
    (
        SELECT
            a.airport_id,
            a.name AS airport_name,
            a.city,
            a.state,
            COUNT(*) AS total_flights
        FROM
            flights f
            JOIN airports a ON f.origin_airport_id = a.airport_id
        GROUP BY
            a.airport_id,
            a.name,
            a.city,
            a.state
    ) AS airport_stats
ORDER BY
    total_flights DESC;