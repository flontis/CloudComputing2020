FROM ubuntu:18.04

WORKDIR /home/florian/projects/cloudcomputing2020/CloudComputing2020/assignment3
RUN apt-get update && apt-get install -y bc && apt-get install -y make && apt-get install -y sysbench && apt-get install -y gcc && apt-get install -y iperf3 && apt-get install -y gawk

COPY benchmark.sh .
COPY forkbench.c .


CMD [ "chmod +x benchmark.sh"]
CMD [ "./benchmark.sh"]
