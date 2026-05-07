End of banner message from server

┌──────────────────────────────────────────────────────────────────────┐

│ • MobaXterm Personal Edition v25.2 • │

│ (SSH client, X server and network tools) │

│ │

│ ⮞ SSH session to root@10.121.177.157 │

│ • Direct SSH : ✓ │

│ • SSH compression : ✓ │

│ • SSH-browser : ✓ │

│ • X11-forwarding : ✗ (disabled or not supported by server) │

│ │

│ ⮞ For more info, ctrl+click on help or visit our website. │

└──────────────────────────────────────────────────────────────────────┘

Authorized users only. All activities may be monitored and reported.

Activate the web console with: systemctl enable --now cockpit.socket

Last login: Fri Apr 10 09:52:48 2026 from 10.121.179.8

Welcome to 5.10.0-216.0.0.115.oe2203sp4.aarch64

System information as of time: 2026年 04月 10日 星期五 10:05:33 CST

System load: 0.00

Memory used: .3%

Swap used: 0%

Usage On: 44%

IP address: 10.121.177.157

IP address: 10.121.177.157

IP address: 192.168.122.1

Users online: 2

\[root@localhost ~\]# cd plug-unplug-safe/

\[root@localhost plug-unplug-safe\]# ls

1-fenqu-safe.sh auto-plug-unplug-fio-safe.sh README.md

2-check-start-safe.sh common.sh runs

3-md5-safe.sh config.sh UUID-safe.sh

4-check-md5-safe.sh fio-safe.sh

5-check-log-safe.sh Plug-UnPlug-安全版操作手册.md

\[root@localhost plug-unplug-safe\]# source /root/plug-unplug-safe/common.sh

\[root@localhost plug-unplug-safe\]# list_dut_disks

/dev/nvme0n1

/dev/nvme10n1

/dev/nvme11n1

/dev/nvme1n1

/dev/nvme2n1

/dev/nvme3n1

/dev/nvme4n1

/dev/nvme6n1

/dev/nvme7n1

/dev/nvme8n1

/dev/nvme9n1

\[root@localhost plug-unplug-safe\]# list_non_dut_nvmes

\[root@localhost plug-unplug-safe\]# cd /root/plug-unplug-safe

\[root@localhost plug-unplug-safe\]# CYCLES=1 bash auto-plug-unplug-fio-safe.sh

Round directory: /root/plug-unplug-safe/runs/2026-04-10_100635

System disk excluded: /dev/nvme5n1

DUT disks: /dev/nvme0n1 /dev/nvme10n1 /dev/nvme11n1 /dev/nvme1n1 /dev/nvme2n1 /dev/nvm e3n1 /dev/nvme4n1 /dev/nvme6n1 /dev/nvme7n1 /dev/nvme8n1 /dev/nvme9n1

Other NVMe disks:

Confirm the test environment is ready and /etc/fstab does not contain stale DUT entrie s.

Press Enter to continue...

===== Step 1: partition disks =====

script: /root/plug-unplug-safe/1-fenqu-safe.sh

Detected DUT NVMe disks:

/dev/nvme0n1

/dev/nvme10n1

/dev/nvme11n1

/dev/nvme1n1

/dev/nvme2n1

/dev/nvme3n1

/dev/nvme4n1

/dev/nvme6n1

/dev/nvme7n1

/dev/nvme8n1

/dev/nvme9n1

Excluded system disk: /dev/nvme5n1

Processing: /dev/nvme0n1

Created p1=/dev/nvme0n1p1 p2=/dev/nvme0n1p2

Processing: /dev/nvme10n1

Created p1=/dev/nvme10n1p1 p2=/dev/nvme10n1p2

Processing: /dev/nvme11n1

Created p1=/dev/nvme11n1p1 p2=/dev/nvme11n1p2

Processing: /dev/nvme1n1

Created p1=/dev/nvme1n1p1 p2=/dev/nvme1n1p2

Processing: /dev/nvme2n1

Created p1=/dev/nvme2n1p1 p2=/dev/nvme2n1p2

Processing: /dev/nvme3n1

Created p1=/dev/nvme3n1p1 p2=/dev/nvme3n1p2

Processing: /dev/nvme4n1

Created p1=/dev/nvme4n1p1 p2=/dev/nvme4n1p2

Processing: /dev/nvme6n1

Created p1=/dev/nvme6n1p1 p2=/dev/nvme6n1p2

Processing: /dev/nvme7n1

Created p1=/dev/nvme7n1p1 p2=/dev/nvme7n1p2

Processing: /dev/nvme8n1

Created p1=/dev/nvme8n1p1 p2=/dev/nvme8n1p2

Processing: /dev/nvme9n1

Created p1=/dev/nvme9n1p1 p2=/dev/nvme9n1p2

===== Step 2: bind UUID and prepare mount points =====

script: /root/plug-unplug-safe/UUID-safe.sh

Running mount -a to verify /etc/fstab...

===== Step 3: collect start logs =====

script: /root/plug-unplug-safe/2-check-start-safe.sh

Disk /dev/nvme6n1：1.75 TiB，1920383410176 字节，3750748848 个扇区

磁盘型号：HWE6AP441T9L00KN

单元：扇区 / 1 \* 512 = 512 字节

扇区大小(逻辑/物理)：512 字节 / 512 字节

I/O 大小(最小/最佳)：131072 字节 / 131072 字节

磁盘标签类型：gpt

磁盘标识符：96BD8620-41BB-4258-91E3-4F4420FC2FCB

设备 起点 末尾 扇区 大小 类型

/dev/nvme6n1p1 2048 19531775 19529728 9.3G Linux 文件系统

/dev/nvme6n1p2 19531776 3750748159 3731216384 1.7T Linux 文件系统

Disk /dev/nvme9n1：1.75 TiB，1920383410176 字节，3750748848 个扇区

磁盘型号：HWE6AP441T9L00KN

单元：扇区 / 1 \* 512 = 512 字节

扇区大小(逻辑/物理)：512 字节 / 512 字节

I/O 大小(最小/最佳)：131072 字节 / 131072 字节

磁盘标签类型：gpt

磁盘标识符：65F4884B-7BAB-4DBB-8E54-4E5E9458E268

设备 起点 末尾 扇区 大小 类型

/dev/nvme9n1p1 2048 19531775 19529728 9.3G Linux 文件系统

/dev/nvme9n1p2 19531776 3750748159 3731216384 1.7T Linux 文件系统

Disk /dev/nvme5n1：1.75 TiB，1920383410176 字节，3750748848 个扇区

磁盘型号：HWE6AP441T9L00KN

单元：扇区 / 1 \* 512 = 512 字节

扇区大小(逻辑/物理)：512 字节 / 512 字节

I/O 大小(最小/最佳)：131072 字节 / 131072 字节

磁盘标签类型：gpt

磁盘标识符：1120011E-1A16-462F-B106-96D89D4747B4

设备 起点 末尾 扇区 大小 类型

/dev/nvme5n1p1 2048 1230847 1228800 600M EFI 系统

/dev/nvme5n1p2 1230848 3327999 2097152 1G Linux 文件系统

/dev/nvme5n1p3 3328000 3750748159 3747420160 1.7T Linux LVM

Disk /dev/nvme2n1：1.75 TiB，1920383410176 字节，3750748848 个扇区

磁盘型号：HWE6AP441T9L00KN

单元：扇区 / 1 \* 512 = 512 字节

扇区大小(逻辑/物理)：512 字节 / 512 字节

I/O 大小(最小/最佳)：131072 字节 / 131072 字节

磁盘标签类型：gpt

磁盘标识符：82162E27-E694-4A27-84AF-2C895AC98025

设备 起点 末尾 扇区 大小 类型

/dev/nvme2n1p1 2048 19531775 19529728 9.3G Linux 文件系统

/dev/nvme2n1p2 19531776 3750748159 3731216384 1.7T Linux 文件系统

Disk /dev/nvme11n1：1.75 TiB，1920383410176 字节，3750748848 个扇区

磁盘型号：HWE6AP441T9L00KN

单元：扇区 / 1 \* 512 = 512 字节

扇区大小(逻辑/物理)：512 字节 / 512 字节

I/O 大小(最小/最佳)：131072 字节 / 131072 字节

磁盘标签类型：gpt

磁盘标识符：3E67664D-A6E0-44EE-BB3C-65F3FB7BA310

设备 起点 末尾 扇区 大小 类型

/dev/nvme11n1p1 2048 19531775 19529728 9.3G Linux 文件系统

/dev/nvme11n1p2 19531776 3750748159 3731216384 1.7T Linux 文件系统

Disk /dev/nvme1n1：1.75 TiB，1920383410176 字节，3750748848 个扇区

磁盘型号：HWE6AP441T9L00KN

单元：扇区 / 1 \* 512 = 512 字节

扇区大小(逻辑/物理)：512 字节 / 512 字节

I/O 大小(最小/最佳)：131072 字节 / 131072 字节

磁盘标签类型：gpt

磁盘标识符：B094D47A-D5D2-4D09-843E-9E4F7B002A27

设备 起点 末尾 扇区 大小 类型

/dev/nvme1n1p1 2048 19531775 19529728 9.3G Linux 文件系统

/dev/nvme1n1p2 19531776 3750748159 3731216384 1.7T Linux 文件系统

Disk /dev/nvme10n1：1.75 TiB，1920383410176 字节，3750748848 个扇区

磁盘型号：HWE6AP441T9L00KN

单元：扇区 / 1 \* 512 = 512 字节

扇区大小(逻辑/物理)：512 字节 / 512 字节

I/O 大小(最小/最佳)：131072 字节 / 131072 字节

磁盘标签类型：gpt

磁盘标识符：1943F6DA-DE83-4DC1-AEC7-C1887D8B2F76

设备 起点 末尾 扇区 大小 类型

/dev/nvme10n1p1 2048 19531775 19529728 9.3G Linux 文件系统

/dev/nvme10n1p2 19531776 3750748159 3731216384 1.7T Linux 文件系统

Disk /dev/nvme3n1：1.75 TiB，1920383410176 字节，3750748848 个扇区

磁盘型号：HWE6AP441T9L00KN

单元：扇区 / 1 \* 512 = 512 字节

扇区大小(逻辑/物理)：512 字节 / 512 字节

I/O 大小(最小/最佳)：131072 字节 / 131072 字节

磁盘标签类型：gpt

磁盘标识符：3D956BE8-0B87-47D1-82C8-E7040870099B

设备 起点 末尾 扇区 大小 类型

/dev/nvme3n1p1 2048 19531775 19529728 9.3G Linux 文件系统

/dev/nvme3n1p2 19531776 3750748159 3731216384 1.7T Linux 文件系统

Disk /dev/nvme4n1：1.75 TiB，1920383410176 字节，3750748848 个扇区

磁盘型号：HWE6AP441T9L00KN

单元：扇区 / 1 \* 512 = 512 字节

扇区大小(逻辑/物理)：512 字节 / 512 字节

I/O 大小(最小/最佳)：131072 字节 / 131072 字节

磁盘标签类型：gpt

磁盘标识符：5CE20744-B912-4BB3-8E3C-52215BD554B2

设备 起点 末尾 扇区 大小 类型

/dev/nvme4n1p1 2048 19531775 19529728 9.3G Linux 文件系统

/dev/nvme4n1p2 19531776 3750748159 3731216384 1.7T Linux 文件系统

Disk /dev/nvme0n1：1.75 TiB，1920383410176 字节，3750748848 个扇区

磁盘型号：HWE6AP441T9L00KN

