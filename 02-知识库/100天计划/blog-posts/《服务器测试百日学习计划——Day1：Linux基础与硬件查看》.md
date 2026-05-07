---

**《服务器测试百日学习计划——Day1：Linux基础与硬件查看》**

**前言**

大家好，我是JACK，服务器硬件测试工程师。从今天开始记录我的百日学习计划，把每天的学习内容整理成文章，既是自己的学习记录，也希望对同样在学习服务器测试的朋友有帮助。

**Day1主要内容：Linux终端基础、查看服务器硬件、查看系统状态、查看系统日志、Python入门、拓展实验。**

---

**一、Linux终端基础**

**1. pwd — 查看当前路径**
```bash
[root@bogon ~]# pwd
/root
```

**2. ls — 查看目录内容**
```bash
[root@bogon ~]# ls
anaconda-ks.cfg  ascend  dmesg.log  sel.log  stress_logs ...

# 查看详细信息（权限、用户、大小、时间）
[root@bogon ~]# ls -l
总用量 1243456
-rw-------. 1 root root       707 2月 12 11:52 anaconda-ks.cfg
drwxr-x---. 4 root root      4096 2月 12 16:37 ascend
-rwxr-xr-x. 1 root root 1104308866 2月 12 13:55 Ascend-cann-toolkit_8.5.0_linux-aarch64.run
-rw-r--r--. 1 root root    278141 3月  6 17:52 dmesg.log
-rw-r--r--. 1 root root     28450 3月  6 17:55 sel.log
```

**3. cd — 切换目录**
```bash
[root@bogon ~]# cd /var/log/
[root@bogon log]# pwd
/var/log
[root@bogon log]# cd ~     # 回到home目录
[root@bogon ~]#
```

**4. mkdir — 创建文件夹**
```bash
[root@bogon ~]# mkdir server_lab
[root@bogon ~]# cd server_lab/
[root@bogon server_lab]#
```

**5. touch — 创建文件**
```bash
[root@bogon server_lab]# touch test.txt
[root@bogon server_lab]# ls
test.txt
```

**6. cp — 复制文件**
```bash
[root@bogon server_lab]# cp test.txt test2.txt
[root@bogon server_lab]# ls
test2.txt  test.txt
```

**7. rm — 删除文件**
```bash
[root@bogon server_lab]# rm test2.txt
rm：是否删除普通空文件 'test2.txt'？y
[root@bogon server_lab]# ls
test.txt
```

**Linux基础命令总结：**

| 命令 | 作用 |
|------|------|
| pwd | 查看当前路径 |
| ls | 查看目录内容 |
| ls -l | 查看详细信息（权限、用户、大小、时间） |
| cd | 切换目录 |
| mkdir | 创建目录 |
| touch | 创建文件 |
| cp | 复制文件 |
| rm | 删除文件 |

---

**二、查看服务器硬件**

**1. 查看CPU — lscpu**

重点关注CPU(s)、Model name、Socket数、每核线程数：

```bash
[root@bogon server_lab]# lscpu
架构：             aarch64
CPU 运行模式：     64-bit
CPU:               256
在线 CPU 列表：    0-255
厂商 ID：          HiSilicon
BIOS Model name:   Kunpeng 920 7260Z
每个核的线程数：   2
每个座的核数：     64
座：               2
CPU 最大 MHz：     2600.0000
CPU 最小 MHz：     400.0000
NUMA 节点：        4
NUMA 节点0 CPU：   0-63
NUMA 节点1 CPU：   64-127
NUMA 节点2 CPU：   128-191
NUMA 节点3 CPU：   192-255
Caches:
  L1d:             8 MiB (128 instances)
  L1i:             8 MiB (128 instances)
  L2:              160 MiB (128 instances)
  L3:              224 MiB (4 instances)
```

> 💡 **解读**：2颗CPU × 每颗64核 × 每核2线程 = 256逻辑CPU，双路鲲鹏920服务器，4个NUMA节点。

**2. 查看内存 — free -h**

```bash
[root@bogon server_lab]# free -h
              total        used        free      shared  buff/cache   available
Mem:          2.0Ti        10Gi       2.0Ti        28Mi       915Mi       2.0Ti
Swap:         4.0Gi          0B       4.0Gi
```

**3. 查看磁盘 — lsblk**

