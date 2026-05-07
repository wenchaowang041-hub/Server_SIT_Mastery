大家好，我是JACK，本篇是服务器测试百日学习计划Day7。

Day6 我们把 NVMe 搞清楚了，今天往更深一层——搞懂 RAID 控制器、逻辑盘、物理盘的关系，以及数据从盘到 OS 设备完整的映射链条。

## 一、先把存储看成4层

很多人看到 `lsblk` 里一堆 `sdX` 就直接说"这是8块盘"，但这个描述是不准确的。要真正看懂服务器存储，需要把它分成4层。

**第1层：物理介质层**
真正插在机器里的盘，关注型号、SN、槽位、健康状态。

**第2层：控制器层**
负责管理盘的"中间大脑"：RAID卡、HBA卡、主板集成控制器。这一层决定盘是直通还是被纳入RAID。

**第3层：逻辑卷层**
RAID卡把多块物理盘抽象成逻辑盘（VD/LD）。OS看到的不是底下的4块物理盘，而是RAID卡给出的"虚拟块设备"。

**第4层：操作系统设备层**
Linux里看到的 `/dev/sda`、`/dev/nvme0n1` 等，关注系统是否识别、分区挂载是否正常。

> 💡 **核心认知**：操作系统看到的盘，不一定是真实物理盘。物理盘 → 控制器 → RAID组 → 逻辑盘 → Linux块设备，这条链条必须搞清楚。

---

## 二、三个最容易混的概念

### 物理盘（PD，Physical Drive）

真实存在的盘，插在某个槽位上。关注型号、SN、容量、槽位、状态（Online/Offline/Failed/Rebuild）。

### 逻辑盘（VD/LD，Virtual Drive / Logical Drive）

RAID控制器组合出来给OS用的"盘"。比如槽位0和槽位1两块盘做RAID1，OS只看到一个 `/dev/sda`，这时 `/dev/sda` 对应的是逻辑盘，而不是某一块物理盘。

### JBOD / 直通

控制器识别到盘，但不做RAID聚合，直接把单盘暴露给OS。效果上每块物理盘对应一个OS设备，但仍然可能经过RAID/HBA控制器。

> ⚠️ **容易踩坑**："系统看到单盘"不等于"主板直连"，也可能是控制器直通模式。

---

## 三、核心映射关系

今天最重要的一句话：

**物理槽位 Slot → 物理盘 PD → RAID组/Array → 逻辑盘 LD/VD → Linux块设备 /dev/sdX**

这条链正着走、反着走都要会。

遇到"/dev/sdb IO错误"，你要能顺着往下找：属于哪个逻辑盘 → 逻辑盘底下哪块物理盘报错 → 哪个槽位。

遇到"5号槽位亮黄灯"，你要能反着往上找：这块物理盘属于哪个RAID组 → 对应哪个逻辑盘 → OS上影响哪个设备 → 当前业务是否受影响。

---

## 四、RAID常见模式

| RAID类型 | 特点 | 容错 | 适用场景 |
|---------|------|------|---------|
| RAID0 | 条带化，提升性能 | 无，任一盘坏即挂 | 纯性能场景 |
| RAID1 | 镜像，两块盘 | 强，常用于系统盘 | 高可靠性 |
| RAID5 | 条带+奇偶校验 | 允许坏1块 | 数据盘折中方案 |
| RAID10 | 镜像+条带 | 强 | 性能和可靠性兼顾 |

**物理盘常见状态：**

| 状态 | 含义 |
|------|------|
| Online | 正常在线 |
| Failed | 故障，已坏或被剔除 |
| Rebuild | 重建中，替换盘正在补数据 |
| Hot Spare | 热备盘，阵列异常时自动顶上 |
| Degraded | 降级（逻辑盘状态），有成员盘故障但阵列还没挂 |

> 💡 **Degraded ≠ 没事**：只要逻辑盘进入Degraded状态，说明已经出故障，只是暂时还能撑。这时IO性能通常会明显下降，必须尽快处理。

---

## 五、两套工具链，不能混用

我们测试环境里同时存在两套RAID工具链，一定要区分：

- **6U 鲲鹏服务器**：Broadcom MegaRAID 9560-16i，工具是 `storcli64`
- **2U 华为服务器**：华为 SP686 RAID，工具是 `hiraidadm`

品牌不同，命令不同，但排障对象和层次几乎一样：找控制器 → 找逻辑盘 → 找物理盘 → 找槽位 → 做映射 → 看状态。

---

## 六、实机分析：本机存储路径实锤

本机（6U鲲鹏服务器）同时存在三条存储路径，这是服务器现场的真实复杂度。

### 确认控制器

