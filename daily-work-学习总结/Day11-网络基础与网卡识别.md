```bash
[root@bogon ~]# ip -br link
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>
eno1             UP             2c:da:3f:15:b5:0a <BROADCAST,MULTICAST,UP,LOWER_UP>
eno2             DOWN           2c:da:3f:15:b5:0b <NO-CARRIER,BROADCAST,MULTICAST,UP>
eno3             DOWN           2c:da:3f:15:b5:0c <NO-CARRIER,BROADCAST,MULTICAST,UP>
eno4             DOWN           2c:da:3f:15:b5:0d <NO-CARRIER,BROADCAST,MULTICAST,UP>
```





```bash
[root@bogon ~]# ethtool eno1
Settings for eno1:
Supported ports: [ MII ]
Supported link modes:   10baseT/Half 10baseT/Full
100baseT/Half 100baseT/Full
1000baseT/Full
Supported pause frame use: Symmetric Receive-only
Supports auto-negotiation: Yes
Supported FEC modes: Not reported
Advertised link modes:  10baseT/Half 10baseT/Full
100baseT/Half 100baseT/Full
1000baseT/Full
Advertised pause frame use: Symmetric
Advertised auto-negotiation: Yes
Advertised FEC modes: Not reported
Link partner advertised link modes:  10baseT/Half 10baseT/Full
100baseT/Half 100baseT/Full
1000baseT/Full
Link partner advertised pause frame use: Symmetric
Link partner advertised auto-negotiation: Yes
Link partner advertised FEC modes: Not reported
Speed: 1000Mb/s
Duplex: Full
Auto-negotiation: on
Port: MII
PHYAD: 1
Transceiver: internal
Supports Wake-on: d
Wake-on: d
Current message level: 0x00000036 (54)
probe link ifdown ifup
Link detected: yes
[root@bogon ~]# ethtool -i eno1
driver: hns3
version: 5.10.0-216.0.0.115.oe2203sp4.aa
firmware-version: 3.10.22.8
expansion-rom-version:
bus-info: 0000:35:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: no
supports-register-dump: yes
supports-priv-flags: yes
[root@bogon ~]# ethtool eno2
Settings for eno2:
Supported ports: [ MII ]
Supported link modes:   10baseT/Half 10baseT/Full
100baseT/Half 100baseT/Full
1000baseT/Full
Supported pause frame use: Symmetric Receive-only
Supports auto-negotiation: Yes
Supported FEC modes: Not reported
Advertised link modes:  10baseT/Half 10baseT/Full
100baseT/Half 100baseT/Full
1000baseT/Full
Advertised pause frame use: Symmetric
Advertised auto-negotiation: Yes
Advertised FEC modes: Not reported
Speed: Unknown!
Duplex: Unknown! (255)
Auto-negotiation: on
Port: MII
PHYAD: 3
Transceiver: internal
Supports Wake-on: d
Wake-on: d
Current message level: 0x00000036 (54)
probe link ifdown ifup
Link detected: no
[root@bogon ~]# ethtool -i eno2
driver: hns3
version: 5.10.0-216.0.0.115.oe2203sp4.aa
firmware-version: 3.10.22.8
expansion-rom-version:
bus-info: 0000:35:00.1
supports-statistics: yes
supports-test: yes
supports-eeprom-access: no
supports-register-dump: yes
supports-priv-flags: yes
[root@bogon ~]# ethtool eno3
Settings for eno3:
Supported ports: [ MII ]
Supported link modes:   10baseT/Half 10baseT/Full
100baseT/Half 100baseT/Full
1000baseT/Full
Supported pause frame use: Symmetric Receive-only
Supports auto-negotiation: Yes
Supported FEC modes: Not reported
Advertised link modes:  10baseT/Half 10baseT/Full
100baseT/Half 100baseT/Full
1000baseT/Full
Advertised pause frame use: Symmetric
Advertised auto-negotiation: Yes
Advertised FEC modes: Not reported
Speed: Unknown!
Duplex: Unknown! (255)
Auto-negotiation: on
Port: MII
PHYAD: 5
Transceiver: internal
Supports Wake-on: d
Wake-on: d
Current message level: 0x00000036 (54)
probe link ifdown ifup
Link detected: no
[root@bogon ~]# ethtool -i eno3
driver: hns3
version: 5.10.0-216.0.0.115.oe2203sp4.aa
firmware-version: 3.10.22.8
expansion-rom-version:
bus-info: 0000:35:00.2
supports-statistics: yes
supports-test: yes
supports-eeprom-access: no
supports-register-dump: yes
supports-priv-flags: yes
[root@bogon ~]# ethtool eno4
Settings for eno4:
Supported ports: [ MII ]
Supported link modes:   10baseT/Half 10baseT/Full
100baseT/Half 100baseT/Full
1000baseT/Full
Supported pause frame use: Symmetric Receive-only
Supports auto-negotiation: Yes
Supported FEC modes: Not reported
Advertised link modes:  10baseT/Half 10baseT/Full
100baseT/Half 100baseT/Full
1000baseT/Full
Advertised pause frame use: Symmetric
Advertised auto-negotiation: Yes
Advertised FEC modes: Not reported
Speed: Unknown!
Duplex: Unknown! (255)
Auto-negotiation: on
Port: MII
PHYAD: 7
Transceiver: internal
Supports Wake-on: d
Wake-on: d
Current message level: 0x00000036 (54)
probe link ifdown ifup
Link detected: no
[root@bogon ~]# ethtool -i eno4
driver: hns3
version: 5.10.0-216.0.0.115.oe2203sp4.aa
firmware-version: 3.10.22.8
expansion-rom-version:
bus-info: 0000:35:00.3
supports-statistics: yes
supports-test: yes
supports-eeprom-access: no
supports-register-dump: yes
supports-priv-flags: yes
```

