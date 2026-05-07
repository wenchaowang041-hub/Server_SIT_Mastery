


**前言**

大家好，我是JACK，服务器硬件测试工程师。百日学习计划Day3，今天进入性能分析专题，学会用各种工具判断服务器瓶颈所在。

---

**一、服务器工程能力图谱**

在正式开始之前，先梳理一下服务器工程师需要掌握的知识体系：

```
服务器工程师
│
├─ Linux系统
│   ├ top
│   ├ ps
│   ├ vmstat
│   └ iostat
│
├─ CPU架构
│   ├ NUMA
│   ├ CPU topology
│   └ CPU affinity
│
├─ PCIe架构
│   ├ PCIe Root Port
│   ├ PCIe Switch
│   └ PCIe Link Speed
│
├─ 存储系统
│   ├ NVMe
│   ├ SAS
│   └ RAID
│
├─ 网络系统
│   ├ NIC
│   ├ RDMA
│   └ IRQ
│
└─ 自动化
    ├ Python
    └ 测试脚本
```

**百日计划的目标：**
- 看到服务器 → 能分析结构
- 看到性能问题 → 能定位瓶颈
- 看到设备异常 → 能排查原因

---

**二、百日学习计划课程路线**

**第一轮（基础循环）：**

| Day | 主题 |
|-----|------|
| Day1 | Linux基础 |
| Day2 | 服务器硬件识别 |
| Day3 | NUMA架构 |
| Day4 | PCIe架构 |
| Day5 | NVMe存储 |
| Day6 | SAS / RAID |
| Day7 | 网络 / RDMA |
| Day8 | 性能分析 |
| Day9 | IRQ与CPU调度 |
| Day10 | 故障排查 |

**10天是一个小循环，后面会不断加深。**


**三个深入方向：**
- **硬件方向**：PCIe / NUMA / NVMe / 服务器整机
- **AI方向**：GPU / RDMA / 分布式训练
- **系统方向**：Linux内核 / 调度 / 系统架构

---

**三、Day3学习模块**

今天共10个模块：
- 模块1：服务器负载 load average
- 模块2：CPU使用率 top
- 模块3：CPU进程分析
- 模块4：内存分析 free
- 模块5：内存细节 /proc/meminfo
- 模块6：IO分析 iostat
- 模块7：进程资源 pidstat
- 模块8：系统运行时间 uptime
- 模块9：CPU中断 /proc/interrupts
- 模块10：watch实时监控

---

**模块1：系统整体负载 — uptime**

```bash
[root@bogon ~]# uptime
12:42:40 up 22:25, 2 users, load average: 0.00, 0.00, 0.00
[root@bogon ~]#
```

三个值分别是：**1分钟平均负载、5分钟平均负载、15分钟平均负载**。

**Load = 正在运行 + 等待CPU的任务数**

> 💡 **举例**：服务器有256个CPU，load=256说明CPU满载；如果load=512，那么有256个任务在排队等CPU。

**用stress-ng跑满CPU，观察load变化：**

```bash
stress-ng --cpu 256
```
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c97913e534f648fba50a41117687c80a.png#pic_center)

【图1：stress-ng运行后uptime，load average迅速升高到44.48】

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6fa7557c44ff418f8e21b726c98186be.png#pic_center)

【图2：stress-ng后台运行（&），连续执行uptime，load从70→86持续上升】

运行后通过uptime可以看到load average迅速升高，停止压测后逐渐回落，三个时间窗口（1/5/15分钟）体现出负载的变化趋势。

---

**模块2：CPU使用率分析 — top**

**CPU字段含义：**

| 字段 | 说明 |
|------|------|
| us | 用户进程占用 |
| sy | 内核占用 |
| id | 空闲 |
| wa | IO等待 |
| hi | 硬件中断 |
| si | 软件中断 |

