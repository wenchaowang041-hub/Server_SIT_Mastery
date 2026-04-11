Day6 主题
NVMe 架构深挖
Day5 你已经解决了：
NVMe / SATA / SAS / RAID 区分
实机存储识别
存储路径
hiraidadm / RAID 基础查看
Day6 要继续往下一层钻：
NVMe 为什么快
NVMe 到底比 SATA 快在哪里
NVMe 的 controller / namespace / queue 是什么
你这台机器的 NVMe 具体参数怎么看

Day6 目标
今天结束后，你要能做到：
- 1. 说清 NVMe = 协议，PCIe = 总线，U.2 / M.2 = 形态
- 2. 看懂 nvme list 的主要字段
- 3. 用 nvme-cli 查看控制器和健康信息
- 4. 说清 namespace 和 controller 的区别
- 5. 解释 NVMe 为什么能跑到 7GB/s 左右
- 6. 写一个最基础的 NVMe 检测脚本

Day6 总体安排
今天分 6 个模块：
## NVMe 核心概念

## 你机器里的 NVMe 实机识别

## controller / namespace

## NVMe 为什么快

## NVMe 健康与状态查看

## Python 自动检测 NVMe


## NVMe 核心概念

先把 4 个最容易混的词彻底分开。
- 1. NVMe
这是：
协议
它定义的是主机怎么和高速 SSD 通信。

- 2. PCIe
这是：
总线
NVMe 盘通过 PCIe 跟 CPU 通信。

- 3. U.2 / M.2
这是：
物理形态 / 接口形态
不是协议。
所以你以后一定要分清：
U.2 形态 + NVMe 协议 + PCIe 总线
M.2 形态 + 可能是 NVMe，也可能是 SATA

- 4. SSD
这是：
存储介质类型
所以一句最标准的话是：
你的两块盘是 U.2 形态的 NVMe SSD，通过 PCIe 接到 CPU

## 你机器里的 NVMe 实机识别

你机器目前确认有两块 NVMe：
/dev/nvme0n1
/dev/nvme1n1
今天先重新看一遍基础信息。
先跑这两个命令
1）看 NVMe 总览
nvme list
/dev/nvme0n1相当于第0个nvme控制器上的第一个namespace

```bash
[root@bogon ~]# nvme list
Node                  SN                   Model                                    Namespace Usage                      Format           FW Rev
--------------------- -------------------- ---------------------------------------- --------- -------------------------- ---------------- --------
/dev/nvme0n1          D77446D401J852       DERAP44YGM03T2US                         1           3.20  TB /   3.20  TB    512   B +  0 B   D7Y05M1F
/dev/nvme1n1          D77446D4017E52       DERAP44YGM03T2US                         1           3.20  TB /   3.20  TB    512   B +  0 B   D7Y05M1F
```

重点看这几列：
Node设备节点
Model型号
Namespace命名空间编号
Usage已用/总容量
Format扇区格式
FW Rev固件版本

2）看 PCIe 层的 NVMe
lspci | grep -i nvme
你应该能看到类似：
81:00.0 Non-Volatile memory controller
82:00.0 Non-Volatile memory controller
这一步的作用是把：
块设备层
↔ PCIe设备层
对应起来。

## controller 和 namespace

这是 Day6 最核心的概念。
- 1. controller 是什么
可以理解成：
NVMe 控制器
也就是主机和盘之间真正负责协议处理的逻辑单元。
你在 lspci 里看到的 NVMe 设备，本质上就是控制器级别的 PCIe 设备。

```bash
[root@bogon ~]# lspci | grep -i non
81:00.0 Non-Volatile memory controller: DERA Storage Device 1515
82:00.0 Non-Volatile memory controller: DERA Storage Device 1515
```



- 2. namespace 是什么
可以理解成：
控制器下面暴露出来的逻辑存储空间
Linux 里看到的：
/dev/nvme0n1
其中：

nvme0 更接近控制器


n1 是 namespace 1

