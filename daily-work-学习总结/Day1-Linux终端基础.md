
## Linux终端基础

1、pwd查看当前路径
```bash
[root@bogon ~]# pwd
/root
```


2、ls查看当前路径下内容
```bash
[root@bogon ~]# ls
anaconda-ks.cfg
ascend
Ascend-cann-toolkit_8.5.0_linux-aarch64.run
ascend_check
Ascend-hdk-910b-npu-driver_25.5.0_linux-aarch64.run
Ascend-hdk-910b-npu-firmware_7.8.0.5.216.run
Ascend-mindx-toolbox_7.3.0_linux-aarch64.run
dmesg.log
log
nohup.out
reboot
reboot.zip
SAS35_StorCLI_7_27-007.2707.0000.0000.zip
sel.log
SIT_Total_Report.csv
storcli.log
storcli.log.1
storcli_rel
stress_all.sh
stress_logs
super_check.py
```

ls -l查看当前路径下文件的详细内容
字段包含权限、用户、大小、时间
```bash
[root@bogon ~]# ls -l
总用量 1243456
-rw-------. 1 root root        707  2月 12 11:52 anaconda-ks.cfg
drwxr-x---. 4 root root       4096  2月 12 16:37 ascend
-rwxr-xr-x. 1 root root 1104308866  2月 12 13:55 Ascend-cann-toolkit_8.5.0_linux-aarch64.run
dr-x------. 2 root root       4096  2月 12 15:05 ascend_check
-rwxr-xr-x. 1 root root  120862617  2月  2 18:38 Ascend-hdk-910b-npu-driver_25.5.0_linux-aarch64.run
-rwxr-xr-x. 1 root root     284438  2月  2 18:38 Ascend-hdk-910b-npu-firmware_7.8.0.5.216.run
-rwxr-xr-x. 1 root root    7135261  2月 12 15:27 Ascend-mindx-toolbox_7.3.0_linux-aarch64.run
-rw-r--r--. 1 root root     278141  3月  6 17:52 dmesg.log
drwxr-xr-x. 5 root root       4096  2月 27 21:36 log
-rw-------. 1 root root          0  2月 12 17:45 nohup.out
drwxrwxrwx. 3 root root       4096  2月 28 09:37 reboot
-rw-r--r--. 1 root root      23966  1月  8 10:40 reboot.zip
-rw-r--r--. 1 root root   34566846  2月  2 20:02 SAS35_StorCLI_7_27-007.2707.0000.0000.zip
-rw-r--r--. 1 root root      28450  3月  6 17:55 sel.log
-rw-r--r--. 1 root root         49  3月  6 17:57 SIT_Total_Report.csv
-rw-r--r--. 1 root root    2562873  2月 24 14:50 storcli.log
-rw-r--r--. 1 root root    3179097  2月 24 10:49 storcli.log.1
drwxr-xr-x. 3 root root       4096  2月 12 17:38 storcli_rel
-rwxr-xr-x. 1 root root       1656  2月 12 17:52 stress_all.sh
drwxr-xr-x. 2 root root       4096  2月 13 09:39 stress_logs
-rw-r--r--. 1 root root       2034  3月  6 17:57 super_check.py
```


3、cd切换路径
```bash
[root@bogon ~]# cd /var/lo
local/ lock/  log/
[root@bogon ~]# cd /var/log/
[root@bogon log]# pwd
/var/log
[root@bogon log]# cd ~
```



4、mkdir创建文件夹
```bash
[root@bogon ~]# mkdir server_lab
[root@bogon ~]# ls
anaconda-ks.cfg
ascend
Ascend-cann-toolkit_8.5.0_linux-aarch64.run
ascend_check
Ascend-hdk-910b-npu-driver_25.5.0_linux-aarch64.run
Ascend-hdk-910b-npu-firmware_7.8.0.5.216.run
Ascend-mindx-toolbox_7.3.0_linux-aarch64.run
dmesg.log
log
nohup.out
reboot
reboot.zip
SAS35_StorCLI_7_27-007.2707.0000.0000.zip
sel.log
server_lab
sever_lab
SIT_Total_Report.csv
storcli.log
storcli.log.1
storcli_rel
stress_all.sh
stress_logs
super_check.py
[root@bogon ~]# cd server_lab/
[root@bogon server_lab]#
```



