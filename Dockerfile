FROM ubuntu:16.04
COPY ./.bashrc /root
# COPY ./hadoop-3.2.1.tar.gz /
# COPY ./apache-hive-3.1.2-bin.tar.gz /
COPY ./kafka-handler-3.1.3000.7.1.4.0-203.jar /
COPY ./GeohashHiveUDF-1.0-SNAPSHOT-jar-with-dependencies.jar /
COPY ./init-hdfs.sh /

ENV container docker
ENV ambari_repo http://public-repo-1.hortonworks.com/ambari/ubuntu16/2.x/updates/2.7.3.0/ambari.list

RUN apt-get update -y
RUN apt-get install -y wget ntp
RUN apt-get install -y openjdk-8-jdk
RUN apt install -y openjdk-8-jre-headless
RUN apt-get install dos2unix
RUN dos2unix /root/.bashrc
RUN dos2unix /init-hdfs.sh

RUN wget http://mirror.intergrid.com.au/apache/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz
RUN mkdir ~/hadoop
RUN tar -xvzf hadoop-3.2.1.tar.gz -C ~/hadoop
RUN apt-get install -y ssh

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN chmod 0600 ~/.ssh/authorized_keys
RUN service ssh restart



RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> ~/hadoop/hadoop-3.2.1/etc/hadoop/hadoop-env.sh
RUN echo 'export HDFS_DATANODE_USER=root' >> ~/hadoop/hadoop-3.2.1/etc/hadoop/hadoop-env.sh
RUN echo 'export HDFS_NAMENODE_USER=root' >> ~/hadoop/hadoop-3.2.1/etc/hadoop/hadoop-env.sh
RUN echo 'export HDFS_SECONDARYNAMENODE_USER=root' >> ~/hadoop/hadoop-3.2.1/etc/hadoop/hadoop-env.sh
RUN echo 'export YARN_RESOURCEMANAGER_USER=root' >> ~/hadoop/hadoop-3.2.1/etc/hadoop/hadoop-env.sh
RUN echo 'export YARN_NODEMANAGER_USER=root' >> ~/hadoop/hadoop-3.2.1/etc/hadoop/hadoop-env.sh

RUN chmod +x ~/hadoop/hadoop-3.2.1/etc/hadoop/hadoop-env.sh \
 ~/hadoop/hadoop-3.2.1/etc/hadoop/hadoop-env.sh

RUN wget http://www.strategylions.com.au/mirror/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz
RUN tar -xvzf apache-hive-3.1.2-bin.tar.gz -C ~/hadoop
RUN rm /root/hadoop/apache-hive-3.1.2-bin/lib/guava-19.0.jar
RUN cp /root/hadoop/hadoop-3.2.1/share/hadoop/hdfs/lib/guava-27.0-jre.jar /root/hadoop/apache-hive-3.1.2-bin/lib/
RUN export HADOOP_HOME=/root/hadoop/hadoop-3.2.1 && \
 /root/hadoop/apache-hive-3.1.2-bin/bin/schematool -dbType derby -initSchema

RUN cp /kafka-handler-3.1.3000.7.1.4.0-203.jar /root/hadoop/apache-hive-3.1.2-bin/lib
RUN cp /kafka-handler-3.1.3000.7.1.4.0-203.jar /root/hadoop/hadoop-3.2.1/share/hadoop/mapreduce/kafka-handler-3.1.3000.7.1.4.0-203.jar

RUN printf '<configuration><property><name>fs.defaultFS</name><value>hdfs://172.17.0.2:9000</value></property></configuration>' > ~/hadoop/hadoop-3.2.1/etc/hadoop/core-site.xml
RUN printf '<configuration><property><name>dfs.replication</name><value>1</value></property><property><name>dfs.permissions</name><value>false</value></property></configuration>' > ~/hadoop/hadoop-3.2.1/etc/hadoop/hdfs-site.xml
RUN printf '<configuration><property><name>mapreduce.framework.name</name><value>yarn</value></property><property><name>mapreduce.application.classpath</name><value>$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*:$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*</value></property></configuration>' > ~/hadoop/hadoop-3.2.1/etc/hadoop/mapred-site.xml
RUN printf '<configuration><property><name>yarn.nodemanager.aux-services</name><value>mapreduce_shuffle</value></property><property><name>yarn.nodemanager.env-whitelist</name><value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value></property></configuration>' > ~/hadoop/hadoop-3.2.1/etc/hadoop/yarn-site.xml

EXPOSE 5432 8440 8441 8440 8080 9870

CMD service ssh restart &&  export PATH=~/hadoop/hadoop-3.2.1/sbin/:$PATH &&  export PATH=~/hadoop/hadoop-3.2.1/bin:$PATH  && sleep infinity