当前只有eno1是连通状态、eno1、2、3、4同属于一张网卡的四个网口、
没有疑似rdma nic






```bash
[root@bogon ~]# rdma link
link roceo1/1 state ACTIVE physical_state LINK_UP netdev eno1
link roceo2/1 state DOWN physical_state DISABLED netdev eno2
link roceo3/1 state DOWN physical_state DISABLED netdev eno3
link roceo4/1 state DOWN physical_state DISABLED netdev eno4
[root@bogon ~]# ibdev2netdev
```

-bash: ibdev2netdev：未找到命令
```bash
[root@bogon ~]# ls /sys/class/infiniband
roceo1  roceo2  roceo3  roceo4
```

本机 eno1~eno4 使用相同驱动 hns3，固件版本一致，PCI 地址连续为 0000:35:00.0 ~ 0000:35:00.3，可判断它们属于同一张 4 口物理网卡。通过 rdma link 可进一步确认该网卡支持 RoCE，且 roceo1~roceo4 分别对应 eno1~eno4。当前仅 eno1 / roceo1 处于活动状态，链路已建立；其余端口由于无物理链路，因此对应 RDMA 端口也为 DOWN / DISABLED。我已经能够判断普通网口状态、驱动、PCI 归属，并完成以太网口与 RDMA 设备映射。










已接上你以前的长期记忆，当前状态是：
你正在按 《100天服务器系统工程强化训练手册（Hard Mode）》 走主线，目标是从 Kunpeng ARM 服务器整合测试工程师 提升到 系统工程师。
我记得你的实验环境重点有：

Kunpeng ARM 服务器


大致拓扑：2 Socket / 4 NUMA / 256 CPU


设备：NVMe（U.2/M.2）/ RAID / NIC / Atlas 300I A2


RAID 工具链要区分：


2U 华为服务器：hiraidadm


6U 服务器：Broadcom 工具链


你已经完成并建立过长期记忆的重点：


Day1-4：Linux基础、硬件识别、NUMA/CPU/内存/PCIe、性能观察


Day5：存储路径识别，能区分 NVMe / SATA / SAS / RAID


Day6：理解 NVMe controller / namespace / smart-log


按你刚上传的总表，Day7-10 已衔接到：


Day7 RAID控制器与逻辑盘


Day8 NVMe顺序读写基线


Day9 NVMe随机IO基线


Day10 存储自动检测脚本 storage_check.py v1

现在正式开始 Day11。

Day11：网卡与链路基础
今天的表格目标

阶段：Phase1-网络


周次：W2


模块：Network


主题：网卡与链路基础


学习重点：
认识 eno1-eno4、链路状态、速率、驱动；把 网卡与 RDMA NIC 对上


命令/工具：
ip link
ethtool
ethtool -i


实验/训练任务：
记录各网口 up/down、速率、驱动、bus-info；解释 1 张卡 4 个口


当日硬性产出：
NIC信息表


