#!/bin/bash

# generate an ssh key pair to authenticate your client with your AWS account
ssh-keygen -t rsa -f ~/.ssh/id_rsa


# import previously generated key pair, fileb is used to interpret the file as binary
aws ec2 import-key-pair --key-name "cc20" --public-key-material fileb://~/.ssh/id_rsa.pub

# create a security group with name and description
aws ec2 create-security-group --group-name cc-sg --description "SecurityGroup for CC20"

# allow all incoming TCP traffic and IMCP traffic from every ipv4 and ipv6 address, again by using the --group-name
# parameter -1 for port arguments denotes all ICMP codes
aws ec2 authorize-security-group-ingress --group-name cc-sg --ip-permissions IpProtocol=tcp,FromPort=0,ToPort=64738,IpRanges='[{CidrIp=0.0.0.0/0}]'
aws ec2 authorize-security-group-ingress --group-name cc-sg --ip-permissions IpProtocol=icmp,FromPort=-1,ToPort=-1,IpRanges='[{CidrIp=0.0.0.0/0}]'
aws ec2 authorize-security-group-ingress --group-name cc-sg --ip-permissions IpProtocol=icmpv6,FromPort=-1,ToPort=-1,Ipv6Ranges='[{CidrIpv6=::/0}]'

# run three VMs with at least 4GB of RAM and 2 CPUs running Ubuntu Server 18.04. (image-id found here: https://cloud-images.ubuntu.com/locator/ec2/)
aws ec2 run-instances --key-name "cc20" --instance-type "t2.large" --security-groups "cc-sg" --image-id "ami-0d0032af1da6905c7"
aws ec2 run-instances --key-name "cc20" --instance-type "t2.large" --security-groups "cc-sg" --image-id "ami-0d0032af1da6905c7"
aws ec2 run-instances --key-name "cc20" --instance-type "t2.large" --security-groups "cc-sg" --image-id "ami-0d0032af1da6905c7"

# check passwordless ssh and passwordless sudo (ssh ubuntu@public_dns)
ssh ubuntu@ec2-3-236-81-199.compute-1.amazonaws.com

# create larger volumes (50GB) since the default one is 8GB and we cant resize (permission error)
aws ec2 create-volume --availability-zone us-east-1f --size 50
aws ec2 create-volume --availability-zone us-east-1f --size 50
aws ec2 create-volume --availability-zone us-east-1f --size 50

# attach larger volumes to the nodes
aws ec2 attach-volume --device /dev/sdh --instance-id i-0ac91d808af2d503f --volume-id vol-041815091959223d8
aws ec2 attach-volume --device /dev/sdh --instance-id i-0c8f83d21a0ed550f --volume-id vol-00c2eea3f74a131c5
aws ec2 attach-volume --device /dev/sdh --instance-id i-0dece3f1ba177e6eb --volume-id vol-00dc07c87cb3572dc


# stop the running instance by passing an instance-id to the command. They can be looked up using `aws ec2 describe-instances`
aws ec2 stop-instances --instance-ids "INSTANCE_ID"

# verify that all vms are stopped (State: stopped)
aws ec2 describe-instances


