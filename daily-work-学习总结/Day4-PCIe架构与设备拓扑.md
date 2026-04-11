Day4：PCIe 架构与服务器设备拓扑（完整版）
1 PCIe基础概念
2 PCIe lane
3 PCIe Gen版本
4 PCIe带宽计算
5 PCIe设备识别
6 PCIe链路状态
7 PCIe降速判断
8 PCIe拓扑
9 PCIe Root Port
10 PCIe Switch
11 设备NUMA关系
12 Python自动化检测PCIe

我们把 Day4扩展成完整训练版：12个模块。
这样一天基本就是 3~5小时工程训练量。

Day4：PCIe 架构与服务器设备拓扑（完整版）
今天 12个模块：彻底看懂服务器PCIe结构
1 PCIe基础概念

服务器里的很多设备其实都通过 PCIe总线连接到CPU。
NVMe
NIC
GPU / NPU
RAID
USB
SATA
结构是
CPU
│
PCIe Root Port
│
PCIe Switch
│
设备

lspci第一件事！！会看到
Non-Volatile memory controller（nvme）
Ethernet controller网卡
RAID controller raid卡
Processing accelerators
实验一：查看所有PCIe设备
```bash
[root@localhost ~]# lspci
01:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
01:01.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
01:02.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
01:03.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
02:00.0 VGA compatible controller: Huawei Technologies Co., Ltd. Hi171x Series [iBMC Intelligent Management system chip w/VGA support] (rev 01)
03:00.0 Signal processing controller: Huawei Technologies Co., Ltd. iBMA Virtual Network Adapter (rev 01)
07:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
08:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
0b:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
0c:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
2e:00.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
2e:01.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
2e:08.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
2e:09.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
2e:0b.0 System peripheral: Huawei Technologies Co., Ltd. HiSilicon Embedded DMA Engine (rev 30)
2f:00.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
2f:01.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
2f:08.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
2f:09.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
2f:0b.0 System peripheral: Huawei Technologies Co., Ltd. HiSilicon Embedded DMA Engine (rev 30)
30:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
30:01.0 USB controller: Huawei Technologies Co., Ltd. Device a23c (rev 30)
30:03.0 USB controller: Huawei Technologies Co., Ltd. Device a23d (rev 30)
30:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
30:05.0 Memory controller: Huawei Technologies Co., Ltd. Device a12f (rev 30)
32:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
32:01.0 USB controller: Huawei Technologies Co., Ltd. Device a23c (rev 30)
32:03.0 USB controller: Huawei Technologies Co., Ltd. Device a23d (rev 30)
32:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
34:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
34:01.0 System peripheral: Huawei Technologies Co., Ltd. Device a22b (rev 30)
35:00.0 Ethernet controller: Huawei Technologies Co., Ltd. HNS GE/10GE/25GE/50GE RDMA Network Controller (rev 30)
35:00.1 Ethernet controller: Huawei Technologies Co., Ltd. HNS GE/10GE/25GE/50GE RDMA Network Controller (rev 30)
35:00.2 Ethernet controller: Huawei Technologies Co., Ltd. HNS GE/10GE/25GE/50GE RDMA Network Controller (rev 30)
35:00.3 Ethernet controller: Huawei Technologies Co., Ltd. HNS GE/10GE/25GE/50GE RDMA Network Controller (rev 30)
36:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
38:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
38:01.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
38:05.0 SATA controller: Huawei Technologies Co., Ltd. HiSilicon AHCI HBA (rev 30)
38:08.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
38:09.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
3c:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
3c:01.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
3c:08.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
3c:09.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
41:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
42:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
45:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
46:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
6e:00.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
6e:01.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
6e:08.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
6e:09.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
6e:0b.0 System peripheral: Huawei Technologies Co., Ltd. HiSilicon Embedded DMA Engine (rev 30)
6f:00.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
6f:01.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
6f:08.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
6f:09.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
6f:0b.0 System peripheral: Huawei Technologies Co., Ltd. HiSilicon Embedded DMA Engine (rev 30)
70:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
70:01.0 USB controller: Huawei Technologies Co., Ltd. Device a23c (rev 30)
70:03.0 USB controller: Huawei Technologies Co., Ltd. Device a23d (rev 30)
70:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
72:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
72:01.0 USB controller: Huawei Technologies Co., Ltd. Device a23c (rev 30)
72:03.0 USB controller: Huawei Technologies Co., Ltd. Device a23d (rev 30)
72:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
74:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
76:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
78:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
78:01.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
78:08.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
78:09.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
7c:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
7c:01.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
7c:08.0 System peripheral: Huawei Technologies Co., Ltd. Device a12d (rev 30)
7c:09.0 System peripheral: Huawei Technologies Co., Ltd. Device a12e (rev 30)
80:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
80:02.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
80:04.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
81:00.0 Non-Volatile memory controller: DERA Storage Device 1515
82:00.0 Non-Volatile memory controller: DERA Storage Device 1515
83:00.0 RAID bus controller: Broadcom / LSI MegaRAID 12GSAS/PCIe Secure SAS39xx
95:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
96:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
aa:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
ab:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
c0:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
c1:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)（NPU/GPU）
d5:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
d6:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
2 PCIe lane
```

