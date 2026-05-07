服务器性能分析、学会判断服务器瓶颈

服务器工程能力

服务器工程师

│

├─Linux系统

│ ├top

│ ├ps

│ ├vmstat

│ └iostat

│

├─CPU架构

│ ├NUMA

│ ├CPU topology

│ └CPU affinity

│

├─PCIe架构

│ ├PCIe Root Port

│ ├PCIe Switch

│ └PCIe Link Speed

│

├─存储系统

│ ├NVMe

│ ├SAS

│ └RAID

│

├─网络系统

│ ├NIC

│ ├RDMA

│ └IRQ

│

└─自动化

├Python

└测试脚本

百日学习计划是为了看到服务器 → 能分析结构

看到性能问题 → 能定位瓶颈

看到设备异常 → 能排查原因

后面的课程会按照以下版块来：

Day1 Linux基础

Day2 服务器硬件识别

Day3 NUMA架构

Day4 PCIe架构

Day5 NVMe存储

Day6 SAS / RAID

Day7 网络 / RDMA

Day8 性能分析

Day9 IRQ与CPU调度

Day10 故障排查

10天其实是 **一个小循环**。

后面会不断加深。

Day1 Linux基础

Day2 硬件识别

Day3 NUMA

Day4 PCIe

Day5 Storage

Day6 Network

Day7 Performance

Day8 IRQ

Day9 Troubleshooting

Day10 Automation

硬件方向：PCIe / NUMA / NVMe / 服务器整机

AI方向：GPU / RDMA / 分布式训练

系统方向：Linux内核 / 调度 / 系统架构

DAY3

模块1 服务器负载 load average

模块2 CPU使用率 top

模块3 CPU进程分析

模块4 内存分析 free

模块5 内存细节 /proc/meminfo

模块6 IO分析 iostat

模块7 进程资源 pidstat

模块8 系统运行时间 uptime

模块9 CPU中断 /proc/interrupts

模块10 watch实时监控

1、系统整体负载

\[root@bogon ~\]# uptime

12:42:40 up 22:25, 2 users, load average: 0.00, 0.00, 0.00

\[root@bogon ~\]#

三个值分别是

1分钟平均负载

5分钟平均负载

15分钟平均负载

Stress-ng --cpu 256

<img src="media/image1.png" style="width:5.76597in;height:1.51944in" alt="78dd7ab024153783fdece4b30d70ed6f" /><img src="media/image2.png" style="width:5.76597in;height:1.25139in" alt="32c6caefa4986733a48b890093957ef7" /><img src="media/image3.png" style="width:5.76806in;height:4.20833in" alt="c72d47408da954df8326a841327492b4" />

下面是未跑stress的状态

<img src="media/image4.png" style="width:5.75972in;height:3.43403in" alt="5f5e55259596c7cc818e273a7b9e574a" />

2、 CPU使用率分析

us 用户进程\
sy 内核\
id 空闲\
wa IO等待

\[root@bogon ~\]# top

top - 12:32:52 up 22:15, 2 users, <span class="mark">load average: 0.00, 0.00, 0.00</span>

Tasks: 832 total, 2 running, 830 sleeping, 0 stopped, 0 zombie

<span class="mark">%Cpu(s): 0.0 us, 0.0 sy, 0.0 ni,100.0 id, 0.0 wa, 0.0 hi, 0.0 si, 0.0 st</span>

MiB Mem : 255968.2 total, 253765.1 free, 3330.2 used, 829.1 buff/cache

MiB Swap: 4096.0 total, 4096.0 free, 0.0 used. 252638.0 avail Mem

PID USER PR NI VIRT RES SHR S %CPU %MEM TIME+ COMMAND

50500 root 20 0 27720 5260 3072 R 0.7 0.0 0:00.15 top

48715 root 20 0 0 0 0 I 0.3 0.0 0:00.20 kworker/u160:4-hclge

1 root 20 0 174244 17552 9640 S 0.0 0.0 0:04.15 systemd

2 root 20 0 0 0 0 S 0.0 0.0 0:00.08 kthreadd

3 root 0 -20 0 0 0 I 0.0 0.0 0:00.00 rcu_gp

4 root 0 -20 0 0 0 I 0.0 0.0 0:00.00 rcu_par_gp

6 root 0 -20 0 0 0 I 0.0 0.0 0:00.00 kworker/0:0H-events_highpri

8 root 0 -20 0 0 0 I 0.0 0.0 0:00.00 mm_percpu_wq

9 root 20 0 0 0 0 S 0.0 0.0 0:00.00 rcu_tasks_rude\_

10 root 20 0 0 0 0 S 0.0 0.0 0:00.00 rcu_tasks_trace

11 root 20 0 0 0 0 S 0.0 0.0 0:00.00 ksoftirqd/0

12 root 20 0 0 0 0 I 0.0 0.0 0:04.67 rcu_sched

13 root rt 0 0 0 0 S 0.0 0.0 0:00.00 migration/0

