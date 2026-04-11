Day7：RAID 控制器、逻辑盘、物理盘、盘位映射与故障定位
这一天学完，你要真正做到三件事：
看懂一台服务器里“控制器—物理盘—逻辑盘—OS 设备”的关系
能区分 直通盘 / JBOD / RAID 逻辑盘
遇到坏盘、掉盘、重建慢、系统看不到盘时，知道从哪一层开始查
操作系统看到的盘，不一定是真实物理盘。
物理盘 → 控制器 → RAID组 → 逻辑盘 → Linux块设备

### 先把存储分层重新立住

你现在要把服务器存储看成 4 层：
第1层：物理介质层
真正插在机器里的盘：
SAS SSD / SAS HDD
SATA SSD / SATA HDD
NVMe SSD
这里关注的是：
盘是否在
盘健康是否异常
盘插在哪个槽位
盘走哪条链路
型号、容量、sn、盘位slot、健康状态、


第2层：控制器层
负责管理盘的“中间大脑”：
RAID 卡
HBA 卡？是？
主板直连控制器
主板集成存储控制器
NVMe 背板/PCIe Root Port/PCIe Switch（NVMe通常不是传统RAID卡那套）
这里关注的是：
控制器型号
控制器是否识别到盘
盘是直通还是被纳入 RAID
cache / policy / rebuild / patrol read 等状态
控制器负责识别物理盘、决定盘是直通还是raid
管理cache、策略、重建、告警、
你环境里要特别记住这件事：
2U 华为服务器：华为 SP686 RAID，工具是 hiraidadm
6U 服务器：Broadcom RAID，不能再按华为工具链讲，要走 Broadcom 工具链
这点以后不能混。

第3层：逻辑卷层
RAID 卡把多个物理盘抽象成：
逻辑盘
虚拟盘
Volume / VD / LD
例如：
2块盘做raid1
4 块 SATA SSD 做 RAID5
OS 里可能只看到 1 块逻辑盘
这时操作系统看到的并不是底下 4 块真实盘，而是 RAID 卡给出的“虚拟块设备”。

第4层：操作系统设备层Linux Block Device
Linux 里看到的是：
/dev/sda
/dev/sdb
/dev/mapper/...
/dev/nvme0n1
这里关注的是：
系统是否识别
分区/文件系统是否正常
I/O 性能是否异常
和上层逻辑盘、下层物理盘如何对应

### 你必须彻底分清的三个概念

这是现场最容易混的。
1）物理盘（PD, Physical Drive）
真实存在的盘。
例如一块 SAS SSD 插在槽位 3。
你关心：
型号
SN
容量
盘位Slot
Media type
状态：Online / Offline / Failed / Rebuild

2）逻辑盘（LD/VD, Logical Drive / Virtual Drive）
RAID 控制器组合出来给 OS 用的“盘”。
例如：
槽位 0、1 两块盘做 RAID1
最后 OS 只看到一个 /dev/sda
这时 /dev/sda 对应的不是某一块物理盘，而是一个逻辑盘。

3）JBOD / 直通
控制器识别到盘，但不做 RAID 聚合，直接把单盘暴露给 OS。
效果上：
每块物理盘通常对应一个 OS 设备
但仍然可能经过 RAID/HBA 控制器
所以“系统看到单盘”不一定意味着它是主板直连，也可能是控制器直通模式。

### 你要建立的核心映射关系

今天最重要的不是命令，而是这张脑图：
物理槽位 Slot → 物理盘 PD → RAID组/Array → 逻辑盘 LD/VD → Linux块设备 /dev/sdX
你以后查问题，必须能顺着这条链走，也能逆着这条链走。
例如：
业务说 /dev/sdb I/O 错误
你要能往下找到：
它属于哪个逻辑盘
逻辑盘底下有哪些物理盘
哪个槽位那块盘在报错
再比如：
机房说 “5号槽位亮黄灯”
你要能往上找到：
这块物理盘属于哪个阵列、哪个raid组、
对应哪个逻辑盘
OS 上可能影响哪个设备
当前业务会不会受影响
RAID
RAID 常见工作模式，你先建立直觉
1）RAID0
条带化
提升性能
不容错
任意一块盘坏，整个逻辑盘可能挂

2）RAID1
镜像
两块盘常见
容错较强
常用于系统盘
3）RAID5
条带 + 奇偶校验
常见于多盘数据盘
坏 1 块还能撑住
性能和容量折中
4）RAID10
镜像 + 条带
性能和可靠性通常更好
成本高一些

物理盘常见状态
Online：在线正常、正常参与阵列
Offline：离线
Failed：故障、坏盘或者已被剔除
Rebuild：重建中、替换盘正在补数据
Hot Spare：热备盘、备用盘、阵列异常时可能自动顶上
Unconfigured Good：未配置但可用
Foreign：带外来配置、这盘可能以前在别的控制器或别的阵列里用过，插进来后控制器发现它带旧配置
Missing：缺失
逻辑盘常见状态
Optimal：正常、阵列当前正常
Degraded：降级、阵列还没彻底挂、但已经有风险
比如raid1/5/10有一块成员盘坏了或者掉了
Degraded 不是“还能用就没事”，而是“已经出故障了，但暂时还能撑”。
Rebuilding：重建中
Failed：逻辑盘失效
Offline：逻辑盘离线

### Linux 侧先做什么

先从 OS 看到的设备入手。
1）看块设备
lsblk
看：
设备名
有哪些盘
大小
分区
挂载点
想一想现在os看到了几块盘？哪块像系统盘、哪块像数据盘？是不是raid逻辑盘

2）看 SCSI 设备
lsscsi
你会看到类似：
[2:0:0:0] disk ATA      SATA SSD ... /dev/sda
[3:0:1:0] disk HGST     SAS SSD  ... /dev/sdb
作用：
帮你知道这是走 SCSI 栈暴露出来的设备
SAS/SATA 盘通常更适合这里观察
看到设备类型、厂商、型号、映射到那个/dev/sdx

3）看存储控制器
lspci | egrep -i 'raid|sas|scsi|storage'
你要识别：
有没有 RAID 控制器
是华为 SP686 还是 Broadcom/LSI 系列
系统看到的盘是不是由它暴露出来

4）看内核日志
dmesg -T | egrep -i 'sd[a-z]|scsi|sas|raid|error|fail|reset'
当盘异常时，这里经常先出现：
link down
medium error
I/O error
reset
abort
timeout

### RAID 现场最关键的状态词

你在控制器工具里经常会看到这些词，必须秒懂。
物理盘常见状态
Online：正常在线
Offline：离线
Unconfigured Good：未配置但可用
Failed：故障
Rebuild：重建中
Hot Spare：热备盘
Foreign：外来配置，可能是从别的机器/控制器插过来的盘
Missing：缺失

逻辑盘常见状态
Optimal：阵列正常
Degraded：降级，说明有成员盘有问题，但阵列还没彻底挂
Rebuilding：重建中
Failed：逻辑盘已失效
Offline：逻辑盘离线

### 你环境里的两套工具链怎么理解

这里先讲方法，不死背命令。
A. 2U 华为服务器：SP686 + hiraidadm
这一套你要重点看：
控制器信息
逻辑盘列表
物理盘列表
盘位信息
重建状态
Cache/Policy
你的目标不是只会敲命令，而是看完输出能回答：
有几个控制器
有几个逻辑盘
每个逻辑盘由哪些物理盘组成
哪个槽位盘异常
当前阵列是不是 degraded
有没有热备盘
是否正在 rebuild

B. 6U 服务器：Broadcom RAID 工具链
这套和华为不能混讲。
Broadcom 一般常见的是 MegaRAID/StorCLI 那类思路。你要关注的对象一样：
Controller
Virtual Drive / Logical Drive
Physical Drive
Enclosure / Slot
DG / VD / PD 对应关系
Foreign / Rebuild / Patrol Read / Cache Policy
不要求你今天把两套工具的全部命令背下来，但你必须建立一个意识：
品牌不同，命令不同；但排障对象和层次几乎一样。
也就是：
找控制器
找逻辑盘
找物理盘
找槽位
做映射
看状态


### 你今天必须学会的排障路径

这是 Day7 最重要的实战能力。
场景1：系统里少了一块盘
比如昨天 lsblk 还有 /dev/sdb，今天没了。
排查顺序：
第一步：OS 层确认
lsblk
lsscsi
dmesg -T | tail -n 100
看是不是：
设备彻底消失
只是分区没挂载
内核在报错重置
第二步：控制器层确认
查 RAID/HBA 工具输出，看：
控制器是否还能看到该物理盘
盘状态是不是 Failed / Missing / Offline
逻辑盘是否 Degraded
第三步：物理层确认
结合盘位槽位：
哪个 Slot 异常
指示灯状态
重新插拔后是否恢复
是否是背板/线缆/供电问题
判断是单盘坏、掉盘、控制器问题、背板问题、阵列问题

场景2：逻辑盘还在，但性能突然很差
可能现象：
业务卡顿
iostat 里 await 很高
吞吐低
先查：
iostat -x 1
再结合控制器看：
是否有盘在重建
是否阵列 degraded
是否 cache policy 变化
是否某块盘出现 media error / predictive failure
这里你要形成一个结论：
RAID 阵列“没挂”不等于“没问题”。
只要 degraded/rebuild，性能往往就已经明显受影响。

场景3：新插了盘，系统没看到
这个非常常见。
不要直接下结论“盘坏了”，要按层排：

lspci 看控制器在不在
控制器工具看新盘是否识别
新盘是：
Unconfigured Good
Foreign
Hot Spare
被自动纳入某逻辑盘
如果是 RAID 模式，OS 不一定直接看到物理盘
还要区分是 SAS/SATA 盘还是 NVMe 盘，因为路径不同

### 今天你要真正吃透的几个“误区”

误区1：OS 里只有一块盘，就说明机器里只有一块盘
错。
可能是：
多块物理盘组成一个 RAID 逻辑盘
OS 只看到逻辑盘

误区2：系统看不到盘，就是盘坏了
错。
还可能是：
控制器没识别
盘被 foreign 配置锁住
盘在 RAID 卡后面未直通
背板/线缆/供电异常
控制器故障

误区3：阵列还能用，就不用处理
错。
只要：
Degraded
Rebuild
Predictive Failure
Media Error 增长
就已经进入风险状态。
换了新盘就一定会恢复x
有的环境需要指定替换盘、清楚foreign
手动加入阵列
手动开始rebuild

误区4：NVMe 和 SAS/SATA RAID 排查路径完全一样
也错。
相同点：

都要分层看
都要找设备与物理位置映射
不同点：
NVMe 更多走 PCIe 路径
SAS/SATA 更强调 RAID/HBA/SCSI 栈
NVMe 常用 nvme list，SAS/SATA 常看 lsscsi 和 RAID 工具


### 今天的实操任务

你今天建议在测试机上自己完成这 4 个动作。
任务1：识别控制器
lspci | egrep -i 'raid|sas|scsi|storage'
你要回答：
这台机是华为 SP686 还是 Broadcom
有几个存储控制器
NVMe 是否走 RAID 卡

任务2：建立 OS 盘清单
lsblk
lsscsi
输出后自己写一张表：
关键不是表本身，而是“你对每块盘的来源有判断”。


任务3：用 RAID 工具看逻辑盘/物理盘
你的目标是拿到这些信息：
控制器编号
逻辑盘数量
每个逻辑盘状态
物理盘状态
槽位号
是否有 hot spare
是否 degraded/rebuild

任务4：做一张“存储路径图”
格式你可以这样写：
Controller0
├─ LogicalDrive0  RAID1  Optimal
│   ├─ Slot0  SATA SSD  Online
│   └─ Slot1  SATA SSD  Online
└─ LogicalDrive1  RAID5  Degraded
├─ Slot2  SAS SSD   Online
├─ Slot3  SAS SSD   Failed
├─ Slot4  SAS SSD   Online
└─ Slot5  SAS SSD   Online
OS:
/dev/sda -> LogicalDrive0
/dev/sdb -> LogicalDrive1
你只要能手工画出来，Day7 就算真正入门了。

### 面试/现场表达模板

以后别人问你“你怎么查 RAID 盘故障”，要这样答：
我会先把问题分成 OS 层、逻辑盘层、物理盘层和控制器层。
先用 lsblk、lsscsi、dmesg 看系统是否识别和是否有 I/O 报错；
再用 RAID 管理工具看逻辑盘状态是不是 Optimal/Degraded，确认物理盘是否 Online/Failed/Rebuild；
然后结合槽位号定位具体故障盘，判断是单盘故障、阵列降级、还是控制器/背板问题。
最后再把 OS 设备和逻辑盘、物理盘做映射，确认业务影响范围。
这个表达就已经比只会敲命令强很多。

### 今天的考核题

你自己先答，不要偷看。
题1
4 块盘做了 RAID5，OS 里一般看到几块盘？
答：通常看到 1 块逻辑盘，不是 4 块物理盘。

题2
一个物理盘 Failed，但业务暂时没挂，逻辑盘大概率是什么状态？
答：Degraded。

题3
系统没看到新插入的 SAS 盘，你第一反应应该是什么？
答：不是直接判盘坏，而是先分层确认：
OS 有没有识别
控制器有没有识别
盘是不是 foreign / unconfigured / hot spare
槽位/背板/线缆是否异常

