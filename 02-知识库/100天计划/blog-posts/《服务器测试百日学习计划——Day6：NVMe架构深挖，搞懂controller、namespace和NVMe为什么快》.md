大家好，我是JACK，本篇是服务器测试百日学习计划Day6。

Day5 我们搞清楚了存储体系全景，今天往下钻一层——深挖 NVMe 架构，搞懂 NVMe 为什么快，以及 controller、namespace 到底是什么。

## 一、四个最容易混的词

先把这四个词彻底分清楚，这是理解 NVMe 的基础。

**NVMe**：协议。定义的是主机怎么和高速 SSD 通信。

**PCIe**：总线。NVMe 盘通过 PCIe 跟 CPU 通信。

**U.2 / M.2**：物理形态。不是协议，不是总线。

**SSD**：存储介质类型。

所以一句最标准的话是：

> 我们这台服务器的两块盘，是 **U.2 形态的 NVMe SSD**，通过 **PCIe 总线** 接到 CPU。

还有一个常见混淆点——M.2 不等于 NVMe：

| 形态 | 可以走的协议 |
|------|------------|
| U.2 | NVMe（企业级标配） |
| M.2 | NVMe 或 SATA（两种都可以） |

Day5 里我们的 sda/sdb 就是 M.2 形态 + SATA 协议，不是 NVMe。

---

## 二、实机 NVMe 识别

### nvme list 总览

```bash
[root@bogon ~]# nvme list
Node         SN               Model              Namespace  Usage               Format       FW Rev
------------ ---------------- ------------------ ---------- ------------------- ------------ -------
/dev/nvme0n1 D77446D401J852   DERAP44YGM03T2US   1          3.20 TB / 3.20 TB   512 B + 0 B  D7Y05M1F
/dev/nvme1n1 D77446D4017E52   DERAP44YGM03T2US   1          3.20 TB / 3.20 TB   512 B + 0 B  D7Y05M1F
```

重点关注这几列：

| 字段 | 含义 |
|------|------|
| Node | 设备节点路径 |
| Model | 硬盘型号 |
| Namespace | 命名空间编号 |
| Usage | 已用/总容量 |
| Format | 扇区格式（512B） |
| FW Rev | 固件版本 |

### lspci 确认 PCIe 层

```bash
[root@bogon ~]# lspci | grep -i non
81:00.0 Non-Volatile memory controller: DERA Storage Device 1515
82:00.0 Non-Volatile memory controller: DERA Storage Device 1515
```

这一步的作用是把块设备层（nvme0n1）和 PCIe 设备层（81:00.0）对应起来，建立完整的链路认知。

---

## 三、controller 和 namespace 是什么

这是 Day6 最核心的概念，面试高频题。

### controller（控制器）

可以理解为主机和盘之间负责协议处理的逻辑单元。`lspci` 里看到的 NVMe 设备，本质上就是控制器级别的 PCIe 设备。

### namespace（命名空间）

控制器下面暴露出来的逻辑存储空间。

`/dev/nvme0n1` 这个设备名拆开来看：

- `nvme0`：第0个 NVMe 控制器
- `n1`：该控制器下的第1个 namespace

**一个 controller 下面可以有一个或多个 namespace。** 我们这台机器每块盘是一个控制器 + 一个 namespace 的标准配置。

> 💡 **记住这句话**：controller 是控制器，namespace 是控制器下面暴露出来的逻辑盘空间。

---

## 四、NVMe 为什么快

面试经常问，标准答法记住这四点：

**1. 走 PCIe 总线**

SATA 受限于 SATA/AHCI 体系，物理带宽上限低。NVMe 直接走 PCIe，带宽上限高很多。

**2. 多队列**

NVMe 支持多提交队列 + 多完成队列，天然支持高并发 IO。SATA/AHCI 是单队列模式，并发能力差很多。

**3. 低延迟**

NVMe 是专门为闪存设计的协议，软件栈更轻，延迟更低，不像 AHCI 是从机械硬盘时代沿用下来的。

**4. 链路够宽**

结合 Day4 学的 PCIe 知识：我们这台服务器的 NVMe 跑在 PCIe Gen4 x4，理论带宽约 8GB/s。

所以完整的标准答法是：

> NVMe 能跑到 7GB/s，是因为它走 PCIe Gen4 x4 总线，协议本身支持多队列，软件栈延迟低，带宽和并发能力都比 SATA 体系强很多。

