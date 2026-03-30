


**前言**

大家好，我是JACK，服务器硬件测试工程师。百日学习计划Day2，今天深入学习服务器架构核心知识：NUMA架构、PCIe链路、网卡调试、CPU亲和性，以及Python读取系统信息实战。

---

**一、NUMA架构（服务器核心概念）**

**NUMA是什么**

NUMA（Non-Uniform Memory Access，非统一内存访问），核心概念：**不同CPU访问不同内存的速度不一样**。

```
CPU0 ── 本地内存
│
└─ 访问很快

CPU1 ── 本地内存
│
└─ 访问很快

CPU0 访问 CPU1 内存
│
└─ 访问较慢
```

CPU和内存是绑定的，这就叫**内存节点**。

**查看NUMA信息：**

```bash
[root@bogon ~]# lscpu | grep NUMA
NUMA 节点：       4
NUMA 节点0 CPU：  0-63
NUMA 节点1 CPU：  64-127
NUMA 节点2 CPU：  128-191
NUMA 节点3 CPU：  192-255
[root@bogon ~]#
```

**NUMA拓扑关系：**

```
CPU0 → node0  node1
CPU1 → node2  node3

CPU0
├── NUMA0
└── NUMA1

CPU1
├── NUMA2
└── NUMA3
```

**查看NUMA详细信息 — numactl --hardware：**

```bash
[root@bogon ~]# numactl --hardware
available: 4 nodes (0-3)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63
node 0 size: 515958 MB
node 0 free: 513966 MB
node 1 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127
node 1 size: 515401 MB
node 1 free: 514252 MB
node 2 cpus: 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191
node 2 size: 515011 MB
node 2 free: 513672 MB
node 3 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255
node 3 size: 516086 MB
node 3 free: 514845 MB
node distances:
node   0    1    2    3
  0:  10   12   35   37
  1:  12   10   37   40
  2:  35   37   10   12
  3:  37   40   12   10
[root@bogon ~]#
```

> 💡 **node distances解读**：同NUMA节点内距离=10（最快）；同一颗CPU的不同节点距离=12（较快）；跨CPU访问距离=35~40（明显变慢）。**256核、四个内存节点。**

---

**二、CPU与内存拓扑**

```bash
[root@bogon ~]# lscpu
架构：             aarch64
CPU 运行模式：     64-bit
字节序：           Little Endian
CPU:               256
在线 CPU 列表：    0-255
厂商 ID：          HiSilicon
BIOS Vendor ID:    HiSilicon
BIOS Model name:   Kunpeng 920 7260Z
型号：             0
每个核的线程数：   2
每个座的核数：     64
座：               2
步进：             0x0
Frequency boost:   disabled
CPU 最大 MHz：     2600.0000
CPU 最小 MHz：     400.0000
BogoMIPS：         200.00
标记：             fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp
                   cpuid asimdrdm jscvt fcma lrcpc dcpop sha3 sm3 sm4 asimddp sha512
                   sve asimdfhm dit uscat ilrcpc flagm ssbs sb dcpodp flagm2 frint
                   svei8mm svef32mm svef64mm svebf16 i8mm bf16 dgh rng ecv
Caches (sum of all):
  L1d:             8 MiB (128 instances)
  L1i:             8 MiB (128 instances)
  L2:              160 MiB (128 instances)
  L3:              224 MiB (4 instances)
NUMA:
NUMA 节点：        4
NUMA 节点0 CPU：   0-63
NUMA 节点1 CPU：   64-127
NUMA 节点2 CPU：   128-191
NUMA 节点3 CPU：   192-255
Vulnerabilities:
Gather data sampling:    Not affected
Itlb multihit:           Not affected
L1tf:                    Not affected
Mds:                     Not affected
Meltdown:                Not affected
Mmio stale data:         Not affected
Retbleed:                Not affected
Spec rstack overflow:    Not affected
Spec store bypass:       Mitigation; Speculative Store Bypass disabled via prctl
Spectre v1:              Mitigation; __user pointer sanitization
Spectre v2:              Not affected
Srbds:                   Not affected
Tsx async abort:         Not affected
[root@bogon ~]#
```