题4
为什么 /dev/sda 不能简单等同于“某一个物理盘”？
答：因为它可能对应的是 RAID 控制器暴露出来的逻辑盘，而不是单独某块物理盘。

### Day7 结束标准

今天你达到以下标准，就算过关：
能说清物理盘、逻辑盘、JBOD 的区别
能解释为什么 OS 看到的盘不一定是真实物理盘
能按“OS → 控制器 → 逻辑盘 → 物理盘 → 槽位”去排查
能区分你们 2U 华为 hiraidadm 和 6U Broadcom 工具链不是一套

能手工画出一张存储映射图


### 给你的 Day7 作业

今晚直接做这一个输出：
《本机 RAID / 存储拓扑识别报告（Day7版）》
内容只写 5 段：
控制器型号与数量

OS 可见盘列表

逻辑盘状态
物理盘与槽位状态

一条你认为最可能的故障排查路径
你写完发我，我可以直接帮你逐行改，改成真正像系统工程师写的版本。
下一节我建议接 Day8：SAS / SATA 架构、HBA、Expander、背板与链路识别。



```bash
[root@bogon ~]# lspci
01:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
01:01.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
01:02.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
01:03.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
02:00.0 VGA compatible controller: Huawei Technologies Co., Ltd. Hi171x Series [iBMC Intelligent Management system chip w/VGA support] (rev 01)
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
35:00.3 Ethernet controller: Huawei Technologies Co., Ltd. HNS GE/10GE/25GE/50GE RDMA Network Controller (rev 30)
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
82:00.0 Non-Volatile memory controller: DERA Storage Device 1515
83:00.0 RAID bus controller: Broadcom / LSI MegaRAID 12GSAS/PCIe Secure SAS39xx
95:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
96:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
aa:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
ab:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
c0:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
c1:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
d5:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
d6:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
[root@bogon ~]# lsscsi
[0:1:124:0]  enclosu BROADCOM VirtualSES       03    -
[0:3:104:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdc
[0:3:105:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdd
[0:3:106:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sde
[0:3:107:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdf
[0:3:108:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdg
[0:3:109:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdh
[0:3:110:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdj
[0:3:111:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdi
[1:0:0:0]    disk    ATA      INTEL SSDSCKKB48 0100  /dev/sda
[2:0:0:0]    disk    ATA      INTEL SSDSCKKB48 0100  /dev/sdb
[N:0:0:1]    disk    DERAP44YGM03T2US__1                        /dev/nvme0n1
[N:1:0:1]    disk    DERAP44YGM03T2US__1                        /dev/nvme1n1
[root@bogon ~]# lsblk
NAME               MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda                  8:0    0 447.1G  0 disk
sdb                  8:16   0 447.1G  0 disk
sdc                  8:32   0 446.6G  0 disk
sdd                  8:48   0 446.6G  0 disk
sde                  8:64   0 446.6G  0 disk
sdf                  8:80   0 446.6G  0 disk
sdg                  8:96   0 446.6G  0 disk
sdh                  8:112  0 446.6G  0 disk
sdi                  8:128  0 446.6G  0 disk
sdj                  8:144  0 446.6G  0 disk
nvme0n1            259:0    0   2.9T  0 disk
├─nvme0n1p1        259:2    0   600M  0 part
├─nvme0n1p2        259:3    0     1G  0 part
└─nvme0n1p3        259:4    0   2.9T  0 part
├─klas-swap      253:2    0     4G  0 lvm
├─klas-backup    253:3    0    50G  0 lvm
└─klas-root      253:4    0   2.9T  0 lvm
nvme1n1            259:1    0   2.9T  0 disk
├─nvme1n1p1        259:5    0   600M  0 part /boot/efi
├─nvme1n1p2        259:6    0     1G  0 part /boot
└─nvme1n1p3        259:7    0   2.9T  0 part
├─openeuler-root 253:0    0    70G  0 lvm  /
├─openeuler-swap 253:1    0     4G  0 lvm  [SWAP]
└─openeuler-home 253:5    0   2.8T  0 lvm  /home
[root@bogon ~]# storcli64 -h
StorCli SAS Customization Utility Ver 007.2707.0000.0000 Dec 18, 2023
(c)Copyright 2023, Broadcom Inc. All Rights Reserved.
storcli -v
storcli [verbose] -h| -help| ?
storcli show
storcli show all
storcli show ctrlcount
storcli show file=<filepath>
storcli /cx add vd r[0|1|5|6|00|10|50|60]
[Size=<VD1_Sz>,<VD2_Sz>,..|remaining] [name=<VDNAME1>,..]
drives=[e:]s|[e:]s-x|[e:]s-x,y [PDperArray=x][SED]
[pdcache=on|off|default][pi][DimmerSwitch(ds)=default|automatic(auto)|
none|maximum(max)|MaximumWithoutCaching(maxnocache)][WT|WB|AWB][nora|ra]
[direct|cached] [cachevd] [unmap][Strip=<8|16|32|64|128|256|512|1024>]
[AfterVd=X] [EmulationType=0|1|2] [Spares = [e:]s|[e:]s-x|[e:]s-x,y]
[force][ExclusiveAccess] [Cbsize=0|1|2 Cbmode=0|1|2|3|4|7]
storcli /cx add vd each r0 [name=<VDNAME1>,..] [drives=[e:]s|[e:]s-x|[e:]s-x,y]|all
[SED] [pdcache=on|off|default][pi] [DimmerSwitch(ds)=default|
automatic(auto)|none|maximum(max)|MaximumWithoutCaching(maxnocache)]
[WT|WB|AWB] [nora|ra] [direct|cached] [EmulationType=0|1|2]
[Strip=<8|16|32|64|128|256|512|1024>] [ExclusiveAccess]
[Cbsize=0|1|2 Cbmode=0|1|2|3|4|7] [unmap]
storcli /cx add VD cachecade r[0|1|10]
drives = [e:]s|[e:]s-x|[e:]s-x,y [WT|WB] [assignvds = 0,1,2]
storcli /cx/ex show
storcli /cx/ex show all
storcli /cx/ex show status [extended]
storcli /cx/ex show phyerrorcounters
storcli /cx/ex set time=systemtime
storcli /cx/vx del [cachecade] [discardcache] [force]
storcli /cx delete config [force]
storcli /cx delete events
storcli /cx show events [ [type= <sincereboot| sinceshutdown| includedeleted|
latest=x| ccincon vd=<0,1,...>] [filter=<[info],[warning],[critical],[fatal]>]
[file=<filepath>] [logfile[=filename]] ]
storcli /cx show events [logfile[=filename]] ]
storcli /cx show eventcounters [type=sas|pcie]
storcli /cx delete eventcounters [type=sas|pcie]
storcli /cx show eventloginfo
storcli /cx delete securitykey
storcli /cx set securitykey useekms
storcli /cx set securitykey < =xxxxxxxx [passphrase=xxxx] [keyid=xxx] [VolatileKey=on|off] > | file=filename
storcli /cx set securitykey < keyid=xxx | file=filename >
storcli /cx compare securitykey <=xxxxxxxxxx | file=filename>
storcli /cx set termlog=on|off|offthisboot
storcli /cx show termlog [type=config|contents] [logfile[=filename]]
storcli /cx delete termlog
storcli /cx set securitykey <=xxxxxxxx oldsecuritykey=xxxxxxxx
[passphrase=xxxx] [keyid=xxx] [VolatileKey=on|off] > | file=filename
storcli /cx set sesmonitoring=on|off
storcli /cx show sesmonitoring
storcli /cx set failpdonsmarterror=on|off
storcli /cx show failpdonsmarterror
storcli /cx/dx show
storcli /cx/dall show cachecade
storcli /cx/dx show all
storcli /cx/dall show mirror
storcli /cx/dall split mirror
storcli /cx/dall add mirror src=<val> [force]
storcli /cx show freespace
storcli /cx/fall show [all] [securityKey = xxx]
storcli /cx/fall del|delete [securityKey = xxx]
storcli /cx/fall import [preview] [securityKey = xxx]
storcli /cx/vx set ssdcaching=on|off
storcli /cx/vx set hidden=on|off
storcli /cx/dx set hidden=on|off
storcli /cx/dx set security=on
storcli /cx/vx show expansion
storcli /cx/vx expand Size=<xx> [expandarray]
storcli /cx get vpd file=<fileName>
storcli /cx[/ex]/sx show
storcli /cx[/ex]/sx show all
storcli /cx[/ex]/sx start rebuild
storcli /cx start diag [duration=<val>]
storcli /cx[/ex]/sx stop rebuild
storcli /cx[/ex]/sx pause rebuild
storcli /cx[/ex]/sx resume rebuild
storcli /cx[/ex]/sx show rebuild
storcli /cx[/ex]/sx show poh [ignoreselftest]
storcli /cx[/ex]/sx show smart
storcli /cx[/ex]/sx start copyback target=e:s
storcli /cx[/ex]/sx stop copyback
storcli /cx[/ex]/sx pause copyback
storcli /cx[/ex]/sx resume copyback
storcli /cx[/ex]/sx reset phyerrorcounters
storcli /cx[/ex]/sx reset errorcounters type = 1|2
storcli /cx[/ex]/sx show copyback
storcli /cx[/ex]/sx show patrolread
storcli /cx[/ex]/sx show phyerrorcounters
storcli /cx[/ex]/sx show errorcounters
storcli /cx[/ex]/sx start initialization
storcli /cx[/ex]/sx stop initialization
storcli /cx[/ex]/sx show initialization
storcli /cx[/ex]/sx start locate
storcli /cx[/ex]/sx stop locate
storcli /cx[/ex]/sx show securitykey keyid
storcli /cx[/ex]/sx add hotsparedrive [DGs=<N|0,1,2...>] [enclaffinity]
storcli /cx[/ex]/sx delete hotsparedrive
storcli /cx[/ex]/sx spinup
storcli /cx[/ex]/sx spindown
storcli /cx[/ex]/sx set online
storcli /cx[/ex]/sx set offline
storcli /cx[/ex]/sx set missing
storcli /cx[/ex]/sx set jbod
storcli /cx[/ex]/sx set security=on
storcli /cx[/ex]/sx set good [force]
storcli /cx[/ex]/sx insert dg=A array=B row=C
storcli /cx/vx set emulationType=0|1|2
storcli /cx/vx set Unmap=<On|Off>
storcli /cx/vx show Unmap
storcli /cx/vx set cbsize=0|1|2 cbmode=0|1|2|3|4|7
storcli /cx/vx set wrcache=WT|WB|AWB
storcli /cx/vx set rdcache=RA|NoRA
storcli /cx/vx set iopolicy=Cached|Direct
storcli /cx/vx set accesspolicy=RW|RO|Blocked|RmvBlkd
storcli /cx/vx set pdcache=On|Off|Default
storcli /cx/vx set name=<NameString>
storcli /cx/vx set HostAccess=ExclusiveAccess|SharedAccess
storcli /cx/vx set ds=Default|Auto|None|Max|MaxNoCache
storcli /cx/vx set autobgi=On|Off
storcli /cx/vx set pi=Off
storcli /cx/vx show
storcli /cx/vx show all [logfile[=filename]]
storcli /cx/vx show init
storcli /cx/vx show cc|consistencycheck
storcli /cx/vx show erase
storcli /cx/vx show migrate
storcli /cx/vx show bgi
storcli /cx/vx show autobgi
storcli /cx set consistencycheck|cc[=off|seq|conc] [delay=value]
[starttime=yyyy/mm/dd hh] [excludevd=x-y,z|none]
storcli /cx show cc|consistencycheck
storcli /cx show ocr
storcli /cx set ocr=<on|off>
storcli /cx show sesmultipathcfg
storcli /cx set sesmultipathcfg=<on|off>
storcli /cx/vx start init [Full] [Force]
storcli /cx/vx start erase [simple|normal|thorough|standard] [patternA=<val>]
[patternB=<val>]
storcli /cx/vx start cc|consistencycheck [Force]
storcli /cx/vx start migrate type=raidx [option=add|remove
drives=[e:]s|[e:]s-x|[e:]s-x,y] [Force]
storcli /cx/vx stop init
storcli /cx/vx stop erase
storcli /cx/vx stop cc|consistencycheck
storcli /cx/vx stop bgi
storcli /cx/vx pause cc|consistencycheck
storcli /cx/vx pause bgi
storcli /cx/vx resume cc|consistencycheck
storcli /cx/vx resume bgi
storcli /cx show
storcli /cx show all [noASO] [logfile[=filename]]
storcli /cx show preservedcache
storcli /cx/vx delete preservedcache [force]
storcli /cx[/ex]/sx download src=<filepath> [satabridge] [mode= 5|7] [parallel [force]] [chunksize=<val>]
storcli /cx[/ex]/sx download status
storcli /cx/ex download src=<filepath> [ mode=5 | [forceActivate] mode=7] [bufferid=<val>] [chunksize=<val>]
storcli /cx/ex download src=<filepath> mode=e [offline] [forceActivate [delay=<val>]] [bufferid=<val>] [chunksize=<val>]
storcli /cx/ex download mode=f [offline] [delay=<val>] [bufferid=<val>]
storcli /cx[/ex]/sx download src=<filepath> mode= E [offline] [activatenow [delay=<val>] ] [chunksize=<val>]
storcli /cx[/ex]/sx download  mode= F [offline] [delay=<val>]
storcli /cx[/ex]/sx secureerase [force]
storcli /cx[/ex]/sx start erase [simple| normal| thorough | standard| threepass | crypto]
[patternA=<val>] [patternB=<val>]
storcli /cx[/ex]/sx start sanitize < cryptoerase| blockErase > [ause]
storcli /cx[/ex]/sx start sanitize overwrite [ause] [invert] [overwritecount=<val>]
[ patternA=<val> patternB=<val> patternC=<val> patternD=<val> ]
storcli /cx[/ex]/sx stop erase
storcli /cx[/ex]/sx show erase
storcli /cx[/ex]/sx show sanitize
storcli /cx[/ex]/sx show jbod
storcli /cx[/ex]/sx show jbod all
storcli /cx[/ex]/sx del jbod [force]
storcli /cx[/ex]/sx set bootdrive=<on|off>
storcli /cx/vx set bootdrive=<on|off>
storcli /cx show bootdrive
storcli /cx show bootwithpinnedcache
storcli /cx set bootwithpinnedcache=<on|off>
storcli /cx show activityforlocate
storcli /cx set activityforlocate=<on|off>
storcli /cx show copyback
storcli /cx set copyback=<on|off> type=ctrl|smartssd|smarthdd|all
storcli /cx show jbod
storcli /cx set jbod=<on|off> [force]
storcli /cx set autorebuild=<on|off>
storcli /cx set ldlimit=<default|max>
storcli /cx show autorebuild
storcli /cx set autoconfig [= < none | R0 [immediate] | JBOD > [usecurrent] ]
[[sesmgmt=on|off]  [securesed=on|off]
[multipath=on|off] [multiinit=on|off]
[discardpinnedcache=<Val>] [failPDOnReadME=on|off]
[Lowlatency=low|off]]
storcli /cx show autoconfig
storcli /cx show cachebypass
storcli /cx set cachebypass=<on|off>
storcli /cx show usefdeonlyencrypt
storcli /cx set usefdeonlyencrypt=<on|off>
storcli /cx show prcorrectunconfiguredareas
storcli /cx set prcorrectunconfiguredareas=<on|off>
storcli /cx show batterywarning
storcli /cx set batterywarning=<on|off>
storcli /cx show abortcconerror
storcli /cx set abortcconerror=<on|off>
storcli /cx show ncq
storcli /cx show configautobalance
storcli /cx set ncq=<on|off>
storcli /cx set configautobalance=<on|off>
storcli /cx show maintainpdfailhistory
storcli /cx set maintainpdfailhistory=<on|off>
storcli /cx show restorehotspare
storcli /cx set restorehotspare=<on|off>
storcli /cx set bios [state=<on|off>] [Mode=<SOE|PE|IE|SME>] [abs=<on|off>]
[DeviceExposure=<value>]
storcli /cx show bios
storcli /cx show alarm
storcli /cx set alarm=<on|off|silence>
storcli /cx show deviceorderbyfirmware
storcli /cx set deviceorderbyfirmware=<on|off>
storcli /cx show foreignautoimport
storcli /cx set foreignautoimport=<on|off>
storcli /cx show directpdmapping
storcli /cx set directpdmapping=<on|off>
storcli /cx show rebuildrate
storcli /cx set rebuildrate=<value>
storcli /cx show loadbalancemode
storcli /cx set loadbalancemode=<on|off>
storcli /cx show eghs
storcli /cx set eghs [state=<on|off>] [eug=<on|off>] [smarter=<on|off>]
storcli /cx show cacheflushint
storcli /cx set cacheflushint=<value>
storcli /cx show prrate
storcli /cx set prrate=<value>
storcli /cx show ccrate
storcli /cx set ccrate=<value>
storcli /cx show bgirate
storcli /cx set bgirate =<value>
storcli /cx show dpm
storcli /cx start dpm
storcli /cx stop dpm
storcli /cx[/ex]/sx show dpmstat type =  HIST | LCT | RA | EXT [logfile[=filename]]
storcli /cx delete dpmstat type =  Hist | LCT | RA | EXT | All
storcli /cx show sgpioforce
storcli /cx set sgpioforce =<on|off>
storcli /cx set supportssdpatrolread =<on|off>
storcli /cx show reconrate
storcli /cx set reconrate=<value>
storcli /cx show spinupdrivecount
storcli /cx show wbsupport
storcli /cx set spinupdrivecount=<value>
storcli /cx show spinupdelay
storcli /cx set spinupdelay=<value>
storcli /cx show coercion
storcli /cx set coercion=<value>
storcli /cx show limitMaxRateSATA
storcli /cx set limitMaxRateSATA=on|off
storcli /cx show HDDThermalPollInterval
storcli /cx set HDDThermalPollInterval=<value>
storcli /cx show SSDThermalPollInterval
storcli /cx set SSDThermalPollInterval=<value>
storcli /cx show smartpollinterval
storcli /cx set smartpollinterval=<value>
storcli /cx show eccbucketsize
storcli /cx set eccbucketsize=<value>
storcli /cx show eccbucketleakrate
storcli /cx set eccbucketleakrate=<value>
storcli /cx show backplane
storcli /cx set backplane mode=<value> expose=<on|off>
storcli /cx show perfmode
storcli /cx set perfmode=<value> [maxflushlines=<value> numiostoorder=<value>]
storcli /cx show perfmodevalues
storcli /cx show pi
storcli /cx set pi [state=<on|off>] [import=<on|off>]
storcli /cx show time
storcli /cx set time=<yyyymmdd hh:mm:ss | systemtime>
storcli /cx show ds
storcli /cx set ds=OFF type=1|2|3|4
storcli /cx set ds=ON type=1|2 [properties]
storcli /cx set ds=ON type=3|4 DefaultLdType=<val> [properties]
storcli /cx set ds [properties]
storcli /cx show safeid
storcli /cx show rehostinfo
storcli /cx show pci
storcli /cx show ASO
storcli /cx set aso key=<key value> preview
storcli /cx set aso key=<key value>
storcli /cx set aso transfertovault
storcli /cx set aso rehostcomplete
storcli /cx set aso deactivatetrialkey
storcli /cx set factory defaults
storcli /cx download file=<filepath> [noverchk] [noreset] [forcehcb] [force]
storcli /cx download file=<filepath> [fwtype=<val>] [ResetNow] [nosigchk]
[noverchk] [force] [forceclose]
storcli /cx flushcache
storcli /cx set sbr
storcli /cx/px show
storcli /cx/px show phyerrorcounters
storcli /cx/px show phyevents
storcli /cx/px show all
storcli /cx/lnx show
storcli /cx show linkconfig
storcli /cx set linkconfig [conname=cx,cy] configid=<val>
storcli /cx/px set linkspeed=0|1.5|3|6|12|22.5
storcli /cx/px set state=on|off
storcli /cx/px reset [hard | errorlog]
storcli /cx/lnx set lanespeed=2.5|5|8|16
storcli /cx/bbu show
storcli /cx/bbu show all
storcli /cx/bbu show status
storcli /cx/bbu show properties
storcli /cx/bbu show learn
storcli /cx/bbu show gasgauge Offset=xxxx Numbytes=n
storcli /cx/bbu start learn
storcli /cx/bbu show modes
storcli /cx/bbu set [ learnDelayInterval=<val> | bbuMode=<val>
|learnStartTime=[DDD HH | off] | autolearnmode=<val> |
powermode=sleep | writeaccess=sealed ]
storcli /cx/cv show
storcli /cx/cv show all
storcli /cx/cv show status
storcli /cx/cv show learn
storcli /cx/cv start learn
storcli /cx show securitykey keyid
storcli /cx start pr|patrolread
storcli /cx stop pr|patrolread
storcli /cx pause pr|patrolread
storcli /cx resume pr|patrolread
storcli /cx show pr|patrolRead
storcli /cx show powermonitoringinfo
storcli /cx show ldlimit
storcli /cx set patrolread [=[[on mode=<auto|manual> ]| off]]
| [starttime=< yyyy/mm/dd hh>]
| [maxconcurrentpd =<value>]
| [includessds=<on|onlymixed|off>]
| [uncfgareas=on|off]
| [excludevd=x-y,z|none]
| [delay = <value>]
storcli /cx show badblocks
storcli /cx flasherase
storcli /cx transform iMR
storcli /cx restart
storcli /cx/vx show BBMT
storcli /cx/vx delete BBMT
storcli /cx show dequeuelog file=<filepath>
storcli /cx show maintenance
storcli /cx set maintenance mode=normal|nodevices
storcli /cx show personality
storcli /cx set personality=RAID|HBA|JBOD
storcli /cx show profile
storcli /cx set profile profileid=<id>
storcli /cx show jbodwritecache
storcli /cx set jbodwritecache=on|off|default
storcli /cx show immediateio
storcli /cx show driveactivityled
storcli /cx set immediateio=<on|off>
storcli /cx show largeiosupport
storcli /cx set largeiosupport=<on|off>
storcli /cx show unmap
storcli /cx set unmap=<on|off>
storcli /cx set driveactivityled=<on|off>
storcli /cx show pdfailevents [lastoneday] [lastseqnum=<val>] [file=<filepath>]
storcli /cx show pdfaileventoptions
storcli /cx set pdfaileventoptions [detectionType=<val>] [correctiveaction=<val>] [errorThreshold=<val>]
storcli /cx set assemblynumber= xxxx
storcli /cx show aliLog [logfile[=filename]]
storcli /cx get config file=<fileName>
storcli /cx set config file=<fileName>
storcli /cx show flushwriteverify
storcli /cx set flushwriteverify=<on|off>
storcli /cx/dx set transport=on|off [EDHSP=on|off] [SDHSP=on|off]
storcli /cx show largeQD
storcli /cx set largeQD=<on|off>
storcli /cx set debug type=<value> option=<value> [level=<value in hex>]
storcli /cx set debug reset all
storcli /cx show assemblynumber
storcli /cx set tracernumber= xxxx
storcli /cx show tracernumber
storcli /cx show boardname
storcli /cx set sasadd = xxxx [devicename] [methodport]
storcli /cx set sasaddhi = xxxx  sasaddlow = xxxxx [devicename] [methodport]
storcli /cx show sasadd
storcli /cx/px compare linkspeed=<speed>
storcli /cx set updatevpd file=<filepath>
storcli /cx show vpd
storcli /cx erase nvsram
storcli /cx erase fwbackup
storcli /cx erase bootservices
storcli /cx erase all [excludemfg] [file=filename]
storcli /cx erase perconfpage
storcli /cx erase mpb
storcli /cx download efibios file=<filepath>
storcli /cx download cpld file=<filepath>
storcli /cx download psoc file=<filepath>
storcli /cx download bios file=<filepath>
storcli /cx download fcode file=<filepath>
storcli /cx compare bios ver =<bios version>
storcli /cx compare fwprodid ver =<fw product id version>
storcli /cx compare ssid ver =<ssid version>
storcli /cx compare firmware ver =<firmware version>
storcli /cx get bios file=<filename>
storcli /cx get firmware  file=<filename>
storcli /cx get mpb  file=<filename>
storcli /cx get fwbackup  file=<filename>
storcli /cx get nvdata file=<filename>
storcli /cx get flash  file=<filename>
storcli /cx set oob mode=i2c|pcie maxpayloadsize=<payloadsize> maxpacketsize=<packetsize> [spdm=on|off] [pldm=on|off]
storcli /cx show oob
storcli /cx show snapdump
storcli /cx set snapdump state=on|off
storcli /cx set snapdump [ savecount=<value> | delayocr=<value> | preboottrace=<on|off> ]
storcli /cx get snapdump [ id=[ all | <value> file=<fileName>] ] [norttdump]
storcli /cx delete snapdump [force]
storcli /cx show htbparams
storcli /cx set htbparams=off
storcli /cx set htbparams [= on] maxsize=<value> minsize=<value> decrementsize=<value>
storcli /cx show failedNvmeDevices
storcli /cx[/ex]/sx show repair
storcli /cx[/ex]/sx start repair [force]
storcli /cx[/ex]/sx stop repair
storcli /cx show security spdm slotgroup=xx slot=yy
storcli /cx export security spdm slotgroup=xx slot=yy subject=subjectfile file=filename
storcli /cx import security spdm slotgroup=xx slot=yy file=filename [seal]
storcli /cx set security spdm slotgroup=xx slot=yy invalidate [force]
storcli /cx get security spdm slotgroup=xx slot=yy file=filename
storcli /cx show parityreadcachebypass
storcli /cx set parityreadcachebypass=<on|off>
storcli /cx show overrideSlowArrayThresholds
storcli /cx set overrideSlowArrayThresholds=<on|off> [force]
storcli /cx show temperature
storcli /cx show refClk
storcli /cx set refClk = 0|1|2
storcli /cx show perst
storcli /cx set perst = 0|1|2
storcli /cx db register type=trace|snapshot [size=<val>] [prodmask=<val>] [iopmask=<val>:<val>] [plmask=<val>:<val>] [irmask=<val>:<val>]
storcli /cx db query type=trace|snapshot
storcli /cx db read type=trace|snapshot file=<filepath>
storcli /cx db release type=trace|snapshot
storcli /cx db unregister type=trace|snapshot
storcli /cx db get type= {[master],[event],[ mpi],[ scsi]} | all
storcli /cx db delete type= {[master],[event],[ mpi],[ scsi]} | all
storcli /cx db set {[master=<val>] [event EventLogQualifier=<val> EventValue=<val> ]
[mpi loginfo=<val> iocstatus=<val>] [ scsi sensekey=<val> asc=<val> ascq=<val>]}
Note:
```

