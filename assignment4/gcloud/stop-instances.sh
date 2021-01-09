#!/bin/bash

zone=europe-west1-b

for i in {1..3}
do
	gcloud compute instances stop vm$i --zone $zone
done
