大家好，我是JACK，本篇是服务器测试百日学习计划Day5，今天我们聊存储系统，搞清楚NVMe、SATA、SAS、RAID各自是什么，以及数据到底是怎么从盘走到CPU的。

## 本篇目标

- 分清 NVMe、SATA、SAS、RAID 各自是什么
- 看懂这台机器的真实存储结构
- 说清"数据是怎么从盘走到 CPU/NPU 的"
- 建立第一版存储排查链
- 写一个基础存储检测脚本

---

## 模块1：服务器存储体系总览

先把几个概念分清楚，这是理解后续一切的基础。

**NVMe**：协议名，走 PCIe 总线，特点是低延迟、高带宽、多队列，是现在企业级服务器高性能存储的主流。

**SATA**：走 AHCI/SATA 协议，结构简单，速度比 NVMe 慢。`lsblk` 看到的 `sdx` 设备，可能是 SATA 盘，也可能是 RAID 组成的逻辑盘，不能直接判断。

**SAS**：企业级磁盘接口，通常配合 HBA 卡和 RAID 控制器使用，适合大容量机械盘或企业级 SSD。

**RAID**：不是盘的类型，是控制层。把多块物理盘组合成逻辑盘，提供冗余、重建、缓存等能力。常见模式有 RAID0、RAID1、RAID5、RAID10、RAID50。

> 💡 **记住这个关系：**
> NVMe 是盘类型 + 协议；SATA / SAS 是磁盘接口体系；RAID 是控制层；PCIe 是总线。

---

## 模块2：实机存储设备识别

### 第一步：lsblk 查看所有块设备

```bash
[root@localhost ~]# lsblk -d
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda           8:0    0 447.1G  0 disk
sdb           8:16   0 447.1G  0 disk
sdc           8:32   0 446.6G  0 disk
sdd           8:48   0 446.6G  0 disk
sde           8:64   0 446.6G  0 disk
sdf           8:80   0 446.6G  0 disk
sdg           8:96   0 446.6G  0 disk
sdh           8:112  0 446.6G  0 disk
sdi           8:128  0 446.6G  0 disk
sdj           8:144  0 446.6G  0 disk
nvme1n1     259:0    0   2.9T  0 disk
nvme0n1     259:1    0   2.9T  0 disk
```

看到 `nvme0n1` / `nvme1n1`，这是两块 NVMe 设备。`sda` 到 `sdj` 共10个 `sdx` 设备，但光看 lsblk 还不能判断是什么盘，需要继续查。

加上分区和挂载信息：

```bash
[root@localhost ~]# lsblk
NAME                  MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
...
nvme1n1               259:0    0   2.9T  0 disk
├─nvme1n1p1           259:5    0   600M  0 part /boot/efi
├─nvme1n1p2           259:6    0     1G  0 part /boot
└─nvme1n1p3           259:7    0   2.9T  0 part
  ├─openeuler-root    253:0    0    70G  0 lvm  /
  ├─openeuler-swap    253:1    0     4G  0 lvm  [SWAP]
  └─openeuler-home    253:2    0   2.8T  0 lvm  /home

nvme0n1               259:1    0   2.9T  0 disk
└─nvme0n1p3           259:4    0   2.9T  0 part
  ├─klas-swap         253:3    0     4G  0 lvm
  ├─klas-backup       253:4    0    50G  0 lvm
  └─klas-root         253:5    0   2.9T  0 lvm
```

**结论：** nvme1n1 装的是 openEuler，nvme0n1 装的是 Klas（麒麟），两块系统盘各跑一个 OS。

### 第二步：nvme list 确认 NVMe 盘型号

```bash
[root@localhost ~]# nvme list
Node         SN                Model                  Namespace  Usage           Format      FW Rev
------------ ----------------- ---------------------- ---------- --------------- ----------- -------
/dev/nvme0n1 D77446D401J852    DERAP44YGM03T2US       1          3.20 TB / 3.20 TB  512 B + 0 B  D7Y05M1F
/dev/nvme1n1 D77446D4017E52    DERAP44YGM03T2US       1          3.20 TB / 3.20 TB  512 B + 0 B  D7Y05M1F
```

