# 服务器整合测试 SIT 工程师工具、用例与排障说明书 v0.1

> 适用对象：服务器 SIT / TE / TSE / 高级测试工程师 / ODM 服务器验证工程师。  
> 适用平台：通用 x86 服务器、ARM 服务器、AI GPU/NPU 服务器、NVMe 存储服务器、RoCE/IB 网络服务器、BMC/IPMI/Redfish 管理平台、部分整柜/液冷场景。  
> 使用原则：本手册不是“照抄命令合集”，而是把 **测试目的、测试手法、工具参数、日志收集、关键字段解读、用例设计思路、问题定位路径** 串起来。

---

## 0. 使用边界与安全提醒

### 0.1 本手册覆盖什么

本版覆盖服务器 SIT 最常见的测试域：

1. 基础信息与版本收集  
2. OS / Kernel / 系统日志  
3. CPU 测试  
4. Memory / ECC / RAS 测试  
5. PCIe / 拓扑 / AER 测试  
6. NVMe / SATA / RAID / HBA 存储测试  
7. Network / Ethernet / RoCE / IB 测试  
8. GPU / NPU 加速卡测试  
9. BIOS / BMC / CPLD / FW 测试  
10. Power / AC Cycle / DC Cycle / Reboot Cycle 测试  
11. Thermal / Fan / Sensor / 液冷基础测试  
12. 整机混合压力 / Burn-in / 稳定性测试  
13. 自动化日志收集脚本  
14. 不同平台的用例设计差异  
15. 常见故障排障路径

### 0.2 不能承诺“全世界所有工具零遗漏”

服务器厂商、芯片厂商、客户实验室会有大量私有工具，例如厂商诊断工具、生产线 FT 工具、GPU/NPU 厂商压测工具、IB 交换机厂商工具、BMC 厂商专用 dump 工具。本手册先建立通用体系，后续可继续补：

- Intel / AMD 平台专项
- NVIDIA / AMD GPU / Ascend NPU 专项
- Mellanox / Broadcom / Intel NIC 专项
- LSI/Broadcom RAID、Microchip、Marvell HBA 专项
- OpenBMC / AMI MegaRAC / AST2600 / AST2700 专项
- OCP / ORv3 / MGX / HGX / GB 系列整柜专项

### 0.3 高风险测试提醒

以下测试可能影响业务、擦写数据或导致设备重启，必须在独立测试环境执行：

- `fio` 对裸盘执行写入：可能清空数据
- `nvme format` / `blkdiscard`：破坏数据
- BIOS / BMC / CPLD / SSD / NIC / GPU / NPU FW 升级：可能导致设备不可用
- AC Cycle / DC Cycle / Power Cycle：会中断业务
- 满载压力 / 高温压力：可能触发保护、降频、重启
- GPU/NPU 算力压力：会占用业务卡
- 网络压力：可能影响生产网络
- 风扇策略修改：可能导致过温

测试前必须确认：

```bash
hostname
whoami
date
uptime
lsblk
mount
ip a
```

裸盘压力前必须二次确认设备：

```bash
lsblk -o NAME,MODEL,SERIAL,SIZE,TYPE,MOUNTPOINT
nvme list
smartctl -a /dev/nvme0
```

---

# 1. SIT 用例设计总方法

## 1.1 每条用例必须回答的 8 个问题

一条合格的服务器 SIT 用例，必须写清楚：

1. 测什么？  
2. 为什么测？  
3. 前置条件是什么？  
4. 怎么测？  
5. 测多久？  
6. 怎么判断 Pass / Fail？  
7. 失败后抓哪些日志？  
8. 修复后如何回归？

## 1.2 标准用例模板

```text
用例编号：SIT_<模块>_<序号>
用例名称：
测试目的：
测试优先级：P0/P1/P2/P3
适用阶段：EVT/DVT/PVT/SIT/MP/ORT/客户验收
适用平台：x86/ARM/GPU/NPU/Storage/Network/Rack
前置条件：
测试配置：
测试步骤：
测试命令：
监控项：
预期结果：
Pass 标准：
Fail 标准：
需收集日志：
回归要求：
风险说明：
备注：
```

## 1.3 优先级定义

| 优先级 | 含义 | 服务器 SIT 示例 |
|---|---|---|
| P0 | 阻塞开机、出货、客户验收 | 无法开机、OS 无法安装、CPU/内存/盘/网卡/GPU/NPU 缺失、满载掉卡、系统重启 |
| P1 | 关键功能和稳定性 | 压力测试、固件升级、BMC 管理、性能基准、长稳 burn-in |
| P2 | 一般功能和兼容性 | 特定 BIOS 选项、边缘配置、非主流 OS、低概率路径 |
| P3 | 扩展验证 | 易用性、显示字段、非关键告警、低风险场景 |

## 1.4 用例来源

SIT 用例不应该只从工具出发，应从以下来源拆解：

1. 客户规格：SOW、PRD、配置矩阵、验收标准  
2. 硬件架构：CPU、内存、PCIe、GPU/NPU、NIC、SSD、BMC、Power、Thermal  
3. 风险清单：掉卡、掉盘、AER、ECC、过温、降频、重启、性能不达标  
4. 历史问题：上一代平台 bug、客户 RMA、量产高发问题  
5. 真实业务场景：训练、推理、存储读写、网络转发、虚拟化、容器、集群部署  
6. 量产要求：工站测试、老化测试、抽检、产线节拍  
7. 运维要求：Redfish、IPMI、日志、远程升级、FRU、SEL、Sensor

## 1.5 用例设计的四种方法

### 方法一：按模块设计

适合普通服务器基础验证：

```text
System → CPU → Memory → Storage → Network → PCIe → BIOS → BMC → Power → Thermal → Firmware → Stress
```

优点：结构清晰。  
缺点：容易漏跨模块问题。

### 方法二：按场景设计

适合 AI 服务器和客户验收：

```text
GPU/NPU 满载 + SSD fio + NIC iperf/RDMA + CPU/Memory 压力 + BMC sensor 监控 + 72h burn-in
```

优点：贴近客户真实负载。  
缺点：失败后定位复杂。

### 方法三：按风险设计

适合高级 SIT：

| 风险 | 用例设计 |
|---|---|
| GPU/NPU 掉卡 | 长时间压力 + PCIe AER 监控 + 温度/功耗监控 |
| SSD 掉盘 | fio randrw + SMART + dmesg nvme reset 监控 |
| 网卡丢包 | iperf3/RDMA 长流 + ethtool counters |
| 过温降频 | 高温环境 + 满载压力 + 频率/温度曲线 |
| 固件版本不匹配 | FW 矩阵 + 升级/回滚 + 兼容性验证 |
| 上下电异常 | AC/DC cycle + POST/SEL/FRU/Sensor 验证 |

### 方法四：按阶段设计

| 阶段 | 测试重点 |
|---|---|
| EVT | Bring-up、点亮、关键设备识别、基础功能 |
| DVT | 设计稳定性、压力、兼容性、性能、可靠性 |
| PVT | 产线可生产性、测试工站、良率、流程一致性 |
| MP | 量产抽检、ORT、客户问题回归、版本维护 |

---

# 2. 测试前基础信息与版本收集

## 2.1 测试目的

测试前必须建立“环境快照”，否则后续 Bug 无法复现、无法对比、无法闭环。

必须收集：

- 服务器型号、序列号、资产编号
- CPU 型号和数量
- 内存容量、条数、插法、频率
- 磁盘型号、数量、序列号、固件
- 网卡型号、端口、固件、驱动
- GPU/NPU 型号、数量、固件、驱动
- BIOS/BMC/CPLD/PSU/FW 版本
- OS、Kernel、驱动版本
- PCIe 拓扑和链路状态
- BMC Sensor 和 SEL

## 2.2 推荐命令

