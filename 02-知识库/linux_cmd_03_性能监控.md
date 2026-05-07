大家好，我是JACK，本篇是Linux命令系列第三篇。上一篇我们讲了硬件检测命令，这篇我们聊性能监控相关命令，结合实际工作中的使用场景和常见异常来讲。

---

## 一、top — 实时监控CPU和内存

top是最常用的性能监控命令，实时显示系统CPU、内存使用情况以及各进程资源占用。

```bash
[root@localhost ~]# top
top - 14:32:10 up 2 days,  3:21,  2 users,  load average: 2.45, 2.31, 2.18
Tasks: 312 total,   2 running, 310 sleeping,   0 stopped,   0 zombie
%Cpu(s): 85.3 us,  2.1 sy,  0.0 ni, 11.8 id,  0.5 wa,  0.0 hi,  0.3 si
MiB Mem : 516096.0 total, 489234.0 free,  15234.0 used,  11628.0 buff/cache
MiB Swap:      0.0 total,      0.0 free,     0.0 used. 499862.0 avail Mem

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
12345 root      20   0  512000  25600   4096 R  99.9   0.0   5:23.45 stress-ng
12346 root      20   0  512000  25600   4096 R  99.8   0.0   5:23.12 stress-ng
```

重点关注字段：

| 字段 | 说明 |
|------|------|
| load average | 系统1/5/15分钟平均负载，超过CPU核心数说明过载 |
| %Cpu us | 用户态CPU占用率 |
| %Cpu id | CPU空闲率，压测时应接近0 |
| %Cpu wa | IO等待，偏高说明存储有瓶颈 |
| MiB Mem | 内存总量、空闲、已用 |

**常用操作：**
```bash
top -d 2          # 每2秒刷新一次
top -p 12345      # 只监控指定PID进程
# 进入top后按1，展开显示每个CPU核心使用率
# 进入top后按M，按内存占用排序
# 进入top后按P，按CPU占用排序
```

**常见异常：**

- **load average持续远超CPU核心数** → 系统过载，进程排队等待CPU，需要排查是哪个进程占用过高
- **wa值持续偏高（>20%）** → IO等待严重，存储可能有性能瓶颈或故障
- **id值接近100但业务跑不起来** → CPU不是瓶颈，问题可能在内存、网络或存储
- **zombie进程出现** → 有僵尸进程，需要排查父进程是否异常

---

## 二、htop — top的增强版

htop是top的增强版，界面更直观，支持鼠标操作，每个CPU核心单独显示，压测时一眼就能看出哪个核心跑满了。

```bash
# 安装htop
yum install htop -y

# 运行htop
[root@localhost ~]# htop
```

htop顶部会显示每个CPU核心的使用率进度条，压测时非常直观，建议作为top的日常替代工具。

**常见异常：**
- **部分核心跑满，部分核心空闲** → 压测工具没有绑定全部核心，检查压测命令是否指定了$(nproc)
- **内存进度条接近满** → 内存压力过大，注意OOM风险

---

## 三、iostat — 监控磁盘IO性能

iostat用来查看磁盘读写性能，在存储测试和排查IO瓶颈时非常有用。

```bash
[root@localhost ~]# iostat -x 2 3
Linux 4.19.90 (localhost)    03/02/2025    _aarch64_    (128 CPU)

Device            r/s     w/s     rkB/s     wkB/s   rrqm/s   wrqm/s  %rrqm  %wrqm r_await w_await aqu-sz rareq-sz wareq-sz  svctm  %util
sda              0.50  125.30      8.00   5234.00     0.00    12.50   0.00   9.08    0.85    2.34   0.29    16.00    41.77   0.18   2.30
nvme0n1        150.20  320.50  12032.00  25640.00     0.00     0.00   0.00   0.00    0.12    0.08   0.06    80.11    80.00   0.05   2.35
```

重点关注字段：

| 字段 | 说明 |
|------|------|
| r/s、w/s | 每秒读写次数（IOPS） |
| rkB/s、wkB/s | 每秒读写带宽 |
| r_await、w_await | 读写平均响应时间（ms），越低越好 |
| %util | 磁盘利用率，接近100%说明磁盘跑满 |
| aqu-sz | 平均队列深度，持续偏高说明IO压力大 |

**常用命令：**
```bash
iostat -x 2        # 每2秒刷新，显示详细信息
iostat -x 2 5      # 每2秒刷新，共显示5次
iostat -d nvme0n1  # 只监控指定磁盘
```

**常见异常：**
- **%util持续接近100%** → 磁盘跑满，IO瓶颈，考虑更换更高性能存储或检查硬盘健康状态
- **r_await或w_await异常高（>100ms）** → 磁盘响应慢，可能是硬盘老化或RAID配置问题
- **rkB/s和wkB/s远低于标称值** → 存储性能不达标，需要深入排查

---

## 四、vmstat — 查看系统整体状态

vmstat提供系统整体视角，包括CPU、内存、IO、进程等综合信息，适合快速判断系统瓶颈在哪里。

```bash
[root@localhost ~]# vmstat 2 5
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 2  0      0 501234  12345 234567    0    0     5   125  234  456 85  2 12  1  0
 3  0      0 500234  12345 234567    0    0     0   234  256  478 87  2 10  1  0
 1  0      0 499234  12345 234567    0    0     0   128  212  432 83  2 14  1  0
```

重点关注字段：

| 字段 | 说明 |
|------|------|
| r | 等待运行的进程数，持续大于CPU核心数说明过载 |
| b | 处于不可中断睡眠的进程数，偏高说明IO阻塞 |
| swpd | 使用的swap空间，服务器正常应为0 |
| si、so | swap换入换出速率，不为0说明内存不足 |
| wa | IO等待CPU占比 |
| us、sy | 用户态和内核态CPU占比 |

**常用命令：**
```bash
vmstat 2           # 每2秒刷新
vmstat 2 10        # 每2秒刷新，共10次
vmstat -m          # 查看内存slab信息
```

**常见异常：**
- **swpd不为0且si/so持续增加** → 内存严重不足，系统开始使用swap，性能会大幅下降
- **r值持续远大于CPU核心数** → CPU严重过载
- **b值持续偏高** → IO阻塞严重，结合iostat进一步定位是哪块磁盘有问题
- **sy值异常高（>30%）** → 内核态开销过大，可能有驱动问题或系统调用异常

---

## 五、组合使用技巧

压测时建议多个命令配合使用，同时收集日志：

```bash
# 终端1：实时看CPU和内存
htop

# 终端2：实时看磁盘IO
iostat -x 2

# 终端3：收集vmstat日志
vmstat 5 >> vmstat_log.txt

# 终端4：收集温度日志
watch -n 5 'ipmitool sensor list | grep -i temp' >> temp_log.txt
```

这样压测结束后，既有实时观察记录，也有完整的日志文件可以事后分析。

---

## 六、总结

四个命令各有侧重：
- **top/htop** — 实时看CPU和内存使用率，定位高占用进程
- **iostat** — 专注磁盘IO性能，排查存储瓶颈
- **vmstat** — 系统整体视角，快速判断瓶颈在CPU、内存还是IO

遇到性能异常时，建议先用vmstat快速判断瓶颈方向，再用top或iostat深入定位具体问题。

下一篇我们聊**日志排查命令详解**，结合实际故障案例讲解如何用日志定位问题，敬请期待！

欢迎关注**JACK的服务器笔记**！
