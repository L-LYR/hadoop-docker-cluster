# Download ubuntu base image 18.04
FROM ubuntu:18.04
MAINTAINER lsc

WORKDIR /root

# Install openssh-server, openjdk and wget
RUN sed -i s@/archive.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list
RUN apt-get clean && apt-get update && apt-get install -y openssh-server openjdk-8-jdk wget nano iputils-ping net-tools telnet

# Install HADOOP
ADD hadoop-2.7.7.tar.gz .
RUN mv hadoop-2.7.7 /usr/local/hadoop

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop 
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin 
# Define the hadoop slaves in the hadoop cluster
ENV HADOOP_SLAVE_NUMBER 2

# ssh without key
RUN ssh-keygen -t rsa -f /root/.ssh/id_rsa -P '' && \
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

# Create the default directories
RUN mkdir -p /root/hdfs/namenode && \ 
    mkdir -p /root/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

# Copy resources from the host to the docker container
COPY config/ssh_config /root/.ssh/config
COPY config/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh
COPY config/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
COPY config/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY config/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
COPY config/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
COPY config/slaves $HADOOP_HOME/etc/hadoop/slaves
COPY config/start_hadoop.sh /root/start_hadoop.sh
COPY config/run_wordcount.sh /root/run_wordcount.sh

RUN chmod +x /root/start_hadoop.sh && \
    chmod +x /root/run_wordcount.sh && \
    chmod +x $HADOOP_HOME/etc/hadoop/slaves && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

# Format namenode
RUN $HADOOP_HOME/bin/hdfs namenode -format

# Start services. NOTE: the /bin/bash has to run finally to keep the container running
CMD [ "sh", "-c", "service ssh start; /root/start_hadoop.sh; /bin/bash"]

# HDFS ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 10020 19888
# Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
