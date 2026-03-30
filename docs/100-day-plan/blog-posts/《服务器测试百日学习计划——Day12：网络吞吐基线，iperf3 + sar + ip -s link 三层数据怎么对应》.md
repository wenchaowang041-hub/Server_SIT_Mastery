大家好，我是JACK，本篇是服务器测试百日学习计划Day12。

Day11 我们识别了网口状态和RDMA归属，今天进入网络性能测试第一篇——**建立网络吞吐基线**。不是只跑一个 iperf3 数字，而是要把三类观测对应起来，建立"网络基线"的完整分析方法。

---

## 一、今天要建立的核心链路

网络吞吐测试的关键不是一个数字，而是把三层观测对应起来：

```
业务层（iperf3）：   链路实际能跑出多少吞吐？         → 943 Mbits/sec
系统层（sar）：      网卡每秒实际收发了多少？          → txkB/s ≈ 117800
接口层（ip -s link）：网口累计发了多少、有没有错误？   → TX bytes 增加 3.5GB，errors=0
```

这三者必须互相印证。只看 iperf3 一个数字是不够的——吞吐有数值不代表链路健康，也不代表数据真的从你预期的网口出去了。

---

## 二、三个工具的分工

### iperf3 — 业务层吞吐测试工具

回答的问题：**这条链路实际能跑出多少吞吐？**

iperf3 采用 C/S 架构，需要两台机器，一台跑服务端，一台跑客户端：

```bash
# 服务端（先启动，监听5201端口）
iperf3 -s

# 客户端（发起测试）
iperf3 -c <服务端IP> -t 30
```

### sar -n DEV 1 — 系统层实时网口速率

回答的问题：**系统每秒看到各网口收/发了多少数据？**

```bash
# 每秒报告所有网口的收发统计
sar -n DEV 1

# 只看特定网口
sar -n DEV 1 | grep eno1
```

输出字段含义：

| 字段 | 含义 | 单位 |
|------|------|------|
| rxpck/s | 每秒接收包数 | 包/秒 |
| txpck/s | 每秒发送包数 | 包/秒 |
| rxkB/s | 每秒接收字节 | KB/秒 |
| txkB/s | 每秒发送字节 | KB/秒 |

### ip -s link — 接口层累计计数器

回答的问题：**网口从启动到现在累计收发了多少，有没有错误和丢包？**

```bash
ip -s link show eno1
```

**关键字段：**

| 字段 | 含义 | 告警条件 |
|------|------|---------|
| RX/TX bytes | 累计收/发字节数 | 压测后应明显增长 |
| RX/TX packets | 累计收/发包数 | 参考 |
| errors | 硬件错误（CRC、帧错误等）| 非零需排查 |
| dropped | 被丢弃的包（缓冲区满等）| 非零需关注 |
| overruns | 接收缓冲区溢出 | 非零说明处理不及时 |
| carrier | 链路载波错误 | 非零说明物理层问题 |

---

## 三、标准实验流程

### 前置确认

```bash
# 确认测试网口有链路（Day11已做）
ip -br link show eno1
ethtool eno1 | grep "Link detected"

# 确认iperf3已安装
iperf3 -v

# 查看本机IP（用于告知对端）
ip addr show eno1 | grep inet
```

### 三窗口同步操作

**窗口1（监控）：**
```bash
sar -n DEV 1
```

**窗口2（基准记录 + 压测）：**
```bash
# 压测前记录累计统计
ip -s link show eno1

# 执行压测（对端已启动 iperf3 -s）
iperf3 -c <对端IP> -t 30

# 压测后再记录
ip -s link show eno1
```

**窗口3（可选）：**
```bash
# 实时监控网口错误
watch -n 1 'ip -s link show eno1 | grep -A3 TX'
```

---

## 四、iperf3 常用参数详解

```bash
# 基础单流TCP（30秒）
iperf3 -c <IP> -t 30

# 多流并发（更接近真实带宽上限）
iperf3 -c <IP> -P 8 -t 30

# 反向测试（测服务器→客户端方向）
iperf3 -c <IP> -R -t 30

# 双向同时测试
iperf3 -c <IP> --bidir -t 30

# UDP测试（用于测丢包率和抖动）
iperf3 -c <IP> -u -b 1G -t 30

# JSON格式输出（便于脚本处理）
iperf3 -c <IP> -P 4 -t 30 -J | tee result_$(date +%s).json

# 绑定特定本地IP（多网卡时指定出口）
iperf3 -c <IP> -B <本地IP> -t 30

# 指定端口（避免5201冲突）
iperf3 -s -p 15201
iperf3 -c <IP> -p 15201 -t 30
```

### iperf3 输出关键字段

```
[ ID] Interval       Transfer     Bitrate         Retr
[  5] 0.00-30.00 sec 3.29 GBytes  943 Mbits/sec    0   sender
[  5] 0.00-30.00 sec 3.29 GBytes  942 Mbits/sec        receiver
```

| 字段 | 含义 | 说明 |
|------|------|------|
| Bitrate | 实际吞吐（bits/sec）| 核心指标 |
| Transfer | 测试期间总传输量 | 用于和 ip -s link 对比 |
| Retr | TCP重传次数 | **非零说明丢包，链路有问题** |