达成效果：
会看网卡基础状态和驱动


### 先把核心概念讲透

- 1. 网卡、端口、接口名，不是一个东西
你今天一定要分清这 3 层：
物理层

1 张网卡(card)：插在 PCIe 槽里的一块卡


1 张卡可以有多个口(port)：例如 2口卡、4口卡

Linux 看到的系统对象

每个口通常会对应一个 网络接口(interface)


Linux 名字可能叫：


eno1


eno2


enp129s0f0


eth0

也就是说：
1 张 4 口网卡 = Linux 里常常会出现 4 个接口名
所以你看到 eno1 eno2 eno3 eno4，通常不是 4 张卡，而更可能是：

1 张 4 口卡
或


2 张 2 口卡
或


板载口 + 扩展卡混合

这就要靠 driver + bus-info 去判断。

- 2. link state 是什么
你今天会反复看到：

UP


DOWN


LOWER_UP


NO-CARRIER

重点理解：
ip link 里的 UP
表示 接口在软件层被启用
不代表线一定通。
LOWER_UP / Link detected: yes
表示 物理链路通了
这通常意味着：

网线/光模块已插好


对端交换机端口有信号


速率协商成功

DOWN / NO-CARRIER
常见原因：

没插线


对端没起


光模块不兼容


口被禁用


驱动异常

所以你要记住一句：
接口 up，不等于链路就通；链路通，要看 lower_up 或 ethtool 的 Link detected

- 3. 速率 speed 是什么
ethtool eno1 常见会看到：

1000Mb/s


10000Mb/s


25000Mb/s


100000Mb/s


Unknown!

解释：

1000Mb/s = 1G


10000Mb/s = 10G


25000Mb/s = 25G


100000Mb/s = 100G

为什么会出现 Unknown!
常见是：

接口 down


没链路


某些驱动不返回


某些虚拟接口不支持

所以：
速率一定要结合链路状态一起看，不能单独看

- 4. driver 是什么
ethtool -i eno1 会看到类似：

driver: hns3


driver: mlx5_core


driver: ixgbe


driver: ice


driver: bnxt_en

这很重要，因为 driver 基本能告诉你这是什么系的卡：

hns3：华为系常见


mlx5_core：Mellanox / NVIDIA，常见于 RDMA / RoCE


ixgbe：Intel 10G


ice：Intel 新一代高速网卡


bnxt_en：Broadcom

所以：
driver 是识别网卡家族的第一把钥匙

- 5. bus-info 是什么
ethtool -i eno1 里常见：

bus-info: 0000:81:00.0

它的格式是 PCI 地址：
域:总线:设备.功能
例如：

0000:81:00.0


0000:81:00.1


0000:81:00.2


0000:81:00.3

这组就非常像：
同一张 4 口网卡的 4 个 function
也就是：

同一个 PCI 设备槽位


不同 function 对应不同口

所以今天最重要的判断逻辑之一就是：
如果 bus-info 很接近，尤其是同一个设备号 .0/.1/.2/.3，大概率属于同一张多口网卡

- 6. “把网卡与 RDMA NIC 对上”是什么意思
你的训练表里这一句非常关键。
意思不是只看普通以太网口，而是要能判断：

哪些接口只是普通网卡口


哪些接口属于 支持 RDMA 的高速 NIC


它们在 Linux 里叫什么


它们对应哪个 PCI 设备

常见经验判断
如果你看到：

driver: mlx5_core

那通常就要高度怀疑它是：

Mellanox / NVIDIA 高速卡


常带 RDMA / RoCE 能力

如果系统里还有这些命令可用：

rdma link


ibdev2netdev

就更容易把 RDMA 设备名 和 Linux 网口名 对上。

### 今天你该怎么做：标准操作流程

第1步：先看所有接口概览
ip -br link
你重点看：

有哪些口：eno1 eno2 eno3 eno4 ...


哪些是 UP


哪些是 DOWN


哪些有 LOWER_UP

你先不要急着解释，先做总览。

第2步：逐个看链路状态和速率
ethtool eno1
ethtool eno2
ethtool eno3
ethtool eno4
你重点记录：

Speed


Duplex


Link detected

你真正要写进表里的，不是整段原始输出，而是提炼后的信息。

第3步：逐个看驱动和 PCI 地址
ethtool -i eno1
ethtool -i eno2
ethtool -i eno3
ethtool -i eno4
你重点记录：