```bash
mkdir -p /var/log/sit_collect_$(date +%F_%H%M%S)
cd /var/log/sit_collect_*

hostnamectl > 00_hostnamectl.txt
uname -a > 00_uname.txt
cat /etc/os-release > 00_os_release.txt
date > 00_date.txt
uptime > 00_uptime.txt
whoami > 00_user.txt

lscpu > 01_lscpu.txt
free -h > 01_free_h.txt
dmidecode > 01_dmidecode_all.txt
dmidecode -t system > 01_dmidecode_system.txt
dmidecode -t bios > 01_dmidecode_bios.txt
dmidecode -t memory > 01_dmidecode_memory.txt

lsblk -o NAME,MODEL,SERIAL,SIZE,TYPE,MOUNTPOINT,FSTYPE > 02_lsblk.txt
blkid > 02_blkid.txt
lspci -nn > 03_lspci_nn.txt
lspci -tv > 03_lspci_tv.txt
lspci -vvv > 03_lspci_vvv.txt

ip a > 04_ip_a.txt
ip route > 04_ip_route.txt
for i in $(ls /sys/class/net | grep -v lo); do ethtool $i > 04_ethtool_$i.txt 2>&1; ethtool -i $i > 04_ethtool_i_$i.txt 2>&1; ethtool -S $i > 04_ethtool_S_$i.txt 2>&1; done

journalctl -k -b > 05_journalctl_kernel_current_boot.txt
dmesg -T > 05_dmesg_T.txt
journalctl -p warning..alert -b > 05_journalctl_warning_alert.txt

ipmitool mc info > 06_bmc_mc_info.txt 2>&1
ipmitool fru print > 06_bmc_fru.txt 2>&1
ipmitool sensor > 06_bmc_sensor.txt 2>&1
ipmitool sdr elist > 06_bmc_sdr_elist.txt 2>&1
ipmitool sel list > 06_bmc_sel_list.txt 2>&1
ipmitool sel elist > 06_bmc_sel_elist.txt 2>&1
```

## 2.3 关键字段解读

### `hostnamectl`

关键字段：

| 字段 | 含义 | 风险点 |
|---|---|---|
| Operating System | OS 发行版 | 客户要求 OS 不匹配会导致驱动/工具不兼容 |
| Kernel | 内核版本 | PCIe、GPU/NPU、RDMA、NVMe 问题强相关 |
| Architecture | CPU 架构 | x86_64、aarch64 工具和驱动不同 |

### `dmidecode -t bios`

关键字段：

| 字段 | 含义 | 风险点 |
|---|---|---|
| Vendor | BIOS 厂商 | AMI、Insyde、EDK2 等差异 |
| Version | BIOS 版本 | 版本不对会导致枚举、NUMA、IOMMU 问题 |
| Release Date | 发布时间 | 旧版本可能缺修复 |

### `dmidecode -t memory`

关键字段：

| 字段 | 含义 | 风险点 |
|---|---|---|
| Size | 单条容量 | No Module Installed 表示槽位空 |
| Locator | 物理槽位 | 定位故障 DIMM 必备 |
| Speed / Configured Speed | 支持频率 / 当前频率 | 降频可能是插法、BIOS、CPU 限制 |
| Manufacturer / Serial Number | 厂商与序列号 | 兼容性、RMA、批次问题 |
| Type | DDR4/DDR5 | 平台规格确认 |

### `lspci -vvv`

关键字段：

| 字段 | 含义 | 解读 |
|---|---|---|
| LnkCap | 设备能力上限 | 例如 Speed 32GT/s, Width x16 |
| LnkSta | 当前链路状态 | 当前是否降速、降宽 |
| DevSta | 设备状态 | CorrErr、NonFatalErr、FatalErr、UnsupReq |
| AERCap | AER 能力 | 是否支持高级错误上报 |
| NUMA node | 设备归属 NUMA | 影响 GPU/NIC 性能 |

典型异常：

```text
LnkCap: Port #0, Speed 32GT/s, Width x16
LnkSta: Speed 16GT/s, Width x8
```

说明设备能力是 Gen5 x16，但当前只跑到 Gen4 x8。可能原因：

- BIOS 限速
- 插槽不支持
- Riser / Retimer / Cable 问题
- 信号质量问题导致降速
- 设备或主板设计限制
- 固件配置问题

---

# 3. OS / Kernel / 系统日志

## 3.1 测试目的

系统日志是 SIT 问题定位的第一现场。服务器出现掉卡、掉盘、panic、重启、AER、ECC、驱动异常，大多数会在以下位置留下痕迹：

- `dmesg`
- `journalctl`
- `/var/log/messages`
- `/var/log/syslog`
- `/var/crash`
- `kdump`
- BMC SEL

## 3.2 常用命令

```bash
dmesg -T
journalctl -k -b
journalctl -p err..alert -b
journalctl --since "2026-04-28 10:00:00" --until "2026-04-28 12:00:00"
last -x | head -50
uptime
cat /proc/uptime
ls -lh /var/crash
coredumpctl list
```

## 3.3 `dmesg` 常见关键字

```bash
dmesg -T | egrep -i "error|fail|fatal|panic|mce|edac|ecc|aer|pcie|nvme|reset|timeout|thermal|throttle|oom|xid|nmi|watchdog|link down|i/o error"
```

## 3.4 关键字段极详细解读

### Kernel panic

典型日志：

```text
Kernel panic - not syncing: Fatal exception
```

含义：内核遇到不可恢复错误。  
常见方向：

- Driver bug
- 内核 bug
- 内存错误
- PCIe 设备异常
- GPU/NPU 驱动异常
- 文件系统损坏
- 硬件 NMI/MCE

必须收集：

```bash
dmesg -T
journalctl -k -b -1
journalctl -k -b
last -x
ls -lh /var/crash
kdumpctl status
```

### MCE / Machine Check Exception

典型关键字：

```text
mce: [Hardware Error]
Machine check events logged
```

含义：CPU 或平台硬件报告严重错误。  
常见方向：

- CPU
- Memory
- Cache
- Interconnect
- PCIe
- 电源/温度引发硬件异常

建议命令：

```bash
journalctl -k | grep -i mce
mcelog --client 2>/dev/null || true
ras-mc-ctl --summary 2>/dev/null || true
ras-mc-ctl --errors 2>/dev/null || true
```

### OOM

典型日志：

```text
Out of memory: Killed process
oom-killer
```

含义：系统内存不足，内核杀进程。  
常见方向：

- 压力工具参数过大
- 应用内存泄漏
- HugePage 配置不合理
- 容器内存限制
- NUMA 分配不均

建议收集：

```bash
free -h
cat /proc/meminfo
numactl -H
journalctl -k | grep -i oom
```

### Watchdog reset

典型关键字：

```text
watchdog: BUG: soft lockup
NMI watchdog
```

含义：CPU 长时间未响应或内核卡死。  
常见方向：

- Driver 卡死
- 中断风暴
- PCIe 设备异常
- Kernel bug
- 高负载下调度异常

---

# 4. CPU 测试

## 4.1 测试目的

验证 CPU 在识别、拓扑、频率、满载、温度、功耗、NUMA、稳定性方面是否符合规格。

## 4.2 基础检查命令

```bash
lscpu
cat /proc/cpuinfo | head -80
numactl -H
cat /sys/devices/system/cpu/online
cat /sys/devices/system/cpu/offline
cpupower frequency-info 2>/dev/null || true
```

## 4.3 关键字段解读

### `lscpu`

| 字段 | 含义 | 解读 |
|---|---|---|
| Architecture | 架构 | x86_64 / aarch64 |
| CPU(s) | 逻辑 CPU 数 | 不符合预期可能 BIOS 关闭 HT/SMT 或 CPU 异常 |
| Thread(s) per core | 每核线程 | SMT/HT 是否开启 |
| Core(s) per socket | 每颗 CPU 核数 | 与规格比对 |
| Socket(s) | CPU 颗数 | 少 CPU 是 P0 问题 |
| NUMA node(s) | NUMA 节点数 | 影响 GPU/NIC/内存亲和性 |
| CPU max MHz / min MHz | 频率范围 | 性能异常时重点看 |

## 4.4 stress-ng CPU 压力

### 常用命令

```bash
stress-ng --cpu 0 --timeout 1h --metrics-brief
stress-ng --cpu 0 --cpu-method matrixprod --timeout 24h --metrics-brief --verify
stress-ng --matrix 0 --timeout 12h --metrics-brief
```

### 参数解读

| 参数 | 含义 | SIT 用法 |
|---|---|---|
| `--cpu N` | 启动 N 个 CPU stressor | `0` 表示按可用 CPU 自动选择，适合满载 |
| `--cpu-method` | CPU 压力算法 | matrixprod、fft、crc16 等，不同算法压力不同 |
| `--timeout` | 运行时间 | EVT 1h，DVT/PVT 12h/24h/72h |
| `--metrics-brief` | 输出简要性能统计 | 用于报告记录 |
| `--verify` | 做结果校验 | 可发现计算异常，但增加开销 |
| `--temp-path` | 临时文件路径 | 部分 stressor 使用 |

### Pass 标准

