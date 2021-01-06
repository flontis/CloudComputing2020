#!/bin/bash

# generate an ssh key pair to authenticate your client with your GCP account
ssh-keygen -t rsa -f ~/.ssh/id_rsa -C "GCP_USERNAME"
# Restrict access to your private key so that only you can read it and nobody can write to it
chmod 400 ~/.ssh/id_rsa
# Upload the public key from your local machine into your GCP project metadata to authenticate
gcloud compute project-info add-metadata --metadata-from-file ssh-keys=/Users/"USERNAME"/.ssh/id_rsa


# create vpc network k8s-network
gcloud compute networks create k8s-network --subnet-mode=custom

# create subnet for cc-network1 with specific range in the region europe-west1 with a specific ip range in this region
gcloud compute networks subnets create k8s-subnet --network=k8s-network --range=10.132.0.0/22 --region=europe-west1

# Create a Firewall rule that allows incoming ICMP and TCP traffic. The rule must apply only for VMs with the tag “cloud-computing”.
gcloud compute firewall-rules create k8s-rule --allow tcp,icmp --network=k8s-network --target-tags k8s-nodes

# find the project name and family for the GCP image of Ubuntu Server 18.04
gcloud compute images list
# project name: ubuntu-os-cloud, family name: ubuntu-1804-lts

# find the right zone in which the instance should be launched --> this should be the same as in the AWS task (for comparison)
gcloud compute zones list
#i.e.: us-east1-b

# Launch an instance with the following parameters: 
# Machine type e2-standard-2
# add the tag k8s-nodes” to appy the firewall rule created before
# set the Image for Ubuntu Server 18.04 by specifying the project and family of the image
gcloud compute instances create k8s-node1 --image-family ubuntu-1804-lts --image-project ubuntu-os-cloud --zone europe-west1-b --machine-type e2-standard-2 --tags k8s-nodes --network-interface subnet=k8s-subnet
gcloud compute instances create k8s-node2 --image-family ubuntu-1804-lts --image-project ubuntu-os-cloud --zone europe-west1-b --machine-type e2-standard-2 --tags k8s-nodes --network-interface subnet=k8s-subnet
gcloud compute instances create k8s-node3 --image-family ubuntu-1804-lts --image-project ubuntu-os-cloud --zone europe-west1-b --machine-type e2-standard-2 --tags k8s-nodes --network-interface subnet=k8s-subnet

# find the disk name for the vm we created in the step before
gcloud compute disks list
# disk name: cc20

# resize the vm disk volume size to 50GB
gcloud compute disks resize k8s-node1 --size 50GB --zone europe-west1-b
gcloud compute disks resize k8s-node2 --size 50GB --zone europe-west1-b
gcloud compute disks resize k8s-node3 --size 50GB --zone europe-west1-b

# check passwordless ssh and passwordless sudo: gcloud-username@public-ip
ssh felix.j.schneider@35.241.215.50

# install pip
sudo apt-get update
sudo apt-get install -y python3-pip
pip3 --version

# check icmp traffic ping public-ip
ping 35.241.215.50

# install required packages
pip3 install -r ~/kubespray/requirements.txt

# Copy inventory/sample as inventory/mycluster:
cp -rfp inventory/sample inventory/mycluster

# Update Ansible inventory file with inventory builder:
declare -a IPS=($(gcloud compute instances list --filter="tags.items=k8s-nodes" --format="value(EXTERNAL_IP)"  | tr '\n' ' '))
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

# shutdown the vm after using it
gcloud compute instances stop cc20 --zone us-east1-b

# verify that all vms are stopped (STATUS TERMINATED)
gcloud compute instances list