5、touch创建文件
```bash
[root@bogon server_lab]# touch test.txt
[root@bogon server_lab]# ls
test.txt
[root@bogon server_lab]#
```



6、cp复制文件
```bash
[root@bogon server_lab]# cp test.txt test2.txt
[root@bogon server_lab]# ls
test2.txt  test.txt
[root@bogon server_lab]#
```


7、rm删除文件
```bash
[root@bogon server_lab]# rm test2.txt
```

rm：是否删除普通空文件 'test2.txt'？y
```bash
[root@bogon server_lab]# ls
test.txt
[root@bogon server_lab]#
```

Linux基础总结
pwd：查看当前路径
ls：查看目录内容
ls -l：查看详细信息
cd：切换目录
mkdir：创建目录
touch：创建文件
cp：复制文件
rm：删除文件


## 查看服务器硬件（CPU、Memory、Disk、PCIe devices）

1、查看CPU：lscpu（重点关注CPU(s)、Model name、Thread(s) per core）
```bash
[root@bogon server_lab]# lscpu
```

架构：                  aarch64
CPU 运行模式：        64-bit
字节序：              Little Endian
CPU:                    256
在线 CPU 列表：       0-255
厂商 ID：               HiSilicon
BIOS Vendor ID:       HiSilicon
BIOS Model name:      Kunpeng 920 7260Z
型号：                0
每个核的线程数：2       CPU(s): 256、Socket: 2、Core per socket: 64、Thread per core: 2
2颗CPU、每颗CPU 64核心、每核心2线程（2*64*2+256）
每个座的核数：        64
座：                  2
步进：                0x0
Frequency boost:      disabled
CPU 最大 MHz：        2600.0000
CPU 最小 MHz：        400.0000
BogoMIPS：            200.00
标记：                fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp cpuid
asimdrdm jscvt fcma lrcpc dcpop sha3 sm3 sm4 asimddp sha512 sve asim
dfhm dit uscat ilrcpc flagm ssbs sb dcpodp flagm2 frint svei8mm svef3
2mm svef64mm svebf16 i8mm bf16 dgh rng ecv
Caches (sum of all):
L1d:                  8 MiB (128 instances)
L1i:                  8 MiB (128 instances)
L2:                   160 MiB (128 instances)
L3:                   224 MiB (4 instances)
NUMA:
NUMA 节点：           4
NUMA 节点0 CPU：      0-63
NUMA 节点1 CPU：      64-127
NUMA 节点2 CPU：      128-191
NUMA 节点3 CPU：      192-255
Vulnerabilities:
Gather data sampling: Not affected
Itlb multihit:        Not affected
L1tf:                 Not affected
Mds:                  Not affected
Meltdown:             Not affected
Mmio stale data:      Not affected
Retbleed:             Not affected
Spec rstack overflow: Not affected
Spec store bypass:    Mitigation; Speculative Store Bypass disabled via prctl
Spectre v1:           Mitigation; __user pointer sanitization
Spectre v2:           Not affected
Srbds:                Not affected
Tsx async abort:      Not affected
```bash
[root@bogon server_lab]#
```

查看内存：free -h

```bash
[root@bogon server_lab]# free -h
total        used        free      shared  buff/cache   available
Mem:           2.0Ti        10Gi       2.0Ti        28Mi       915Mi       2.0Ti
Swap:          4.0Gi          0B       4.0Gi
[root@bogon server_lab]#
```

查看磁盘：lsblk
lsblk 命令会列出系统中 所有的块设备（包括硬盘、分区、RAID等）。
如果一个 NVMe SSD 消失了，可能是 系统没有检测到该设备。
这种情况往往发生在硬件故障、驱动问题、或者设备与主板之间的连接问题时。

