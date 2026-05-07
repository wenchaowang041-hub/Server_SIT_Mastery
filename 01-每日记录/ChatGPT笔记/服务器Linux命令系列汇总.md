**服务器 Linux 命令系列**

全 6 篇完整汇总

JACK 的服务器笔记

*鲲鹏920 · 昇腾Atlas · 信创服务器测试实战*

**系列目录**

| **篇章** | **标题**             | **核心命令**                          |
|----------|----------------------|---------------------------------------|
| 第一篇   | Linux常用命令汇总    | ls / cd / grep / ps / df / systemctl  |
| 第二篇   | 硬件检测命令实战     | lscpu / lspci / dmidecode / nvme list |
| 第三篇   | 性能监控命令实战     | top / iostat / vmstat / mpstat        |
| 第四篇   | 日志排查命令实战     | dmesg / ipmitool sel / journalctl     |
| 第五篇   | 网络测试命令实战     | ping / ethtool / iperf3 / bond        |
| 第六篇   | 昇腾鲲鹏专项命令实战 | npu-smi / ascend-dmi / numactl        |

**第一篇 Linux常用命令汇总**

*服务器运维日常必备 · 从入门到熟练*

**一、文件与目录操作**

| **命令** | **说明**      | **常用示例**                    |
|----------|---------------|---------------------------------|
| ls       | 列出目录内容  | ls -la /root                    |
| cd       | 切换目录      | cd /var/log                     |
| pwd      | 显示当前路径  | pwd                             |
| mkdir    | 创建目录      | mkdir -p /root/server_lab       |
| cp       | 复制文件/目录 | cp -r src/ dst/                 |
| mv       | 移动/重命名   | mv old.txt new.txt              |
| rm       | 删除文件/目录 | rm -rf /tmp/test                |
| find     | 查找文件      | find / -name '\*.log'           |
| grep     | 文本搜索过滤  | grep -i error /var/log/messages |

**二、文件查看**

| **命令** | **说明**           | **常用示例**                 |
|----------|--------------------|------------------------------|
| cat      | 显示文件全部内容   | cat /etc/os-release          |
| head     | 显示前N行          | head -n 20 /var/log/messages |
| tail     | 显示后N行/实时追踪 | tail -f /var/log/messages    |
| less     | 分页查看           | less /var/log/messages       |
| wc       | 统计行数/字数      | wc -l /var/log/messages      |

**三、系统信息查看**

| **命令** | **说明**       | **常用示例** |
|----------|----------------|--------------|
| uname    | 系统和内核信息 | uname -a     |
| hostname | 主机名         | hostname     |
| uptime   | 运行时间/负载  | uptime       |
| date     | 系统时间       | date         |
| free     | 内存使用情况   | free -h      |
| nproc    | CPU核心数      | nproc        |

**四、进程管理**

| **命令** | **说明**         | **常用示例**          |
|----------|------------------|-----------------------|
| ps       | 查看进程快照     | ps aux \| grep stress |
| top      | 实时进程监控     | top                   |
| kill     | 发送信号终止进程 | kill -9 \<PID\>       |
| pkill    | 按名称杀进程     | pkill stress-ng       |
| nohup    | 后台持续运行     | nohup ./script.sh &   |

**五、磁盘与存储**

| **命令** | **说明**     | **常用示例**          |
|----------|--------------|-----------------------|
| df       | 磁盘使用情况 | df -h                 |
| du       | 目录占用空间 | du -sh /var/log       |
| lsblk    | 块设备列表   | lsblk -d              |
| mount    | 挂载信息     | mount \| grep nvme    |
| fdisk    | 分区管理查看 | fdisk -l /dev/nvme0n1 |

**六、网络基础命令**

| **命令** | **说明**     | **常用示例**               |
|----------|--------------|----------------------------|
| ip       | 网络接口信息 | ip a                       |
| ping     | 网络连通测试 | ping -c 4 192.168.1.1      |
| ss       | 网络连接状态 | ss -tuln                   |
| curl     | HTTP请求测试 | curl -I http://example.com |
| scp      | 远程文件传输 | scp file root@host:/tmp/   |

**七、软件包与服务管理**

> \# 软件包管理（openEuler / CentOS / 麒麟）
>
> yum install \<包名\>
>
> yum remove \<包名\>
>
> rpm -qa \| grep \<关键词\>
>
> \# 系统服务管理
>
> systemctl status sshd \# 查看状态
>
> systemctl start/stop/restart sshd \# 启动/停止/重启
>
> systemctl enable sshd \# 设置开机自启

**八、日志查看基础**

> \# 实时查看系统日志
>
> tail -f /var/log/messages
>
> \# 内核日志（带时间戳）
>
> dmesg -T \| tail -n 50
>
> \# 查看 systemd 日志
>
> journalctl -xe
>
> journalctl -u sshd --since '10 minutes ago'

**九、实战：拿到新服务器的第一步**

接手一台新服务器，建议按以下顺序快速摸清基本情况：

> \# 1. 确认OS版本和内核
>
> cat /etc/os-release
>
> uname -a
>
> \# 2. 确认CPU架构和核数
>
> lscpu \| grep -E 'Architecture\|CPU\\s\\\|Socket\|NUMA'
>
> \# 3. 确认内存总量
>
> free -h
>
> \# 4. 确认存储设备
>
> lsblk -d
>
> \# 5. 确认网络接口
>
> ip a
>
> \# 6. 确认系统运行状态
>
> uptime
>
> systemctl --failed

**第二篇 硬件检测命令实战**

*lscpu · lspci · dmidecode · nvme list · npu-smi*

**一、lscpu — CPU拓扑详情**

lscpu是查看CPU架构和拓扑最快的命令，是上机第一个要跑的命令。