---

## 五、单位换算 — 最容易踩的坑

iperf3 报告的是 **bits/sec（比特每秒）**，sar 报告的是 **kB/s（千字节每秒）**，必须会换算：

```
iperf3:  943 Mbits/sec
         ÷8（bit → Byte）= 117.9 MB/s
         ×1024（MB → kB）= 120,730 kB/s
         ≈ sar 里的 txkB/s ~ 117,000~120,000
```

换算公式：

```
iperf3(Mbits/sec) ÷ 8 × 1024 ≈ sar txkB/s 或 rxkB/s
```

| iperf3 吞吐 | 等价 MB/s | 等价 sar kB/s |
|------------|---------|-------------|
| 100 Mbits/sec | 12.5 MB/s | ~12,800 kB/s |
| 943 Mbits/sec | 117.9 MB/s | ~120,700 kB/s |
| 9.4 Gbits/sec | 1,175 MB/s | ~1,203,200 kB/s |
| 24 Gbits/sec | 3,000 MB/s | ~3,072,000 kB/s |

---

## 六、场景一：正常的1G吞吐基线

### iperf3 结果（模拟）

```
Connecting to host 192.168.10.20, port 5201
[ ID] Interval       Transfer     Bitrate
[  5] 0.00-1.00 sec   112 MBytes  939 Mbits/sec
[  5] 1.00-2.00 sec   113 MBytes  947 Mbits/sec
[  5] 2.00-3.00 sec   112 MBytes  941 Mbits/sec
      ...
[  5] 29.00-30.00 sec  112 MBytes  940 Mbits/sec

[ ID] Interval       Transfer     Bitrate         Retr
[  5] 0.00-30.00 sec  3.29 GBytes  943 Mbits/sec    0   sender
[  5] 0.00-30.00 sec  3.29 GBytes  942 Mbits/sec        receiver
```

### 同步 sar -n DEV 1（摘取eno1相关行）

```
时刻      IFACE   rxpck/s   txpck/s   rxkB/s    txkB/s
12:00:02  eno1      12.00   8120.00     1.20  117300.00
12:00:03  eno1      10.00   8195.00     0.88  118050.00
12:00:04  eno1      11.00   8168.00     1.05  117620.00
12:00:05  eno1      13.00   8210.00     1.30  117980.00
```

### 压测前 ip -s link show eno1

```
RX: bytes    packets  errors  dropped overrun mcast
    1250000     9200       0        0       0    10
TX: bytes    packets  errors  dropped carrier collsns
     980000     8100       0        0       0     0
```

### 压测后 ip -s link show eno1

```
RX: bytes    packets  errors  dropped overrun mcast
    1298000     9550       0        0       0    10
TX: bytes    packets  errors  dropped carrier collsns
 3534200000  2465000       0        0       0     0
```

### 三层数据对照分析

**第一层 iperf3：** 943 Mbits/sec，Retr=0，结论是1G链路接近跑满，无重传。

**第二层 sar：** txkB/s 持续在117,000~118,000区间，换算：117,500 kB/s ÷ 1024 × 8 ≈ 917 Mbits/sec（方向和量级与iperf3一致）。iperf3是-c发起方，所以本机TX高、RX低，方向正确。

**第三层 ip -s link：** TX bytes 从 980,000 增加到 3,534,200,000，增量约 **3.53 GB**；iperf3 Transfer 是 3.29 GBytes，两者接近（差异来自协议头开销和时间窗口不完全重合），errors=0，dropped=0，接口健康。

> 💡 **为什么1G链路只跑出943而不是1000 Mbits/sec？** 以太网帧头（14B）+ FCS（4B）+ IPG（12B）+ TCP/IP头（40B+）共消耗约7%的带宽，所以1G链路有效TCP吞吐在930~950 Mbits/sec是完全正常的。

---

## 七、场景二：异常数据分析

### iperf3 结果（异常）

```
[ ID] Interval       Transfer     Bitrate         Retr
[  5] 0.00-30.00 sec  1.86 GBytes  532 Mbits/sec   38   sender
[  5] 0.00-30.00 sec  1.84 GBytes  526 Mbits/sec        receiver
```

### sar -n DEV 1（异常）

```
12:30:02  eno1   15.00  4600.00   1.40  66200.00
12:30:03  eno1   16.00  4720.00   1.55  67500.00
12:30:04  eno1   14.00  4510.00   1.10  64800.00
```

### ip -s link（异常）

```
TX: bytes    packets  errors  dropped carrier collsns
 2018000000  1410000       0      126       0     0
```

### 异常数据解读

| 观测项 | 正常预期 | 实际值 | 问题 |
|--------|---------|--------|------|
| iperf3 吞吐 | 930~950 Mbits/sec | 532 Mbits/sec | 偏低接近一半 |
| sar txkB/s | ~117,000 kB/s | ~66,000 kB/s | 与iperf3印证，真实发送不足 |
| Retr | 0 | 38 | TCP重传，说明丢包 |
| TX dropped | 0 | 126 | 发送路径存在丢弃 |