```bash
[root@bogon server_lab]# lsblk
NAME               MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda                  8:0    0 446.6G  0 disk
sdb                  8:16   0 446.6G  0 disk
sdc                  8:32   0 446.6G  0 disk
sdd                  8:48   0 446.6G  0 disk
sde                  8:64   0 446.6G  0 disk
sdf                  8:80   0 447.1G  0 disk
sdg                  8:96   0 447.1G  0 disk
sdh                  8:112  0 446.6G  0 disk
sdi                  8:128  0 446.6G  0 disk
sdj                  8:144  0 446.6G  0 disk
nvme1n1            259:0    0   2.9T  0 disk
├─nvme1n1p1        259:2    0   600M  0 part /boot/efi
├─nvme1n1p2        259:3    0     1G  0 part /boot
└─nvme1n1p3        259:4    0   2.9T  0 part
├─openeuler-root 253:0    0    70G  0 lvm  /
├─openeuler-swap 253:1    0     4G  0 lvm  [SWAP]
└─openeuler-home 253:3    0   2.8T  0 lvm  /home
nvme0n1            259:1    0   2.9T  0 disk
├─nvme0n1p1        259:5    0   600M  0 part
├─nvme0n1p2        259:6    0     1G  0 part
└─nvme0n1p3        259:7    0   2.9T  0 part
├─klas-swap      253:2    0     4G  0 lvm
├─klas-backup    253:4    0    50G  0 lvm
└─klas-root      253:5    0   2.9T  0 lvm
[root@bogon server_lab]#
```

查看pci设备：lspci


lspci 会列出 PCIe设备；NVMe 是 PCIe 设备，所以 lspci 能帮助你看到是否是 PCIe 总线的问题
如果你 没有看到 NVMe 设备，但在 lspci 中能看到设备（例如 NVMe 控制器），就说明：
NVMe SSD 本身可能没问题，但有驱动、配置或电源等问题


如果 lspci 中也看不见 NVMe 设备：
接下来你可以：
查看 dmesg 日志（Kernel Log）：dmesg | grep -i nvme是否 内核加载了 NVMe 驱动；是否有 硬件故障（例如设备初始化错误、I/O 错误等）。
如果看到类似 "NVMe timeout"、"controller reset"，说明可能是 硬件连接或控制器问题。
如果没有看到相关信息，说明设备可能 没有正确连接，或者主板上的 PCIe 插槽失效。
查看 lsmod：确认相关驱动是否加载。lsmod | grep nvme
如果问题还没解决，可以尝试 重启服务器，或者检查硬件连接：
是否 PCIe 插槽接触不良
是否 电源不稳定
是否 NVMe驱动出现问题
最终建议：
如果硬件连接正常，且设备在 lspci 中没有显示，可能需要 重新加载驱动 或 检查BIOS/UEFI设置，确认 NVMe 支持已开启。