单元：扇区 / 1 \* 512 = 512 字节

扇区大小(逻辑/物理)：512 字节 / 512 字节

I/O 大小(最小/最佳)：131072 字节 / 131072 字节

磁盘标签类型：gpt

磁盘标识符：FEE4D73D-4813-4662-9E0F-F0235C240DDE

设备 起点 末尾 扇区 大小 类型

/dev/nvme0n1p1 2048 19531775 19529728 9.3G Linux 文件系统

/dev/nvme0n1p2 19531776 3750748159 3731216384 1.7T Linux 文件系统

Disk /dev/nvme7n1：1.75 TiB，1920383410176 字节，3750748848 个扇区

磁盘型号：HWE6AP441T9L00KN

单元：扇区 / 1 \* 512 = 512 字节

扇区大小(逻辑/物理)：512 字节 / 512 字节

I/O 大小(最小/最佳)：131072 字节 / 131072 字节

磁盘标签类型：gpt

磁盘标识符：DB7C04D7-D55C-47E0-BA03-2B94EE221F8D

设备 起点 末尾 扇区 大小 类型

/dev/nvme7n1p1 2048 19531775 19529728 9.3G Linux 文件系统

/dev/nvme7n1p2 19531776 3750748159 3731216384 1.7T Linux 文件系统

Disk /dev/nvme8n1：1.75 TiB，1920383410176 字节，3750748848 个扇区

磁盘型号：HWE6AP441T9L00KN

单元：扇区 / 1 \* 512 = 512 字节

扇区大小(逻辑/物理)：512 字节 / 512 字节

I/O 大小(最小/最佳)：131072 字节 / 131072 字节

磁盘标签类型：gpt

磁盘标识符：74422943-FE8A-447E-9655-7F08DC992AF0

设备 起点 末尾 扇区 大小 类型

/dev/nvme8n1p1 2048 19531775 19529728 9.3G Linux 文件系统

/dev/nvme8n1p2 19531776 3750748159 3731216384 1.7T Linux 文件系统

Disk /dev/mapper/openeuler-root：70 GiB，75161927680 字节，146800640 个扇区

单元：扇区 / 1 \* 512 = 512 字节

扇区大小(逻辑/物理)：512 字节 / 512 字节

I/O 大小(最小/最佳)：131072 字节 / 131072 字节

Disk /dev/mapper/openeuler-swap：4 GiB，4294967296 字节，8388608 个扇区

单元：扇区 / 1 \* 512 = 512 字节

扇区大小(逻辑/物理)：512 字节 / 512 字节

I/O 大小(最小/最佳)：131072 字节 / 131072 字节

Disk /dev/mapper/openeuler-home：1.67 TiB，1839219081216 字节，3592224768 个扇区

单元：扇区 / 1 \* 512 = 512 字节

扇区大小(逻辑/物理)：512 字节 / 512 字节

I/O 大小(最小/最佳)：131072 字节 / 131072 字节

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===

Model Number: HWE6AP441T9L00KN

Serial Number: 034XESZERC000419

Firmware Version: 2020

PCI Vendor/Subsystem ID: 0x19e5

IEEE OUI Identifier: 0x18e91d

Total NVM Capacity: 1,920,383,410,176 \[1.92 TB\]

Unallocated NVM Capacity: 0

Controller ID: 1

NVMe Version: 1.4

Number of Namespaces: 128

Namespace 1 Size/Capacity: 1,920,383,410,176 \[1.92 TB\]

Namespace 1 Formatted LBA Size: 512

Namespace 1 IEEE EUI-64: 18e91d 019fe9e000

Local Time is: Fri Apr 10 10:09:48 2026 CST

Firmware Updates (0x14): 2 Slots, no Reset required

Optional Admin Commands (0x023e): Format Frmw_DL NS_Mngmt Self_Test Directvs Get_LBA \_Sts

Optional NVM Commands (0x0056): Wr_Unc DS_Mngmt Sav/Sel_Feat Timestmp

Log Page Attributes (0x0e): Cmd_Eff_Lg Ext_Get_Lg Telmtry_Lg

Maximum Data Transfer Size: 32 Pages

Warning Comp. Temp. Threshold: 83 Celsius

Critical Comp. Temp. Threshold: 85 Celsius

Namespace 1 Features (0x10): NP_Fields

Supported Power States

St Op Max Active Idle RL RT WL WT Ent_Lat Ex_Lat

0 + 25.00W - - 0 0 0 0 0 0

1 + 23.00W - - 1 1 1 1 0 0

2 + 21.00W - - 2 2 2 2 0 0

3 + 20.00W - - 3 3 3 3 0 0

4 + 18.00W - - 4 4 4 4 0 0

5 + 16.00W - - 5 5 5 5 0 0

6 + 14.00W - - 6 6 6 6 0 0

7 + 12.00W - - 7 7 7 7 0 0

Supported LBA Sizes (NSID 0x1)

Id Fmt Data Metadt Rel_Perf

0 - 512 0 0

1 - 512 8 1

2 - 4096 64 1

3 - 4096 0 0

4 - 4096 8 1

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

SMART/Health Information (NVMe Log 0x02)

Critical Warning: 0x00

Temperature: 46 Celsius

Available Spare: 100%

Available Spare Threshold: 10%

Percentage Used: 0%

Data Units Read: 28,796,653 \[14.7 TB\]

Data Units Written: 12,157,946 \[6.22 TB\]

Host Read Commands: 3,401,407,976

Host Write Commands: 1,447,929,788

Controller Busy Time: 728

Power Cycles: 538

Power On Hours: 246

Unsafe Shutdowns: 531

Media and Data Integrity Errors: 0

Error Information Log Entries: 0

Warning Comp. Temperature Time: 0

Critical Comp. Temperature Time: 0

Temperature Sensor 1: 50 Celsius

Error Information (NVMe Log 0x01, 16 of 64 entries)

No Errors Logged

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===

Model Number: HWE6AP441T9L00KN

Serial Number: 034XESZERC000235

Firmware Version: 2020

PCI Vendor/Subsystem ID: 0x19e5

IEEE OUI Identifier: 0x18e91d

Total NVM Capacity: 1,920,383,410,176 \[1.92 TB\]

Unallocated NVM Capacity: 0

Controller ID: 1

NVMe Version: 1.4

Number of Namespaces: 128

Namespace 1 Size/Capacity: 1,920,383,410,176 \[1.92 TB\]

Namespace 1 Formatted LBA Size: 512

Namespace 1 IEEE EUI-64: 18e91d 01a01e2000

Local Time is: Fri Apr 10 10:09:48 2026 CST

Firmware Updates (0x14): 2 Slots, no Reset required

Optional Admin Commands (0x023e): Format Frmw_DL NS_Mngmt Self_Test Directvs Get_LBA \_Sts

Optional NVM Commands (0x0056): Wr_Unc DS_Mngmt Sav/Sel_Feat Timestmp

Log Page Attributes (0x0e): Cmd_Eff_Lg Ext_Get_Lg Telmtry_Lg

Maximum Data Transfer Size: 32 Pages

Warning Comp. Temp. Threshold: 83 Celsius

Critical Comp. Temp. Threshold: 85 Celsius

Namespace 1 Features (0x10): NP_Fields

Supported Power States

St Op Max Active Idle RL RT WL WT Ent_Lat Ex_Lat

0 + 25.00W - - 0 0 0 0 0 0

1 + 23.00W - - 1 1 1 1 0 0

2 + 21.00W - - 2 2 2 2 0 0

3 + 20.00W - - 3 3 3 3 0 0

4 + 18.00W - - 4 4 4 4 0 0

5 + 16.00W - - 5 5 5 5 0 0

6 + 14.00W - - 6 6 6 6 0 0

7 + 12.00W - - 7 7 7 7 0 0

Supported LBA Sizes (NSID 0x1)

Id Fmt Data Metadt Rel_Perf

0 - 512 0 0

1 - 512 8 1

2 - 4096 64 1

3 - 4096 0 0

4 - 4096 8 1

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

SMART/Health Information (NVMe Log 0x02)

Critical Warning: 0x00

Temperature: 51 Celsius

Available Spare: 100%

Available Spare Threshold: 10%

Percentage Used: 0%

Data Units Read: 678,994 \[347 GB\]

Data Units Written: 303,049 \[155 GB\]

Host Read Commands: 5,222,241

Host Write Commands: 2,268,901

Controller Busy Time: 2

Power Cycles: 537

Power On Hours: 246

Unsafe Shutdowns: 531

Media and Data Integrity Errors: 0

Error Information Log Entries: 0

Warning Comp. Temperature Time: 0

Critical Comp. Temperature Time: 0

Temperature Sensor 1: 53 Celsius

Error Information (NVMe Log 0x01, 16 of 64 entries)

No Errors Logged

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===

Model Number: HWE6AP441T9L00KN

Serial Number: 034XESZERC000474

Firmware Version: 2020

PCI Vendor/Subsystem ID: 0x19e5

IEEE OUI Identifier: 0x18e91d

Total NVM Capacity: 1,920,383,410,176 \[1.92 TB\]

Unallocated NVM Capacity: 0

Controller ID: 1

NVMe Version: 1.4

Number of Namespaces: 128

Namespace 1 Size/Capacity: 1,920,383,410,176 \[1.92 TB\]

Namespace 1 Formatted LBA Size: 512

Namespace 1 IEEE EUI-64: 18e91d 019ffa9000

Local Time is: Fri Apr 10 10:09:48 2026 CST

Firmware Updates (0x14): 2 Slots, no Reset required

Optional Admin Commands (0x023e): Format Frmw_DL NS_Mngmt Self_Test Directvs Get_LBA \_Sts

Optional NVM Commands (0x0056): Wr_Unc DS_Mngmt Sav/Sel_Feat Timestmp

Log Page Attributes (0x0e): Cmd_Eff_Lg Ext_Get_Lg Telmtry_Lg

Maximum Data Transfer Size: 32 Pages

Warning Comp. Temp. Threshold: 83 Celsius

Critical Comp. Temp. Threshold: 85 Celsius

Namespace 1 Features (0x10): NP_Fields

Supported Power States

St Op Max Active Idle RL RT WL WT Ent_Lat Ex_Lat

0 + 25.00W - - 0 0 0 0 0 0

1 + 23.00W - - 1 1 1 1 0 0

2 + 21.00W - - 2 2 2 2 0 0

3 + 20.00W - - 3 3 3 3 0 0

4 + 18.00W - - 4 4 4 4 0 0

5 + 16.00W - - 5 5 5 5 0 0

6 + 14.00W - - 6 6 6 6 0 0

7 + 12.00W - - 7 7 7 7 0 0

Supported LBA Sizes (NSID 0x1)

Id Fmt Data Metadt Rel_Perf

0 - 512 0 0

1 - 512 8 1

2 - 4096 64 1

3 - 4096 0 0

4 - 4096 8 1

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

SMART/Health Information (NVMe Log 0x02)

Critical Warning: 0x00

Temperature: 48 Celsius

Available Spare: 100%

Available Spare Threshold: 10%

Percentage Used: 0%

Data Units Read: 679,804 \[348 GB\]

Data Units Written: 303,654 \[155 GB\]

Host Read Commands: 5,214,106

Host Write Commands: 2,266,402

Controller Busy Time: 2

Power Cycles: 538

Power On Hours: 246

Unsafe Shutdowns: 533

Media and Data Integrity Errors: 0

Error Information Log Entries: 0

Warning Comp. Temperature Time: 0