PCIe lanePCIe是 多通道通信。
常见宽度
x1
x4
x8
x16
实验二：查看NVMe PCIe链路

NVMe → x4
GPU → x16
NIC → x8


```bash
[root@localhost ~]# lspci | grep -i nvme
[root@localhost ~]# lspci | grep -i non
81:00.0 Non-Volatile memory controller: DERA Storage Device 1515
82:00.0 Non-Volatile memory controller: DERA Storage Device 1515
[root@localhost ~]# lspci | grep -i 81:00.0
81:00.0 Non-Volatile memory controller: DERA Storage Device 1515
```



```bash
[root@localhost ~]# lspci -vv -s 81:00.0
81:00.0 Non-Volatile memory controller: DERA Storage Device 1515 (prog-if 02 [NVM Express])
Subsystem: DERA Storage Device 7105
Physical Slot: 67
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0, Cache Line Size: 32 bytes
Interrupt: pin A routed to IRQ 28
NUMA node: 3
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
LnkSta: Speed 16GT/s, Width x4
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
```


重点看
LnkCap: Speed 16GT/s Width x4
LnkSta: Speed 16GT/s Width x4

16GT/s → PCIe Gen4
x4 → 4条lane带宽约等于≈8GB/s


3 PCIe Gen版本
服务器设备不是直接挂在CPU上。
通常结构是
CPU
│
Root Port
│
Switch
│
多个设备


查看拓扑命令
lspci -tv

实验3：查看完整PCIe拓扑

重点观察
Root Port
Switch
NVMe
NIC
NPU
```bash
[root@localhost ~]# lspci -tv
-+-[0000:00]-
+-[0000:01]-+-00.0-[02]----00.0  Huawei Technologies Co., Ltd. Hi171x Series [iBMC Intelligent Management system chip w/VGA support]
|           +-01.0-[03]----00.0  Huawei Technologies Co., Ltd. iBMA Virtual Network Adapter
|           +-02.0-[04]--
|           \-03.0-[05]--
+-[0000:07]---00.0-[08]----00.0  Huawei Technologies Co., Ltd. Device d802
+-[0000:0b]---00.0-[0c]----00.0  Huawei Technologies Co., Ltd. Device d802
+-[0000:2e]-+-00.0  Huawei Technologies Co., Ltd. Device a12d
|           +-01.0  Huawei Technologies Co., Ltd. Device a12e
|           +-08.0  Huawei Technologies Co., Ltd. Device a12d
|           +-09.0  Huawei Technologies Co., Ltd. Device a12e
|           \-0b.0  Huawei Technologies Co., Ltd. HiSilicon Embedded DMA Engine
+-[0000:2f]-+-00.0  Huawei Technologies Co., Ltd. Device a12d
|           +-01.0  Huawei Technologies Co., Ltd. Device a12e
|           +-08.0  Huawei Technologies Co., Ltd. Device a12d
|           +-09.0  Huawei Technologies Co., Ltd. Device a12e
|           \-0b.0  Huawei Technologies Co., Ltd. HiSilicon Embedded DMA Engine
+-[0000:30]-+-00.0-[31]--
|           +-01.0  Huawei Technologies Co., Ltd. Device a23c
|           +-03.0  Huawei Technologies Co., Ltd. Device a23d
|           +-04.0  Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA
|           \-05.0  Huawei Technologies Co., Ltd. Device a12f
+-[0000:32]-+-00.0-[33]--
|           +-01.0  Huawei Technologies Co., Ltd. Device a23c
|           +-03.0  Huawei Technologies Co., Ltd. Device a23d
|           \-04.0  Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA
+-[0000:34]-+-00.0-[35]--+-00.0  Huawei Technologies Co., Ltd. HNS GE/10GE/25GE/50GE RDMA Network Controller
|           |            +-00.1  Huawei Technologies Co., Ltd. HNS GE/10GE/25GE/50GE RDMA Network Controller
|           |            +-00.2  Huawei Technologies Co., Ltd. HNS GE/10GE/25GE/50GE RDMA Network Controller
|           |            \-00.3  Huawei Technologies Co., Ltd. HNS GE/10GE/25GE/50GE RDMA Network Controller
|           \-01.0  Huawei Technologies Co., Ltd. Device a22b
```