```bash
[root@bogon server_lab]# lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda           8:0    0 446.6G  0 disk
sdb           8:16   0 446.6G  0 disk
sdc           8:32   0 446.6G  0 disk
sdd           8:48   0 446.6G  0 disk
sde           8:64   0 446.6G  0 disk
sdf           8:80   0 447.1G  0 disk
sdg           8:96   0 447.1G  0 disk
sdh           8:112  0 446.6G  0 disk
sdi           8:128  0 446.6G  0 disk
sdj           8:144  0 446.6G  0 disk
nvme1n1     259:0    0   2.9T  0 disk
├─nvme1n1p1            600M       /boot/efi
├─nvme1n1p2              1G       /boot
└─nvme1n1p3            2.9T
  ├─openeuler-root      70G       /
  ├─openeuler-swap       4G       [SWAP]
  └─openeuler-home     2.8T       /home
nvme0n1     259:1    0   2.9T  0 disk
```

> 💡 **lsblk说明**：列出系统中所有块设备，包括硬盘、分区、RAID等。如果NVMe SSD消失，可能是硬件故障、驱动问题或设备连接问题。

用nvme list查看NVMe硬盘详情：

```bash
[root@bogon ~]# nvme list
Node         SN               Model              Namespace  Usage                Format    FW Rev
/dev/nvme0n1 D77446D401J852   DERAP44YGM03T2US   1          3.20 TB / 3.20 TB   512 B     D7Y05M1F
/dev/nvme1n1 D77446D4017E52   DERAP44YGM03T2US   1          3.20 TB / 3.20 TB   512 B     D7Y05M1F
```

用lsscsi查看所有SCSI/SAS/SATA/NVMe设备：

```bash
[root@bogon ~]# lsscsi
[0:1:124:0]  enclosu  BROADCOM  VirtualSES           03    -
[0:3:104:0]  disk     BROADCOM  MR9560-16i           5.29  /dev/sda
[0:3:105:0]  disk     BROADCOM  MR9560-16i           5.29  /dev/sdc
[0:3:106:0]  disk     BROADCOM  MR9560-16i           5.29  /dev/sdb
[0:3:107:0]  disk     BROADCOM  MR9560-16i           5.29  /dev/sdd
[0:3:108:0]  disk     BROADCOM  MR9560-16i           5.29  /dev/sde
[0:3:109:0]  disk     BROADCOM  MR9560-16i           5.29  /dev/sdh
[0:3:110:0]  disk     BROADCOM  MR9560-16i           5.29  /dev/sdi
[0:3:111:0]  disk     BROADCOM  MR9560-16i           5.29  /dev/sdj
[1:0:0:0]    disk     ATA       INTEL SSDSCKKB48     0100  /dev/sdg
[2:0:0:0]    disk     ATA       INTEL SSDSCKKB48     0100  /dev/sdf
[N:0:0:1]    disk     DERAP44YGM03T2US__1             -    /dev/nvme0n1
[N:1:0:1]    disk     DERAP44YGM03T2US__1             -    /dev/nvme1n1
```

**存储架构拓扑：**
```
CPU
├── PCIe → NVMe SSD (M.2) 3.2TB × 2    # NVMe通过PCIe x4直连CPU
├── SATA Controller → SATA SSD 480GB × 2
└── RAID Controller → SAS SSD 446GB × 8
```

**NVMe消失四层排查法：**
```
设备层  → lsblk               # 系统是否识别
PCIe层  → lspci               # PCIe总线是否识别
协议层  → lsmod | grep nvme   # 驱动是否加载
日志层  → dmesg | grep nvme   # 内核是否有报错
```

**4. 查看PCIe设备 — lspci**

lspci列出系统中所有PCIe设备，通过设备类型可以快速识别各硬件：

```bash
[root@bogon server_lab]# lspci
# BMC管理芯片（远程控制、KVM、硬件监控、IPMI）
02:00.0 VGA compatible controller: Huawei Hi171x [iBMC w/VGA support]

# 网卡（4个口，支持10/25/50GbE RDMA）
35:00.0 Ethernet controller: Huawei HNS GE/10GE/25GE/50GE RDMA Network Controller
35:00.1 Ethernet controller: Huawei HNS GE/10GE/25GE/50GE RDMA Network Controller
35:00.2 Ethernet controller: Huawei HNS GE/10GE/25GE/50GE RDMA Network Controller
35:00.3 Ethernet controller: Huawei HNS GE/10GE/25GE/50GE RDMA Network Controller

# NVMe（NVMe = PCIe协议存储设备，通过PCIe x4连接CPU）
81:00.0 Non-Volatile memory controller: DERA Storage Device 1515
82:00.0 Non-Volatile memory controller: DERA Storage Device 1515

# RAID卡
83:00.0 RAID bus controller: Broadcom/LSI MegaRAID 12GSAS/PCIe Secure SAS39xx

# NPU加速卡 × 8
08:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802
0c:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802
42:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802
46:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802
96:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802
ab:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802
c1:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802
d6:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802
```