Critical Comp. Temperature Time: 0

Temperature Sensor 1: 50 Celsius

Error Information (NVMe Log 0x01, 16 of 64 entries)

No Errors Logged

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===

Model Number: HWE6AP441T9L00KN

Serial Number: 034XESZERC000508

Firmware Version: 2020

PCI Vendor/Subsystem ID: 0x19e5

IEEE OUI Identifier: 0x18e91d

Total NVM Capacity: 1,920,383,410,176 \[1.92 TB\]

Unallocated NVM Capacity: 0

Controller ID: 1

NVMe Version: 1.4

Number of Namespaces: 128

Namespace 1 Size/Capacity: 1,920,383,410,176 \[1.92 TB\]

Namespace 1 Formatted LBA Size: 512

Namespace 1 IEEE EUI-64: 18e91d 019fff6000

Local Time is: Fri Apr 10 10:09:48 2026 CST

Firmware Updates (0x14): 2 Slots, no Reset required

Optional Admin Commands (0x023e): Format Frmw_DL NS_Mngmt Self_Test Directvs Get_LBA \_Sts

Optional NVM Commands (0x0056): Wr_Unc DS_Mngmt Sav/Sel_Feat Timestmp

Log Page Attributes (0x0e): Cmd_Eff_Lg Ext_Get_Lg Telmtry_Lg

Maximum Data Transfer Size: 32 Pages

Warning Comp. Temp. Threshold: 83 Celsius

Critical Comp. Temp. Threshold: 85 Celsius

Namespace 1 Features (0x10): NP_Fields

Supported Power States

St Op Max Active Idle RL RT WL WT Ent_Lat Ex_Lat

0 + 25.00W - - 0 0 0 0 0 0

1 + 23.00W - - 1 1 1 1 0 0

2 + 21.00W - - 2 2 2 2 0 0

3 + 20.00W - - 3 3 3 3 0 0

4 + 18.00W - - 4 4 4 4 0 0

5 + 16.00W - - 5 5 5 5 0 0

6 + 14.00W - - 6 6 6 6 0 0

7 + 12.00W - - 7 7 7 7 0 0

Supported LBA Sizes (NSID 0x1)

Id Fmt Data Metadt Rel_Perf

0 - 512 0 0

1 - 512 8 1

2 - 4096 64 1

3 - 4096 0 0

4 - 4096 8 1

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

SMART/Health Information (NVMe Log 0x02)

Critical Warning: 0x00

Temperature: 51 Celsius

Available Spare: 100%

Available Spare Threshold: 10%

Percentage Used: 0%

Data Units Read: 756,918 \[387 GB\]

Data Units Written: 327,566 \[167 GB\]

Host Read Commands: 11,942,581

Host Write Commands: 5,114,175

Controller Busy Time: 3

Power Cycles: 537

Power On Hours: 246

Unsafe Shutdowns: 531

Media and Data Integrity Errors: 0

Error Information Log Entries: 0

Warning Comp. Temperature Time: 0

Critical Comp. Temperature Time: 0

Temperature Sensor 1: 55 Celsius

Error Information (NVMe Log 0x01, 16 of 64 entries)

No Errors Logged

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===

Model Number: HWE6AP441T9L00KN

Serial Number: 034XESZERC000354

Firmware Version: 2020

PCI Vendor/Subsystem ID: 0x19e5

IEEE OUI Identifier: 0x18e91d

Total NVM Capacity: 1,920,383,410,176 \[1.92 TB\]

Unallocated NVM Capacity: 0

Controller ID: 1

NVMe Version: 1.4

Number of Namespaces: 128

Namespace 1 Size/Capacity: 1,920,383,410,176 \[1.92 TB\]

Namespace 1 Formatted LBA Size: 512

Namespace 1 IEEE EUI-64: 18e91d 019ff54000

Local Time is: Fri Apr 10 10:09:48 2026 CST

Firmware Updates (0x14): 2 Slots, no Reset required

Optional Admin Commands (0x023e): Format Frmw_DL NS_Mngmt Self_Test Directvs Get_LBA \_Sts

Optional NVM Commands (0x0056): Wr_Unc DS_Mngmt Sav/Sel_Feat Timestmp

Log Page Attributes (0x0e): Cmd_Eff_Lg Ext_Get_Lg Telmtry_Lg

Maximum Data Transfer Size: 32 Pages

Warning Comp. Temp. Threshold: 83 Celsius

Critical Comp. Temp. Threshold: 85 Celsius

Namespace 1 Features (0x10): NP_Fields

Supported Power States

St Op Max Active Idle RL RT WL WT Ent_Lat Ex_Lat

0 + 25.00W - - 0 0 0 0 0 0

1 + 23.00W - - 1 1 1 1 0 0

2 + 21.00W - - 2 2 2 2 0 0

3 + 20.00W - - 3 3 3 3 0 0

4 + 18.00W - - 4 4 4 4 0 0

5 + 16.00W - - 5 5 5 5 0 0

6 + 14.00W - - 6 6 6 6 0 0

7 + 12.00W - - 7 7 7 7 0 0

Supported LBA Sizes (NSID 0x1)

Id Fmt Data Metadt Rel_Perf

0 - 512 0 0

1 - 512 8 1

2 - 4096 64 1

3 - 4096 0 0

4 - 4096 8 1

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

SMART/Health Information (NVMe Log 0x02)

Critical Warning: 0x00

Temperature: 37 Celsius

Available Spare: 100%

Available Spare Threshold: 10%

Percentage Used: 0%

Data Units Read: 1,360,873 \[696 GB\]

Data Units Written: 966,854 \[495 GB\]

Host Read Commands: 7,975,975

Host Write Commands: 4,899,375

Controller Busy Time: 6

Power Cycles: 540

Power On Hours: 246

Unsafe Shutdowns: 534

Media and Data Integrity Errors: 0

Error Information Log Entries: 0

Warning Comp. Temperature Time: 0

Critical Comp. Temperature Time: 0

Temperature Sensor 1: 40 Celsius

Error Information (NVMe Log 0x01, 16 of 64 entries)

No Errors Logged

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===

Model Number: HWE6AP441T9L00KN

Serial Number: 034XESZERC000041

Firmware Version: 2020

PCI Vendor/Subsystem ID: 0x19e5

IEEE OUI Identifier: 0x18e91d

Total NVM Capacity: 1,920,383,410,176 \[1.92 TB\]

Unallocated NVM Capacity: 0

Controller ID: 1

NVMe Version: 1.4

Number of Namespaces: 128

Namespace 1 Size/Capacity: 1,920,383,410,176 \[1.92 TB\]

Namespace 1 Formatted LBA Size: 512

Namespace 1 IEEE EUI-64: 18e91d 01a0070000

Local Time is: Fri Apr 10 10:09:48 2026 CST

Firmware Updates (0x14): 2 Slots, no Reset required

Optional Admin Commands (0x023e): Format Frmw_DL NS_Mngmt Self_Test Directvs Get_LBA \_Sts

Optional NVM Commands (0x0056): Wr_Unc DS_Mngmt Sav/Sel_Feat Timestmp

Log Page Attributes (0x0e): Cmd_Eff_Lg Ext_Get_Lg Telmtry_Lg

Maximum Data Transfer Size: 32 Pages

Warning Comp. Temp. Threshold: 83 Celsius

Critical Comp. Temp. Threshold: 85 Celsius

Namespace 1 Features (0x10): NP_Fields

Supported Power States

St Op Max Active Idle RL RT WL WT Ent_Lat Ex_Lat

0 + 25.00W - - 0 0 0 0 0 0

1 + 23.00W - - 1 1 1 1 0 0

2 + 21.00W - - 2 2 2 2 0 0

3 + 20.00W - - 3 3 3 3 0 0

4 + 18.00W - - 4 4 4 4 0 0

5 + 16.00W - - 5 5 5 5 0 0

6 + 14.00W - - 6 6 6 6 0 0

7 + 12.00W - - 7 7 7 7 0 0

Supported LBA Sizes (NSID 0x1)

Id Fmt Data Metadt Rel_Perf

0 - 512 0 0

1 - 512 8 1

2 - 4096 64 1

3 - 4096 0 0

4 - 4096 8 1

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

SMART/Health Information (NVMe Log 0x02)

Critical Warning: 0x00

Temperature: 46 Celsius

Available Spare: 100%

Available Spare Threshold: 10%

Percentage Used: 0%

Data Units Read: 2,148,700 \[1.10 TB\]

Data Units Written: 1,754,459 \[898 GB\]

Host Read Commands: 11,172,718

Host Write Commands: 8,027,291

Controller Busy Time: 14

Power Cycles: 538

Power On Hours: 245

Unsafe Shutdowns: 532

Media and Data Integrity Errors: 0

Error Information Log Entries: 0

Warning Comp. Temperature Time: 0

Critical Comp. Temperature Time: 0

Temperature Sensor 1: 49 Celsius

Error Information (NVMe Log 0x01, 16 of 64 entries)

No Errors Logged

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===

Model Number: HWE6AP441T9L00KN

Serial Number: 034XESD9R6000101

Firmware Version: 1073

PCI Vendor/Subsystem ID: 0x19e5

IEEE OUI Identifier: 0xf828c9

Total NVM Capacity: 1,920,383,410,176 \[1.92 TB\]

Unallocated NVM Capacity: 0

Controller ID: 1

NVMe Version: 1.4

Number of Namespaces: 128

Namespace 1 Size/Capacity: 1,920,383,410,176 \[1.92 TB\]

Namespace 1 Formatted LBA Size: 512

Namespace 1 IEEE EUI-64: f828c9 01147c2000

Local Time is: Fri Apr 10 10:09:48 2026 CST

Firmware Updates (0x14): 2 Slots, no Reset required

Optional Admin Commands (0x023e): Format Frmw_DL NS_Mngmt Self_Test Directvs Get_LBA \_Sts

Optional NVM Commands (0x0056): Wr_Unc DS_Mngmt Sav/Sel_Feat Timestmp

Log Page Attributes (0x0e): Cmd_Eff_Lg Ext_Get_Lg Telmtry_Lg

Maximum Data Transfer Size: 32 Pages

Warning Comp. Temp. Threshold: 83 Celsius

Critical Comp. Temp. Threshold: 85 Celsius

Namespace 1 Features (0x10): NP_Fields

Supported Power States

St Op Max Active Idle RL RT WL WT Ent_Lat Ex_Lat

0 + 25.00W - - 0 0 0 0 0 0

1 + 23.00W - - 1 1 1 1 0 0

2 + 21.00W - - 2 2 2 2 0 0

3 + 20.00W - - 3 3 3 3 0 0

4 + 18.00W - - 4 4 4 4 0 0

5 + 16.00W - - 5 5 5 5 0 0

6 + 14.00W - - 6 6 6 6 0 0

7 + 12.00W - - 7 7 7 7 0 0

Supported LBA Sizes (NSID 0x1)

Id Fmt Data Metadt Rel_Perf

0 - 512 0 0

1 - 512 8 1

2 - 4096 64 1

3 - 4096 0 0

4 - 4096 8 1

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

SMART/Health Information (NVMe Log 0x02)

Critical Warning: 0x00

Temperature: 43 Celsius

Available Spare: 100%

Available Spare Threshold: 10%

Percentage Used: 0%

Data Units Read: 232,201,398 \[118 TB\]

Data Units Written: 133,983,589 \[68.5 TB\]

Host Read Commands: 11,250,265,272

Host Write Commands: 8,283,531,906

Controller Busy Time: 990

