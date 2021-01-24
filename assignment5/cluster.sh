# checkout the master branch of apache/flink
gh repo clone apache/flink
# find the WordCount example
cd flink-examples/flink-examples-streaming
# change the code...

# format the code
mvn spotless:apply

# create a jar
mvn package

# /Users/fschnei4/TUB_Master_ISM/WiSe20/CC/CloudComputing2020/assignment5/flink-master/flink-examples/flink-examples-streaming/target/flink-examples-streaming_2.11-1.13-SNAPSHOT-WordCount.jar
# run the Flink app

# we assume to be in the root directory of the unzipped Flink distribution
cd apache-flink/flink-1.12.0
# (1) Start Cluster
./bin/start-cluster.sh

# (2) You can now access the Flink Web Interface on http://localhost:8081

# (3) Submit the flink job and save the output in a .txt file

./bin/flink run /Users/fschnei4/TUB_Master_ISM/WiSe20/CC/CloudComputing2020/assignment5/flink-master/flink-examples/flink-examples-streaming/target/WordCount.jar --input /Users/fschnei4/TUB_Master_ISM/WiSe20/CC/CloudComputing2020/assignment5/tolstoy-war-and-peace.txt --output /Users/fschnei4/TUB_Master_ISM/WiSe20/CC/CloudComputing2020/assignment5/WordCountResults.txt


# (4) Stop the cluster again
./bin/stop-cluster.sh