driver


firmware-version


bus-info

这是今天的核心数据。

第4步：把“接口名”和“物理卡”对应起来
当你拿到这些 bus-info 之后，开始归类。
例如你看到：

eno1 -> 0000:81:00.0


eno2 -> 0000:81:00.1


eno3 -> 0000:81:00.2


eno4 -> 0000:81:00.3

那就可以写结论：
eno1-eno4 很可能属于同一张 4 口卡
如果是：

eno1 -> 0000:81:00.0


eno2 -> 0000:81:00.1


eno3 -> 0000:82:00.0


eno4 -> 0000:82:00.1

那更可能是：
两张 2 口卡

### 今天最实用的采集命令

你可以直接跑这个：
for nic in $(ls /sys/class/net | grep -v lo); do
echo "===== $nic ====="
ip -br link show "$nic"
ethtool "$nic" 2>/dev/null | egrep "Speed|Duplex|Link detected"
ethtool -i "$nic" 2>/dev/null | egrep "driver|firmware-version|bus-info"
echo
done
这个命令会帮你快速抓出今天最关键的信息。

### NIC信息表模板

你今天的硬性产出就是这个表。你可以按下面格式记：

### 今天必须学会的 5 个判断

判断1：这个口是不是“真的通”
看这个：

Link detected: yes
或


LOWER_UP

不是只看 UP。

判断2：这个口有没有实际速率
看：

Speed: 1000Mb/s / 25000Mb/s / 100000Mb/s

如果是 Unknown!，多半没建立物理链路。

判断3：这几个口是不是同一张卡
看：

bus-info

如果是同一个设备的 .0 .1 .2 .3
通常就是同一张多口卡。

判断4：这是不是 RDMA NIC
优先看：

driver

如果是 mlx5_core，通常强相关。
如果你机器上有这些命令，再补充确认：
rdma link
ibdev2netdev

判断5：为什么“1 张卡 4 个口”
标准解释你今天必须能说出来：
因为一张物理网卡可以集成多个物理端口，每个端口在 Linux 中暴露为独立网络接口；这些接口通常共享相近的 PCI 地址，只是在 function 编号上不同，例如 .0/.1/.2/.3。
这句话是你今天的“面试表达版”。

### 常见坑，今天提前避开

- 1. UP 不等于链路正常
软件启用了，不代表线通了。
- 2. DOWN 不一定是故障
可能只是没接线、没配、没用到。
- 3. Speed: Unknown! 不一定是坏卡
很多时候只是链路没起来。
- 4. 同一张卡的多个口，不一定接口名连续
不一定总是 eno1-eno4，也可能名字乱一些，所以最终还是要看 bus-info。
- 5. bond/team 会干扰判断
如果机器做了 bond，先分清：

bond0 是逻辑口


eno1/eno2 才是物理口


### 今天的标准作业

你今天按这个顺序完成：
任务1：列出所有网口
ip -br link
任务2：逐口记录状态/速率/驱动/bus-info
ethtool eno1
ethtool -i eno1
对每个网口都做。
任务3：填写 NIC 信息表
至少把以下字段填全：

网口名


up/down


Link detected


Speed


driver


bus-info

任务4：回答两个问题

哪些口当前真的连通？


哪些口属于同一张物理网卡？

任务5：写一句总结
模板直接给你：
今天我已经能通过 ip link、ethtool、ethtool -i 判断网口的基础状态，能区分“接口启用”和“物理链路正常”的区别，并能通过 bus-info 判断多个网口是否属于同一张多口网卡。

### 今天的达成标准

你完成 Day11，不是“命令跑过了”，而是你能做到这 4 件事：

看到 eno1-eno4 不慌


能判断哪个口是真通、哪个只是启用


能看懂速率和驱动


能解释“1 张卡 4 个口”为什么成立


### 你现在可以直接开练

直接按这个顺序跑：
ip -br link
ethtool eno1
ethtool -i eno1
ethtool eno2
ethtool -i eno2
ethtool eno3
ethtool -i eno3
ethtool eno4
ethtool -i eno4
如果你愿意最高效推进，下一条把你的输出贴给我，我直接帮你做：
1）NIC信息表整理
2）判断哪些口属于同一张卡
3）判断哪些口疑似 RDMA NIC
很好，你这份 Day11 作业已经基本达标 了。
我先帮你整理成标准版，再给你结论和点评。

