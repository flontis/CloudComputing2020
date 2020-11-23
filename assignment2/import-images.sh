#!/bin/bash
#
# This scripts creates default flavors and uploads Ubuntu
# and Cirros Images
#
CIRROS_URL=http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
UBUNTU_1604_URL=https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img

# Test if OS credentials are sourced           
if [[ "${OS_USERNAME}" == "" ]]; then          
    echo "No Keystone credentials specified"   
    exit               
fi                     

# add default flavors, if they don't already exist
if ! openstack flavor list | grep -q m1.tiny; then
    openstack flavor create --id 1 --ram 1024 --disk 1 --vcpus 1 m1.small
fi

if ! openstack flavor list | grep -q m1.medium; then
    openstack flavor create --id 2 --ram 2048 --disk 20 --vcpus 2 m1.medium
fi

# check if cirros images already exists
if ! openstack image list | grep -q cirros; then
    echo "Downloading Cirros Image"
    curl -L -o ./cirros.img $CIRROS_URL
    echo "Creating Glance image"
    openstack image create --disk-format qcow2 --container-format bare --public \
    --file ./cirros.img cirros
fi

if ! openstack image list | grep -q ubuntu-16.04; then
    echo "Downloading Ubuntu 16.04 Image"
    curl -L -o ./ubuntu-16.04.img $UBUNTU_1604_URL
    echo "Creating Ubuntu image"
    openstack image create --disk-format qcow2 --container-format bare --public \
    --file ./ubuntu-16.04.img ubuntu-16.04
fi

echo ""
echo "Deleting local images"
echo ""
rm ./cirros.img
rm ./ubuntu-16.04.img

