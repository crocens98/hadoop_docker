#!/bin/sh

VAR CONTAINER_IP=cat /etc/hosts | grep hadoop-host | awk '{print $1}'
printf "<configuration><property><name>fs.defaultFS</name><value>hdfs://%s:9000</value></property></configuration>"  "$CONTAINER_IP" > ~/hadoop/hadoop-3.2.1/etc/hadoop/core-site.xml


echo "Y" | ~/hadoop/hadoop-3.2.1/bin/hdfs namenode -format
start-all.sh

hadoop fs -mkdir /hw2
hadoop fs -mkdir /hw2/hotels
hadoop fs -mkdir /hw2/weather
hadoop fs -mkdir /hw2/expedia

hadoop fs -mkdir /tmp
hadoop fs -mkdir -p /user/hive/warehouse
hadoop fs -chmod g+w /tmp
hadoop fs -chmod g+w /user/hive/warehouse

hadoop fs -mkdir /root
hadoop fs -mkdir /root/hadoop/
hadoop fs -mkdir /root/hadoop/apache-hive-3.1.2-bin/
hadoop fs -mkdir /root/hadoop/apache-hive-3.1.2-bin/lib


cp /kafka-handler-3.1.3000.7.1.4.0-203.jar   /kafka-handler-3.1.3000.7.1.4.0-203.jar $HIVE_HOME/lib
cp /kafka-handler-3.1.3000.7.1.4.0-203.jar $HADOOP_HOME/share/hadoop/mapreduce/

hadoop fs -put /kafka-handler-3.1.3000.7.1.4.0-203.jar /root/hadoop/apache-hive-3.1.2-bin/lib


# need have data
hadoop fs -put /external/development/hotels /hw2/hotels
hadoop fs -put /external/development/expedia /hw2/expedia
hadoop fs -put /external/development/weather /hw2/weather