> \[root@localhost ~\]# lscpu
>
> Architecture: aarch64
>
> CPU(s): 128
>
> Thread(s) per core: 1
>
> Core(s) per socket: 64
>
> Socket(s): 2
>
> NUMA node(s): 4
>
> Model name: Kunpeng-920
>
> CPU MHz: 2600.000
>
> NUMA node0 CPU(s): 0-31
>
> NUMA node1 CPU(s): 32-63
>
> NUMA node2 CPU(s): 64-95
>
> NUMA node3 CPU(s): 96-127

| **字段**              | **含义**                                    |
|-----------------------|---------------------------------------------|
| Architecture: aarch64 | ARM 64位架构（x86服务器显示x86_64）         |
| CPU(s): 128           | 逻辑CPU总数 = 2 Socket × 64 Core × 1 Thread |
| NUMA node(s): 4       | 4个NUMA节点，每节点32核，影响NPU/NVMe性能   |
| Thread(s) per core: 1 | 鲲鹏无超线程，每核1线程（Intel通常是2）     |

**二、lspci — PCIe设备全景**

lspci列出所有PCIe设备，一条命令看清服务器的整体硬件配置。

> \# 过滤关键设备类型
>
> \[root@localhost ~\]# lspci \| egrep -i 'Non-Volatile\|RAID\|Network\|Accelerat\|SATA\|SAS'
>
> 81:00.0 Non-Volatile memory controller: DERA Storage Device 1515
>
> 82:00.0 Non-Volatile memory controller: DERA Storage Device 1515
>
> 83:00.0 RAID bus controller: Broadcom / LSI MegaRAID 12GSAS/PCIe
>
> 38:05.0 SATA controller: Huawei HiSilicon AHCI HBA
>
> 35:00.0 Ethernet controller: Huawei HNS GE/10GE/25GE RDMA
>
> 08:00.0 Processing accelerators: Huawei Device d802 (rev 20)
>
> 0c:00.0 Processing accelerators: Huawei Device d802 (rev 20)

**▍ 查看PCIe链路速率（排查降速问题）**

> \[root@localhost ~\]# lspci -vv -s 81:00.0 \| grep -E 'LnkCap\|LnkSta'
>
> LnkCap: Port \#0, Speed 16GT/s, Width x4
>
> LnkSta: Speed 16GT/s (ok), Width x4 (ok)
>
> \# LnkCap=设备支持上限，LnkSta=实际协商速率
>
> \# 两者一致说明没有降速，Speed 16GT/s = PCIe Gen4
>
> *💡 LnkCap和LnkSta不一致（比如Cap是Gen4但Sta是Gen3）说明PCIe降速，会影响NVMe和NPU的实际性能，需要排查BIOS配置或信号质量。*

**三、dmidecode — SMBIOS硬件详情**

**▍ 查看内存规格**

> \[root@localhost ~\]# dmidecode -t memory
>
> Memory Device
>
> Locator: DIMM_A1
>
> Type: DDR4
>
> Speed: 3200 MT/s
>
> Manufacturer: Samsung
>
> Size: 32 GB
>
> Configured Memory Speed: 3200 MT/s

**▍ 查看BIOS版本**

> \[root@localhost ~\]# dmidecode -t bios
>
> BIOS Information
>
> Vendor: Huawei
>
> Version: 2.10
>
> Release Date: 2025/06/15

**▍ 查看整机序列号（资产信息）**

> \[root@localhost ~\]# ipmitool fru
>
> Board Manufacturer : Huawei
>
> Board Product Name : TaiShan 200 Pro
>
> Board Serial : 2102XXXXXXXX
>
> Product Serial : 2102XXXXXXXX

**四、存储设备识别命令组合**

> \# 1. 查看块设备全貌
>
> lsblk -d
>
> \# 2. 区分盘的来源（RAID逻辑盘/SATA直通/NVMe）
>
> lsscsi
>
> \# 3. NVMe盘详情（型号/容量/固件）
>
> nvme list
>
> \# 4. NVMe健康状态
>
> nvme smart-log /dev/nvme0n1 \| grep -E 'critical\|temp\|spare\|used\|errors'

**五、昇腾NPU检测**

> \# 查看NPU识别情况（PCIe层）
>
> lspci \| grep -i accelerat
>
> \# 查看NPU状态（需安装昇腾驱动）
>
> npu-smi info
>
> \# 查看NPU详细参数
>
> npu-smi info -t common

**六、硬件检测速查表**

| **检测目标**      | **推荐命令**               | **关键字段**                 |
|-------------------|----------------------------|------------------------------|
| CPU架构/核数/NUMA | lscpu                      | Architecture / CPU(s) / NUMA |
| 内存规格/频率     | dmidecode -t memory        | Speed / Size / Manufacturer  |
| PCIe设备清单      | lspci \| egrep -i '...'    | 设备类型/PCI地址             |
| PCIe链路速率      | lspci -vv -s \<addr\>      | LnkCap / LnkSta              |
| 存储设备识别      | lsblk -d + lsscsi          | NAME/SIZE/TYPE/来源控制器    |
| NVMe详情/健康     | nvme list + nvme smart-log | Model/FW/temp/errors         |
| NPU状态           | npu-smi info               | Temp/Power/Util              |
| BIOS版本          | dmidecode -t bios          | Version/Date                 |
| 整机序列号        | ipmitool fru               | Board Serial/Product Serial  |

**第三篇 性能监控命令实战**

*top · iostat · vmstat · mpstat · pidstat*

**一、top — 实时监控CPU和内存**

top是最常用的性能监控命令，实时显示系统CPU、内存使用情况以及各进程资源占用。

