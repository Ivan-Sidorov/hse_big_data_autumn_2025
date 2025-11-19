USE flights_db;

CREATE EXTERNAL TABLE IF NOT EXISTS airports (
    airport_id INT,
    city STRING,
    state STRING,
    name STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/flights_db.db/airports'
TBLPROPERTIES ('skip.header.line.count'='1');

CREATE EXTERNAL TABLE IF NOT EXISTS flights (
    day_of_month INT,
    day_of_week INT,
    carrier STRING,
    origin_airport_id INT,
    dest_airport_id INT,
    dep_delay INT,
    arr_delay INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/flights_db.db/flights'
TBLPROPERTIES ('skip.header.line.count'='1');