Power Cycles: 1,298

Power On Hours: 1,018

Unsafe Shutdowns: 969

Media and Data Integrity Errors: 0

Error Information Log Entries: 0

Warning Comp. Temperature Time: 0

Critical Comp. Temperature Time: 0

Temperature Sensor 1: 46 Celsius

Error Information (NVMe Log 0x01, 16 of 64 entries)

No Errors Logged

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===

Model Number: HWE6AP441T9L00KN

Serial Number: 034XESZERC000485

Firmware Version: 2020

PCI Vendor/Subsystem ID: 0x19e5

IEEE OUI Identifier: 0x18e91d

Total NVM Capacity: 1,920,383,410,176 \[1.92 TB\]

Unallocated NVM Capacity: 0

Controller ID: 1

NVMe Version: 1.4

Number of Namespaces: 128

Namespace 1 Size/Capacity: 1,920,383,410,176 \[1.92 TB\]

Namespace 1 Formatted LBA Size: 512

Namespace 1 IEEE EUI-64: 18e91d 019fe5b000

Local Time is: Fri Apr 10 10:09:48 2026 CST

Firmware Updates (0x14): 2 Slots, no Reset required

Optional Admin Commands (0x023e): Format Frmw_DL NS_Mngmt Self_Test Directvs Get_LBA \_Sts

Optional NVM Commands (0x0056): Wr_Unc DS_Mngmt Sav/Sel_Feat Timestmp

Log Page Attributes (0x0e): Cmd_Eff_Lg Ext_Get_Lg Telmtry_Lg

Maximum Data Transfer Size: 32 Pages

Warning Comp. Temp. Threshold: 83 Celsius

Critical Comp. Temp. Threshold: 85 Celsius

Namespace 1 Features (0x10): NP_Fields

Supported Power States

St Op Max Active Idle RL RT WL WT Ent_Lat Ex_Lat

0 + 25.00W - - 0 0 0 0 0 0

1 + 23.00W - - 1 1 1 1 0 0

2 + 21.00W - - 2 2 2 2 0 0

3 + 20.00W - - 3 3 3 3 0 0

4 + 18.00W - - 4 4 4 4 0 0

5 + 16.00W - - 5 5 5 5 0 0

6 + 14.00W - - 6 6 6 6 0 0

7 + 12.00W - - 7 7 7 7 0 0

Supported LBA Sizes (NSID 0x1)

Id Fmt Data Metadt Rel_Perf

0 - 512 0 0

1 - 512 8 1

2 - 4096 64 1

3 - 4096 0 0

4 - 4096 8 1

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

SMART/Health Information (NVMe Log 0x02)

Critical Warning: 0x00

Temperature: 45 Celsius

Available Spare: 100%

Available Spare Threshold: 10%

Percentage Used: 0%

Data Units Read: 1,066,253 \[545 GB\]

Data Units Written: 609,738 \[312 GB\]

Host Read Commands: 15,204,578

Host Write Commands: 4,573,539

Controller Busy Time: 5

Power Cycles: 536

Power On Hours: 246

Unsafe Shutdowns: 531

Media and Data Integrity Errors: 0

Error Information Log Entries: 0

Warning Comp. Temperature Time: 0

Critical Comp. Temperature Time: 0

Temperature Sensor 1: 49 Celsius

Error Information (NVMe Log 0x01, 16 of 64 entries)

No Errors Logged

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===

Model Number: HWE6AP441T9L00KN

Serial Number: 034XESZERB003970

Firmware Version: 2020

PCI Vendor/Subsystem ID: 0x19e5

IEEE OUI Identifier: 0x74342b

Total NVM Capacity: 1,920,383,410,176 \[1.92 TB\]

Unallocated NVM Capacity: 0

Controller ID: 1

NVMe Version: 1.4

Number of Namespaces: 128

Namespace 1 Size/Capacity: 1,920,383,410,176 \[1.92 TB\]

Namespace 1 Formatted LBA Size: 512

Namespace 1 IEEE EUI-64: 74342b 01f4723000

Local Time is: Fri Apr 10 10:09:48 2026 CST

Firmware Updates (0x14): 2 Slots, no Reset required

Optional Admin Commands (0x023e): Format Frmw_DL NS_Mngmt Self_Test Directvs Get_LBA \_Sts

Optional NVM Commands (0x0056): Wr_Unc DS_Mngmt Sav/Sel_Feat Timestmp

Log Page Attributes (0x0e): Cmd_Eff_Lg Ext_Get_Lg Telmtry_Lg

Maximum Data Transfer Size: 32 Pages

Warning Comp. Temp. Threshold: 83 Celsius

Critical Comp. Temp. Threshold: 85 Celsius

Namespace 1 Features (0x10): NP_Fields

Supported Power States

St Op Max Active Idle RL RT WL WT Ent_Lat Ex_Lat

0 + 25.00W - - 0 0 0 0 0 0

1 + 23.00W - - 1 1 1 1 0 0

2 + 21.00W - - 2 2 2 2 0 0

3 + 20.00W - - 3 3 3 3 0 0

4 + 18.00W - - 4 4 4 4 0 0

5 + 16.00W - - 5 5 5 5 0 0

6 + 14.00W - - 6 6 6 6 0 0

7 + 12.00W - - 7 7 7 7 0 0

Supported LBA Sizes (NSID 0x1)

Id Fmt Data Metadt Rel_Perf

0 - 512 0 0

1 - 512 8 1

2 - 4096 64 1

3 - 4096 0 0

4 - 4096 8 1

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

SMART/Health Information (NVMe Log 0x02)

Critical Warning: 0x00

Temperature: 46 Celsius

Available Spare: 100%

Available Spare Threshold: 10%

Percentage Used: 0%

Data Units Read: 1,000,229 \[512 GB\]

Data Units Written: 303,986 \[155 GB\]

Host Read Commands: 7,259,261

Host Write Commands: 2,206,957

Controller Busy Time: 3

Power Cycles: 536

Power On Hours: 247

Unsafe Shutdowns: 531

Media and Data Integrity Errors: 0

Error Information Log Entries: 0

Warning Comp. Temperature Time: 0

Critical Comp. Temperature Time: 0

Temperature Sensor 1: 48 Celsius

Error Information (NVMe Log 0x01, 16 of 64 entries)

No Errors Logged

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===

Model Number: HWE6AP441T9L00KN

Serial Number: 034XESZERC000513

Firmware Version: 2020

PCI Vendor/Subsystem ID: 0x19e5

IEEE OUI Identifier: 0x18e91d

Total NVM Capacity: 1,920,383,410,176 \[1.92 TB\]

Unallocated NVM Capacity: 0

Controller ID: 1

NVMe Version: 1.4

Number of Namespaces: 128

Namespace 1 Size/Capacity: 1,920,383,410,176 \[1.92 TB\]

Namespace 1 Formatted LBA Size: 512

Namespace 1 IEEE EUI-64: 18e91d 019ffcd000

Local Time is: Fri Apr 10 10:09:48 2026 CST

Firmware Updates (0x14): 2 Slots, no Reset required

Optional Admin Commands (0x023e): Format Frmw_DL NS_Mngmt Self_Test Directvs Get_LBA \_Sts

Optional NVM Commands (0x0056): Wr_Unc DS_Mngmt Sav/Sel_Feat Timestmp

Log Page Attributes (0x0e): Cmd_Eff_Lg Ext_Get_Lg Telmtry_Lg

Maximum Data Transfer Size: 32 Pages

Warning Comp. Temp. Threshold: 83 Celsius

Critical Comp. Temp. Threshold: 85 Celsius

Namespace 1 Features (0x10): NP_Fields

Supported Power States

St Op Max Active Idle RL RT WL WT Ent_Lat Ex_Lat

0 + 25.00W - - 0 0 0 0 0 0

1 + 23.00W - - 1 1 1 1 0 0

2 + 21.00W - - 2 2 2 2 0 0

3 + 20.00W - - 3 3 3 3 0 0

4 + 18.00W - - 4 4 4 4 0 0

5 + 16.00W - - 5 5 5 5 0 0

6 + 14.00W - - 6 6 6 6 0 0

7 + 12.00W - - 7 7 7 7 0 0

Supported LBA Sizes (NSID 0x1)

Id Fmt Data Metadt Rel_Perf

0 - 512 0 0

1 - 512 8 1

2 - 4096 64 1

3 - 4096 0 0

4 - 4096 8 1

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

SMART/Health Information (NVMe Log 0x02)

Critical Warning: 0x00

Temperature: 44 Celsius

Available Spare: 100%

Available Spare Threshold: 10%

Percentage Used: 0%

Data Units Read: 683,905 \[350 GB\]

Data Units Written: 302,747 \[155 GB\]

Host Read Commands: 5,249,655

Host Write Commands: 2,270,463

Controller Busy Time: 2

Power Cycles: 538

Power On Hours: 246

Unsafe Shutdowns: 531

Media and Data Integrity Errors: 0

Error Information Log Entries: 0

Warning Comp. Temperature Time: 0

Critical Comp. Temperature Time: 0

Temperature Sensor 1: 46 Celsius

Error Information (NVMe Log 0x01, 16 of 64 entries)

No Errors Logged

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===

Model Number: HWE6AP441T9L00KN

Serial Number: 034XESD9R6000189

Firmware Version: 1073

PCI Vendor/Subsystem ID: 0x19e5

IEEE OUI Identifier: 0xf828c9

Total NVM Capacity: 1,920,383,410,176 \[1.92 TB\]

Unallocated NVM Capacity: 0

Controller ID: 1

NVMe Version: 1.4

Number of Namespaces: 128

Namespace 1 Size/Capacity: 1,920,383,410,176 \[1.92 TB\]

Namespace 1 Formatted LBA Size: 512

Namespace 1 IEEE EUI-64: f828c9 011481a000

Local Time is: Fri Apr 10 10:09:48 2026 CST

Firmware Updates (0x14): 2 Slots, no Reset required

Optional Admin Commands (0x023e): Format Frmw_DL NS_Mngmt Self_Test Directvs Get_LBA \_Sts

Optional NVM Commands (0x0056): Wr_Unc DS_Mngmt Sav/Sel_Feat Timestmp

Log Page Attributes (0x0e): Cmd_Eff_Lg Ext_Get_Lg Telmtry_Lg

Maximum Data Transfer Size: 32 Pages

Warning Comp. Temp. Threshold: 83 Celsius

Critical Comp. Temp. Threshold: 85 Celsius

Namespace 1 Features (0x10): NP_Fields

Supported Power States

St Op Max Active Idle RL RT WL WT Ent_Lat Ex_Lat

0 + 25.00W - - 0 0 0 0 0 0

1 + 23.00W - - 1 1 1 1 0 0

2 + 21.00W - - 2 2 2 2 0 0

3 + 20.00W - - 3 3 3 3 0 0

4 + 18.00W - - 4 4 4 4 0 0

5 + 16.00W - - 5 5 5 5 0 0

6 + 14.00W - - 6 6 6 6 0 0

7 + 12.00W - - 7 7 7 7 0 0

Supported LBA Sizes (NSID 0x1)

Id Fmt Data Metadt Rel_Perf

0 - 512 0 0

1 - 512 8 1

2 - 4096 64 1

3 - 4096 0 0

4 - 4096 8 1

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

SMART/Health Information (NVMe Log 0x02)

Critical Warning: 0x00

Temperature: 38 Celsius

Available Spare: 100%

Available Spare Threshold: 10%

Percentage Used: 0%

Data Units Read: 682,556 \[349 GB\]

