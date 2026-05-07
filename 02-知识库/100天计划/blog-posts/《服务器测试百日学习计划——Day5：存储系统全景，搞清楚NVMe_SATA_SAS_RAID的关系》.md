大家好，我是JACK，本篇是服务器测试百日学习计划Day5。

上一篇我们搞清楚了块设备和文件系统，今天深入存储系统——搞清楚NVMe、SATA、SAS、RAID各自是什么，以及数据怎么从盘走到CPU。

## 一、先把概念分清楚

很多人看到 `lsblk` 输出一堆 `sdX` 和 `nvmeXnX`，不知道哪个是什么盘，根本原因是没分清这几个层次：

**NVMe**：协议名，走 PCIe 总线，低延迟、高带宽、多队列，是企业服务器高性能存储主流。

**SATA**：走 AHCI/SATA 协议，结构简单，速度比 NVMe 慢。`lsblk` 看到 `sdX`，可能是 SATA 盘，也可能是 RAID 逻辑盘，不能直接判断。

**SAS**：企业级磁盘接口，通常配合 HBA 卡和 RAID 控制器使用。

**RAID**：不是盘的类型，是控制层。把多块物理盘组合成逻辑盘，提供冗余和缓存能力，常见模式 RAID0/1/5/10。

> 💡 记住这个关系：NVMe 是协议，SATA/SAS 是接口体系，RAID 是控制层，PCIe 是总线，M.2/U.2 是形态。

---

## 二、实机存储设备识别

本机配置：两块 U.2 NVMe SSD、一张 Broadcom MegaRAID RAID 卡（MR9560-16i）、两块 Intel M.2 SATA SSD。

### 第一步：lsblk 看所有块设备

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

`nvme0n1` 和 `nvme1n1` 是 NVMe 盘，`sda` 到 `sdj` 共10个 `sdX` 设备，但光看这里还不知道是什么盘，继续查。

加上分区挂载信息：

```bash
[root@localhost ~]# lsblk
NAME                  MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
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

nvme1n1 装的是 openEuler，nvme0n1 装的是 Klas（麒麟），两块系统盘各跑一个 OS。

### 第二步：nvme list 确认 NVMe 盘型号

```bash
[root@localhost ~]# nvme list
Node         SN               Model              Namespace  Usage               Format       FW Rev
------------ ---------------- ------------------ ---------- ------------------- ------------ -------
/dev/nvme0n1 D77446D401J852   DERAP44YGM03T2US   1          3.20 TB / 3.20 TB   512 B + 0 B  D7Y05M1F
/dev/nvme1n1 D77446D4017E52   DERAP44YGM03T2US   1          3.20 TB / 3.20 TB   512 B + 0 B  D7Y05M1F
```

两块 NVMe 型号一致：DERAP44YGM03T2US，单块 3.2TB，U.2 形态，通过 PCIe 直连 CPU。

### 第三步：lsscsi 看清所有 sdX 是什么盘

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
[N:0:0:1]    disk     DERAP44YGM03T2US__1                 /dev/nvme0n1
[N:1:0:1]    disk     DERAP44YGM03T2US__1                 /dev/nvme1n1
```

现在全清楚了：

| 设备 | 来源 | 类型 |
|------|------|------|
| sdc ~ sdj（8块） | BROADCOM MR9560-16i | RAID 控制器逻辑盘 |
| sda / sdb（2块） | ATA INTEL SSDSCKKB48 | M.2 形态 SATA SSD |
| nvme0n1 / nvme1n1 | DERAP44YGM03T2US | U.2 NVMe 直连 PCIe |

> 💡 **sda/sdb 显示 ATA 的原因**：这是 M.2 形态、SATA 协议的 Intel SSD。M.2 是形态，SATA 是协议，不是 NVMe。这两种协议共用 M.2 插槽，容易混淆。

### 第四步：lspci 确认存储控制器

```bash
[root@localhost ~]# lspci | egrep -i "SATA|SAS|NVME|SCSI|raid"
30:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
32:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
38:05.0 SATA controller: Huawei Technologies Co., Ltd. HiSilicon AHCI HBA (rev 30)
70:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
72:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
83:00.0 RAID bus controller: Broadcom / LSI MegaRAID 12GSAS/PCIe Secure SAS39xx

[root@localhost ~]# lspci | egrep -i "Non"
81:00.0 Non-Volatile memory controller: DERA Storage Device 1515
82:00.0 Non-Volatile memory controller: DERA Storage Device 1515
```

| PCIe 设备 | 作用 |
|-----------|------|
| 81:00.0 / 82:00.0 | NVMe 控制器，对应 nvme0n1 / nvme1n1 |
| 38:05.0 HiSilicon AHCI HBA | SATA 控制器，挂 sda / sdb |
| 83:00.0 Broadcom MegaRAID | RAID 控制器，挂 sdc ~ sdj |
| 30/32/70/72 HiSilicon SAS HBA | 华为板载 SAS 通道 |