> \[root@localhost ~\]# top
>
> top - 14:32:10 up 2 days, 3:21, 2 users, load average: 2.45, 2.31, 2.18
>
> Tasks: 312 total, 2 running, 310 sleeping, 0 stopped, 0 zombie
>
> %Cpu(s): 85.3 us, 2.1 sy, 0.0 ni, 11.8 id, 0.5 wa, 0.0 hi, 0.3 si
>
> MiB Mem : 516096.0 total, 489234.0 free, 15234.0 used, 11628.0 buff/cache
>
> MiB Swap: 0.0 total, 0.0 free, 0.0 used. 499862.0 avail Mem
>
> PID USER PR NI VIRT RES SHR S %CPU %MEM TIME+ COMMAND
>
> 12345 root 20 0 512000 25600 4096 R 99.9 0.0 5:23.45 stress-ng
>
> 12346 root 20 0 512000 25600 4096 R 99.8 0.0 5:23.12 stress-ng

重点关注字段：

| **字段**     | **说明**                                      |
|--------------|-----------------------------------------------|
| load average | 系统1/5/15分钟平均负载，超过CPU核心数说明过载 |
| %Cpu us      | 用户态CPU占用率                               |
| %Cpu id      | CPU空闲率，压测时应接近0                      |
| %Cpu wa      | IO等待，偏高说明存储有瓶颈                    |
| MiB Mem      | 内存总量、空闲、已用                          |

**常用操作：**

> top -d 2 \# 每2秒刷新一次
>
> top -p 12345 \# 只监控指定PID进程
>
> \# 进入top后按1，展开显示每个CPU核心使用率
>
> \# 进入top后按M，按内存占用排序
>
> \# 进入top后按P，按CPU占用排序

**常见异常：**

- **load average持续远超CPU核心数** → 系统过载，进程排队等待CPU，需要排查是哪个进程占用过高

- **wa值持续偏高（\>20%）** → IO等待严重，存储可能有性能瓶颈或故障

- **id值接近100但业务跑不起来** → CPU不是瓶颈，问题可能在内存、网络或存储

- **zombie进程出现** → 有僵尸进程，需要排查父进程是否异常

**二、htop — top的增强版**

htop是top的增强版，界面更直观，支持鼠标操作，每个CPU核心单独显示，压测时一眼就能看出哪个核心跑满了。

> \# 安装htop
>
> yum install htop -y
>
> \# 运行htop
>
> \[root@localhost ~\]# htop

htop顶部会显示每个CPU核心的使用率进度条，压测时非常直观，建议作为top的日常替代工具。

**常见异常：**

- **部分核心跑满，部分核心空闲** → 压测工具没有绑定全部核心，检查压测命令是否指定了\$(nproc)

- **内存进度条接近满** → 内存压力过大，注意OOM风险

**三、iostat — 监控磁盘IO性能**

iostat用来查看磁盘读写性能，在存储测试和排查IO瓶颈时非常有用。

> \[root@localhost ~\]# iostat -x 2 3
>
> Linux 4.19.90 (localhost) 03/02/2025 \_aarch64\_ (128 CPU)
>
> Device r/s w/s rkB/s wkB/s rrqm/s wrqm/s %rrqm %wrqm r_await w_await aqu-sz rareq-sz wareq-sz svctm %util
>
> sda 0.50 125.30 8.00 5234.00 0.00 12.50 0.00 9.08 0.85 2.34 0.29 16.00 41.77 0.18 2.30
>
> nvme0n1 150.20 320.50 12032.00 25640.00 0.00 0.00 0.00 0.00 0.12 0.08 0.06 80.11 80.00 0.05 2.35

重点关注字段：

| **字段**         | **说明**                           |
|------------------|------------------------------------|
| r/s、w/s         | 每秒读写次数（IOPS）               |
| rkB/s、wkB/s     | 每秒读写带宽                       |
| r_await、w_await | 读写平均响应时间（ms），越低越好   |
| %util            | 磁盘利用率，接近100%说明磁盘跑满   |
| aqu-sz           | 平均队列深度，持续偏高说明IO压力大 |

**常用命令：**

> iostat -x 2 \# 每2秒刷新，显示详细信息
>
> iostat -x 2 5 \# 每2秒刷新，共显示5次
>
> iostat -d nvme0n1 \# 只监控指定磁盘

**常见异常：**

- **%util持续接近100%** → 磁盘跑满，IO瓶颈，考虑更换更高性能存储或检查硬盘健康状态

- **r_await或w_await异常高（\>100ms）** → 磁盘响应慢，可能是硬盘老化或RAID配置问题

- **rkB/s和wkB/s远低于标称值** → 存储性能不达标，需要深入排查

**四、vmstat — 查看系统整体状态**

vmstat提供系统整体视角，包括CPU、内存、IO、进程等综合信息，适合快速判断系统瓶颈在哪里。

> \[root@localhost ~\]# vmstat 2 5
>
> procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
>
> r b swpd free buff cache si so bi bo in cs us sy id wa st
>
> 2 0 0 501234 12345 234567 0 0 5 125 234 456 85 2 12 1 0
>
> 3 0 0 500234 12345 234567 0 0 0 234 256 478 87 2 10 1 0
>
> 1 0 0 499234 12345 234567 0 0 0 128 212 432 83 2 14 1 0

重点关注字段：

| **字段** | **说明**                                    |
|----------|---------------------------------------------|
| r        | 等待运行的进程数，持续大于CPU核心数说明过载 |
| b        | 处于不可中断睡眠的进程数，偏高说明IO阻塞    |
| swpd     | 使用的swap空间，服务器正常应为0             |
| si、so   | swap换入换出速率，不为0说明内存不足         |
| wa       | IO等待CPU占比                               |
| us、sy   | 用户态和内核态CPU占比                       |

**常用命令：**