- 压力工具正常结束
- 系统无 panic、hang、reboot
- BMC SEL 无 critical event
- CPU 无异常降频或过温
- dmesg 无 MCE、fatal error、watchdog

### 必抓日志

```bash
lscpu
numactl -H
stress-ng 输出日志
dmesg -T
journalctl -k -b
ipmitool sel elist
ipmitool sensor
```

## 4.5 CPU 问题排障路径

### 现象：压力下重启

排查：

1. 查 BMC SEL 是否 power lost / thermal trip / VR fault  
2. 查 OS 日志是否 kernel panic  
3. 查是否有 MCE / NMI  
4. 查 CPU 温度是否超过阈值  
5. 查 PSU 是否冗余失效或功耗不足  
6. 降低负载复测，判断是否功耗/温度相关  
7. 换 BIOS 版本或默认 BIOS 设置复测

---

# 5. Memory / ECC / RAS 测试

## 5.1 测试目的

验证内存容量、插法、频率、ECC、压力稳定性、RAS 错误上报是否正常。

## 5.2 基础检查

```bash
free -h
dmidecode -t memory
numactl -H
cat /proc/meminfo
```

## 5.3 ECC / RAS 检查

```bash
ras-mc-ctl --summary 2>/dev/null || true
ras-mc-ctl --errors 2>/dev/null || true
ras-mc-ctl --status 2>/dev/null || true
journalctl -k | egrep -i "edac|ecc|mce|memory error|corrected|uncorrected"
dmesg -T | egrep -i "edac|ecc|mce|memory error|corrected|uncorrected"
```

## 5.4 关键字段解读

### Corrected Error / CE

含义：可纠正错误。  
判断：

- 单次少量 CE：需要记录和观察
- 同一 DIMM 持续增长：疑似 DIMM、插槽、CPU memory controller 或信号问题
- 压力测试期间持续增长：Fail，必须定位

### Uncorrected Error / UE

含义：不可纠正错误。  
判断：

- 一般为 Critical / P0
- 可能导致系统 panic、重启、数据错误
- 必须隔离 DIMM、槽位、CPU channel

### DIMM 定位字段

重点看：

- Socket
- Channel
- Slot / Locator
- DIMM label
- Physical address

## 5.5 memtester

### 命令

```bash
memtester 100G 5
memtester 80% 3  # 部分版本不支持百分比，需确认
```

### 参数解读

| 参数 | 含义 |
|---|---|
| 第一个参数 | 测试内存大小 |
| 第二个参数 | 循环次数 |

### 注意

`memtester` 是用户态工具，不能覆盖 OS 占用和保留内存。测试容量不要超过可用内存，否则会触发 OOM。

## 5.6 stressapptest

### 常用命令

```bash
stressapptest -M 102400 -s 3600 -W --pause_delay 1000
```

### 参数解读

| 参数 | 含义 |
|---|---|
| `-M` | 分配内存，单位 MB |
| `-s` | 测试时间，单位秒 |
| `-W` | 使用更多内存写压力 |
| `--pause_delay` | 线程 pause 延迟 |

### Pass 标准

- 工具无 data miscompare
- 无 ECC UE
- CE 不持续增长
- 系统无 panic / reboot

---

# 6. PCIe / 拓扑 / AER 测试

## 6.1 测试目的

验证所有 PCIe 设备枚举、拓扑、链路速率、链路宽度、AER 错误、NUMA 归属是否符合设计。

## 6.2 基础命令

```bash
lspci -nn
lspci -tv
lspci -vvv
lspci -s <BDF> -vvv
find /sys/bus/pci/devices -maxdepth 1 -type l
```

## 6.3 PCIe 关键概念

| 概念 | 说明 |
|---|---|
| BDF | Bus:Device.Function，例如 `3b:00.0` |
| Root Port | CPU/芯片组侧 PCIe 根端口 |
| Switch | PCIe Switch，下挂多个 Endpoint |
| Endpoint | 终端设备，如 GPU、NIC、NVMe |
| Retimer | 高速链路信号重定时器 |
| Link Speed | Gen3/4/5/6 速率 |
| Link Width | x1/x4/x8/x16 |
| AER | Advanced Error Reporting，高级错误上报 |

## 6.4 链路检查命令

```bash
for dev in $(lspci | awk '{print $1}'); do
  echo "===== $dev ====="
  lspci -s $dev -vvv | egrep "LnkCap|LnkSta|DevSta|AER|UESta|CESta" || true
done
```

## 6.5 关键字段解读

### LnkCap

设备或端口能力上限。

```text
LnkCap: Speed 32GT/s, Width x16
```

说明该链路理论支持 PCIe Gen5 x16。

### LnkSta

当前实际运行状态。

```text
LnkSta: Speed 16GT/s, Width x8
```

如果低于 LnkCap，需要确认设计是否允许。若设计要求 x16 Gen5，但实际 x8 Gen4，则 Fail。

### DevSta

```text
DevSta: CorrErr+ NonFatalErr- FatalErr- UnsupReq-
```

含义：

| 字段 | 含义 | 判断 |
|---|---|---|
| CorrErr | Correctable Error | 压力下持续出现需关注 |
| NonFatalErr | 非致命错误 | 通常 Fail，需要分析 |
| FatalErr | 致命错误 | P0/P1 严重问题 |
| UnsupReq | Unsupported Request | 可能是驱动/配置/设备访问异常 |

## 6.6 AER 日志解读

常见日志：

```text
pcieport 0000:80:02.0: AER: Corrected error received
PCIe Bus Error: severity=Corrected, type=Physical Layer
```

字段解释：

| 字段 | 含义 |
|---|---|
| `pcieport` | 报错来自 PCIe Root Port 或 Switch Port |
| BDF | 报错设备位置 |
| severity=Corrected | 可纠正错误 |
| severity=Uncorrected | 不可纠正错误 |
| type=Physical Layer | 物理层错误，常与信号相关 |
| type=Data Link Layer | 数据链路层错误，可能链路稳定性问题 |
| Receiver Error | 接收错误，常见 Correctable |
| BadTLP / BadDLLP | 包格式/链路层包错误 |
| Completion Timeout | 请求超时，较严重 |
| Surprise Down | 链路意外掉线，严重 |

## 6.7 PCIe 用例设计

### 用例：PCIe 设备枚举与链路检查

```text
测试目的：确认所有 PCIe 设备正常识别，链路速率和宽度符合设计。
测试步骤：
1. 收集 lspci -tv
2. 收集 lspci -vvv
3. 对比设计拓扑图
4. 检查 LnkCap/LnkSta
5. 检查 dmesg AER
Pass：所有设备识别，链路符合规格，无 fatal/non-fatal AER。
Fail：设备缺失、降速降宽、AER fatal、链路 surprise down。
```

### 用例：PCIe 压力下 AER 监控

```text
测试目的：验证 GPU/NIC/NVMe 满载时 PCIe 链路稳定性。
手法：
1. 启动 GPU/NPU、fio、iperf/RDMA 压力
2. 每 60 秒采集 dmesg 增量
3. 每 10 分钟采集 lspci -vvv
4. 测试 24/48/72 小时
Pass：无新增 fatal/non-fatal AER，无设备掉线，无链路降级。
```

---

# 7. Storage / NVMe / SATA / RAID / HBA 测试

## 7.1 测试目的

验证存储设备识别、健康状态、性能、长时间读写稳定性、掉盘、I/O error、reset、温度和固件兼容性。

## 7.2 基础命令

```bash
lsblk -o NAME,MODEL,SERIAL,SIZE,TYPE,MOUNTPOINT,FSTYPE
blkid
fdisk -l
nvme list
nvme smart-log /dev/nvme0
nvme error-log /dev/nvme0
smartctl -a /dev/nvme0
smartctl -a /dev/sda
```

## 7.3 NVMe 关键字段解读

### `nvme list`

| 字段 | 含义 | 判断 |
|---|---|---|
| Node | 设备节点 | `/dev/nvme0n1` |
| SN | 序列号 | RMA 和批次定位 |
| Model | 型号 | 与 BOM 比对 |
| Namespace | 命名空间 | 多 namespace 需确认 |
| Usage | 使用容量 | 裸盘测试前确认无业务数据 |
| Format | sector 大小 | 512B/4K |
| FW Rev | 固件版本 | 兼容性关键 |

### SMART 关键字段