```bash
[root@bogon server_lab]# lspci
01:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
01:01.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
01:02.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
01:03.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
02:00.0 VGA compatible controller: Huawei Technologies Co., Ltd. Hi171x Series [iBMC Intelligent Management system chip w/VGA support] (rev 01)##BMC卡
03:00.0 Signal processing controller: Huawei Technologies Co., Ltd. iBMA Virtual Network Adapter (rev 01)
07:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
08:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
0b:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
0c:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
2e:00.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
2e:01.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
2e:08.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
2e:09.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
2e:0b.0 System peripheral: Huawei Technologies Co., Ltd. HiSilicon Embedded DMA Engine (rev 30)
2f:00.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
2f:01.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
2f:08.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
2f:09.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
2f:0b.0 System peripheral: Huawei Technologies Co., Ltd. HiSilicon Embedded DMA Engine (rev 30)
30:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
30:01.0 USB controller: Huawei Technologies Co., Ltd. Device a23c (rev 30)
30:03.0 USB controller: Huawei Technologies Co., Ltd. Device a23d (rev 30)
30:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
30:05.0 Memory controller: Huawei Technologies Co., Ltd. Device a12f (rev 30)
32:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
32:01.0 USB controller: Huawei Technologies Co., Ltd. Device a23c (rev 30)
32:03.0 USB controller: Huawei Technologies Co., Ltd. Device a23d (rev 30)
32:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
34:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
34:01.0 System peripheral: Huawei Technologies Co., Ltd. Device a22b (rev 30)
35:00.0 Ethernet controller: Huawei Technologies Co., Ltd. HNS GE/10GE/25GE/50GE RDMA Network Controller (rev 30)
35:00.1 Ethernet controller: Huawei Technologies Co., Ltd. HNS GE/10GE/25GE/50GE RDMA Network Controller (rev 30)
35:00.2 Ethernet controller: Huawei Technologies Co., Ltd. HNS GE/10GE/25GE/50GE RDMA Network Controller (rev 30)
35:00.3 Ethernet controller: Huawei Technologies Co., Ltd. HNS GE/10GE/25GE/50GE RDMA Network Controller (rev 30) ##网卡
36:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
38:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
38:01.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
38:05.0 SATA controller: Huawei Technologies Co., Ltd. HiSilicon AHCI HBA (rev 30)
38:08.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
38:09.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
3c:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
3c:01.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
3c:08.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
3c:09.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
41:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
42:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
45:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
46:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
6e:00.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
6e:01.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
6e:08.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
6e:09.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
6e:0b.0 System peripheral: Huawei Technologies Co., Ltd. HiSilicon Embedded DMA Engine (rev 30)
6f:00.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
6f:01.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
6f:08.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
6f:09.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
6f:0b.0 System peripheral: Huawei Technologies Co., Ltd. HiSilicon Embedded DMA Engine (rev 30)
70:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
70:01.0 USB controller: Huawei Technologies Co., Ltd. Device a23c (rev 30)
70:03.0 USB controller: Huawei Technologies Co., Ltd. Device a23d (rev 30)
70:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
72:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
72:01.0 USB controller: Huawei Technologies Co., Ltd. Device a23c (rev 30)
72:03.0 USB controller: Huawei Technologies Co., Ltd. Device a23d (rev 30)
72:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
74:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
76:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
78:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
78:01.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
78:08.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
78:09.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
7c:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
7c:01.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
7c:08.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
7c:09.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
80:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
80:02.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
80:04.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
81:00.0 Non-Volatile memory controller: DERA Storage Device 1515
82:00.0 Non-Volatile memory controller: DERA Storage Device 1515##M.2形式的NVME
```

NVMe = PCIe协议的存储设备
NVMe通过PCIe x4连接CPU
所以会出现在lspci中

NVMe消失排查步骤：

1 lsblk
2 lspci
3 dmesg | grep nvme
4 lsmod | grep nvme

83:00.0 RAID bus controller: Broadcom / LSI MegaRAID 12GSAS/PCIe Secure SAS39xx##RAID卡
95:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
96:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
aa:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
ab:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
c0:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
c1:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
d5:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
d6:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
```bash
[root@bogon server_lab]#
```

查看服务器硬件部分总结
服务器结构：
CPU：Kunpeng 920 ×2
核心：256逻辑CPU
内存：2TB
PCIe设备：
NVMe SSD ×2
SAS HBA ×4
RDMA NIC ×1（4 ports）
RAID卡 ×1
NPU ×8
BMC ×1
## 查看系统状态