Data Units Written: 302,412 \[154 GB\]

Host Read Commands: 5,289,013

Host Write Commands: 2,244,262

Controller Busy Time: 2

Power Cycles: 1,275

Power On Hours: 1,042

Unsafe Shutdowns: 980

Media and Data Integrity Errors: 0

Error Information Log Entries: 0

Warning Comp. Temperature Time: 0

Critical Comp. Temperature Time: 0

Temperature Sensor 1: 42 Celsius

Error Information (NVMe Log 0x01, 16 of 64 entries)

No Errors Logged

smartctl 7.2 2020-12-30 r5155 \[aarch64-linux-5.10.0-216.0.0.115.oe2203sp4.aarch64\] (lo cal build)

Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF SMART DATA SECTION ===

SMART overall-health self-assessment test result: PASSED

===== Step 4: create md5 source files and copy to p1 =====

script: /root/plug-unplug-safe/3-md5-safe.sh

文件系统 容量 已用 可用 已用% 挂载点

devtmpfs 4.0M 0 4.0M 0% /dev

tmpfs 1008G 0 1008G 0% /dev/shm

tmpfs 403G 38M 403G 1% /run

tmpfs 4.0M 0 4.0M 0% /sys/fs/cgroup

/dev/mapper/openeuler-root 69G 28G 37G 44% /

tmpfs 1008G 0 1008G 0% /tmp

/dev/nvme5n1p2 974M 154M 754M 17% /boot

/dev/nvme5n1p1 599M 6.5M 593M 2% /boot/efi

/dev/mapper/openeuler-home 1.7T 48K 1.6T 1% /home

/dev/nvme0n1p1 9.1G 24K 8.6G 1% /mnt/nvme0n1p1

/dev/nvme3n1p1 9.1G 24K 8.6G 1% /mnt/nvme3n1p1

/dev/nvme6n1p1 9.1G 24K 8.6G 1% /mnt/nvme6n1p1

/dev/nvme11n1p1 9.1G 24K 8.6G 1% /mnt/nvme11n1p1

/dev/nvme9n1p1 9.1G 24K 8.6G 1% /mnt/nvme9n1p1

/dev/nvme2n1p1 9.1G 24K 8.6G 1% /mnt/nvme2n1p1

/dev/nvme10n1p1 9.1G 24K 8.6G 1% /mnt/nvme10n1p1

/dev/nvme8n1p1 9.1G 24K 8.6G 1% /mnt/nvme8n1p1

/dev/nvme1n1p1 9.1G 24K 8.6G 1% /mnt/nvme1n1p1

/dev/nvme4n1p1 9.1G 24K 8.6G 1% /mnt/nvme4n1p1

/dev/nvme7n1p1 9.1G 24K 8.6G 1% /mnt/nvme7n1p1

记录了1000+0 的读入

记录了1000+0 的写出

1048576000字节（1.0 GB，1000 MiB）已复制，2.599 s，403 MB/s

b34e7c0d0b8b2b37ae7257c2f8acf56f ./md5/nvme0n1p1.bin

记录了1000+0 的读入

记录了1000+0 的写出

1048576000字节（1.0 GB，1000 MiB）已复制，2.60509 s，403 MB/s

7cadbf8511c448d035b549f32479b229 ./md5/nvme10n1p1.bin

记录了1000+0 的读入

记录了1000+0 的写出

1048576000字节（1.0 GB，1000 MiB）已复制，2.61179 s，401 MB/s

174cd67bc6f2e4d714c4d812c62b56ac ./md5/nvme11n1p1.bin

记录了1000+0 的读入

记录了1000+0 的写出

1048576000字节（1.0 GB，1000 MiB）已复制，2.59451 s，404 MB/s

6b2b5d34a43385b2a535bca64c0b6e72 ./md5/nvme1n1p1.bin

记录了1000+0 的读入

记录了1000+0 的写出

1048576000字节（1.0 GB，1000 MiB）已复制，2.59052 s，405 MB/s

72c72715739cc0d83661aed0f587a9cb ./md5/nvme2n1p1.bin

记录了1000+0 的读入

记录了1000+0 的写出

1048576000字节（1.0 GB，1000 MiB）已复制，2.59935 s，403 MB/s

b0c46024e8dd180207b513fd0161ddfa ./md5/nvme3n1p1.bin

记录了1000+0 的读入

记录了1000+0 的写出

1048576000字节（1.0 GB，1000 MiB）已复制，2.59574 s，404 MB/s

b4e2a02681e528ed30bb776f046a2988 ./md5/nvme4n1p1.bin

记录了1000+0 的读入

记录了1000+0 的写出

1048576000字节（1.0 GB，1000 MiB）已复制，2.60258 s，403 MB/s

e547d30270beca7795d06f9dadfb0fcd ./md5/nvme6n1p1.bin

记录了1000+0 的读入

记录了1000+0 的写出

1048576000字节（1.0 GB，1000 MiB）已复制，2.60676 s，402 MB/s

f20cfcf7500709d3f70f219f4ee33175 ./md5/nvme7n1p1.bin

记录了1000+0 的读入

记录了1000+0 的写出

1048576000字节（1.0 GB，1000 MiB）已复制，2.60937 s，402 MB/s

7c829e674a509c5cce063ae19c365f0a ./md5/nvme8n1p1.bin

记录了1000+0 的读入

记录了1000+0 的写出

1048576000字节（1.0 GB，1000 MiB）已复制，2.61016 s，402 MB/s

44421f57fa0631f13d059552736de054 ./md5/nvme9n1p1.bin

umount: /mnt/nvme5n1p1: 未挂载.

umount: /mnt/nvme_hotplug: 未挂载.

===== Step 5: start fio pressure on p2 =====

script: /root/plug-unplug-safe/fio-safe.sh

seq_mixed10: (g=0): rw=rw, bs=(R) 1024KiB-1024KiB, (W) 1024KiB-1024KiB, (T) 1024KiB-10 24KiB, ioengine=libaio, iodepth=1

fio-3.29

Starting 1 process

seq_mixed11: (g=0): rw=rw, bs=(R) 1024KiB-1024KiB, (W) 1024KiB-1024KiB, (T) 1024KiB-10 24KiB, ioengine=libaio, iodepth=1

fio-3.29

Starting 1 process

seq_mixed4: (g=0): rw=rw, bs=(R) 1024KiB-1024KiB, (W) 1024KiB-1024KiB, (T) 1024KiB-102 4KiB, ioengine=libaio, iodepth=1

fio-3.29

Starting 1 process

seq_mixed3: (g=0): rw=rw, bs=(R) 1024KiB-1024KiB, (W) 1024KiB-1024KiB, (T) 1024KiB-102 4KiB, ioengine=libaio, iodepth=1

fio-3.29

Starting 1 process

seq_mixed1: (g=0): rw=rw, bs=(R) 1024KiB-1024KiB, (W) 1024KiB-1024KiB, (T) 1024KiB-102 4KiB, ioengine=libaio, iodepth=1

fio-3.29

Starting 1 process

seq_mixed9: (g=0): rw=rw, bs=(R) 1024KiB-1024KiB, (W) 1024KiB-1024KiB, (T) 1024KiB-102 4KiB, ioengine=libaio, iodepth=1

fio-3.29

Starting 1 process

seq_mixed5: (g=0): rw=rw, bs=(R) 1024KiB-1024KiB, (W) 1024KiB-1024KiB, (T) 1024KiB-102 4KiB, ioengine=libaio, iodepth=1

fio-3.29

Starting 1 process

seq_mixed2: (g=0): rw=rw, bs=(R) 1024KiB-1024KiB, (W) 1024KiB-1024KiB, (T) 1024KiB-102 4KiB, ioengine=libaio, iodepth=1

fio-3.29

Starting 1 process

seq_mixed8: (g=0): rw=rw, bs=(R) 1024KiB-1024KiB, (W) 1024KiB-1024KiB, (T) 1024KiB-102 4KiB, ioengine=libaio, iodepth=1

fio-3.29

Starting 1 process

seq_mixed7: (g=0): rw=rw, bs=(R) 1024KiB-1024KiB, (W) 1024KiB-1024KiB, (T) 1024KiB-102 4KiB, ioengine=libaio, iodepth=1

fio-3.29

Starting 1 process

seq_mixed6: (g=0): rw=rw, bs=(R) 1024KiB-1024KiB, (W) 1024KiB-1024KiB, (T) 1024KiB-102 4KiB, ioengine=libaio, iodepth=1

fio-3.29

Starting 1 process