- 1. Use 'page[=x]'as the last option in all the commands to set the page break.
X=lines per page. E.g. 'storcli help page=10'
- 2. Use 'nolog' option to disable debug logging. E.g. 'storcli show nolog'


```bash
[root@bogon ~]# storcli64 /c0 show
Generating detailed summary of the adapter, it may take a while to complete.
CLI Version = 007.2707.0000.0000 Dec 18, 2023
Operating system = Linux 5.10.0-216.0.0.115.oe2203sp4.aarch64
Controller = 0
Status = Success
Description = None
Product Name = MegaRAID 9560-16i 8GB
Serial Number = SPE5201509
SAS Address =  500062b220902e00
PCI Address = 00:83:00:00
System Time = 03/19/2026 23:02:02
Mfg. Date = 01/10/25
Controller Time = 03/19/2026 15:02:03
FW Package Build = 52.29.0-5442
BIOS Version = 7.29.00.0_0x071D0000
FW Version = 5.290.02-3997
Driver Name = megaraid_sas
Driver Version = 07.714.04.00-rc1
Current Personality = RAID-Mode
Vendor Id = 0x1000
Device Id = 0x10E2
SubVendor Id = 0x1000
SubDevice Id = 0x4000
Host Interface = PCI-E
Device Interface = SAS-12G
Bus Number = 131
Device Number = 0
Function Number = 0
Domain ID = 0
Security Protocol = None
Drive Groups = 8
TOPOLOGY :
========
-----------------------------------------------------------------------------
DG Arr Row EID:Slot DID Type  State BT       Size PDC  PI SED DS3  FSpace TR
-----------------------------------------------------------------------------
0 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
0 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
0 0   0   252:0    2   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
1 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
1 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
1 0   0   252:1    9   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
2 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
2 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
2 0   0   252:3    5   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
3 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
3 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
3 0   0   252:4    4   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
4 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
4 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
4 0   0   252:5    6   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
5 -   -   -        -   RAID0 Optl  Y  446.625 GB dflt N  N   none N      N
5 0   -   -        -   RAID0 Optl  Y  446.625 GB dflt N  N   none N      N
5 0   0   252:6    7   DRIVE Onln  Y  446.625 GB dflt N  N   none -      N
6 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
6 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
6 0   0   252:7    8   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
7 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
7 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
7 0   0   252:2    3   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
-----------------------------------------------------------------------------
DG=Disk Group Index|Arr=Array Index|Row=Row Index|EID=Enclosure Device ID
DID=Device ID|Type=Drive or RAID Type|Onln=Online|Rbld=Rebuild|Optl=Optimal
Dgrd=Degraded|Pdgd=Partially degraded|Offln=Offline|BT=Background Task Active
PDC=PD Cache|PI=Protection Info|SED=Self Encrypting Drive|Frgn=Foreign
DS3=Dimmer Switch 3|dflt=Default|Msng=Missing|FSpace=Free Space Present
TR=Transport Ready
Virtual Drives = 8
VD LIST :
=======
---------------------------------------------------------------
DG/VD TYPE  State Access Consist Cache Cac sCC       Size Name
---------------------------------------------------------------
6/232 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
5/233 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
4/234 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
3/235 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
2/236 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
7/237 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
1/238 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
0/239 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
---------------------------------------------------------------
VD=Virtual Drive| DG=Drive Group|Rec=Recovery
Cac=CacheCade|OfLn=OffLine|Pdgd=Partially Degraded|Dgrd=Degraded
Optl=Optimal|dflt=Default|RO=Read Only|RW=Read Write|HD=Hidden|TRANS=TransportReady
B=Blocked|Consist=Consistent|R=Read Ahead Always|NR=No Read Ahead|WB=WriteBack
AWB=Always WriteBack|WT=WriteThrough|C=Cached IO|D=Direct IO|sCC=Scheduled
Check Consistency
Physical Drives = 8
PD LIST :
=======
------------------------------------------------------------------------------
EID:Slt DID State DG       Size Intf Med SED PI SeSz Model            Sp Type
------------------------------------------------------------------------------
252:0     2 Onln   0 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:1     9 Onln   1 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:2     3 Onln   7 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:3     5 Onln   2 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:4     4 Onln   3 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:5     6 Onln   4 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:6     7 Onln   5 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:7     8 Onln   6 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
------------------------------------------------------------------------------
EID=Enclosure Device ID|Slt=Slot No|DID=Device ID|DG=DriveGroup
DHS=Dedicated Hot Spare|UGood=Unconfigured Good|GHS=Global Hotspare
UBad=Unconfigured Bad|Sntze=Sanitize|Onln=Online|Offln=Offline|Intf=Interface
Med=Media Type|SED=Self Encryptive Drive|PI=PI Eligible
SeSz=Sector Size|Sp=Spun|U=Up|D=Down|T=Transition|F=Foreign
UGUnsp=UGood Unsupported|UGShld=UGood shielded|HSPShld=Hotspare shielded
CFShld=Configured shielded|Cpybck=CopyBack|CBShld=Copyback Shielded
UBUnsp=UBad Unsupported|Rbld=Rebuild
Enclosures = 1
Enclosure LIST :
==============
------------------------------------------------------------------------
EID State Slots PD PS Fans TSs Alms SIM Port# ProdID     VendorSpecific
------------------------------------------------------------------------
252 OK       16  8  0    0   0    0   0 -     VirtualSES
------------------------------------------------------------------------
EID=Enclosure Device ID | PD=Physical drive count | PS=Power Supply count
TSs=Temperature sensor count | Alms=Alarm count | SIM=SIM Count | ProdID=Product ID
```