Top:查看系统进程(CPU usage、Memory usage、Running processes)
#q退出
```bash
[root@bogon server_lab]# top
top - 12:09:39 up 2 days, 21:05,  1 user,  load average: 8.00, 8.00, 8.00
Tasks: 2701 total,   1 running, 2700 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem : 2062458.+total, 2056736.+free,  10918.3 used,    918.1 buff/cache
MiB Swap:   4096.0 total,   4096.0 free,      0.0 used. 2051539.+avail Mem
PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
6950 root      20   0   82628   5436   1832 S   2.0   0.0  53:42.46 irqbalance
15836 root      20   0   30568   8160   3016 R   1.3   0.0   0:00.25 top
13 root      20   0       0      0      0 I   0.3   0.0   1:49.51 rcu_sched
1 root      20   0  182204  16908   8284 S   0.0   0.0   0:27.06 systemd
2 root      20   0       0      0      0 S   0.0   0.0   0:00.27 kthreadd
3 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 rcu_gp
4 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 rcu_par_gp
6 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/0:0H-events_+
9 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 mm_percpu_wq
10 root      20   0       0      0      0 S   0.0   0.0   0:00.00 rcu_tasks_rude_
11 root      20   0       0      0      0 S   0.0   0.0   0:00.00 rcu_tasks_trace
12 root      20   0       0      0      0 S   0.0   0.0   0:00.32 ksoftirqd/0
14 root      rt   0       0      0      0 S   0.0   0.0   0:00.02 migration/0
15 root      20   0       0      0      0 S   0.0   0.0   0:00.00 cpuhp/0
16 root      20   0       0      0      0 S   0.0   0.0   0:00.00 cpuhp/1
17 root      rt   0       0      0      0 S   0.0   0.0   0:00.00 migration/1
18 root      20   0       0      0      0 S   0.0   0.0   0:00.00 ksoftirqd/1
19 root      20   0       0      0      0 I   0.0   0.0   0:00.00 kworker/1:0-events
```


```bash
[root@bogon server_lab]#
```



## 查看系统日志

dmesg | head
```bash
[root@bogon server_lab]# dmesg | head
[    0.000000] Booting Linux on physical CPU 0x0300000000 [0x480fd020]
[    0.000000] Linux version 5.10.0-216.0.0.115.oe2203sp4.aarch64 (root@dc-64g.compass-ci) (gcc_old (GCC) 10.3.1, GNU ld (GNU Binutils) 2.37) #1 SMP Thu Jun 27 15:22:10 CST 2024
[    0.000000] efi: EFI v2.70 by EDK II
[    0.000000] efi: SMBIOS 3.0=0x5f960000 ACPI 2.0=0x5ffe0018 MEMATTR=0x528f3018 MOKvar=0x5f590000 RNG=0x5ffee918 MEMRESERVE=0x4eba5118
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x000000005FFE0018 000024 (v02 HISI  )
[    0.000000] ACPI: XSDT 0x000000005FFEFE98 0000A4 (v01 HISI   HIP09    00000000 HISI 20151124)
[    0.000000] ACPI: FACP 0x000000005FFEFA98 000114 (v06 HISI   HIP09    00000000 HISI 20151124)
[    0.000000] ACPI: DSDT 0x000000005FF20018 04507A (v02 HISI   HIP09    00000000 INTL 20230628)
[    0.000000] ACPI: APIC 0x000000005FFA0018 032094 (v01 HISI   HIP09    00000000 HISI 20151124)
[root@bogon server_lab]#
Dmesg| tail
[root@bogon server_lab]# dmesg | tail
[ 3463.325844] usb 1-1: USB disconnect, device number 3
[ 3605.344548] usb 1-1: new high-speed USB device number 4 using xhci_hcd
[ 3605.501349] usb 1-1: New USB device found, idVendor=12d1, idProduct=0001, bcdDevice= 1.00
[ 3605.510687] usb 1-1: New USB device strings: Mfr=0, Product=1, SerialNumber=2
[ 3605.518927] usb 1-1: Product: Keyboard/Mouse KVM 2.0
[ 3605.524795] usb 1-1: SerialNumber: 0123456
[ 3605.565264] input: Keyboard/Mouse KVM 2.0 as /devices/pci0000:30/0000:30:01.0/usb1/1-1/1-1:1.0/0003:12D1:0001.0008/input/input9
[ 3605.636990] hid-generic 0003:12D1:0001.0008: input,hidraw0: USB HID v2.00 Keyboard [Keyboard/Mouse KVM 2.0] on usb-0000:30:01.0-1/input0
[ 3605.654634] input: Keyboard/Mouse KVM 2.0 as /devices/pci0000:30/0000:30:01.0/usb1/1-1/1-1:1.1/0003:12D1:0001.0009/input/input10
[ 3605.670975] hid-generic 0003:12D1:0001.0009: input,hidraw1: USB HID v2.00 Mouse [Keyboard/Mouse KVM 2.0] on usb-0000:30:01.0-1/input1
[root@bogon server_lab]#
```