Day11 标准整理版：NIC 信息表
有一个小修正：

你写的 eno1 -> 000:35:00.0，大概率应为 0000:35:00.0


因为另外三个都是 0000:35:00.x，这才是标准 PCI 地址格式


你的结论，已经可以这样说
1）当前真正连通的口
只有 eno1 真正建立了物理链路。
判断依据：

状态：UP


物理链路：yes


速率：1G


双工：Full

这说明：
eno1 不只是软件启用，而且物理层已经协商成功，目前工作在 1Gbps 全双工

2）其余三个口的状态

eno2


eno3


eno4

都处于：

DOWN


Link detected: no


Speed: Unknown


Duplex: Unknown

这说明：
这三个口当前没有建立物理链路。大概率是未接线、对端未启用、未插模块，或者当前没有使用。
这里要注意，你理解已经对了：
Unknown 不等于坏卡，更多时候只是 链路没起来

3）这 4 个口属于同一张物理网卡
这个判断是 正确的。
因为它们的 bus-info 是：

0000:35:00.0


0000:35:00.1


0000:35:00.2


0000:35:00.3

这是一组非常标准的：
同一 PCI 设备，不同 function
所以可以下结论：
eno1 ~ eno4 很可能就是 同一张 4 口网卡 暴露出来的 4 个 Linux 网络接口。

4）“1 张卡 4 个口”你现在已经能解释了
你现在可以直接这样表达：
一张物理网卡可以集成多个物理端口，每个端口在 Linux 中表现为一个独立接口；这些接口通常共享相同的 PCI 设备号，只在 function 编号上不同，例如 0000:35:00.0 ~ 0000:35:00.3。
这句话已经是面试可用表达了。

进一步分析：驱动 hns3 说明什么
你这 4 个口全部是：

driver: hns3


固件版本一致：3.10.22.8

这进一步加强了“同卡A”的判断。
hns3 一般说明这是 华为系网卡驱动。
结合你的环境，很符合 Kunpeng / 华为服务器平台特征。
所以今天你至少已经会做这三件事了：

通过 ethtool 看链路状态


通过 ethtool -i 看驱动和 PCI 地址


通过 bus-info 判断多口卡归属


关于“RDMA NIC 对上”，你这次还差半步
你今天的表已经把普通网口层面做对了。
但训练表里还有一句：
把网卡与 RDMA NIC 对上
基于你目前这份信息，还不能完全确认 RDMA 对应关系，因为你现在只有：

网口名


驱动


固件


bus-info

这足够判断“是不是同一张多口卡”，但还 不足以确认 RDMA 设备映射。
当前能做的稳妥结论

这 4 个接口属于同一张 hns3 网卡


其中 eno1 有链路，eno2~eno4 无链路


是否属于 RDMA NIC，当前证据还不够

真正要对 RDMA，还需要这些命令
你后面补这两个最有价值：
rdma link
ibdev2netdev
如果系统没有 ibdev2netdev，也可以补：
ls /sys/class/infiniband
这样我就能帮你把：

RDMA 设备名


Linux 网口名


PCI 地址

三者彻底对齐。

这次作业的点评
做得对的地方
你已经准确抓到了今天最关键的字段：

状态


物理链路


速率


双工


驱动


固件版本


bus-info


归属判断

这说明你不是在“抄命令输出”，而是在做结构化整理，这非常对。

还可以更严谨的地方
- 1. 统一格式
建议以后统一成：

yes / no


0000:35:00.0

不要出现：

No


000:35:00.0

因为后面做自动化脚本时，格式统一很重要。
- 2. 状态最好区分“管理状态”和“物理链路”
以后可以拆成两列：

管理状态：UP / DOWN


物理链路：yes / no

这样更清楚，也便于自动化采集。
- 3. 备注列可以加用途判断
比如：

eno1：当前在用


eno2~eno4：未接线/预留口

这会让表更接近真实运维文档。

你今天的 Day11 结论版总结
你可以直接记成这段：
本机 eno1~eno4 使用相同驱动 hns3，固件版本一致，PCI 地址连续为 0000:35:00.0 ~ 0000:35:00.3，可判断它们属于同一张 4 口物理网卡。当前只有 eno1 建立了物理链路，工作在 1G Full；eno2~eno4 均未建立链路，因此速率与双工显示为 Unknown。我已经能够通过 ip link、ethtool、ethtool -i 判断网口基础状态，并通过 bus-info 识别多口网卡归属。

