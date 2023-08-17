#!/bin/bash

# The 1st argument is set to YES if you want to create a master, the default is YES
# The 2nd argument is the number of slaves you want to create, the default is 2

# The default hadoop cluster has 3 nodes includes 1 master and 2 slaves

# Set the default CREATE_HADOOP_MASTER is NO
CREATE_HADOOP_MASTER=${1:-YES}
echo "CREATE_HADOOP_MASTER =" $CREATE_HADOOP_MASTER

# Set the default hadoop slave number is 2
HADOOP_SLAVE_NUMBER=${2:-2}
echo "HADOOP_SLAVE_NUMBER =" $HADOOP_SLAVE_NUMBER

if [[ ${CREATE_HADOOP_MASTER} == "YES" ]]; then
	# Start hadoop master container
	sudo docker rm -f hadoop-master &> /dev/null
	echo "Start hadoop-master container in the hadoop network..."
	sudo docker run -itd \
		--net=hadoop \
		-p 50070:50070 \
		-p 8088:8088 \
		-e HADOOP_SLAVE_NUMBER=$HADOOP_SLAVE_NUMBER \
		--name hadoop-master \
		--hostname hadoop-master \
		lsc/hadoop:2.7.7 &> /dev/null
fi

# Start hadoop slave containers
i=1
while [ $i -lt $((HADOOP_SLAVE_NUMBER+1)) ]
do
	sudo docker rm -f hadoop-slave$i &> /dev/null
	echo "Start hadoop-slave$i container..."

	# To avoid port confliction in the same host machine, slaves' ports are mapped to 5007$i
	sudo docker run -itd \
		--net=hadoop \
		-p 5007$i:50075 \
		-e HADOOP_SLAVE_NUMBER=$HADOOP_SLAVE_NUMBER \
		--name hadoop-slave$i \
		--hostname hadoop-slave$i \
		lsc/hadoop:2.7.7 &> /dev/null
	
	i=$(($i+1))
done
