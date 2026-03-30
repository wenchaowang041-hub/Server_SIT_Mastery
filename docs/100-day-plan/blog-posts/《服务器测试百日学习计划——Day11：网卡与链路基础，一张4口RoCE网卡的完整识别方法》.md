大家好，我是JACK，本篇是服务器测试百日学习计划Day11。

前几天我们在存储层深耕了很久，今天切换赛道，进入网络模块第一篇——**网卡与链路基础**，把网口状态、驱动、多口卡识别、RDMA/RoCE对应关系彻底搞清楚。

---

## 一、先把三个层次分清楚

很多人刚接触服务器网络时容易把这三个概念混在一起：

```
物理层：1张网卡（Card）可以有多个物理端口（Port）
系统层：每个端口在Linux里对应一个网络接口（Interface），如 eno1、eno2
逻辑层：接口可以被组合成 Bond、VLAN、Bridge 等逻辑设备
```

所以看到 eno1 eno2 eno3 eno4，不要条件反射认为是4张网卡——更可能是1张4口卡，或者2张2口卡。怎么判断？靠 **driver + bus-info**，后面详细说。

---

## 二、接口状态：UP ≠ 链路通

这是今天最重要的一个认知纠正。

```bash
[root@bogon ~]# ip -br link
lo        UNKNOWN   00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>
eno1      UP        2c:da:3f:15:b5:0a <BROADCAST,MULTICAST,UP,LOWER_UP>
eno2      DOWN      2c:da:3f:15:b5:0b <NO-CARRIER,BROADCAST,MULTICAST,UP>
eno3      DOWN      2c:da:3f:15:b5:0c <NO-CARRIER,BROADCAST,MULTICAST,UP>
eno4      DOWN      2c:da:3f:15:b5:0d <NO-CARRIER,BROADCAST,MULTICAST,UP>
```

状态字段解读：

| 标志 | 含义 | 说明 |
|------|------|------|
| `UP` | 接口在软件层被启用 | 不代表线一定通 |
| `LOWER_UP` | **物理链路已建立** | 线通了，协商成功 |
| `NO-CARRIER` | 无物理载波 | 没插线、对端未起、模块不兼容 |
| `DOWN` | 接口未启用或无链路 | 需要结合 `Link detected` 判断 |

> ⚠️ **核心认知：接口 UP 不等于链路正常；链路通，要看 LOWER_UP 或 ethtool 的 Link detected: yes。**

---

## 三、ethtool — 看链路状态和速率

```bash
[root@bogon ~]# ethtool eno1
Settings for eno1:
  Supported ports: [ MII ]
  Supported link modes: 10baseT/Half 10baseT/Full
                        100baseT/Half 100baseT/Full
                        1000baseT/Full
  Speed: 1000Mb/s
  Duplex: Full
  Auto-negotiation: on
  Link detected: yes
```

```bash
[root@bogon ~]# ethtool eno2
Settings for eno2:
  Speed: Unknown!
  Duplex: Unknown! (255)
  Auto-negotiation: on
  Link detected: no
```

**关键字段提炼：**

| 字段 | eno1 | eno2~eno4 | 说明 |
|------|------|-----------|------|
| Speed | 1000Mb/s（1G）| Unknown! | Unknown! 说明没建立物理链路，不是坏卡 |
| Duplex | Full | Unknown! | 全双工/未知 |
| Link detected | yes | no | **这才是链路通不通的关键字段** |

> 💡 **速率要结合链路状态一起看**。Speed=Unknown! 绝大多数情况是"链路没起来"，不是网卡坏了。接上线、对端激活后一般会自动协商到正确速率。

---

## 四、ethtool -i — 看驱动和PCI归属

这是判断"多个网口是不是同一张卡"的核心命令：