^\[\[B

seq_mixed1: (groupid=0, jobs=1): err= 0: pid=545906: Fri Apr 10 10:14:49 2026

read: IOPS=624, BW=624MiB/s (654MB/s)(36.6GiB/60001msec)

slat (usec): min=32, max=191, avg=41.29, stdev= 5.82

clat (usec): min=413, max=5801, avg=1083.43, stdev=606.08

lat (usec): min=454, max=5846, avg=1124.94, stdev=605.86

clat percentiles (usec):

\| 1.00th=\[ 490\], 5.00th=\[ 519\], 10.00th=\[ 537\], 20.00th=\[ 586\],

\| 30.00th=\[ 627\], 40.00th=\[ 685\], 50.00th=\[ 734\], 60.00th=\[ 873\],

\| 70.00th=\[ 1614\], 80.00th=\[ 1860\], 90.00th=\[ 1991\], 95.00th=\[ 2089\],

\| 99.00th=\[ 2278\], 99.50th=\[ 2343\], 99.90th=\[ 3654\], 99.95th=\[ 4752\],

\| 99.99th=\[ 5276\]

bw ( KiB/s): min=530432, max=768000, per=100.00%, avg=639440.67, stdev=62348.77, s amples=119

iops : min= 518, max= 750, avg=624.45, stdev=60.89, samples=119

write: IOPS=624, BW=624MiB/s (654MB/s)(36.6GiB/60001msec); 0 zone resets

slat (usec): min=28, max=120, avg=44.14, stdev= 7.19

clat (usec): min=334, max=678, avg=428.81, stdev=49.28

lat (usec): min=412, max=726, avg=473.18, stdev=52.76

clat percentiles (usec):

\| 1.00th=\[ 383\], 5.00th=\[ 388\], 10.00th=\[ 388\], 20.00th=\[ 388\],

\| 30.00th=\[ 388\], 40.00th=\[ 408\], 50.00th=\[ 412\], 60.00th=\[ 420\],

\| 70.00th=\[ 437\], 80.00th=\[ 478\], 90.00th=\[ 506\], 95.00th=\[ 515\],

\| 99.00th=\[ 594\], 99.50th=\[ 635\], 99.90th=\[ 660\], 99.95th=\[ 668\],

\| 99.99th=\[ 676\]

bw ( KiB/s): min=491520, max=765952, per=100.00%, avg=640077.45, stdev=66555.21, s amples=119

iops : min= 480, max= 748, avg=625.08, stdev=65.00, samples=119

lat (usec) : 500=43.97%, 750=31.87%, 1000=6.10%

lat (msec) : 2=13.14%, 4=4.87%, 10=0.04%

cpu : usr=0.85%, sys=4.94%, ctx=74897, majf=0, minf=11

IO depths : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, \>=64=0.0%

submit : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

complete : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

issued rwts: total=37446,37449,0,0 short=0,0,0,0 dropped=0,0,0,0

latency : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):

READ: bw=624MiB/s (654MB/s), 624MiB/s-624MiB/s (654MB/s-654MB/s), io=36.6GiB (39.3G B), run=60001-60001msec

WRITE: bw=624MiB/s (654MB/s), 624MiB/s-624MiB/s (654MB/s-654MB/s), io=36.6GiB (39.3G B), run=60001-60001msec

Disk stats (read/write):

nvme0n1: ios=299104/299065, merge=0/0, ticks=252891/81837, in_queue=334728, util=94. 39%

seq_mixed6: (groupid=0, jobs=1): err= 0: pid=545907: Fri Apr 10 10:14:49 2026

read: IOPS=701, BW=702MiB/s (736MB/s)(41.1GiB/60001msec)

slat (usec): min=29, max=655, avg=37.85, stdev= 6.87

clat (usec): min=153, max=2805, avg=928.59, stdev=517.89

lat (usec): min=184, max=2837, avg=966.63, stdev=517.77

clat percentiles (usec):

\| 1.00th=\[ 494\], 5.00th=\[ 510\], 10.00th=\[ 529\], 20.00th=\[ 562\],

\| 30.00th=\[ 594\], 40.00th=\[ 619\], 50.00th=\[ 660\], 60.00th=\[ 758\],

\| 70.00th=\[ 889\], 80.00th=\[ 1434\], 90.00th=\[ 1893\], 95.00th=\[ 2024\],

\| 99.00th=\[ 2245\], 99.50th=\[ 2343\], 99.90th=\[ 2540\], 99.95th=\[ 2606\],

\| 99.99th=\[ 2737\]

bw ( KiB/s): min=612352, max=782336, per=100.00%, avg=718779.16, stdev=34066.67, s amples=119

iops : min= 598, max= 764, avg=701.93, stdev=33.27, samples=119

write: IOPS=697, BW=698MiB/s (732MB/s)(40.9GiB/60001msec); 0 zone resets

slat (usec): min=25, max=169, avg=40.51, stdev= 7.48

clat (usec): min=258, max=1364, avg=416.51, stdev=39.92

lat (usec): min=413, max=1413, avg=457.22, stdev=43.22

clat percentiles (usec):

\| 1.00th=\[ 383\], 5.00th=\[ 388\], 10.00th=\[ 388\], 20.00th=\[ 388\],

\| 30.00th=\[ 392\], 40.00th=\[ 392\], 50.00th=\[ 404\], 60.00th=\[ 416\],

\| 70.00th=\[ 424\], 80.00th=\[ 441\], 90.00th=\[ 461\], 95.00th=\[ 498\],

\| 99.00th=\[ 570\], 99.50th=\[ 611\], 99.90th=\[ 668\], 99.95th=\[ 676\],

\| 99.99th=\[ 685\]

bw ( KiB/s): min=608256, max=808960, per=100.00%, avg=715801.82, stdev=41352.85, s amples=119

iops : min= 594, max= 790, avg=699.03, stdev=40.38, samples=119

lat (usec) : 250=0.07%, 500=48.60%, 750=30.93%, 1000=7.16%

lat (msec) : 2=10.22%, 4=3.02%

cpu : usr=1.12%, sys=4.71%, ctx=83983, majf=0, minf=12

IO depths : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, \>=64=0.0%

submit : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

complete : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

issued rwts: total=42114,41869,0,0 short=0,0,0,0 dropped=0,0,0,0

latency : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):

READ: bw=702MiB/s (736MB/s), 702MiB/s-702MiB/s (736MB/s-736MB/s), io=41.1GiB (44.2G B), run=60001-60001msec

WRITE: bw=698MiB/s (732MB/s), 698MiB/s-698MiB/s (732MB/s-732MB/s), io=40.9GiB (43.9G B), run=60001-60001msec

Disk stats (read/write):

nvme3n1: ios=336586/334720, merge=0/0, ticks=229826/88120, in_queue=317945, util=94. 35%

seq_mixed8: (groupid=0, jobs=1): err= 0: pid=545908: Fri Apr 10 10:14:49 2026

read: IOPS=1038, BW=1038MiB/s (1089MB/s)(60.8GiB/60001msec)

slat (usec): min=28, max=105, avg=32.85, stdev= 4.99

clat (usec): min=136, max=2835, avg=496.17, stdev=518.03

lat (usec): min=182, max=2865, avg=529.16, stdev=520.74

clat percentiles (usec):

\| 1.00th=\[ 155\], 5.00th=\[ 155\], 10.00th=\[ 155\], 20.00th=\[ 157\],

\| 30.00th=\[ 163\], 40.00th=\[ 176\], 50.00th=\[ 186\], 60.00th=\[ 510\],

\| 70.00th=\[ 594\], 80.00th=\[ 693\], 90.00th=\[ 1352\], 95.00th=\[ 1844\],

\| 99.00th=\[ 2147\], 99.50th=\[ 2245\], 99.90th=\[ 2442\], 99.95th=\[ 2507\],

\| 99.99th=\[ 2737\]

bw ( MiB/s): min= 590, max= 1778, per=99.70%, avg=1035.26, stdev=433.58, samples= 119

iops : min= 590, max= 1778, avg=1035.26, stdev=433.58, samples=119

write: IOPS=1034, BW=1034MiB/s (1085MB/s)(60.6GiB/60001msec); 0 zone resets

slat (usec): min=25, max=166, avg=34.87, stdev= 6.63

clat (usec): min=252, max=1410, avg=398.16, stdev=24.02

lat (usec): min=412, max=1450, avg=433.17, stdev=28.26

clat percentiles (usec):

\| 1.00th=\[ 388\], 5.00th=\[ 388\], 10.00th=\[ 388\], 20.00th=\[ 388\],

\| 30.00th=\[ 388\], 40.00th=\[ 388\], 50.00th=\[ 388\], 60.00th=\[ 388\],

\| 70.00th=\[ 388\], 80.00th=\[ 408\], 90.00th=\[ 420\], 95.00th=\[ 453\],

\| 99.00th=\[ 502\], 99.50th=\[ 506\], 99.90th=\[ 537\], 99.95th=\[ 570\],

\| 99.99th=\[ 586\]

bw ( MiB/s): min= 574, max= 1672, per=99.71%, avg=1031.34, stdev=427.47, samples= 119

iops : min= 574, max= 1672, avg=1031.34, stdev=427.47, samples=119

lat (usec) : 250=29.37%, 500=49.65%, 750=12.19%, 1000=2.81%

lat (msec) : 2=4.66%, 4=1.32%

cpu : usr=1.36%, sys=6.10%, ctx=124367, majf=0, minf=13

IO depths : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, \>=64=0.0%

submit : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

complete : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

issued rwts: total=62304,62062,0,0 short=0,0,0,0 dropped=0,0,0,0

latency : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):

READ: bw=1038MiB/s (1089MB/s), 1038MiB/s-1038MiB/s (1089MB/s-1089MB/s), io=60.8GiB (65.3GB), run=60001-60001msec

WRITE: bw=1034MiB/s (1085MB/s), 1034MiB/s-1034MiB/s (1085MB/s-1085MB/s), io=60.6GiB (65.1GB), run=60001-60001msec

Disk stats (read/write):

nvme6n1: ios=497712/495792, merge=0/0, ticks=176976/120006, in_queue=296983, util=92 .73%

seq_mixed3: (groupid=0, jobs=1): err= 0: pid=545909: Fri Apr 10 10:14:49 2026

read: IOPS=1087, BW=1087MiB/s (1140MB/s)(63.7GiB/60001msec)

slat (usec): min=24, max=133, avg=29.14, stdev= 4.78

clat (usec): min=132, max=2770, avg=457.34, stdev=493.43

lat (usec): min=181, max=2796, avg=486.64, stdev=495.54

clat percentiles (usec):

\| 1.00th=\[ 157\], 5.00th=\[ 157\], 10.00th=\[ 159\], 20.00th=\[ 159\],

\| 30.00th=\[ 165\], 40.00th=\[ 176\], 50.00th=\[ 186\], 60.00th=\[ 204\],

\| 70.00th=\[ 553\], 80.00th=\[ 652\], 90.00th=\[ 1037\], 95.00th=\[ 1795\],

\| 99.00th=\[ 2147\], 99.50th=\[ 2245\], 99.90th=\[ 2442\], 99.95th=\[ 2507\],

\| 99.99th=\[ 2638\]

bw ( MiB/s): min= 594, max= 1778, per=99.81%, avg=1085.21, stdev=434.69, samples= 119

iops : min= 594, max= 1778, avg=1085.21, stdev=434.69, samples=119

write: IOPS=1081, BW=1082MiB/s (1135MB/s)(63.4GiB/60001msec); 0 zone resets

slat (usec): min=19, max=119, avg=31.34, stdev= 5.92

clat (usec): min=305, max=1484, avg=401.37, stdev=28.67

lat (usec): min=410, max=1519, avg=432.87, stdev=31.64

clat percentiles (usec):

\| 1.00th=\[ 388\], 5.00th=\[ 392\], 10.00th=\[ 392\], 20.00th=\[ 392\],

\| 30.00th=\[ 392\], 40.00th=\[ 392\], 50.00th=\[ 392\], 60.00th=\[ 392\],

\| 70.00th=\[ 392\], 80.00th=\[ 400\], 90.00th=\[ 420\], 95.00th=\[ 461\],

\| 99.00th=\[ 510\], 99.50th=\[ 553\], 99.90th=\[ 611\], 99.95th=\[ 652\],

\| 99.99th=\[ 676\]

bw ( MiB/s): min= 608, max= 1656, per=99.78%, avg=1079.60, stdev=426.27, samples= 119

iops : min= 608, max= 1656, avg=1079.60, stdev=426.27, samples=119

lat (usec) : 250=31.77%, 500=49.11%, 750=11.33%, 1000=2.64%

lat (msec) : 2=3.95%, 4=1.21%

cpu : usr=1.38%, sys=5.70%, ctx=130161, majf=0, minf=13

IO depths : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, \>=64=0.0%

submit : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

complete : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

issued rwts: total=65237,64921,0,0 short=0,0,0,0 dropped=0,0,0,0

latency : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):

READ: bw=1087MiB/s (1140MB/s), 1087MiB/s-1087MiB/s (1140MB/s-1140MB/s), io=63.7GiB (68.4GB), run=60001-60001msec

WRITE: bw=1082MiB/s (1135MB/s), 1082MiB/s-1082MiB/s (1135MB/s-1135MB/s), io=63.4GiB (68.1GB), run=60001-60001msec

Disk stats (read/write):

nvme11n1: ios=519712/517128, merge=0/0, ticks=166241/123399, in_queue=289640, util=9 3.39%

seq_mixed11: (groupid=0, jobs=1): err= 0: pid=545910: Fri Apr 10 10:14:49 2026

read: IOPS=1095, BW=1095MiB/s (1148MB/s)(64.2GiB/60001msec)

slat (usec): min=26, max=218, avg=30.64, stdev= 5.59

clat (usec): min=59, max=3166, avg=436.94, stdev=469.89

lat (usec): min=181, max=3206, avg=467.72, stdev=472.76

clat percentiles (usec):

\| 1.00th=\[ 155\], 5.00th=\[ 155\], 10.00th=\[ 155\], 20.00th=\[ 157\],

\| 30.00th=\[ 165\], 40.00th=\[ 176\], 50.00th=\[ 184\], 60.00th=\[ 194\],

\| 70.00th=\[ 553\], 80.00th=\[ 619\], 90.00th=\[ 963\], 95.00th=\[ 1745\],

\| 99.00th=\[ 2073\], 99.50th=\[ 2147\], 99.90th=\[ 2245\], 99.95th=\[ 2278\],