> vmstat 2 \# 每2秒刷新
>
> vmstat 2 10 \# 每2秒刷新，共10次
>
> vmstat -m \# 查看内存slab信息

**常见异常：**

- **swpd不为0且si/so持续增加** → 内存严重不足，系统开始使用swap，性能会大幅下降

- **r值持续远大于CPU核心数** → CPU严重过载

- **b值持续偏高** → IO阻塞严重，结合iostat进一步定位是哪块磁盘有问题

- **sy值异常高（\>30%）** → 内核态开销过大，可能有驱动问题或系统调用异常

**五、组合使用技巧**

压测时建议多个命令配合使用，同时收集日志：

> \# 终端1：实时看CPU和内存
>
> htop
>
> \# 终端2：实时看磁盘IO
>
> iostat -x 2
>
> \# 终端3：收集vmstat日志
>
> vmstat 5 \>\> vmstat_log.txt
>
> \# 终端4：收集温度日志
>
> watch -n 5 'ipmitool sensor list \| grep -i temp' \>\> temp_log.txt

这样压测结束后，既有实时观察记录，也有完整的日志文件可以事后分析。

**六、总结**

四个命令各有侧重：

- **top/htop** — 实时看CPU和内存使用率，定位高占用进程

- **iostat** — 专注磁盘IO性能，排查存储瓶颈

- **vmstat** — 系统整体视角，快速判断瓶颈在CPU、内存还是IO

遇到性能异常时，建议先用vmstat快速判断瓶颈方向，再用top或iostat深入定位具体问题。

下一篇我们聊**日志排查命令详解**，结合实际故障案例讲解如何用日志定位问题，敬请期待！

**第四篇 日志排查命令实战**

*dmesg · ipmitool sel · journalctl · 案例实战*

**一、日志排查的重要性**

在服务器测试工作中，日志是定位问题最重要的手段。遇到硬件异常、设备识别问题、测试中断等情况，第一步就是查日志。

> *💡 ：每次跑测试之前，先清空dmesg和SEL日志，确保测试结束后日志里全是本次测试产生的内容，排查问题不会被旧日志干扰。*

**二、dmesg — 内核日志**

dmesg记录了系统内核运行时的所有事件，包括硬件识别、驱动加载、设备报错等，是硬件测试中最常用的日志工具。

**测试前清空dmesg：**

> \[root@localhost ~\]# dmesg -c
>
> \# 清空当前dmesg日志，-c表示清空并打印
>
> \# 清空后跑测试，日志更干净

**查看dmesg日志：**

> \# 查看全部dmesg日志
>
> \[root@localhost ~\]# dmesg
>
> \# 过滤错误日志
>
> \[root@localhost ~\]# dmesg \| grep -i error
>
> \# 过滤警告日志
>
> \[root@localhost ~\]# dmesg \| grep -i warning
>
> \# 实时监控dmesg（类似tail -f）
>
> \[root@localhost ~\]# dmesg -w
>
> \# 保存dmesg日志到文件
>
> \[root@localhost ~\]# dmesg \> dmesg_log.txt

**实际案例：网卡识别异常排查**

在测试过程中遇到过网卡识别异常的情况，dmesg里会出现hns3相关报错：

> \[root@localhost ~\]# dmesg \| grep -i hns3
>
> \[ 3.256789\] hns3 0000:01:00.0: firmware version: 1.8.0.12
>
> \[ 3.512345\] hns3 0000:01:00.0: fail to initialize hw, ret = -110
>
> \[ 3.513456\] hns3 0000:01:00.0: probe with driver hns3 failed with error -110
>
> \# hns3是华为网卡驱动，出现probe failed说明网卡初始化失败

排查步骤：

> \# 第一步：确认网卡是否被系统识别
>
> \[root@localhost ~\]# lspci \| grep -i network
>
> 0000:01:00.0 Network controller: Huawei Technologies Co., Ltd. HNS GE/10GE/25GE
>
> \# 第二步：查看网卡详细报错
>
> \[root@localhost ~\]# dmesg \| grep -i hns3
>
> \# 根据报错信息判断是驱动问题还是硬件问题
>
> \# 第三步：检查驱动是否正常加载
>
> \[root@localhost ~\]# lsmod \| grep hns3
>
> hns3 204800 0
>
> hclge 458752 1 hns3
>
> hnae3 49152 2 hns3,hclge
>
> \# 第四步：尝试重新加载驱动
>
> \[root@localhost ~\]# rmmod hns3
>
> \[root@localhost ~\]# modprobe hns3
>
> \[root@localhost ~\]# dmesg \| grep -i hns3
>
> \# 查看重新加载后是否恢复正常
>
> *💡 ：hns3网卡识别异常通常和驱动版本或固件版本有关，遇到这类问题先查dmesg确认报错类型，再考虑更新驱动或固件版本。*

**三、ipmitool sel — BMC事件日志**

SEL（System Event Log）是BMC记录的系统事件日志，记录了硬件层面的所有重要事件，包括电源操作、温度告警、硬件故障等。

**测试前清空SEL日志：**

> \[root@localhost ~\]# ipmitool sel clear
>
> Clearing SEL buffer ... done
>
> \# 和dmesg一样，测试前先清空，保证日志干净

**查看SEL日志：**

> \# 查看所有SEL事件
>
> \[root@localhost ~\]# ipmitool sel list
>
> 1 \| 03/04/2026 09:12:34 \| Power Unit \| Power off/down \| Asserted
>
> 2 \| 03/04/2026 09:12:45 \| Power Unit \| Power on \| Asserted
>
> 3 \| 03/04/2026 09:13:02 \| Processor \| IERR \| Asserted
>
> 4 \| 03/04/2026 09:15:23 \| Memory \| Correctable ECC \| Asserted
>
> 5 \| 03/04/2026 09:18:45 \| Fan \| Fan failure \| Asserted
>
> \# 查看SEL日志条目数量
>
> \[root@localhost ~\]# ipmitool sel info
>
> SEL Information
>
> Version : 1.5 (v1.5, v2 compliant)
>
> Entries : 5
>
> Free Space : 16384 bytes

