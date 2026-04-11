开始 Day12。
我已经按你总表定位到今天内容：

Day12


阶段：Phase1-网络


周次：W2


模块：Network性能


主题：网络吞吐基线


学习重点：用 iperf3 + sar 建立 网络吞吐 与 接口统计 的对应关系


命令/工具：iperf3、sar -n DEV 1、ip -s link


实验任务：跑一次 iperf，记录吞吐、tx/rx、丢包；对照 sar 和 ip -s link


硬性产出：网络吞吐记录


达成效果：建立网络性能测试直觉


### 先说今天到底学什么

今天不是单纯学一个命令，而是要建立这条链路：
业务层看到的吞吐
↔ 系统层看到的网卡收发速率
↔ 网口累计统计和丢包
也就是以后别人问你：

这次网络压测到底打到了多少？


网卡有没有真的跑起来？


带宽跑不上去，是链路问题、统计问题，还是业务端问题？

你不能只说 “iperf3 跑了个数”，而要能把三类观测对上。

### 结合你当前机器，今天优先看哪个口

你 Day11 已经确认了：

eno1：UP，链路 yes，1G，Full


eno2~eno4：都没链路


roceo1 ↔ eno1

所以 今天 Day12 的主角就是 eno1。
因为它是你当前唯一真正有链路的口。
所以今天所有吞吐观察，默认都围绕：
eno1
展开。

### 先把三个工具分工讲清楚

- 1. iperf3
它回答的问题是：
现在这条链路实际能跑出多少吞吐？
它是“压测工具”。
你会看到类似结果：

940 Mbits/sec


9.4 Gbits/sec


24 Gbits/sec

这代表应用层看到的有效吞吐。

- 2. sar -n DEV 1
它回答的问题是：
系统每秒看到各网口收/发了多少数据包和字节？
它是“动态监控工具”。
它会按秒输出每个网口的：

rxpck/s


txpck/s


rxkB/s


txkB/s

所以它非常适合在 iperf 跑的时候，旁边同步盯着看。

- 3. ip -s link
它回答的问题是：
某个网口从启动到现在累计发了多少包、多少字节、有没有错误和丢弃？
它是“累计计数器查看工具”。
你重点看：

RX bytes / packets


TX bytes / packets


errors


dropped


overruns


carrier

所以它特别适合：

压测前看一次


压测后再看一次


做前后对比


### 今天最重要的认知

你必须先记住：
iperf3 看的是“压测结果”
例如：

940 Mbps

sar -n DEV 1 看的是“系统实时网卡速率”
例如：

rxkB/s / txkB/s

ip -s link 看的是“累计计数器变化”
例如：

TX bytes 从 1GB 增加到 12GB

所以今天真正目标不是学 3 个命令，而是学会：
把这三份观测对应起来

### 今天怎么做实验

网络吞吐测试至少需要 两台机器：

一台做 server


一台做 client

如果你当前环境只有一台机器，那今天可以先学命令和记录方法；
真正压吞吐时必须有对端。

第1步：确认 iperf3 是否存在
iperf3 -v
如果没有，就会提示命令不存在。
有的话继续。

第2步：在对端机器启动服务端
在对端执行：
iperf3 -s
这台机器就开始监听 5201 端口。

第3步：确认本机 eno1 的 IP
在你这台机器上看：
ip addr show eno1
同时你也要知道对端机器的 IP。

第4步：本机先开动态监控
开一个窗口执行：
sar -n DEV 1
如果你只想重点看网口，也可以后面人工只盯 eno1 这一行。

第5步：压测前看一次累计统计
ip -s link show eno1
把这里的 RX/TX bytes、packets、errors、dropped 记下来。

第6步：执行 iperf3 压测
在客户端执行：
iperf3 -c <对端IP> -t 30
解释：

-c：连接服务端


-t 30：持续 30 秒

例如：
iperf3 -c 192.168.1.10 -t 30

### 你今天先做最基础的单流测试

先别一上来就多线程。
第一轮只做：
iperf3 -c <对端IP> -t 30
因为今天是 基线，不是极限调优。
你先建立“1 条流大概能打到多少”的感觉。

### 测试时你应该看到什么

假设你当前 eno1 是 1G 全双工，而且链路和对端都正常，那么一个非常常见的结果会是：

iperf3：大约 930~950 Mbits/sec