\| 99.99th=\[ 2376\]

bw ( MiB/s): min= 652, max= 1794, per=99.76%, avg=1092.62, stdev=439.47, samples= 119

iops : min= 652, max= 1794, avg=1092.62, stdev=439.47, samples=119

write: IOPS=1089, BW=1089MiB/s (1142MB/s)(63.8GiB/60001msec); 0 zone resets

slat (nsec): min=22900, max=93890, avg=33375.87, stdev=6818.26

clat (usec): min=341, max=1065, avg=411.87, stdev=56.22

lat (usec): min=411, max=1113, avg=445.38, stdev=60.62

clat percentiles (usec):

\| 1.00th=\[ 388\], 5.00th=\[ 388\], 10.00th=\[ 388\], 20.00th=\[ 388\],

\| 30.00th=\[ 388\], 40.00th=\[ 388\], 50.00th=\[ 388\], 60.00th=\[ 392\],

\| 70.00th=\[ 392\], 80.00th=\[ 392\], 90.00th=\[ 545\], 95.00th=\[ 562\],

\| 99.00th=\[ 570\], 99.50th=\[ 570\], 99.90th=\[ 578\], 99.95th=\[ 578\],

\| 99.99th=\[ 578\]

bw ( MiB/s): min= 622, max= 1670, per=99.78%, avg=1087.03, stdev=430.54, samples= 119

iops : min= 622, max= 1670, avg=1087.03, stdev=430.54, samples=119

lat (usec) : 100=0.01%, 250=31.93%, 500=43.87%, 750=18.34%, 1000=0.96%

lat (msec) : 2=4.03%, 4=0.86%

cpu : usr=1.45%, sys=6.08%, ctx=131084, majf=0, minf=12

IO depths : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, \>=64=0.0%

submit : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

complete : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

issued rwts: total=65717,65365,0,0 short=0,0,0,0 dropped=0,0,0,0

latency : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):

READ: bw=1095MiB/s (1148MB/s), 1095MiB/s-1095MiB/s (1148MB/s-1148MB/s), io=64.2GiB (68.9GB), run=60001-60001msec

WRITE: bw=1089MiB/s (1142MB/s), 1089MiB/s-1089MiB/s (1142MB/s-1142MB/s), io=63.8GiB (68.5GB), run=60001-60001msec

Disk stats (read/write):

nvme9n1: ios=525394/522504, merge=0/0, ticks=161371/123922, in_queue=285293, util=92 .84%

seq_mixed5: (groupid=0, jobs=1): err= 0: pid=545911: Fri Apr 10 10:14:49 2026

read: IOPS=693, BW=694MiB/s (728MB/s)(40.7GiB/60001msec)

slat (usec): min=31, max=147, avg=40.30, stdev= 4.54

clat (usec): min=145, max=2815, avg=941.09, stdev=526.09

lat (usec): min=187, max=2849, avg=981.60, stdev=525.80

clat percentiles (usec):

\| 1.00th=\[ 490\], 5.00th=\[ 515\], 10.00th=\[ 529\], 20.00th=\[ 578\],

\| 30.00th=\[ 603\], 40.00th=\[ 619\], 50.00th=\[ 676\], 60.00th=\[ 766\],

\| 70.00th=\[ 906\], 80.00th=\[ 1483\], 90.00th=\[ 1909\], 95.00th=\[ 2057\],

\| 99.00th=\[ 2278\], 99.50th=\[ 2343\], 99.90th=\[ 2507\], 99.95th=\[ 2606\],

\| 99.99th=\[ 2737\]

bw ( KiB/s): min=616448, max=788480, per=100.00%, avg=710982.99, stdev=30297.06, s amples=119

iops : min= 602, max= 770, avg=694.32, stdev=29.59, samples=119

write: IOPS=691, BW=691MiB/s (725MB/s)(40.5GiB/60001msec); 0 zone resets

slat (usec): min=28, max=188, avg=43.93, stdev= 6.13

clat (usec): min=341, max=1328, avg=413.53, stdev=32.28

lat (usec): min=414, max=1369, avg=457.67, stdev=34.73

clat percentiles (usec):

\| 1.00th=\[ 383\], 5.00th=\[ 388\], 10.00th=\[ 388\], 20.00th=\[ 388\],

\| 30.00th=\[ 388\], 40.00th=\[ 404\], 50.00th=\[ 408\], 60.00th=\[ 412\],

\| 70.00th=\[ 416\], 80.00th=\[ 429\], 90.00th=\[ 453\], 95.00th=\[ 494\],

\| 99.00th=\[ 515\], 99.50th=\[ 553\], 99.90th=\[ 594\], 99.95th=\[ 644\],

\| 99.99th=\[ 660\]

bw ( KiB/s): min=620544, max=790528, per=100.00%, avg=708711.26, stdev=34813.80, s amples=119

iops : min= 606, max= 772, avg=692.10, stdev=34.00, samples=119

lat (usec) : 250=0.05%, 500=49.39%, 750=29.90%, 1000=7.21%

lat (msec) : 2=10.02%, 4=3.43%

cpu : usr=1.06%, sys=5.08%, ctx=83092, majf=0, minf=12

IO depths : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, \>=64=0.0%

submit : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

complete : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

issued rwts: total=41631,41461,0,0 short=0,0,0,0 dropped=0,0,0,0

latency : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):

READ: bw=694MiB/s (728MB/s), 694MiB/s-694MiB/s (728MB/s-728MB/s), io=40.7GiB (43.7G B), run=60001-60001msec

WRITE: bw=691MiB/s (725MB/s), 691MiB/s-691MiB/s (725MB/s-725MB/s), io=40.5GiB (43.5G B), run=60001-60001msec

Disk stats (read/write):

nvme2n1: ios=332648/331280, merge=0/0, ticks=232948/90866, in_queue=323814, util=94. 72%

seq_mixed2: (groupid=0, jobs=1): err= 0: pid=545918: Fri Apr 10 10:14:50 2026

read: IOPS=1096, BW=1096MiB/s (1150MB/s)(64.2GiB/60001msec)

slat (usec): min=24, max=118, avg=28.11, stdev= 5.18

clat (usec): min=122, max=2789, avg=455.08, stdev=492.97

lat (usec): min=181, max=2815, avg=483.32, stdev=495.90

clat percentiles (usec):

\| 1.00th=\[ 157\], 5.00th=\[ 157\], 10.00th=\[ 157\], 20.00th=\[ 159\],

\| 30.00th=\[ 165\], 40.00th=\[ 176\], 50.00th=\[ 184\], 60.00th=\[ 200\],

\| 70.00th=\[ 570\], 80.00th=\[ 644\], 90.00th=\[ 996\], 95.00th=\[ 1811\],

\| 99.00th=\[ 2147\], 99.50th=\[ 2245\], 99.90th=\[ 2474\], 99.95th=\[ 2507\],

\| 99.99th=\[ 2638\]

bw ( MiB/s): min= 640, max= 1804, per=99.80%, avg=1094.08, stdev=442.94, samples= 119

iops : min= 640, max= 1804, avg=1094.08, stdev=442.94, samples=119

write: IOPS=1090, BW=1091MiB/s (1143MB/s)(63.9GiB/60001msec); 0 zone resets

slat (usec): min=20, max=142, avg=29.71, stdev= 6.59

clat (usec): min=308, max=1496, avg=399.00, stdev=22.66

lat (usec): min=410, max=1534, avg=428.84, stdev=26.74

clat percentiles (usec):

\| 1.00th=\[ 392\], 5.00th=\[ 392\], 10.00th=\[ 392\], 20.00th=\[ 392\],

\| 30.00th=\[ 392\], 40.00th=\[ 392\], 50.00th=\[ 392\], 60.00th=\[ 392\],

\| 70.00th=\[ 392\], 80.00th=\[ 404\], 90.00th=\[ 416\], 95.00th=\[ 453\],

\| 99.00th=\[ 506\], 99.50th=\[ 506\], 99.90th=\[ 553\], 99.95th=\[ 570\],

\| 99.99th=\[ 586\]

bw ( MiB/s): min= 642, max= 1682, per=99.82%, avg=1088.50, stdev=434.02, samples= 119

iops : min= 642, max= 1682, avg=1088.50, stdev=434.02, samples=119

lat (usec) : 250=31.95%, 500=49.11%, 750=11.33%, 1000=2.61%

lat (msec) : 2=3.68%, 4=1.33%

cpu : usr=1.31%, sys=5.45%, ctx=131211, majf=0, minf=13

IO depths : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, \>=64=0.0%

submit : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

complete : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

issued rwts: total=65779,65432,0,0 short=0,0,0,0 dropped=0,0,0,0

latency : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):

READ: bw=1096MiB/s (1150MB/s), 1096MiB/s-1096MiB/s (1150MB/s-1150MB/s), io=64.2GiB (69.0GB), run=60001-60001msec

WRITE: bw=1091MiB/s (1143MB/s), 1091MiB/s-1091MiB/s (1143MB/s-1143MB/s), io=63.9GiB (68.6GB), run=60001-60001msec

Disk stats (read/write):

nvme10n1: ios=524592/521780, merge=0/0, ticks=169018/125245, in_queue=294261, util=9 3.87%

seq_mixed4: (groupid=0, jobs=1): err= 0: pid=545919: Fri Apr 10 10:14:50 2026

read: IOPS=1069, BW=1069MiB/s (1121MB/s)(62.6GiB/60001msec)

slat (usec): min=27, max=222, avg=32.73, stdev= 5.08

clat (usec): min=3, max=2829, avg=463.18, stdev=494.69

lat (usec): min=184, max=2867, avg=496.07, stdev=497.02

clat percentiles (usec):

\| 1.00th=\[ 155\], 5.00th=\[ 157\], 10.00th=\[ 157\], 20.00th=\[ 159\],

\| 30.00th=\[ 163\], 40.00th=\[ 176\], 50.00th=\[ 186\], 60.00th=\[ 204\],

\| 70.00th=\[ 586\], 80.00th=\[ 685\], 90.00th=\[ 1029\], 95.00th=\[ 1811\],

\| 99.00th=\[ 2147\], 99.50th=\[ 2212\], 99.90th=\[ 2442\], 99.95th=\[ 2507\],

\| 99.99th=\[ 2704\]

bw ( MiB/s): min= 572, max= 1773, per=99.67%, avg=1065.63, stdev=431.84, samples= 119

iops : min= 572, max= 1773, avg=1065.49, stdev=431.86, samples=119

write: IOPS=1063, BW=1064MiB/s (1115MB/s)(62.3GiB/60001msec); 0 zone resets

slat (usec): min=23, max=135, avg=34.90, stdev= 6.25

clat (usec): min=290, max=1524, avg=404.06, stdev=34.51

lat (usec): min=413, max=1567, avg=439.13, stdev=37.92

clat percentiles (usec):

\| 1.00th=\[ 388\], 5.00th=\[ 388\], 10.00th=\[ 388\], 20.00th=\[ 392\],

\| 30.00th=\[ 392\], 40.00th=\[ 392\], 50.00th=\[ 392\], 60.00th=\[ 392\],

\| 70.00th=\[ 392\], 80.00th=\[ 408\], 90.00th=\[ 441\], 95.00th=\[ 498\],

\| 99.00th=\[ 523\], 99.50th=\[ 553\], 99.90th=\[ 652\], 99.95th=\[ 660\],

\| 99.99th=\[ 676\]

bw ( MiB/s): min= 590, max= 1647, per=99.71%, avg=1060.66, stdev=424.08, samples= 119

