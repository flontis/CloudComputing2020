------------------------ Commands to setup hdfs without kubernetes ------------------------

# first, setup 3 GCP nodes, we used Ubuntu 18.04 as OS on e2-standard-4 machines (4 vCPUs, 16 GB Mem). Smaller ones might work, but can face ressource problems with heavier tasks. The nodes have to be in the same subnetwork.

# configure ssh access to the VMs from local host and between the VMs. This task is described in previous assignments and skipped here

# install wget, Java 8 and pdsh 

# download hadoop and untar the folder
sudo wget -P ~ https://mirrors.sonic.net/apache/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz
tar xzf hadoop-3.2.1.tar.gz

# change folder name for easer readability (optional command, if skipped, adjust following commands accordingly)
mv hadoop-3.2.1 hadoop

# edit the hadoop-env.sh file so that it contains the exported Java-Home
nano ~/hadoop/etc/hadoop/hadoop-env.sh
--> add line "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/"

# move folder to /usr/local/hadoop
sudo mv hadoop /usr/local/hadoop

# open /etc/environment and adjust path variable
sudo nano /etc/environment
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/local/hadoop/bin:/usr/local/hadoop/sbin"JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre"

# create user hadoopuser (if you choose another name, adjust following commands). Set the password, skip all other # asked information
sudo adduser hadoopuser

# adjust rights of new user
sudo usermod -aG hadoopuser hadoopuser
sudo chown hadoopuser:root -R /usr/local/hadoop/
sudo chmod g+rwx -R /usr/local/hadoop/
sudo adduser hadoopuser sudo

# edit the /etc/hosts file, enter the local IP of the hosts and their names, e.g.
10.240.0.15 hadoop-master
10.240.0.16 hadoop-slave1
10.240.0.17 hadoop-slave2

# insert the hostname of every machine in the machine's /etc/hostname file
sudo nano /etc/hostname
on master vm --> enter master name, e.g. hadoop-master
on slave vms --> enter slave names, e.g. hadoop-slave1 on slave-vm1, hadoop-slave2 on slave-vm2

# reboot in order to make changes take effect
sudo reboot

# make sure to enable ssh access between hadoopuser's on every machine

# config the core-site.xml on the master to define the "entry point" of the hdfs
# enter in the /usr/local/hadoop/etc/hadoop/core-site.xml:
<configuration>
<property>
<name>fs.defaultFS</name>
<value>hdfs://hadoop-master:9000</value>
</property>
</configuration>

# same way, configure /usr/local/hadoop/etc/hadoop/hdfs-site.xml. Define NameNode directory and DataNode directory as well as amount of replicas. Enter:
<configuration>
<property>
<name>dfs.namenode.name.dir</name><value>/usr/local/hadoop/data/nameNode</value>
</property>
<property>
<name>dfs.datanode.data.dir</name><value>/usr/local/hadoop/data/dataNode</value>
</property>
<property>
<name>dfs.replication</name>
<value>2</value>
</property>
</configuration>

# configure the worker nodes by adding their host-names to /usr/local/hadoop/etc/hadoop/workers, e.g.
hadoop-slave1
hadoop-slave2

# copy the configuration to the slave VMs
scp /usr/local/hadoop/etc/hadoop/* hadoop-slave1:/usr/local/hadoop/etc/hadoop/
scp /usr/local/hadoop/etc/hadoop/* hadoop-slave2:/usr/local/hadoop/etc/hadoop/

# source the environment and format the namenode
source /etc/environment
hdfs namenode -format

# export following env variables
export HADOOP_HOME="/usr/local/hadoop"
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_YARN_HOME=$HADOOP_HOME
export HADOOP_CLASSPATH=/usr/local/hadoop/etc/hadoop:/usr/local/hadoop/share/hadoop/common/lib/*:/usr/local/hadoop/share/hadoop/common/*:/usr/local/hadoop/share/hadoop/hdfs:/usr/local/hadoop/share/hadoop/hdfs/lib/*:/usr/local/hadoop/share/hadoop/hdfs/*:/usr/local/hadoop/share/hadoop/mapreduce/lib/*:/usr/local/hadoop/share/hadoop/mapreduce/*:/usr/local/hadoop/share/hadoop/yarn:/usr/local/hadoop/share/hadoop/yarn/lib/*:/usr/local/hadoop/share/hadoop/yarn/*

# setup and configuration of hdfs is done, now let's configure YARN (not explicitly necessary, but useful)
# on slave nodes, edit /usr/local/hadoop/etc/hadoop/yarn-site.xml:
<property>
<name>yarn.resourcemanager.hostname</name>
<value>hadoop-master</value>
</property>

# now start hdfs and yarn
start-dfs.sh
start-yarn.sh

# you can check the nodes via "jps"
# upload the txt-file for the workcount
hdfs dfs -put tolstoy-war-and-peace.txt hdfs://hadoop-master:9000/user/tolstoy-wap.txt

# check availability on every node via
hdfs dfs -ls -R hdfs://hadoop-master:9000/user/


------------------------ Commands to setup a flink cluster in session mode ------------------------

# now download flink from the website, we used version 1.12.1, and untar it
cd flink-1.12.1/

# edit the flink-conf.yaml, set the file system default scheme
fs.default-scheme: hdfs://hadoop-master:9000

# now, edit /conf/workers and conf/masters, add the hostnames
masters-file --> localhost:8081
workers-file --> localhost, hadoop-slave1, hadoop-slave2 (below each other, not separated by comma)

# now start the cluster, it automatically reads the master and worker file and adjusts the necessary config-files
./bin/start-cluster.sh


# run the adjusted WordCount.jar
./bin/flink run ../WordCount.jar --input hdfs://hadoop-master:9000/user/tolstoy-wap.txt --output hdfs://hadoop-master:9000/user/result.txt