```bash
[root@bogon ~]# lspci | grep -i raid
83:00.0 RAID bus controller: Broadcom / LSI MegaRAID 12GSAS/PCIe Secure SAS39xx

[root@bogon ~]# lspci | egrep -i "sata|sas"
30:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
32:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
38:05.0 SATA controller: Huawei Technologies Co., Ltd. HiSilicon AHCI HBA (rev 30)
70:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
72:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
```

本机存在三类控制器：1张Broadcom RAID卡、4路HiSilicon SAS HBA、1个HiSilicon AHCI HBA，以及两个独立NVMe控制器。不是单一路径。

### storcli64 /c0 show 完整输出

```bash
[root@bogon ~]# storcli64 /c0 show
Product Name = MegaRAID 9560-16i 8GB
Serial Number = SPE5201509
FW Version = 5.290.02-3997
Driver Name = megaraid_sas
Current Personality = RAID-Mode
Drive Groups = 8

TOPOLOGY :
---------------------------------------------------------------------------
DG Arr Row EID:Slot DID Type  State BT Size        PDC  PI SED DS3 FSpace TR
---------------------------------------------------------------------------
0  -   -   -        -   RAID0 Optl  N  446.625 GB  dflt N  N   none N   N
0  0   0   252:0    2   DRIVE Onln  N  446.625 GB  dflt N  N   none -   N
1  -   -   -        -   RAID0 Optl  N  446.625 GB  dflt N  N   none N   N
1  0   0   252:1    9   DRIVE Onln  N  446.625 GB  dflt N  N   none -   N
...（共8个DG，全部RAID0，全部Optl）

VD LIST :
-------------------------------------------------------------
DG/VD  TYPE  State Access Consist Cache sCC Size
-------------------------------------------------------------
6/232  RAID0 Optl  RW     Yes     RWTD  ON  446.625 GB
5/233  RAID0 Optl  RW     Yes     RWTD  ON  446.625 GB
4/234  RAID0 Optl  RW     Yes     RWTD  ON  446.625 GB
3/235  RAID0 Optl  RW     Yes     RWTD  ON  446.625 GB
2/236  RAID0 Optl  RW     Yes     RWTD  ON  446.625 GB
7/237  RAID0 Optl  RW     Yes     RWTD  ON  446.625 GB
1/238  RAID0 Optl  RW     Yes     RWTD  ON  446.625 GB
0/239  RAID0 Optl  RW     Yes     RWTD  ON  446.625 GB

PD LIST :
---------------------------------------------------------------------------
EID:Slt DID State DG Size       Intf Med  Model             Sp
---------------------------------------------------------------------------
252:0   2   Onln  0  446.625 GB SATA SSD  HWE62ST3480L003N  U
252:1   9   Onln  1  446.625 GB SATA SSD  HWE62ST3480L003N  U
252:2   3   Onln  7  446.625 GB SATA SSD  HWE62ST3480L003N  U
252:3   5   Onln  2  446.625 GB SATA SSD  HWE62ST3480L003N  U
252:4   4   Onln  3  446.625 GB SATA SSD  HWE62ST3480L003N  U
252:5   6   Onln  4  446.625 GB SATA SSD  HWE62ST3480L003N  U
252:6   7   Onln  5  446.625 GB SATA SSD  HWE62ST3480L003N  U
252:7   8   Onln  6  446.625 GB SATA SSD  HWE62ST3480L003N  U
```

**关键发现：** 8块物理SATA SSD，每块单独做了一个RAID0，这不是JBOD直通，而是"单盘RAID0"方案，OS看到的 sdc~sdj 是8个逻辑盘，不是8块裸物理盘。

---

## 七、槽位到Linux设备的完整映射

通过 `storcli64 /c0/vall show all` 和 `storcli64 /c0/e252/sall show all` 可以把槽位到盘符一一对死：

| EID:Slot | DID | DG | VD | OS设备 | 型号 | 状态 |
|---------|-----|-----|-----|-------|------|------|
| 252:7 | 8 | 6 | 232 | /dev/sdc | HWE62ST3480L003N | Onln |
| 252:6 | 7 | 5 | 233 | /dev/sdd | HWE62ST3480L003N | Onln |
| 252:5 | 6 | 4 | 234 | /dev/sde | HWE62ST3480L003N | Onln |
| 252:4 | 4 | 3 | 235 | /dev/sdf | HWE62ST3480L003N | Onln |
| 252:3 | 5 | 2 | 236 | /dev/sdg | HWE62ST3480L003N | Onln |
| 252:2 | 3 | 7 | 237 | /dev/sdh | HWE62ST3480L003N | Onln |
| 252:1 | 9 | 1 | 238 | /dev/sdj | HWE62ST3480L003N | Onln |
| 252:0 | 2 | 0 | 239 | /dev/sdi | HWE62ST3480L003N | Onln |