> 💡 **Vulnerabilities全部Not affected**：鲲鹏920是ARM架构，对Spectre/Meltdown等x86常见漏洞天然免疫，这是ARM架构的安全优势。

---

**三、PCIe链路速度**

**先过滤查看Lnk关键信息：**

```bash
[root@bogon ~]# lspci -vv -s 81:00.0 | grep Lnk
LnkCap:  Port #0, Speed 16GT/s, Width x4, ASPM not supported
LnkCtl:  ASPM Disabled; RCB 128 bytes, Disabled- CommClk-
LnkSta:  Speed 16GT/s, Width x4
LnkCap2: Supported Link Speeds: 2.5-16GT/s, Crosslink- Retimer+ 2Retimers+ DRS-
LnkCtl2: Target Link Speed: 16GT/s, EnterCompliance- SpeedDis-
LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete+ EqualizationPhase1+
LnkCtl3: LnkEquIntrruptEn- PerformEqu-
[root@bogon ~]#
```

**确认NVMe设备：**

```bash
[root@bogon ~]# lspci -vv | grep -i 1515
81:00.0 Non-Volatile memory controller: DERA Storage Device 1515 (prog-if 02 [NVM Express])
82:00.0 Non-Volatile memory controller: DERA Storage Device 1515 (prog-if 02 [NVM Express])
```

**查看完整PCIe设备详情：**

```bash
[root@bogon ~]# lspci -vv -s 81:00.0
81:00.0 Non-Volatile memory controller: DERA Storage Device 1515 (prog-if 02 [NVM Express])
        Subsystem: DERA Storage Device 7105
        Physical Slot: 67
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 28
        NUMA node: 3   ##NVMe挂在NUMA node3、如果程序跑在CPU 0-63访问nvme就会跨NUMA性能就会下降
        Region 0: Memory at a0320000 (64-bit, non-prefetchable) [size=32K]
        Expansion ROM at a0300000 [disabled] [size=128K]
        Capabilities: [80] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [90] MSI: Enable- Count=1/1 Maskable+ 64bit+
                Address: 0000000000000000  Data: 0000
                Masking: 00000000  Pending: 00000000
        Capabilities: [b0] MSI-X: Enable+ Count=257 Masked-
                Vector table: BAR=0 offset=00004000
                PBA: BAR=0 offset=00006000
        Capabilities: [c0] Express (v2) Endpoint, MSI 00
                DevCap: MaxPayload 512 bytes, PhantFunc 0, Latency L0s <1us, L1 <1us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset+ SlotPowerLimit 0W
                DevCtl: CorrErr+ NonFatalErr+ FatalErr+ UnsupReq+
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+ FLReset-
                        MaxPayload 256 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr- NonFatalErr- FatalErr- UnsupReq- AuxPwr- TransPend-
                LnkCap: Port #0, Speed 16GT/s, Width x4, ASPM not supported
                        ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp+
                LnkCtl: ASPM Disabled; RCB 128 bytes, Disabled- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 16GT/s, Width x4   ###cap和sta数据一致、带宽没有变低、延迟没有变高
                        TrErr- Train- SlotClk- DLActive- BWMgmt- ABWMgmt-
                DevCap2: Completion Timeout: Range B, TimeoutDis+ NROPrPrP- LTR+
                        10BitTagComp+ 10BitTagReq- OBFF Via message, ExtFmt+ EETLPPrefix+, MaxEETLPPrefixes 2
                        EmergencyPowerReduction Not Supported, EmergencyPowerReductionInit-
                        FRS- TPHComp+ ExtTPHComp+
                        AtomicOpsCap: 32bit- 64bit- 128bitCAS-
                DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis- LTR- 10BitTagReq- OBFF Disabled,
                        AtomicOpsCtl: ReqEn-
                LnkCap2: Supported Link Speeds: 2.5-16GT/s, Crosslink- Retimer+ 2Retimers+ DRS-
                LnkCtl2: Target Link Speed: 16GT/s, EnterCompliance- SpeedDis-
                        Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
                        Compliance Preset/De-emphasis: -6dB de-emphasis, 0dB preshoot
                LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete+ EqualizationPhase1+
                        EqualizationPhase2+ EqualizationPhase3+ LinkEqualizationRequest-
                        Retimer- 2Retimers- CrosslinkRes: unsupported
        Capabilities: [100 v2] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC+ UnsupReq+ ACSViol-
                UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvNonFatalErr-
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvNonFatalErr+
                AERCap: First Error Pointer: 00, ECRCGenCap+ ECRCGenEn- ECRCChkCap+ ECRCChkEn-
                        MultHdrRecCap- MultHdrRecEn- TLPPfxPres- HdrLogCap-
                HeaderLog: 00000000 00000000 00000000 00000000
        Capabilities: [150 v1] Device Serial Number 9c-bd-6e-56-70-01-28-cf
        Capabilities: [160 v1] Power Budgeting <?>
        Capabilities: [300 v1] Secondary PCI Express
                LnkCtl3: LnkEquIntrruptEn- PerformEqu-
                LaneErrStat: 0
        Capabilities: [400 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
        Capabilities: [910 v1] Data Link Feature <?>
        Capabilities: [920 v1] Lane Margining at the Receiver <?>
        Capabilities: [9c0 v1] Physical Layer 16.0 GT/s <?>
        Kernel driver in use: nvme
        Kernel modules: nvme
[root@bogon ~]#
```