Day11 评价
我给你这次 8.8/10。
扣分点不是理解问题，而是：

表格格式还不够整齐


RDMA 对应关系还没补齐最后一步

但核心目标已经完成了：

会看网口基础状态


会看驱动


会看 bus-info


会解释 1 张卡 4 个口


把 rdma link 和 ibdev2netdev 的输出贴来，我可以把 Day11 最后一块“RDMA NIC 对应关系” 也帮你补完。
很好，这下 Day11 最后一块已经补齐 了：
你已经把 普通网口 ↔ RDMA 设备 对上了。

Day11 补充结论：RDMA NIC 对应关系已确认
你的输出是：
rdma link
link roceo1/1 state ACTIVE physical_state LINK_UP netdev eno1
link roceo2/1 state DOWN physical_state DISABLED netdev eno2
link roceo3/1 state DOWN physical_state DISABLED netdev eno3
link roceo4/1 state DOWN physical_state DISABLED netdev eno4
以及：
ls /sys/class/infiniband
roceo1  roceo2  roceo3  roceo4
这说明：

roceo1 对应 eno1


roceo2 对应 eno2


roceo3 对应 eno3


roceo4 对应 eno4

也就是说：
这张 hns3 四口网卡，不只是普通以太网卡口，同时每个口还对应一个 RoCE RDMA 设备。

现在可以下的完整结论
- 1. 这是一张支持 RoCE 的 4 口网卡
证据链已经完整：

网口驱动全是 hns3


PCI 地址连续：0000:35:00.0 ~ 0000:35:00.3


RDMA 设备也一一对应：


roceo1 ↔ eno1


roceo2 ↔ eno2


roceo3 ↔ eno3


roceo4 ↔ eno4

所以现在可以非常明确地说：
这是 同一张 4 口、支持 RoCE 的网卡，每个以太网口都有对应的 RDMA 设备实例。

- 2. 当前只有 eno1 / roceo1 处于真正工作状态
你看到：

roceo1 state ACTIVE physical_state LINK_UP netdev eno1

这和前面的 eno1 信息完全吻合：

eno1：UP


物理链路：yes


速率：1G


RDMA 设备：roceo1


RDMA 状态：ACTIVE


RDMA 物理状态：LINK_UP

说明：
eno1 不仅普通以太网链路是通的，而且它对应的 RoCE 端口也已经处于活动状态。

- 3. eno2~eno4 目前没有激活 RDMA 链路
你看到：

roceo2 state DOWN physical_state DISABLED netdev eno2


roceo3 state DOWN physical_state DISABLED netdev eno3


roceo4 state DOWN physical_state DISABLED netdev eno4

这与前面的普通网口状态也一致：

eno2~eno4 都没有物理链路


所以它们对应的 RDMA 端口也处于 DOWN / DISABLED

这说明：
RDMA 端口是否激活，和对应以太网口的链路状态密切相关。网口没链路，RoCE 端口一般也起不来。

为什么 ibdev2netdev 找不到，不是问题
你这里：
-bash: ibdev2netdev：未找到命令
这很正常，不代表 RDMA 不可用。
只是说明系统里没装这个工具，或者环境变量里没有它。
你已经用这两个方法完成了同样的事情：

rdma link


/sys/class/infiniband

所以这次完全够用了。

你的 Day11 最终标准版表格
我帮你升级成可交付版：

你今天已经真正学会的东西
- 1. 能把普通网口和 RDMA 设备对上
这是今天最关键的增强点：

eno1 ↔ roceo1


eno2 ↔ roceo2


eno3 ↔ roceo3


eno4 ↔ roceo4


- 2. 能判断这不是“4 张卡”，而是“1 张 4 口卡”
依据是：

同驱动


同固件版本


连续 bus-info


RDMA 设备也一一成组对应


- 3. 能理解 RoCE 的基本依赖关系
你现在可以这么理解：
RoCE 是跑在以太网口之上的 RDMA 能力。对应网口没有链路，RoCE 端口通常也不会是 ACTIVE。

