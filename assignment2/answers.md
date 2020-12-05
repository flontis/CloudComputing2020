# Question 1: What did we do in this assignment?
First, we set up a VPC-network with subnets and firewall rules on the Google Cloud Platform (GCP). In this network, we created virtual resources for the means of computing and controlling other resources.After verifying, that our resources are connected and running, we set up and installed OpenStack using the service "kolla-ansible", which deploys all necessary services of OpenStack in docker containers.Once OpenStack was running on the GCP, we configured the network, again with subnets and firewall rules, using the OpenStack CLI. Second, we started a VM instance in this network on OpenStack.

# Question 2: How many virtual networks are involved to establish the connectivity?
## GCP
2 virtual networks (cc-network1, cc-network2)
## OpenStack
2 virtual networks (1 external network, 1 admin network)

**In total, 4 virtual networks are involved to establish the connectivity**

# Question 3: Initially, the OpenStack VM was not reachable from the gc controller VM. Why?
For reference:
- https://ask.openstack.org/en/question/31238/can-not-access-ping-to-vm-from-controller-or-any-host/

- https://ask.openstack.org/en/question/97565/cant-ping-instance-from-controller-or-any-other-external-hosts-but-can-ping-from-compute-node/

- Packets that were going out from the gc controller were not forwarded to the OpenStack VM.

# Question 4: Look into the `iptables-magic.sh` script. What is happening there? Describe every command with 1-2 sentences
For reference: 
* https://linux.die.net/man/8/ip
* https://linux.die.net/man/8/iptables

```bash
#/bin/bash

# define a subnet for and a gateway for the floating IP.
floating_subnet="10.122.0.0/24"
floating_gateway="10.122.0.1"

# The following 3 bash commands execute commands on the docker container openvswitch_vswitchd.
# This line adds the previously defined floating gateway of the floating IP address (a) to the container's network adapter (dev) `br-ex`
docker exec openvswitch_vswitchd ip a add $floating_gateway dev br-ex

# This line configures the network adapter `br-ex`. It actives the network adapter.
docker exec openvswitch_vswitchd ip link set br-ex up

# This line also configures the network adapter `br-ex`. 
# It sets the maximum packet size that can be transmitted over the network adapter to 1400
docker exec openvswitch_vswitchd ip link set dev br-ex mtu 1400  # Ensure correct ssh connection

# This lines adds a new route for the floating subnet. the floating subnet. 
# It defines, that the nexthop router should be the floating gateway. 
# This new route applies to the `br-ex` network adapter
ip r a "$floating_subnet" via $floating_gateway dev br-ex

# This command appends a new chain rule to the end of the POSTROUTING chain in the nat table of the controller VM.
# The chain rule defines to masquerade packets that are sent out from the network adapter `ens4`
iptables -t nat -A POSTROUTING -o ens4 -j MASQUERADE

# This command appends a new chain rule to the end of the FORWARD chain of the controller VM.
# The chain rule defines packet forwarding between the network adapter `ens4` of the controller VM and the network adapter of the docker container `br-ex`.
# Packets that are coming in on `ens4` should go out on `br-ex`.
iptables -A FORWARD -i ens4 -o br-ex -j ACCEPT

# This command also appends a new chain rule to the end of the FORWARD chain of the controller VM.
# The chain rule defines packet forwarding between the network adapter `ens4` of the controller VM and the network adapter of the docker container `br-ex`.
# Packets that are coming in on `br-ex` should go out on `ens4`.
iptables -A FORWARD -i br-ex -o ens4 -j ACCEPT
```