14 root 20 0 0 0 0 S 0.0 0.0 0:00.00 cpuhp/0

15 root 20 0 0 0 0 S 0.0 0.0 0:00.00 cpuhp/1

16 root rt 0 0 0 0 S 0.0 0.0 0:00.00 migration/1

17 root 20 0 0 0 0 S 0.0 0.0 0:00.00 ksoftirqd/1

18 root 20 0 0 0 0 I 0.0 0.0 0:00.00 kworker/1:0-events

19 root 0 -20 0 0 0 I 0.0 0.0 0:00.00 kworker/1:0H-events_highpri

20 root 20 0 0 0 0 S 0.0 0.0 0:00.00 cpuhp/2

21 root rt 0 0 0 0 S 0.0 0.0 0:00.02 migration/2

22 root 20 0 0 0 0 S 0.0 0.0 0:00.03 ksoftirqd/2

24 root 0 -20 0 0 0 I 0.0 0.0 0:00.00 kworker/2:0H-events_highpri

25 root 20 0 0 0 0 S 0.0 0.0 0:00.00 cpuhp/3

26 root rt 0 0 0 0 S 0.0 0.0 0:00.01 migration/3

27 root 20 0 0 0 0 S 0.0 0.0 0:00.02 ksoftirqd/3

29 root 0 -20 0 0 0 I 0.0 0.0 0:00.00 kworker/3:0H-events_highpri

30 root 20 0 0 0 0 S 0.0 0.0 0:00.00 cpuhp/4

31 root rt 0 0 0 0 S 0.0 0.0 0:00.01 migration/4

32 root 20 0 0 0 0 S 0.0 0.0 0:00.04 ksoftirqd/4

34 root 0 -20 0 0 0 I 0.0 0.0 0:00.00 kworker/4:0H-events_highpri

35 root 20 0 0 0 0 S 0.0 0.0 0:00.00 cpuhp/5

36 root rt 0 0 0 0 S 0.0 0.0 0:00.01 migration/5

37 root 20 0 0 0 0 S 0.0 0.0 0:00.04 ksoftirqd/5

39 root 0 -20 0 0 0 I 0.0 0.0 0:00.00 kworker/5:0H-events_highpri

40 root 20 0 0 0 0 S 0.0 0.0 0:00.00 cpuhp/6

41 root rt 0 0 0 0 S 0.0 0.0 0:00.01 migration/6

42 root 20 0 0 0 0 S 0.0 0.0 0:00.04 ksoftirqd/6

44 root 0 -20 0 0 0 I 0.0 0.0 0:00.00 kworker/6:0H-events_highpri

45 root 20 0 0 0 0 S 0.0 0.0 0:00.00 cpuhp/7

46 root rt 0 0 0 0 S 0.0 0.0 0:00.01 migration/7

47 root 20 0 0 0 0 S 0.0 0.0 0:00.04 ksoftirqd/7

按h查看help

Help for Interactive Commands - procps-ng 4.0.2

Window 1:Def: Cumulative mode Off. System: Delay 3.0 secs; Secure mode Off.

Z,B,E,e Global: 'Z' colors; 'B' bold; 'E'/'e' summary/task memory scale

l,t,m,I Toggle: 'l' load avg; 't' task/cpu; 'm' memory; 'I' Irix mode

0,1,2,3,4 Toggle: '0' zeros; '1/2/3' cpu/numa views; '4' cpus two abreast

f,X Fields: 'f' add/remove/order/sort; 'X' increase fixed-width fields

L,&,\<,\> . Locate: 'L'/'&' find/again; Move sort column: '\<'/'\>' left/right

R,H,J,C . Toggle: 'R' Sort; 'H' Threads; 'J' Num justify; 'C' Coordinates

c,i,S,j . Toggle: 'c' Cmd name/line; 'i' Idle; 'S' Time; 'j' Str justify

x,y . Toggle highlights: 'x' sort field; 'y' running tasks

z,b . Toggle: 'z' color/mono; 'b' bold/reverse (only if 'x' or 'y')

u,U,o,O . Filter by: 'u'/'U' effective/any user; 'o'/'O' other criteria

n,#,^O . Set: 'n'/'#' max tasks displayed; Show: Ctrl+'O' other filter(s)

V,v,F . Toggle: 'V' forest view; 'v' hide/show children; 'F' keep focused

d,k,r,^R 'd' set delay; 'k' kill; 'r' renice; Ctrl+'R' renice autogroup

^G,K,N,U View: ctl groups ^G; cmdline ^K; environment ^N; supp groups ^U

W,Y,!,^E Write cfg 'W'; Inspect 'Y'; Combine Cpus '!'; Scale time ^E'

q Quit

( commands shown with '.' require a visible task display window )

Press 'h' or '?' for help with Windows,

Type 'q' or \<Esc\> to continue

3、CPU进程分析

鲲鹏920

按p进不去？？

4、内存使用分析

\[root@bogon ~\]# free -h

