#!/usr/bin/env python3
# Before running this script, install required Pythons package manager:
#   sudo apt update && sudo apt install -y python-pip
# Then install required packages:
#   pip install numpy matplotlib

import matplotlib.pyplot as plt
import matplotlib.dates as md
import numpy as np
import datetime as dt


def make_image(data_name, time_aws, data_aws, time_gcp, data_gcp):
    ax = plt.gca()
    xfmt = md.DateFormatter('%d.%m.%Y %H:%M:%S')
    ax.xaxis.set_major_formatter(xfmt)
    plt.xticks(rotation = 25)

    plt.plot(time_aws, data_aws, label='AWS')
    plt.plot(time_gcp, data_gcp, label='GCP')
    
    image_name = data_name + '-plot.png'
    print("Plotting " + image_name)
    plt.xlabel('time')
    plt.ylabel(data_name)
    plt.legend()
    plt.savefig(image_name, bbox_inches='tight')
    plt.clf()

def convert_time(raw_time):
    return md.date2num([ dt.datetime.fromtimestamp(ts) for ts in raw_time ])

print("Loading data")
data_time_aws, data_cpu_aws, data_mem_aws, data_diskRand_aws, data_diskSeq_aws = np.loadtxt('aws_results.csv', delimiter=',', unpack=True, skiprows=1)
parsed_time_aws = convert_time(data_time_aws)
data_time_gcp, data_cpu_gcp, data_mem_gcp, data_diskRand_gcp, data_diskSeq_gcp = np.loadtxt('gcp_results.csv', delimiter=',', unpack=True, skiprows=1)
parsed_time_gcp = convert_time(data_time_gcp)

make_image('cpu', parsed_time_aws, data_cpu_aws, parsed_time_gcp, data_cpu_gcp)
make_image('mem', parsed_time_aws, data_mem_aws, parsed_time_gcp, data_mem_gcp)
make_image('diskRand', parsed_time_aws, data_diskRand_aws, parsed_time_gcp, data_diskRand_gcp)
make_image('diskSeq', parsed_time_aws, data_diskSeq_aws, parsed_time_gcp, data_diskSeq_gcp)