```bash
[root@bogon ~]# top
top - 12:32:52 up 22:15, 2 users, load average: 0.00, 0.00, 0.00
Tasks: 832 total,   2 running, 830 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :  255968.2 total,  253765.1 free,    3330.2 used,     829.1 buff/cache
MiB Swap:    4096.0 total,    4096.0 free,       0.0 used.  252638.0 avail Mem

  PID USER   PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+   COMMAND
50500 root   20   0   27720   5260   3072 R   0.7   0.0   0:00.15  top
48715 root   20   0       0      0      0 I   0.3   0.0   0:00.20  kworker/u160:4-hclge
    1 root   20   0  174244  17552   9640 S   0.0   0.0   0:04.15  systemd
    2 root   20   0       0      0      0 S   0.0   0.0   0:00.08  kthreadd
    3 root    0 -20       0      0      0 I   0.0   0.0   0:00.00  rcu_gp
    4 root    0 -20       0      0      0 I   0.0   0.0   0:00.00  rcu_par_gp
    6 root    0 -20       0      0      0 I   0.0   0.0   0:00.00  kworker/0:0H-events_highpri
    8 root    0 -20       0      0      0 I   0.0   0.0   0:00.00  mm_percpu_wq
    9 root   20   0       0      0      0 S   0.0   0.0   0:00.00  rcu_tasks_rude_
   10 root   20   0       0      0      0 S   0.0   0.0   0:00.00  rcu_tasks_trace
   11 root   20   0       0      0      0 S   0.0   0.0   0:00.00  ksoftirqd/0
   12 root   20   0       0      0      0 I   0.0   0.0   0:04.67  rcu_sched
   13 root   rt   0       0      0      0 S   0.0   0.0   0:00.00  migration/0
   14 root   20   0       0      0      0 S   0.0   0.0   0:00.00  cpuhp/0
   15 root   20   0       0      0      0 S   0.0   0.0   0:00.00  cpuhp/1
   16 root   rt   0       0      0      0 S   0.0   0.0   0:00.00  migration/1
   17 root   20   0       0      0      0 S   0.0   0.0   0:00.00  ksoftirqd/1
   18 root   20   0       0      0      0 I   0.0   0.0   0:00.00  kworker/1:0-events
   19 root    0 -20       0      0      0 I   0.0   0.0   0:00.00  kworker/1:0H-events_highpri
   20 root   20   0       0      0      0 S   0.0   0.0   0:00.00  cpuhp/2
   21 root   rt   0       0      0      0 S   0.0   0.0   0:00.02  migration/2
   22 root   20   0       0      0      0 S   0.0   0.0   0:00.03  ksoftirqd/2
   24 root    0 -20       0      0      0 I   0.0   0.0   0:00.00  kworker/2:0H-events_highpri
   25 root   20   0       0      0      0 S   0.0   0.0   0:00.00  cpuhp/3
   26 root   rt   0       0      0      0 S   0.0   0.0   0:00.01  migration/3
   27 root   20   0       0      0      0 S   0.0   0.0   0:00.02  ksoftirqd/3
   29 root    0 -20       0      0      0 I   0.0   0.0   0:00.00  kworker/3:0H-events_highpri
   30 root   20   0       0      0      0 S   0.0   0.0   0:00.00  cpuhp/4
   31 root   rt   0       0      0      0 S   0.0   0.0   0:00.01  migration/4
   32 root   20   0       0      0      0 S   0.0   0.0   0:00.04  ksoftirqd/4
   34 root    0 -20       0      0      0 I   0.0   0.0   0:00.00  kworker/4:0H-events_highpri
   35 root   20   0       0      0      0 S   0.0   0.0   0:00.00  cpuhp/5
   36 root   rt   0       0      0      0 S   0.0   0.0   0:00.01  migration/5
   37 root   20   0       0      0      0 S   0.0   0.0   0:00.04  ksoftirqd/5
   39 root    0 -20       0      0      0 I   0.0   0.0   0:00.00  kworker/5:0H-events_highpri
   40 root   20   0       0      0      0 S   0.0   0.0   0:00.00  cpuhp/6
   41 root   rt   0       0      0      0 S   0.0   0.0   0:00.01  migration/6
   42 root   20   0       0      0      0 S   0.0   0.0   0:00.04  ksoftirqd/6
   44 root    0 -20       0      0      0 I   0.0   0.0   0:00.00  kworker/6:0H-events_highpri
   45 root   20   0       0      0      0 S   0.0   0.0   0:00.00  cpuhp/7
   46 root   rt   0       0      0      0 S   0.0   0.0   0:00.01  migration/7
   47 root   20   0       0      0      0 S   0.0   0.0   0:00.04  ksoftirqd/7
```

**top内置帮助（top界面按h查看）：**

