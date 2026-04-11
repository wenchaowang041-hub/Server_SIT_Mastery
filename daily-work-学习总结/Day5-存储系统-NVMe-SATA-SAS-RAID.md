服务器存储系统：NVMe / SATA / SAS / RAID / IO路径

- 1. 分清 NVMe、SATA、SAS、RAID 各自是什么
- 2. 看懂你这台机器的真实存储结构
- 3. 说清“数据是怎么从盘走到 CPU/NPU 的”
- 4. 建立第一版存储排查链
- 5. 写一个最基础的存储检测脚本

## 服务器存储体系总览


1、NVME:是nvme协议、PCIE总线、特点是低延迟、高带宽、多队列
2、SATA：AHCI\SATA协议、结构简单、速度比nvme慢、
如果系统lsblk看到sdx、可能是sata也可能是raid组成的逻辑盘
SAS：企业级磁盘接口、常用于服务器、通常配合HBA和Raid控制器
Raid：是磁盘控制层、把多块物理盘组合成逻辑盘、提供冗余、重建、缓存等能力、radi0、1、5、50、10
## 实机存储设备识别

本机两块U.2的NVME、一张raid卡、（一张bordcom/lsi卡）
应该是U.2形态的NVME  SSD直连pcie的盘

L sblk-d 查看块设备查看NAME：sda、sdb、SIZE字段、TYPE

```bash
[root@localhost ~]# lsblk -d
NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda       8:0    0 447.1G  0 disk
sdb       8:16   0 447.1G  0 disk
sdc       8:32   0 446.6G  0 disk
sdd       8:48   0 446.6G  0 disk
sde       8:64   0 446.6G  0 disk
sdf       8:80   0 446.6G  0 disk
sdg       8:96   0 446.6G  0 disk
sdh       8:112  0 446.6G  0 disk
sdi       8:128  0 446.6G  0 disk
sdj       8:144  0 446.6G  0 disk
nvme1n1 259:0    0   2.9T  0 disk
nvme0n1 259:1    0   2.9T  0 disk
[root@localhost ~]# lsblk
NAME               MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda                  8:0    0 447.1G  0 disk
sdb                  8:16   0 447.1G  0 disk
sdc                  8:32   0 446.6G  0 disk
sdd                  8:48   0 446.6G  0 disk
sde                  8:64   0 446.6G  0 disk
sdf                  8:80   0 446.6G  0 disk
sdg                  8:96   0 446.6G  0 disk
sdh                  8:112  0 446.6G  0 disk
sdi                  8:128  0 446.6G  0 disk
sdj                  8:144  0 446.6G  0 disk
nvme1n1            259:0    0   2.9T  0 disk
├─nvme1n1p1        259:5    0   600M  0 part /boot/efi
├─nvme1n1p2        259:6    0     1G  0 part /boot
└─nvme1n1p3        259:7    0   2.9T  0 part
├─openeuler-root 253:0    0    70G  0 lvm  /
├─openeuler-swap 253:1    0     4G  0 lvm  [SWAP]
└─openeuler-home 253:2    0   2.8T  0 lvm  /home
nvme0n1            259:1    0   2.9T  0 disk
├─nvme0n1p1        259:2    0   600M  0 part
├─nvme0n1p2        259:3    0     1G  0 part
└─nvme0n1p3        259:4    0   2.9T  0 part
├─klas-swap      253:3    0     4G  0 lvm
├─klas-backup    253:4    0    50G  0 lvm
└─klas-root      253:5    0   2.9T  0 lvm
```

Nvme list：设备名、容量、型号、固件版本
```bash
[root@localhost ~]# nvme list
Node                  SN                   Model                                    Namespace Usage                      Format           FW Rev
--------------------- -------------------- ---------------------------------------- --------- -------------------------- ---------------- --------
/dev/nvme0n1          D77446D401J852       DERAP44YGM03T2US                         1           3.20  TB /   3.20  TB    512   B +  0 B   D7Y05M1F
/dev/nvme1n1          D77446D4017E52       DERAP44YGM03T2US                         1           3.20  TB /   3.20  TB    512   B +  0 B   D7Y05M1F
```

查看scsi/raid后面的盘
```bash
[root@localhost ~]# lsblk -d
NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda       8:0    0 447.1G  0 disk
sdb       8:16   0 447.1G  0 disk
sdc       8:32   0 446.6G  0 disk
sdd       8:48   0 446.6G  0 disk
sde       8:64   0 446.6G  0 disk
sdf       8:80   0 446.6G  0 disk
sdg       8:96   0 446.6G  0 disk
sdh       8:112  0 446.6G  0 disk
sdi       8:128  0 446.6G  0 disk
sdj       8:144  0 446.6G  0 disk
nvme1n1 259:0    0   2.9T  0 disk
nvme0n1 259:1    0   2.9T  0 disk
[root@localhost ~]# lsscsi
[0:1:124:0]  enclosu BROADCOM VirtualSES       03    -
[0:3:104:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdc
[0:3:105:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdd
[0:3:106:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sde
[0:3:107:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdf
[0:3:108:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdi
[0:3:109:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdj
[0:3:110:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdh
[0:3:111:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdg
[1:0:0:0]    disk    ATA      INTEL SSDSCKKB48 0100  /dev/sda
[2:0:0:0]    disk    ATA      INTEL SSDSCKKB48 0100  /dev/sdb
[N:0:0:1]    disk    DERAP44YGM03T2US__1                        /dev/nvme0n1
[N:1:0:1]    disk    DERAP44YGM03T2US__1                        /dev/nvme1n1
```

