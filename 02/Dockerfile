FROM eclipse-temurin:8-jre

ENV HADOOP_VERSION=3.3.6
ENV HIVE_VERSION=3.1.3
ENV HADOOP_HOME=/opt/hadoop
ENV HIVE_HOME=/opt/hive
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
ENV HIVE_CONF_DIR=/opt/hive/conf
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME/bin
ENV JAVA_HOME=/opt/java/openjdk
ENV HADOOP_USER_NAME=hdfs

WORKDIR /opt
ADD https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz /opt/
RUN tar -xzf hadoop-${HADOOP_VERSION}.tar.gz && \
    mv hadoop-${HADOOP_VERSION} ${HADOOP_HOME} && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

ADD https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz /opt/
RUN tar -xzf apache-hive-${HIVE_VERSION}-bin.tar.gz && \
    mv apache-hive-${HIVE_VERSION}-bin ${HIVE_HOME} && \
    rm apache-hive-${HIVE_VERSION}-bin.tar.gz

RUN mkdir -p ${HIVE_HOME}/warehouse && \
    mkdir -p ${HIVE_HOME}/tmp && \
    mkdir -p ${HIVE_HOME}/logs

COPY hadoop-config/capacity-scheduler.xml ${HADOOP_CONF_DIR}/capacity-scheduler.xml
COPY hadoop-config/core-site.xml ${HADOOP_CONF_DIR}/core-site.xml
COPY hadoop-config/hdfs-site.xml ${HADOOP_CONF_DIR}/hdfs-site.xml
COPY hadoop-config/mapred-site.xml ${HADOOP_CONF_DIR}/mapred-site.xml
COPY hadoop-config/yarn-site.xml ${HADOOP_CONF_DIR}/yarn-site.xml

COPY hive-config/hive-site.xml ${HIVE_CONF_DIR}/hive-site.xml

COPY scripts/tasks.sh /tasks.sh
COPY scripts/*.sql /opt/scripts/
RUN chmod +x /tasks.sh && \
    mkdir -p /opt/scripts && \
    mkdir -p /opt/data

COPY data/*.csv /opt/data/

ENTRYPOINT ["/tasks.sh"]

