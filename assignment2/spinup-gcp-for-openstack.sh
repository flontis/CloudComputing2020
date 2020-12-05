#!/bin/bash

# to create and import key pair, see assignment no. 1.
# We re-use the keys and start directly with
# creating the VPC networks

# create a VPC network with subnet-mode set to custom to be able to add custom defined subnets.
gcloud compute networks create cc-network1 \
    --subnet-mode=custom

# create a second VPC network with the same settings.
gcloud compute networks create cc-network2 \
    --subnet-mode=custom

# create a subnet called cc-subnet1 for the network cc-network1 with the IP range from the region eu-west1 (10.132.0.0.0/20).
# We divide this IP range into two subnets. 
# The first subnet is again divided into a primary, and a secondary IP range. 
# The latter will be used for IP-aliasing
gcloud compute networks subnets create cc-subnet1 \
     --network=cc-network1 \
     --range=10.132.0.0/22 \
     --region=europe-west1 \
     --secondary-range secrange=10.132.4.0/22

# create a subnet called cc-subnet1 for the network cc-network1 with the IP range from the second half of the region eu-west1 (10.132.8.0/21).
gcloud compute networks subnets create cc-subnet2 \
    --network=cc-network2 \
    --range=10.132.8.0/21 \
    --region=europe-west1

# create a disk as a storage device for the VMs.
gcloud compute disks create disk1 \
    --size=100GB \
    --image-family=ubuntu-1804-lts \
    --image-project=ubuntu-os-cloud \
    --zone=europe-west1-b

# create an Image of Ubuntu 18.04. with a license for nested virtualization as a base image for the VMs.
gcloud compute images create nested-vm-image \
    --source-disk=disk1 \
    --source-disk-zone=europe-west1-b \
    --licenses "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"

# create a VM instance based on the image created before.
# define two network interfaces, one for each subnet, such that this instance can communicate with other instances in both subnets.
# The first network instance also has the alaias IPs assigned, such that the containers that will run on this machine can get an IP from this range.
gcloud compute instances create controller \
    --image=nested-vm-image \
    --zone europe-west1-b \
    --machine-type n2-standard-2 \
    --tags cc \
    --network-interface subnet=cc-subnet1,aliases=range1:10.132.4.0/22 \
    --network-interface subnet=cc-subnet2

# creates another VM instance based on the same image as the `controller` instance.
# This instance also has two network interfaces, one for each subnet of the respective network to be able to communicate with other instances in both networks.
gcloud compute instances create compute1 \
    --image=ubuntu-nested-vm-image \
    --zone europe-west1-b \
    --machine-type n2-standard-2 \
    --tags cc \
    --network-interface subnet=cc-subnet1 \
    --network-interface subnet=cc-subnet2 

# clone of compute instance 1 to have more instances to run computations on.
gcloud compute instances create compute2 \
    --image=ubuntu-nested-vm-image \
    --zone europe-west1-b \
    --machine-type n2-standard-2 \
    --tags cc \
    --network-interface subnet=cc-subnet1 \
    --network-interface subnet=cc-subnet2 

# Firewall rule to allow incoming traffic of the given network protocols to the VMs that match the tag and are in the specified range of the network cc-network1.
gcloud compute firewall-rules create rule1 \
    --allow=tcp,icmp,udp \
    --network=cc-network1 \
    --source-ranges=10.132.0.0/22,10.132.4.0/22 \
    --source-tags=cc \
    --target-tags=cc

# Similar rule as above but for the network `cc-network2` and the respective IP ranges of the respective subnet `cc-subnet2`.
gcloud compute firewall-rules create rule2 \
    --allow=tcp,icmp,udp \
    --network=cc-network2 \
    --source-ranges=10.132.8.0/21 \
    --source-tags=cc \
    --target-tags=cc

# Firewall rule that is necessary to permit OpenStack service traffic from all external IPs to the VMs with a matching tag.
to allow all external IPs to c
gcloud compute firewall-rules create number8 \
    --allow=tcp,icmp \
    --network=cc-network1 \
    --source-ranges=0.0.0.0/0 \
    --target-tags cc
