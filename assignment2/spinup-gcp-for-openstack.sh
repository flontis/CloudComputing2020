#!/bin/bash

# to create and import key pair, see assignment no. 1.
# We re-use the keys and start directly with
# creating the VPC networks

# create VPC network called NETWORK_NAME with subnet-mode set to custom
gcloud compute networks create $NETWORK_NAME --subnet-mode=custom

# create a subnet called SUBNET_NAME for the network NETWORK_NAME with IP range IP_RANGE in CIDR format, e.g. 192.168.63.0/24, for a specific region
# to include secondary range, append parameter --secondary-range=$IP_RANGE_SEC, e.g. --secondary-range range1=192.168.64.0/24
gcloud compute networks subnets create $SUBNET_NAME --network=$NETWORK_NAME --range=$IP_RANGE --region=europe-west1

# 
gcloud compute disks create disk1 --size=100GB --image-family=ubuntu-1804-lts --image-project=ubuntu-os-cloud --zone=europe-west1-b

# 
gcloud compute images create nested-vm-image --source-disk=disk1 --source-disk-zone=europe-west1-b --licenses "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"

# controller
gcloud compute instances create controller --image=nested-vm-image --zone europe-west1-b --machine-type n2-standard-2 --tags cc --network-interface subnet=cc-subnet1,aliases=range1:192.168.64.0/24 --network-interface subnet=cc-subnet2

# compute-X
gcloud compute instances create compute2 --image=nested-vm-image --zone europe-west1-b --machine-type n2-standard-2 --tags cc --network-interface subnet=cc-subnet1 --network-interface subnet=cc-subnet2

# ????
gcloud compute firewall-rules create rule1 --allow=tcp,icmp,udp --network=cc-network1 --source-tags=cc --target-tags=cc

# ???
gcloud compute firewall-rules create number8 --allow=tcp,icmp --network=cc-network1 --target-tags=cc