```
Help for Interactive Commands - procps-ng 4.0.2
Window 1:Def: Cumulative mode Off.  System: Delay 3.0 secs; Secure mode Off.

  Z,B,E,e   Global: 'Z' colors; 'B' bold; 'E'/'e' summary/task memory scale
  l,t,m,I   Toggle: 'l' load avg; 't' task/cpu; 'm' memory; 'I' Irix mode
  0,1,2,3,4 Toggle: '0' zeros; '1/2/3' cpu/numa views; '4' cpus two abreast
  f,X       Fields: 'f' add/remove/order/sort; 'X' increase fixed-width fields
  L,&,<,>   Locate: 'L'/'&' find/again; Move sort column: '<'/'>' left/right
  R,H,J,C   Toggle: 'R' Sort; 'H' Threads; 'J' Num justify; 'C' Coordinates
  c,i,S,j   Toggle: 'c' Cmd name/line; 'i' Idle; 'S' Time; 'j' Str justify
  x,y       Toggle highlights: 'x' sort field; 'y' running tasks
  z,b       Toggle: 'z' color/mono; 'b' bold/reverse (only if 'x' or 'y')
  u,U,o,O   Filter by: 'u'/'U' effective/any user; 'o'/'O' other criteria
  n,#,^O    Set: 'n'/'#' max tasks displayed; Show: Ctrl+'O' other filter(s)
  V,v,F     Toggle: 'V' forest view; 'v' hide/show children; 'F' keep focused
  d,k,r,^R  'd' set delay; 'k' kill; 'r' renice; Ctrl+'R' renice autogroup
  ^G,K,N,U  View: ctl groups ^G; cmdline ^K; environment ^N; supp groups ^U
  W,Y,!,^E  Write cfg 'W'; Inspect 'Y'; Combine Cpus '!'; Scale time ^E'
  q         Quit
```

**stress-ng跑满时的top截图对比：**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/26e73fb20e6b415caaa99cdd33d12eb8.png#pic_center)

【图3：stress-ng满载时top截图 — us=99.9%，257个进程running，load=157】
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ca3051758e0e4b09ae18608b6315b44f.png#pic_center)

【图4：stress停止后top截图 — id=100%，负载回落，只有top进程在跑】

> 💡 **两张截图对比**，压测前后CPU使用率的变化一目了然。

---

**模块3：CPU进程分析**

在top界面中：

- **Shift + P**：按CPU使用率排序，快速找出CPU占用最高的进程

---

**模块4：内存使用分析 — free -h**

```bash
[root@bogon ~]# free -h
              total        used        free      shared  buff/cache   available
Mem:          249Gi        3.2Gi       247Gi       9.9Mi       834Mi       246Gi
Swap:         4.0Gi          0B       4.0Gi
[root@bogon ~]#
```

> 💡 **关键指标**：重点看 **used** 和 **available**。**available很低才说明内存不够用**，而不是看free，因为buff/cache随时可以回收。

**用stress-ng进行内存压测，观察内存变化：**

```bash
stress-ng --vm 32 --vm-bytes 1G &    # 32个进程，每个申请1G内存
stress-ng --vm 32 --vm-bytes 3G &    # 32个进程，每个申请3G内存
```
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6e9a07ff3bca41dea013bc2a760c8d95.png#pic_center)

【图5：内存压测过程 — free -h显示used从10Gi→11Gi→15Gi逐步增加，Swap开始被占用】

---

**模块5：查看内存细节 — /proc/meminfo**

重点关注三个指标：**MemTotal、MemFree、MemAvailable**

```bash
cat /proc/meminfo | head
```
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/e305bb3370c545ffadcf942911b13435.png#pic_center)

【图6：/proc/meminfo完整输出 — MemTotal: 2111956924 kB，MemFree: 2106256724 kB，MemAvailable: 2100865008 kB】

---

**模块6：IO分析 — iostat**

首先安装sysstat工具包：

```bash
yum install sysstat
```

**运行iostat：**

