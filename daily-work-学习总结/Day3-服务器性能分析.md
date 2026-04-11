服务器性能分析、学会判断服务器瓶颈
服务器工程能力
服务器工程师
│
├─Linux系统
│   ├top
│   ├ps
│   ├vmstat
│   └iostat
│
├─CPU架构
│   ├NUMA
│   ├CPU topology
│   └CPU affinity
│
├─PCIe架构
│   ├PCIe Root Port
│   ├PCIe Switch
│   └PCIe Link Speed
│
├─存储系统
│   ├NVMe
│   ├SAS
│   └RAID
│
├─网络系统
│   ├NIC
│   ├RDMA
│   └IRQ
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
10天其实是 一个小循环。
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
## 服务器负载 load average

## CPU使用率 top

## CPU进程分析

## 内存分析 free

## 内存细节 /proc/meminfo

## IO分析 iostat

## 进程资源 pidstat

## 系统运行时间 uptime

## CPU中断 /proc/interrupts

## watch实时监控

1、系统整体负载

```bash
[root@bogon ~]# uptime
12:42:40 up 22:25,  2 users,  load average: 0.00, 0.00, 0.00
```

三个值分别是
1分钟平均负载
5分钟平均负载
15分钟平均负载
Stress-ng --cpu 256


下面是未跑stress的状态

- 2、 CPU使用率分析

us 用户进程
sy 内核
id 空闲
wa IO等待
```bash
[root@bogon ~]# top
top - 12:32:52 up 22:15,  2 users,  load average: 0.00, 0.00, 0.00
Tasks: 832 total,   2 running, 830 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem : 255968.2 total, 253765.1 free,   3330.2 used,    829.1 buff/cache
MiB Swap:   4096.0 total,   4096.0 free,      0.0 used. 252638.0 avail Mem
PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
50500 root      20   0   27720   5260   3072 R   0.7   0.0   0:00.15 top
48715 root      20   0       0      0      0 I   0.3   0.0   0:00.20 kworker/u160:4-hclge
1 root      20   0  174244  17552   9640 S   0.0   0.0   0:04.15 systemd
2 root      20   0       0      0      0 S   0.0   0.0   0:00.08 kthreadd
3 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 rcu_gp
4 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 rcu_par_gp
6 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/0:0H-events_highpri
8 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 mm_percpu_wq
9 root      20   0       0      0      0 S   0.0   0.0   0:00.00 rcu_tasks_rude_
10 root      20   0       0      0      0 S   0.0   0.0   0:00.00 rcu_tasks_trace
11 root      20   0       0      0      0 S   0.0   0.0   0:00.00 ksoftirqd/0
12 root      20   0       0      0      0 I   0.0   0.0   0:04.67 rcu_sched
13 root      rt   0       0      0      0 S   0.0   0.0   0:00.00 migration/0
14 root      20   0       0      0      0 S   0.0   0.0   0:00.00 cpuhp/0
15 root      20   0       0      0      0 S   0.0   0.0   0:00.00 cpuhp/1
16 root      rt   0       0      0      0 S   0.0   0.0   0:00.00 migration/1
17 root      20   0       0      0      0 S   0.0   0.0   0:00.00 ksoftirqd/1
18 root      20   0       0      0      0 I   0.0   0.0   0:00.00 kworker/1:0-events
19 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/1:0H-events_highpri
20 root      20   0       0      0      0 S   0.0   0.0   0:00.00 cpuhp/2
21 root      rt   0       0      0      0 S   0.0   0.0   0:00.02 migration/2
22 root      20   0       0      0      0 S   0.0   0.0   0:00.03 ksoftirqd/2
24 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/2:0H-events_highpri
25 root      20   0       0      0      0 S   0.0   0.0   0:00.00 cpuhp/3
26 root      rt   0       0      0      0 S   0.0   0.0   0:00.01 migration/3
27 root      20   0       0      0      0 S   0.0   0.0   0:00.02 ksoftirqd/3
29 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/3:0H-events_highpri
30 root      20   0       0      0      0 S   0.0   0.0   0:00.00 cpuhp/4
31 root      rt   0       0      0      0 S   0.0   0.0   0:00.01 migration/4
32 root      20   0       0      0      0 S   0.0   0.0   0:00.04 ksoftirqd/4
34 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/4:0H-events_highpri
35 root      20   0       0      0      0 S   0.0   0.0   0:00.00 cpuhp/5
36 root      rt   0       0      0      0 S   0.0   0.0   0:00.01 migration/5
37 root      20   0       0      0      0 S   0.0   0.0   0:00.04 ksoftirqd/5
39 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/5:0H-events_highpri
40 root      20   0       0      0      0 S   0.0   0.0   0:00.00 cpuhp/6
41 root      rt   0       0      0      0 S   0.0   0.0   0:00.01 migration/6
42 root      20   0       0      0      0 S   0.0   0.0   0:00.04 ksoftirqd/6
44 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/6:0H-events_highpri
45 root      20   0       0      0      0 S   0.0   0.0   0:00.00 cpuhp/7
46 root      rt   0       0      0      0 S   0.0   0.0   0:00.01 migration/7
47 root      20   0       0      0      0 S   0.0   0.0   0:00.04 ksoftirqd/7
```