## Python

1、python3进入Python环境
```bash
[root@bogon server_lab]# python3
Python 3.9.9 (main, Dec 27 2025, 20:20:19)
[GCC 10.3.1] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> print("Hello Server Engineer")
Hello Server Engineer
>>> exit()
[root@bogon server_lab]#
```

拓展实验
查看pci设备拓扑结构lspci -tv

```bash
[root@bogon server_lab]# lspci -tv
-+-[0000:00]-
```

+-[0000:01]-+-00.0-[02]----00.0  Huawei Technologies Co., Ltd. Hi171x Series [iBMC Intelligent Management system chip w/VGA support]###BMC + VGA这是服务器的 管理芯片
（远程控制服务器、KVM、硬件监控、IPMI）
|           +-01.0-[03]----00.0  Huawei Technologies Co., Ltd. iBMA Virtual Network Adapter
|           +-02.0-[04]--
|           \-03.0-[05]--
+-[0000:07]---00.0-[08]----00.0  Huawei Technologies Co., Ltd. Device d802###NPU
+-[0000:0b]---00.0-[0c]----00.0  Huawei Technologies Co., Ltd. Device d802###NPU
+-[0000:2e]-+-00.0  Huawei Technologies Co., Ltd. Device a12d
|           +-01.0  Huawei Technologies Co., Ltd. Device a12e
|           +-08.0  Huawei Technologies Co., Ltd. Device a12d
|           +-09.0  Huawei Technologies Co., Ltd. Device a12e
|           \-0b.0  Huawei Technologies Co., Ltd. HiSilicon Embedded DMA Engine
+-[0000:2f]-+-00.0  Huawei Technologies Co., Ltd. Device a12d
|           +-01.0  Huawei Technologies Co., Ltd. Device a12e
|           +-08.0  Huawei Technologies Co., Ltd. Device a12d
|           +-09.0  Huawei Technologies Co., Ltd. Device a12e
|           \-0b.0  Huawei Technologies Co., Ltd. HiSilicon Embedded DMA Engine
+-[0000:30]-+-00.0-[31]--
|           +-01.0  Huawei Technologies Co., Ltd. Device a23c
|           +-03.0  Huawei Technologies Co., Ltd. Device a23d
|           +-04.0  Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA
|           \-05.0  Huawei Technologies Co., Ltd. Device a12f
+-[0000:32]-+-00.0-[33]--
|           +-01.0  Huawei Technologies Co., Ltd. Device a23c
|           +-03.0  Huawei Technologies Co., Ltd. Device a23d
|           \-04.0  Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA
+-[0000:34]-+-00.0-[35]--+-00.0  Huawei Technologies Co., Ltd. HNS GE/10GE/25GE/50GE RDMA Network Controller
|           |            +-00.1  Huawei Technologies Co., Ltd. HNS GE/10GE/25GE/50GE RDMA Network Controller
|           |            +-00.2  Huawei Technologies Co., Ltd. HNS GE/10GE/25GE/50GE RDMA Network Controller
|           |            \-00.3  Huawei Technologies Co., Ltd. HNS GE/10GE/25GE/50GE RDMA Network Controller
##网卡、四个网口、支持10、25、50、RDMA
|           \-01.0  Huawei Technologies Co., Ltd. Device a22b
+-[0000:36]---00.0-[37]--
+-[0000:38]-+-00.0-[39]--
|           +-01.0-[3a]--
|           +-05.0  Huawei Technologies Co., Ltd. HiSilicon AHCI HBA
|           +-08.0  Huawei Technologies Co., Ltd. Device a12d
|           \-09.0  Huawei Technologies Co., Ltd. Device a12e
+-[0000:3c]-+-00.0-[3d]--
|           +-01.0-[3e]--
|           +-08.0  Huawei Technologies Co., Ltd. Device a12d
|           \-09.0  Huawei Technologies Co., Ltd. Device a12e
+-[0000:41]---00.0-[42]----00.0  Huawei Technologies Co., Ltd. Device d802###NPU
+-[0000:45]---00.0-[46]----00.0  Huawei Technologies Co., Ltd. Device d802###NPU
+-[0000:6e]-+-00.0  Huawei Technologies Co., Ltd. Device a12d
|           +-01.0  Huawei Technologies Co., Ltd. Device a12e
|           +-08.0  Huawei Technologies Co., Ltd. Device a12d
|           +-09.0  Huawei Technologies Co., Ltd. Device a12e
|           \-0b.0  Huawei Technologies Co., Ltd. HiSilicon Embedded DMA Engine
+-[0000:6f]-+-00.0  Huawei Technologies Co., Ltd. Device a12d
|           +-01.0  Huawei Technologies Co., Ltd. Device a12e
|           +-08.0  Huawei Technologies Co., Ltd. Device a12d
|           +-09.0  Huawei Technologies Co., Ltd. Device a12e
|           \-0b.0  Huawei Technologies Co., Ltd. HiSilicon Embedded DMA Engine
+-[0000:70]-+-00.0-[71]--
|           +-01.0  Huawei Technologies Co., Ltd. Device a23c
|           +-03.0  Huawei Technologies Co., Ltd. Device a23d
|           \-04.0  Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA
+-[0000:72]-+-00.0-[73]--
|           +-01.0  Huawei Technologies Co., Ltd. Device a23c
|           +-03.0  Huawei Technologies Co., Ltd. Device a23d
|           \-04.0  Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA
+-[0000:74]---00.0-[75]--
+-[0000:76]---00.0-[77]--
+-[0000:78]-+-00.0-[79]--
|           +-01.0-[7a]--
|           +-08.0  Huawei Technologies Co., Ltd. Device a12d
|           \-09.0  Huawei Technologies Co., Ltd. Device a12e
+-[0000:7c]-+-00.0-[7d]--
|           +-01.0-[7e]--
|           +-08.0  Huawei Technologies Co., Ltd. Device a12d
|           \-09.0  Huawei Technologies Co., Ltd. Device a12e
+-[0000:80]-+-00.0-[81]----00.0  DERA Storage Device 1515
|           +-02.0-[82]----00.0  DERA Storage Device 1515
|           \-04.0-[83]----00.0  Broadcom / LSI MegaRAID 12GSAS/PCIe Secure SAS39xx
+-[0000:95]---00.0-[96]----00.0  Huawei Technologies Co., Ltd. Device d802###NPU
+-[0000:aa]---00.0-[ab]----00.0  Huawei Technologies Co., Ltd. Device d802###NPU
+-[0000:c0]---00.0-[c1]----00.0  Huawei Technologies Co., Ltd. Device d802###NPU
\-[0000:d5]---00.0-[d6]----00.0  Huawei Technologies Co., Ltd. Device d802###NPU
```bash
[root@bogon server_lab]#
CPU Root Complex
│
PCIe Root Port
│
PCIe Switch
│
```