```bash
[root@bogon ~]# ethtool -i eno1
driver: hns3
version: 5.10.0-216.0.0.115.oe2203sp4.aa
firmware-version: 3.10.22.8
bus-info: 0000:35:00.0

[root@bogon ~]# ethtool -i eno2
driver: hns3
firmware-version: 3.10.22.8
bus-info: 0000:35:00.1

[root@bogon ~]# ethtool -i eno3
driver: hns3
firmware-version: 3.10.22.8
bus-info: 0000:35:00.2

[root@bogon ~]# ethtool -i eno4
driver: hns3
firmware-version: 3.10.22.8
bus-info: 0000:35:00.3
```

**关键字段解读：**

### driver — 识别网卡家族的第一把钥匙

| 驱动名 | 对应网卡 | 说明 |
|--------|---------|------|
| `hns3` | 华为HiSilicon网卡 | 鲲鹏服务器板载/HNS系列，支持RoCE |
| `mlx5_core` | Mellanox/NVIDIA CX系列 | 高速RDMA网卡，最常见 |
| `ixgbe` | Intel 82599/X520/X540 | Intel 10G网卡 |
| `ice` | Intel E810系列 | Intel 25G/100G新一代 |
| `bnxt_en` | Broadcom NetXtreme | 博通高速网卡 |
| `be2net` | Emulex/Broadcom OCe | 老一代万兆卡 |

### bus-info — 判断多口卡归属的关键

bus-info 格式为标准 **PCI 地址**：`域:总线:设备.功能`

```
0000:35:00.0   →  域0000, 总线35, 设备00, 功能0
0000:35:00.1   →  域0000, 总线35, 设备00, 功能1
0000:35:00.2   →  域0000, 总线35, 设备00, 功能2
0000:35:00.3   →  域0000, 总线35, 设备00, 功能3
```

**判断规则：** 同一个"域:总线:设备"，只有功能号（最后一位）不同 → **属于同一张多口网卡的不同 function**。

本机 eno1~eno4 的 bus-info 从 `.0` 到 `.3` 连续，driver 相同，firmware 版本相同，**可以确认是同一张4口物理网卡**。

---

## 五、批量采集脚本

不用一个一个手敲，一条命令全部搞定：

```bash
for nic in $(ls /sys/class/net | grep -v lo); do
    echo "===== $nic ====="
    ip -br link show "$nic"
    ethtool "$nic" 2>/dev/null | egrep "Speed|Duplex|Link detected"
    ethtool -i "$nic" 2>/dev/null | egrep "driver|firmware-version|bus-info"
    echo
done
```

---

## 六、ethtool -S — 查看网卡错误计数

这个在 Day11 原始内容里没有，但是测试工作中非常重要——用于确认网卡是否有丢包、CRC错误等异常：

```bash
# 查看网卡详细统计（包含错误计数）
ethtool -S eno1

# 过滤错误相关字段
ethtool -S eno1 | grep -iE 'error|drop|miss|fail|bad'
```

**关键错误计数字段（hns3驱动）：**

| 字段 | 说明 | 告警条件 |
|------|------|---------|
| `rx_errors` | 接收错误总数 | 持续增长需关注 |
| `tx_errors` | 发送错误总数 | 持续增长需关注 |
| `rx_dropped` | 接收丢包数 | 非零时排查MTU或缓冲区 |
| `rx_crc_errors` | CRC校验错误 | 非零说明链路质量差 |
| `tx_queue_stopped` | 发送队列停止次数 | 高负载时常见 |

---

## 七、RDMA/RoCE 与以太网口的对应关系

做完普通网口的分析，训练表里还要求"把网卡与RDMA NIC对上"：

```bash
[root@bogon ~]# rdma link
link roceo1/1 state ACTIVE physical_state LINK_UP netdev eno1
link roceo2/1 state DOWN   physical_state DISABLED netdev eno2
link roceo3/1 state DOWN   physical_state DISABLED netdev eno3
link roceo4/1 state DOWN   physical_state DISABLED netdev eno4

[root@bogon ~]# ls /sys/class/infiniband
roceo1  roceo2  roceo3  roceo4
```