| 字段 | 含义 | 风险 |
|---|---|---|
| critical_warning | 非 0 需关注 | 温度、寿命、可靠性异常 |
| temperature | 当前温度 | 高温会降速或掉盘 |
| available_spare | 剩余备用块 | 低于阈值风险 |
| percentage_used | 寿命消耗 | 高值不适合验证 |
| media_errors | 介质错误 | 非 0 需分析 |
| num_err_log_entries | 错误日志数量 | 压力前后对比 |

## 7.4 fio 测试工具

### 7.4.1 测试目的

`fio` 用于模拟不同 I/O 负载，验证 SSD/HDD/RAID/HBA 在读、写、随机、顺序、高队列深度、多线程下的性能和稳定性。

### 7.4.2 高风险提醒

以下命令会写裸盘，可能破坏数据：

```bash
fio --filename=/dev/nvme0n1 --rw=write
fio --filename=/dev/nvme0n1 --rw=randwrite
fio --filename=/dev/nvme0n1 --rw=randrw
```

测试前必须确认设备未挂载：

```bash
lsblk
mount | grep nvme0n1
```

### 7.4.3 常用参数解读

| 参数 | 含义 | 用例设计说明 |
|---|---|---|
| `--name` | job 名称 | 日志中识别不同任务 |
| `--filename` | 测试对象 | 可为文件或裸设备 |
| `--rw` | I/O 模式 | read/write/randread/randwrite/rw/randrw |
| `--bs` | 块大小 | 4k 看 IOPS，128k/1M 看带宽 |
| `--iodepth` | 队列深度 | NVMe 常用 32/64/128 |
| `--numjobs` | 并发 job 数 | 模拟多线程 |
| `--runtime` | 运行时间 | 稳定性常用 1h/12h/24h |
| `--time_based` | 按时间运行 | 不因文件大小提前结束 |
| `--direct=1` | 绕过 page cache | 更接近真实块设备性能 |
| `--group_reporting` | 聚合输出 | 多 job 汇总结果 |
| `--size` | 测试文件大小 | 文件测试时必须设置 |
| `--offset` | 起始偏移 | 多 job 分区测试 |
| `--verify` | 数据校验 | 查数据一致性，性能会下降 |
| `--verify=crc32c` | CRC 校验 | 常用于数据完整性 |
| `--output` | 输出文件 | 保存报告 |
| `--output-format=json` | JSON 输出 | 便于自动化解析 |

### 7.4.4 典型命令

#### 随机读 IOPS

```bash
fio --name=randread_4k --filename=/dev/nvme0n1 --rw=randread --bs=4k --iodepth=64 --numjobs=4 --runtime=1h --time_based --direct=1 --group_reporting --output=randread_4k.log
```

#### 随机写稳定性

```bash
fio --name=randwrite_4k --filename=/dev/nvme0n1 --rw=randwrite --bs=4k --iodepth=32 --numjobs=4 --runtime=12h --time_based --direct=1 --group_reporting --output=randwrite_4k_12h.log
```

#### 混合读写

```bash
fio --name=randrw_70_30 --filename=/dev/nvme0n1 --rw=randrw --rwmixread=70 --bs=4k --iodepth=32 --numjobs=4 --runtime=24h --time_based --direct=1 --group_reporting --output=randrw_70_30.log
```

#### 顺序带宽

```bash
fio --name=seqread_1m --filename=/dev/nvme0n1 --rw=read --bs=1m --iodepth=32 --numjobs=1 --runtime=1h --time_based --direct=1 --group_reporting
```

### 7.4.5 fio 输出关键字段解读

| 字段 | 含义 | 判断 |
|---|---|---|
| IOPS | 每秒 I/O 次数 | 4K 随机读写核心指标 |
| BW | 带宽 | 顺序读写核心指标 |
| lat | 延迟 | avg、min、max、percentile |
| clat | completion latency | 完成延迟，重点看 |
| slat | submission latency | 提交延迟 |
| 99.00th / 99.99th | 尾延迟 | 高尾延迟可能是抖动或 reset |
| err | 错误数 | 非 0 一般 Fail |

### 7.4.6 存储日志关键字

```bash
dmesg -T | egrep -i "nvme|I/O error|blk_update_request|reset|timeout|abort|failed|medium error|controller is down"
```

常见日志解读：

| 日志关键字 | 含义 | 方向 |
|---|---|---|
| `I/O error` | I/O 失败 | SSD、链路、驱动、文件系统 |
| `nvme reset` | 控制器 reset | 盘 FW、PCIe、温度、电源 |
| `controller is down` | 控制器不可用 | 严重掉盘 |
| `timeout` | 请求超时 | 设备忙、链路、FW bug |
| `Abort status` | 命令中止 | NVMe 命令异常 |

## 7.5 Storage 用例设计

### 用例：NVMe 识别与健康检查

```text
目的：确认 NVMe 盘数量、型号、序列号、FW、SMART 状态符合 BOM。
命令：nvme list; nvme smart-log; smartctl -a
Pass：数量正确，critical_warning=0，无 media_errors 增长，温度正常。
Fail：少盘、FW 不一致、SMART critical、media error、温度异常。
```

### 用例：NVMe 长时间 fio 稳定性

```text
目的：验证高负载下不掉盘、不 reset、不 I/O error。
手法：randrw 70/30，4K，iodepth 32，numjobs 4，12h/24h。
监控：dmesg、nvme smart-log、fio err、温度。
Pass：fio err=0，dmesg 无 nvme reset/I/O error，SMART 无异常增长。
```

---

# 8. Network / Ethernet / RoCE / IB 测试

## 8.1 测试目的

验证网卡识别、链路速率、驱动/固件、吞吐、丢包、错误计数、RDMA/RoCE/IB 能力、长时间稳定性。

## 8.2 基础命令

```bash
ip a
ip link
ip -s link
lspci | egrep -i "ethernet|network|infiniband|mellanox|broadcom|intel"
for i in $(ls /sys/class/net | grep -v lo); do
  ethtool $i
  ethtool -i $i
  ethtool -S $i
 done
```

## 8.3 ethtool 关键字段解读

### `ethtool ethX`

| 字段 | 含义 | 判断 |
|---|---|---|
| Supported ports | 支持端口类型 | TP/FIBRE/Backplane |
| Supported link modes | 支持速率 | 与网卡规格比对 |
| Speed | 当前速率 | 不达标为 Fail |
| Duplex | 双工 | 一般应 Full |
| Auto-negotiation | 自协商 | 视平台设计 |
| Link detected | 链路状态 | no 为链路问题 |

### `ethtool -i ethX`

| 字段 | 含义 |
|---|---|
| driver | 驱动名称 |
| version | 驱动版本 |
| firmware-version | 网卡固件版本 |
| bus-info | PCIe BDF |

### `ethtool -S ethX`

重点字段：

| 字段 | 含义 | 判断 |
|---|---|---|
| rx_errors | 接收错误 | 压力后增长需分析 |
| tx_errors | 发送错误 | 压力后增长需分析 |
| rx_dropped | 接收丢包 | 可能 buffer、驱动、网络拥塞 |
| tx_dropped | 发送丢包 | 队列、驱动、链路问题 |
| crc_errors | CRC 错误 | 光模块/线缆/信号问题 |
| symbol_error | 物理层错误 | 高速链路风险 |
| link_down_events | link down 次数 | 增长即 Fail |
| rx_discards_phy | 物理层丢弃 | 线缆/模块/交换机 |
| tx_timeout | 发送超时 | 驱动/固件/设备异常 |

## 8.4 iperf3 测试

### Server 端

```bash
iperf3 -s
iperf3 -s -p 5202
```

### Client 端 TCP

```bash
iperf3 -c <server_ip> -t 3600 -P 8
iperf3 -c <server_ip> -t 3600 -P 16 --json > iperf3_tcp.json
```

### UDP

```bash
iperf3 -c <server_ip> -u -b 10G -t 600
```

### 反向测试

```bash
iperf3 -c <server_ip> -R -t 600 -P 8
```

### 双向测试

```bash
iperf3 -c <server_ip> --bidir -t 600 -P 8
```

### 参数解读

| 参数 | 含义 | 用例说明 |
|---|---|---|
| `-s` | server 模式 | 接收端 |
| `-c` | client 模式 | 发起测试 |
| `-t` | 测试时间，秒 | 稳定性建议 1h+ |
| `-P` | 并行流数量 | 高速网卡需要多流打满 |
| `-u` | UDP 模式 | 测丢包、抖动 |
| `-b` | 目标带宽 | UDP 必须设置 |
| `-R` | reverse | 反向流量 |
| `--bidir` | 双向流量 | 同时收发 |
| `--json` | JSON 输出 | 自动化解析 |
| `-p` | 端口 | 避免冲突 |