设备
PCI bridge其实它们就是：PCIe Root Port
CPU → Root Port → PCIe Device
一个 Root Port 可以连接：NVMe、NIC、GPU、RAID

CPU
│
├─ PCIe Root Port 01
│   ├─ VGA (BMC)
│   ├─ Virtual NIC
│
├─ PCIe Root Port 34
│   └─ RDMA NIC (4 ports)
│
├─ PCIe Root Port 80
│   ├─ NVMe SSD
│   ├─ NVMe SSD
│   └─ RAID Controller
│
├─ PCIe Root Port 30 / 32 / 70 / 72
│   └─ SAS Controller
│
└─ PCIe Root Port 41 / 45 / 95 / AA / C0 / D5
└─ Accelerator devices

Watch查看CPU核心数、每一秒执行一次命令
watch 的作用：每秒执行一次命令、以后常用来监控：CPU、网络、IO
watch -n1 "cat /proc/interrupts"
```bash
[root@bogon server_lab]# watch -n 1 "cat /proc/cpuinfo | grep processor | wc -l"
Every 1.0s: cat /proc/cpuinfo | grep processor | wc -l        bogon: Mon Mar  9 12:28:12 2026
256
```

256逻辑CPU

Ctrl+c退出

3、查看Linux内存信息。
```bash
[root@bogon server_lab]# cat /proc/meminfo | head
MemTotal:       2111956928 kB
MemFree:        2106097672 kB
MemAvailable:   2100777804 kB
```