现在你的 Day11 总结可以升级成这一版
本机 eno1~eno4 使用相同驱动 hns3，固件版本一致，PCI 地址连续为 0000:35:00.0 ~ 0000:35:00.3，可判断它们属于同一张 4 口物理网卡。通过 rdma link 可进一步确认该网卡支持 RoCE，且 roceo1~roceo4 分别对应 eno1~eno4。当前仅 eno1 / roceo1 处于活动状态，链路已建立；其余端口由于无物理链路，因此对应 RDMA 端口也为 DOWN / DISABLED。我已经能够判断普通网口状态、驱动、PCI 归属，并完成以太网口与 RDMA 设备映射。

Day11 最终评分
这次我给你 9.6/10。
你现在已经完整达成了 Day11 目标：

会看 ip link


会看 ethtool


会看 ethtool -i


会判断多口卡归属


会把 网卡与 RDMA NIC 对上

还差的那 0.4 分，只是因为你现在还没有继续深入到：

RDMA 模式参数


PFC/ECN


RoCE 性能与调优

但那已经是后面的内容了，不属于今天范围。

Day11 结课
可以，先把这两个概念讲透，再给你几道检查题。
一句话先记住

RDMA：一种“远程直接内存访问”的通信能力


InfiniBand：一种专门为高性能通信设计的网络/互连体系


关系：InfiniBand 可以承载 RDMA，但 RDMA 不等于 InfiniBand


- 1. RDMA 是什么
RDMA 全称是：
Remote Direct Memory Access
远程直接内存访问
它的核心意思是：
一台机器可以通过网卡，直接把数据写到另一台机器的内存里，或者直接从对方内存里读数据，而且尽量少经过对方 CPU 的参与。
所以 RDMA 追求的是这几件事：

低延迟


高带宽


低 CPU 开销


零拷贝 / 少拷贝


适合大规模数据传输


你可以把它和普通网络对比着理解
普通 TCP/IP 通信
数据路径通常比较长：
应用 -> 内核协议栈 -> 网卡 -> 网络 -> 对端网卡 -> 对端内核 -> 对端应用
这中间会有：

多次拷贝


协议栈处理


CPU 参与较多


延迟更高

RDMA 通信
目标是尽量缩短路径：
应用准备好内存 -> RDMA 网卡直接搬运 -> 对端内存
因此它更适合：

AI 训练集群


HPC 高性能计算


分布式存储


低延迟消息传输


- 2. InfiniBand 是什么
InfiniBand 不是单纯一个“命令”或者“驱动名”，它本质上是：
一整套高性能互连架构 / 网络体系
它包括：

链路层


传输机制


寻址方式


交换网络


队列对（QP）通信模型


RDMA 能力

所以你可以把 InfiniBand 理解成：
一种“天生为 RDMA 和高性能通信而设计”的专用网络世界
它常见在：

超算


HPC 集群


大规模训练集群


极低延迟场景


- 3. RDMA 和 InfiniBand 到底是什么关系
最容易混的地方就在这。
正确关系是：
RDMA = 能力 / 通信方式
强调的是：

能直接访问远端内存


减少 CPU 参与


低延迟高吞吐

InfiniBand = 一种网络体系
它原生支持 RDMA
所以：
InfiniBand 是一种实现 RDMA 的网络环境
但 RDMA 还可以跑在别的网络上

- 4. RDMA 不只跑在 InfiniBand 上
现在常见有 3 类：
1）InfiniBand
原生 RDMA 网络
最“正统”
2）RoCE
全称：
RDMA over Converged Ethernet
意思是：
在以太网上实现 RDMA
也就是你现在机器上看到的这个：

roceo1


roceo2


roceo3


roceo4

这已经很明确说明：
你现在这台机器走的是 RoCE，不是传统意义上的 InfiniBand 交换网络。
3）iWARP
也是 RDMA over Ethernet 的一种方案
但你目前环境里看到的重点不是它。

- 5. 结合你机器来理解
你前面看到的是：
rdma link
link roceo1/1 state ACTIVE physical_state LINK_UP netdev eno1
这里已经透露了重要信息：

netdev eno1：说明它绑定的是普通以太网口


roceo1：说明这个口具有 RoCE RDMA 能力


也就是说：

你的 RDMA 是基于 Ethernet 网口实现的
这属于 RoCE
不是那种“纯 InfiniBand 口”的形态