哪些盘来自 RAID 控制器
哪些是单独直通的设备
看 PCIe 层的存储控制器

```bash
[root@localhost ~]# lspci | egrep -i "SATA|SAS|NVME|SCSI|raid"
30:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
32:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
38:05.0 SATA controller: Huawei Technologies Co., Ltd. HiSilicon AHCI HBA (rev 30)
70:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
72:04.0 Serial Attached SCSI controller: Huawei Technologies Co., Ltd. HiSilicon SAS 3.0 HBA (rev 30)
83:00.0 RAID bus controller: Broadcom / LSI MegaRAID 12GSAS/PCIe Secure SAS39xx
```

## NVMe / SATA / SAS / RAID 区别

看到 nvme0n1 / nvme1n1这是NVMe 块设备本质是pcie设备
Nvme list、lspci | grep -i nvme（ Non-Volatile memory ）

```bash
[root@localhost ~]# lspci | egrep -i "Non"
81:00.0 Non-Volatile memory controller: DERA Storage Device 1515
82:00.0 Non-Volatile memory controller: DERA Storage Device 1515
```

看到sdx、不一定是sata盘、继续看lsscsi、看他属于哪个设备
是raid的逻辑盘还是直通设备
如果它显示：
BROADCOM MR9560-16i
这种 RAID 控制器信息，就说明：
这是 RAID 逻辑盘 / RAID 控制器后面的盘
设备一：
root@thtf-pc:~# lsscsi
[N:0:0:1]    disk    BIWIN AP443 1TB SSD__1                     /dev/nvme0n1
root@thtf-pc:~#


设备二：
```bash
[root@localhost ~]# lsscsi
[0:1:124:0]  enclosu BROADCOM VirtualSES       03    -
[0:3:104:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdc
[0:3:105:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdd
[0:3:106:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sde
[0:3:107:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdf
[0:3:108:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdi
[0:3:109:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdj
[0:3:110:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdh
[0:3:111:0]  disk    BROADCOM MR9560-16i       5.29  /dev/sdg
[1:0:0:0]    disk    ATA      INTEL SSDSCKKB48 0100  /dev/sda
[2:0:0:0]    disk    ATA      INTEL SSDSCKKB48 0100  /dev/sdb
[N:0:0:1]    disk    DERAP44YGM03T2US__1                        /dev/nvme0n1
[N:1:0:1]    disk    DERAP44YGM03T2US__1                        /dev/nvme1n1
```

看到ATA 是sata设备、
结合机器BOM验证sda、sdb是M.2形态的SATA协议的设备

NVMe 是盘类型 + 协议
RAID 是控制层
SATA / SAS 是磁盘接口体系

看到 RAID bus controller
说明这是：RAID 控制器本身

设备三：[root@bogon ~]# lsscsi
[0:0:7:0]    disk    ATA      WUS721208BLE604  WNFB  /dev/sda
[0:2:0:0]    disk    HUAWEI   RAID0            C00   /dev/sdb
[0:2:1:0]    disk    HUAWEI   RAID0            C00   /dev/sdc
[0:2:2:0]    disk    HUAWEI   RAID1            C00   /dev/sdd
[0:2:3:0]    disk    HUAWEI   RAID5            C00   /dev/sde
[0:2:4:0]    disk    HUAWEI   RAID0            C00   /dev/sdf
[0:2:5:0]    disk    HUAWEI   RAID1            C00   /dev/sdg
## 你这台机器的存储路径图

6U这台机器的存储结构可以先画成这样

CPU
└─ PCIe Root Port
	├─ NVMe (U.2) ×2
	└─ RAID Controller
		└─ 多块 SSD（SAS / SATA 体系）
这张图非常重要，因为它直接决定：
带宽
延迟
故障位置
排查顺序

以后你看到“存储慢”，不能只说：
磁盘慢
你要能继续往下追：
是 NVMe 本身慢？
是 RAID 层慢？
是 PCIe 上游链路有竞争？
是跨 NUMA？
这就是系统工程思维。



## 存储异常排查链


- 1. 如果“盘不见了”
NVMe 不见了
lsblk
→ nvme list
→ lspci | grep -i nvme
→ dmesg | grep -i nvme
→ lsmod | grep nvme
RAID / SAS 盘异常
lsblk
→ lsscsi
→ storcli
→ dmesg
→ lspci | grep -i raid


NVMe：块设备 → 控制器 → PCIe → 日志 → 驱动
RAID：块设备 → SCSI/RAID → 管理工具 → 日志 → PCIe

- 2. 如果“盘还在，但是慢”
先看：
iostat -x 1
然后区分：
%util 高不高
await 高不高
是 NVMe 慢还是 RAID 慢
有没有上游链路共享问题



## Python存储检测脚本

让脚本帮你把存储设备列出来
会用 subprocess 拉系统信息

Vi storage_check.py

import subprocess

print("==== lsblk ====")
print(subprocess.run(["lsblk", "-d"], capture_output=True, text=True).stdout)

print("==== nvme list ====")
print(subprocess.run(["nvme", "list"], capture_output=True, text=True).stdout)

print("==== lsscsi ====")
print(subprocess.run(["lsscsi"], capture_output=True, text=True).stdout)

python3 storage_check.py


M.2 ，U.2是形态
SATA / NVMe 是协议
PCIe 是总线

Storcli64使用方法（博通）
storcli 是“先看控制器 /c0，再看逻辑盘 /vall，再看物理盘 /eall/sall”

# 1. 先看控制器在不在
storcli show



