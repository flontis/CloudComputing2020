#!/bin/bash

# prepare random access read disk sysbench, 1gb total file size, mode --> random read, extra-flags --> direct access, no caching, file-num--> use only one file instead of default
prepare=$(sysbench fileio --file-total-size=1GB --file-test-mode=rndrd --file-extra-flags=direct --file-num=1 prepare)

# prepare sequential disk read acces benchmarking, 1gb total file size, sequential read mode, direct access, use only one file
prepareseqrd=$(sysbench fileio --file-total-size=1GB --file-test-mode=seqrd --file-extra-flags=direct --file-num=1 prepare)

# get epoch timestamp in seconds
timestamp=$(date +%s)

# sysbench for cpu benchmarking, grep the line with events per second
result=$(sysbench  cpu --max-time=60 run | grep "events per second")

# cut the string, first split on :, take the second part, then split again on whitespace, such that you only retrieve the number
cputime=$(echo $result| cut -d":"   -f2 | cut -d" " -f2)

# sysbench the memory, 4kb block size, 100tb total, for 60 seconds. grep line with transferred, since here is the result 
resultmem=$(sysbench memory --memory-oper=read --memory-block-size=4kb --memory-total-size=100TB --max-time=60 run | grep "transferred")

# again string manipulation to get only the number
rm=$( echo $resultmem | cut -d"(" -f2)
rm2=$(echo ${rm%?} | cut -d" " -f1)

# run the rnd read test for max 60 seconds, grep result
rndr=$(sysbench fileio --file-total-size=1GB --file-test-mode=rndrd --file-extra-flags=direct --file-num=1 --max-time=60 run | grep "read, MiB/s:")
# string manipulation
rn=$(echo $rndr | cut -d" " -f3)

# run the benchmarking and grep result line
seqr=$(sysbench fileio --file-total-size=1GB --file-test-mode=seqrd --file-extra-flags=direct --file-num=1 --max-time=60 run | grep "read, MiB/s:")
# string manipulation
seqrn=$(echo $seqr | cut -d" " -f3)

# concatenate the strings
final="${timestamp},${cputime},${rm2},${rn},${seqrn}"
# print the output
echo $final