**关键字段解读：**

| 字段 | 含义 |
|------|------|
| LnkCap | 链路能力（硬件支持的最大值） |
| LnkSta | 链路状态（实际运行值） |
| Speed 16GT/s | PCIe Gen4速率 |
| Width x4 | 4条PCIe通道 |
| NUMA node: 3 | 该设备挂在NUMA3节点 |
| Kernel driver in use: nvme | 驱动已正常加载 |

> 💡 **LnkCap和LnkSta数据一致，说明带宽没有降低、延迟没有变高，链路完全正常。**

**PCIe带宽计算：**

| 规格 | 单通道带宽 | x4带宽 |
|------|-----------|--------|
| PCIe Gen3 | 1GB/s | 4GB/s |
| PCIe Gen4 | 2GB/s | 8GB/s |
| PCIe Gen5 | 4GB/s | 16GB/s |

**跨NUMA访问NVMe的性能影响：**

```
# 未优化（CPU0访问NUMA3的NVMe）
CPU0
│
Interconnect（4-5GB/s）
│
CPU1
│
PCIe
│
NVMe
多了一段CPU ↔ CPU 互联（4-5GB/s），延迟增加20%~50%

# 优化后（NUMA绑定）
numactl --cpunodebind=3 后：CPU → PCIe → NVMe（7GB/s）
numactl --cpunodebind=3 --membind=3
# 程序CPU使用node3，内存使用node3，CPU、内存、NVMe都在同一个NUMA
```

---

**四、网卡信息与调试**

**1. 查看网卡状态 — ip link**

```bash
[root@bogon ~]# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 2c:da:3f:15:b5:0a brd ff:ff:ff:ff:ff:ff
3: eno2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN mode DEFAULT group default qlen 1000
    link/ether 2c:da:3f:15:b5:0b brd ff:ff:ff:ff:ff:ff
4: eno3: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN mode DEFAULT group default qlen 1000
    link/ether 2c:da:3f:15:b5:0c brd ff:ff:ff:ff:ff:ff
5: eno4: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN mode DEFAULT group default qlen 1000
    link/ether 2c:da:3f:15:b5:0d brd ff:ff:ff:ff:ff:ff
[root@bogon ~]#
```

> 💡 **一张网卡、四个网口，只有eno1处于UP状态在用，其余三个DOWN未在用。ethtool eno1的速率为1000Mb/s，是1G的电口，灵活网卡。**

**2. 查看网卡速率 — ethtool**

```bash
[root@bogon ~]# ethtool eno1
Settings for eno1:
    Supported ports: [ MII ]
    Supported link modes: 10baseT/Half 10baseT/Full
                          100baseT/Half 100baseT/Full
                          1000baseT/Full
    Supported pause frame use: Symmetric Receive-only
    Supports auto-negotiation: Yes
    Supported FEC modes: Not reported
    Advertised link modes: 10baseT/Half 10baseT/Full
                           100baseT/Half 100baseT/Full
                           1000baseT/Full
    Advertised pause frame use: Symmetric
    Advertised auto-negotiation: Yes
    Advertised FEC modes: Not reported
    Link partner advertised link modes: 10baseT/Half 10baseT/Full
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
[root@bogon ~]#
```