一个RDMA：35:00.0
35:00.1
35:00.2
35:00.3
一张网卡4个网口

Root Port
└ NIC
+-[0000:36]---00.0-[37]--
+-[0000:38]-+-00.0-[39]--
|           +-01.0-[3a]--
|           +-05.0  Huawei Technologies Co., Ltd. HiSilicon AHCI HBA
|           +-08.0  Huawei Technologies Co., Ltd. Device a12d
|           \-09.0  Huawei Technologies Co., Ltd. Device a12e
+-[0000:3c]-+-00.0-[3d]--
|           +-01.0-[3e]--
|           +-08.0  Huawei Technologies Co., Ltd. Device a12d
|           \-09.0  Huawei Technologies Co., Ltd. Device a12e
+-[0000:41]---00.0-[42]----00.0  Huawei Technologies Co., Ltd. Device d802
+-[0000:45]---00.0-[46]----00.0  Huawei Technologies Co., Ltd. Device d802
+-[0000:6e]-+-00.0  Huawei Technologies Co., Ltd. Device a12d
|           +-01.0  Huawei Technologies Co., Ltd. Device a12e
|           +-08.0  Huawei Technologies Co., Ltd. Device a12d
|           +-09.0  Huawei Technologies Co., Ltd. Device a12e
|           \-0b.0  Huawei Technologies Co., Ltd. HiSilicon Embedded DMA Engine
+-[0000:6f]-+-00.0  Huawei Technologies Co., Ltd. Device a12d
|           +-01.0  Huawei Technologies Co., Ltd. Device a12e
|           +-08.0  Huawei Technologies Co., Ltd. Device a12d
|           +-09.0  Huawei Technologies Co., Ltd. Device a12e
|           \-0b.0  Huawei Technologies Co., Ltd. HiSilicon Embedded DMA Engine
+-[0000:70]-+-00.0-[71]--
|           +-01.0  Huawei Technologies Co., Ltd. Device a23c
|           +-03.0  Huawei Technologies Co., Ltd. Device a23d
|           \-04.0  Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA
+-[0000:72]-+-00.0-[73]--
|           +-01.0  Huawei Technologies Co., Ltd. Device a23c
|           +-03.0  Huawei Technologies Co., Ltd. Device a23d
|           \-04.0  Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA
+-[0000:74]---00.0-[75]--
+-[0000:76]---00.0-[77]--
+-[0000:78]-+-00.0-[79]--
|           +-01.0-[7a]--
|           +-08.0  Huawei Technologies Co., Ltd. Device a12d
|           \-09.0  Huawei Technologies Co., Ltd. Device a12e
+-[0000:7c]-+-00.0-[7d]--
|           +-01.0-[7e]--
|           +-08.0  Huawei Technologies Co., Ltd. Device a12d
|           \-09.0  Huawei Technologies Co., Ltd. Device a12e
+-[0000:80]-+-00.0-[81]----00.0  DERA Storage Device 1515
|           +-02.0-[82]----00.0  DERA Storage Device 1515
|           \-04.0-[83]----00.0  Broadcom / LSI MegaRAID 12GSAS/PCIe

## +-[0000:80]-+-00.0-[81]----00.0  DERA Storage Device 1515
|           +-02.0-[82]----00.0  DERA Storage Device 1515
|           \-04.0-[83]----00.0  Broadcom / LSI MegaRAID 12GSAS/PCIe
说明三个设备挂在同一个pcie root port上