```bash
[root@localhost ~]# storcli64 show
CLI Version = 007.2707.0000.0000 Dec 18, 2023
Operating system = Linux 5.10.0-216.0.0.115.oe2203sp4.aarch64
Status Code = 0
Status = Success
Description = None
Number of Controllers = 1
Host Name = localhost.localdomain
Operating System  = Linux 5.10.0-216.0.0.115.oe2203sp4.aarch64
System Overview :
===============
--------------------------------------------------------------------------------
Ctl Model               Ports PDs DGs DNOpt VDs VNOpt BBU sPR DS  EHS ASOs Hlth
--------------------------------------------------------------------------------
0 MegaRAID9560-16i8GB    16   8   8     0   8     0 N/A On  1&2 Y      4 Opt
--------------------------------------------------------------------------------
Ctl=Controller Index|DGs=Drive groups|VDs=Virtual drives|Fld=Failed
PDs=Physical drives|DNOpt=Array NotOptimal|VNOpt=VD NotOptimal|Opt=Optimal
Msng=Missing|Dgd=Degraded|NdAtn=Need Attention|Unkwn=Unknown
sPR=Scheduled Patrol Read|DS=DimmerSwitch|EHS=Emergency Spare Drive
Y=Yes|N=No|ASOs=Advanced Software Options|BBU=Battery backup unit/CV
Hlth=Health|Safe=Safe-mode boot|CertProv-Certificate Provision mode
Chrg=Charging | MsngCbl=Cable Failure
```




- 2. 看 c0 总览
storcli /c0 show

```bash
[root@localhost ~]# storcli64 /c0 show
Generating detailed summary of the adapter, it may take a while to complete.
CLI Version = 007.2707.0000.0000 Dec 18, 2023
Operating system = Linux 5.10.0-216.0.0.115.oe2203sp4.aarch64
Controller = 0
Status = Success
Description = None
Product Name = MegaRAID 9560-16i 8GB
Serial Number = SPE5201509
SAS Address =  500062b220902e00
PCI Address = 00:83:00:00
System Time = 03/16/2026 15:31:06
Mfg. Date = 01/10/25
Controller Time = 03/16/2026 07:31:05
FW Package Build = 52.29.0-5442
BIOS Version = 7.29.00.0_0x071D0000
FW Version = 5.290.02-3997
Driver Name = megaraid_sas
Driver Version = 07.714.04.00-rc1
Current Personality = RAID-Mode
Vendor Id = 0x1000
Device Id = 0x10E2
SubVendor Id = 0x1000
SubDevice Id = 0x4000
Host Interface = PCI-E
Device Interface = SAS-12G
Bus Number = 131
Device Number = 0
Function Number = 0
Domain ID = 0
Security Protocol = None
Drive Groups = 8
TOPOLOGY :
========
-----------------------------------------------------------------------------
DG Arr Row EID:Slot DID Type  State BT       Size PDC  PI SED DS3  FSpace TR
-----------------------------------------------------------------------------
0 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
0 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
0 0   0   252:0    2   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
1 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
1 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
1 0   0   252:1    9   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
2 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
2 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
2 0   0   252:3    5   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
3 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
3 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
3 0   0   252:4    4   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
4 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
4 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
4 0   0   252:5    6   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
5 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
5 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
5 0   0   252:6    7   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
6 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
6 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
6 0   0   252:7    8   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
7 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
7 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
7 0   0   252:2    3   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
-----------------------------------------------------------------------------
DG=Disk Group Index|Arr=Array Index|Row=Row Index|EID=Enclosure Device ID
DID=Device ID|Type=Drive or RAID Type|Onln=Online|Rbld=Rebuild|Optl=Optimal
Dgrd=Degraded|Pdgd=Partially degraded|Offln=Offline|BT=Background Task Active
PDC=PD Cache|PI=Protection Info|SED=Self Encrypting Drive|Frgn=Foreign
DS3=Dimmer Switch 3|dflt=Default|Msng=Missing|FSpace=Free Space Present
TR=Transport Ready
Virtual Drives = 8
VD LIST :
=======
---------------------------------------------------------------
DG/VD TYPE  State Access Consist Cache Cac sCC       Size Name
---------------------------------------------------------------
6/232 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
5/233 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
4/234 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
3/235 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
2/236 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
7/237 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
1/238 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
0/239 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
---------------------------------------------------------------
VD=Virtual Drive| DG=Drive Group|Rec=Recovery
Cac=CacheCade|OfLn=OffLine|Pdgd=Partially Degraded|Dgrd=Degraded
Optl=Optimal|dflt=Default|RO=Read Only|RW=Read Write|HD=Hidden|TRANS=TransportReady
B=Blocked|Consist=Consistent|R=Read Ahead Always|NR=No Read Ahead|WB=WriteBack
AWB=Always WriteBack|WT=WriteThrough|C=Cached IO|D=Direct IO|sCC=Scheduled
Check Consistency
Physical Drives = 8
PD LIST :
=======
------------------------------------------------------------------------------
EID:Slt DID State DG       Size Intf Med SED PI SeSz Model            Sp Type
------------------------------------------------------------------------------
252:0     2 Onln   0 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:1     9 Onln   1 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:2     3 Onln   7 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:3     5 Onln   2 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:4     4 Onln   3 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:5     6 Onln   4 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:6     7 Onln   5 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:7     8 Onln   6 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
------------------------------------------------------------------------------
EID=Enclosure Device ID|Slt=Slot No|DID=Device ID|DG=DriveGroup
DHS=Dedicated Hot Spare|UGood=Unconfigured Good|GHS=Global Hotspare
UBad=Unconfigured Bad|Sntze=Sanitize|Onln=Online|Offln=Offline|Intf=Interface
Med=Media Type|SED=Self Encryptive Drive|PI=PI Eligible
SeSz=Sector Size|Sp=Spun|U=Up|D=Down|T=Transition|F=Foreign
UGUnsp=UGood Unsupported|UGShld=UGood shielded|HSPShld=Hotspare shielded
CFShld=Configured shielded|Cpybck=CopyBack|CBShld=Copyback Shielded
UBUnsp=UBad Unsupported|Rbld=Rebuild
Enclosures = 1
Enclosure LIST :
==============
------------------------------------------------------------------------
EID State Slots PD PS Fans TSs Alms SIM Port# ProdID     VendorSpecific
------------------------------------------------------------------------
252 OK       16  8  0    0   0    0   0 -     VirtualSES
------------------------------------------------------------------------
EID=Enclosure Device ID | PD=Physical drive count | PS=Power Supply count
TSs=Temperature sensor count | Alms=Alarm count | SIM=SIM Count | ProdID=Product ID
```