```bash
[root@bogon ~]# lspci
01:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
01:01.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
01:02.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
01:03.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
02:00.0 VGA compatible controller: Huawei Technologies Co., Ltd. Hi171x Series [iBMC Intelligent Management system chip w/VGA support] (rev 01)
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
35:00.3 Ethernet controller: Huawei Technologies Co., Ltd. HNS GE/10GE/25GE/50GE RDMA Network Controller (rev 30)
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
82:00.0 Non-Volatile memory controller: DERA Storage Device 1515
83:00.0 RAID bus controller: Broadcom / LSI MegaRAID 12GSAS/PCIe Secure SAS39xx
95:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
96:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
aa:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
ab:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
c0:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
c1:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
d5:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
d6:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
[root@bogon ~]# lspci | grep -i "raid/sata"
[root@bogon ~]# lspci | grep -i raid
83:00.0 RAID bus controller: Broadcom / LSI MegaRAID 12GSAS/PCIe Secure SAS39xx
[root@bogon ~]# storcli64 /c0 pdlist
syntax error, unexpected TOKEN_UNKNOWN
StorCli SAS Customization Utility Ver 007.2707.0000.0000 Dec 18, 2023
(c)Copyright 2023, Broadcom Inc. All Rights Reserved.
help - lists all the commands with their usage. E.g. storcli help
<command> help - gives details about a particular command. E.g. storcli add help
List of commands:
Commands   Description
-------------------------------------------------------------------
add        Adds/creates a new element to controller like VD,Spare..etc
delete     Deletes an element like VD,Spare
show       Displays information about an element
set        Set a particular value to a property
get        Get a particular value to a property
compare    Compares particular value to a property
start      Start background operation
stop       Stop background operation
pause      Pause background operation
resume     Resume background operation
download   Downloads file to given device
expand     expands size of given drive
insert     inserts new drive for missing
transform  downgrades the controller
reset      resets the controller phy
split      splits the logical drive mirror
/cx        Controller specific commands
/ex        Enclosure specific commands
/sx        Slot/PD specific commands
/vx        Virtual drive specific commands
/dx        Disk group specific commands
/fall      Foreign configuration specific commands
/px        Phy specific commands
/lnx       Lane specific commands
/[bbu|cv]  Battery Backup Unit, Cachevault commands
Other aliases : cachecade, freespace, sysinfo
Use a combination of commands to filter the output of help further.
E.g. 'storcli cx show help' displays all the show operations on cx.
Use verbose for detailed description E.g. 'storcli add  verbose help'
Use 'page[=x]' as the last option in all the commands to set the page break.
X=lines per page. E.g. 'storcli help page=10'
Use J as the last option to print the command output in JSON format
Command options must be entered in the same order as displayed in the help of
the respective commands.
Use 'nolog' option to disable debug logging. E.g. 'storcli show nolog'
```


```bash
[root@bogon ~]# storcli64 /c0
anaconda-ks.cfg
ascend/
Ascend-cann-toolkit_8.5.0_linux-aarch64.run
ascend_check/
Ascend-hdk-910b-npu-driver_25.5.0_linux-aarch64.run
Ascend-hdk-910b-npu-firmware_7.8.0.5.216.run
Ascend-mindx-toolbox_7.3.0_linux-aarch64.run
.bash_history
.bash_logout
.bash_profile
.bashrc
.cache/
.config/
.cshrc
dmesg.log
.lesshst
.local/
log/
nohup.out
nvme_info.py
.python_history
reboot/
reboot.zip
SAS35_StorCLI_7_27-007.2707.0000.0000.zip
sel.log
server_info.py
server_lab/
sever_lab/
SIT_Total_Report.csv
storcli.log
[root@bogon ~]# storcli64 /c0 show
Generating detailed summary of the adapter, it may take a while to complete.
CLI Version = 007.2707.0000.0000 Dec 18, 2023
Operating system = Linux 5.10.0-216.0.0.115.oe2203sp4.aarch64
Controller = 0
Status = Success
Description = None
Product Name = MegaRAID 9560-16i 8GB
Serial Number = SPE5201509
SAS Address =  500062b220902e00
PCI Address = 00:83:00:00
System Time = 03/19/2026 23:07:49
Mfg. Date = 01/10/25
Controller Time = 03/19/2026 15:07:50
FW Package Build = 52.29.0-5442
BIOS Version = 7.29.00.0_0x071D0000
FW Version = 5.290.02-3997
Driver Name = megaraid_sas
Driver Version = 07.714.04.00-rc1
Current Personality = RAID-Mode
Vendor Id = 0x1000
Device Id = 0x10E2
SubVendor Id = 0x1000
SubDevice Id = 0x4000
Host Interface = PCI-E
Device Interface = SAS-12G
Bus Number = 131
Device Number = 0
Function Number = 0
Domain ID = 0
Security Protocol = None
Drive Groups = 8
TOPOLOGY :
========
-----------------------------------------------------------------------------
DG Arr Row EID:Slot DID Type  State BT       Size PDC  PI SED DS3  FSpace TR
-----------------------------------------------------------------------------
0 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
0 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
0 0   0   252:0    2   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
1 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
1 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
1 0   0   252:1    9   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
2 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
2 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
2 0   0   252:3    5   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
3 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
3 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
3 0   0   252:4    4   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
4 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
4 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
4 0   0   252:5    6   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
5 -   -   -        -   RAID0 Optl  Y  446.625 GB dflt N  N   none N      N
5 0   -   -        -   RAID0 Optl  Y  446.625 GB dflt N  N   none N      N
5 0   0   252:6    7   DRIVE Onln  Y  446.625 GB dflt N  N   none -      N
6 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
6 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
6 0   0   252:7    8   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
7 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
7 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
7 0   0   252:2    3   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
-----------------------------------------------------------------------------
DG=Disk Group Index|Arr=Array Index|Row=Row Index|EID=Enclosure Device ID
DID=Device ID|Type=Drive or RAID Type|Onln=Online|Rbld=Rebuild|Optl=Optimal
Dgrd=Degraded|Pdgd=Partially degraded|Offln=Offline|BT=Background Task Active
PDC=PD Cache|PI=Protection Info|SED=Self Encrypting Drive|Frgn=Foreign
DS3=Dimmer Switch 3|dflt=Default|Msng=Missing|FSpace=Free Space Present
TR=Transport Ready
Virtual Drives = 8
VD LIST :
=======
---------------------------------------------------------------
DG/VD TYPE  State Access Consist Cache Cac sCC       Size Name
---------------------------------------------------------------
6/232 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
5/233 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
4/234 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
3/235 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
2/236 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
7/237 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
1/238 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
0/239 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
---------------------------------------------------------------
VD=Virtual Drive| DG=Drive Group|Rec=Recovery
Cac=CacheCade|OfLn=OffLine|Pdgd=Partially Degraded|Dgrd=Degraded
Optl=Optimal|dflt=Default|RO=Read Only|RW=Read Write|HD=Hidden|TRANS=TransportReady
B=Blocked|Consist=Consistent|R=Read Ahead Always|NR=No Read Ahead|WB=WriteBack
AWB=Always WriteBack|WT=WriteThrough|C=Cached IO|D=Direct IO|sCC=Scheduled
Check Consistency
Physical Drives = 8
PD LIST :
=======
------------------------------------------------------------------------------
EID:Slt DID State DG       Size Intf Med SED PI SeSz Model            Sp Type
------------------------------------------------------------------------------
252:0     2 Onln   0 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:1     9 Onln   1 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:2     3 Onln   7 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:3     5 Onln   2 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:4     4 Onln   3 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:5     6 Onln   4 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:6     7 Onln   5 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:7     8 Onln   6 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
------------------------------------------------------------------------------
EID=Enclosure Device ID|Slt=Slot No|DID=Device ID|DG=DriveGroup
DHS=Dedicated Hot Spare|UGood=Unconfigured Good|GHS=Global Hotspare
UBad=Unconfigured Bad|Sntze=Sanitize|Onln=Online|Offln=Offline|Intf=Interface
Med=Media Type|SED=Self Encryptive Drive|PI=PI Eligible
SeSz=Sector Size|Sp=Spun|U=Up|D=Down|T=Transition|F=Foreign
UGUnsp=UGood Unsupported|UGShld=UGood shielded|HSPShld=Hotspare shielded
CFShld=Configured shielded|Cpybck=CopyBack|CBShld=Copyback Shielded
UBUnsp=UBad Unsupported|Rbld=Rebuild
Enclosures = 1
Enclosure LIST :
==============
------------------------------------------------------------------------
EID State Slots PD PS Fans TSs Alms SIM Port# ProdID     VendorSpecific
------------------------------------------------------------------------
252 OK       16  8  0    0   0    0   0 -     VirtualSES
------------------------------------------------------------------------
EID=Enclosure Device ID | PD=Physical drive count | PS=Power Supply count
TSs=Temperature sensor count | Alms=Alarm count | SIM=SIM Count | ProdID=Product ID
```