- 6. 为什么 Linux 里会出现 /sys/class/infiniband
这个地方特别容易误导初学者。
你机器里有：
ls /sys/class/infiniband
roceo1 roceo2 roceo3 roceo4
很多人一看就以为：
“我这机器用的是 InfiniBand”
其实不一定。
Linux/RDMA 子系统历史上很多接口、目录、工具都沿用了 infiniband 这个命名。
所以：
/sys/class/infiniband 里出现设备，不代表你的物理网络一定是 InfiniBand
它也可能是 RoCE 设备
你这台机器就是典型例子：

目录名在 infiniband


但设备名叫 roceoX


绑定的是 enoX


所以它本质上是 RoCE over Ethernet


- 7. 你现在该怎么区分这两个概念
你可以这样记：
RDMA
回答“它是干什么的”

一种高性能数据传输方式


远端直接内存访问


低延迟、低 CPU、少拷贝

InfiniBand
回答“它跑在哪种网络体系里”

一种专门的高性能互连架构


原生支持 RDMA


- 8. 再给你一个最实用的类比
可以这样类比：

RDMA 像“高速运输方式”


InfiniBand 像“专门为高速运输修建的专用高速铁路”


RoCE 像“在以太网公路体系上，尽量实现类似高速运输效果”

这个类比不完全严谨，但非常适合入门记忆。

- 9. 你当前环境的正确结论
基于你前面的输出，你现在可以明确说：
我这台机器的网卡支持 RDMA，具体表现为 RoCE 设备 roceo1~roceo4 分别对应以太网口 eno1~eno4。因此这里的 RDMA 是跑在以太网上的，不是传统 InfiniBand 专网形态。
这句话很重要，说明你已经不混淆了。

- 10. 给你几个检查题
你先自己想，再看答案会更好。
题1
RDMA 是一种网络类型，还是一种通信能力？
题2
InfiniBand 和 RDMA 是不是同一个东西？
题3
RoCE 属于 InfiniBand，还是属于 RDMA over Ethernet？
题4
为什么 /sys/class/infiniband 里有设备，并不一定说明机器跑的是 InfiniBand 网络？
题5
你机器里的 roceo1 -> eno1 说明了什么？

参考答案
1
RDMA 是一种 通信能力/数据传输方式，不是单纯网络类型。
2
不是。
InfiniBand 是网络体系，RDMA 是高性能通信能力。
InfiniBand 可以承载 RDMA。
3
RoCE 属于 RDMA over Ethernet。
4
因为 Linux 的 RDMA 子系统很多接口沿用了 infiniband 这个历史命名，RoCE 设备也会出现在这个目录下。
5
说明 eno1 这个以太网口对应一个 RoCE RDMA 设备 roceo1，即该网口具备 RDMA 能力。

你现阶段最该背下来的标准表达
RDMA 是远程直接内存访问，是一种高性能通信能力；InfiniBand 是一种专门为高性能通信设计的互连体系，原生支持 RDMA。除了 InfiniBand，RDMA 也可以运行在以太网上，例如 RoCE。我当前机器上的 roceo1~roceo4 对应 eno1~eno4，说明这里使用的是 RoCE 型 RDMA，而不是传统 InfiniBand 专网。
你要是愿意，我下一条可以继续给你讲：
“RoCE、InfiniBand、普通以太网三者到底差在哪”
这个会直接把你 Day11 后面的网络/RDMA基础打牢。


## 硬件对照表

| 网口 | 状态 |
|---|---|
| eno1 | UP |
|---|---|
| eno2 | DOWN |
|---|---|
| eno3 | DOWN |
|---|---|
| eno4 | DOWN |
|---|---|


## 硬件对照表

| 网口 | 状态 |
|---|---|
| eno1 | UP |
|---|---|
| eno2 | DOWN |
|---|---|
| eno3 | DOWN |
|---|---|
| eno4 | DOWN |
|---|---|


## 硬件对照表

| 网口 | 状态 |
|---|---|
| eno1 | UP |
|---|---|
| eno2 | DOWN |
|---|---|
| eno3 | UP |
|---|---|
| eno4 | DOWN |
|---|---|


## 硬件对照表

| 网口 | 状态 |
|---|---|
| eno1 | UP |
|---|---|
| eno2 | DOWN |
|---|---|
| eno3 | DOWN |
|---|---|
| eno4 | DOWN |
|---|---|


## 硬件对照表

| 网口 | 状态 |
|---|---|
| eno1 | UP |
|---|---|
| eno2 | DOWN |
|---|---|
| eno3 | DOWN |
|---|---|
| eno4 | DOWN |
|---|---|