### iperf3 输出字段解读

| 字段 | 含义 | 判断 |
|---|---|---|
| sender bitrate | 发送端带宽 | 与规格比对 |
| receiver bitrate | 接收端带宽 | 实际接收能力 |
| Retr | TCP 重传 | 高重传说明网络/链路问题 |
| Cwnd | 拥塞窗口 | 低窗口可能网络受限 |
| Jitter | UDP 抖动 | 高抖动影响实时性 |
| Lost/Total Datagrams | UDP 丢包 | 非预期丢包需分析 |

## 8.5 RDMA / RoCE / IB 基础检查

常见命令：

```bash
ibv_devinfo
rdma link
rdma dev
ibstat
ibstatus
ofed_info -s 2>/dev/null || true
```

RoCE 检查：

```bash
show_gids 2>/dev/null || true
cma_roce_mode 2>/dev/null || true
```

RDMA 性能测试常见工具：

```bash
ib_write_bw
ib_read_bw
ib_send_bw
ib_write_lat
ib_read_lat
```

典型命令：

Server：

```bash
ib_write_bw -d mlx5_0 -F
```

Client：

```bash
ib_write_bw -d mlx5_0 <server_ip> -F -D 600
```

关键字段：

| 字段 | 含义 |
|---|---|
| BW average | 平均带宽 |
| MsgRate | 消息速率 |
| Latency | 延迟 |
| GID index | RoCE v1/v2 和 VLAN 相关 |
| MTU | 影响吞吐 |

## 8.6 Network 用例设计

### 用例：网卡链路与 FW/Driver 检查

```text
目的：确认所有网口识别、速率、驱动、FW 正确。
命令：ip a; ethtool; ethtool -i; ethtool -S
Pass：端口数量正确，Speed 达标，Link detected yes，FW/Driver 符合要求。
Fail：少口、降速、link down、FW 版本不匹配。
```

### 用例：TCP 长时间吞吐测试

```text
目的：验证网卡长流稳定性和吞吐。
手法：iperf3 TCP，多并发流，1h/12h。
监控：ethtool -S 前后计数、dmesg、链路状态。
Pass：带宽达标，无 link down，无 error/drop/retransmit 异常增长。
```

### 用例：RoCE RDMA 带宽测试

```text
目的：验证 RDMA 能力、RoCE 配置和链路性能。
手法：ib_write_bw/ib_read_bw，指定设备和 GID。
Pass：RDMA 设备可识别，带宽达标，无 RDMA CM 失败，无端口 error 增长。
```

---

# 9. GPU / NPU 加速卡测试

## 9.1 测试目的

验证 GPU/NPU 的识别、驱动、固件、健康状态、拓扑、PCIe 链路、算力压力、温度、功耗、显存/HBM、卡间通信、长稳、掉卡恢复。

## 9.2 通用检查

```bash
lspci -tv
lspci -nn | egrep -i "nvidia|amd|huawei|ascend|accelerator|processing"
lspci -vvv | egrep "LnkCap|LnkSta|AER|DevSta" -n
journalctl -k | egrep -i "nvidia|xid|npu|ascend|pcie|aer|gpu|hbm|fatal|reset"
```

## 9.3 NVIDIA GPU 常用命令

```bash
nvidia-smi
nvidia-smi -L
nvidia-smi -q
nvidia-smi topo -m
nvidia-smi dmon -s pucvmt -d 5
nvidia-smi --query-gpu=index,name,serial,uuid,pci.bus_id,driver_version,vbios_version,temperature.gpu,power.draw,power.limit,utilization.gpu,memory.used,memory.total,ecc.errors.uncorrected.volatile.total,ecc.errors.corrected.volatile.total --format=csv
```

### 关键字段解读

| 字段 | 含义 | 判断 |
|---|---|---|
| GPU index | GPU 编号 | 与物理槽位不一定一致 |
| UUID | GPU 唯一 ID | RMA 和定位必备 |
| PCI Bus ID | PCIe BDF | 与 lspci 对应 |
| Driver Version | 驱动版本 | 与 CUDA/应用兼容 |
| VBIOS Version | GPU VBIOS | 版本矩阵关键 |
| Persistence Mode | 持久化模式 | 数据中心建议开启 |
| Pstate | 性能状态 | P0/P2 等，压力下应合理 |
| Temp | 温度 | 高温可能降频/保护 |
| Power Draw | 当前功耗 | 满载是否达到预期 |
| Power Limit | 功耗上限 | 配置错误会影响性能 |
| GPU-Util | GPU 利用率 | 压力是否打满 |
| Memory-Util | 显存利用率 | 显存压力观察 |
| ECC Errors | ECC 错误 | UE 严重，CE 持续增长需分析 |
| Xid | NVIDIA 驱动错误码 | 定位 GPU/驱动/硬件问题关键 |

### NVIDIA Xid 日志

查看：

```bash
journalctl -k | grep -i xid
dmesg -T | grep -i xid
```

常见解读：

| 关键字 | 含义 | 方向 |
|---|---|---|
| `NVRM: Xid` | NVIDIA 驱动报告错误 | 查具体 Xid 码 |
| GPU has fallen off the bus | GPU 从 PCIe 总线消失 | PCIe、电源、GPU、主板、固件 |
| ECC error | 显存/HBM 错误 | GPU/HBM/温度/硬件 |
| GPU reset | GPU 被重置 | 驱动、硬件、超时 |

## 9.4 Ascend NPU 常用命令

常见命令：

```bash
npu-smi info
npu-smi info -l
npu-smi info -t board
npu-smi info -t health
npu-smi info -t usages
ascend-dmi -h
ascend-dmi -i
ascend-dmi -f -d 0 -t int8 --et 60
```

> 注意：不同 CANN / toolkit / 驱动版本下 `npu-smi`、`ascend-dmi` 参数可能有差异，必须以本机 `-h` 输出和项目文档为准。

### 关键字段解读

| 字段 | 含义 | 判断 |
|---|---|---|
| NPU ID / Device ID | 设备编号 | 参数 `-d` 需要使用有效 ID |
| Health | 健康状态 | abnormal / warning 需分析 |
| Power | 功耗 | 满载是否达预期，有无保护 |
| Temperature | 温度 | 高温可能降频/保护 |
| AICore Util | AI Core 利用率 | 压力是否打满 |
| HBM Usage | HBM 使用率 | 显存/内存压力 |
| Chip ID | 芯片编号 | 与物理位置映射 |
| PCIe Bus | PCIe 位置 | 与 lspci 对应 |

### 常见错误：device ID invalid

现象：

```text
Error code [0xa] is displayed. The device ID does not exist or is invalid.
```

排查：

1. 先执行 `npu-smi info` 确认实际 Device ID  
2. 不要把无效数字当 `-d` 参数  
3. 确认驱动是否正常加载  
4. 确认是否所有 NPU 都识别  
5. 查看 `/var/log/ascend-dmi/ascend-dmi.log`  
6. 查看 dmesg 是否有 PCIe/AER/driver error

## 9.5 GPU/NPU 压力测试用例

### 用例：加速卡识别

```text
目的：确认所有 GPU/NPU 在 OS 下正常识别。
命令：lspci; nvidia-smi/npu-smi; lspci -tv
Pass：数量正确，状态正常，驱动加载正常，PCIe 链路符合设计。
Fail：少卡、状态异常、驱动失败、链路降级、AER error。
```

### 用例：单卡压力

```text
目的：验证每张卡单独满载稳定性，排除单卡个体问题。
手法：逐卡执行厂商压力工具。
监控：温度、功耗、利用率、HBM/显存、dmesg、BMC SEL。
Pass：单卡压力完成，无掉卡、无 Xid/driver error、无过温。
```

### 用例：多卡同时压力

```text
目的：验证满配系统在所有卡同时工作时的供电、散热、PCIe、驱动稳定性。
手法：8 卡/全卡同时压力 12h/24h/72h。
监控：GPU/NPU 利用率、功耗、温度、PCIe AER、BMC sensor、SEL。
Pass：全卡不掉、不降级、不报 fatal，性能无异常抖动。
```

### 用例：卡间通信

```text
目的：验证 GPU/NPU 之间通信拓扑和带宽。
手法：NCCL/HCCL/厂商通信测试工具。
监控：通信带宽、错误码、拓扑、网络/RDMA 状态。
Pass：带宽符合平台预期，无通信失败、无链路错误。
```