常见PCIe设备类型对照：

| 设备类型 | 说明 |
|---------|------|
| Ethernet controller | 网卡 |
| Non-Volatile memory controller | NVMe硬盘 |
| Processing accelerators | GPU/NPU加速卡 |
| RAID bus controller | RAID卡 |
| VGA compatible controller | 显卡/BMC管理芯片 |

> 💡 **PCI bridge = PCIe Root Port**，CPU通过Root Port连接各PCIe设备：`CPU → Root Port → PCIe Device`，一个Root Port可以连接NVMe、NIC、GPU、RAID等设备。

**本台服务器硬件汇总：**

| 硬件 | 规格 |
|------|------|
| CPU | 鲲鹏920 × 2，共256逻辑核 |
| 内存 | 2TB |
| NVMe SSD | 3.2TB × 2（M.2接口） |
| SAS HDD | 446GB × 8（RAID卡管理） |
| SATA SSD | 480GB × 2 |
| RDMA NIC | 4口（10/25/50GbE） |
| RAID卡 | Broadcom MegaRAID |
| NPU | 华为加速卡 × 8 |
| BMC | 华为iBMC |

---

**三、查看系统状态**

**1. top — 查看系统进程**

```bash
[root@bogon server_lab]# top
top - 12:09:39 up 2 days, 21:05, 1 user, load average: 8.00, 8.00, 8.00
Tasks: 2701 total,   1 running, 2700 sleeping
%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni, 100.0 id,  0.0 wa
MiB Mem:  2062458 total, 2056736 free,  10918 used,    918 buff/cache
MiB Swap:    4096 total,    4096 free,      0 used

  PID USER   PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+   COMMAND
 6950 root   20   0   82628   5436   1832 S   2.0   0.0  53:42.46  irqbalance
15836 root   20   0   30568   8160   3016 R   1.3   0.0   0:00.25  top
```

> 💡 **解读**：id=100%说明CPU完全空闲；load average=8对256核CPU完全正常；按**q**退出top。

---

**四、查看系统日志 — dmesg**

```bash
# 查看最早的内核启动日志
[root@bogon server_lab]# dmesg | head
[    0.000000] Booting Linux on physical CPU 0x0300000000 [0x480fd020]
[    0.000000] Linux version 5.10.0-216.0.0.115.oe2203sp4.aarch64
[    0.000000] efi: EFI v2.70 by EDK II
[    0.000000] ACPI: RSDP 0x000000005FFE0018 000024 (v02 HISI)

# 查看最新的内核日志
[root@bogon server_lab]# dmesg | tail
[  3605.501349] usb 1-1: New USB device found, idVendor=12d1
[  3605.518927] usb 1-1: Product: Keyboard/Mouse KVM 2.0
[  3605.565264] input: Keyboard/Mouse KVM 2.0 as /devices/...
```

---

**五、Python3入门**

服务器测试中Python非常有用，可以用来写自动化脚本：

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

---

**六、拓展实验**

**1. 查看PCIe拓扑结构 — lspci -tv**