# 3. 看所有逻辑盘
Storcli64 /c0/vall show

```bash
[root@localhost ~]# storcli64 /c0/vall show
CLI Version = 007.2707.0000.0000 Dec 18, 2023
Operating system = Linux 5.10.0-216.0.0.115.oe2203sp4.aarch64
Controller = 0
Status = Success
Description = None
Virtual Drives :
==============
---------------------------------------------------------------
DG/VD TYPE  State Access Consist Cache Cac sCC       Size Name
---------------------------------------------------------------
6/232 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
5/233 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
4/234 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
3/235 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
2/236 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
7/237 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
1/238 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
0/239 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
---------------------------------------------------------------
VD=Virtual Drive| DG=Drive Group|Rec=Recovery
Cac=CacheCade|OfLn=OffLine|Pdgd=Partially Degraded|Dgrd=Degraded
Optl=Optimal|dflt=Default|RO=Read Only|RW=Read Write|HD=Hidden|TRANS=TransportReady
B=Blocked|Consist=Consistent|R=Read Ahead Always|NR=No Read Ahead|WB=WriteBack
AWB=Always WriteBack|WT=WriteThrough|C=Cached IO|D=Direct IO|sCC=Scheduled
Check Consistency
```






# 4. 看所有物理盘
storcli /c0/eall/sall show


```bash
[root@localhost ~]# storcli64 /c0/eall/sall show
CLI Version = 007.2707.0000.0000 Dec 18, 2023
Operating system = Linux 5.10.0-216.0.0.115.oe2203sp4.aarch64
Controller = 0
Status = Success
Description = Show Drive Information Succeeded.
Drive Information :
=================
------------------------------------------------------------------------------
EID:Slt DID State DG       Size Intf Med SED PI SeSz Model            Sp Type
------------------------------------------------------------------------------
252:0     2 Onln   0 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:1     9 Onln   1 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:2     3 Onln   7 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:3     5 Onln   2 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:4     4 Onln   3 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:5     6 Onln   4 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:6     7 Onln   5 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:7     8 Onln   6 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
------------------------------------------------------------------------------
EID=Enclosure Device ID|Slt=Slot No|DID=Device ID|DG=DriveGroup
DHS=Dedicated Hot Spare|UGood=Unconfigured Good|GHS=Global Hotspare
UBad=Unconfigured Bad|Sntze=Sanitize|Onln=Online|Offln=Offline|Intf=Interface
Med=Media Type|SED=Self Encryptive Drive|PI=PI Eligible
SeSz=Sector Size|Sp=Spun|U=Up|D=Down|T=Transition|F=Foreign
UGUnsp=UGood Unsupported|UGShld=UGood shielded|HSPShld=Hotspare shielded
CFShld=Configured shielded|Cpybck=CopyBack|CBShld=Copyback Shielded
UBUnsp=UBad Unsupported|Rbld=Rebuild
```






# 5. 想看更细再展开
storcli /c0 show all
华为有自己的工具

Show：这会列出控制器列表；StorCLI 的对象是按控制器编号来看的，后面常见就是 /c0。StorCLI 的通用语法也是按 /cX 这种控制器索引来组织的。

storcli /c0 show all
查看更详细的信息