**rdma link 输出字段解读：**

| 字段 | 含义 |
|------|------|
| `roceo1/1` | RDMA设备名/端口号 |
| `state ACTIVE` | RDMA层面处于激活状态 |
| `physical_state LINK_UP` | 物理层链路已建立 |
| `netdev eno1` | 绑定的以太网接口名 |

---

## 八、完整NIC信息表（可交付版）

| 网口 | 管理状态 | 物理链路 | 速率 | 双工 | 驱动 | 固件版本 | bus-info | RDMA设备 | RDMA状态 | RDMA物理状态 | 归属 |
|------|---------|---------|------|------|------|---------|---------|---------|---------|------------|------|
| eno1 | UP | yes | 1G | Full | hns3 | 3.10.22.8 | 0000:35:00.0 | roceo1 | ACTIVE | LINK_UP | 卡A |
| eno2 | DOWN | no | Unknown | Unknown | hns3 | 3.10.22.8 | 0000:35:00.1 | roceo2 | DOWN | DISABLED | 卡A |
| eno3 | DOWN | no | Unknown | Unknown | hns3 | 3.10.22.8 | 0000:35:00.2 | roceo3 | DOWN | DISABLED | 卡A |
| eno4 | DOWN | no | Unknown | Unknown | hns3 | 3.10.22.8 | 0000:35:00.3 | roceo4 | DOWN | DISABLED | 卡A |

**结论：**
- eno1~eno4 属于**同一张4口物理网卡**（driver相同 + firmware一致 + bus-info连续）
- 该网卡支持 **RoCE RDMA**，每个以太网口对应一个 RoCE 设备（roceo1~roceo4）
- 当前只有 eno1 / roceo1 建立了物理链路并处于 ACTIVE 状态
- eno2~eno4 无物理链路，对应 RDMA 端口也为 DOWN/DISABLED

---

## 九、RDMA / InfiniBand / RoCE — 三个概念讲清楚

这是 Day11 的概念收尾，必须搞清楚三者关系。

### RDMA — 一种通信能力

RDMA（Remote Direct Memory Access，远程直接内存访问）的核心是：一台机器的网卡可以直接读写另一台机器的内存，**尽量绕过对方CPU的参与**。

对比普通TCP/IP：
```
TCP路径：应用 → 内核协议栈 → 网卡 → 网络 → 对端网卡 → 对端内核 → 对端应用
RDMA路径：应用准备内存 → RDMA网卡直接搬运 → 对端内存（对端CPU几乎不参与）
```

RDMA的优势：**低延迟（μs级）、高带宽、低CPU开销、零/少拷贝**，适合AI训练、HPC、分布式存储。

### InfiniBand — 一种网络体系

InfiniBand 是专门为高性能通信设计的互连架构，**原生支持RDMA**，包含专用的链路层、寻址方式、交换机、队列对（QP）通信模型。常见于超算、HPC集群、大规模训练集群。

### RoCE — RDMA over Converged Ethernet

RoCE 是在**以太网上实现RDMA能力**，分两个版本：

| 版本 | 传输层 | 说明 |
|------|--------|------|
| RoCEv1 | 以太网二层 | 不可路由，同子网内使用 |
| RoCEv2 | UDP/IP | **可路由，跨子网，主流选择** |

### 三者关系

```
RDMA = 通信能力（远程直接内存访问）
    ↓ 可以运行在
InfiniBand（专用高性能网络）   ← 原生RDMA，延迟最低
RoCEv2（以太网 + UDP/IP）     ← 在以太网基础上实现RDMA，兼容现有网络
iWARP（以太网 + TCP/IP）      ← 另一种以太网RDMA方案
```

> 💡 **类比记忆：** RDMA = 高速运输方式；InfiniBand = 专用高铁网络；RoCE = 在公路网络上尽量跑出高铁速度。