**结论：** 四个异常信号同时出现——吞吐偏低、sar印证、TCP重传、TX dropped增长——可判断链路或系统发送路径存在问题，而不是测试工具的偶发误差。

**下一步排查方向：**

```bash
# 1. 检查链路质量（CRC错误）
ethtool -S eno1 | grep -i error

# 2. 检查CPU是否成为瓶颈
top -d 1  # 看sys%和softirq

# 3. 检查TCP队列
ss -tuln
cat /proc/net/softnet_stat  # 看dropped列

# 4. 检查对端是否有问题
# 让对端也运行 sar -n DEV 1，看RX dropped是否也有增长

# 5. 检查MTU配置
ip link show eno1 | grep mtu
# Jumbo Frame: mtu 9000 对高速网卡很重要
```

---

## 八、完整吞吐记录表（硬性产出）

| 测试网口 | 链路状态 | 协商速率 | 测试方式 | 时长 | iperf3吞吐 | sar观察 | ip -s link变化 | 错误/丢包 | 结论 |
|---------|---------|---------|---------|------|-----------|---------|--------------|---------|------|
| eno1 | UP / LOWER_UP | 1G Full | client→server | 30s | **943 Mbits/sec** | txkB/s 稳定~117,000~118,000 | TX bytes增加约3.5GB | 0 / 0 | 1G链路吞吐正常，三层数据一致 |

---

## 九、补充：iperf3 多参数场景对比

实际测试中，不同参数组合会影响结果，以下是常见对比：

```bash
# 场景1：单流（基线，看单条TCP流能力）
iperf3 -c <IP> -t 30
# 1G: ~940 Mbps；25G: ~18-20 Gbps（单流有上限）

# 场景2：多流（并发，更接近实际带宽上限）
iperf3 -c <IP> -P 8 -t 30
# 1G: ~940 Mbps（变化不大）；25G: ~23-24 Gbps（提升明显）

# 场景3：反向（测下载方向）
iperf3 -c <IP> -R -t 30
# 本机变成主要接收方，sar里改看rxkB/s

# 场景4：双向同时（压满全双工）
iperf3 -c <IP> --bidir -P 4 -t 30
# 双向各跑约一半带宽
```

> 💡 **1G网卡建议单流就够了**；25G及以上必须用 `-P 4` 或以上多流，否则单条TCP流的速度会受限于拥塞控制，无法压满带宽。

---

## 十、MTU对吞吐的影响（补充）

这个点在测试中很容易被忽视，尤其是25G/100G环境：

```bash
# 查看当前MTU
ip link show eno1 | grep mtu
# 默认: mtu 1500

# 测试大包连通性（检查MTU链路）
ping -M do -s 8972 <对端IP>
# 8972 + 28(IP+ICMP头) = 9000，即Jumbo Frame

# 临时设置Jumbo Frame（需要两端和交换机都支持）
ip link set eno1 mtu 9000

# 或在配置文件中永久设置（openEuler/CentOS）
echo 'MTU=9000' >> /etc/sysconfig/network-scripts/ifcfg-eno1
```

**MTU对性能的影响（以25GbE为例）：**

| MTU | 实测吞吐 | 说明 |
|-----|---------|------|
| 1500 | ~18-20 Gbps | 默认值，有开销 |
| 9000（Jumbo Frame）| ~23-24 Gbps | 减少分片，提升15-20% |

---

## 十一、今天必须建立的直觉

**三句核心话，背下来：**

1. **1G 正常 TCP 吞吐常见在 930~950 Mbits/sec**，不是正好 1000，这是正常的协议开销。

2. **sar 的 kB/s 要能和 iperf3 的 Mbits/sec 对上**：Mbits/sec ÷ 8 × 1024 ≈ sar kB/s。

3. **ip -s link 不只看字节增长，errors 和 dropped 不能为非零**，它们反映链路健康度，不只是吞吐大小。

**方向判断：**

```
执行 iperf3 -c <IP>（你是client）
  → 你主要在"发"
  → 本机 sar 里 txkB/s 高，rxkB/s 低
  → ip -s link 里 TX bytes 增长大

执行 iperf3 -c <IP> -R（反向，你是接收方）
  → 你主要在"收"
  → 本机 sar 里 rxkB/s 高，txkB/s 低
  → ip -s link 里 RX bytes 增长大
```

---

## 十二、Day12 总结

三工具的分工彻底清楚了：

- **iperf3**：业务层，压测实际吞吐，看 Bitrate 和 Retr
- **sar -n DEV 1**：系统层，实时看网口每秒速率，验证方向和量级
- **ip -s link**：接口层，看累计字节变化 + errors/dropped 是否干净

单独看任何一个都是不完整的。iperf3 跑出好数字、但 dropped 在涨，说明问题被掩盖了；sar 看到流量高，但 iperf3 没跑满，说明有其他开销。**三者对应，才是真正的基线数据。**

下一篇 Day13 继续网络方向，进入 iperf3 多流测试和网卡中断亲和性，敬请期待！

欢迎关注 **JACK的服务器笔记**，我们下篇见！