```bash
[root@bogon ~]# lsblk
NAME               MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda                  8:0    0 447.1G  0 disk
sdb                  8:16   0 447.1G  0 disk
sdc                  8:32   0 446.6G  0 disk
sdd                  8:48   0 446.6G  0 disk
sde                  8:64   0 446.6G  0 disk
sdf                  8:80   0 446.6G  0 disk
sdg                  8:96   0 446.6G  0 disk
sdh                  8:112  0 446.6G  0 disk
sdi                  8:128  0 446.6G  0 disk
sdj                  8:144  0 446.6G  0 disk
nvme0n1            259:0    0   2.9T  0 disk
├─nvme0n1p1        259:2    0   600M  0 part
├─nvme0n1p2        259:3    0     1G  0 part
└─nvme0n1p3        259:4    0   2.9T  0 part
├─klas-swap      253:2    0     4G  0 lvm
├─klas-backup    253:3    0    50G  0 lvm
└─klas-root      253:4    0   2.9T  0 lvm
nvme1n1            259:1    0   2.9T  0 disk
├─nvme1n1p1        259:5    0   600M  0 part /boot/efi
├─nvme1n1p2        259:6    0     1G  0 part /boot
└─nvme1n1p3        259:7    0   2.9T  0 part
├─openeuler-root 253:0    0    70G  0 lvm  /
├─openeuler-swap 253:1    0     4G  0 lvm  [SWAP]
└─openeuler-home 253:5    0   2.8T  0 lvm  /home
```

很好，这次已经不是“会看命令”了，已经开始进入 按层做映射 了。
我先直接下结论：
你的 Day7 已经过关了，水平大概在 75~80 分。
强项是你已经抓住了主线：OS 盘 → 控制器 → 逻辑盘 → 物理盘 → 槽位。
现在主要要修正的是：不要把“看到的盘”说得太快太粗，要把来源说准。
下面我按“批改作业”的方式给你改。

### 你这台机器的存储结构，我先帮你定性

这台机不是“只有一套存储”，而是至少三套路径同时存在：
1）Broadcom RAID 卡路径
你这里明确有一张：

83:00.0 RAID bus controller: Broadcom / LSI MegaRAID 12GSAS/PCIe Secure SAS39xx


storcli64 /c0 show 也确认：


Controller = 0


Product Name = MegaRAID 9560-16i 8GB


Current Personality = RAID-Mode

这说明：
这台机有 1 张真正的 Broadcom RAID 卡，并且当前工作在 RAID 模式。

2）板载/SoC 自带 SAS HBA 路径
lspci 里还有 4 个：

30:04.0 Serial Attached SCSI controller: HiSilicon SAS 3.0 HBA


32:04.0 Serial Attached SCSI controller: HiSilicon SAS 3.0 HBA


70:04.0 Serial Attached SCSI controller: HiSilicon SAS 3.0 HBA


72:04.0 Serial Attached SCSI controller: HiSilicon SAS 3.0 HBA

这说明：
除了 Broadcom RAID 卡以外，机器本身还有多路 HiSilicon SAS HBA。
但从你这次 lsscsi / lsblk 输出看，当前真正挂着并被 OS 识别出来的数据盘主角，是 Broadcom 这一路 + 两块 Intel SATA + 两块 NVMe。

3）独立 NVMe 路径
你这里有两块 NVMe：

81:00.0 Non-Volatile memory controller: DERA Storage Device 1515


82:00.0 Non-Volatile memory controller: DERA Storage Device 1515

对应 OS：

/dev/nvme0n1


/dev/nvme1n1

这说明：
这两块 NVMe 是走 PCIe/NVMe 路径，不走 Broadcom 这张 SAS RAID 卡。
这点非常关键。
也就是说你这台机里同时存在：

RAID 卡管理的 SATA 盘


非 RAID 卡管理的 SATA 盘


独立 PCIe NVMe 盘

这就是服务器现场的真实复杂度。

### 你原来第 1 条，基本对，但还能说得更专业

你写的是：
控制器型号：Broadcom博通的raid卡一张MegaRAID 9560-16i 8GB
这个判断 是对的。
更专业的说法应该改成：
改写版
本机至少存在 1 张 Broadcom MegaRAID 9560-16i 8GB RAID 控制器（Controller 0，RAID-Mode），同时还存在多路 HiSilicon SAS 3.0 HBA 以及独立 NVMe 控制器。当前 storcli64 /c0 show 看到的 8 块 446.6G SATA SSD 归 Broadcom RAID 卡管理。
你看，区别就在于：

不是只说“有一张 RAID 卡”


而是把 整机存储控制平面 说清了

这就是系统工程师表达。

### 你原来第 2 条，有一个明显需要修正的地方

你写的是：
os下lsblk可以看到2张M.2形态的sata盘、8张sata盘、2张nvme盘、系统盘是nvme、两个系统
这里面有两处要改。

先说第一处：“2张M.2形态的sata盘” 这个说法证据不足
从你给的输出里，我只能确认：
lsscsi 显示：

[1:0:0:0] disk ATA INTEL SSDSCKKB48 0100 /dev/sda


[2:0:0:0] disk ATA INTEL SSDSCKKB48 0100 /dev/sdb

lsblk 显示：

/dev/sda 447.1G


/dev/sdb 447.1G

这能确认的是：

它们是 ATA / SATA 协议盘


型号是 Intel SSD


容量约 447G

但不能仅凭这几个输出就断定它们的物理形态一定是 M.2。
所以更稳妥的表述应该是：
改写
OS 当前还能看到两块独立暴露的 Intel SATA SSD（/dev/sda、/dev/sdb），每块约 447.1G；其物理形态是否为 M.2，单靠本次输出还不能完全确认。
这就是工程上“只说证据能支持的话”。

第二处：你把“8张 sata盘”说少了半层关系
其实这里更准确应该说：
当前 OS 一共看到的非 NVMe 块盘有 10 块

/dev/sda


/dev/sdb


/dev/sdc ~ /dev/sdj 共 8 块

其中分两类：
A 类：两块 Intel SATA SSD

/dev/sda


/dev/sdb

B 类：8 块 Broadcom 暴露出来的逻辑盘

/dev/sdc ~ /dev/sdj

这里关键不是“8 张 SATA 盘”这句话本身，而是你要知道：
sdc 到 sdj 不是 OS 直接看到的 8 块裸物理盘，而是 RAID 卡给出来的 8 个单盘 RAID0 逻辑盘。
这就是 Day7 的重点。

### 最关键的一个发现：这 8 块不是 JBOD，而是“单盘 RAID0”

你这次最大的收获就在这。
看 storcli64 /c0 show：

Virtual Drives = 8


Drive Groups = 8


每个 DG/VD 都是 RAID0 Optl 446.625 GB


每个 DG 下面只有 1 块 DRIVE Onln

这说明什么？
说明这 8 块物理 SATA SSD 没有直接以 JBOD 裸盘方式给 OS，
而是被 Broadcom 控制器 每盘各做了一个 RAID0 虚拟盘，所以 OS 才看到：

/dev/sdc


/dev/sdd


...


/dev/sdj

这点非常重要。
你要把它记成一句标准话：
当前 Broadcom 控制器下 8 块 446.625G SATA SSD，并不是以 JBOD 形式直通给系统，而是被分别创建成 8 个单盘 RAID0 虚拟盘（每块物理盘对应 1 个 VD）。
这句话一说出来，Day7 就真的到位了。

### 你原来第 3、4 条写得太简略，我帮你展开成标准版

你写的是：
storcli64 /c0 show可以查看pd和vd list
8张sata盘、两张nvme
这个可以升级成下面这样。

### 我帮你整理成一版“Day7 存储识别报告”

你可以直接抄进笔记。
《Day7：本机 RAID / 存储拓扑识别报告》
- 1. 控制器识别
本机存在多类存储控制器：

1 张 Broadcom MegaRAID 9560-16i 8GB RAID 控制器


PCI 地址：83:00.0


Controller ID：/c0


Personality：RAID-Mode


4 路 HiSilicon SAS 3.0 HBA


2 个独立 NVMe 控制器（对应两块 DERA NVMe SSD）


1 个 HiSilicon AHCI HBA（38:05.0 SATA controller）

结论：
本机存储并非单一路径，而是 RAID 卡、板载 SATA/SAS 控制器、独立 NVMe 控制器并存。

- 2. OS 可见块设备
lsblk 显示当前主要块设备如下：

/dev/sda 447.1G


/dev/sdb 447.1G


/dev/sdc ~ /dev/sdj，共 8 块，每块 446.6G


/dev/nvme0n1 2.9T


/dev/nvme1n1 2.9T

合计：

2 块独立 SATA SSD


8 块通过 Broadcom 控制器暴露的 SATA 逻辑盘


2 块独立 NVMe SSD


- 3. SATA / RAID 关系判断
lsscsi 显示：

/dev/sdc ~ /dev/sdj 厂商都显示为 BROADCOM MR9560-16i


storcli64 /c0 show 显示：


8 个 VD


8 个 DG


每个 VD 类型均为 RAID0


每个 DG 下仅 1 块物理盘

因此可以判断：
这 8 块 446.6G SATA SSD 不是 OS 直接看到的裸盘，而是由 Broadcom RAID 卡将每块物理盘分别做成单盘 RAID0 后暴露给 OS 的。

- 4. 物理盘与槽位状态
storcli64 /c0 show 中 PD LIST 显示：

Enclosure：252


Slot：0 ~ 7


共 8 块 SATA SSD


型号：HWE62ST3480L003N


每块容量：446.625 GB


状态：全部 Onln


所属 DG：0 ~ 7

结论：
当前 Broadcom RAID 卡下 8 块 SATA SSD 均在线，未见 Failed / Rebuild / Degraded / Hot Spare。

- 5. 逻辑盘状态
VD LIST 显示：

共 8 个 Virtual Drive


全部为 RAID0


全部为 Optl


访问属性为 RW


一致性状态为 Yes

结论：
Broadcom 控制器当前逻辑盘层状态正常，无降级、无重建。

- 6. NVMe 系统盘判断
lsblk 显示：

/dev/nvme1n1


p1 挂载 /boot/efi


p2 挂载 /boot


p3 上 LVM 承载 /、/home、swap

因此当前运行系统的活动系统盘是：
/dev/nvme1n1
而 /dev/nvme0n1 也存在完整分区和 LVM 结构，但未见当前挂载到活动根文件系统。
因此更合理的判断是：
nvme0n1 上可能保留了另一套历史系统或备用系统数据，但当前在线启动系统是 nvme1n1。
注意这里我用了“可能”，这就是严谨。

### 给你把盘和来源做成一张映射图

你现在最需要这个。
Broadcom RAID Controller /c0  (MegaRAID 9560-16i 8GB, RAID-Mode)
└─ Enclosure 252
├─ Slot0  -> PD 446.625G SATA SSD -> DG0/VD239 RAID0 -> /dev/sdc
├─ Slot1  -> PD 446.625G SATA SSD -> DG1/VD238 RAID0 -> /dev/sdd
├─ Slot2  -> PD 446.625G SATA SSD -> DG7/VD237 RAID0 -> /dev/sdi 或 /dev/sdj之一
├─ Slot3  -> PD 446.625G SATA SSD -> DG2/VD236 RAID0 -> /dev/sde
├─ Slot4  -> PD 446.625G SATA SSD -> DG3/VD235 RAID0 -> /dev/sdf
├─ Slot5  -> PD 446.625G SATA SSD -> DG4/VD234 RAID0 -> /dev/sdg
├─ Slot6  -> PD 446.625G SATA SSD -> DG5/VD233 RAID0 -> /dev/sdh
└─ Slot7  -> PD 446.625G SATA SSD -> DG6/VD232 RAID0 -> /dev/sdi 或 /dev/sdj之一