```bash
[root@localhost ~]# storcli64 /c0 show all
Generating detailed summary of the adapter, it may take a while to complete.
CLI Version = 007.2707.0000.0000 Dec 18, 2023
Operating system = Linux 5.10.0-216.0.0.115.oe2203sp4.aarch64
Controller = 0
Status = Success
Description = None
Basics :
======
Controller = 0
Model = MegaRAID 9560-16i 8GB
Serial Number = SPE5201509
Current Controller Date/Time = 03/16/2026, 07:35:14
Current System Date/time = 03/16/2026, 15:35:14
SAS Address = 500062b220902e00
PCI Address = 00:83:00:00
Mfg Date = 01/10/25
Rework Date = 00/00/00
Revision No = 00011
Version :
=======
Firmware Package Build = 52.29.0-5442
Firmware Version = 5.290.02-3997
PSOC FW Version = 0x001B
PSOC Hardware Version = 0x000A
PSOC Part Number = 29211-270-8GB
NVDATA Version = 5.2900.00-0761
CBB Version = 29.250.01.00
Bios Version = 7.29.00.0_0x071D0000
HII Version = 07.29.00.00
HIIA Version = 07.29.00.00
Driver Name = megaraid_sas
Driver Version = 07.714.04.00-rc1
Bus :
===
Vendor Id = 0x1000
Device Id = 0x10E2
SubVendor Id = 0x1000
SubDevice Id = 0x4000
Host Interface = PCI-E
Device Interface = SAS-12G
Bus Number = 131
Device Number = 0
Function Number = 0
Domain ID = 0
Pending Images in Flash :
=======================
Image name = No pending images
Status :
======
Controller Status = Optimal
Memory Correctable Errors = 0
Memory Uncorrectable Errors = 0
ECC Bucket Count = 0
Any Offline VD Cache Preserved = No
BBU Status = NA
PD Firmware Download in progress = No
Support PD Firmware Download = Yes
Lock Key Assigned = No
Failed to get lock key on bootup = No
Lock key has not been backed up = No
Bios was not detected during boot = No
Controller must be rebooted to complete security operation = No
A rollback operation is in progress = No
At least one PFK exists in NVRAM = No
SSC Policy is WB = No
Controller has booted into safe mode = No
Controller shutdown required = No
Controller has booted into certificate provision mode = No
Current Personality = RAID-Mode
Supported Adapter Operations :
============================
Rebuild Rate = Yes
CC Rate = Yes
BGI Rate  = Yes
Reconstruct Rate = Yes
Patrol Read Rate = Yes
Alarm Control = No
Cluster Support = No
BBU = NA
Spanning = Yes
Dedicated Hot Spare = Yes
Revertible Hot Spares = Yes
Foreign Config Import = Yes
Self Diagnostic = Yes
Allow Mixed Redundancy on Array = No
Global Hot Spares = Yes
Deny SCSI Passthrough = No
Deny SMP Passthrough = No
Deny STP Passthrough = No
Support more than 8 Phys = Yes
FW and Event Time in GMT = No
Support Enhanced Foreign Import = Yes
Support Enclosure Enumeration = Yes
Support Allowed Operations = Yes
Abort CC on Error = Yes
Support Multipath = Yes
Support Odd & Even Drive count in RAID1E = No
Support Security = Yes
Support Config Page Model = Yes
Support the OCE without adding drives = Yes
Support EKM = Yes
Snapshot Enabled = No
Support PFK = Yes
Support PI = No
Support Ld BBM Info = No
Support Shield State = Yes
Block SSD Write Disk Cache Change = No
Support Suspend Resume BG ops = Yes
Support Emergency Spares = Yes
Support Set Link Speed = Yes
Support Boot Time PFK Change = No
Support JBOD = No
Disable Online PFK Change = No
Support Perf Tuning = Yes
Support SSD PatrolRead = Yes
Real Time Scheduler = Yes
Support Reset Now = Yes
Support Emulated Drives = Yes
Headless Mode = Yes
Dedicated HotSpares Limited = No
Point In Time Progress = Yes
Extended LD = Yes
Support Uneven span  = No
Support Config Auto Balance = No
Support Maintenance Mode = No
Support Diagnostic results = Yes
Support Ext Enclosure = Yes
Support Sesmonitoring = Yes
Support SecurityonJBOD = Yes
Support ForceFlash = Yes
Support DisableImmediateIO = Yes
Support LargeIOSupport = No
Support DrvActivityLEDSetting = Yes
Support FlushWriteVerify = Yes
Support CPLDUpdate = No
Support ForceTo512e = Yes
Support discardCacheDuringLDDelete = No
Support JBOD Write cache = No
Support Large QD Support = No
Support Ctrl Info Extended = Yes
Support IButton less = Yes
Support AES Encryption Algorithm = No
Support Encrypted MFC = Yes
Support Snapdump = Yes
Support Force Personality Change = Yes
Support Dual Fw Image = No
Support PSOC Update = Yes
Support Secure Boot = Yes
Support Debug Queue = No
Support Least Latency Mode = No
Support OnDemand Snapdump = Yes
Support Clear Snapdump = Yes
Support FW Triggered Snapdump = Yes
Support PHY current speed = Yes
Support Lane current speed = Yes
Support NVMe Width = Yes
Support Lane DeviceType = Yes
Support Extended Drive performance Monitoring = Yes
Support NVMe Repair = Yes
Support Platform Security = No
Support None Mode Params = Yes
Support Extended Controller Property = Yes
Support Smart Poll Interval for DirectAttached = Yes
Support Write Journal Pinning = Yes
Support SMP Passthru with Port Number = Yes
Support SnapDump Preboot Trace Buffer Toggle = Yes
Support Parity Read Cache Bypass = Yes
Support NVMe Init Error Device ConnectorIndex = No
Support VolatileKey = Yes
Support PSOC Part Information = Yes
Support Slow array threshold calculation = Yes
Support PCIe Reference Clock override = Yes
Support Target ID Reuse = Yes
Support PCIe PERST override = Yes
Support Drive FW Download Mask = Yes
Support Drive FW Download Mode-5 = Yes
Support Drive FW Download Mode-7 = Yes
Support Drive FW Download Mode-E = Yes
Supported Drive FW Download Chunk Size = 32 KB
Enterprise Key management :
=========================
Capability = Supported
Boot Agent = Not Available
Configured = No
Supported PD Operations :
=======================
Force Online = Yes
Force Offline = Yes
Force Rebuild = Yes
Deny Force Failed = No
Deny Force Good/Bad = No
Deny Missing Replace = No
Deny Clear = No
Deny Locate = No
Support Power State = Yes
Set Power State For Cfg = No
Support T10 Power State = No
Support Temperature = Yes
NCQ = Yes
Support Max Rate SATA = No
Support Degraded Media = No
Support Parallel FW Update = Yes
Support Drive Crypto Erase = Yes
Support SSD Wear Gauge = No
Support Sanitize = No
Support Extended Sanitize = Yes
Supported VD Operations :
=======================
Read Policy = Yes
Write Policy = Yes
IO Policy = No
Access Policy = Yes
Disk Cache Policy = Yes
Reconstruction = Yes
Deny Locate = No
Deny CC = No
Allow Ctrl Encryption = No
Enable LDBBM = Yes
Support FastPath = Yes
Performance Metrics = Yes
Power Savings = No
Support Powersave Max With Cache = No
Support Breakmirror = No
Support SSC WriteBack = No
Support SSC Association = No
Support VD Hide = Yes
Support VD Cachebypass = Yes
Support VD discardCacheDuringLDDelete = No
Support VD Scsi Unmap = Yes
Advanced Software Option :
========================
-----------------------------------------
Adv S/W Opt         Time Remaining  Mode
-----------------------------------------
MegaRAID FastPath   Unlimited       -
MegaRAID SafeStore  Unlimited       -
MegaRAID RAID6      Unlimited       -
MegaRAID RAID5      Unlimited       -
-----------------------------------------
Safe ID =  B94DI8GWNMJ8R5MPE8NWERM14D1LDVCN83613RAZ
HwCfg :
=====
ChipRevision =  A0
BatteryFRU = N/A
Front End Port Count = 0
Backend Port Count = 16
BBU = Absent
Alarm = Absent
Serial Debugger = Present
NVRAM Size = 128KB
Flash Size = 16MB
On Board Memory Size = 8192MB
CacheVault Flash Size = NA
TPM = Absent
Upgrade Key = Absent
On Board Expander = Absent
Temperature Sensor for ROC = Present
Temperature Sensor for Controller = Absent
Upgradable CPLD = Absent
Upgradable PSOC = Present
Current Size of CacheCade (GB) = 0
Current Size of FW Cache (MB) = 6678
ROC temperature(Degree Celsius) = 42
Policies :
========
Policies Table :
==============
------------------------------------------------
Policy                          Current Default
------------------------------------------------
Predictive Fail Poll Interval   300 sec
Interrupt Throttle Active Count 16
Interrupt Throttle Completion   50 us
Rebuild Rate                    30 %    30%
PR Rate                         30 %    30%
BGI Rate                        30 %    30%
Check Consistency Rate          30 %    30%
Reconstruction Rate             30 %    30%
Cache Flush Interval            4s
------------------------------------------------
Flush Time(Default) = 4s
Drive Coercion Mode = none
Auto Rebuild = On
Battery Warning = On
ECC Bucket Size = 15
ECC Bucket Leak Rate (hrs) = 24
Restore Hot Spare on Insertion = Off
Expose Enclosure Devices = On
Maintain PD Fail History = On
Reorder Host Requests = On
Auto detect BackPlane = SGPIO/i2c SEP
Load Balance Mode = Auto
Security Key Assigned = Off
Disable Online Controller Reset = Off
Use drive activity for locate = Off
Boot :
====
BIOS Enumerate VDs = 1
Stop BIOS on Error = Off
Delay during POST = 0
Spin Down Mode = None
Enable Ctrl-R = No
Enable Web BIOS = No
Enable PreBoot CLI = No
Enable BIOS = Yes
Max Drives to Spinup at One Time = 2
Maximum number of direct attached drives to spin up in 1 min = 60
Delay Among Spinup Groups (sec) = 2
Allow Boot with Preserved Cache = Off
High Availability :
=================
Topology Type = None
Cluster Permitted = No
Cluster Active = No
Defaults :
========
Phy Polarity = 0
Phy PolaritySplit = 0
Strip Size = 256 KB
Write Policy = WB
Read Policy = RA
Cache When BBU Bad = Off
Cached IO = Off
VD PowerSave Policy = Controller Defined
Default spin down time (mins) = 30
Coercion Mode = None
ZCR Config = Unknown
Max Chained Enclosures = 16
Direct PD Mapping = No
Restore Hot Spare on Insertion = No
Expose Enclosure Devices = Yes
Maintain PD Fail History = Yes
Zero Based Enclosure Enumeration = No
Disable Puncturing = No
EnableLDBBM = Yes
DisableHII = No
Un-Certified Hard Disk Drives = Allow
SMART Mode = Mode 6
Enable LED Header = Yes
LED Show Drive Activity = Yes
Dirty LED Shows Drive Activity = No
EnableCrashDump = No
Disable Online Controller Reset = No
Treat Single span R1E as R10 = No
Power Saving option = Enabled
TTY Log In Flash = No
Auto Enhanced Import = Yes
BreakMirror RAID Support = No
Disable Join Mirror = Yes
Enable Shield State = Yes
Time taken to detect CME = 60 sec
Capabilities :
============
Supported Drives = SAS, SATA, NVMe
RAID Level Supported = RAID0, RAID1(2 or more drives), RAID5, RAID6, RAID00, RAID10(2 or more drives per span), RAID50, RAID60
Enable JBOD = No
Mix in Enclosure = Allowed
Mix of SAS/SATA of HDD type in VD = Allowed
Mix of SAS/SATA of SSD type in VD = Not Allowed
Mix of SSD/HDD in VD = Not Allowed
SAS Disable = No
Max Arms Per VD = 32
Max Spans Per VD = 8
Max Arrays = 240
Max VD per array = 16
Max Number of VDs = 240
Max Parallel Commands = 5101
Max SGE Count = 60
Max Data Transfer Size = 2048 sectors
Max Strips PerIO = 42
Max Configurable CacheCade Size(GB) = 0
Max Transportable DGs = 0
Enable Snapdump = Yes
Enable SCSI Unmap = Yes
Read cache bypass enabled for Parity RAID LDs = Yes
FDE Drive Mix Support = No
Min Strip Size = 64 KB
Max Strip Size = 1.000 MB
Scheduled Tasks :
===============
Consistency Check Reoccurrence = 168 hrs
Next Consistency check launch = 03/21/2026, 03:00:00
Patrol Read Reoccurrence = 168 hrs
Next Patrol Read launch = 03/21/2026, 03:00:00
Battery learn Reoccurrence = NA
Next Battery Learn = NA
OEMID = Broadcom
Secure Boot :
===========
Secure Boot Enabled = Yes
Controller in Soft Secure Mode = No
Controller in Hard Secure Mode = Yes
Key Update Pending = No
Remaining Secure Boot Key Slots = 7
Security Protocol properties :
============================
Security Protocol = None
Drive Groups = 8
TOPOLOGY :
========
-----------------------------------------------------------------------------
DG Arr Row EID:Slot DID Type  State BT       Size PDC  PI SED DS3  FSpace TR
-----------------------------------------------------------------------------
0 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
0 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
0 0   0   252:0    2   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
1 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
1 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
1 0   0   252:1    9   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
2 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
2 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
2 0   0   252:3    5   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
3 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
3 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
3 0   0   252:4    4   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
4 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
4 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
4 0   0   252:5    6   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
5 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
5 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
5 0   0   252:6    7   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
6 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
6 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
6 0   0   252:7    8   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
7 -   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
7 0   -   -        -   RAID0 Optl  N  446.625 GB dflt N  N   none N      N
7 0   0   252:2    3   DRIVE Onln  N  446.625 GB dflt N  N   none -      N
-----------------------------------------------------------------------------
DG=Disk Group Index|Arr=Array Index|Row=Row Index|EID=Enclosure Device ID
DID=Device ID|Type=Drive or RAID Type|Onln=Online|Rbld=Rebuild|Optl=Optimal
Dgrd=Degraded|Pdgd=Partially degraded|Offln=Offline|BT=Background Task Active
PDC=PD Cache|PI=Protection Info|SED=Self Encrypting Drive|Frgn=Foreign
DS3=Dimmer Switch 3|dflt=Default|Msng=Missing|FSpace=Free Space Present
TR=Transport Ready
Virtual Drives = 8
VD LIST :
=======
---------------------------------------------------------------
DG/VD TYPE  State Access Consist Cache Cac sCC       Size Name
---------------------------------------------------------------
6/232 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
5/233 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
4/234 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
3/235 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
2/236 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
7/237 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
1/238 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
0/239 RAID0 Optl  RW     Yes     RWTD  -   ON  446.625 GB
---------------------------------------------------------------
VD=Virtual Drive| DG=Drive Group|Rec=Recovery
Cac=CacheCade|OfLn=OffLine|Pdgd=Partially Degraded|Dgrd=Degraded
Optl=Optimal|dflt=Default|RO=Read Only|RW=Read Write|HD=Hidden|TRANS=TransportReady
B=Blocked|Consist=Consistent|R=Read Ahead Always|NR=No Read Ahead|WB=WriteBack
AWB=Always WriteBack|WT=WriteThrough|C=Cached IO|D=Direct IO|sCC=Scheduled
Check Consistency
Physical Drives = 8
PD LIST :
=======
------------------------------------------------------------------------------
EID:Slt DID State DG       Size Intf Med SED PI SeSz Model            Sp Type
------------------------------------------------------------------------------
252:0     2 Onln   0 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:1     9 Onln   1 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:2     3 Onln   7 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:3     5 Onln   2 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:4     4 Onln   3 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:5     6 Onln   4 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:6     7 Onln   5 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
252:7     8 Onln   6 446.625 GB SATA SSD N   N  512B HWE62ST3480L003N U  -
------------------------------------------------------------------------------
EID=Enclosure Device ID|Slt=Slot No|DID=Device ID|DG=DriveGroup
DHS=Dedicated Hot Spare|UGood=Unconfigured Good|GHS=Global Hotspare
UBad=Unconfigured Bad|Sntze=Sanitize|Onln=Online|Offln=Offline|Intf=Interface
Med=Media Type|SED=Self Encryptive Drive|PI=PI Eligible
SeSz=Sector Size|Sp=Spun|U=Up|D=Down|T=Transition|F=Foreign
UGUnsp=UGood Unsupported|UGShld=UGood shielded|HSPShld=Hotspare shielded
CFShld=Configured shielded|Cpybck=CopyBack|CBShld=Copyback Shielded
UBUnsp=UBad Unsupported|Rbld=Rebuild
Enclosures = 1
Enclosure LIST :
==============
------------------------------------------------------------------------
EID State Slots PD PS Fans TSs Alms SIM Port# ProdID     VendorSpecific
------------------------------------------------------------------------
252 OK       16  8  0    0   0    0   0 -     VirtualSES
------------------------------------------------------------------------
EID=Enclosure Device ID | PD=Physical drive count | PS=Power Supply count
TSs=Temperature sensor count | Alms=Alarm count | SIM=SIM Count | ProdID=Product ID
```