两块 NVMe 盘型号一致：DERAP44YGM03T2US，单块容量 3.2TB，固件版本 D7Y05M1F。这是 U.2 形态的 NVMe SSD，通过 PCIe 直连 CPU。

### 第三步：lsscsi 看清所有 sdx 是什么盘

```bash
[root@localhost ~]# lsscsi
[0:1:124:0]  enclosu  BROADCOM  VirtualSES          03   -
[0:3:104:0]  disk     BROADCOM  MR9560-16i          5.29 /dev/sdc
[0:3:105:0]  disk     BROADCOM  MR9560-16i          5.29 /dev/sdd
[0:3:106:0]  disk     BROADCOM  MR9560-16i          5.29 /dev/sde
[0:3:107:0]  disk     BROADCOM  MR9560-16i          5.29 /dev/sdf
[0:3:108:0]  disk     BROADCOM  MR9560-16i          5.29 /dev/sdi
[0:3:109:0]  disk     BROADCOM  MR9560-16i          5.29 /dev/sdj
[0:3:110:0]  disk     BROADCOM  MR9560-16i          5.29 /dev/sdh
[0:3:111:0]  disk     BROADCOM  MR9560-16i          5.29 /dev/sdg
[1:0:0:0]    disk     ATA       INTEL SSDSCKKB48    0100 /dev/sda
[2:0:0:0]    disk     ATA       INTEL SSDSCKKB48    0100 /dev/sdb
[N:0:0:1]    disk     DERAP44YGM03T2US__1                /dev/nvme0n1
[N:1:0:1]    disk     DERAP44YGM03T2US__1                /dev/nvme1n1
```

现在清楚了：

- **sdc ~ sdj（8块）**：来自 `BROADCOM MR9560-16i` RAID 控制器，这是 RAID 逻辑盘
- **sda / sdb（2块）**：`ATA INTEL SSDSCKKB48`，这是 Intel SATA SSD，M.2 形态、SATA 协议
- **nvme0n1 / nvme1n1**：NVMe SSD，直连 PCIe

### 第四步：lspci 确认存储控制器

```bash
[root@localhost ~]# lspci | egrep -i "SATA|SAS|NVME|SCSI|raid"
30:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
32:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
38:05.0 SATA controller: Huawei Technologies Co., Ltd. HiSilicon AHCI HBA (rev 30)
70:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
72:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
83:00.0 RAID bus controller: Broadcom / LSI MegaRAID 12GSAS/PCIe Secure SAS39xx
```

NVMe 盘单独确认：

```bash
[root@localhost ~]# lspci | egrep -i "Non"
81:00.0 Non-Volatile memory controller: DERA Storage Device 1515
82:00.0 Non-Volatile memory controller: DERA Storage Device 1515
```

**关键信息：**

| PCIe 设备 | 作用 |
|-----------|------|
| 81:00.0 / 82:00.0 | NVMe 控制器，对应 nvme0n1 / nvme1n1 |
| 38:05.0 HiSilicon AHCI HBA | SATA 控制器，挂 sda / sdb |
| 83:00.0 Broadcom MegaRAID | RAID 控制器，挂 sdc ~ sdj 的8块逻辑盘 |
| 30/32/70/72 HiSilicon SAS HBA | 华为自研 SAS HBA，板载 SAS 通道 |

---

## 模块3：NVMe / SATA / SAS / RAID 到底怎么区分

**判断方法一：看设备名**

- 设备名是 `nvmeXnX` → 一定是 NVMe
- 设备名是 `sdX` → 可能是 SATA、SAS，也可能是 RAID 逻辑盘，需要继续查

**判断方法二：lsscsi 看归属**