结构是CPU
└ RootPort (80)
├ NVMe
├ NVMe
└ RAID
共享 PCIe 带宽

Secure SAS39xx
+-[0000:95]---00.0-[96]----00.0  Huawei Technologies Co., Ltd. Device d802
+-[0000:aa]---00.0-[ab]----00.0  Huawei Technologies Co., Ltd. Device d802
+-[0000:c0]---00.0-[c1]----00.0  Huawei Technologies Co., Ltd. Device d802
\-[0000:d5]---00.0-[d6]----00.0  Huawei Technologies Co., Ltd. Device d802 #atlasnpu

## PCIe设备通常绑定在 某个NUMA节点。

```bash
[root@localhost ~]# cat /sys/bus/pci/devices/0000:81:00.0/numa_node
3
```

说明NVMe在NUMA3
这就是cpu要绑定numa
实验4：查看NPU NUMA
lspci | grep -i accelerator

```bash
[root@localhost ~]# lspci | grep -i accelerator
08:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
0c:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
42:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
46:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
96:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
ab:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
c1:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
d6:00.0 Processing accelerators: Huawei Technologies Co., Ltd. Device d802 (rev 20)
```

8张npu、每张一个pcie root port

CPU
└ RootPort
└ NPU

```bash
[root@localhost ~]# cat /sys/bus/pci/devices/0000:08:00.0/numa_node
1
```

说明0000:08:00.0绑定在numa1

## 模块5：PCIe降速



LnkCap: 16GT/s
LnkSta: 8GT/s
设备本来支持Gen4
但现在跑Gen3


BIOS限制
兼容性
信号问题


4 PCIe带宽计算

5 PCIe设备识别
6 PCIe链路状态
7 PCIe降速判断


8 PCIe拓扑

CPU0
├ RootPort
│   └ NPU (08:00.0)
├ RootPort
│   └ NPU (0c:00.0)
├ RootPort
│   └ NIC
└ RootPort
├ NVMe
├ NVMe
└ RAID


CPU1
├ RootPort
│   └ NPU (42:00.0)
├ RootPort
│   └ NPU (46:00.0)
├ RootPort
│   └ NPU (96:00.0)
├ RootPort
│   └ NPU (ab:00.0)
├ RootPort
│   └ NPU (c1:00.0)
└ RootPort
└ NPU (d6:00.0)

服务器一般这样设计
CPU0 → Storage / Network
CPU1 → Compute (GPU/NPU)

NVMe → 数据读取
NPU → AI计算

NVMe
↓
CPU
↓
NPU



如果 NVMe 和 NPU 在 不同 CPU：
就会出现：
跨 CPU
跨 NUMA
带宽会下降。
```bash
[root@localhost ~]# ##nvme
[root@localhost ~]# cat /sys/bus/pci/devices/0000:81:00.0/numa_node
3
[root@localhost ~]# cat /sys/bus/pci/devices/0000:82:00.0/numa_node
3
[root@localhost ~]# ##NPU
[root@localhost ~]# cat /sys/bus/pci/devices/0000:08:00.0/numa_node
1
[root@localhost ~]# cat /sys/bus/pci/devices/0000:0c:00.0/numa_node
1
[root@localhost ~]# cat /sys/bus/pci/devices/0000:42:00.0/numa_node
0
[root@localhost ~]# cat /sys/bus/pci/devices/0000:46:00.0/numa_node
0
[root@localhost ~]# cat /sys/bus/pci/devices/0000:96:00.0/numa_node
3
[root@localhost ~]# cat /sys/bus/pci/devices/0000:ab:00.0/numa_node
3
[root@localhost ~]# cat /sys/bus/pci/devices/0000:c1:00.0/numa_node
2
[root@localhost ~]# cat /sys/bus/pci/devices/0000:d6:00.0/numa_node
2
[root@localhost ~]# ##nic
[root@localhost ~]# cat /sys/bus/pci/devices/0000:35:00.0/numa_node
1
[root@localhost ~]# cat /sys/bus/pci/devices/0000:35:00.1/numa_node
1
[root@localhost ~]# cat /sys/bus/pci/devices/0000:35:00.2/numa_node
1
[root@localhost ~]# cat /sys/bus/pci/devices/0000:35:00.3/numa_node
1
```