所以：
一个 controller 下面可以有一个或多个 namespace
你当前机器里每块盘看起来都是：
一个控制器 + 一个 namespace

你今天必须记住的一句话
controller 是控制器
namespace 是控制器下面暴露出来的逻辑盘空间

## NVMe 为什么快

这题以后面试经常问。
原因1：走 PCIe
SATA 受限于 SATA/AHCI 体系。
NVMe 直接走 PCIe，所以物理带宽上限高很多。

原因2：多队列
NVMe 支持：
多提交队列
多完成队列
比 SATA/AHCI 那种单队列模式强很多。
你现在不用死记协议细节，先记住这一句：
NVMe 比 SATA 快，不只是因为盘快，而是协议和总线都更适合并发

原因3：低延迟
NVMe 是专门为闪存设计的协议，软件栈更轻，延迟更低。

原因4：链路够宽
你前面 Day4 已经看过：
LnkCap / LnkSta
Speed 16GT/s
Width x4
这就是为什么一块 Gen4 x4 NVMe 的理论带宽大概在：
8GB/s 左右
所以你以后回答：
NVMe 为什么能到 7GB/s？
标准答法就是：
因为它走 PCIe Gen4 x4，协议是 NVMe，支持多队列，延迟低，所以能提供高带宽和高并发。

## NVMe 健康与状态查看

今天把两个 nvme-cli 命令学会。
1）看控制器信息
先试：
nvme id-ctrl /dev/nvme0
如果环境里没有 /dev/nvme0 这种控制器节点，也可以试：
nvme id-ctrl /dev/nvme0n1


```bash
[root@bogon ~]# nvme id-ctrl /dev/nvme0
NVME Identify Controller:
```

vid       : 0x1d78厂商
ssvid     : 0x1d78厂商
sn        : D77446D401J852序列号（唯一身份编号）
mn        : DERAP44YGM03T2US型号
fr        : D7Y05M1F固件版本
rab       : 4
ieee      : 9cbd6e
cmic      : 0
mdts      : 8
cntlid    : 0
ver       : 0x20000  nvme协议版本、是NVME 2.0
rtd3r     : 0x7a1200
rtd3e     : 0xe4e1c0
oaes      : 0x300
ctratt    : 0
rrls      : 0
cntrltype : 1
fguid     :
crdt1     : 0
crdt2     : 0
crdt3     : 0
nvmsr     : 0
vwci      : 0
mec       : 0
oacs      : 0x1e
acl       : 0
aerl      : 3
frmw      : 0x12
lpa       : 0x2a
elpe      : 255
npss      : 4
avscc     : 0x1
apsta     : 0
wctemp    : 348
cctemp    : 356
mtfa      : 1200
hmpre     : 0
hmmin     : 0
tnvmcap   : 3200631791616总的NVME容量、3.2T
unvmcap   : 0
rpmbs     : 0
edstt     : 120
dsto      : 1
fwug      : 0
kas       : 0
hctma     : 0
mntmt     : 0
mxtmt     : 0
sanicap   : 0x40000002
hmminds   : 0
hmmaxd    : 0
nsetidmax : 0
endgidmax : 0
anatt     : 0
anacap    : 0
anagrpmax : 0
nanagrpid : 0
pels      : 0
domainid  : 0
megcap    : 0
sqes      : 0x66
cqes      : 0x44
maxcmd    : 0
nn        : 1表示这个控制器下有一个namespace
oncs      : 0x44
fuses     : 0
fna       : 0
vwc       : 0x4
awun      : 0
awupf     : 0
icsvscc     : 1
nwpc      : 0
acwu      : 0
ocfs      : 0
sgls      : 0
mnan      : 0
maxdna    : 0
maxcna    : 0
subnqn    : nqn.2015-07.com.derastorage:nvme:D77446D401J852
ioccsz    : 0
iorcsz    : 0
icdoff    : 0
fcatt     : 0
msdbd     : 0
ofcs      : 0
ps    0 : mp:18.00W operational enlat:0 exlat:0 rrt:0 rrl:0
rwt:0 rwl:0 idle_power:- active_power:-
ps    1 : mp:16.00W operational enlat:0 exlat:0 rrt:1 rrl:1
rwt:1 rwl:1 idle_power:- active_power:-
ps    2 : mp:14.00W operational enlat:0 exlat:0 rrt:2 rrl:2
rwt:2 rwl:2 idle_power:- active_power:-
ps    3 : mp:12.00W operational enlat:0 exlat:0 rrt:3 rrl:3
rwt:3 rwl:3 idle_power:- active_power:-
ps    4 : mp:10.00W operational enlat:0 exlat:0 rrt:4 rrl:4
rwt:4 rwl:4 idle_power:- active_power:-