---

**五、PCIe设备与NUMA关系**

通过sysfs可以直接查看任何PCIe设备属于哪个NUMA节点：

```bash
# 查看NVMe属于哪个NUMA
cat /sys/bus/pci/devices/0000:81:00.0/numa_node
3
# 返回3，说明这块NVMe属于NUMA3

# 查看网卡属于哪个NUMA
cat /sys/bus/pci/devices/0000:35:00.0/numa_node
```

---

**六、CPU中断（IRQ）与网卡性能**

**网络中断在哪个CPU处理？**

如果网卡在NUMA2，但中断跑在CPU0（NUMA0），数据处理就会跨NUMA，性能会下降。

```bash
# 查看所有中断分布（eth0-TxRx-0）
cat /proc/interrupts

# 只查看eno1的中断分布
cat /proc/interrupts | grep eno1
120:  1000  0  0  0  ...  eno1-TxRx-0
# 说明eno1的中断跑在CPU0处理
```

**高性能服务器会做IRQ Affinity（中断亲和性）：让网卡NUMA = CPU NUMA，网络性能最好。**

---

> 🔥 **以下为进阶部分：AI服务器/高性能服务器调优必学**

---

**七、PCIe拓扑分析**

服务器的PCIe结构：

```
CPU
│
Root Port
│
PCIe Switch
│
多个设备（共享带宽）
```

所以服务器会出现多个设备共享带宽，通过lspci -tv可以看到：

```
-+-[0000:80]-
 |--81:00.0 NVMe
 |--82:00.0 NVMe
 |--83:00.0 RAID
```

这三个设备在同一个Root Port下，**共享PCIe带宽**。

**带宽竞争分析：**

- 4块NVMe都挂在PCIe x16，理论带宽32GB/s
- 4块NVMe总需求：4 × 8 = 32GB/s，刚好跑满
- 再挂一个设备就会带宽竞争，性能下降

**AI服务器瓶颈分析（8个NPU + 2块NVMe）：**

- 8个NPU，每个需要2GB/s，总需求16GB/s
- 2块NVMe，每块7GB/s，总带宽14GB/s
- **14GB/s < 16GB/s，存储带宽不足是瓶颈**

**重要区分：**

- NVMe NUMA不一致 ≠ NVMe总带宽不够
- NUMA不一致主要影响**访问延迟和跨CPU带宽**
- NVMe → CPU3 → CPU2 → NPU，多了一段CPU-CPU interconnect
- NUMA不一致会导致带宽下降和延迟增加
- 但本例中是NVMe总带宽小于NPU需求带宽，**存储带宽不足是根本瓶颈，而不是NUMA不一致**

---

**八、CPU亲和性（CPU Affinity）**

服务器程序通常会指定CPU核心运行，原因是**避免CPU迁移**：
- 程序在CPU间跳来跳去，缓存失效
- 跨NUMA节点，内存访问延迟增加

**1. 查看进程CPU绑定 — taskset**

```bash
# 查看当前进程可以跑在哪些CPU
taskset -p $$
# 输出：pid XXX's current affinity mask: ffffffff（说明进程能跑在所有CPU）

# 指定CPU核心运行程序（绑定到NUMA3，CPU 192-200）
taskset -c 192-200 stress-ng --cpu 4
# 程序只能跑在NUMA3，CPU-内存-NVMe同一个NUMA，性能高
```

**2. NUMA绑定运行程序 — numactl**

```bash
numactl --cpunodebind=3 --membind=3 stress-ng --cpu 4 --timeout 20
# CPU使用NUMA3、内存也使用NUMA3
```

运行后用**top查看CPU使用情况**，确认进程确实绑定在目标CPU核心上。

**3. 真实案例：AI推理性能优化**

```
场景：AI服务器GPU在NUMA1，程序未绑定NUMA
结果：推理延迟25ms

优化：numactl --cpunodebind=1 绑定到NUMA1
结果：推理延迟18ms，性能提升30%
```

**4. 挑战题分析**

