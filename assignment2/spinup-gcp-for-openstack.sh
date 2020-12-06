#!/bin/bash

# to create and import key pair, see assignment no. 1.
# We re-use the keys and start directly with
# creating the VPC networks

# create custom network cc-network1
gcloud compute networks create cc-network1 --subnet-mode=custom

# create custom network cc-network2
gcloud compute networks create cc-network2 --subnet-mode=custom

# create subnet for cc-network1 with specific range in the region europe-west1 with a specific secondary range
gcloud compute networks subnets create cc-subnet1 --network=cc-network1 --range=10.132.0.0/22 --region=europe-west1 --secondary-range secrange=10.132.4.0/22

# create similarly the subnet for cc-network2, without secondary range
gcloud compute networks subnets create cc-subnet2 --network=cc-network2 --range=10.132.8.0/21 --region=europe-west1

# create controller instance with specific machine-type and tag. Connect first NIC to cc-subnetwork1 with alias-ip-range, and second NIC to cc-subnetwork2
gcloud compute instances create controller --image=nested-vm-image --zone europe-west1-b --machine-type n2-standard-2 --tags cc --network-interface subnet=cc-subnet1,aliases=secrange:10.132.4.0/22 --network-interface subnet=cc-subnet2

# create similarly the compute instances, but without alias-ip
gcloud compute instances create compute2 --image=nested-vm-image --zone europe-west1-b --machine-type n2-standard-2 --tags cc --network-interface subnet=cc-subnet1 --network-interface subnet=cc-subnet2
gcloud compute instances create compute1 --image=nested-vm-image --zone europe-west1-b --machine-type n2-standard-2 --tags cc --network-interface subnet=cc-subnet1 --network-interface subnet=cc-subnet2

# create firewall rule for cc-network1, allowing all icmp, tcp and udp traffic from all sources inside subnet1 and subnet2 to all destination instances tagged with cc.
gcloud compute firewall-rules create rule1 --allow=tcp,icmp,udp --network=cc-network1 --target-tags=cc --source-ranges=10.132.0.0/22,10.132.8.0/21
# same for cc-network2
gcloud compute firewall-rules create rule12 --allow=tcp,icmp,udp --network=cc-network2 --target-tags=cc --source-ranges=10.132.0.0/22,10.132.8.0/21

# allow all incoming tcp and icmp traffic from all sources to destination instances tagged with cc
gcloud compute firewall-rules create number8 --allow=tcp,icmp --network=cc-network1 --source-ranges=0.0.0.0/0 --target-tags cc
