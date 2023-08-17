#!/bin/bash

# Test the hadoop cluster by running wordcount

# Create input files 
mkdir input
echo "Hello Docker" >input/file1.txt
echo "Hello Hadoop" >input/file2.txt

# Create input directory on HDFS
hadoop fs -mkdir -p input

# Put input files to HDFS
hdfs dfs -put ./input/* input

# Run wordcount 
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/sources/hadoop-mapreduce-examples-2.7.7-sources.jar org.apache.hadoop.examples.WordCount input output

# print the input files
echo -e "\nInput file1.txt:"
hdfs dfs -cat input/file1.txt

echo -e "\nInput file2.txt:"
hdfs dfs -cat input/file2.txt

# print the output of wordcount
echo -e "\nWordcount output:"
hdfs dfs -cat output/part-r-00000