###2111956928 / 1024 / 1024 ≈ 2TB内存
Buffers:           78820 kB
Cached:           610068 kB
SwapCached:            0 kB
Active:           462952 kB
Inactive:         368536 kB
Active(anon):       4044 kB
Inactive(anon):   168288 kB
```bash
[root@bogon server_lab]#
```



```bash
[root@bogon ~]# nvme list
Node                  SN                   Model                                    Namespace Usage                      Format           FW Rev
--------------------- -------------------- ---------------------------------------- --------- -------------------------- ---------------- --------
/dev/nvme0n1          D77446D401J852       DERAP44YGM03T2US                         1           3.20  TB /   3.20  TB    512   B +  0 B   D7Y05M1F
/dev/nvme1n1          D77446D4017E52       DERAP44YGM03T2US                         1           3.20  TB /   3.20  TB    512   B +  0 B   D7Y05M1F
[root@bogon ~]# lsscsi
[0:1:124:0]  enclosu BROADCOM VirtualSES       03    -
[0:3:104:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sda
[0:3:105:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdc
[0:3:106:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdb
[0:3:107:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdd
[0:3:108:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sde
[0:3:109:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdh
[0:3:110:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdi
[0:3:111:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdj
[1:0:0:0]    disk    ATA      INTEL SSDSCKKB48 0100  /dev/sdg
[2:0:0:0]    disk    ATA      INTEL SSDSCKKB48 0100  /dev/sdf
[N:0:0:1]    disk    DERAP44YGM03T2US__1                        /dev/nvme0n1
[N:1:0:1]    disk    DERAP44YGM03T2US__1                        /dev/nvme1n1
[root@bogon ~]# lsblk -d
NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda       8:0    0 446.6G  0 disk
sdb       8:16   0 446.6G  0 disk
sdc       8:32   0 446.6G  0 disk
sdd       8:48   0 446.6G  0 disk
sde       8:64   0 446.6G  0 disk
sdf       8:80   0 447.1G  0 disk
sdg       8:96   0 447.1G  0 disk
sdh       8:112  0 446.6G  0 disk
sdi       8:128  0 446.6G  0 disk
sdj       8:144  0 446.6G  0 disk
nvme0n1 259:0    0   2.9T  0 disk
nvme1n1 259:1    0   2.9T  0 disk
CPU
│
├── PCIe
│    ├── NVMe SSD (M.2) 3.2TB
│    └── NVMe SSD (M.2) 3.2TB
│
├── SATA Controller
│    ├── SATA SSD 480GB
│    └── SATA SSD 480GB
│
└── RAID Controller
└── SAS SSD ×8
nvme0n1 不见了
```

排查思路
设备层
↓
PCIe层
↓
协议层
↓
日志层

## 硬件对照表

| Ethernet controller | 网卡 |
|---|---|


## 硬件对照表

| Non-Volatile memory | NVMe硬盘 |
|---|---|


## 硬件对照表

| VGA controller | GPU |
|---|---|