**实际案例一：验证power cycle是否执行成功**

power cycle（重启上下电）是测试中常见操作，通过SEL日志可以验证执行是否正常：

> \# 执行power cycle
>
> \[root@localhost ~\]# ipmitool power cycle
>
> \# 服务器重启后查看SEL日志
>
> \[root@localhost ~\]# ipmitool sel list
>
> 1 \| 03/04/2026 10:00:01 \| Power Unit \| Power off/down \| Asserted
>
> 2 \| 03/04/2026 10:00:03 \| Power Unit \| AC lost \| Asserted
>
> 3 \| 03/04/2026 10:00:15 \| Power Unit \| Power on \| Asserted
>
> \# Power off和Power on都有记录，说明power cycle执行正常

**实际案例二：验证DC间隔时间**

通过SEL日志可以精确计算DC上下电的间隔时间：

> \[root@localhost ~\]# ipmitool sel list
>
> 1 \| 03/04/2026 10:00:01 \| Power Unit \| Power off/down \| Asserted
>
> 2 \| 03/04/2026 10:00:15 \| Power Unit \| Power on \| Asserted
>
> \# Power off时间10:00:01，Power on时间10:00:15
>
> \# DC间隔时间 = 14秒，确认是否符合规格要求

**常见SEL事件说明：**

| **事件**          | **说明**                     |
|-------------------|------------------------------|
| Power off/down    | 服务器下电                   |
| Power on          | 服务器上电                   |
| AC lost           | 交流电源丢失                 |
| Correctable ECC   | 内存可纠正错误               |
| Uncorrectable ECC | 内存不可纠正错误，需更换内存 |
| Fan failure       | 风扇故障                     |
| Temperature       | 温度告警                     |
| IERR              | CPU内部错误                  |

**四、journalctl — 系统服务日志**

journalctl是systemd的日志查看工具，记录了系统服务、启动过程、应用程序等日志，比/var/log/messages更全面。

> \# 查看所有系统日志
>
> \[root@localhost ~\]# journalctl
>
> \# 查看最新日志（类似tail）
>
> \[root@localhost ~\]# journalctl -e
>
> \# 实时监控日志
>
> \[root@localhost ~\]# journalctl -f
>
> \# 查看本次启动的日志
>
> \[root@localhost ~\]# journalctl -b
>
> \# 查看指定服务的日志
>
> \[root@localhost ~\]# journalctl -u NetworkManager
>
> \# 过滤错误级别日志
>
> \[root@localhost ~\]# journalctl -p err
>
> \# 查看指定时间段的日志
>
> \[root@localhost ~\]# journalctl --since "2026-03-04 09:00:00" --until "2026-03-04 10:00:00"

**五、/var/log/messages — 系统消息日志**

/var/log/messages记录了系统运行时的各类消息，包括内核消息、系统服务消息等。

> \# 查看系统日志
>
> \[root@localhost ~\]# cat /var/log/messages
>
> \# 实时监控系统日志
>
> \[root@localhost ~\]# tail -f /var/log/messages
>
> \# 搜索关键词
>
> \[root@localhost ~\]# grep -i error /var/log/messages
>
> \[root@localhost ~\]# grep -i hns3 /var/log/messages
>
> \# 查看最后100行
>
> \[root@localhost ~\]# tail -n 100 /var/log/messages

**六、日志排查综合流程**

测试标准流程建议如下：

**测试前：**

> \# 清空dmesg
>
> dmesg -c
>
> \# 清空SEL日志
>
> ipmitool sel clear

**测试中：**

> \# 实时监控dmesg有无报错
>
> dmesg -w
>
> \# 实时监控系统日志
>
> tail -f /var/log/messages

**测试后：**

> \# 保存dmesg日志
>
> dmesg \> dmesg\_\$(date +%Y%m%d\_%H%M%S).txt
>
> \# 保存SEL日志
>
> ipmitool sel list \> sel\_\$(date +%Y%m%d\_%H%M%S).txt
>
> \# 检查关键报错
>
> dmesg \| grep -i error
>
> dmesg \| grep -i warning
>
> ipmitool sel list \| grep -i fail

**七、总结**

日志排查核心工具：

- **dmesg** — 内核硬件日志，测试前先清空，测试后检查报错

- **ipmitool sel** — BMC事件日志，验证power cycle、DC间隔时间，查看硬件告警

- **journalctl** — 系统服务日志，排查服务启动和运行问题

- **/var/log/messages** — 系统消息日志，综合排查系统异常

养成测试前清空日志、测试后保存归档的习惯，遇到问题排查效率会大幅提升。

下一篇我们聊**网络测试命令详解**，包括ethtool、iperf3实战用法，敬请期待！

**第五篇 网络测试命令实战**

*ping · ethtool · iperf3 · Bond · 25GbE实测*

**一、ping — 测试网络连通性**

ping是最基础的网络测试命令，用来验证两台服务器之间网络是否连通。

> \# 基本ping测试
>
> \[root@localhost ~\]# ping 192.168.1.100
>
> PING 192.168.1.100 (192.168.1.100) 56(84) bytes of data.
>
> 64 bytes from 192.168.1.100: icmp_seq=1 ttl=64 time=0.312 ms
>
> 64 bytes from 192.168.1.100: icmp_seq=2 ttl=64 time=0.298 ms
>
> 64 bytes from 192.168.1.100: icmp_seq=3 ttl=64 time=0.301 ms
>
> \# 指定ping次数
>
> \[root@localhost ~\]# ping -c 10 192.168.1.100
>
> \# 指定包大小（测试大包传输）
>
> \[root@localhost ~\]# ping -s 8192 192.168.1.100
>
> \# 持续ping并记录日志
>
> \[root@localhost ~\]# ping 192.168.1.100 \>\> ping_log.txt