```bash
[root@bogon ~]# nvme id-ctrl /dev/nvme0n1
NVME Identify Controller:
```

vid       : 0x1d78厂商
ssvid     : 0x1d78厂商
sn        : D77446D401J852序列号
mn        : DERAP44YGM03T2US型号
fr        : D7Y05M1F固件版本
rab       : 4
ieee      : 9cbd6e
cmic      : 0
mdts      : 8
cntlid    : 0
ver       : 0x20000
rtd3r     : 0x7a1200
rtd3e     : 0xe4e1c0
oaes      : 0x300
ctratt    : 0
rrls      : 0
cntrltype : 1
fguid     :
crdt1     : 0
crdt2     : 0
crdt3     : 0
nvmsr     : 0
vwci      : 0
mec       : 0
oacs      : 0x1e
acl       : 0
aerl      : 3
frmw      : 0x12
lpa       : 0x2a
elpe      : 255
npss      : 4
avscc     : 0x1
apsta     : 0
wctemp    : 348
cctemp    : 356
mtfa      : 1200
hmpre     : 0
hmmin     : 0
tnvmcap   : 3200631791616
unvmcap   : 0
rpmbs     : 0
edstt     : 120
dsto      : 1
fwug      : 0
kas       : 0
hctma     : 0
mntmt     : 0
mxtmt     : 0
sanicap   : 0x40000002
hmminds   : 0
hmmaxd    : 0
nsetidmax : 0
endgidmax : 0
anatt     : 0
anacap    : 0
anagrpmax : 0
nanagrpid : 0
pels      : 0
domainid  : 0
megcap    : 0
sqes      : 0x66
cqes      : 0x44
maxcmd    : 0
nn        : 1
oncs      : 0x44
fuses     : 0
fna       : 0
vwc       : 0x4
awun      : 0
awupf     : 0
icsvscc     : 1
nwpc      : 0
acwu      : 0
ocfs      : 0
sgls      : 0
mnan      : 0
maxdna    : 0
maxcna    : 0
subnqn    : nqn.2015-07.com.derastorage:nvme:D77446D401J852
ioccsz    : 0
iorcsz    : 0
icdoff    : 0
fcatt     : 0
msdbd     : 0
ofcs      : 0
ps    0 : mp:18.00W operational enlat:0 exlat:0 rrt:0 rrl:0
rwt:0 rwl:0 idle_power:- active_power:-
ps    1 : mp:16.00W operational enlat:0 exlat:0 rrt:1 rrl:1
rwt:1 rwl:1 idle_power:- active_power:-
ps    2 : mp:14.00W operational enlat:0 exlat:0 rrt:2 rrl:2
rwt:2 rwl:2 idle_power:- active_power:-
ps    3 : mp:12.00W operational enlat:0 exlat:0 rrt:3 rrl:3
rwt:3 rwl:3 idle_power:- active_power:-
ps    4 : mp:10.00W operational enlat:0 exlat:0 rrt:4 rrl:4
rwt:4 rwl:4 idle_power:- active_power:-

重点关注：
vid
ssvid
sn
mn
fr
rab
ieee
你今天不用全背，只要能看出：
厂商
序列号
型号
固件版本
就够了。

2）看健康信息
nvme smart-log /dev/nvme0n1

