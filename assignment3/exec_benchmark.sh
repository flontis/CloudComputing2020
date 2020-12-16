#!/bin/bash

echo "time,cpu,mem,diskRand,diskSeq,fork,uplink" > native-results.csv
echo "time,cpu,mem,diskRand,diskSeq,fork,uplink" > docker-results.csv
echo "time,cpu,mem,diskRand,diskSeq,fork,uplink" > kvm-results.csv
echo "time,cpu,mem,diskRand,diskSeq,fork,uplink" > qemu-results.csv

for run in {1..10}
do
	./benchmark.sh >> native-results.csv
done

sudo docker build -t benchmark_container .

for run in {1..10}
do
	sudo docker container run benchmark_container >> docker-results.csv
done

# for KVM
sshpass -p 'DeepMind' scp -P 2222 forkbench.c florian@localhost:/home/florian/
sshpass -p 'DeepMind' scp -P 2222 benchmark.sh florian@localhost:/home/florian/
sshpass -p 'DeepMind' ssh -p 2222 florian@localhost

for run in {1..10}
do
	sshpass -p 'DeepMind' ssh florian@localhost -p 2222 './benchmark.sh' >> kvm-results.csv
done


# for Qemu, adjust the port when invoking qemu
sshpass -p 'DeepMind' scp -P 2223 forkbench.c florian@localhost:/home/florian/
sshpass -p 'DeepMind' scp -P 2223 benchmark.sh florian@localhost:/home/florian/
sshpass -p 'DeepMind' ssh -p 2223 florian@localhost

for run in {1..10}
do
	sshpass -p 'DeepMind' ssh florian@localhost -p 2223 './benchmark.sh' >> qemu-results.csv
done