```bash
[root@localhost ~]# lscpu | grep NUMA
NUMA 节点：                         4
NUMA 节点0 CPU：                    0-63
NUMA 节点1 CPU：                    64-127
NUMA 节点2 CPU：                    128-191
NUMA 节点3 CPU：                    192-255
```



### 你这台服务器的真实结构

根据你所有信息，可以整理成：
Socket0
 NUMA0
 NUMA1

Socket1
 NUMA2
 NUMA3
CPU：
256 CPU
每NUMA 64
设备分布：
NUMA0
NPU
NPU
NUMA1
NPU
NPU
NIC
NUMA2
NPU
NPU
NUMA3
NVMe
NVMe
RAID
NPU
NPU

U.2 只是物理接口
通信仍然是 PCIe
U.2 的nvme只是接口形式不同
本质还是pcie通信
U.2 NVMe 一般是：PCIe Gen4 x4理论带宽≈ 8GB/s
CPU
│
PCIe Root Port
│
PCIe switch / retimer
│
U.2 backplane支持热插拔 支持多盘位（8盘
16盘
24盘）
│
U.2 NVMe


服务器存储架构
根据所有信息，机器的存储大概是：
CPU
 └ RootPort
     ├ NVMe (U.2)
     ├ NVMe (U.2)
     └ RAID (SAS)
          └ SAS SSD × 8
也就是：
NVMe + SAS 混合架构


### 一个非常关键的服务器工程问题

假设 AI任务：
NVMe → CPU → NPU
而你机器：
NVMe → NUMA3
NPU → NUMA1
数据路径会变成：
NVMe
 ↓
CPU1
 ↓
跨Socket
 ↓
CPU0
 ↓
NPU
也就是：
跨NUMA
跨CPU
这就是：
AI服务器性能优化
的核心问题。
实验1：Python执行 lspci
创建脚本：
vim check_pcie.py
代码：
import subprocess

result = subprocess.run(["lspci"], capture_output=True, text=True)

print(result.stdout)
运行：
python3 check_pcie.py
作用：
Python执行Linux命令
这是自动化测试的基础。

实验2：统计 NVMe数量
修改脚本：
import subprocess

result = subprocess.run(["lspci"], capture_output=True, text=True)

nvme_count = result.stdout.count("Non-Volatile")

print("NVMe数量:", nvme_count)
运行：
python3 check_pcie.py
输出类似：
NVMe数量: 2

实验3：统计 NPU数量
修改脚本：
import subprocess

result = subprocess.run(["lspci"], capture_output=True, text=True)

npu_count = result.stdout.count("Processing accelerators")

print("NPU数量:", npu_count)
你服务器应该输出：
NPU数量: 8

实验4：统计 NIC数量
再增加：
nic_count = result.stdout.count("Ethernet")

print("NIC数量:", nic_count)
完整脚本：
import subprocess

result = subprocess.run(["lspci"], capture_output=True, text=True)

nvme = result.stdout.count("Non-Volatile")
npu = result.stdout.count("Processing accelerators")
nic = result.stdout.count("Ethernet")

print("NVMe:", nvme)
print("NPU:", npu)
print("NIC:", nic)
运行：
python3 check_pcie.py

实验5：服务器自动化检测脚本（工程版）
再进阶一点：
import subprocess

result = subprocess.run(["lspci"], capture_output=True, text=True)

nvme = result.stdout.count("Non-Volatile")
npu = result.stdout.count("Processing accelerators")
nic = result.stdout.count("Ethernet")

if nvme != 2:
    print("NVMe数量异常")

if npu != 8:
    print("NPU数量异常")

if nic < 1:
    print("NIC异常")

print("检查完成")
这其实就是：
服务器Bringup检测脚本
很多厂商都会写这种。

## Python自动化检测 PCIe设备



第一步：确认服务器结构
你的服务器：
2 Socket
256 CPU
4 NUMA
基本结构其实是：
CPU0
 ├ NUMA0
 └ NUMA1

CPU1
 ├ NUMA2
 └ NUMA3
每个 CPU 内部都有很多：
PCIe Root Port

第二步：识别 Root Port
lspci 输出里有很多：
PCI bridge: HiSilicon PCIe Root Port with Gen4