```
条件：
- 8张NPU，NPU在NUMA2
- 2块NVMe，NVMe在NUMA3
- 1张RDMA NIC
- AI程序数据流：NVMe → CPU → NPU

问题：程序应该绑定在哪个NUMA？
```

**答案：绑定NUMA2（计算设备优先原则）**

在AI/HPC/GPU/NPU场景，通常优先考虑：**计算设备优先，CPU NUMA ≈ 加速卡NUMA**。

**绑定NUMA2的数据路径：**

```
CPU(NUMA2)
│
PCIe
│
NPU
```

**如果错误绑定NUMA3的数据路径：**

```
CPU(NUMA3)
│
PCIe
│
NVMe
│
CPU interconnect
│
CPU(NUMA2)
│
PCIe
│
NPU
跨两次NUMA，性能更差！
```

**真实数据流程：**

```
NVMe
│
CPU
│
内存
│
NPU
```

这是关键阶段。**推理时间远大于数据加载时间**，所以优先保证CPU-NPU本地NUMA。

```bash
# 正确做法：NPU在NUMA2，绑定NUMA2
numactl --cpunodebind=2 --membind=2 [AI程序]
```

NVMe数据读取：NVMe(NUMA3) → CPU(NUMA2)，虽然跨NUMA但只有一次，而且计算阶段完全没有跨NUMA。

**诊断分析：**

NPU在NUMA2，推理程序应该跑在NUMA2，NPU挂在NUMA2的PCIe Root Port，程序跑在NUMA2：

```
CPU(NUMA2)
│
PCIe Root Port
│
NPU
→ 延迟最低，带宽最大
```

如果跑在其他NUMA：

```
CPU0
│
CPU interconnect
│
CPU1
│
PCIe
│
NPU
→ 多了一段CPU↔CPU互联，延迟增加，带宽下降
```

---

**九、Python实战：读取系统信息**

Python在服务器测试中用途：**自动化测试、日志分析、系统监控、批量操作服务器**。

今天学Python + Linux系统信息读取。

**1. 读取CPU信息**

```python
# 创建文件：vim cpu_info.py
with open("/proc/cpuinfo") as f:
    cpuinfo = f.read()

cpu_count = cpuinfo.count("processor")
print("cpu cores:", cpu_count)
```

```bash
# 运行
python3 cpu_info.py
CPU cores: 256
```

**2. 读取内存信息**

```python
# 创建文件：vim mem_info.py
with open("/proc/meminfo") as f:
    for line in f:
        if "MemTotal" in line:
            print(line)
```

```bash
# 运行
python3 mem_info.py
MemTotal:       2111956928 kB
```

**3. 调用Linux命令**

```python
# 创建文件：vim disk_info.py
import subprocess

result = subprocess.run(["lsblk"], capture_output=True, text=True)
print(result.stdout)
```

**4. 检测NVMe数量**

```python
import subprocess

result = subprocess.run(["nvme", "list"], capture_output=True, text=True)
count = result.stdout.count("/dev/nvme")
print("NVMe devices:", count)
```

---

**Day2总结**

今天学习了服务器架构核心知识：

- **NUMA架构**：CPU和内存绑定，跨NUMA访问延迟增加，numactl --hardware查看完整拓扑
- **PCIe链路**：lspci -vv查看链路详情，LnkCap=LnkSta说明链路正常，NUMA node确认设备归属
- **NUMA与PCIe设备**：sysfs查看设备所属NUMA节点
- **网卡调试**：ip link查看状态，ethtool查看速率
- **中断亲和性**：/proc/interrupts查看中断分布，IRQ affinity提升网络性能
- **PCIe带宽分析**：多设备共享Root Port带宽，存储带宽不足与NUMA不一致是两个不同问题
- **CPU亲和性**：taskset绑定CPU核心，numactl绑定NUMA节点，top验证效果
- **Python读取系统信息**：/proc/cpuinfo、/proc/meminfo、subprocess调用命令

**核心收获：AI/NPU场景优先让CPU NUMA对齐计算设备（GPU/NPU）的NUMA，推理性能可提升30%！**

明天继续！如果这篇文章对你有帮助，欢迎**点赞、收藏、关注**，百日学习计划持续更新，不迷路！

欢迎关注**JACK的服务器笔记**！

---