> ⚠️ **注意**：Linux盘符枚举顺序不能按槽位顺序脑补，VD号最小的（VD232）反而对应 `/dev/sdc`，必须以工具输出为准。

---

## 八、本机完整存储路径图

```
Broadcom MegaRAID 9560-16i 8GB (/c0, RAID-Mode, 83:00.0)
└─ Enclosure 252
   ├─ Slot7 → PD → DG6/VD232 RAID0 → /dev/sdc
   ├─ Slot6 → PD → DG5/VD233 RAID0 → /dev/sdd
   ├─ Slot5 → PD → DG4/VD234 RAID0 → /dev/sde
   ├─ Slot4 → PD → DG3/VD235 RAID0 → /dev/sdf
   ├─ Slot3 → PD → DG2/VD236 RAID0 → /dev/sdg
   ├─ Slot2 → PD → DG7/VD237 RAID0 → /dev/sdh
   ├─ Slot1 → PD → DG1/VD238 RAID0 → /dev/sdj
   └─ Slot0 → PD → DG0/VD239 RAID0 → /dev/sdi

其他路径
├─ /dev/sda → Intel SATA SSD（AHCI控制器直连）
├─ /dev/sdb → Intel SATA SSD（AHCI控制器直连）
├─ /dev/nvme0n1 → DERA NVMe（PCIe 81:00.0）
└─ /dev/nvme1n1 → DERA NVMe（PCIe 82:00.0，当前活动系统盘）
```

有了这张图，遇到 `/dev/sde` 异常，立刻知道是 Slot5 那块盘；机房说"252:4要点灯"，立刻知道影响的是 `/dev/sdf`。

---

## 九、AHCI / HBA / RAID / NVMe 到底怎么区分

这四个词经常让人混，原因是它们不在同一个维度：

| 名称 | 类型 | 含义 |
|------|------|------|
| AHCI | 接口规范 | SATA控制器和OS交互的标准方式 |
| HBA | 适配器角色 | 主机连接存储设备的适配器，偏接入和透传 |
| RAID | 管理能力 | 控制器上的磁盘编组、逻辑盘、缓存、重建 |
| NVMe | 存储协议 | 基于PCIe的高性能存储协议，面向闪存 |

结合本机：

- **AHCI路径**：sda/sdb，Intel SATA SSD，主板AHCI控制器直连
- **RAID路径**：sdc~sdj，Broadcom RAID卡管理，单盘RAID0逻辑盘
- **NVMe路径**：nvme0n1/nvme1n1，独立PCIe NVMe盘，不经过RAID卡

---

## 十、存储异常排查链

### 盘不见了

**先分清是哪条路径的盘，再按路径排查：**

```bash
# 第1步：OS层确认
lsblk
lsscsi
dmesg -T | egrep -i 'sd[a-z]|scsi|sas|error|fail|reset'

# 第2步：控制器层确认（Broadcom路径）
storcli64 /c0 show          # 看控制器总览
storcli64 /c0/vall show     # 看逻辑盘状态
storcli64 /c0/e252/sall show # 看物理盘状态

# 第3步：物理层确认
# 结合槽位和指示灯，判断是单盘坏、背板问题还是控制器问题
```

### 逻辑盘还在但性能突然很差

很可能是阵列已经降级或正在重建：

```bash
iostat -x 1
# 结合storcli确认是否有盘在Rebuild或Degraded
# RAID阵列"没挂"不等于"没问题"，Degraded状态下性能就已经明显受影响
```

---

## 十一、常见误区

**误区1：OS里只有一块盘，就说明机器里只有一块盘。**
错。可能是多块物理盘组成一个RAID逻辑盘，OS只看到逻辑盘。

**误区2：系统看不到盘，就是盘坏了。**
错。还可能是控制器没识别、盘带Foreign配置、盘在RAID卡后面未直通、背板线缆异常。

**误区3：阵列还能用就不用处理。**
错。只要Degraded/Rebuild/Predictive Failure/Media Error增长，就已经进入风险状态。

---

## 总结

| 层次 | 关键工具 | 本机实例 |
|------|---------|---------|
| OS层 | lsblk / lsscsi / dmesg | 12块设备，分三条路径 |
| 控制器层 | storcli64 / lspci | Broadcom MegaRAID + AHCI + NVMe控制器 |
| 逻辑盘层 | storcli64 /c0/vall show | 8个单盘RAID0，全部Optl |
| 物理盘层 | storcli64 /c0/e252/sall show | 8块SATA SSD，Slot0~7，全部Onln |
| 映射表 | 综合以上 | Slot → DG/VD → /dev/sdX，精确对应 |

下一篇 Day8 聊SAS/SATA架构、背板、Expander和链路识别，继续往存储体系的底层走，敬请期待！

欢迎关注 **JACK的服务器笔记**，我们下篇见！