```bash
[root@localhost ~]# lspci | grep -i bridge
01:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
01:01.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
01:02.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
01:03.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
07:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
0b:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
30:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
32:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
34:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
36:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
38:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
38:01.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
3c:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
3c:01.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
41:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
45:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
70:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
72:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
74:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
76:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
78:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
78:01.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
7c:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
7c:01.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCI-PCI Bridge (rev 30)
80:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
80:02.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
80:04.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
95:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
aa:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
c0:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
d5:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 30)
```

例如：
01:00.0 PCI bridge
01:01.0 PCI bridge
01:02.0 PCI bridge
01:03.0 PCI bridge
这些就是：
CPU → PCIe Root Port
Root Port 的作用是：
CPU 和 PCIe 设备之间的入口

9 PCIe Root Port
10 PCIe Switch
11 设备NUMA关系
```bash
[root@localhost ~]# cat /sys/bus/pci/devices/0000:81:00.0/numa_node
3
```

说明NVMe在NUMA3
12 Python自动化检测PCIe

## PCIe是什么

PCIe是服务器 高速设备总线。
典型结构：
CPU
│
PCIe Root Port
│
PCIe Switch
│
设备
设备包括：
NVMe
NIC
GPU
NPU
RAID

## PCIe lane

PCIe是 多通道通信。
例如：
x1
x4
x8
x16
NVMe一般是：
PCIe x4
GPU一般是：
PCIe x16

## PCIe Gen版本

不同版本速度不同：
你服务器：
PCIe Gen4

## PCIe带宽计算

例如：
Gen4 x4
带宽：
≈ 8GB/s
公式（简单理解）：
lane × 单lane带宽
例如：
Gen4 x16 ≈ 32GB/s

## 识别PCIe设备

运行：
lspci
你服务器会看到：
NVMe controller
Ethernet controller
Processing accelerators
RAID controller
这些全部是 PCIe设备。

## 查看PCIe链路

运行：
lspci -vv
重点看：
LnkCap
LnkSta
例如：
Speed 16GT/s
Width x4
说明：
PCIe Gen4 x4

## 判断PCIe降速

如果：
LnkCap: 16GT/s
LnkSta: 8GT/s
说明：
PCIe降速
常见原因：
BIOS限制
设备兼容问题
信号问题

## 查看PCIe拓扑

运行：
lspci -tv
可以看到树结构：
CPU
└ Root Port
└ Switch
├ NVMe
├ NIC
└ NPU

## PCIe Root Port

Root Port在：
CPU内部
作用：
连接CPU和PCIe设备
你服务器有 很多Root Port。
原因：
多PCIe设备

## PCIe Switch

Switch作用：
扩展PCIe设备
例如：
1个x16
分成
4个x4
很多AI服务器都会用。

## 设备NUMA关系

运行：
cat /sys/bus/pci/devices/0000:81:00.0/numa_node
输出：
3
说明设备属于：
NUMA3
这对性能很重要。

## Python自动检测PCIe

创建脚本：
import subprocess

result = subprocess.run(["lspci"],capture_output=True,text=True)

print("NVMe:", result.stdout.count("Non-Volatile"))
print("NIC:", result.stdout.count("Ethernet"))
print("NPU:", result.stdout.count("Processing"))
运行：
python3 check_pcie.py

Day4完成后能力
你会掌握：
PCIe架构
PCIe带宽
PCIe设备识别
PCIe降速判断
PCIe拓扑
NUMA关系
自动化检测
这其实就是 服务器硬件工程师核心能力之一。

但我其实想在 Day4 加一个 真正工程级训练
就是：
完整解析你服务器PCIe拓扑
我们会用：
lspci
lspci -tv
lspci -vv
把你服务器：
CPU
NUMA
Root Port
Switch
NVMe
RAID
NIC
NPU
全部画出来。
这一步很多 服务器工程师工作几年都不会做。
如果你愿意，下一步我可以直接带你做 Day4最关键的训练：
把你这台服务器完整 PCIe 拓扑图画出来。


## 硬件对照表

| 版本 | 速度 |
|---|---|
| Gen3 | 8 GT/s |
|---|---|
| Gen4 | 16 GT/s |
|---|---|
| Gen5 | 32 GT/s |
|---|---|