```bash
[root@bogon ~]# iostat -x 1    # -x 详细模式，1 每一秒输出一次
Linux 5.10.0-216.0.0.115.oe2203sp4.aarch64 (bogon)  2026年03月11日  _aarch64_  (80 CPU)

avg-cpu:  %user  %nice  %system  %iowait  %steal  %idle
           0.01   0.00     0.01     0.00    0.00   99.99

Device     r/s   rkB/s  rrqm/s  %rrqm  r_await  rareq-sz   w/s   wkB/s  wrqm/s  %wrqm  w_await  wareq-sz  d/s  dkB/s  drqm/s  %drqm  d_await  dareq-sz  f/s  f_await  aqu-sz  %util
dm-0      0.13    3.06    0.00   0.00     0.23     24.26  1.03   21.02    0.00   0.00     0.02     20.43  0.00   0.00    0.00   0.00     0.00      0.00  0.00     0.00    0.00   0.09
dm-1      0.00    0.03    0.00   0.00     0.30     70.40  0.00    0.00    0.00   0.00     0.00      0.00  0.00   0.00    0.00   0.00     0.00      0.00  0.00     0.00    0.00   0.00
dm-2      0.00    0.05    0.00   0.00     0.10     27.41  0.00    0.01    0.00   0.00     0.00      4.00  0.00   0.00    0.00   0.00     0.00      0.00  0.00     0.00    0.00   0.00
sda       0.11    3.90    0.05  33.10     0.41     35.81  0.68   21.03    0.46  40.69     0.24     31.12  0.00   0.00    0.00   0.00     0.00      0.00  0.00     0.00    0.00   0.00

avg-cpu:  %user  %nice  %system  %iowait  %steal  %idle
           0.01   0.00     0.01     0.00    0.00   99.98

Device     r/s   rkB/s  rrqm/s  %rrqm  r_await  rareq-sz   w/s   wkB/s  wrqm/s  %wrqm  w_await  wareq-sz  d/s  dkB/s  drqm/s  %drqm  d_await  dareq-sz  f/s  f_await  aqu-sz  %util
dm-0      0.00    0.00    0.00   0.00     0.00      0.00  0.00    0.00    0.00   0.00     0.00      0.00  0.00   0.00    0.00   0.00     0.00      0.00  0.00     0.00    0.00   0.00
dm-1      0.00    0.00    0.00   0.00     0.00      0.00  0.00    0.00    0.00   0.00     0.00      0.00  0.00   0.00    0.00   0.00     0.00      0.00  0.00     0.00    0.00   0.00
dm-2      0.00    0.00    0.00   0.00     0.00      0.00  0.00    0.00    0.00   0.00     0.00      0.00  0.00   0.00    0.00   0.00     0.00      0.00  0.00     0.00    0.00   0.00
sda       0.00    0.00    0.00   0.00     0.00      0.00  0.00    0.00    0.00   0.00     0.00      0.00  0.00   0.00    0.00   0.00     0.00      0.00  0.00     0.00    0.00   0.00
```
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/bf2ccf3aaad9425a9308c1769fe86103.png#pic_center)

【图7：iostat -x 1 实际运行截图】

**关键指标及阈值：**

| 指标 | 含义 | 告警阈值 |
|------|------|---------|
| %util | 磁盘利用率 | **>80% 磁盘接近瓶颈，=100% 磁盘跑满** |
| r_await | 读请求平均延迟(ms) | **>20ms IO延迟高** |
| w_await | 写请求平均延迟(ms) | **>20ms IO延迟高** |
| d_await | discard请求延迟(ms) | **>20ms IO延迟高** |
| f_await | flush请求延迟(ms) | 关注是否异常 |

---

**模块7：进程资源分析 — pidstat**

直接运行pidstat会提示命令不存在，yum单独安装也找不到：
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/cf9f4008b25d40aea3b5167216d713f3.png#pic_center)

【图8：pidstat报错"未找到命令"，yum install pidstat提示"Unable to find a match"】

因为pidstat属于**sysstat工具包**，需要安装整个包：

```bash
yum install sysstat
```

**sysstat包含以下完整工具：**
- **iostat** — IO分析
- **pidstat** — 进程资源分析
- **mpstat** — 多核CPU分析
- **sar** — 系统活动报告

安装完成后运行pidstat：

```bash
pidstat 1    # 每秒输出一次
```
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/47b1622ae9144bb18a642e36fbf747b0.png#pic_center)

【图9：pidstat 1 成功运行截图 — 显示各进程的%usr/%system/%CPU及所在CPU核心】

---

**模块8：系统运行时间 — uptime**

```bash
uptime
```
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ce92afffb11248f0b5dd5fb3cfc5cece.png#pic_center)

