#!/bin/bash

# create a security group with name "open-all"
openstack security group create open-all

openstack security group rule create --protocol icmp --ingress open-all
openstack security group rule create --protocol tcp --ingress open-all --dst-port 1:65535
openstack security group rule create --protocol udp --ingress open-all --dst-port 1:65535
openstack security group rule create --protocol icmp --egress open-all
openstack security group rule create --protocol tcp --egress open-all --dst-port 1:65535
openstack security group rule create --protocol udp --egress open-all --dst-port 1:65535

# change to the .ssh directory
cd ~/.ssh/
# if you enter the command, you will be asked to name the file. We named it "second", so the public key
# will be stored in second.pub, the private key in second
ssh-keygen ---> file: ~/.ssh/second

# create a keypair for openstack based on the public key we created in the previous command
openstack keypair create --public-key ~/.ssh/second.pub second

# send the private key via ssh to the gc control instance (replace the IP with the public IP of the controller
# and adjust the path to the path where you private key is stored)
scp /home/florian/.ssh/second  flo372@104.199.22.225:/home/flo372/.ssh

# access your cntroller vm
ssh -i ~/.ssh/gcp flo372@104.199.22.225
cd ~/.ssh
# adjust the permissions of the private key
sudo chmod 400 second

# collect the parameters for instance creation

# retrieve the available networks
openstack network list

# retrieve the security groups
openstack security group list

# retrieve the available flavors
openstack flavor list

# retriebe the available images
openstack image list

# create an instance with the desired flavor number, the image-ID, a key-name (the one being created in the first steps), the security-group and a NIC connected to the admin-net 
nova boot --flavor 2 --image 86f85454-4e74-4b1e-ae18-60bacee5abc9 --key-name second --security-groups open-all --nic net-name=admin-net vm