### 关于 /sys/class/infiniband 的常见误解

```bash
[root@bogon ~]# ls /sys/class/infiniband
roceo1  roceo2  roceo3  roceo4
```

**很多人一看到 infiniband 目录就以为"我这台机器用的是InfiniBand"——这是错的。**

Linux RDMA子系统历史上沿用了 infiniband 这个目录名，RoCE设备同样会出现在这里。判断是IB还是RoCE，要看设备名和驱动：
- 设备名 `mlx5_*`、`ib0`：大概率是InfiniBand
- 设备名 `roceo*`、绑定 netdev 的：**是RoCE over Ethernet**

本机的 roceo1~roceo4 绑定了 eno1~eno4 以太网口，所以是 **RoCE**，不是传统InfiniBand。

---

## 十、本机网络结论

> 本机 eno1~eno4 使用相同驱动 hns3，固件版本一致（3.10.22.8），PCI地址连续为 0000:35:00.0 ~ 0000:35:00.3，可判断它们属于同一张4口物理网卡。通过 `rdma link` 确认该网卡支持 RoCE，roceo1~roceo4 分别对应 eno1~eno4。当前仅 eno1 / roceo1 处于活动状态（1G Full，RDMA ACTIVE）；其余端口无物理链路，对应RDMA端口也为 DOWN/DISABLED。

**一个值得注意的细节：** eno1 当前协商速率是 **1G**，但 hns3 驱动支持的卡通常是 25GbE 级别。1G 的原因是对端交换机端口或网线限制了速率，不是网卡本身问题。实际测试时接上 25G 交换机 + DAC/光模块，速率会协商到 25000Mb/s。

---

## 十一、补充：几个今天没用到但很重要的命令

### ip addr — 查IP地址（和 ip link 的区别）

```bash
# ip link 只看二层（MAC、状态）
ip link show eno1

# ip addr 看二层+三层（MAC + IP地址）
ip addr show eno1

# 查所有接口的IP汇总
ip -br addr
```

### ss — 查看网络连接状态

```bash
# 查看所有TCP连接
ss -tuln

# 查看特定端口
ss -tlnp | grep :22

# 统计各状态连接数
ss -s
```

### MTU — 最大传输单元

```bash
# 查看MTU（默认1500，Jumbo Frame为9000）
ip link show eno1 | grep mtu

# 设置Jumbo Frame（25G/100G网卡高性能场景）
ip link set eno1 mtu 9000

# 测试MTU（ping大包，不分片）
ping -M do -s 8972 <目标IP>
```

> 💡 **iperf3 测试25G/100G网卡时，务必先确认MTU=9000（Jumbo Frame）。默认MTU=1500会限制实际带宽，可能导致测试结果偏低20-30%。**

### ibv_devinfo — 查看RDMA设备详情

```bash
# 安装
yum install libibverbs-utils -y

# 查看所有RDMA设备
ibv_devices

# 查看特定设备详情（GID、端口能力等）
ibv_devinfo -d roceo1
```

---

## 总结

Day11 核心收获三点：

**一、区分"接口启用"和"物理链路正常"。** UP 是软件层状态，`Link detected: yes` 或 `LOWER_UP` 才是物理链路建立的依据。Speed: Unknown! 不是坏卡，是没链路。

**二、通过 driver + bus-info 判断多口卡归属。** bus-info 同一个"设备"下的 .0/.1/.2/.3 → 同一张多口卡。driver 和 firmware 一致进一步加强判断。

**三、RDMA ≠ InfiniBand，RoCE 是在以太网上实现RDMA。** 本机的 roceo1~roceo4 绑定 eno1~eno4，是 RoCE 方案，/sys/class/infiniband 目录名不代表跑的是InfiniBand网络。



欢迎关注 **JACK的服务器笔记**，我们下篇见！