- 显示 `BROADCOM MR9560-16i` → 这是 RAID 控制器后面的逻辑盘
- 显示 `ATA` → 这是 SATA 设备
- 显示 `HUAWEI RAID0/RAID1/RAID5` → 这是华为 RAID 控制器的逻辑盘（另一台设备的例子）

**对比三台不同设备的 lsscsi 输出：**

```bash
# 设备一：只有一块 NVMe，直通盘
[N:0:0:1]  disk  BIWIN AP443 1TB SSD__1  /dev/nvme0n1

# 设备二：本机，RAID卡+SATA+NVMe混合
[0:3:104:0]  disk  BROADCOM MR9560-16i  /dev/sdc   # RAID逻辑盘
[1:0:0:0]    disk  ATA INTEL SSDSCKKB48 /dev/sda   # SATA直通盘
[N:0:0:1]    disk  DERAP44YGM03T2US__1  /dev/nvme0n1  # NVMe直通盘

# 设备三：华为RAID控制器
[0:0:7:0]  disk  ATA WUS721208BLE604  /dev/sda      # SATA/SAS 直通盘
[0:2:0:0]  disk  HUAWEI RAID0        /dev/sdb       # 华为RAID0逻辑盘
[0:2:2:0]  disk  HUAWEI RAID1        /dev/sdd       # 华为RAID1逻辑盘
[0:2:3:0]  disk  HUAWEI RAID5        /dev/sde       # 华为RAID5逻辑盘
```

---

## 模块4：本机存储路径图

把这台 6U 服务器的存储结构整理成路径图：

```
CPU
└─ PCIe Root Port
   ├─ NVMe Controller (81:00.0) → nvme0n1 (3.2TB, 系统盘 Klas)
   ├─ NVMe Controller (82:00.0) → nvme1n1 (3.2TB, 系统盘 openEuler)
   ├─ HiSilicon AHCI HBA (38:05.0) → sda / sdb (Intel SATA SSD × 2)
   └─ Broadcom MegaRAID (83:00.0) → sdc ~ sdj (RAID0 逻辑盘 × 8)
```

**这张图非常重要**，因为它直接决定带宽、延迟、故障位置和排查顺序。

以后你看到"存储慢"，不能只说"磁盘慢"，要能继续往下追：

- 是 NVMe 本身慢？
- 是 RAID 层慢？
- 是 PCIe 上游链路有竞争？
- 是跨 NUMA 导致的？

这就是系统工程思维。

---

## 模块5：存储异常排查链

### 盘不见了怎么查

**NVMe 不见了：**

```bash
lsblk
→ nvme list
→ lspci | grep -i nvme
→ dmesg | grep -i nvme
→ lsmod | grep nvme
```

**RAID / SAS 盘异常：**

```bash
lsblk
→ lsscsi
→ storcli64 show
→ dmesg
→ lspci | grep -i raid
```

排查逻辑：
- NVMe：块设备 → 控制器 → PCIe → 日志 → 驱动
- RAID：块设备 → SCSI/RAID → 管理工具 → 日志 → PCIe

### 盘还在但是慢怎么查

先看 iostat：

```bash
iostat -x 1
```

重点关注：

- `%util` 高不高（磁盘利用率是否打满）
- `await` 高不高（IO 平均等待时间）
- 是 NVMe 慢还是 RAID 慢（对比不同设备）
- 有没有上游链路共享问题（回到 PCIe 拓扑）

---

## 模块6：storcli64 使用方法（博通 RAID 卡）

storcli64 是管理 Broadcom/LSI RAID 控制器的专用工具，语法是先看控制器 `/c0`，再看逻辑盘 `/vall`，再看物理盘 `/eall/sall`。

### 查看控制器总览

