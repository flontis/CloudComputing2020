####################
#   Google Cloud   #
####################
# generate an ssh key pair to authenticate your client with your GCP account
ssh-keygen -t rsa -f flink-cluster-keypair -C "fschnei4"
# Restrict access to your private key so that only you can read it and nobody can write to it
chmod 777 flink-cluster-keypair
# Upload the public key from your local machine into your GCP project metadata to authenticate
gcloud compute project-info add-metadata --metadata-from-file ssh-keys=flink-cluster-keypair.pub

# create custom network flink-cluster-network
gcloud compute networks create flink-cluster-network \
    --subnet-mode=custom

# create subnet for cc-network1 with specific range in the region europe-west1
gcloud compute networks subnets create flink-cluster-network-subnet \
    --network=flink-cluster-network \
    --range=10.132.8.0/21 \
    --region=europe-west1 

# create the Hadoop Master (NameNode)
gcloud compute instances create hadoop-namenode \
    --image-family ubuntu-1804-lts \
    --image-project ubuntu-os-cloud \
    --zone europe-west1-b \
    --machine-type n2-standard-2 \
    --tags flink-cluster \
    --network-interface subnet=flink-cluster-network-subnet

# create the Hadoop Master (ResourceManager)
gcloud compute instances create hadoop-resourcemanager \
    --image-family ubuntu-1804-lts \
    --image-project ubuntu-os-cloud \
    --zone europe-west1-b \
    --machine-type n2-standard-2 \
    --tags flink-cluster \
    --network-interface subnet=flink-cluster-network-subnet 

# create the Hadoop Worker (acts as both DataNode and NodeManager)
gcloud compute instances create hadoop-worker \
    --image-family ubuntu-1804-lts \
    --image-project ubuntu-os-cloud \
    --zone europe-west1-b \
    --machine-type n2-standard-2 \
    --tags flink-cluster \
    --network-interface subnet=flink-cluster-network-subnet 

# create a firewall rule for the network allowing all icmp, tcp and udp traffic to all destination instances tagged with flink-cluster.
# (not recommended in production)
gcloud compute firewall-rules create flink-cluster-network-firewall-rule \
    --allow=tcp,icmp,udp \
    --network=flink-cluster-network \
    --target-tags flink-cluster \
    --source-ranges=0.0.0.0/0 

# resize the disk of each node to 50GB of storage
gcloud compute disks resize hadoop-namenode \
    --size 50GB \
    --zone europe-west1-b 

gcloud compute disks resize hadoop-resourcemanager \
    --size 50GB \
    --zone europe-west1-b 

gcloud compute disks resize hadoop-worker \
    --size 50GB \
    --zone europe-west1-b 

# test availability of all nodes using ansible
ansible -i ansible/hosts.yaml all -m ping

ssh -i flink-cluster-keypair fschnei4@35.241.180.6

####################
#   Hadoop Setup   #
####################

# ansible playbook for installing java 8, ssh, pdsh, hadoop on the nodes
mkdir /etc/ansible/hosts