#!/bin/bash
# This script benchmarks CPU, memory and random/sequential disk access.
# Some debug output is written to stderr, and the final benchmark result is output on stdout as a single CSV-formatted line.

# Execute the sysbench tests for the given number of seconds
runtime=60

# Record the Unix timestamp before starting the benchmarks.
time=$(date +%s)

# Run the sysbench CPU test and extract the "events per second" line.
1>&2 echo "Running CPU test..."
r="$(sysbench --max-time=$runtime --max-requests=10000000 --test=cpu run)"
c=$(echo "$r" | grep 'total number of events' | awk '/ [0-9.]*$/ { print $NF }')
t=$(echo "$r" | grep 'total time taken by event execution' | awk '/ [0-9.]*$/ { print $NF }')
cpu=$(echo "$c / $t" | bc)

# Run the sysbench memory test and extract the "transferred" line. Set large total memory size so the benchmark does not end prematurely.
1>&2 echo "Running memory test..."
mem=$(sysbench --memory-block-size=4K --max-time=$runtime --memory-total-size=100T --test=memory run | grep -oP 'transferred \(\K[0-9\.]*')

# Prepare one file (1GB) for the disk benchmarks
1>&2 sysbench --file-total-size=1G --file-num=1 --test=fileio prepare

# Run the sysbench sequential disk benchmark on the prepared file. Use the direct disk access flag. Extract the number of read MiB.
1>&2 echo "Running fileio sequential read test..."
diskSeq=$(sysbench --max-time=$runtime --file-test-mode=seqrd --file-total-size=1G --file-num=1 --file-extra-flags=direct --test=fileio run | grep -oP 'transferred .* \(\K[0-9\.]*')

# Run the sysbench random access disk benchmark on the prepared file. Use the direct disk access flag. Extract the number of read MiB.
1>&2 echo "Running fileio random read test..."
diskRand=$(sysbench --max-time=$runtime --file-test-mode=rndrd --file-total-size=1G --file-num=1 --file-extra-flags=direct --test=fileio run | grep -oP 'transferred .* \(\K[0-9\.]*')

# Output the benchmark results as one CSV line
echo "$time,$cpu,$mem,$diskRand,$diskSeq"
