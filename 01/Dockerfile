FROM eclipse-temurin:11-jre

ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
ENV JAVA_HOME=/opt/java/openjdk
ENV HADOOP_USER_NAME=hdfs

WORKDIR /opt
ADD https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz /opt/
RUN tar -xzf hadoop-${HADOOP_VERSION}.tar.gz && \
    mv hadoop-${HADOOP_VERSION} ${HADOOP_HOME} && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

COPY hadoop-config/capacity-scheduler.xml ${HADOOP_CONF_DIR}/capacity-scheduler.xml
COPY hadoop-config/core-site.xml  ${HADOOP_CONF_DIR}/core-site.xml
COPY hadoop-config/hdfs-site.xml  ${HADOOP_CONF_DIR}/hdfs-site.xml
COPY hadoop-config/mapred-site.xml ${HADOOP_CONF_DIR}/mapred-site.xml
COPY hadoop-config/yarn-site.xml  ${HADOOP_CONF_DIR}/yarn-site.xml

COPY tasks.sh /tasks.sh
RUN chmod +x /tasks.sh
ENTRYPOINT ["/tasks.sh"]