```bash
[root@bogon server_lab]# lspci -tv
-+-[0000:00]-
 +-[0000:01]-+-00.0-[02]----00.0 Huawei Hi171x [iBMC+VGA]   # BMC管理芯片
 |           +-01.0-[03]----00.0 iBMA Virtual Network Adapter
 +-[0000:07]----00.0-[08]----00.0 Huawei Device d802         # NPU
 +-[0000:0b]----00.0-[0c]----00.0 Huawei Device d802         # NPU
 +-[0000:34]-+-00.0-[35]-+-00.0 HNS RDMA Network Controller  # 网卡
 |           |           +-00.1 HNS RDMA Network Controller
 |           |           +-00.2 HNS RDMA Network Controller
 |           |           \-00.3 HNS RDMA Network Controller  # 4个网口
 +-[0000:41]----00.0-[42]----00.0 Huawei Device d802         # NPU
 +-[0000:45]----00.0-[46]----00.0 Huawei Device d802         # NPU
 +-[0000:80]-+-00.0-[81]----00.0 DERA Storage Device 1515    # NVMe
 |           +-02.0-[82]----00.0 DERA Storage Device 1515    # NVMe
 |           \-04.0-[83]----00.0 Broadcom MegaRAID           # RAID卡
 +-[0000:95]----00.0-[96]----00.0 Huawei Device d802         # NPU
 +-[0000:aa]----00.0-[ab]----00.0 Huawei Device d802         # NPU
 +-[0000:c0]----00.0-[c1]----00.0 Huawei Device d802         # NPU
 \-[0000:d5]----00.0-[d6]----00.0 Huawei Device d802         # NPU
```

完整PCIe拓扑图：

```
CPU
├── PCIe Root Port 01
│   ├── BMC + VGA（远程控制、KVM、IPMI）
│   └── Virtual NIC
├── PCIe Root Port 34
│   └── RDMA NIC（4个网口，支持10/25/50GbE）
├── PCIe Root Port 80
│   ├── NVMe SSD 3.2TB（M.2）
│   ├── NVMe SSD 3.2TB（M.2）
│   └── RAID Controller
├── PCIe Root Port 30/32/70/72
│   └── SAS Controller × 4
└── PCIe Root Port 41/45/95/AA/C0/D5
    └── NPU加速卡 × 8
```

**2. watch — 每秒刷新执行命令**

watch的作用：每隔指定时间执行一次命令，常用来监控CPU、网络、IO：

```bash
# 每1秒查看一次CPU逻辑核心数
[root@bogon server_lab]# watch -n 1 "cat /proc/cpuinfo | grep processor | wc -l"
Every 1.0s: cat /proc/cpuinfo | grep processor | wc -l    bogon: Mon Mar 9 12:28:12 2026
256
# Ctrl+C退出
```

**3. 查看内存详细信息 — /proc/meminfo**

```bash
[root@bogon server_lab]# cat /proc/meminfo | head
MemTotal:       2111956928 kB
MemFree:        2106097672 kB
MemAvailable:   2100777804 kB
# 2111956928 / 1024 / 1024 ≈ 2TB内存
Buffers:          78820 kB
Cached:          610068 kB
SwapCached:           0 kB
Active:          462952 kB
Inactive:        368536 kB
```

**4. 查看磁盘详情组合命令**

```bash
# 只显示磁盘不显示分区
[root@bogon ~]# lsblk -d
NAME      MAJ:MIN RM   SIZE RO TYPE
sda         8:0    0 446.6G  0 disk
sdb         8:16   0 446.6G  0 disk
sdc         8:32   0 446.6G  0 disk
sdd         8:48   0 446.6G  0 disk
sde         8:64   0 446.6G  0 disk
sdf         8:80   0 447.1G  0 disk
sdg         8:96   0 447.1G  0 disk
sdh         8:112  0 446.6G  0 disk
sdi         8:128  0 446.6G  0 disk
sdj         8:144  0 446.6G  0 disk
nvme0n1   259:0    0   2.9T  0 disk
nvme1n1   259:1    0   2.9T  0 disk
```

---

**Day1总结**

今天主要学习了：
- Linux基础命令（pwd、ls、cd、mkdir、touch、cp、rm）
- 查看服务器硬件（lscpu、free、lsblk、lsblk -d、nvme list、lsscsi、lspci、lspci -tv）
- 查看系统状态（top）
- 查看系统日志（dmesg）
- Python3基础入门
- 拓展实验（lspci -tv拓扑、watch、/proc/meminfo、lsblk -d）

**核心收获：**
- lspci能看到所有PCIe设备，NVMe是PCIe设备所以也在里面
- NVMe消失排查四层法：设备层→PCIe层→协议层→日志层
- PCIe拓扑通过lspci -tv可以清晰看到CPU→Root Port→设备的完整连接关系
- watch命令可以实时监控任何命令的输出，非常实用

明天继续！如果这篇文章对你有帮助，欢迎**点赞、收藏、关注**，百日学习计划持续更新，不迷路！

欢迎关注**JACK的服务器笔记**！

---

