1.  下发CDB命令的常用工具

> sg_raw -- 通常linux OS会自带
>
> storelibtest -- Broadcom的内部测试工具，适用于LSI RAID卡
>
> PMC卡暂时没有特有工具，后续有的话会补充

2.  sg_raw工具使用

> 例子1：3408卡下给/dev/sda下发1a 00 1c 00 40 00
>
> OS命令：sg_raw /dev/sda 1a 00 1c 00 40 00
>
> 3408串口打印：

<img src="media/image1.png" style="width:5.76806in;height:0.19722in" />

> 其他例子：
>
> OS命令：sg_raw /dev/sda 37 00 0c 00 00 00 00 00 04 00
>
> 串口打印：
>
> <img src="media/image2.png" style="width:5.76806in;height:0.23889in" />
>
> OS命令：sg_raw /dev/sda b7 0c 00 00 00 00 00 00 00 08 00 00
>
> 串口打印：
>
> <img src="media/image3.png" style="width:5.76806in;height:0.1875in" />
>
> OS命令：sg_raw /dev/sda 4d 00 40 00 00 00 00 00 04 00
>
> 串口打印：
>
> <img src="media/image4.png" style="width:5.76806in;height:0.18611in" />

3.  storelibtest工具使用

> 例子1：给某个槽位的硬盘下发12 01 c0 00 20 00
>
> 步骤1：查询目标物理盘的DID号
>
> <img src="media/image5.png" style="width:5.76806in;height:2.14167in" />
>
> 步骤2：用storelibtest给DID号为26的盘下发12 01 c0 00 20 00
>
> <img src="media/image6.png" style="width:5.76806in;height:5.75972in" /><img src="media/image7.png" style="width:7.59593in;height:4.01962in" />
>
> RAID卡串口日志：
>
> <img src="media/image8.png" style="width:7.05208in;height:0.46875in" />
>
> 例子2：给SATA盘下发STP命令
>
> ...MAIN MENU...
>
> ---------------
>
> \(1\) SelectController (2) System
>
> \(3\) Controller (4) Physical Device
>
> \(5\) Logical Device (6) Configuration
>
> \(7\) BBU (8) Passthru
>
> \(9\) Event (10)Enclosure
>
> (11)Run BVT (12)Security
>
> 0 TO QUIT
>
> Please enter choice : 8
>
> ...PASSTHRU MENU ...
>
> --------------------
>
> \(1\) SCSI Passthru (2) SMP Passthru
>
> \(3\) STP Passthru (4) DCMD Passthru
>
> \(5\) STP Passthru Write Sector
>
> \(6\) NVME Passthru
>
> 0 TO QUIT. Invalid option to return to Previous Menu
>
> Currently selected controller = 0
>
> Please enter choice :3
>
> ...STP Passthru Menu...
>
> ---------------
>
> \(1\) STP Identify (2) Any STP Passthru
>
> 0 TO QUIT. Invalid option to return to Previous Menu
>
> Please enter choice : 2
>
> Enter Data Length \[Identify = 512\]
>
> 0x950
>
> Enter cmd direction (0-\>no data transfer, 1-\>transfer from host, 2-\>transfer to host, 3-\>transfer both to and from the host --\>1
>
> Enter SATA Device Id 23
>
> Enter Time Out Value 30
>
> Enter 20 FISs in Hex ---\>FIS\[0\] = 0x0
>
> FIS\[1\] = 0x0
>
> FIS\[2\] = 0x1
>
> FIS\[3\] = 0x1
>
> FIS\[4\] = 0x0
>
> FIS\[5\] = 0x0
>
> FIS\[6\] = 0x0
>
> FIS\[7\] = 0x0
>
> FIS\[8\] = 0x0
>
> FIS\[9\] = 0x0
>
> FIS\[10\] = 0x0
>
> FIS\[11\] = 0x0
>
> FIS\[12\] = 0x0
>
> FIS\[13\] = 0x0
>
> FIS\[14\] = 0x0
>
> FIS\[15\] = 0x0
>
> FIS\[16\] = 0x9c
>
> FIS\[17\] = 0x56
>
> FIS\[18\] = 0x01
>
> FIS\[19\] = 0x44
>
> \*\*\*\*\*\*FIS\*\*\*\*\*\*
>
> Fis type 0x0
>
> Command Bit 0x0
>
> Command 0x1
>
> Features 0x1
>
> LBALow_0_7 0x0
>
> LBAMid_8_15 0x0
>
> LBAHigh_16_23 0x0
>
> Device 0x0
>
> LBALowExp_24_31 0x0
>
> LBAMidExp_32_39 0x0
>
> LBAHighExp_40_47 0x0
>
> FeaturesExp 0x0
>
> SectorCount0_7 0x0
>
> SectorCountExp8_15 0x0
>
> Reserved0E 0x0
>
> Control 0x0
>
> \*\*\*\*\*\*FIS END\*\*\*\*\*\*
>
> Enter Flag
>
> CSMI_SAS_STP_READ 0x00000001
>
> CSMI_SAS_STP_WRITE 0x00000002
>
> CSMI_SAS_STP_UNSPECIFIED 0x00000004
>
> CSMI_SAS_STP_PIO 0x00000010
>
> CSMI_SAS_STP_DMA 0x00000020
>
> CSMI_SAS_STP_PACKET 0x00000040
>
> CSMI_SAS_STP_DMA_QUEUED 0x00000080
>
> CSMI_SAS_STP_EXECUTE_DIAG 0x00000100
>
> CSMI_SAS_STP_RESET_DEVICE 0x00000200
>
> 0x950
>
> Sending to storelib
>
> STPPassthru : ProcessLibCommandCall failed; rval = 0x2E
>
> ERROR 0x2E
>
> Press ENTER to continue
