CPU interconnect是什么？

numactl --cpunodebind绑定numa

Cpu调度

# NUMA + PCIe（Day2 和 Day4 的连接）

服务器设备也有 NUMA 归属。

例如：

NVMe → NUMA3\
NIC → NUMA1\
NPU → NUMA0

查看方法：

cat /sys/bus/pci/devices/xxxx/numa_node

这就是为什么服务器工程师会分析：

CPU\
NUMA\
PCIe设备

的关系。

假设nvme=numa3、npu=numa1、

Cpu绑定在numa1最合适

在ai推理服务器中、npu一般一次性读取数据、多次计算、所以要将cpu靠近计算端、也就是nvmenuma3-cpunuma1-pcie-npu只有一次的跨numa而且npu访问的是本地

NVMe (NUMA3)

↓

跨 NUMA

↓

CPU (NUMA1)

↓

本地 PCIe

↓

NPU

出现在nvme的数据读取阶段、在ai推理服务器中、npu主要负责推理计算、而cpu可能只负责调度、

如果cpu和numa3绑定那就会出现nvme-cpunuma3-pcie root port-cpu numa1 -npu出现一次跨numa、多了一次cpu调度但是npu计算是远程、不是本地

NVMe (NUMA3)

↓

CPU (NUMA3)

↓

跨 NUMA

↓

# NPU (NUMA1)为什么 AI 服务器优先靠近计算设备

因为 AI 推理的特点是：

一次读取\
多次计算

例如：

读模型\
读输入数据

之后大量时间是：

矩阵计算\
张量计算

所以服务器调度通常是：

CPU 靠近 GPU/NPU

而不是：

CPU 靠近 NVMe

Iostat是看io

Iostat -x 1每秒刷新一次io状态

重点看

%util

await

r/s

w/s

rkB/s

wkB/s

Await\>20ms越大速度越慢、%util越大利用率越高

# 服务器排查问题的标准流程

工程师通常按这个顺序：

top\
↓\
iostat -x 1\
↓\
free -h\
↓\
lspci

意思是：

先看CPU\
再看IO\
再看内存\
最后看硬件

• load average \> CPU核心数 → CPU过载

• • us 很高 → 用户进程计算多

• • sy 很高 → 内核开销大

•

### 2️⃣ 内存

命令：

free -h

重点看：

available

原则：

available 低 → 内存紧张\
available 高 → 内存充足

注意：

free 不重要\
Linux会把内存做缓存

### 3️⃣ IO

命令：

iostat -x 1

重点看：

%util\
await\
rkB/s\
wkB/s

判断：

%util ≈ 100% → 磁盘跑满\
await 很高 → IO延迟大