重点关注字段：

| **字段**    | **说明**               |
|-------------|------------------------|
| time        | 往返延迟，越低越好     |
| ttl         | 生存时间，判断网络跳数 |
| packet loss | 丢包率，正常应为0%     |

**常见异常：**

- **ping不通** → 检查网线、IP配置、防火墙

- **丢包率不为0** → 网络质量差，检查网线或交换机端口

- **延迟异常高** → 网络拥塞或链路质量问题

**二、ethtool — 查看网卡状态和速率**

ethtool用来查看和配置网卡的链路状态、速率、驱动信息等，是网卡测试中最常用的工具。

> \# 查看网卡基本信息
>
> \[root@localhost ~\]# ethtool eth0
>
> Settings for eth0:
>
> Supported ports: \[ FIBRE \]
>
> Speed: 25000Mb/s
>
> Duplex: Full
>
> Auto-negotiation: on
>
> Port: FIBRE
>
> Link detected: yes
>
> \# 查看网卡驱动信息
>
> \[root@localhost ~\]# ethtool -i eth0
>
> driver: hns3
>
> version: 1.9.40.0
>
> firmware-version: 1.8.0.12
>
> bus-info: 0000:01:00.0
>
> \# 查看网卡统计信息
>
> \[root@localhost ~\]# ethtool -S eth0
>
> NIC statistics:
>
> rx_packets: 1234567
>
> tx_packets: 987654
>
> rx_bytes: 1234567890
>
> tx_bytes: 987654321
>
> rx_errors: 0
>
> tx_errors: 0
>
> rx_dropped: 0
>
> tx_dropped: 0
>
> \# rx_errors和tx_errors不为0说明有网络错误

重点关注字段：

| **字段**              | **说明**                     |
|-----------------------|------------------------------|
| Speed                 | 链路速率，确认是否达到标称值 |
| Link detected         | yes正常，no表示链路断开      |
| rx_errors/tx_errors   | 收发错误包数，正常应为0      |
| rx_dropped/tx_dropped | 丢包数，正常应为0            |

**三、iperf/iperf3 — 测试网络带宽**

iperf3是测试网络实际带宽最常用的工具，需要一台服务器作为服务端，另一台作为客户端。

**1. 基本带宽测试**

> \# 服务端启动
>
> \[root@server ~\]# iperf3 -s
>
> -----------------------------------------------------------
>
> Server listening on 5201
>
> -----------------------------------------------------------
>
> \# 客户端发起测试，跑60秒
>
> \[root@client ~\]# iperf3 -c 192.168.1.100 -t 60
>
> Connecting to host 192.168.1.100, port 5201
>
> \[ ID\] Interval Transfer Bitrate Retr
>
> \[ 5\] 0.00-60.00 sec 172 GBytes 24.7 Gbits/sec 0 sender
>
> \[ 5\] 0.00-60.00 sec 172 GBytes 24.7 Gbits/sec receiver
>
> \# 25GbE网卡实测带宽24.7Gbps，达成率接近99%，正常

**2. 多线程测试（提升带宽利用率）**

> \[root@client ~\]# iperf3 -c 192.168.1.100 -t 60 -P 4
>
> \[SUM\] 0.00-60.00 sec 175 GBytes 25.1 Gbits/sec 0
>
> \# -P 4 表示4个并行线程，更充分利用带宽

**3. Bond4双口聚合测试**

> \[root@client ~\]# iperf3 -c 192.168.1.100 -t 60 -P 8
>
> \# Bond4两个口叠加，理论50GbE，用多线程测试
>
> \[SUM\] 0.00-60.00 sec 336 GBytes 48.3 Gbits/sec
>
> \# 实测48.3Gbps，接近理论值50GbE，正常

**4. 双向测试**

> \[root@client ~\]# iperf3 -c 192.168.1.100 -t 60 --bidir
>
> \# 同时测试上行和下行带宽
>
> \[ 5\]\[TX-C\] 0.00-60.00 sec 172 GBytes 24.7 Gbits/sec 0 sender
>
> \[ 7\]\[RX-C\] 0.00-60.00 sec 171 GBytes 24.6 Gbits/sec receiver

**5. UDP测试**

> \[root@client ~\]# iperf3 -c 192.168.1.100 -u -b 10G -t 60
>
> \[ 5\] 0.00-60.00 sec 172 GBytes 24.7 Gbits/sec 0.023 ms 0/125890 (0%)
>
> \# 0/125890 (0%) 表示无丢包，正常

**iperf3输出重点关注：**

| **字段** | **说明**                  |
|----------|---------------------------|
| Bitrate  | 实际带宽，是否达到标称值  |
| Retr     | 重传次数，不为0说明有丢包 |
| Transfer | 总传输数据量              |

**四、Bond链路聚合**

Bond是将多个网口绑定在一起的技术，可以提升带宽和冗余。服务器测试中常用的有Bond1和Bond4两种模式。

**Bond1（Active-Backup，主备模式）：**

- 同一时间只有一个网口在工作，另一个备用

- 主网口故障时自动切换到备用网口

- 带宽不叠加，仍然是单口速率

- 主要用途是保障网络冗余，防止单点故障

**Bond4（802.3ad LACP，链路聚合模式）：**

- 多个网口同时工作，带宽叠加

- 比如两个25GbE口做Bond4，理论带宽达到50GbE

- 同时也有冗余保障，一个口故障不影响整体

- 需要交换机也支持LACP协议配合