## 9.6 掉卡问题排障路径

现象：GPU/NPU 压力后少卡或工具不可见。

排查：

1. `lspci` 是否还能看到设备  
2. 如果 `lspci` 看不到：偏 PCIe/电源/硬件/固件  
3. 如果 `lspci` 能看到但 `nvidia-smi/npu-smi` 看不到：偏驱动/固件/设备状态  
4. 查 `dmesg` 是否有 AER / Xid / reset / timeout  
5. 查 BMC SEL 是否有过温、掉电、VR fault  
6. 查链路 `LnkSta` 是否降级  
7. 确认掉卡位置是否固定  
8. 换卡、换槽、换线、换 Riser、换 Retimer FW 交叉验证  
9. 降低功耗或打开风扇全速复测，判断温度/功耗相关  
10. 更换 BIOS/BMC/Driver/FW 版本验证

---

# 10. BMC / IPMI / Redfish 测试

## 10.1 测试目的

验证服务器带外管理能力，包括开关机、重启、Sensor、SEL、FRU、SDR、风扇控制、远程 KVM、SOL、固件升级、Redfish API、用户权限、安全策略。

## 10.2 IPMI 基础命令

```bash
ipmitool mc info
ipmitool chassis status
ipmitool power status
ipmitool power on
ipmitool power off
ipmitool power cycle
ipmitool power reset
ipmitool sensor
ipmitool sdr elist
ipmitool sel list
ipmitool sel elist
ipmitool sel clear
ipmitool fru print
ipmitool lan print
```

远程：

```bash
ipmitool -I lanplus -H <bmc_ip> -U <user> -P '<password>' power status
ipmitool -I lanplus -H <bmc_ip> -U <user> -P '<password>' sensor
```

## 10.3 IPMI 关键输出解读

### `ipmitool sensor`

| 字段 | 含义 | 判断 |
|---|---|---|
| Sensor 名称 | 传感器 | CPU Temp、DIMM Temp、Fan、Voltage、PSU |
| Reading | 当前读数 | 是否合理 |
| Units | 单位 | degrees C、RPM、Volts、Watts |
| Status | 状态 | ok / ns / cr / nr |
| Lower/Upper Threshold | 阈值 | 越界会告警 |

常见异常：

| 异常 | 含义 |
|---|---|
| `na` | 无读数，可能 sensor 未实现/异常 |
| `ns` | no sensor，SDR 问题或硬件不支持 |
| `cr` | critical，严重告警 |
| `nr` | non-recoverable，极严重 |

### `ipmitool sel elist`

重点字段：

| 字段 | 含义 |
|---|---|
| Event ID | 事件编号 |
| Date/Time | 时间，需要确认 BMC 时间正确 |
| Sensor | 触发源 |
| Event | 事件内容 |
| Assertion/Deassertion | 告警产生/恢复 |

常见 SEL：

| SEL 关键字 | 方向 |
|---|---|
| Power Unit | 电源事件 |
| Voltage | 电压异常 |
| Temperature | 过温 |
| Fan | 风扇异常 |
| Processor | CPU 错误 |
| Memory | 内存错误 |
| PCIe | PCIe 错误 |
| Watchdog | 系统 watchdog |

## 10.4 Redfish 基础命令

```bash
curl -k -u user:password https://<bmc_ip>/redfish/v1/
curl -k -u user:password https://<bmc_ip>/redfish/v1/Systems
curl -k -u user:password https://<bmc_ip>/redfish/v1/Chassis
curl -k -u user:password https://<bmc_ip>/redfish/v1/Managers
```

常见资源：

```text
/redfish/v1/Systems/1
/redfish/v1/Chassis/1
/redfish/v1/Managers/1
/redfish/v1/Chassis/1/Thermal
/redfish/v1/Chassis/1/Power
/redfish/v1/Systems/1/LogServices
/redfish/v1/UpdateService
```

## 10.5 Redfish 用例设计

### 用例：Redfish 基础资源访问

```text
目的：验证 Redfish 服务可访问，基础资源返回正常。
命令：curl 访问 ServiceRoot、Systems、Chassis、Managers。
Pass：HTTP 200，JSON 格式正确，字段完整。
Fail：无法访问、认证失败、HTTP 500、资源缺失。
```

### 用例：BMC Sensor 一致性

```text
目的：验证 IPMI 与 Redfish Sensor 数据一致。
手法：分别用 ipmitool sensor 和 Redfish Thermal/Power 获取读数。
Pass：关键温度、风扇、电源读数一致或在合理误差范围。
Fail：Redfish 缺字段、读数明显不一致、状态错误。
```

---

# 11. BIOS / FW / CPLD 测试

## 11.1 测试目的

验证 BIOS/BMC/CPLD/设备固件版本、升级、回滚、默认设置、配置持久化、启动项、PCIe 枚举、NUMA、IOMMU、SR-IOV、Secure Boot、Boot mode 等功能。

## 11.2 BIOS 重点用例

| 用例 | 目的 |
|---|---|
| BIOS 版本检查 | 确认版本符合 release |
| Load Default | 默认值是否正确 |
| Boot Order | 启动顺序是否可配置和保存 |
| UEFI/Legacy | 启动模式兼容 |
| Secure Boot | 安全启动功能 |
| Above 4G Decoding | 多 GPU/NPU 大 BAR 资源 |
| SR-IOV | 虚拟化网卡/设备能力 |
| IOMMU/VT-d/SVM | 虚拟化和设备隔离 |
| NUMA | CPU/Memory/PCIe 拓扑 |
| Power Policy | AC 恢复后行为 |

## 11.3 固件版本矩阵

必须建立版本矩阵：

```text
BIOS：
BMC：
CPLD：
CPU Microcode：
NIC FW：
SSD FW：
GPU/NPU FW：
PCIe Switch FW：
Retimer FW：
PSU FW：
OS：
Kernel：
Driver：
Toolkit/CUDA/CANN：
```

## 11.4 FW 升级用例

```text
目的：验证固件升级过程可靠，升级后版本正确，功能正常。
步骤：
1. 收集升级前版本和日志
2. 执行升级
3. 检查升级过程是否成功
4. AC/DC cycle 或 reboot
5. 检查升级后版本
6. 跑关键冒烟测试
Pass：升级成功，版本正确，配置符合预期，关键功能正常。
Fail：升级失败、版本不变、设备不可识别、配置丢失、功能异常。
```

必须收集：

```bash
dmidecode -t bios
ipmitool mc info
ipmitool sel elist
lspci -vvv
设备厂商 FW 查询命令
升级工具日志
```

---

# 12. Power / Cycle / 稳定性测试

## 12.1 测试目的

验证服务器在反复开关机、重启、AC 断电恢复、BMC power control、满载功耗、PSU 冗余场景下稳定。

## 12.2 常见测试类型

| 测试 | 含义 |
|---|---|
| Reboot Cycle | OS 重启循环 |
| DC Cycle | BMC 控制 power off/on |
| AC Cycle | 断开 AC 输入再恢复 |
| Power Button | 物理按键 |
| BMC Power Cycle | 远程电源循环 |
| PSU Redundancy | 拔 PSU 或模拟单电源 |
| Full Load Power | 满载功耗 |

## 12.3 Reboot Cycle 脚本示例

```bash
#!/bin/bash
COUNT_FILE=/root/reboot_count.txt
MAX=100
COUNT=$(cat $COUNT_FILE 2>/dev/null || echo 0)
COUNT=$((COUNT+1))
echo $COUNT > $COUNT_FILE
mkdir -p /root/reboot_logs

date >> /root/reboot_logs/reboot_history.log
hostname >> /root/reboot_logs/reboot_history.log
uptime >> /root/reboot_logs/reboot_history.log
lspci >> /root/reboot_logs/lspci_$COUNT.log
ipmitool sel elist >> /root/reboot_logs/sel_$COUNT.log 2>&1

if [ $COUNT -lt $MAX ]; then
  systemctl reboot
else
  echo "Reboot cycle completed: $COUNT" >> /root/reboot_logs/reboot_history.log
fi
```

## 12.4 Pass / Fail

Pass：

- 每次均能正常启动到 OS
- 设备数量不丢失
- BMC 可访问
- SEL 无 critical event
- OS 无 panic

Fail：

- 卡 POST
- 无法开机
- OS 启动失败
- 少设备
- SEL 出现 critical
- reboot 后配置丢失

