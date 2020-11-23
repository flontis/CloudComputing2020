#!/usr/bin/env python3
# Before running this script, install required Pythons package manager:
#   sudo apt update && sudo apt install -y python-pip
# Then install required packages:
#   pip install numpy matplotlib

import matplotlib.pyplot as plt
import matplotlib.dates as md
import numpy as np
import datetime as dt


def make_image(data_name, time_openstack, data_openstack):
    ax = plt.gca()
    xfmt = md.DateFormatter('%d.%m.%Y %H:%M:%S')
    ax.xaxis.set_major_formatter(xfmt)
    plt.xticks(rotation = 25)

    plt.plot(time_openstack, data_openstack, label='OPENSTACK')
    
    image_name = data_name + '-plot' + '.png'
    print("Plotting " + image_name)
    plt.xlabel('time')
    plt.ylabel(data_name)
    plt.legend()
    plt.savefig(image_name, bbox_inches='tight')
    plt.clf()

def convert_time(raw_time):
    return md.date2num([ dt.datetime.fromtimestamp(ts) for ts in raw_time ])

print("Loading data")
data_time_openstack, data_cpu_openstack, data_mem_openstack, data_diskRand_openstack, data_diskSeq_openstack = np.loadtxt('results-openstack.csv', delimiter=',', unpack=True, skiprows=1)
parsed_time_openstack = convert_time(data_time_openstack)

make_image('cpu', parsed_time_openstack, data_cpu_openstack)
make_image('mem', parsed_time_openstack, data_mem_openstack)
make_image('diskRand', parsed_time_openstack, data_diskRand_openstack)
make_image('diskSeq', parsed_time_openstack, data_diskSeq_openstack)
