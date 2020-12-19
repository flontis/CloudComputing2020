# Question 1
## Look at your benchmark results. Are they consistent with your expectations, regarding the different virtualization platforms? Explain your answer. 

Our expectations are based on the IBM Research Report (An Updated Performance Comparison of Virtual Machines and Linux Containers, 2014).

### CPU, MEM

For CPU and RAM performance, we were not expecting performance differences between the four virtualization platforms (Native, Docker, KVM, Qemu). In terms of CPU performance, our plot for "forksum" and prime number calculations confirm our expectations, except for the very bad performance of Qemu. Also in terms of RAM performance, our respective plot confirms our expectation.

### Network 

For Network transmission performance, we were expecting our Host machine (Native) to perform best, followed by KVM and then the Docker container. On the one hand, the performance of Native was confirmed by our plot of "iperf uplink". On the other hand, both virtual machine platforms (Qemu, KVM) were showing very bad performance. On top, our docker container was outperforming KVM, which we were not expecting. And again, our Qemu VM was performing very badly.

### Random, Sequential Disk IO

For sequential disk IO, we were expecting a similarly high throughput for reading and write operations of Native, Docker, and KVM. This expectation can be proven to be true for Native ad Docker. Again, similar to network performance, both virtual machine platforms were showing very bad performance, even though KVM was performing better than Qemu.

For random disk IO, we were expecting both, KVM and Qemu to score a lower value for Input/output operations per second (IOPS). We expected an equally high-scoring value of IOPS for Native and Docker. This time, our plot could confirm our expectations.

## What are the main reasons for the differences between the platforms? Answer these questions for all benchmarks:

### a. CPU
VMs and containers introduce low CPU access overhead, which is why the performance was equally high for all platforms. Qemu performed so badly because of the Tiny Code Generator (TCG), who is the only "optimizer" for CPU access in default qemu emulation. Using the TCG, the instructions have to be translated to tcg ops, and afterwards to instructions for the host architecture. If no previous specified JIT (just-in-time) compiler code can be found for instructions, TCG uses the TCG Interpreter (TCI), which is even slower. This results in very bad performance compared to the hardware-supported CPU access of KVM or dockers direct access to the CPU, since only the application is isolated.
### b. Memory
Also, VMs and containers introduce low memory access overhead, which is why the performance of operations in memory is constantly high. Here again, the memory for Qemu is only emulated, resulting in Shadow Page Tables being generated in order to virtualize the access of the memory, which increases memory access overhead compared to direct memory access very strong.
### c. Random disk access
The virtual IO device of both virtual platforms causes a higher latency and mitigates IOPs.
### d Sequential disk access
The throughput for sequential disk access is about the same on all virtualization platforms. Hardware-assisted virtualization as in KVM is faster than in e.g. full virtualization due to the guest running native IO drivers and "owning" the physical device.
### e. Fork
Similar to CPU-benchmarking, VMs and containers introduce low CPU access overhead, which does not mitigate the performance compared to an operation on the Host. Here again, Qemu performs very bad because the privileged instructions to create new processes have to be trapped and translated, resulting in a heavy performance decrease.
### f. iperf uplink
In general, there is a low CPU overhead for handling network traffic. However, the latency for the different platforms varies. Docker experiences a latency increase due to NAT. KVM experiences the same due to the virtual network device introducing latency. For Qemu, an E1000 PCI was emulated, resulting in, in comparison to the other systems, very slow network performance. The emulated E1000 PCI is in all aspects way slower than the host driver, the Qualcomm Atheros AR8161 Gigabit Ethernet.

# Question 2
## Choose the guest system with the highest uplink deviation compared to the native execution and rerun the iperf3 benchmark using a public iperf3 server.
Chosen server: bouygues.iperf.fr
Guest system: Qemu (without KVM)
Results:  94.1
          94.2
          94.4
          94.3
          94.4
          94.2
          92.9
          91.4
          91.6
          92.7
## Run the same experiment using the host as a client (and the same public iperf3 server). Could the results from Task 3 be reproduced? Why? Why not?
Chosen server: bouygues.iperf.fr
System: native
Results:  94.5
          94.7
          94.5
          94.6
          95.0
          94.7
          94.6
          94.5
          94.6
          94.5
Here, we couldn't see any deviation from host performance, but both results are also much slower than the results if the host also provides the server. This indicates that the bottleneck is outside of the internal network, so there has to be a bottleneck on the internet side of the router, i.e. the bandwidth the ISP provides.
