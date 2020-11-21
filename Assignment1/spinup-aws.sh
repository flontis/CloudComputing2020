#!/bin/bash

# generate an ssh key pair to authenticate your client with your AWS account
ssh-keygen -t rsa -f ~/.ssh/id_rsa -C "USERNAME"

# check if vpc is available
aws ec2 describe-vpcs

# import previously generated key pair, fileb to interpret file as binary
aws ec2 import-key-pair --key-name "cc20" --public-key-material fileb://~/.ssh/id_rsa.pub

# create security group for VPC. Get the VPC-ID via "aws ec2 describe-vpcs"
aws ec2 create-security-group --group-name CC20SecGroup --description "SecurityGroup for CC20"

# gain access for all incoming ssh traffic (bad idea). get group-id of security group via "aws ec2 describe-security-groups"
aws ec2 authorize-security-group-ingress --group-name CC20SecGroup --protocol tcp --port 22 --cidr 0.0.0.0/0

# allow all incoming IMCP traffic from every ipv4 and ipv6 address
aws ec2 authorize-security-group-ingress --group-name CC20SecGroup --ip-permissions IpProtocol=icmpv6,FromPort=-1,ToPort=-1,Ipv6Ranges='[{CidrIpv6=::/0}]'
aws ec2 authorize-security-group-ingress --group-name CC20SecGroup --ip-permissions IpProtocol=icmp,FromPort=-1,ToPort=-1,IpRanges='[{CidrIp=0.0.0.0/0}]'

# run the instance with corresponding key, type, sg and image
aws ec2 run-instances --key-name "cc20" --instance-type "t2.large" --security-groups "CC20SecGroup" --image-id "ami-00ddb0e5626798373"

# resize the volume, get volume-id via "aws ec2 describe-volumes"
aws ec2 modify-volume --size 100 --volume-id "VOL-ID" 

# stop the running instance by passing an instance-id to the command. They can be looked up using `aws ec2 describe-instances`
aws ec2 stop-instances --instance-ids "INSTANCE_ID"