sar -n DEV 1：对应方向出现大约 110000~120000 kB/s


ip -s link：对应方向的 TX 或 RX bytes 明显增加

为什么不是正好 1000 Mbps？
因为：

协议头开销


帧开销


系统栈开销


测试环境波动

所以 1G 链路看到 940 Mbps 左右是正常直觉。
这句你今天必须建立起来。

### 怎么看方向

这个特别重要。
如果你在本机执行：
iperf3 -c <对端IP> -t 30
默认是 本机向对端发数据。
那通常你本机会看到：

sar -n DEV 1 里 eno1 的 txkB/s 很高


ip -s link show eno1 里 TX bytes 增加明显

而不是 RX。
所以你一定要建立方向感：
client 默认主要发，server 默认主要收

### 测试后看累计统计

压完后再执行：
ip -s link show eno1
你重点看这些字段有没有明显变化：

RX bytes


RX packets


TX bytes


TX packets


errors


dropped

理想情况下：

TX 或 RX bytes 大幅增加


errors 仍为 0


dropped 最好为 0 或极少


### 今天你要学会的“对照关系”

这是今天核心。
对照1：iperf3 吞吐 vs sar 实时速率
如果 iperf3 打出：

940 Mbits/sec

那 sar -n DEV 1 的对应方向，应该也能看到比较稳定的高流量。
大体上：

940 Mbits/sec ≈ 117500 kB/s

因为：

1 Byte = 8 bit


940 Mb/s ÷ 8 ≈ 117.5 MB/s


再换成 KB/s，大约 117000+ KB/s

这就是你今天要开始建立的单位换算直觉。

对照2：sar 实时速率 vs ip -s link 累计字节
sar 是每秒流速。
ip -s link 是累计值。
所以如果你压了 30 秒，每秒大约 117000 kB/s，
那累计增加量大概会是：

117000 kB/s × 30 ≈ 3.5 GB

所以测试后你应该在 ip -s link 里看到几 GB 级别的累计增长。

对照3：吞吐正常但丢包不正常
如果出现：

iperf3 吞吐还行


但 ip -s link 里 dropped/errors 增长明显

那说明：
表面吞吐看起来有数值，但链路质量或系统处理并不健康
这就是为什么不能只看 iperf3。

### 今天的标准实验流程

你可以直接照这个做：
窗口1：看实时统计
sar -n DEV 1
窗口2：压测前记录
ip -s link show eno1
窗口3：开始压测
iperf3 -c <对端IP> -t 30
压测结束后再次记录
ip -s link show eno1
然后把 3 类结果整理到一张表里。

### Day12 产出模板：网络吞吐记录

你今天的“硬性产出”可以按这个模板做。

### 你今天的合格标准

Day12 完成，不是“命令跑了”，而是你能说出下面这些话：
1
iperf3 给的是链路实际吞吐结果。
2
sar -n DEV 1 给的是网口每秒收发速率和包速率。
3
ip -s link 给的是网口累计收发、错误、丢包统计。
4
三者应该互相印证，不能只看一个结果。

### 今天最容易踩的坑

- 1. 只看 iperf3，不看网口统计
这是最常见错误。
你必须把吞吐和接口统计对应起来。
- 2. 搞反发送方向
client 默认是发，server 默认是收。
- 3. 把 Mbps 和 MB/s 混了
这个以后会经常出错：

940 Mbits/sec 不是 940 MB/s


它大约是 117.5 MB/s

- 4. 用没链路的口测试
你这里只有 eno1 真正有链路，所以不要拿 eno2~eno4 做今天基线。
- 5. 忽略 errors/dropped
吞吐有数值，不代表链路健康。

### 今天先记住一句最关键的话

网络基线不是只跑出一个 iperf3 数字，而是要把吞吐结果、实时接口速率、累计字节和错误统计对应起来。

### 你现在就可以开始练

按这个顺序直接做：
ip addr show eno1
ip -s link show eno1
sar -n DEV 1
iperf3 -c <对端IP> -t 30
ip -s link show eno1
你把这 3 份输出贴给我：

iperf3 结果


sar -n DEV 1 里 eno1 那几秒的关键行


压测前后两次 ip -s link show eno1

我直接帮你做 Day12 网络吞吐记录表，再给你做一版 结果分析 + 复盘点评。
可以。
我直接按你当前环境来 模拟一组 Day12 数据，然后带你做“像真机一样”的解读。
已知前提：