Direct / Non-Broadcom devices
├─ /dev/sda -> Intel SATA SSD 447.1G
├─ /dev/sdb -> Intel SATA SSD 447.1G
├─ /dev/nvme0n1 -> DERA NVMe 2.9T
└─ /dev/nvme1n1 -> DERA NVMe 2.9T (current active system disk)
这里我故意保留了一个严谨点：
slot 和 /dev/sdc~sdj 的一一对应顺序，不能只靠这份 show 粗暴拍死。
因为 VD 编号和 Linux 枚举顺序不一定自然递增完全对应。
你要想把这张图画到 100% 精准，需要补一个命令。

### 你下一步必须补的两个命令

为了把 “VD ↔ /dev/sdX ↔ Slot” 完全对死，补这两个：
storcli64 /c0/vall show all
storcli64 /c0/e252/sall show all
你会得到更细的信息：

每个 VD 的 target/WWN/属性


每个 PD 的详细信息


可能更容易和 OS 侧对应

如果还想进一步从 Linux 侧核对：
udevadm info --query=all --name=/dev/sdc
udevadm info --query=all --name=/dev/sdd
这样你能把 /dev/sdX 和控制器暴露出来的设备属性再做一次映射。

### 你第 5 条排障思路是对的，我帮你升级成标准版

你写的是：
如果lsblk丢盘了、先查看lsscsi控制器能不能看到盘、再看是逻辑盘嘛、逻辑盘的话对应哪个物理盘、点灯定位、查看物理槽位
这个方向是对的。
我给你改成一个更像面试/现场汇报的版本。
标准表达
当 OS 层出现丢盘或设备异常时，我会先确认 lsblk / lsscsi / dmesg 中设备是否消失或报 I/O 错误；然后区分该设备是独立盘还是 RAID 逻辑盘。若为 Broadcom 逻辑盘，则进一步通过 storcli64 /c0 show、/c0/vall show all、/c0/e252/sall show all 确认对应 VD、DG、PD 和槽位；若发现物理盘异常，再结合 locate/点灯功能和机箱槽位定位故障盘，最后判断是单盘故障、逻辑盘异常还是背板/控制器路径问题。
这段你背下来，已经很能打了。

### 我给你这次作业的扣分点

主要 3 个：
1）“M.2 形态 SATA 盘”说早了
证据不够，工程上不能先下结论。
2）没有明确说出“8 块是单盘 RAID0”
这是这次最值钱的发现，你原文没点透。
3）没有把“多控制器并存”说出来
你这台机不是单一 Broadcom 盘机，而是：

Broadcom RAID


HiSilicon SAS HBA


AHCI HBA


NVMe 控制器
同时存在。

这个要形成意识。

### 这次作业我帮你打一个更准确的分

得分：78/100
为什么不是更低？
因为你已经抓到了 Day7 的灵魂：

会看控制器


会看 OS 盘


会看 PD/VD


会想“逻辑盘对应物理盘”


会想到点灯定位槽位

为什么没到 90？
因为你还差：

表达精确


证据链完整


映射说透


不乱猜盘形态


### 你现在已经可以进入 Day7 下半场了

下一步我们不讲大理论，直接进入：
Day7 实战版：Broadcom storcli 输出怎么逐行读
我建议你接着马上执行这几个命令，把输出贴我：
storcli64 /c0/vall show all
storcli64 /c0/e252/sall show all
storcli64 /c0 show events
dmesg -T | egrep -i 'sd[a-z]|nvme|scsi|sas|error|fail|reset'
我下一条就直接带你做 Day7 实战精读，把：

VD


DG


EID:Slot


DID


RAID0 单盘盘组


丢盘排障路径

全部给你串起来。
很好，这份 dmesg 已经够用了。
而且它把你前面 Day7 里几个还“半确定”的地方，补成了实锤。
我先给你一句总评：
这台机器的存储路径现在已经基本被你摸清了，而且 dmesg 证明当前没有明显的掉盘、reset、I/O error、SAS link flap 这类存储故障。
下面我直接带你做 Day7 实战精读。

### 先说这份 dmesg 最重要的结论

从这份日志里，可以确认 4 件关键事：
1）Broadcom RAID 卡初始化正常
关键日志：
megaraid_sas 0000:83:00.0: FW now in Ready state
megaraid_sas 0000:83:00.0: INIT adapter done
scsi host0: Avago SAS based MegaRAID driver
这说明：

83:00.0 这张 Broadcom/MegaRAID 卡正常起来了


固件 ready


驱动正常加载


OS 成功把它注册成了 scsi host0

这和你前面 storcli64 /c0 show 完全对上了。

2）两块 Intel SATA 盘不是走 Broadcom，而是走 AHCI
关键日志：
scsi host1: ahci
scsi host2: ahci
ata1.00: ATA-10: INTEL SSDSCKKB480GZ
ata2.00: ATA-10: INTEL SSDSCKKB480GZ
scsi 1:0:0:0: Direct-Access ATA INTEL ... /dev/sda
scsi 2:0:0:0: Direct-Access ATA INTEL ... /dev/sdb
这点非常值钱。
它说明：

/dev/sda 对应 scsi host1: ahci


/dev/sdb 对应 scsi host2: ahci


它们是 AHCI/SATA 路径


不是 Broadcom RAID 卡给出来的逻辑盘

所以你前面那句“2 张 Intel SATA 盘”是对的，
而且现在可以再多加一句：
这两块 Intel SATA 盘是由 AHCI 控制器直接暴露给系统的，不属于 Broadcom RAID 卡管理范围。
这就是证据链闭环了。

3）两块 NVMe 盘是独立 PCIe/NVMe 路径
关键日志：
nvme nvme0: pci function 0000:81:00.0
nvme nvme1: pci function 0000:82:00.0
nvme0n1: p1 p2 p3
nvme1n1: p1 p2 p3
EXT4-fs (nvme1n1p2): mounted filesystem
这说明：

nvme0n1 对应 81:00.0


nvme1n1 对应 82:00.0


两块盘都正常识别、正常分区


当前启动链路里，nvme1n1p2 被挂载了


也就是说当前活动系统仍然是你之前判断的 nvme1n1

所以这句可以正式落地：
当前在线启动系统盘是 nvme1n1，不是 Broadcom RAID 盘，也不是 Intel SATA 盘。

4）8 块 Broadcom 盘确实是 8 个逻辑设备给到 Linux
关键日志：
scsi 0:3:104:0 ... /dev/sdc
scsi 0:3:105:0 ... /dev/sdd
scsi 0:3:106:0 ... /dev/sde
scsi 0:3:107:0 ... /dev/sdf
scsi 0:3:108:0 ... /dev/sdg
scsi 0:3:109:0 ... /dev/sdh
scsi 0:3:110:0 ... /dev/sdj
scsi 0:3:111:0 ... /dev/sdi
这说明：

Broadcom 控制器在 host0


它向 OS 暴露了 8 个 SCSI Direct-Access 设备


target ID 是 104 ~ 111


这些设备对应：


sdc


sdd


sde


sdf


sdg


sdh


sdj


sdi

这和前面的 lsscsi 一模一样，说明不是偶发枚举，而是稳定识别。

### 你现在可以把整机存储路径写成“实锤版”

这是你 Day7 最该记住的成果。
本机当前存储路径实锤版
路径A：Broadcom RAID 路径

控制器：83:00.0


驱动：megaraid_sas


Linux 主机号：scsi host0


对外暴露：8 个 SCSI 盘


OS 设备：/dev/sdc ~ /dev/sdj


本质：8 个单盘 RAID0 虚拟盘


路径B：AHCI 直连 SATA 路径

控制器：AHCI


Linux 主机号：scsi host1、scsi host2


OS 设备：


/dev/sda


/dev/sdb


本质：两块独立 Intel SATA SSD，非 Broadcom RAID 盘


路径C：PCIe NVMe 路径

控制器 PCI 地址：


81:00.0


82:00.0


OS 设备：


/dev/nvme0n1


/dev/nvme1n1


本质：独立 NVMe 设备


当前活动系统盘：/dev/nvme1n1


### 这次 dmesg 把你前面一个模糊点纠正得更清楚了

你前面有一句话容易说得不够准：
“8 张 sata 盘、两张 nvme、两张 Intel 盘”
现在你要改成更工程化的表达：
正确表达
本机当前 OS 可见的块设备分为三类：

2 块 AHCI 直连 Intel SATA SSD：sda、sdb


8 个 Broadcom MegaRAID 暴露的 RAID0 逻辑盘：sdc~sdj


2 块独立 PCIe NVMe SSD：nvme0n1、nvme1n1

这个表达就比“几张盘几张盘”强很多。

### 这份日志里有没有“存储异常”？

结论是：
没看到典型存储异常
我重点看的就是这些：

I/O error


abort


reset


medium error


link down


device offline


timed out


failed


degraded

你这份 dmesg 里，没有看到这些针对磁盘路径的异常。
所以目前可以判断：

Broadcom 控制器正常


8 个 Broadcom 逻辑盘正常枚举


两块 Intel SATA 正常枚举


两块 NVMe 正常枚举


没有明显丢盘痕迹


没有明显 reset 风暴


没有 I/O 错误

这点很重要。
因为它说明你现在拿到的是一份“健康机”的基线日志。
这非常适合拿来做对照模板。以后机器出问题，你就拿异常机和这个健康基线对比。

### 但日志里有两个“非存储主线”的注意点

1）APEI Hardware Error
开机最前面这几行：
{1}[Hardware Error]: Hardware error from APEI ...
event severity: recoverable
这说明：

平台层记录到过一个 可恢复硬件错误


但它没有直接指向当前某块盘掉线


更像是平台/固件/总线层面一次可恢复事件

你现在不要把它直接判成“磁盘坏”。
更好的处理方式是：
记下来，作为平台层单独跟踪项；如果以后反复出现，才再结合 APEI/firmware/BMC/PCIe 错误一起看。
也就是说：

它值得关注


但目前不能直接归因到存储故障


2）几个 USB hub 错误
hub x-0:1.0: config failed, hub doesn't have any ports! (err -19)
这和你当前存储主线关系不大。
先别分散注意力。

### 你现在已经可以把 Broadcom 到 Linux 的映射再往前推进一步

这一步是 Day7 最像实战的地方。
从 dmesg + lsscsi + storcli，你现在已经能稳定确认：
Broadcom 逻辑设备到 Linux 设备映射

0:3:104:0 -> /dev/sdc


0:3:105:0 -> /dev/sdd


0:3:106:0 -> /dev/sde


0:3:107:0 -> /dev/sdf


0:3:108:0 -> /dev/sdg


0:3:109:0 -> /dev/sdh


0:3:110:0 -> /dev/sdj


0:3:111:0 -> /dev/sdi

注意最后两个顺序：

110 -> sdj


111 -> sdi

所以你以后不能偷懒默认“target 号越大，盘符也越后”。
Linux 盘符枚举不一定严格和你心里想象的顺序一致。
这是个很好的现场经验点。

### 这份 dmesg 还给了你一个很好的“排障切入口诀”

你以后碰到“lsblk 少盘了”，就按这个切：
第1步：先分路径
先问自己，少的是哪类盘？

Broadcom RAID 盘？


AHCI 直连 SATA 盘？


NVMe 盘？

这一步非常关键，因为不同路径查法不一样。

第2步：看内核有没有枚举
比如：
如果少的是 Broadcom 盘
你先看有没有类似：
scsi 0:3:10x:0
sd 0:3:10x:0
如果都没了：

可能是 RAID 卡没给出来


可能是 VD 没了


可能是控制器异常

如果还有，但 /dev/sdX 没了：

再看 udev / 分区 / multipath / 设备节点问题


如果少的是 AHCI 盘
就看：
ata1.00
ata2.00
scsi 1:0:0:0
scsi 2:0:0:0
如果 ATA 链路都没起来：

查 SATA/AHCI 路径


查主板口、供电、背板、线缆


如果少的是 NVMe 盘
就看：
nvme nvme0
nvme nvme1
如果 nvme 控制器日志都没了：

查 PCIe 枚举


查 Root Port


查热插拔/链路训练/BMC/电源

这才叫真正“分层排障”。

### 我帮你把 Day7 报告升级成最终版

你可以直接收进笔记。
《Day7：本机 RAID / 存储拓扑识别报告（修正版）》
- 1. 控制器与路径
本机存在三类主要存储路径：

Broadcom MegaRAID 9560-16i 8GB


PCI：83:00.0


驱动：megaraid_sas


Linux：scsi host0


当前工作模式：RAID-Mode


AHCI SATA 控制器


Linux：scsi host1、scsi host2


连接两块 Intel SATA SSD


独立 NVMe 控制器


PCI：81:00.0、82:00.0


对应两块 NVMe SSD


- 2. OS 可见盘

/dev/sda、/dev/sdb：Intel SATA SSD，经 AHCI 路径暴露


/dev/sdc ~ /dev/sdj：Broadcom 控制器暴露出的 8 个逻辑盘


