#!/bin/bash

# The default HADOOP_SLAVE_NUMBER is 2
HADOOP_SLAVE_NUMBER=${HADOOP_SLAVE_NUMBER:-2}
echo "HADOOP_SLAVE_NUMBER =" $HADOOP_SLAVE_NUMBER

# Delete the old slaves file
rm $HADOOP_HOME/etc/hadoop/slaves

# Change slaves file
i=1
while [ $i -lt $((HADOOP_SLAVE_NUMBER+1)) ]
do
	echo "hadoop-slave$i" >> $HADOOP_HOME/etc/hadoop/slaves
	((i++))
done 

# Start hadoop service
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

# if [[ $1 == "-d" ]]; then
# 	while true
# 	do 
# 		sleep 10
# 	done
# elif [[ $1 == "-bash" ]]; then
# 	/bin/bash
# fi