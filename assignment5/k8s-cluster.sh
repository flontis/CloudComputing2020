#####################
#   Task 1          #
#####################
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
./bin/flink run /path/toWordCount.jar --input /path/to/tolstoy-war-and-peace.txt --output /path/to/WordCountResults.txt

# (4) Stop the cluster again
./bin/stop-cluster.sh

#####################
#   Task 2          #
#####################

# Setup Hadoop on Minikube

# Start minikube with VB driver and enough resources
minikube config set vm-driver virtualbox
minikube --memory 4096 --cpus 2 start

# install helm
brew install helm

# Initialize a Helm Chart Repository
helm repo add stable https://charts.helm.sh/stable

# spinup hadoop cluster
  helm install \
    --set yarn.nodeManager.resources.limits.memory=4096Mi \
    --set yarn.nodeManager.replicas=1 \
    stable/hadoop \
    --generate-name

# after a while, check the status of HDFS 
kubectl exec -n default -it hadoop-1611589334-hadoop-hdfs-nn-0 -- /usr/local/hadoop/bin/hdfs dfsadmin -report

# make sure Flink components are able to reference themselves through a Kubernetes service
minikube ssh 'sudo ip link set docker0 promisc on'

# Starting a Kubernetes Cluster (Session Mode)
# Configuration and service definition
kubectl create -f flink-k8s/flink-configuration-configmap.yaml
kubectl create -f flink-k8s/jobmanager-service.yaml
# Create the deployments for the cluster
kubectl create -f flink-k8s/jobmanager-session-deployment.yaml
kubectl create -f flink-k8s/taskmanager-session-deployment.yaml

# set an env variable with the pod name of the Flink JobManager (Master)
JOBMANAGER=$(kubectl get pod -l app=flink -o jsonpath="{.items[0].metadata.name}")

# same for the HDFS NodeManager (Master)
NODEMANAGER=$(kubectl get pods | grep yarn-nm | awk '{print $1}')

# put .jar on the  NodeManager container
kubectl cp WordCount.jar "${NODEMANAGER}":/home
# SSH into the  NodeManager container and create an input directory
kubectl exec -it "${NODEMANAGER}" bash
cd /home
mkdir input
exit

# put data on the NodeManager container
kubectl cp tolstoy-war-and-peace.txt "${NODEMANAGER}":/home/input

# SSH into the  NodeManager container
kubectl exec -it "${NODEMANAGER}" bash 

# put the data into the HDFS drive
/usr/local/hadoop/bin/hadoop fs -put input/tolstoy-war-and-peace.txt /input/tolstoy-war-and-peace.txt

# forward port of Flink JobManager
kubectl port-forward $JOBMANAGER 8081:8081

# forward port of HDFS NodeManager
kubectl port-forward $NODEMANAGER 8088:8088

# check for the file
/usr/local/hadoop/bin/hadoop fs -ls -d /input

# submit jobs to the cluster
./bin/flink run -m localhost:8081 
./WordCount.jar

# tear down the cluster
kubectl delete -f jobmanager-service.yaml
kubectl delete -f flink-configuration-configmap.yaml
kubectl delete -f taskmanager-session-deployment.yaml
kubectl delete -f jobmanager-session-deployment.yaml

minikube delete --all