/dev/nvme0n1、/dev/nvme1n1：独立 NVMe 盘


- 3. Broadcom RAID 盘结论
storcli64 /c0 show 表明：

8 个 DG


8 个 VD


每个 VD 都是单盘 RAID0


每个 VD 对应 1 块 446.625G SATA SSD


所有 PD/VD 当前状态均为 Onln/Optl

结论：
Broadcom 下的 8 块 SATA SSD 不是 JBOD，而是被分别创建为 8 个 RAID0 逻辑盘提供给 OS。

- 4. 系统盘结论
当前活动系统在：

/dev/nvme1n1


/boot/efi


/boot


/


/home


swap

因此：
当前在线系统盘是 nvme1n1。

- 5. 当前健康状态
从 dmesg 看：

Broadcom RAID 控制器初始化正常


8 个 Broadcom 逻辑盘全部正常枚举


两块 Intel SATA 盘正常枚举


两块 NVMe 盘正常枚举


未见明显存储 I/O error / reset / timeout / failed / degraded 日志

结论：
当前机器存储路径整体处于健康状态，适合作为健康基线样本。

### 你这次 Day7 实战成绩，我给你再往上提一点

如果前一版是 78 分，
那加上这次 dmesg 之后，我给你：
84/100
因为你现在已经能做到：

分清 3 类路径


分清 RAID 逻辑盘和直连盘


用 dmesg 验证 lsscsi / lsblk / storcli 的结论


判断当前机器“无明显存储异常”

这已经很不错了。

### Day7 现在还差最后半步

如果你想把 Day7 收得更完整，下一步只补一个方向就够了：
补“槽位到 /dev/sdX 的精确映射”
也就是把：

EID:Slot


DG/VD


/dev/sdc ~ /dev/sdj

彻底一一对死。
最值得继续跑的是：
storcli64 /c0/vall show all
storcli64 /c0/e252/sall show all
你把这两段贴出来，我下一条就直接帮你做 Day7 收官版：
把 Broadcom 的 槽位→物理盘→DG/VD→Linux 盘符 全部画成最终拓扑图。
好，这下 Day7 真正收官了。
你补的这两份 storcli 详细输出，把最后一块最关键的拼图补齐了：
Broadcom 槽位 → 物理盘 → DG/VD → Linux 盘符
现在已经可以 100% 对死。

Day7 收官结论
1）Broadcom 这 8 块盘的精确映射
这个表就是你 Day7 最值钱的成果。
因为你已经不只是“知道有 8 块盘”，而是已经能精确回答：

某个槽位对应哪个 DG


哪个 DG 对应哪个 VD


哪个 VD 对应哪个 /dev/sdX

这些关系都已经在两份文件里直接给出来了。

2）这 8 块盘的本质
它们不是 JBOD，也不是多盘 RAID5/RAID10，
而是：

8 块物理 SATA SSD


每块盘单独做了一个 RAID0


每个 VD 只包含 1 块 PD


全部暴露给 OS

也就是说：

Slot7 → DG6 → VD232 → /dev/sdc


Slot6 → DG5 → VD233 → /dev/sdd


…


Slot0 → DG0 → VD239 → /dev/sdi

这是标准的 “单盘 RAID0 暴露” 方案。

你现在可以画出最终拓扑图了
Broadcom MegaRAID 9560-16i 8GB  (/c0, RAID-Mode)
└─ Enclosure 252
├─ Slot7 -> PD DID8  -> DG6 -> VD232 RAID0 -> /dev/sdc
├─ Slot6 -> PD DID7  -> DG5 -> VD233 RAID0 -> /dev/sdd
├─ Slot5 -> PD DID6  -> DG4 -> VD234 RAID0 -> /dev/sde
├─ Slot4 -> PD DID4  -> DG3 -> VD235 RAID0 -> /dev/sdf
├─ Slot3 -> PD DID5  -> DG2 -> VD236 RAID0 -> /dev/sdg
├─ Slot2 -> PD DID3  -> DG7 -> VD237 RAID0 -> /dev/sdh
├─ Slot1 -> PD DID9  -> DG1 -> VD238 RAID0 -> /dev/sdj
└─ Slot0 -> PD DID2  -> DG0 -> VD239 RAID0 -> /dev/sdi

Other storage paths
├─ /dev/sda -> Intel SATA SSD (AHCI)
├─ /dev/sdb -> Intel SATA SSD (AHCI)
├─ /dev/nvme0n1 -> DERA NVMe
└─ /dev/nvme1n1 -> DERA NVMe (current active system disk)
这个图现在已经不是“推测”，而是可以直接落地的结果。

3）这 8 块盘的健康状态
这次详细输出还能让你做一次更专业的健康检查：
所有 8 块盘都显示：

State = Onln


Media Error Count = 0


Other Error Count = 0


Predictive Failure Count = 0


S.M.A.R.T alert flagged by drive = No

温度大致在 30C 到 38C 之间，链路速率和设备速率都为 6.0Gb/s。
这说明当前 Broadcom 这一路的盘：

没有介质错误


没有预测性故障


没有 SMART 告警


链路协商正常

结论就是：
当前 8 块 Broadcom SATA SSD 处于健康在线状态。

4）你还能顺手学到几个很实用的现场点
第一，Linux 盘符顺序不能想当然
你前面从 dmesg 已经看到 target 号和 /dev/sdX 不是完全按你直觉排的。
这次 OS Drive Name 直接给你实锤了：

最低 VD232 反而是 /dev/sdc


最高 VD239 反而是 /dev/sdi

所以以后你不能凭“槽位顺序”脑补盘符，
必须以工具输出为准。

第二，单盘 RAID0 和 JBOD 不是一回事
这里每个 VD 都写明：

TYPE = RAID0


Span Depth = 1


Number of Drives Per Span = 1


VD has Emulated PD = Yes


Exposed to OS = Yes

这就是典型单盘 RAID0 逻辑盘，不是裸盘直通。

第三，盘侧写缓存和 VD 写缓存要分开看
PD 详细信息里写的是：

Write Cache = Enabled

但 VD 属性里又写：

Write Cache(initial setting) = WriteBack


Disk Cache Policy = Disk's Default

这提醒你以后现场看缓存策略时，要分清：

物理盘写缓存


RAID 虚拟盘写策略

这俩不是一个层次。

5）你现在已经具备的排障能力
现在如果有人说：
“/dev/sde 异常了”
你已经能立刻反查：

/dev/sde = VD234


VD234 = DG4


DG4 下只有 1 块盘


那块盘是 252:5


DID = 6


型号 HWE62ST3480L003N

也就是你能直接定位到：
Enclosure 252，Slot 5
这个就是 Day7 要练出来的真本事。
反过来，如果机房说：
“252:4 这块盘要点灯确认”
你也能马上知道：

252:4 = DG3


DG3 = VD235


VD235 = /dev/sdf

这就能直接判断业务影响面。

6）我帮你整理成 Day7 最终版作业
你可以直接抄到手册里。
《Day7：本机 RAID / 存储拓扑识别报告（最终版）》
本机 Broadcom 存储路径由 1 张 MegaRAID 9560-16i 8GB 控制器管理，当前控制器下有 1 个 Enclosure（EID 252）、8 块 SATA SSD 物理盘，所有物理盘均为 HWE62ST3480L003N，容量 446.625 GB，状态均为 Onln。8 块盘全部被分别创建为单盘 RAID0 虚拟盘，而不是以 JBOD 裸盘方式暴露给系统。
这 8 个虚拟盘与 OS 盘符的对应关系为：
252:7 -> /dev/sdc，252:6 -> /dev/sdd，252:5 -> /dev/sde，252:4 -> /dev/sdf，252:3 -> /dev/sdg，252:2 -> /dev/sdh，252:1 -> /dev/sdj，252:0 -> /dev/sdi。每个 VD 仅包含 1 块 PD，且全部 Optl、Exposed to OS = Yes。
盘健康状态方面，8 块盘的 Media Error Count、Other Error Count、Predictive Failure Count 均为 0，SMART 未告警，温度约 30C~38C，设备速率和链路速率均为 6.0Gb/s，当前可视为健康基线状态。
本机另有两块 AHCI 直连 Intel SATA SSD（/dev/sda、/dev/sdb）和两块独立 NVMe SSD（/dev/nvme0n1、/dev/nvme1n1），其中当前活动系统盘为 nvme1n1。这一点是 Broadcom RAID 路径之外的其他存储路径，需要与 /dev/sdc~/dev/sdj 区分。
当 OS 侧出现 /dev/sdX 异常时，应先判断该设备属于 AHCI 直连盘、NVMe 盘还是 Broadcom RAID 逻辑盘；若属于 Broadcom 路径，则通过 OS Drive Name -> VD -> DG -> EID:Slot 反查到具体物理槽位，再做点灯、换盘或进一步控制器层排障。

7）Day7 我给你最终评分
这次不是 84 了，
这次我给你：
90/100
因为你现在已经完成了 Day7 最重要的闭环：

能识别控制器


能区分 AHCI / RAID / NVMe 三条路径


能识别单盘 RAID0


能把 Slot / DG / VD / /dev/sdX 对死


能做健康基线判断


能反向定位故障盘

扣掉的 10 分，主要留给后面更熟练的表达和实际故障演练。

8）Day8 最自然的衔接
下一节最适合接：
Day8：SAS / SATA 架构、背板、Expander、HBA 与链路识别
因为你现在已经会“看结果”了，
下一步就该学：

为什么一个 Enclosure 里能挂这么多盘


SAS/SATA 背板和 Expander 是怎么工作的


HBA、RAID、AHCI 各自站在哪一层


Device Speed / Link Speed / Connector Name 这些字段该怎么真正理解

你只要回一句“开始Day8”，我就按你这台机的实际环境继续讲。
对，你现在这句话已经抓到 RAID 卡 的核心了：
RAID 卡 = 管磁盘的独立控制器，通常插在 PCIe 上
但你现在混淆的是：
HBA、AHCI、RAID 到底谁和谁是一类，谁比谁大，谁在什么位置。
我给你按你现在最容易懂的方式拆开。

先给你一句总框架
这三个东西都和“主机怎么把磁盘接进来、识别、管理”有关，但不是同一层次。
你可以先这样记：

AHCI：主要是 SATA 控制器的工作规范/驱动模型


HBA：更像一个总称，意思是 主机总线适配器


RAID 卡：是一种更强的 存储控制器卡，它能在 HBA 基础上进一步做 RAID 管理

所以最简单先记成：
AHCI 更偏 SATA 控制方式
HBA 更偏“把盘接进主机”的适配器概念
RAID 更偏“在控制器上做磁盘编排和管理”

### 先说你已经熟悉的 RAID

RAID 你已经比较有感觉了，我只帮你把位置摆准。
RAID 卡是什么
RAID 卡本质上是一个 专门的存储控制器，它负责：

识别物理盘


管理物理盘状态


组 RAID0/1/5/10


给 OS 暴露逻辑盘


做 cache、rebuild、hot spare、告警、点灯

所以 RAID 卡的核心不是“让磁盘能连上”，而是：
在主机和物理盘之间，加了一层更强的管理和抽象。
比如你这台机：

Broadcom MegaRAID 9560-16i


8 块 SATA SSD


每块做成一个单盘 RAID0


OS 看到 /dev/sdc ~ /dev/sdj

这就是 RAID 卡在工作。

### HBA 到底是什么

HBA 全称
Host Bus Adapter
翻译成你容易理解的话就是：
主机总线适配器
它的意思很宽，不是只指某一个特别具体的芯片名。
它表达的是：

主机这边是 CPU/内存/PCIe


设备那边是磁盘/SAS/SATA/FC 等


中间需要一个“适配器”把两边连起来

这个适配器就可以叫 HBA

你先把 HBA 理解成什么
你先理解成：
HBA = 让主机能够接入和访问存储设备的控制器/适配器
它最核心的事是：

发现盘


建立通路


把盘呈现给 OS

但一般不强调 RAID 管理
纯 HBA 更像：

我负责把盘接进来


我负责让系统看见它


但我不一定帮你做复杂 RAID 抽象

所以你可以先粗暴理解为：

HBA 偏“连接与透传”


RAID 卡偏“连接 + 管理 + 逻辑抽象”


你机器里的 HBA 例子
你 lspci 里看到很多：

HiSilicon SAS 3.0 HBA


HiSilicon AHCI HBA

这里的 HBA 就是在表示：
这是主机接 SAS/SATA 设备的一类控制器。

### AHCI 到底是什么

这是最容易糊的地方。
AHCI 全称
Advanced Host Controller Interface
它不是“盘”，也不是“RAID 级别”，而是：
SATA 控制器的一套标准接口/工作模型
你可以把它理解成：

如果主机要接 SATA 盘


控制器和操作系统之间，需要有一套统一说话方式


AHCI 就是这套方式


AHCI 更像什么
更像：

SATA 控制器的标准模式


OS 驱动怎么跟控制器配合的一种规范

所以你在 dmesg 里看到：

scsi host1: ahci


scsi host2: ahci

它的意思不是“这是一块盘”，而是：
这两个 host 是由 AHCI 这套 SATA 控制器驱动起来的。
然后这两个 host 下挂了：

/dev/sda


/dev/sdb

