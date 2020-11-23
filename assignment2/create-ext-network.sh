#!/bin/bash
# 
# This script creates an external OpenStack Network
#
# An OpenRC File has to be sourced


EXT_NET_CIDR="10.122.0.0/24"
EXT_NET_GATEWAY="10.122.0.1"

ADMIN_NET_CIDR="10.0.0.0/24"
ADMIN_NET_GATEWAY="10.0.0.1"
ADMIN_NET_NAMESERVER="8.8.8.8"


# Test if OS credentials are sourced
if [[ "${OS_USERNAME}" == "" ]]; then
    echo "No Keystone credentials specified"
    exit
fi


echo ""
echo "Creating external network"
echo ""
openstack network create --external --provider-physical-network \
        physnet1 --provider-network-type flat external

openstack subnet create --no-dhcp \
        --network external \
        --subnet-range ${EXT_NET_CIDR} --gateway ${EXT_NET_GATEWAY} external-sub

echo ""
echo " Creating admin network"
echo ""
openstack network create --provider-network-type vxlan admin-net
openstack subnet create --subnet-range $ADMIN_NET_CIDR --network admin-net\
    --gateway $ADMIN_NET_GATEWAY --dns-nameserver $ADMIN_NET_NAMESERVER admin-sub



echo ""
echo "Creating admin router"
echo ""
openstack router create admin-router
openstack router add subnet admin-router admin-sub
openstack router set --external-gateway external admin-router