华为Hiraidadm用法
```bash
[root@bogon ~]# ./hiraidadm show allctrl
========================================== Hiraidadm   Information ===========================================
Name: hiraidadm
Version: 1.2.2.9
Build Time: Jul  4 2025 11:03:05
==============================================================================================================
==============================================================================================================
Status Code = 0
Status = Success
Description = None
==============================================================================================================
Controllers Number = 1
-------------------------------------------------------
Controller Id           | 0
Device Name             | /dev/bsg/hiraid0
Pcie Bus Domain         | 0000
Bus Number              | 18
Device Number           | 00
Function Number         | 00
PCI Address             | 0000:18:00.0
[root@bogon ~]# ./hiraidadm show ctrlcount
========================================== Hiraidadm   Information ===========================================
Name: hiraidadm
Version: 1.2.2.9
Build Time: Jul  4 2025 11:03:05
==============================================================================================================
==============================================================================================================
Status Code = 0
Status = Success
Description = None
==============================================================================================================
ctrlcount:1
==============================================================================================================
[root@bogon ~]# hiraidadm c0 show config
```

-bash: hiraidadm：未找到命令
```bash
[root@bogon ~]# ./hiraidadm c0 show config
========================================== Hiraidadm   Information ===========================================
Name: hiraidadm
Version: 1.2.2.9
Build Time: Jul  4 2025 11:03:05
==============================================================================================================
==============================================================================================================
Status Code = 0
Status = Success
Description = None
==============================================================================================================
--------------------------------------------------------------------------------------------------------------
Raid Global Config Information
--------------------------------------------------------------------------------------------------------------
Precopy Switch             | On
Emergency Hotspare Switch  | Off
CopyBack Switch            | On
Bginit Rate                | low
Rebuild Rate               | high
CopyBack Rate              | high
PreCopy Rate               | high
Sanitize Rate              | low
CCheck Switch              | On
CCheck Period              | 30 day
CCheck Rate                | low
CCheck Repair Switch       | On
Patrolread Switch          | On
Patrolread Period          | 30 day
Patrolread Rate            | low
Drive Parall Num           | 4
Auto Import Fncfg Switch   | Off
--------------------------------------------------------------------------------------------------------------
[root@bogon ~]# ./hiraidadm c0 show pdlist
========================================== Hiraidadm   Information ===========================================
Name: hiraidadm
Version: 1.2.2.9
Build Time: Jul  4 2025 11:03:05
==============================================================================================================
==============================================================================================================
Status Code = 0
Status = Success
Description = None
==============================================================================================================
Total pd number is 12
--------------------------------------------------------------------------------------------------------------
Index Enc  Slot DID  Intf  Media Type     Status         PreFail SlowDrive LinkSpd Capacity   SecType FUA SED Spin FW       Model
--------------------------------------------------------------------------------------------------------------
0     0    0    1    SATA  SSD   member   online         No      No        6.0Gb/s   447.132GB  512E   Sup No  UP   6060     HWE74ST3480L007N
1     0    1    0    SATA  SSD   member   online         No      No        6.0Gb/s   447.132GB  512E   Sup No  UP   6060     HWE74ST3480L007N
2     0    2    4    SATA  HDD   member   online         No      No        6.0Gb/s     7.277TB  512E   Sup No  UP   V1GAWNFB WUS721208BLE604
3     0    3    5    SATA  HDD   member   online         No      No        6.0Gb/s     7.277TB  512E   Sup No  UP   V1GAWNFB WUS721208BLE604
4     0    4    2    SATA  HDD   member   online         No      No        6.0Gb/s     7.277TB  512E   Sup No  UP   V1GAWNFB WUS721208BLE604
5     0    5    7    SATA  HDD   member   online         No      No        6.0Gb/s     7.277TB  512E   Sup No  UP   V1GAWNFB WUS721208BLE604
6     0    6    8    SATA  HDD   member   online         No      No        6.0Gb/s     7.277TB  512E   Sup No  UP   V1GAWNFB WUS721208BLE604
7     0    7    11   SATA  HDD   rawdrive online         No      No        6.0Gb/s     7.277TB  512E   Sup No  UP   V1GAWNFB WUS721208BLE604
8     0    8    9    SATA  HDD   member   online         No      No        6.0Gb/s     7.277TB  512E   Sup No  UP   V1GAWNFB WUS721208BLE604
9     0    9    3    SATA  HDD   member   online         No      No        6.0Gb/s     7.277TB  512E   Sup No  UP   V1GAWNFB WUS721208BLE604
10    0    10   6    SATA  HDD   member   online         No      No        6.0Gb/s     7.277TB  512E   Sup No  UP   V1GAWNFB WUS721208BLE604
11    0    11   10   SATA  HDD   member   online         No      No        6.0Gb/s     7.277TB  512E   Sup No  UP   V1GAWNFB WUS721208BLE604
--------------------------------------------------------------------------------------------------------------
[root@bogon ~]# ./hiraidadm c0 show vdlist
========================================== Hiraidadm   Information ===========================================
Name: hiraidadm
Version: 1.2.2.9
Build Time: Jul  4 2025 11:03:05
==============================================================================================================
==============================================================================================================
Status Code = 0
Status = Success
Description = None
==============================================================================================================
Total vd number is 6
--------------------------------------------------------------------------------------------------------------
VDID RGID Name           Type    Status         Capacity   SUSz   SecSz  RCache   WCache RealWCache Access
--------------------------------------------------------------------------------------------------------------
0    0                   normal  normal          892.262GB   64KB   512B No_Ahead WT     WT         RW
1    1    RAID0_Disk2    normal  normal            7.276TB  256KB   512B No_Ahead WT     WT         RW
2    2    RAID1_Disk3_4  normal  normal            7.276TB  256KB   512B No_Ahead WT     WT         RW
3    3    RAID5_5_6_7    normal  normal           14.553TB  256KB   512B No_Ahead WT     WT         RW
4    4    RAID0_8        normal  normal            7.276TB  256KB   512B No_Ahead WT     WT         RW
5    5    RAID1_9_10     normal  normal            7.276TB  256KB   512B No_Ahead WT     WT         RW
--------------------------------------------------------------------------------------------------------------
```