---

# 13. Thermal / Fan / Sensor 测试

## 13.1 测试目的

验证服务器在空闲、满载、高温、风扇策略、异常风扇、电源冗余等场景下温度可控、无过温保护、无异常降频。

## 13.2 常用命令

```bash
ipmitool sensor
ipmitool sdr elist
sensors 2>/dev/null || true
watch -n 5 "ipmitool sensor | egrep -i 'temp|fan|power|voltage'"
```

GPU：

```bash
nvidia-smi dmon -s pucvmt -d 5
nvidia-smi --query-gpu=index,temperature.gpu,power.draw,clocks.sm,clocks.mem,utilization.gpu --format=csv -l 5
```

NPU：

```bash
npu-smi info
npu-smi info -t usages
npu-smi info -t health
```

## 13.3 关键字段

| 字段 | 含义 | 判断 |
|---|---|---|
| CPU Temp | CPU 温度 | 接近阈值会降频或保护 |
| DIMM Temp | 内存温度 | DDR5 高温可能降频/报错 |
| GPU/NPU Temp | 加速卡温度 | 高温掉卡/降频风险 |
| SSD Temp | 盘温度 | 高温导致限速/reset |
| Fan RPM | 风扇转速 | 过低散热不足，过高噪音/策略问题 |
| PSU Power | 电源功率 | 满载是否超 PSU 能力 |
| Inlet Temp | 入风温度 | 环境温度关键 |

## 13.4 用例：满载温度测试

```text
目的：验证整机满载散热能力。
手法：CPU + Memory + Storage + Network + GPU/NPU 同时压力。
监控：BMC sensor、GPU/NPU 温度、CPU 频率、SEL、dmesg。
Pass：无过温、无 thermal trip、无异常降频、无重启、风扇策略正常。
Fail：过温、降频严重、风扇异常、系统保护、掉卡、掉盘。
```

---

# 14. 整机混合压力 / Burn-in 测试

## 14.1 测试目的

模拟客户真实高负载，验证 CPU、内存、存储、网络、PCIe、GPU/NPU、BMC、Power、Thermal 的综合稳定性。

## 14.2 典型组合

```text
CPU：stress-ng --cpu 0
Memory：stressapptest / memtester
Storage：fio randrw
Network：iperf3 / RDMA perftest
GPU/NPU：厂商压力工具
BMC：sensor / SEL 定时采集
PCIe：dmesg AER 定时采集
```

## 14.3 整机压力启动示例

```bash
mkdir -p /var/log/sit_burnin_$(date +%F_%H%M%S)
LOGDIR=$(ls -td /var/log/sit_burnin_* | head -1)

# CPU
nohup stress-ng --cpu 0 --timeout 24h --metrics-brief > $LOGDIR/stress_ng_cpu.log 2>&1 &

# Storage 示例，谨慎确认设备
# nohup fio --name=nvme_randrw --filename=/dev/nvme0n1 --rw=randrw --rwmixread=70 --bs=4k --iodepth=32 --numjobs=4 --runtime=24h --time_based --direct=1 --group_reporting > $LOGDIR/fio_nvme0.log 2>&1 &

# BMC/OS monitor
nohup bash -c 'while true; do date; ipmitool sensor; ipmitool sel elist; dmesg -T | tail -200; sleep 60; done' > $LOGDIR/monitor.log 2>&1 &
```

## 14.4 整机压力 Pass 标准

- 测试工具无异常退出
- 系统无 reboot / panic / hang
- 无 GPU/NPU 掉卡
- 无 NVMe 掉盘 / reset / I/O error
- 无 NIC link down / 严重 error/drop
- 无 PCIe fatal / non-fatal AER
- 无 ECC UE，CE 不持续增长
- BMC SEL 无 critical event
- 温度、功耗、风扇在规格内
- 性能无异常大幅波动

---

# 15. 一键日志收集脚本

## 15.1 目的

当 SIT 失败时，必须快速固定现场，避免重启后证据丢失。

## 15.2 通用收集脚本

```bash
#!/bin/bash
set -euo pipefail
TS=$(date +%F_%H%M%S)
DIR=/var/log/sit_issue_collect_$TS
mkdir -p $DIR
cd $DIR

run() {
  echo "[RUN] $*"
  bash -c "$*" > "$(echo $* | tr ' /|:*' '______').log" 2>&1 || true
}

run "date"
run "hostnamectl"
run "uname -a"
run "cat /etc/os-release"
run "uptime"
run "last -x | head -100"

run "lscpu"
run "numactl -H"
run "free -h"
run "cat /proc/meminfo"
run "dmidecode"
run "dmidecode -t bios"
run "dmidecode -t system"
run "dmidecode -t memory"

run "lsblk -o NAME,MODEL,SERIAL,SIZE,TYPE,MOUNTPOINT,FSTYPE"
run "blkid"
run "nvme list"
for d in /dev/nvme[0-9]; do [ -e "$d" ] && run "nvme smart-log $d"; done
for d in /dev/nvme[0-9]; do [ -e "$d" ] && run "nvme error-log $d"; done

run "lspci -nn"
run "lspci -tv"
run "lspci -vvv"
run "dmesg -T"
run "journalctl -k -b"
run "journalctl -p warning..alert -b"

run "ip a"
run "ip route"
for i in $(ls /sys/class/net | grep -v lo); do
  run "ethtool $i"
  run "ethtool -i $i"
  run "ethtool -S $i"
done

run "ipmitool mc info"
run "ipmitool chassis status"
run "ipmitool fru print"
run "ipmitool sensor"
run "ipmitool sdr elist"
run "ipmitool sel elist"

command -v nvidia-smi >/dev/null 2>&1 && run "nvidia-smi -q"
command -v nvidia-smi >/dev/null 2>&1 && run "nvidia-smi topo -m"
command -v npu-smi >/dev/null 2>&1 && run "npu-smi info"
command -v ascend-dmi >/dev/null 2>&1 && run "ascend-dmi -i"
command -v ras-mc-ctl >/dev/null 2>&1 && run "ras-mc-ctl --summary"
command -v ras-mc-ctl >/dev/null 2>&1 && run "ras-mc-ctl --errors"

cd /var/log
tar czf sit_issue_collect_$TS.tar.gz sit_issue_collect_$TS

echo "Collected: /var/log/sit_issue_collect_$TS.tar.gz"
```

## 15.3 失败后禁止做什么

在未收集日志前，尽量不要：

- 直接重启
- 清 SEL
- 重新插拔设备
- 覆盖测试日志
- 重新刷版本
- 删除 `/var/log`
- 继续跑破坏性测试

---

# 16. 常见故障排障路径

## 16.1 无法开机 / 无法 POST

优先收集：

```bash
BMC Web 截图
ipmitool sel elist
ipmitool sensor
ipmitool chassis status
BMC debug log
主板 7-seg code / LED code
```

排查方向：

1. AC 是否输入  
2. PSU 是否正常  
3. BMC 是否启动  
4. power button / power command 是否有效  
5. CPU/DIMM 是否安装正确  
6. BIOS 是否损坏  
7. CPLD 上电时序  
8. 主板短路/过流保护  
9. 外设导致卡 POST

## 16.2 OS 安装失败

排查：

1. BIOS Boot mode  
2. Secure Boot  
3. RAID/HBA/NVMe 驱动  
4. 安装介质  
5. 网络 PXE  
6. 磁盘是否识别  
7. dmesg 是否 I/O error  
8. ISO 与平台兼容性

## 16.3 压力下重启

排查：

1. `last -x` 看 reboot 时间  
2. BMC SEL 是否 power/thermal/watchdog  
3. journalctl 上一次启动是否 panic  
4. CPU/GPU/NPU 温度  
5. PSU 功耗和冗余  
6. MCE/ECC/AER  
7. 压力组合是否超过设计  
8. 降低单项负载对比

## 16.4 掉盘

排查：

1. `lsblk` / `nvme list` 是否少盘  
2. dmesg 是否 `nvme reset` / `I/O error`  
3. SMART 是否异常  
4. 盘温度是否过高  
5. 是否固定槽位  
6. 换盘/换槽/换背板/换线  
7. PCIe AER  
8. SSD FW 版本  
9. HBA/RAID FW 和驱动

## 16.5 网卡 link down / 带宽低

排查：