**简单对比：**

| **模式** | **带宽** | **冗余** | **适用场景**               |
|----------|----------|----------|----------------------------|
| Bond1    | 不叠加   | ✅       | 对冗余要求高，带宽要求不高 |
| Bond4    | 叠加     | ✅       | 既要高带宽又要冗余         |

**查看Bond状态：**

> \[root@localhost ~\]# cat /proc/net/bonding/bond0
>
> Ethernet Channel Bonding Driver: v3.7.1
>
> Bonding Mode: IEEE 802.3ad Dynamic link aggregation
>
> MII Status: up
>
> Active Aggregator Info:
>
> Aggregator ID: 1
>
> Number of ports: 2
>
> Slave Interface: eth0
>
> MII Status: up
>
> Speed: 25000 Mbps
>
> Duplex: full
>
> Slave Interface: eth1
>
> MII Status: up
>
> Speed: 25000 Mbps
>
> Duplex: full
>
> \# 两个口都是up，说明Bond4正常工作

**五、常见问题及排查**

**网络带宽跑不上去**

这是网络测试中最常见的问题，排查思路：

**第一步：确认链路速率是否正常**

> \[root@localhost ~\]# ethtool eth0 \| grep Speed
>
> Speed: 25000Mb/s
>
> \# 如果只有1000Mb/s，说明链路协商有问题
>
> \# 检查光模块是否匹配、交换机端口配置是否正确

**第二步：确认链路是否有错误包**

> \[root@localhost ~\]# ethtool -S eth0 \| grep -i error
>
> rx_errors: 0
>
> tx_errors: 0
>
> \# 有错误包说明链路质量差，检查网线或光纤

**第三步：排除CPU瓶颈**

> \# 测试时同时查看CPU使用率
>
> \[root@localhost ~\]# top
>
> \# 如果CPU已经跑满，带宽上不去是CPU瓶颈，用多线程测试
>
> \[root@client ~\]# iperf3 -c 192.168.1.100 -t 60 -P 8

**第四步：检查网卡中断绑核**

> \# 查看网卡中断分配
>
> \[root@localhost ~\]# cat /proc/interrupts \| grep eth0
>
> \# 如果所有中断都在同一个CPU核心，会导致带宽瓶颈
>
> \# 可以用irqbalance自动均衡中断
>
> \[root@localhost ~\]# systemctl start irqbalance

**第五步：查看dmesg日志**

> \[root@localhost ~\]# dmesg \| grep -i hns3
>
> \# 确认网卡驱动有无报错
>
> \# 如果有报错考虑更新驱动或固件版本

**第六步：检查Bond配置**

> \# 如果是Bond4聚合口带宽上不去
>
> \[root@localhost ~\]# cat /proc/net/bonding/bond0
>
> \# 确认两个slave口都是up状态
>
> \# 确认交换机开启了LACP

**六、测试时需要记录的数据**

| **指标**     | **说明**                   |
|--------------|----------------------------|
| 链路速率     | ethtool确认是否达到标称值  |
| 单口实测带宽 | iperf3跑分，达成率是否正常 |
| 重传次数     | Retr是否为0                |
| 错误包数     | rx_errors/tx_errors是否为0 |
| 丢包率       | UDP测试丢包率是否为0       |

**七、组合使用技巧**

网络测试时建议多个命令配合使用：

> \# 终端1：跑iperf3带宽测试
>
> iperf3 -c 192.168.1.100 -t 300 -P 4 \| tee iperf_log.txt
>
> \# 终端2：实时监控网卡错误包
>
> watch -n 2 'ethtool -S eth0 \| grep -i error'
>
> \# 终端3：监控CPU使用率
>
> top
>
> \# 终端4：监控网卡流量
>
> watch -n 1 'ip -s link show eth0'

**八、总结**

网络测试核心三步：**ping确认连通 → ethtool确认速率 → iperf3测试带宽**。遇到带宽跑不上去，按照链路速率、错误包、CPU瓶颈、中断绑核、驱动固件的顺序逐步排查，基本能定位到问题所在。

下一篇我们聊**昇腾鲲鹏专项命令实战**，结合实际测试经验深入讲解，敬请期待！

**第六篇 昇腾鲲鹏专项命令实战**

*npu-smi · ascend-dmi · numactl · 信创测试规范*

**一、npu-smi — 昇腾NPU管理工具**

npu-smi是昇腾NPU的专用管理工具，功能类似NVIDIA的nvidia-smi，用于查看NPU状态、温度、利用率、驱动版本等。

**▍ 查看NPU总览**

> \[root@localhost ~\]# npu-smi info
>
> +-------------------------------------------------------+
>
> \| npu-smi 25.5.0 Driver: 25.5.0 \|
>
> +---------------------------+---------------------------+
>
> \| NPU Name \| Bus-Id \|
>
> \| Firmware Version \| NPU-Util \|
>
> +===========================+===========================+
>
> \| 0 910B \| 0000:08:00.0 \|
>
> \| 7.8.0.5.216 \| 0% \|
>
> +---------------------------+---------------------------+
>
> \| 1 910B \| 0000:0c:00.0 \|
>
> \| 7.8.0.5.216 \| 0% \|
>
> +===========================+===========================+

**▍ 查看所有NPU详细参数**

> \[root@localhost ~\]# npu-smi info -t common
>
> NPU ID Chip ID Temp(C) Power(W) Freq(MHz) Util(%) Mem Used(MiB) Mem Total(MiB)
>
> 0 0 48 68 1000 0 512 32768
>
> 1 0 47 67 1000 0 512 32768
>
> 2 0 49 69 1000 0 512 32768
>
> 3 0 48 68 1000 0 512 32768

