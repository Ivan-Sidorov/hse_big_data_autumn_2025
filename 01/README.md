# Задание по Hadoop

Этот проект реализует контейнеризованное решение для работы с Apache Hadoop 3.3.6, включая развертывание полного кластера и выполнение тестовых задач.

### Структура проекта:
```
big_data/
├── Dockerfile          # Docker-файл для создания образа
├── hadoop-config/      # Конфигурационные файлы
├── results/            # Директория с результатом (вывод консоли)
└── tasks.sh            # bash-скрипт, выполняющий задания
```

### Запуск:

1. **Загрузить базовый образ:**
   ```bash
   docker pull eclipse-temurin:11-jre
   ```

2. **Собрать кастомный образ с Hadoop:**
   ```bash
   sudo docker build -t hadoop-hw1:3.3.6 .
   ```

3. **Поднять кластер Hadoop и выполнить задания:**
   ```bash
   docker run --rm --hostname any -e HADOOP_USER_NAME=hdfs hadoop-hw1:3.3.6
   ```

### Проверка результатов:

1. Для проверки результатов применяются следующие команды:
```bash
# убедиться, что операции с директориями выполнены корректно
hdfs dfs -ls /
# убедиться, что в этот файл было записано число вхождений Innsmouth
hdfs dfs -cat /whataboutinsmouth.txt
# посмотреть на результат работы MR wordcount
hdfs dfs -cat "$OUT"/part-* | head -n 50
```

2. В файле shadow.txt содержался следующий текст (генерировал ChatGPT):
```
The old lighthouse keeper had heard the rumors about Innsmouth long before he accepted the posting. They said Innsmouth was a dying town where the fish had stopped biting and the people had grown strange. When he finally arrived at Innsmouth on a gray October morning, the smell of brine and decay hung heavy in the air.

The natives of Innsmouth watched him from shadowed doorways, their eyes reflecting an odd, greenish light. He tried to tell himself that Innsmouth was just another coastal town fallen on hard times, but the whispers that echoed through the streets at night told a different story. By his third week in Innsmouth he understood why no keeper had lasted more than a month—and why he wouldn't either.
```

3. Результат wordcount
```
By         1
He         1
Innsmouth  6
October    1
The        2
They       1
When       1
a          4
about      1
accepted   1
air.       1
an         1
and        2
another    1
arrived    1
at         2
before     1
biting     1
brine      1
but        1
coastal    1
decay      1
different  1
doorways,  1
dying      1
echoed     1
either.    1
eyes       1
fallen     1
finally    1
fish       1
from       1
gray       1
greenish   1
grown      1
had        4
hard       1
he         4
heard      1
heavy      1
him        1
himself    1
his        1
hung       1
in         2
just       1
keeper     2
lasted     1
light.     1
lighthouse 1
```