#!/bin/bash

ZONE=europe-west1-b

declare -a IPS

for i in {1..3}
do
	gcloud compute instances start vm$i --zone $ZONE
	IPS+=("$(gcloud compute instances describe vm$i --zone $ZONE | grep -oP '(?<=networkIP: ).*')","$(gcloud compute instances describe vm$i --zone $ZONE | grep -oP '(?<=natIP: ).*')")	
done

echo ""

for i in {1..3}
do
	echo "ips$i: ${IPS[$i - 1]}"
done