当前真正有链路的是 eno1


链路速率是 1G Full


其余口都没链路


所以 Day12 的测试对象就是 eno1


场景一：正常的 1G 吞吐基线
1）模拟 iperf3 结果
假设你作为 client，执行：
iperf3 -c 192.168.10.20 -t 30
得到输出：
Connecting to host 192.168.10.20, port 5201
[  5] local 192.168.10.10 port 48562 connected to 192.168.10.20 port 5201
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.00   sec   112 MBytes   939 Mbits/sec
[  5]   1.00-2.00   sec   113 MBytes   947 Mbits/sec
[  5]   2.00-3.00   sec   112 MBytes   941 Mbits/sec
[  5]   3.00-4.00   sec   113 MBytes   946 Mbits/sec
...
[  5]  29.00-30.00  sec   112 MBytes   940 Mbits/sec

[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-30.00  sec  3.29 GBytes   943 Mbits/sec    0   sender
[  5]   0.00-30.00  sec  3.29 GBytes   942 Mbits/sec        receiver

2）模拟 sar -n DEV 1
压测同时，另一窗口执行：
sar -n DEV 1
摘取 eno1 相关几秒：
12:00:01 IFACE   rxpck/s   txpck/s   rxkB/s   txkB/s   rxcmp/s   txcmp/s  rxmcst/s
12:00:02 eno1      12.00   8120.00     1.20  117300.00    0.00      0.00      0.00
12:00:03 eno1      10.00   8195.00     0.88  118050.00    0.00      0.00      0.00
12:00:04 eno1      11.00   8168.00     1.05  117620.00    0.00      0.00      0.00
12:00:05 eno1      13.00   8210.00     1.30  117980.00    0.00      0.00      0.00
12:00:06 eno1      12.00   8182.00     1.11  117540.00    0.00      0.00      0.00

3）模拟压测前 ip -s link show eno1
2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
link/ether 9c:xx:xx:xx:xx:01 brd ff:ff:ff:ff:ff:ff
RX: bytes  packets  errors  dropped overrun mcast
1250000    9200     0       0       0       10
TX: bytes  packets  errors  dropped carrier collsns
980000     8100     0       0       0       0

4）模拟压测后 ip -s link show eno1
2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
link/ether 9c:xx:xx:xx:xx:01 brd ff:ff:ff:ff:ff:ff
RX: bytes  packets  errors  dropped overrun mcast
1298000    9550     0       0       0       10
TX: bytes  packets  errors  dropped carrier collsns
3534200000 2465000  0       0       0       0

这组数据怎么解读
第一层：先看 iperf3
最终结果：

943 Mbits/sec sender


942 Mbits/sec receiver


Retr = 0

这说明：
这条 1G 链路已经基本跑满了，表现正常。
为什么说正常？
因为 1G 网口实际做 TCP 吞吐测试时，常见结果就是：

930 ~ 950 Mbits/sec

不是正好 1000，是因为有：

以太网开销


TCP/IP 协议头


系统协议栈处理开销

所以：
943 Mbits/sec 对 1G 网口来说是很健康的基线值

第二层：再看 sar
你这里最关键的是：

txkB/s 持续在 117300 ~ 118050


rxkB/s 很低

这和 iperf3 -c 的方向完全一致。
因为默认 client 是“往外发数据”，所以本机应该表现为：

TX 很高


RX 很低

单位换算要会
iperf3 是：

943 Mbits/sec

换成 MB/s：

943 ÷ 8 ≈ 117.9 MB/s

sar 里是：

117300 ~ 118050 kB/s

这和上面的结果对得上。
也就是说：
iperf3 看到的业务吞吐，和 sar 看到的网卡实时发送速率，是一致的。
这就是 Day12 最核心的“对应关系”。

第三层：最后看 ip -s link
压测前 TX bytes：

980000

压测后 TX bytes：

3534200000

增加量大约：

3.53 GB

而 iperf3 总传输量是：

3.29 GBytes

两者很接近，方向也一致，说明：
本机确实通过 eno1 发出了大量数据，网卡累计计数器变化与压测结果相互印证。
为什么不是完全一模一样？
因为：

ip -s link 统计的是接口层累计字节


iperf3 统计的是应用层测试传输量


时间窗口也未必精确到同一秒

所以接近即可，不要求字节级完全相同。

第四层：看错误和丢包
你这里：

errors = 0


dropped = 0


carrier = 0

说明：
吞吐正常，而且网口统计也很干净，没有明显链路错误或丢包迹象。

这组模拟数据最终结论
你可以直接写成 Day12 记录：

场景二：异常案例，帮你练判断
下面我再模拟一组“不正常”的数据，让你学会怎么看问题。
模拟 iperf3
[  5]   0.00-30.00  sec  1.86 GBytes   532 Mbits/sec   38   sender
[  5]   0.00-30.00  sec  1.84 GBytes   526 Mbits/sec        receiver
模拟 sar -n DEV 1
12:30:02 eno1   15.00   4600.00   1.40   66200.00
12:30:03 eno1   16.00   4720.00   1.55   67500.00
12:30:04 eno1   14.00   4510.00   1.10   64800.00
模拟压测后 ip -s link show eno1
RX: bytes  packets  errors  dropped overrun mcast
1305000    9600     0       0       0       10
TX: bytes  packets  errors  dropped carrier collsns
2018000000 1410000  0       126     0       0

这组异常数据怎么解读
- 1. 吞吐明显偏低
1G 链路理论上正常基线应在：

930~950 Mbits/sec

现在只有：

530 Mbits/sec 左右

说明：
链路没有跑满，性能异常。

- 2. sar 也印证了没跑满
txkB/s 只有：

65000 ~ 67000 kB/s

大约等于：

66 MB/s × 8 ≈ 528 Mbits/sec

和 iperf3 一致。
说明不是 iperf3 假象，而是网口层面真的只发出了这么多。

- 3. ip -s link 出现 dropped
这里最关键：

TX dropped = 126

这说明：
虽然链路还能传，但发送过程中存在丢弃，链路或系统侧并不健康。

- 4. Retr = 38
这通常说明 TCP 重传发生了。
也就是说：

吞吐偏低


sar 不高


TX dropped 增长


iperf3 出现重传

这四者合起来，可以判断：
这不是单纯“测试不稳定”，而是链路质量或系统发送路径存在问题。

如果你在面试或复盘里要怎么说
正常场景表达
本次在 eno1 上进行 30 秒 TCP 吞吐测试，iperf3 结果约 943 Mbits/sec，符合 1G 网口正常基线。压测期间 sar -n DEV 1 观察到 txkB/s 稳定在 117000 左右，与 iperf3 吞吐换算结果一致；压测后 ip -s link 中 TX bytes 显著增加且无 errors/dropped，说明链路吞吐正常且接口健康。
异常场景表达
本次测试仅得到约 530 Mbits/sec，明显低于 1G 网口正常基线。sar 显示实时发送速率仅约 66MB/s，与 iperf3 结果一致，说明并非单一工具误差；同时 ip -s link 出现 TX dropped 增长，且 iperf3 存在 Retr，初步判断链路或发送路径存在异常，需要进一步排查对端、交换机、队列、驱动或 CPU 处理能力。

你现在真正该掌握的 Day12 直觉
记住这三句就够了：

1G 正常 TCP 吞吐，常见是 930~950 Mbits/sec


sar 的 kB/s 要能和 iperf3 的 Mbits/sec 对上


ip -s link 不只是看字节增长，还要看 errors / dropped


给你一个小测验
我给你一组数字，你自己先判断：

iperf3 = 941 Mbits/sec


sar txkB/s = 117800


ip -s link 中 TX bytes 增长 3.4GB


errors=0 dropped=0

你应该得出的结论是：
这是 正常的 1G 网络吞吐基线，三组观测彼此一致，链路健康。

你要的话，我下一条可以继续直接给你做 Day12 作业成品版，包括：

一份完整“网络吞吐记录表”


一份“Day12 总结模板”


5 道检查题和答案

那我直接给你 Day12 作业成品版，你可以直接记到笔记里。
Day12 作业成品版
- 1. 网络吞吐记录表
场景：1G 网口正常基线

- 2. Day12 标准分析结论
你可以直接写成这段：
本次在 eno1 上进行 30 秒网络吞吐测试。iperf3 结果约为 943 Mbits/sec，符合 1G 网口常见正常基线。测试期间 sar -n DEV 1 观察到 eno1 的 txkB/s 持续稳定在 117000~118000 左右，与 iperf3 吞吐换算结果一致。测试前后对比 ip -s link show eno1，可见 TX bytes 明显增长，且 errors、dropped 均为 0，说明该链路吞吐正常、方向正确、接口健康，无明显丢包与错误。

- 3. Day12 核心知识点总结
今天学会了什么

iperf3：看链路实际吞吐


sar -n DEV 1：看网口每秒收发速率


ip -s link：看网口累计字节、包数、错误、丢包

三者关系

iperf3 是业务层吞吐结果


sar 是系统层实时速率


ip -s link 是接口累计计数器


三者应该互相印证，不能只看其中一个


- 4. 今天必须背下来的 4 句话
第一句
网络吞吐测试不是只看 iperf3 一个数字，而是要结合 sar 和 ip -s link 一起看。
第二句
对 1G 网口来说，正常 TCP 吞吐基线常见在 930~950 Mbits/sec 左右。
第三句
iperf3 -c 默认由 client 向 server 发流，因此本机通常表现为 TX 更高。
第四句
errors 和 dropped 即使不大，也不能忽略，因为它们反映的是链路健康度，而不只是吞吐大小。

- 5. Day12 面试版表达
你可以这样说：
我能够使用 iperf3 建立网络吞吐基线，并结合 sar -n DEV 1 验证接口实时发送/接收速率，再通过 ip -s link 对比累计字节和错误丢包统计，从而判断链路是否真正跑满以及接口是否健康。对于 1G 网口，正常 TCP 吞吐通常在 930 到 950 Mbits/sec 左右。

- 6. 5 道检查题
题1
iperf3、sar -n DEV 1、ip -s link 三者分别是看什么的？
答案：

iperf3：实际吞吐


sar -n DEV 1：每秒接口收发速率


ip -s link：累计字节/包数/错误/丢包


题2
为什么 1G 网口跑 TCP 测试时，看到 943 Mbits/sec 可以认为正常？
答案：
因为协议头、帧开销、系统栈处理会消耗一部分带宽，1G 网口常见有效 TCP 吞吐大约就是 930~950 Mbits/sec。

题3
执行 iperf3 -c <server_ip> -t 30 时，本机 sar 中通常哪个方向更高？
答案：
通常是 TX 更高，因为 client 默认向 server 发数据。

题4
为什么不能只看 iperf3 的吞吐结果？
答案：
因为吞吐有数值不代表链路健康，还要看：

sar 是否真的有对应流量


ip -s link 是否有 errors/dropped
这样才能确认结果真实且链路正常。


题5
ip -s link 中哪几个字段最值得重点关注？
答案：

RX bytes / TX bytes


RX packets / TX packets


errors


dropped


carrier


- 7. Day12 复盘模板
你可以以后每天按这个模板写：
今天学习了网络吞吐基线测试，掌握了 iperf3、sar -n DEV 1、ip -s link 的基本用途。理解了 iperf3 负责输出吞吐结果，sar 负责实时观察接口速率，ip -s link 负责查看累计字节与错误丢包统计。对 1G 网口来说，正常 TCP 吞吐常见在 930~950 Mbits/sec 左右。后续做网络性能测试时，不能只看一个压测数字，而要把吞吐、接口速率、累计统计三者对应起来。

- 8. 今天的最终达成标准
Day12 完成后，你应该能做到：

知道为什么 943 Mbits/sec 对 1G 来说正常


能把 iperf3 和 sar 单位对应起来


能看 ip -s link 是否有错误和丢包


能说出“吞吐、实时速率、累计统计要互相印证”


- 9. 给你的 Day12 结课版
Day12 已完成。我已建立网络吞吐基线的基本分析方法，能够把 iperf3 吞吐结果、sar -n DEV 1 的接口实时速率，以及 ip -s link 的累计统计对应起来，并能基于 1G 网口判断吞吐是否正常、链路方向是否正确、接口是否存在错误或丢包。
下一步就可以进 Day13。


## 硬件对照表

| 测试时间 | 测试网口 |
|---|---|
| 2026-03-25 xx:xx | eno1 |
|---|---|


## 硬件对照表

| 测试网口 | 链路速率 |
|---|---|
| eno1 | 1G Full |
|---|---|


## 硬件对照表

| 测试时间 | 测试网口 |
|---|---|
| 模拟 | eno1 |
|---|---|

