大家好，我是JACK，本篇是Linux命令系列第五篇。上一篇我们讲了日志排查命令，这篇我们聊网络测试相关命令，结合实际工作中的使用场景和排查案例来讲。

---

## 一、ping — 测试网络连通性

ping是最基础的网络测试命令，用来验证两台服务器之间网络是否连通。

```bash
# 基本ping测试
[root@localhost ~]# ping 192.168.1.100
PING 192.168.1.100 (192.168.1.100) 56(84) bytes of data.
64 bytes from 192.168.1.100: icmp_seq=1 ttl=64 time=0.312 ms
64 bytes from 192.168.1.100: icmp_seq=2 ttl=64 time=0.298 ms
64 bytes from 192.168.1.100: icmp_seq=3 ttl=64 time=0.301 ms

# 指定ping次数
[root@localhost ~]# ping -c 10 192.168.1.100

# 指定包大小（测试大包传输）
[root@localhost ~]# ping -s 8192 192.168.1.100

# 持续ping并记录日志
[root@localhost ~]# ping 192.168.1.100 >> ping_log.txt
```

重点关注字段：

| 字段 | 说明 |
|------|------|
| time | 往返延迟，越低越好 |
| ttl | 生存时间，判断网络跳数 |
| packet loss | 丢包率，正常应为0% |

**常见异常：**
- **ping不通** → 检查网线、IP配置、防火墙
- **丢包率不为0** → 网络质量差，检查网线或交换机端口
- **延迟异常高** → 网络拥塞或链路质量问题

---

## 二、ethtool — 查看网卡状态和速率

ethtool用来查看和配置网卡的链路状态、速率、驱动信息等，是网卡测试中最常用的工具。

```bash
# 查看网卡基本信息
[root@localhost ~]# ethtool eth0
Settings for eth0:
        Supported ports: [ FIBRE ]
        Speed: 25000Mb/s
        Duplex: Full
        Auto-negotiation: on
        Port: FIBRE
        Link detected: yes

# 查看网卡驱动信息
[root@localhost ~]# ethtool -i eth0
driver: hns3
version: 1.9.40.0
firmware-version: 1.8.0.12
bus-info: 0000:01:00.0

# 查看网卡统计信息
[root@localhost ~]# ethtool -S eth0
NIC statistics:
     rx_packets: 1234567
     tx_packets: 987654
     rx_bytes: 1234567890
     tx_bytes: 987654321
     rx_errors: 0
     tx_errors: 0
     rx_dropped: 0
     tx_dropped: 0
# rx_errors和tx_errors不为0说明有网络错误
```

重点关注字段：

| 字段 | 说明 |
|------|------|
| Speed | 链路速率，确认是否达到标称值 |
| Link detected | yes正常，no表示链路断开 |
| rx_errors/tx_errors | 收发错误包数，正常应为0 |
| rx_dropped/tx_dropped | 丢包数，正常应为0 |

---

## 三、iperf/iperf3 — 测试网络带宽

iperf3是测试网络实际带宽最常用的工具，需要一台服务器作为服务端，另一台作为客户端。

**1. 基本带宽测试**

```bash
# 服务端启动
[root@server ~]# iperf3 -s
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------

# 客户端发起测试，跑60秒
[root@client ~]# iperf3 -c 192.168.1.100 -t 60
Connecting to host 192.168.1.100, port 5201
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-60.00  sec   172 GBytes  24.7 Gbits/sec    0   sender
[  5]   0.00-60.00  sec   172 GBytes  24.7 Gbits/sec        receiver
# 25GbE网卡实测带宽24.7Gbps，达成率接近99%，正常
```

**2. 多线程测试（提升带宽利用率）**

```bash
[root@client ~]# iperf3 -c 192.168.1.100 -t 60 -P 4
[SUM]   0.00-60.00  sec   175 GBytes  25.1 Gbits/sec    0
# -P 4 表示4个并行线程，更充分利用带宽
```

**3. Bond4双口聚合测试**

```bash
[root@client ~]# iperf3 -c 192.168.1.100 -t 60 -P 8
# Bond4两个口叠加，理论50GbE，用多线程测试
[SUM]   0.00-60.00  sec   336 GBytes  48.3 Gbits/sec
# 实测48.3Gbps，接近理论值50GbE，正常
```

**4. 双向测试**

```bash
[root@client ~]# iperf3 -c 192.168.1.100 -t 60 --bidir
# 同时测试上行和下行带宽
[  5][TX-C]   0.00-60.00  sec   172 GBytes  24.7 Gbits/sec    0   sender
[  7][RX-C]   0.00-60.00  sec   171 GBytes  24.6 Gbits/sec        receiver
```