【图10：uptime输出 — 23:02:13 up 7:05, 2 users, load average: 8.00, 8.00, 8.00】

输出当前时间、系统已运行时长、登录用户数、以及1/5/15分钟平均负载，与top第一行信息一致。

---

**模块9：CPU中断分析 — /proc/interrupts**

```bash
cat /proc/interrupts
```
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/265fbc3b30d6490484a05b8550faaa61.png#pic_center)

【图11：/proc/interrupts截图 — 可以看到NVMe、NIC、GPU等设备的中断分布在各CPU核心上】

通过查看中断分布在哪些CPU核心上，可以判断是否存在中断集中导致的性能瓶颈。这与Day2学习的IRQ Affinity优化直接相关。

---

**模块10：watch实时监控**

```bash
watch -n 1 "cat /proc/interrupts"
```
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ec3c8a2525ff4558a7734e1469a9f503.png#pic_center)

【图12：watch -n 1 "cat /proc/interrupts" 实时监控截图 — 每秒自动刷新，可以实时观察中断变化】

配合前面各模块的命令，watch可以实现对CPU、内存、IO、中断的实时持续监控。

---

**四、Python模块（服务器工程版本）**

**1. 用Python读取服务器信息 — lscpu**

```python
import subprocess

result = subprocess.run(["lscpu"], capture_output=True, text=True)
print(result.stdout)
# 功能等同于直接运行 lscpu
```
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/56ff52a067b4443cb5c3e24a75b9c3e5.png#pic_center)

【图13：vim server_info.py 创建脚本后 python3.9 运行的截图】

**2. 读取CPU数量**

```python
import subprocess

result = subprocess.run(["lscpu"], capture_output=True, text=True)
for line in result.stdout.split("\n"):
    if "CPU(s):" in line:
        print(line)
# 等同于：lscpu | grep -i cpu
# 输出：CPU: 256
```

**3. 检测NVMe数量**

```python
# 创建文件：vim nvme_check.py
import subprocess

result = subprocess.run(["nvme", "list"], capture_output=True, text=True)
count = result.stdout.count("/dev/nvme")
print("NVMe devices:", count)
```
![
+](https://i-blog.csdnimg.cn/direct/e7efad3f2477411588ed0f9c97a6e5e8.png#pic_center)

【图14：nvme list输出 — /dev/nvme0n1 和 /dev/nvme1n1，共2块NVMe】

> 💡 nvme list和Python脚本都能看到NVMe数量是2，两种方式结果一致。

**4. 综合脚本**

```python
import subprocess

print("=== CPU ===")
print(subprocess.run(["lscpu"], capture_output=True, text=True).stdout)

print("=== Memory ===")
print(subprocess.run(["free", "-h"], capture_output=True, text=True).stdout)

print("=== NVMe ===")
print(subprocess.run(["nvme", "list"], capture_output=True, text=True).stdout)
```

**5. 更工程化的写法**

```python
import subprocess

def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True).stdout

print("=== CPU ===")
print(run(["lscpu"]))

print("=== Memory ===")
print(run(["free", "-h"]))

print("=== NVMe ===")
print(run(["nvme", "list"]))
```

> 💡 **工程化改进**：把重复的subprocess调用封装成run()函数，代码更简洁，后续添加更多命令只需一行，这就是写测试脚本的正确思路！

---

**Day3总结**

今天学习了服务器性能分析的10个核心模块：

- **uptime** — 查看系统负载，load值与CPU数对比判断是否满载
- **top** — CPU使用率，us/sy/id/wa/hi/si各字段含义，Shift+P按CPU排序
- **free -h** — 内存分析，关注available而非free
- **/proc/meminfo** — 内存细节，关注MemTotal/MemFree/MemAvailable
- **iostat -x 1** — IO分析，%util>80%磁盘接近瓶颈，await>20ms IO延迟高
- **pidstat** — 进程资源分析，属于sysstat包，yum install sysstat安装
- **/proc/interrupts** — 查看NVMe/NIC/GPU等设备中断分布
- **watch** — 实时监控任意命令输出

**Python工程化升级**：把重复调用封装成函数，逐步向自动化测试脚本演进！

明天继续！如果这篇文章对你有帮助，欢迎**点赞、收藏、关注**，百日学习计划持续更新，不迷路！

欢迎关注**JACK的服务器笔记**！

---