---

## 五、nvme-cli 查看控制器和健康状态

### nvme id-ctrl 看控制器信息

```bash
[root@bogon ~]# nvme id-ctrl /dev/nvme0n1
NVME Identify Controller:
vid     : 0x1d78          # 厂商ID
ssvid   : 0x1d78          # 子系统厂商ID
sn      : D77446D401J852  # 序列号（唯一身份编号）
mn      : DERAP44YGM03T2US # 型号
fr      : D7Y05M1F        # 固件版本
ver     : 0x20000         # NVMe协议版本（NVMe 2.0）
tnvmcap : 3200631791616   # 总容量（3.2TB）
nn      : 1               # 该控制器下的namespace数量为1
...
ps 0    : mp:18.00W       # 最大功耗状态
ps 4    : mp:10.00W       # 最低功耗状态
```

重点关注：sn（序列号）、mn（型号）、fr（固件版本）、ver（NVMe协议版本）、nn（namespace数量）。

### nvme smart-log 看健康状态

```bash
[root@bogon ~]# nvme smart-log /dev/nvme0n1
Smart Log for NVME device:nvme0n1 namespace-id:ffffffff
critical_warning         : 0       # 严重警告，0表示正常
temperature              : 43 C    # 当前温度
available_spare          : 100%    # 备用块空间100%，冗余充足
available_spare_threshold: 30%     # 低于30%会触发告警
percentage_used          : 0%      # 寿命消耗0%，盘很新
data_units_read          : 2,423,907
data_units_written       : 2,331,036
host_read_commands       : 175,882,364
host_write_commands      : 170,152,224
power_on_hours           : 1,253   # 累计使用1253小时
unsafe_shutdowns         : 297     # 非正常掉电次数
media_errors             : 0       # 介质错误，0表示正常
num_err_log_entries      : 0       # 错误日志条目，0表示正常
Temperature Sensor 1     : 54 C
Temperature Sensor 2     : 43 C
Temperature Sensor 3     : 43 C
```

重点关注字段：

| 字段 | 说明 | 本机状态 |
|------|------|---------|
| critical_warning | 严重警告 | 0，正常 |
| temperature | 当前温度 | 43℃，正常 |
| available_spare | 备用块空间 | 100%，充足 |
| percentage_used | 寿命消耗 | 0%，盘很新 |
| power_on_hours | 累计使用时间 | 1253小时 |
| media_errors | 介质错误 | 0，正常 |
| num_err_log_entries | 错误日志 | 0，正常 |

> 💡 **实际测试中**：每次验收新盘，先跑一遍 `nvme smart-log`，重点看 `critical_warning`、`media_errors`、`percentage_used` 三项，任何一项异常都要记录并评估是否需要换盘。

---

## 六、Python 自动检测 NVMe

```python
# nvme_check.py
import subprocess

# 打印 NVMe 总览
print("==== NVMe List ====")
nvme_list = subprocess.run(["nvme", "list"], capture_output=True, text=True).stdout
print(nvme_list)

# 统计 NVMe 数量
count = nvme_list.count("/dev/nvme")
print("NVMe count:", count)

# 打印 PCIe 层 NVMe 设备
print("==== PCIe NVMe ====")
pcie_nvme = subprocess.run(
    ["bash", "-lc", "lspci | grep -i nvme"],
    capture_output=True, text=True
).stdout
print(pcie_nvme)
```

```bash
python3 nvme_check.py
```

脚本目标：把 NVMe 的块设备层和 PCIe 设备层对应起来，一键输出。

---

## 总结

| 概念 | 类型 | 说明 |
|------|------|------|
| NVMe | 协议 | 定义主机与高速SSD通信方式 |
| PCIe | 总线 | NVMe 的物理传输通道 |
| U.2 / M.2 | 形态 | 物理接口形态，不代表协议 |
| controller | 控制器 | PCIe 设备层，负责协议处理 |
| namespace | 逻辑盘空间 | controller 下暴露的存储单元，nvme0**n1** 里的 n1 |

**NVMe 快的四个原因：PCIe 带宽高、多队列并发、低延迟软件栈、Gen4 x4 链路宽。**

下一篇 Day7 深入 RAID 控制器与逻辑盘，结合 storcli64 实测数据讲 RAID 配置与排查，敬请期待！

欢迎关注 **JACK的服务器笔记**，我们下篇见！