iops : min= 590, max= 1647, avg=1060.53, stdev=424.10, samples=119

lat (usec) : 4=0.01%, 250=31.47%, 500=47.62%, 750=12.86%, 1000=2.90%

lat (msec) : 2=3.92%, 4=1.23%

cpu : usr=1.59%, sys=6.15%, ctx=127977, majf=0, minf=14

IO depths : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, \>=64=0.0%

submit : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

complete : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

issued rwts: total=64150,63825,0,0 short=0,0,0,0 dropped=0,0,0,0

latency : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):

READ: bw=1069MiB/s (1121MB/s), 1069MiB/s-1069MiB/s (1121MB/s-1121MB/s), io=62.6GiB (67.3GB), run=60001-60001msec

WRITE: bw=1064MiB/s (1115MB/s), 1064MiB/s-1064MiB/s (1115MB/s-1115MB/s), io=62.3GiB (66.9GB), run=60001-60001msec

Disk stats (read/write):

nvme1n1: ios=509864/507726, merge=0/0, ticks=166683/122401, in_queue=289084, util=92 .15%

seq_mixed7: (groupid=0, jobs=1): err= 0: pid=545921: Fri Apr 10 10:14:50 2026

read: IOPS=623, BW=624MiB/s (654MB/s)(36.5GiB/60002msec)

slat (nsec): min=22320, max=88590, avg=30555.52, stdev=4810.15

clat (usec): min=417, max=6616, avg=1085.98, stdev=608.61

lat (usec): min=446, max=6649, avg=1116.73, stdev=608.59

clat percentiles (usec):

\| 1.00th=\[ 498\], 5.00th=\[ 523\], 10.00th=\[ 545\], 20.00th=\[ 603\],

\| 30.00th=\[ 635\], 40.00th=\[ 693\], 50.00th=\[ 725\], 60.00th=\[ 832\],

\| 70.00th=\[ 1614\], 80.00th=\[ 1876\], 90.00th=\[ 2008\], 95.00th=\[ 2089\],

\| 99.00th=\[ 2245\], 99.50th=\[ 2311\], 99.90th=\[ 3654\], 99.95th=\[ 4621\],

\| 99.99th=\[ 5604\]

bw ( KiB/s): min=493568, max=804864, per=100.00%, avg=638838.32, stdev=83396.58, s amples=119

iops : min= 482, max= 786, avg=623.87, stdev=81.44, samples=119

write: IOPS=623, BW=624MiB/s (654MB/s)(36.6GiB/60002msec); 0 zone resets

slat (nsec): min=17930, max=87780, avg=32805.28, stdev=5912.52

clat (usec): min=355, max=1538, avg=449.29, stdev=57.72

lat (usec): min=409, max=1580, avg=482.31, stdev=59.81

clat percentiles (usec):

\| 1.00th=\[ 392\], 5.00th=\[ 392\], 10.00th=\[ 392\], 20.00th=\[ 392\],

\| 30.00th=\[ 404\], 40.00th=\[ 408\], 50.00th=\[ 420\], 60.00th=\[ 457\],

\| 70.00th=\[ 502\], 80.00th=\[ 506\], 90.00th=\[ 515\], 95.00th=\[ 523\],

\| 99.00th=\[ 644\], 99.50th=\[ 660\], 99.90th=\[ 676\], 99.95th=\[ 685\],

\| 99.99th=\[ 701\]

bw ( KiB/s): min=473088, max=806912, per=100.00%, avg=639371.83, stdev=85344.46, s amples=119

iops : min= 462, max= 788, avg=624.39, stdev=83.34, samples=119

lat (usec) : 500=33.37%, 750=43.08%, 1000=5.67%

lat (msec) : 2=12.72%, 4=5.13%, 10=0.04%

cpu : usr=1.23%, sys=3.41%, ctx=74855, majf=0, minf=11

IO depths : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, \>=64=0.0%

submit : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

complete : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

issued rwts: total=37425,37430,0,0 short=0,0,0,0 dropped=0,0,0,0

latency : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):

READ: bw=624MiB/s (654MB/s), 624MiB/s-624MiB/s (654MB/s-654MB/s), io=36.5GiB (39.2G B), run=60002-60002msec

WRITE: bw=624MiB/s (654MB/s), 624MiB/s-624MiB/s (654MB/s-654MB/s), io=36.6GiB (39.2G B), run=60002-60002msec

Disk stats (read/write):

nvme4n1: ios=299352/299366, merge=0/0, ticks=251305/83678, in_queue=334982, util=94. 02%

seq_mixed9: (groupid=0, jobs=1): err= 0: pid=545922: Fri Apr 10 10:14:50 2026

read: IOPS=1010, BW=1011MiB/s (1060MB/s)(59.2GiB/60001msec)

slat (usec): min=26, max=156, avg=30.96, stdev= 5.47

clat (usec): min=123, max=2831, avg=500.27, stdev=504.89

lat (usec): min=180, max=2858, avg=531.38, stdev=507.60

clat percentiles (usec):

\| 1.00th=\[ 153\], 5.00th=\[ 155\], 10.00th=\[ 157\], 20.00th=\[ 161\],

\| 30.00th=\[ 176\], 40.00th=\[ 188\], 50.00th=\[ 251\], 60.00th=\[ 318\],

\| 70.00th=\[ 603\], 80.00th=\[ 709\], 90.00th=\[ 1156\], 95.00th=\[ 1844\],

\| 99.00th=\[ 2180\], 99.50th=\[ 2245\], 99.90th=\[ 2442\], 99.95th=\[ 2507\],

\| 99.99th=\[ 2671\]

bw ( KiB/s): min=581632, max=1794048, per=99.64%, avg=1031314.29, stdev=404909.57, samples=119

iops : min= 568, max= 1752, avg=1007.14, stdev=395.42, samples=119

write: IOPS=1007, BW=1008MiB/s (1057MB/s)(59.1GiB/60001msec); 0 zone resets

slat (nsec): min=21560, max=86990, avg=32677.09, stdev=6832.35

clat (usec): min=350, max=1291, avg=424.00, stdev=50.50

lat (usec): min=410, max=1332, avg=456.82, stdev=53.56

clat percentiles (usec):

\| 1.00th=\[ 388\], 5.00th=\[ 388\], 10.00th=\[ 388\], 20.00th=\[ 388\],

\| 30.00th=\[ 392\], 40.00th=\[ 392\], 50.00th=\[ 392\], 60.00th=\[ 408\],

\| 70.00th=\[ 437\], 80.00th=\[ 486\], 90.00th=\[ 502\], 95.00th=\[ 510\],

\| 99.00th=\[ 578\], 99.50th=\[ 627\], 99.90th=\[ 660\], 99.95th=\[ 668\],

\| 99.99th=\[ 685\]

bw ( KiB/s): min=595968, max=1716224, per=99.69%, avg=1028904.87, stdev=404147.73, samples=119

iops : min= 582, max= 1676, avg=1004.79, stdev=394.68, samples=119

lat (usec) : 250=23.72%, 500=51.16%, 750=16.46%, 1000=3.08%

lat (msec) : 2=4.13%, 4=1.46%

cpu : usr=1.52%, sys=5.54%, ctx=121118, majf=0, minf=12

IO depths : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, \>=64=0.0%

submit : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

complete : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

issued rwts: total=60645,60473,0,0 short=0,0,0,0 dropped=0,0,0,0

latency : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):

READ: bw=1011MiB/s (1060MB/s), 1011MiB/s-1011MiB/s (1060MB/s-1060MB/s), io=59.2GiB (63.6GB), run=60001-60001msec

WRITE: bw=1008MiB/s (1057MB/s), 1008MiB/s-1008MiB/s (1057MB/s-1057MB/s), io=59.1GiB (63.4GB), run=60001-60001msec

Disk stats (read/write):

nvme7n1: ios=484880/483571, merge=0/0, ticks=165336/118332, in_queue=283668, util=91 .11%

seq_mixed10: (groupid=0, jobs=1): err= 0: pid=545920: Fri Apr 10 10:14:50 2026

read: IOPS=875, BW=876MiB/s (918MB/s)(51.3GiB/60001msec)

slat (usec): min=30, max=218, avg=39.17, stdev= 6.64

clat (usec): min=127, max=2695, avg=555.58, stdev=492.63

lat (usec): min=180, max=2729, avg=594.93, stdev=494.51

clat percentiles (usec):

\| 1.00th=\[ 151\], 5.00th=\[ 155\], 10.00th=\[ 157\], 20.00th=\[ 182\],

\| 30.00th=\[ 237\], 40.00th=\[ 285\], 50.00th=\[ 289\], 60.00th=\[ 562\],

\| 70.00th=\[ 652\], 80.00th=\[ 750\], 90.00th=\[ 1319\], 95.00th=\[ 1827\],

\| 99.00th=\[ 2114\], 99.50th=\[ 2212\], 99.90th=\[ 2376\], 99.95th=\[ 2442\],

\| 99.99th=\[ 2573\]

bw ( KiB/s): min=581632, max=1744896, per=99.44%, avg=891620.03, stdev=333832.06, samples=119

iops : min= 568, max= 1704, avg=870.72, stdev=326.01, samples=119

write: IOPS=871, BW=872MiB/s (914MB/s)(51.1GiB/60001msec); 0 zone resets

slat (nsec): min=26420, max=99980, avg=43439.16, stdev=8914.07

clat (usec): min=349, max=1403, avg=502.03, stdev=108.62

lat (usec): min=412, max=1455, avg=545.65, stdev=114.73

clat percentiles (usec):

\| 1.00th=\[ 383\], 5.00th=\[ 388\], 10.00th=\[ 388\], 20.00th=\[ 388\],

\| 30.00th=\[ 388\], 40.00th=\[ 424\], 50.00th=\[ 469\], 60.00th=\[ 545\],

\| 70.00th=\[ 619\], 80.00th=\[ 644\], 90.00th=\[ 644\], 95.00th=\[ 644\],

\| 99.00th=\[ 652\], 99.50th=\[ 652\], 99.90th=\[ 668\], 99.95th=\[ 685\],

\| 99.99th=\[ 701\]

bw ( KiB/s): min=598016, max=1710080, per=99.49%, avg=888126.39, stdev=330309.66, samples=119

iops : min= 584, max= 1670, avg=867.31, stdev=322.57, samples=119

lat (usec) : 250=15.81%, 500=40.57%, 750=33.55%, 1000=3.84%

lat (msec) : 2=5.20%, 4=1.03%

cpu : usr=1.46%, sys=6.82%, ctx=104847, majf=0, minf=12

IO depths : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, \>=64=0.0%

submit : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

complete : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, \>=64=0.0%

issued rwts: total=52539,52308,0,0 short=0,0,0,0 dropped=0,0,0,0

latency : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):

READ: bw=876MiB/s (918MB/s), 876MiB/s-876MiB/s (918MB/s-918MB/s), io=51.3GiB (55.1G B), run=60001-60001msec

WRITE: bw=872MiB/s (914MB/s), 872MiB/s-872MiB/s (914MB/s-914MB/s), io=51.1GiB (54.8G B), run=60001-60001msec

Disk stats (read/write):

nvme8n1: ios=420280/418432, merge=0/0, ticks=161835/113526, in_queue=275361, util=91 .73%

===== Hotplug loop 1/1 =====

\[2026-04-10 10:14:50\] loop 1 disk /dev/nvme0n1 start

Now you may PULL OUT /dev/nvme0n1.

Press Enter to continue...
