#!/bin/bash

ZONE=europe-west1-b

VM_SPECS="--image ubuntu-1804-bionic-v20210105 \
	--image-project ubuntu-os-cloud \
	--zone $ZONE \
	--machine-type e2-standard-2 \
	--tags cc-4"

INSTALL_COMMAND="sudo apt update && sudo apt install -y python3-pip"

KUBESPRAY_REPO="../kubespray"

#for i in {1..3}
#do
#	gcloud compute instances create vm$i $VM_SPECS
#done

#gcloud compute firewall-rules create allow-traffic-in \
#	--allow tcp,icmp,udp \
#	--direction IN \
#	--target-tags cc-4

#gcloud compute firewall-rules create allow-traffic-out \
#	--allow tcp,icmp,udp \
#	--direction OUT \
#	--target-tags cc-4

declare -a IPS

for i in {1..3}
do
	#gcloud compute ssh vm$i --zone $zone --command "$install_command"
	IPS+=("$(gcloud compute instances describe vm$i --zone $ZONE | grep -oP '(?<=networkIP: ).*')","$(gcloud compute instances describe vm$i --zone $ZONE | grep -oP '(?<=natIP: ).*')")
done

echo ""
for i in {1..3}
do
	echo "ip$i: ${IPS[$i - 1]}"
done