1. `ethtool` Speed/Link  
2. `ethtool -S` error/drop/CRC  
3. 光模块/线缆/交换机端口  
4. NIC FW/Driver  
5. PCIe 链路是否降级  
6. MTU、RSS、队列数  
7. NUMA 亲和性  
8. RoCE PFC/ECN 配置  
9. iperf 流数是否足够

## 16.6 GPU/NPU 掉卡

排查：

1. `lspci` 是否还在  
2. `nvidia-smi/npu-smi` 是否可见  
3. dmesg 是否 Xid/AER/reset  
4. BMC SEL 是否 thermal/power  
5. PCIe LnkSta 是否降速降宽  
6. 掉卡是否固定 slot/card  
7. 单卡压力 vs 多卡压力  
8. 降功耗/风扇全速复测  
9. FW/Driver/BIOS 版本组合  
10. Riser/Retimer/Switch/线缆交叉验证

## 16.7 ECC 错误

排查：

1. CE 还是 UE  
2. 是否固定 DIMM  
3. 是否压力下增长  
4. DIMM 交换槽位  
5. 检查插法和频率  
6. BIOS memory training  
7. CPU memory controller  
8. 温度和电压  
9. 批次问题

---

# 17. 不同平台如何设计用例

## 17.1 通用 x86 双路服务器

重点：

- CPU socket 识别
- DDR 插法和频率
- NUMA
- PCIe slot
- NVMe/RAID
- NIC
- BMC/IPMI/Redfish
- AC/DC/Reboot cycle
- CPU/Memory/Storage/Network 混合压力

P0 用例：

```text
开机 → OS 安装 → 设备识别 → BIOS/BMC 版本 → BMC sensor → CPU/Memory 压力 → Storage fio → Network iperf → Reboot/Power cycle
```

## 17.2 ARM / 鲲鹏 / Ampere 类服务器

重点差异：

- 架构是 `aarch64`
- 部分工具包和驱动与 x86 不同
- BIOS/UEFI/ACPI/NUMA 表可能不同
- 某些 PCIe 设备驱动兼容性需额外验证
- OS 发行版支持矩阵更关键

用例增加：

```text
OS 兼容性矩阵
Kernel/Driver 兼容
PCIe 设备枚举
性能基线与 x86 不直接横向比较
容器镜像架构兼容
```

## 17.3 NVIDIA GPU AI 服务器

重点：

- GPU 数量和拓扑
- NVIDIA Driver / CUDA / Fabric Manager / DCGM
- NVLink/NVSwitch
- PCIe 链路
- GPU Xid
- ECC
- NCCL 通信
- GPU + NIC + Storage 联合压力
- 散热和功耗

P0 用例：

```text
nvidia-smi -L
nvidia-smi topo -m
PCIe LnkSta
单卡压力
全卡压力
NCCL all_reduce
GPU + RoCE/IB
GPU + NVMe
72h burn-in
```

## 17.4 Ascend NPU AI 服务器

重点：

- `npu-smi info` 设备状态
- `ascend-dmi` 压力
- CANN / Driver / Firmware / Toolkit 版本
- HCCL 通信
- NPU 健康状态
- AICore 利用率
- HBM
- PCIe / HCCS / RoCE
- `/var/log/ascend-dmi/` 日志

P0 用例：

```text
npu-smi info
ascend-dmi -i
单 NPU 压力
全 NPU 压力
HCCL 通信
NPU + Network
NPU + Storage
长稳 burn-in
掉卡恢复
```

## 17.5 存储密集型服务器

重点：

- NVMe 数量多
- 背板/线缆/Retimer
- HBA/RAID FW
- 热插拔
- fio 多盘并发
- 温度
- 掉盘和 reset

用例设计：

```text
全盘识别
全盘 SMART
单盘 fio
全盘并发 fio
热插拔
长时间 randrw
高温 fio
RAID rebuild
掉电恢复
```

## 17.6 网络密集型服务器

重点：

- 多 100G/200G/400G/800G NIC
- 光模块
- DAC/AOC
- PCIe 带宽
- RoCE/IB
- PFC/ECN
- NUMA 亲和性
- CPU 中断绑定

用例设计：

```text
端口识别
链路速率
光模块信息
iperf3 TCP/UDP
RDMA bandwidth/latency
多口同时打流
长时间 error counter 监控
NUMA 亲和性性能对比
```

## 17.7 整柜 / 液冷 AI 服务器

重点：

- 整柜供电
- CDU / 液冷
- 漏液检测
- 冷板温度
- 节点间网络
- 整柜风扇/泵/阀
- 机柜级 Redfish/管理
- 集群级训练压力

用例设计：

```text
节点基础识别
整柜 power on sequence
CDU 状态
漏液传感器
全节点 GPU/NPU 压力
跨节点 NCCL/HCCL
整柜功耗曲线
冷却能力验证
节点故障隔离
整柜 72h burn-in
```

---

# 18. 报告模板

## 18.1 测试报告结构

```text
1. 项目名称
2. 平台配置
3. 版本矩阵
4. 测试范围
5. 测试环境
6. 测试用例统计
7. Pass/Fail/Block 概况
8. Critical/Major Bug 列表
9. 性能结果
10. 稳定性结果
11. 风险评估
12. Release 建议
13. 附件日志
```

## 18.2 Bug 报告模板

```text
Bug 标题：
严重等级：Critical/Major/Minor
发现阶段：EVT/DVT/PVT/SIT/客户现场
平台配置：
版本信息：BIOS/BMC/CPLD/Driver/FW/OS/Kernel
测试工具与命令：
复现步骤：
实际结果：
预期结果：
复现概率：
影响范围：
日志证据：
初步分析：
怀疑方向：BIOS/BMC/HW/FW/Driver/OS/Thermal/Power
临时规避：
回归要求：
附件：
```

## 18.3 RCA 模板

```text
1. 问题描述
2. 影响范围
3. 时间线
4. 测试环境
5. 复现步骤
6. 日志证据
7. 根因分析
8. 修复方案
9. 验证结果
10. 防再发措施
11. 补充用例
```

---

# 19. 高级 SIT 工程师检查清单

## 19.1 发现问题后第一反应

不要只说“失败了”，要立刻补齐：

```text
什么时候失败？
跑了什么命令？
跑了多久？
哪个设备失败？
失败前有什么告警？
OS 还活着吗？
BMC 还能访问吗？
lspci 还能看到设备吗？
BMC SEL 有什么？
dmesg 有什么？
是否可复现？
是否固定槽位/固定设备/固定版本？
```

## 19.2 判断问题归属

| 现象 | 优先方向 |
|---|---|
| OS 看不到设备，BMC 有 power/thermal | Power/Thermal/HW |
| OS 看不到设备，dmesg AER surprise down | PCIe/HW/FW |
| lspci 可见，工具不可见 | Driver/FW/Runtime |
| 压力下温度高后失败 | Thermal/Fan/Power |
| 换槽问题跟槽走 | Slot/Riser/Backplane/Board |
| 换卡问题跟卡走 | Device 本体/FW |
| 换版本后消失 | BIOS/BMC/Driver/FW |
| 只有高负载复现 | Power/Thermal/Signal/Driver race |
| 只有长时间复现 | 稳定性/泄漏/累积错误/温度漂移 |

---

# 20. 后续优化方向

本 v0.1 后续建议补充以下专章：

1. NVIDIA GPU：DCGM、NCCL、NVLink/NVSwitch、Xid 表详解  
2. Ascend NPU：npu-smi、ascend-dmi、CANN、HCCL、日志路径详解  
3. Mellanox：mlxlink、mlxconfig、ib_write_bw、RoCE PFC/ECN  
4. Broadcom/Intel NIC：FW、driver、ethtool counter 详解  
5. NVMe 企业盘：SMART 字段、sanitize、format、namespace、掉盘 RCA  
6. RAID/HBA：storcli/perccli/arcconf 用法  
7. BMC：Redfish API 全用例、SEL 事件码、Sensor 阈值  
8. BIOS：常见选项对 PCIe/GPU/NIC/NUMA 的影响  
9. 液冷整柜：CDU、漏液、冷板、泵、阀、整柜功耗  
10. 自动化平台：Python 采集、日志解析、报告生成、Jenkins/Lab 管理

---

# 21. 一句话总结

服务器 SIT 的测试工具很多，但高级工程师真正要掌握的是：

```text
测试目的 → 工具参数 → 运行过程 → 日志证据 → 关键字段 → 问题归属 → 回归闭环
```

只会跑命令，是普通测试工程师；能把命令背后的系统风险、日志证据和问题闭环讲清楚，才是高级 SIT 工程师。

