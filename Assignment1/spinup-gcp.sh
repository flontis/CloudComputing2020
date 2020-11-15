# generate ssh key pair to authenticate 
ssh-keygen -t rsa -f ~/.ssh/id_rsa -C [GCP_USERNAME]
# Restrict access to your private key so that only you can read it and nobody can write to it
chmod 400 ~/.ssh/id_rsa
# Upload the public key into your project metadata to authenticate
gcloud compute project-info add-metadata --metadata-from-file ssh-keys=/Users/[USERNAME]/.ssh/id_rsa
# Create a Firewall rule that allows incoming ICMP and SSH traffic. The rule must apply only for VMs with the tag “cloud-computing”.
gcloud compute firewall-rules create traffic-rule --allow tcp:22,icmp --target-tags cloud-computing
# find the name of the project and family for the GCP image of Ubuntu Server 18.04
gcloud compute images list
# project name: ubuntu-os-cloud family name: ubuntu-1804-lts
# find the right zone in which the instance should be launched
gcloud compute zones list
#i.e.: us-east1-b
# Launch an instance with the following parameters: 
# Machine type e2-standard-2
# add the tag “cloud-computing” to appy the firewall rule created before
# set the Image for Ubuntu Server 18.04 by specifying the project and family of the image
gcloud compute instances create cc20 --image-family ubuntu-1804-lts --image-project ubuntu-os-cloud --zone us-east1-b --machine-type e2-standard-2 --tags cloud-computing
# find the disk name for the vm we created in the step before
gcloud compute disks list
# disk name: cc20
# resize the vm disk volume size to 100GB
gcloud compute disks resize cc20 --size 100GB --zone us-east1-b
# shutdown the vm after using it
gcloud compute instances stop cc20 --zone us-east1-b
# verify that all vms are stopped (STATUS TERMINATED)
gcloud compute instances list