---

## 三、本机存储路径图

```
CPU
└─ PCIe Root Port
   ├─ NVMe Controller (81:00.0) → nvme0n1 (3.2TB，系统盘 Klas)
   ├─ NVMe Controller (82:00.0) → nvme1n1 (3.2TB，系统盘 openEuler)
   ├─ HiSilicon AHCI HBA (38:05.0) → sda / sdb (Intel M.2 SATA SSD × 2)
   └─ Broadcom MegaRAID (83:00.0) → sdc ~ sdj (RAID0 逻辑盘 × 8)
```

这张图很重要。以后遇到"存储慢"，不能只说磁盘慢，要能往下追：

- 是 NVMe 本身慢？
- 是 RAID 层引入了额外延迟？
- 是 PCIe 链路有竞争？
- 是跨 NUMA 访问？

---

## 四、storcli64 管理 RAID 控制器

`storcli64` 是管理 Broadcom/LSI RAID 卡的专用工具，语法是按 `/c0`（控制器）→ `/vall`（逻辑盘）→ `/eall/sall`（物理盘）的层次来查。

### 查控制器总览

```bash
[root@localhost ~]# storcli64 show
CLI Version = 007.2707.0000.0000 Dec 18, 2023
Status = Success

System Overview :
===============
-------------------------------------------------------------------------
Ctl  Model                Ports  PDs  DGs  DNOpt  VDs  VNOpt  Hlth
-------------------------------------------------------------------------
  0  MegaRAID9560-16i8GB  16     8    8    0      8    0      Opt
-------------------------------------------------------------------------
```

关键字段：PDs=8块物理盘，VDs=8块逻辑盘，DNOpt/VNOpt=0表示无异常，Hlth=Opt表示健康。

### 查所有逻辑盘

```bash
[root@localhost ~]# storcli64 /c0/vall show
Controller = 0
Status = Success

Virtual Drives :
==============
-----------------------------------------------------------
DG/VD  TYPE   State  Access  Consist  Cache  sCC  Size
-----------------------------------------------------------
6/232  RAID0  Optl   RW      Yes      RWTD   ON   446.625 GB
5/233  RAID0  Optl   RW      Yes      RWTD   ON   446.625 GB
4/234  RAID0  Optl   RW      Yes      RWTD   ON   446.625 GB
3/235  RAID0  Optl   RW      Yes      RWTD   ON   446.625 GB
2/236  RAID0  Optl   RW      Yes      RWTD   ON   446.625 GB
7/237  RAID0  Optl   RW      Yes      RWTD   ON   446.625 GB
1/238  RAID0  Optl   RW      Yes      RWTD   ON   446.625 GB
0/239  RAID0  Optl   RW      Yes      RWTD   ON   446.625 GB
-----------------------------------------------------------
```

8块物理盘各自做了 RAID0（单盘直通），对应 sdc ~ sdj，每块 446.6GB，State 全部 Optl（正常）。

### storcli64 常用命令速查

```bash
# 看控制器列表
storcli64 show

# 看 c0 控制器总览
storcli64 /c0 show

# 看所有逻辑盘
storcli64 /c0/vall show

# 看所有物理盘
storcli64 /c0/eall/sall show

# 看完整详情
storcli64 /c0 show all
```

---

## 五、存储异常排查链

### 盘不见了

**NVMe 不见了：**

```bash
lsblk
→ nvme list
→ lspci | grep -i nvme
→ dmesg | grep -i nvme
→ lsmod | grep nvme
```

**RAID/SAS 盘不见了：**

```bash
lsblk
→ lsscsi
→ storcli64 show
→ dmesg
→ lspci | grep -i raid
```

### 盘还在但是慢

```bash
# 先看 IO 指标
iostat -x 1

# 重点关注：
# %util：磁盘利用率是否打满
# await：IO 平均等待时间是否异常高
# 对比 NVMe 和 RAID 逻辑盘的数据，定位是哪层慢
```

---

## 六、Python 存储检测脚本

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

拿到一台新服务器，先跑这个脚本，三条命令的输出就能快速建立对存储架构的基本认知。

---

## 总结

| 层次 | 概念 | 本机实例 |
|------|------|---------|
| 形态 | M.2 / U.2 | NVMe 是 U.2，SATA 是 M.2 |
| 协议 | NVMe / SATA / SAS | NVMe 走 PCIe，SATA 走 AHCI |
| 控制层 | RAID | Broadcom MegaRAID，8块盘各做 RAID0 |
| 排查工具 | lsblk / lsscsi / nvme list / storcli64/hiraidadm(华为raid卡专用) | 四步确认设备类型和健康状态 |

下一篇 Day6 深入 NVMe 架构，聊 NVMe 的内部结构、队列机制和健康状态查看，敬请期待！

欢迎关注 **JACK的服务器笔记**，我们下篇见！