也就是那两块 Intel SATA SSD。

### 你可以这样区分三者

我给你一个最实用的区分法。
1）AHCI
你把它看成：
SATA 控制器和 OS 交互的一种标准模式
关键词：

SATA


控制器接口规范


常见于主板 SATA 控制器


常见直连 SATA 盘


2）HBA
你把它看成：
主机接存储设备的适配器/控制器这一大类概念
关键词：

Host Bus Adapter


SAS/SATA/FC 都可能用这个词


更偏“接入和透传”


不一定做 RAID


3）RAID
你把它看成：
在控制器层对物理盘做逻辑组织和管理
关键词：

逻辑盘


物理盘


cache


rebuild


hot spare


degraded


RAID0/1/5/10


### 你现在可以先记一个关系图

CPU / 内存
│
PCIe
│
存储控制器
├─ AHCI 控制器  -> 接 SATA 盘 -> OS 直接看到盘
├─ SAS HBA     -> 接 SAS/SATA 盘 -> 常见透传/JBOD
└─ RAID 卡     -> 接 SAS/SATA 盘 -> 先做逻辑盘再给 OS
这个图你先吃透，比死背定义更有用。

### 结合你这台机器来理解，一下就清楚了

你这台机其实正好三种都出现了。
1）AHCI 路径
你在 dmesg 里看到：

scsi host1: ahci


scsi host2: ahci

然后出来：

/dev/sda


/dev/sdb

这说明：
两块 Intel SATA SSD 是走 AHCI 路径进系统的。
也就是：

主机 SATA 控制器


用 AHCI 模式


OS 直接识别到两块盘


2）SAS HBA 路径
你 lspci 里有：

HiSilicon SAS 3.0 HBA

这说明机器上也有 SAS HBA 控制器。
它的角色更偏：

提供 SAS/SATA 接入能力


让主机能连到这些盘/背板/expander

但你这次真正用来给 /dev/sdc~sdj 暴露盘的，不是它，而是 Broadcom RAID 卡。

3）RAID 路径
Broadcom 这张卡：

接了 8 块 SATA SSD


每块做成单盘 RAID0


变成 /dev/sdc ~ /dev/sdj

这就是标准 RAID 控制器行为。

### 你现在最容易犯的误区，我顺手帮你纠正

误区1：HBA 和 RAID 卡完全没关系
不对。
更准确说：

RAID 卡也是一种存储控制器/适配器


只不过它比“纯 HBA”多了一层 RAID 管理能力

你可以先近似理解成：
纯 HBA：偏透传
RAID 卡：偏管理

误区2：AHCI 和 HBA 是同一层的精确对等名词
也不完全对。
因为：

AHCI 更偏 SATA 控制接口规范


HBA 更偏适配器/控制器这类硬件角色名

所以 AHCI HBA 这种说法也会出现。
意思就是：
一个按 AHCI 方式工作的主机存储适配器/控制器

误区3：只要是插 PCIe 的就是 RAID 卡
不对。
插 PCIe 的可以是：

HBA 卡


RAID 卡


NVMe 控制器


网卡


NPU


USB 控制器

PCIe 只是总线，不等于功能。
这个很重要。

### 给你一个“现场判断口诀”

以后你看到一个存储控制器，先问 3 个问题：
第一个问题：它接的是什么盘？

SATA


SAS


NVMe

第二个问题：它有没有把物理盘变成逻辑盘？

有：大概率是 RAID 思路


没有：更像直通/HBA/JBOD

第三个问题：OS 看到的是裸盘还是逻辑盘？

裸盘：更像 AHCI/HBA 直通


逻辑盘：更像 RAID 卡暴露


### 我帮你压成一句你现在就能记住的话

你就先记这版，不要一下背太复杂：
AHCI 是 SATA 控制器和系统交互的标准方式；HBA 是主机连接存储设备的适配器/控制器概念；RAID 卡是在存储控制器基础上增加了磁盘编组、逻辑盘、缓存和重建管理能力的更强控制器。

### 再用“人话版”收一下

你可以把它们想成：

AHCI：怎么和 SATA 控制器说话


HBA：怎么把存储设备接进主机


RAID 卡：不光接进来，还替你管起来、编起来、虚拟成逻辑盘


### 你现在该达到的理解标准

如果我现在问你：
问：你机器里的 /dev/sda、/dev/sdb 更像走什么？
答：走 AHCI 路径 的直连 SATA 盘。
问：/dev/sdc ~ /dev/sdj 更像走什么？
答：走 Broadcom RAID 卡，是逻辑盘，不是裸物理盘。
问：HiSilicon SAS HBA 是干什么的？
答：是主机连接 SAS/SATA 存储的一类适配器/控制器，更偏接入和通路，不等于一定做 RAID。
你能答到这一步，就已经懂了。

下一步我可以直接给你讲一个你最需要的东西：
“HBA / AHCI / RAID / NVMe 四者放到同一张图里，到底分别站哪一层”。
可以，直接给你放到 同一张分层图 里看。
一张图先看懂
应用 / 文件系统 / LVM
│
Linux 块设备层
│
┌──────────────────────────────────────────────┐
│ OS看到的设备：/dev/sda  /dev/sdb  /dev/nvme0n1 │
└──────────────────────────────────────────────┘
│
│  这里往下，开始分成两大路
│
────────┼────────────────────────────────────────────
│
│ A路：SATA / SAS 传统存储路径
│
│   RAID / HBA / AHCI 所在区域
▼
┌──────────────────────────────────────────────┐
│ 存储控制器层                                  │
│                                              │
│ 1. AHCI 控制器                               │
│    - 主要服务 SATA                           │
│    - 常见主板直连 SATA                       │
│    - OS 常直接看到单盘                       │
│                                              │
│ 2. SAS HBA                                   │
│    - Host Bus Adapter                        │
│    - 负责把 SAS/SATA 设备接进主机            │
│    - 常见透传 / JBOD                         │
│                                              │
│ 3. RAID 卡                                   │
│    - 比 HBA 更强的存储控制器                 │
│    - 负责 RAID0/1/5/10、cache、rebuild       │
│    - 先做逻辑盘，再把逻辑盘给 OS             │
└──────────────────────────────────────────────┘
│
▼
SATA盘 / SAS盘 / 背板 / Expander
│
▼
物理磁盘

────────────────────────────────────────────────────

│
│ B路：NVMe 路径
▼
┌──────────────────────────────────────────────┐
│ PCIe / NVMe 控制器层                          │
│                                              │
│ NVMe = 协议                                  │
│ PCIe = 总线                                  │
│ NVMe SSD 通常直接挂 PCIe                     │
│ OS 常看到 /dev/nvme0n1                       │
└──────────────────────────────────────────────┘
│
▼
NVMe SSD（U.2 / M.2 / E1.S 等形态）

先给你一句最重要的话
这四个东西 不是同一维度，所以你以前才会混。
它们分别属于不同“层次/角色”

AHCI：更像 SATA 控制器的接口/工作规范


HBA：更像 存储接入适配器/控制器角色


RAID：更像 控制器上的磁盘管理与抽象能力


NVMe：更像 面向闪存的存储协议

所以它们不是“四选一”的并列关系。

### 四者分别站哪一层

1）AHCI 站在“控制器接口规范层”
你可以把它理解成：
主机怎么管理 SATA 控制器、OS 怎么和 SATA 控制器说话
所以 AHCI 常出现的位置是：

主板 SATA 控制器


AHCI 模式下的 SATA 口


Linux 里常看到 ahci

它下面接的通常是：

SATA SSD


SATA HDD

它上面给 OS 的结果通常是：

直接看到单盘 /dev/sda


/dev/sdb

你机器里的例子
你的：

/dev/sda


/dev/sdb

就是典型 AHCI 路径的 SATA 盘。

2）HBA 站在“主机接入存储的适配器层”
HBA 是个更宽的词。
你可以理解成：
主机要连存储设备，中间得有个适配器，这类东西就叫 HBA
所以 HBA 更像“角色名”，不是某一种固定协议。
常见的 HBA 可以接：

SAS


SATA


光纤存储（FC HBA）

在服务器本地盘这里，你先重点记：
SAS HBA 常用于把 SAS/SATA 盘接进来，并把设备透传给 OS
所以 HBA 更偏：

接入


枚举


透传


建通路

而不一定负责：

逻辑盘


RAID5


rebuild


hot spare


3）RAID 站在“磁盘管理和逻辑抽象层”
RAID 不是总线，也不是协议，它更像一种：
控制器上的磁盘组织与管理能力
RAID 卡一般本身也是插在 PCIe 上的独立控制器，但它和纯 HBA 的差别在于：
它不只是“把盘接进来”，还会：

管物理盘


做 RAID0/1/5/10


生成逻辑盘 VD/LD


做缓存


做重建


做热备


做点灯


做告警

所以 RAID 比 HBA 多了一层“管理与抽象”。
你机器里的例子
你的 Broadcom 9560-16i：

底下接 8 块 SATA SSD


每块单独做成一个 RAID0


再把 8 个逻辑盘给 OS


OS 看到 /dev/sdc ~ /dev/sdj

这就是 RAID 层在工作。

4）NVMe 站在“存储协议层”
这个最关键的一点是：
NVMe 不是 RAID，不是 HBA，不是 AHCI。
NVMe 是一种存储协议，专门为闪存和并发队列设计，通常跑在 PCIe 总线 上。
所以 NVMe 路径一般是：

CPU / PCIe Root Port


NVMe 控制器


NVMe SSD


OS 看到 /dev/nvme0n1

它通常不走传统 SATA/AHCI/SAS 那套链。
你机器里的例子
你的：

/dev/nvme0n1


/dev/nvme1n1

就是独立 NVMe 路径。

### 你要彻底改掉的一个误区

你以前容易把这四个看成同一类词，其实不是。
更准确地说：
AHCI
是 SATA 控制器的工作规范
HBA
是 主机接入存储设备的适配器/控制器角色
RAID
是 控制器上的磁盘编排和逻辑抽象能力
NVMe
是 存储协议
所以它们分别回答的问题不同：

AHCI：SATA 控制器按什么方式工作？


HBA：谁把存储设备接进主机？


RAID：盘有没有被控制器做逻辑管理？


NVMe：这块闪存盘用什么协议跟主机通信？


### 再给你一张“角色图”

PCIe 总线
│
├─ AHCI 控制器 ──────> SATA盘 ──────> OS常见单盘
│
├─ SAS HBA ─────────> SAS/SATA盘 ──> OS常见透传盘/JBOD
│
├─ RAID 卡 ─────────> SAS/SATA盘 ──> 先生成逻辑盘，再给OS
│
└─ NVMe 控制器/设备 ─> NVMe SSD ───> OS看到 nvme0n1
这张图里你要注意两件事：
第一
AHCI / HBA / RAID 更像“控制器/接入方式”这一侧的话题。
第二
NVMe 更像“设备协议”这一侧的话题。

### 把你机器代进去，你就彻底通了

你的机器里实际同时有三条路
路1：AHCI 路

控制器：AHCI


设备：Intel SATA SSD


OS：/dev/sda、/dev/sdb

路2：RAID 路

控制器：Broadcom 9560-16i


设备：8 块 SATA SSD


RAID 方式：单盘 RAID0


OS：/dev/sdc ~ /dev/sdj

路3：NVMe 路

控制器/路径：PCIe + NVMe


设备：两块 DERA NVMe


OS：/dev/nvme0n1、/dev/nvme1n1

所以你这台机本身就是最好的教材。

### 你现在可以用一句话概括四者关系

你就背这句：
AHCI 是 SATA 控制器的接口规范，HBA 是主机连接存储设备的适配器角色，RAID 是控制器上的磁盘编排和逻辑盘管理能力，NVMe 是运行在 PCIe 上的高性能存储协议。
这句你吃透，后面 Day8 就很好讲。

### 我再给你一个“面试版”表达

别人问你 HBA / AHCI / RAID / NVMe 分别是什么，你可以这样答：
AHCI 主要对应 SATA 控制器的标准工作模式；HBA 是主机接入存储设备的适配器，更多强调接入和透传；RAID 是在控制器层对物理盘做编组、缓存、重建和逻辑抽象；NVMe 则是基于 PCIe 的存储协议，通常用于高性能 SSD，和传统 SATA/SAS 路径不是一套体系。
这段已经很像工程师表达了。

### 最后给你一个最容易记的“口诀”

口诀版
AHCI 管 SATA 说话
HBA 管存储接入
RAID 管磁盘编组
NVMe 管高速闪存协议

下一步最适合接着讲的，就是 Day8：SAS / SATA / 背板 / Expander / HBA / RAID 在一台服务器里怎么串起来。


## 硬件对照表

| OS设备 | 容量 |
|---|---|
| /dev/sda | ? |
|---|---|
| /dev/sdb | ? |
|---|---|


## 硬件对照表

| EID:Slot | DID |
|---|---|
| 252:0 | 2 |
|---|---|
| 252:1 | 9 |
|---|---|
| 252:2 | 3 |
|---|---|
| 252:3 | 5 |
|---|---|
| 252:4 | 4 |
|---|---|
| 252:5 | 6 |
|---|---|
| 252:6 | 7 |
|---|---|
| 252:7 | 8 |
|---|---|