按h查看help
Help for Interactive Commands - procps-ng 4.0.2
Window 1:Def: Cumulative mode Off.  System: Delay 3.0 secs; Secure mode Off.

Z,B,E,e   Global: 'Z' colors; 'B' bold; 'E'/'e' summary/task memory scale
l,t,m,I   Toggle: 'l' load avg; 't' task/cpu; 'm' memory; 'I' Irix mode
0,1,2,3,4 Toggle: '0' zeros; '1/2/3' cpu/numa views; '4' cpus two abreast
f,X       Fields: 'f' add/remove/order/sort; 'X' increase fixed-width fields

L,&,<,> . Locate: 'L'/'&' find/again; Move sort column: '<'/'>' left/right
R,H,J,C . Toggle: 'R' Sort; 'H' Threads; 'J' Num justify; 'C' Coordinates
c,i,S,j . Toggle: 'c' Cmd name/line; 'i' Idle; 'S' Time; 'j' Str justify
x,y     . Toggle highlights: 'x' sort field; 'y' running tasks
z,b     . Toggle: 'z' color/mono; 'b' bold/reverse (only if 'x' or 'y')
u,U,o,O . Filter by: 'u'/'U' effective/any user; 'o'/'O' other criteria
n,#,^O  . Set: 'n'/'#' max tasks displayed; Show: Ctrl+'O' other filter(s)
V,v,F   . Toggle: 'V' forest view; 'v' hide/show children; 'F' keep focused

d,k,r,^R 'd' set delay; 'k' kill; 'r' renice; Ctrl+'R' renice autogroup
^G,K,N,U  View: ctl groups ^G; cmdline ^K; environment ^N; supp groups ^U
W,Y,!,^E  Write cfg 'W'; Inspect 'Y'; Combine Cpus '!'; Scale time ^E'
q         Quit
( commands shown with '.' require a visible task display window )
Press 'h' or '?' for help with Windows,
Type 'q' or <Esc> to continue

3、CPU进程分析
鲲鹏920
按p进不去？？
4、内存使用分析

```bash
[root@bogon ~]# free -h
total        used        free      shared      buff/cache   available
Mem:          249Gi       3.2Gi       247Gi       9.9Mi       834Mi       246Gi
Swap:          4.0Gi          0B       4.0Gi
```

##available 很低说明内存不够用






5、模块5：查看内存细节：关注
MemTotal
MemFree
MemAvailable
cat /proc/meminfo | head



6、模块6 IO分析 iostat
IO性能分析
```bash
[root@bogon ~]# iostat -x 1（-x 1每一秒输出一次）
Linux 5.10.0-216.0.0.115.oe2203sp4.aarch64 (bogon)      2026年03月11日  _aarch64_       (80 CPU)
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
```

0.01    0.00    0.01    0.00    0.00   99.99



Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
dm-0             0.13      3.06     0.00   0.00    0.23    24.26    1.03     21.02     0.00   0.00    0.02    20.43    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.09
dm-1             0.00      0.03     0.00   0.00    0.30    70.40    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
dm-2             0.00      0.05     0.00   0.00    0.10    27.41    0.00      0.01     0.00   0.00    0.00     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
sda              0.11      3.90     0.05  33.10    0.41    35.81    0.68     21.03     0.46  40.69    0.24    31.12    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00


avg-cpu:  %user   %nice %system %iowait  %steal   %idle
0.01    0.00    0.01    0.00    0.00   99.98

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
dm-0             0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
dm-1             0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
dm-2             0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
sda              0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
%util 100说明磁盘已经跑满

先下载yum install sysstat

7、模块进程资源 pidstat
系统提示无Pidstat命令

## 系统运行时间 uptime

Uptime

## CPU中断 /proc/interrupts



## watch实时监控


Day3 Python模块（服务器工程版本）


用python读取服务器信息
import subprocess

result = subprocess.run(["lscpu"], capture_output=True, text=True)

print(result.stdout)

功能等同于lscpu

读取cpu数

import subprocess

result = subprocess.run(["lscpu"], capture_output=True, text=True)

for line in result.stdout.split("\n"):
if "CPU(s):" in line:
print(line)
等同于：
lscpu | grep -i cpu：
Cpu: 256


读取NVME数量

vim nvme_check.py
import subprocess

result = subprocess.run(["nvme", "list"], capture_output=True, text=True)

count = result.stdout.count("/dev/nvme")

print("NVMe devices:", count)


可以看到nvme数量是2
同意nvme list也可以看到有几个nmve





综合脚本

import subprocess

print("=== CPU ===")
print(subprocess.run(["lscpu"], capture_output=True, text=True).stdout)

print("=== Memory ===")
print(subprocess.run(["free","-h"], capture_output=True, text=True).stdout)

print("=== NVMe ===")
print(subprocess.run(["nvme","list"], capture_output=True, text=True).stdout)