```bash
[root@bogon ~]# nvme smart-log /dev/nvme0n1
Smart Log for NVME device:nvme0n1 namespace-id:ffffffff
```

critical_warning                        : 0 当前没有严重警告
temperature                             : 43 C (316 Kelvin)温度
available_spare                       : 100%  可备用空间100%盘的监控冗余很充足
available_spare_threshold               : 30%
percentage_used                         : 0%寿命消耗0、盘很新、磨损很小
endurance group critical warning summary: 0
data_units_read                         : 2,423,907
data_units_written                      : 2,331,036
host_read_commands                      : 175,882,364
host_write_commands                     : 170,152,224
controller_busy_time                    : 6
power_cycles                            : 772
power_on_hours                          : 1,253累计使用1253小时、
unsafe_shutdowns                        : 297 非正常关机/非安全掉电次数
media_errors                            : 0 没有介质错误
num_err_log_entries                     : 0 没有明显错误记录
Warning Temperature Time                : 0
Critical Composite Temperature Time     : 0
Temperature Sensor 1           : 54 C (327 Kelvin)  传感器温度
Temperature Sensor 2           : 43 C (316 Kelvin)
Temperature Sensor 3           : 43 C (316 Kelvin)
Thermal Management T1 Trans Count       : 0
Thermal Management T2 Trans Count       : 0
Thermal Management T1 Total Time        : 0
Thermal Management T2 Total Time        : 0

重点看：
temperature
available_spare
percentage_used
data_units_read
data_units_written
power_on_hours
media_errors
num_err_log_entries
这一步非常实用，因为以后盘异常、寿命、介质错误，都会从这里看。

## Python 自动检测 NVMe

今天的 Python 还是服务于工程，不追求花哨。
脚本1：打印 NVMe 总览
import subprocess
#利用subprocess执行shell命令抓取nvme信息

print("==== nvme list ====")
print(subprocess.run(["nvme", "list"], capture_output=True, text=True).stdout)

脚本2：统计 NVMe 数量
import subprocess

result = subprocess.run(["nvme", "list"], capture_output=True, text=True)
count = result.stdout.count("/dev/nvme")

print("NVMe count:", count)

脚本3：组合脚本
import subprocess

print("==== NVMe List ====")
nvme_list = subprocess.run(["nvme", "list"], capture_output=True, text=True).stdout
print(nvme_list)

print("==== PCIe NVMe ====")
pcie_nvme = subprocess.run(["bash", "-lc", "lspci | grep -i nvme"], capture_output=True, text=True).stdout
print(pcie_nvme)
今天脚本目标只有一个：
把 NVMe 的块设备层和 PCIe 设备层对应起来

今天的训练任务
你就按这个顺序做。
任务1：重新采一遍 NVMe 信息
跑：
nvme list
lspci | grep -i nvme
nvme id-ctrl /dev/nvme0n1
nvme smart-log /dev/nvme0n1
如果 id-ctrl /dev/nvme0n1 不支持，再试：
nvme id-ctrl /dev/nvme0

任务2：回答这 5 个问题

NVMe 是协议、总线，还是形态？


PCIe 是协议、总线，还是形态？


U.2 是协议、总线，还是形态？


什么是 controller？


什么是 namespace？


任务3：写一个脚本
写：
nvme_check.py
至少完成：

输出 nvme list


统计 NVMe 数量


输出 lspci | grep -i nvme


今天结束后你会达到什么效果
如果今天做完，Day6 你会从：
知道这机器有两块 NVMe
升级到：
知道 NVMe 的协议、本质、形态、链路、健康信息、控制器/命名空间关系
这就是真正开始“懂 NVMe”。

先热身，回答我这 4 个小题
不看笔记，直接答：
1
NVMe 是协议、总线，还是物理形态？
2
PCIe 是协议、总线，还是物理形态？
3
U.2 是协议、总线，还是物理形态？
4
为什么说：
/dev/nvme0n1
这里的 n1 很关键？
你答完，我继续按 Day6 带你往下走。