| **字段**      | **说明**      | **参考阈值**                   |
|---------------|---------------|--------------------------------|
| Temp(C)       | NPU芯片温度   | 正常 \< 80℃，超过90℃告警       |
| Power(W)      | NPU实时功耗   | Atlas 300I空载约40W，满载约75W |
| Freq(MHz)     | 工作频率      | 1000 MHz为标称值，降频说明过热 |
| Util(%)       | NPU计算利用率 | 压测时应接近100%               |
| Mem Used(MiB) | 已用HBM显存   | 根据业务负载变化               |

**▍ 实时监控所有NPU**

> \# 每2秒刷新所有NPU状态
>
> npu-smi info -d 2
>
> \# 监控指定卡（卡号0）
>
> npu-smi info -i 0
>
> \# 查看NPU错误日志
>
> npu-smi info -t error

**二、ascend-dmi — NPU算力压测**

ascend-dmi是昇腾专用的NPU算力验收工具，测试NPU实际算力是否达到标称值。

**▍ 单卡INT8精度压测**

> \[root@localhost ~\]# ascend-dmi -f -d 0 -t int8 --et 60
>
> ======== Ascend DMI Compute Performance Test ========
>
> Device ID: 0 \| Compute Type: INT8 \| Duration: 60s
>
> Performance Result:
>
> Achieved TOPS: 558.164
>
> Theoretical TOPS: 576
>
> Achievement Rate: 97.0%

**▍ 单卡FP16精度压测**

> \[root@localhost ~\]# ascend-dmi -f -d 0 -t fp16 --et 60
>
> Achieved TFLOPS: 287.563
>
> Theoretical TFLOPS: 288
>
> Achievement Rate: 99.0%

**▍ 8张卡批量压测脚本**

> \# 8张NPU同时压测INT8，结果分别保存
>
> for i in {0..7}; do
>
> ascend-dmi -f -d \$i -t int8 --et 60 \| tee card\${i}\_int8.txt &
>
> done
>
> wait
>
> \# 汇总所有卡的达成率
>
> grep 'Achievement Rate' card\*.txt

| **精度类型** | **理论算力（Atlas 300I）** | **实测结果**   | **达成率** |
|--------------|----------------------------|----------------|------------|
| INT8         | 576 TOPS                   | 558.164 TOPS   | 97%        |
| FP16         | 288 TFLOPS                 | 287.563 TFLOPS | 99%        |

> *💡 达成率低于95%需要排查：NPU温度过高导致降频、PCIe Gen4链路是否降速、驱动或固件版本是否匹配。*

**三、鲲鹏平台专项命令**

**▍ STREAM内存带宽测试**

> \[root@localhost ~\]# gcc -O3 -fopenmp stream.c -o stream
>
> \[root@localhost ~\]# OMP_NUM_THREADS=128 ./stream
>
> Function Best Rate MB/s Avg time Min time
>
> Copy: 185432.3 0.008658 0.008628
>
> Triad: 198756.2 0.012065 0.012074
>
> \# 重点看Triad综合带宽

**▍ NUMA绑定执行**

> \# 绑定进程到NUMA节点0运行（CPU和内存都本地）
>
> numactl --cpunodebind=0 --membind=0 ./workload
>
> \# 查看NUMA拓扑距离
>
> numactl --hardware
>
> \# 查看进程NUMA内存统计
>
> numastat -p \<PID\>

**▍ 查看设备NUMA归属**

> \# 查看NVMe盘的NUMA节点
>
> cat /sys/bus/pci/devices/0000:81:00.0/numa_node
>
> \# 查看NPU的NUMA节点
>
> cat /sys/bus/pci/devices/0000:08:00.0/numa_node
>
> \# 批量查看所有NPU NUMA归属
>
> for dev in \$(lspci \| grep -i accelerat \| awk '{print \$1}'); do
>
> echo "\$dev: \$(cat /sys/bus/pci/devices/0000:\${dev}/numa_node 2\>/dev/null)"
>
> done

**四、信创测试标准操作规范**

每次测试前后都要按规范操作，确保测试数据的可重现性和可追溯性：

**▍ 测试前准备**

> \# 1. 清空内核日志（避免历史信息干扰）
>
> dmesg -c
>
> \# 2. 清空BMC事件日志
>
> ipmitool sel clear
>
> \# 3. 确认所有NPU状态正常
>
> npu-smi info
>
> \# 4. 记录环境基线
>
> lscpu \> baseline_cpu.txt
>
> free -h \> baseline_mem.txt
>
> ipmitool sensor list \> baseline_sensor.txt

**▍ 测试后归档**

> \# 保存内核日志
>
> dmesg \> dmesg\_\$(date +%Y%m%d\_%H%M%S).txt
>
> \# 保存BMC事件日志
>
> ipmitool sel list \> sel\_\$(date +%Y%m%d\_%H%M%S).txt
>
> \# 保存NPU状态
>
> npu-smi info \> npu\_\$(date +%Y%m%d\_%H%M%S).txt

**五、常用命令快速参考**

| **场景**     | **命令**                         | **说明**              |
|--------------|----------------------------------|-----------------------|
| 查看NPU状态  | npu-smi info                     | 温度/功耗/利用率总览  |
| NPU算力验收  | ascend-dmi -f -d 0 -t int8       | 测试INT8达成率        |
| 内存带宽测试 | ./stream                         | 重点看Triad值         |
| NUMA绑定执行 | numactl --cpunodebind=0 cmd      | 避免跨NUMA性能损失    |
| 查设备NUMA   | cat /sys/bus/pci/.../numa_node   | 确认NPU/NVMe NUMA归属 |
| 清空日志     | dmesg -c && ipmitool sel clear   | 测试前标准操作        |
| 归档日志     | dmesg \> dmesg\_\$(date +%s).txt | 测试后标准操作        |