```bash
[root@localhost ~]# storcli64 show
CLI Version = 007.2707.0000.0000 Dec 18, 2023
Operating system = Linux 5.10.0-216.0.0.115.oe2203sp4.aarch64
Status = Success

System Overview :
===============
-----------------------------------------------------------------------
Ctl  Model                Ports  PDs  DGs  DNOpt  VDs  VNOpt  Hlth
-----------------------------------------------------------------------
  0  MegaRAID9560-16i8GB  16     8    8    0      8    0      Opt
-----------------------------------------------------------------------
```

**关键字段解读：**

| 字段 | 含义 | 本机数据 |
|------|------|---------|
| Ports | 控制器端口数 | 16 |
| PDs | 物理盘数量 | 8 |
| DGs | Drive Group 数 | 8 |
| VDs | 虚拟盘（逻辑盘）数 | 8 |
| DNOpt | 异常 DG 数量 | 0（正常） |
| VNOpt | 异常 VD 数量 | 0（正常） |
| Hlth | 整体健康状态 | Opt（Optimal，正常） |

### 查看所有逻辑盘

```bash
[root@localhost ~]# storcli64 /c0/vall show
Controller = 0
Status = Success

Virtual Drives :
==============
---------------------------------------------------------------
DG/VD  TYPE   State  Access  Consist  Cache   sCC  Size
---------------------------------------------------------------
6/232  RAID0  Optl   RW      Yes      RWTD    ON   446.625 GB
5/233  RAID0  Optl   RW      Yes      RWTD    ON   446.625 GB
4/234  RAID0  Optl   RW      Yes      RWTD    ON   446.625 GB
3/235  RAID0  Optl   RW      Yes      RWTD    ON   446.625 GB
2/236  RAID0  Optl   RW      Yes      RWTD    ON   446.625 GB
7/237  RAID0  Optl   RW      Yes      RWTD    ON   446.625 GB
1/238  RAID0  Optl   RW      Yes      RWTD    ON   446.625 GB
0/239  RAID0  Optl   RW      Yes      RWTD    ON   446.625 GB
---------------------------------------------------------------
```

8块物理盘各自做了 RAID0（单盘直通，不做冗余），对应 lsblk 里的 sdc ~ sdj，每块 446.6GB，状态全部 Optl（Optimal，正常）。

### 常用命令速查

```bash
# 1. 看控制器列表
storcli64 show

# 2. 看 c0 控制器总览
storcli64 /c0 show

# 3. 看所有逻辑盘
storcli64 /c0/vall show

# 4. 看所有物理盘
storcli64 /c0/eall/sall show

# 5. 看完整详情
storcli64 /c0 show all
```

---

## 模块7：Python 存储检测脚本

```python
# storage_check.py
import subprocess

print("==== lsblk ====")
print(subprocess.run(["lsblk", "-d"], capture_output=True, text=True).stdout)

print("==== nvme list ====")
print(subprocess.run(["nvme", "list"], capture_output=True, text=True).stdout)

print("==== lsscsi ====")
print(subprocess.run(["lsscsi"], capture_output=True, text=True).stdout)
```

```bash
python3 storage_check.py
```

拿到任何一台服务器，先跑这个脚本，三条命令的输出就能快速建立对存储架构的基本认知。

---

## 本篇总结

| 层次 | 关键概念 | 本机实例 |
|------|---------|---------|
| 形态 | M.2 / U.2 / 2.5寸 | NVMe 是 U.2 形态，SATA 是 M.2 形态 |
| 协议 | NVMe / SATA / SAS | NVMe 直连 PCIe，SATA 走 AHCI |
| 总线 | PCIe | 所有存储最终都通过 PCIe 与 CPU 通信 |
| 控制层 | RAID | Broadcom MegaRAID，8块盘各做 RAID0 |
| 排查工具 | lsblk / lsscsi / storcli64 | 三步确认设备类型和健康状态 |

下一篇我们继续深入存储测试，用 fio 对 NVMe 和 RAID 逻辑盘分别测试，对比真实性能差异，敬请期待！

欢迎关注 **JACK的服务器笔记**，我们下篇见！