**5. UDP测试**

```bash
[root@client ~]# iperf3 -c 192.168.1.100 -u -b 10G -t 60
[  5]   0.00-60.00  sec   172 GBytes  24.7 Gbits/sec  0.023 ms  0/125890 (0%)
# 0/125890 (0%) 表示无丢包，正常
```

**iperf3输出重点关注：**

| 字段 | 说明 |
|------|------|
| Bitrate | 实际带宽，是否达到标称值 |
| Retr | 重传次数，不为0说明有丢包 |
| Transfer | 总传输数据量 |

---

## 四、Bond链路聚合

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

| 模式 | 带宽 | 冗余 | 适用场景 |
|------|------|------|---------|
| Bond1 | 不叠加 | ✅ | 对冗余要求高，带宽要求不高 |
| Bond4 | 叠加 | ✅ | 既要高带宽又要冗余 |

**查看Bond状态：**
```bash
[root@localhost ~]# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.7.1

Bonding Mode: IEEE 802.3ad Dynamic link aggregation
MII Status: up
Active Aggregator Info:
        Aggregator ID: 1
        Number of ports: 2

Slave Interface: eth0
MII Status: up
Speed: 25000 Mbps
Duplex: full

Slave Interface: eth1
MII Status: up
Speed: 25000 Mbps
Duplex: full
# 两个口都是up，说明Bond4正常工作
```

---

## 五、常见问题及排查

**网络带宽跑不上去**

这是网络测试中最常见的问题，排查思路：

**第一步：确认链路速率是否正常**
```bash
[root@localhost ~]# ethtool eth0 | grep Speed
Speed: 25000Mb/s
# 如果只有1000Mb/s，说明链路协商有问题
# 检查光模块是否匹配、交换机端口配置是否正确
```

**第二步：确认链路是否有错误包**
```bash
[root@localhost ~]# ethtool -S eth0 | grep -i error
rx_errors: 0
tx_errors: 0
# 有错误包说明链路质量差，检查网线或光纤
```

**第三步：排除CPU瓶颈**
```bash
# 测试时同时查看CPU使用率
[root@localhost ~]# top
# 如果CPU已经跑满，带宽上不去是CPU瓶颈，用多线程测试
[root@client ~]# iperf3 -c 192.168.1.100 -t 60 -P 8
```

**第四步：检查网卡中断绑核**
```bash
# 查看网卡中断分配
[root@localhost ~]# cat /proc/interrupts | grep eth0
# 如果所有中断都在同一个CPU核心，会导致带宽瓶颈
# 可以用irqbalance自动均衡中断
[root@localhost ~]# systemctl start irqbalance
```

**第五步：查看dmesg日志**
```bash
[root@localhost ~]# dmesg | grep -i hns3
# 确认网卡驱动有无报错
# 如果有报错考虑更新驱动或固件版本
```

**第六步：检查Bond配置**
```bash
# 如果是Bond4聚合口带宽上不去
[root@localhost ~]# cat /proc/net/bonding/bond0
# 确认两个slave口都是up状态
# 确认交换机开启了LACP
```

---

## 六、测试时需要记录的数据

| 指标 | 说明 |
|------|------|
| 链路速率 | ethtool确认是否达到标称值 |
| 单口实测带宽 | iperf3跑分，达成率是否正常 |
| 重传次数 | Retr是否为0 |
| 错误包数 | rx_errors/tx_errors是否为0 |
| 丢包率 | UDP测试丢包率是否为0 |

---

## 七、组合使用技巧

网络测试时建议多个命令配合使用：

```bash
# 终端1：跑iperf3带宽测试
iperf3 -c 192.168.1.100 -t 300 -P 4 | tee iperf_log.txt

# 终端2：实时监控网卡错误包
watch -n 2 'ethtool -S eth0 | grep -i error'

# 终端3：监控CPU使用率
top

# 终端4：监控网卡流量
watch -n 1 'ip -s link show eth0'
```

---

## 八、总结

网络测试核心三步：**ping确认连通 → ethtool确认速率 → iperf3测试带宽**。遇到带宽跑不上去，按照链路速率、错误包、CPU瓶颈、中断绑核、驱动固件的顺序逐步排查，基本能定位到问题所在。

下一篇我们聊**昇腾鲲鹏专项命令实战**，结合实际测试经验深入讲解，敬请期待！

欢迎关注**JACK的服务器笔记**！