total <span class="mark">used</span> free shared buff/cache <span class="mark">available</span>

Mem: 249Gi 3.2Gi 247Gi 9.9Mi 834Mi 246Gi

Swap: 4.0Gi 0B 4.0Gi

\[root@bogon ~\]#

\##available 很低说明内存不够用

<img src="media/image5.png" style="width:5.75972in;height:3.14444in" alt="6974747a6231fd66538ce63040601388" />

5、模块5：查看内存细节：关注

MemTotal

MemFree

MemAvailable

cat /proc/meminfo \| head

<img src="media/image6.png" style="width:4.27083in;height:2.22917in" alt="2e9c12cfc3702523455aaea622fbd1f0" />

6、模块6 IO分析 iostat

IO性能分析

\[root@bogon ~\]# iostat -x 1（-x 1每一秒输出一次）

Linux 5.10.0-216.0.0.115.oe2203sp4.aarch64 (bogon) 2026年03月11日 \_aarch64\_ (80 CPU)

avg-cpu: %user %nice %system %iowait %steal %idle

0.01 0.00 0.01 0.00 0.00 99.99

Device r/s rkB/s rrqm/s %rrqm r_await rareq-sz w/s wkB/s wrqm/s %wrqm w_await wareq-sz d/s dkB/s drqm/s %drqm d_await dareq-sz f/s f_await aqu-sz %util

dm-0 0.13 3.06 0.00 0.00 0.23 24.26 1.03 21.02 0.00 0.00 0.02 20.43 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.09

dm-1 0.00 0.03 0.00 0.00 0.30 70.40 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00

dm-2 0.00 0.05 0.00 0.00 0.10 27.41 0.00 0.01 0.00 0.00 0.00 4.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00

sda 0.11 3.90 0.05 33.10 0.41 35.81 0.68 21.03 0.46 40.69 0.24 31.12 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00

avg-cpu: %user %nice %system %iowait %steal %idle

0.01 0.00 0.01 0.00 0.00 99.98

Device r/s rkB/s rrqm/s %rrqm <span class="mark">r_await</span> rareq-sz w/s wkB/s wrqm/s %wrqm <span class="mark">w_await</span> wareq-sz d/s dkB/s drqm/s %drqm <span class="mark">d_await</span> dareq-sz <span class="mark">f/s f_await</span> aqu-sz <span class="mark">%util</span>

dm-0 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00

dm-1 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00

dm-2 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00

sda 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00

%util 100说明磁盘已经跑满

<img src="media/image7.png" style="width:5.75833in;height:1.15694in" alt="9e571cfb5443d1fbbbea7deb0268b23e" />

先下载yum install sysstat

7、模块进程资源 pidstat

系统提示无Pidstat命令

<img src="media/image8.png" style="width:5.76319in;height:0.79653in" alt="c13f8a3192cefa76a048b23972275ad0" />

8.  模块8 系统运行时间 uptime

    Uptime

    <img src="media/image9.png" style="width:5.76597in;height:0.46875in" alt="7e694e06dafa75d944cfe3c699709ec4" />

模块9 CPU中断 /proc/interrupts

<img src="media/image10.png" style="width:5.76597in;height:3.40833in" alt="f986b1340bcf57c3b26bdb53e57a98a2" />

模块10 watch实时监控

<img src="media/image11.png" style="width:5.76597in;height:3.40833in" alt="03d234452f484681c7b7f5929b65bc4b" />

Day3 Python模块（服务器工程版本）

用python读取服务器信息

import subprocess

result = subprocess.run(\["lscpu"\], capture_output=True, text=True)

print(result.stdout)

<img src="media/image12.png" style="width:4.64583in;height:0.36458in" alt="a02cf61590b110ed6f0e85d584e94d2e" />

功能等同于lscpu

读取cpu数

import subprocess

result = subprocess.run(\["lscpu"\], capture_output=True, text=True)

for line in result.stdout.split("\n"):

if "CPU(s):" in line:

print(line)

等同于：

lscpu \| grep -i cpu：

Cpu: 256

读取NVME数量

vim nvme_check.py

import subprocess

result = subprocess.run(\["nvme", "list"\], capture_output=True, text=True)

count = result.stdout.count("/dev/nvme")

print("NVMe devices:", count)

可以看到nvme数量是2

同意nvme list也可以看到有几个nmve

<img src="media/image13.png" style="width:5.57292in;height:1.64583in" alt="317652ea3d549e6ae7ab3f638079fa60" />

综合脚本

import subprocess

print("=== <span class="mark">CPU</span> ===")

print(subprocess.run(\["<span class="mark">lscpu</span>"\], capture_output=True, text=True).stdout)

print("=== <span class="mark">Memory</span> ===")

print(subprocess.run(\["<span class="mark">free","-h</span>"\], capture_output=True, text=True).stdout)

print("=== <span class="mark">NVMe</span> ===")

print(subprocess.run(\["<span class="mark">nvme","list</span>"\], capture_output=True, text=True).stdout)
