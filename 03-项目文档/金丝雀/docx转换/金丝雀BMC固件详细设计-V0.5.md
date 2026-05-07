<span class="mark">金丝雀BMC固件</span>

详细设计说明书

V0.5

# 版本修订记录

| **版本** | **发布时间** | **变更内容** | **修订人** | **审核人** |
|:--------:|:------------:|--------------|:----------:|:----------:|
|          |              |              |            |            |
|          |              |              |            |            |
|          |              |              |            |            |
|          |              |              |            |            |
|          |              |              |            |            |
|          |              |              |            |            |
|          |              |              |            |            |
|          |              |              |            |            |

# 目录

[版本修订记录 [1](#版本修订记录)](#版本修订记录)

[1. 引言 [3](#引言)](#引言)

[1.1 目的 [3](#目的)](#目的)

[1.2 关联SR/AR号 [3](#关联srar号)](#关联srar号)

[1.3 背景和功能描述 [3](#背景和功能描述)](#背景和功能描述)

[1.4 术语解释（可选） [4](#术语解释可选)](#术语解释可选)

[1.5 参考资料（可选） [4](#参考资料可选)](#参考资料可选)

[2. 总体设计 [6](#总体设计)](#总体设计)

[2.1 系统架构 [6](#系统架构)](#系统架构)

[2.2 BMC软件平台架构 [6](#bmc软件平台架构)](#bmc软件平台架构)

[2.2.1 BMC架构分层 [6](#bmc架构分层)](#bmc架构分层)

[2.3 总体设计框图和描述 [7](#总体设计框图和描述)](#总体设计框图和描述)

[3. 详细设计 [7](#详细设计)](#详细设计)

[3.1 全局数据结构和变量说明（可选） [7](#_Toc215499010)](#_Toc215499010)

[3.2 数据库/数据文件设计（可选） [7](#_Toc215499011)](#_Toc215499011)

[3.3 接口和UI设计（新增命令、接口、选项等）（可选） [7](#_Toc215499012)](#_Toc215499012)

[3.4 详细功能设计 [8](#_Toc215499013)](#_Toc215499013)

[3.5 测试接口说明及测试建议 [10](#_Toc521917694)](#_Toc521917694)

[3.6 自测结果及报告 [10](#_Toc215499015)](#_Toc215499015)

#  引言

## 目的

本详细设计说明书编写的目的是说明金丝雀BMC固件的设计思路， 包括总体固件描述、功能实现细节和流程逻辑等，为软件编程和系统维护提供背景基础。

本说明书的预期读者为系统设计人员、软件开发人员、软件测试人员和项目评审人员。

## 关联SR/AR号

*（要求：列举详细设计规范中相关的SR/AR号和描述）*

## 背景和功能描述

超强 A960I A2是基于华为鲲鹏平台开发的服务器，采用2路920X系列处理器，最多支持32根DDR5 DIMMs。

超强 A960I A2 服务器是基于新一代高性能 AI 芯片的算力密集型 6U/多GPU 机架式服务器。该服务器面向人工智能训练、深度学习、大规模数据处理、智能推理等前沿领域，具备超强算力输出、大规模并行计算、高效能效比、灵活资源调度、便捷运维管理等显著优势。适用于科技研发、金融风控、智能医疗、自动驾驶、智慧城市、互联网服务等全行业智能化升级场景，提供澎湃的 AI 算力支撑与弹性扩展能力，满足大规模神经网络训练、超算级模型推演、实时智能决策、复杂数据建模等高性能计算需求，以及数据中心多元化 AI 算力部署的核心诉求。

GPU互联拓扑可以根据业务场景不同。在线一键切换Balance及Cascade拓扑。

- Balance拓扑：

<!-- -->

- 适合GPU直通虚拟化

- 中/小规模深度学习训练、推理、公有云和HPC

<!-- -->

- Cascade拓扑：

<!-- -->

- 部分AI训练模型性能最优

适用于多参数模型的大规模深度学习训练场景

<table>
<colgroup>
<col style="width: 10%" />
<col style="width: 31%" />
<col style="width: 27%" />
<col style="width: 31%" />
</colgroup>
<thead>
<tr>
<th colspan="4" style="text-align: center;"><strong>鲲鹏 6U 服务器</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: center;"><strong>参数</strong></td>
<td style="text-align: center;"><strong>直通机型</strong></td>
<td style="text-align: center;"><strong>2 Switch机型</strong></td>
<td style="text-align: center;"><strong>4 Switch机型</strong></td>
</tr>
<tr>
<td style="text-align: center;">CPU</td>
<td colspan="3" style="text-align: center;">支持2个鲲鹏920X系列处理器，处理器规格为≥48核</td>
</tr>
<tr>
<td style="text-align: center;">内存</td>
<td colspan="3" style="text-align: center;">最大支持32条 DDR5 最大支持4800MT/s内存；支持RDIMM</td>
</tr>
<tr>
<td style="text-align: center;">GPU</td>
<td style="text-align: center;">最大支持8张单宽/双宽GPU</td>
<td style="text-align: center;">最大支持10张双宽GPU</td>
<td style="text-align: center;">最大支持20张单宽GPU</td>
</tr>
<tr>
<td style="text-align: center;">存储</td>
<td colspan="3" style="text-align: center;"><p>前置：最大支持12*3.5 SAS/SATA/NVME</p>
<p>内置：支持2个M.2 SSD</p></td>
</tr>
<tr>
<td style="text-align: center;">IO</td>
<td colspan="3" style="text-align: center;"><p>FIO:2*USB3.0+1*VGA</p>
<p>RIO:2*USB3.0+1*VGA+1*GE RJ45管理网口+1*串口</p></td>
</tr>
<tr>
<td style="text-align: center;">风扇</td>
<td colspan="3" style="text-align: center;">13*8080风扇（（前置*5；中置*8）），支持N+1 冗余</td>
</tr>
<tr>
<td style="text-align: center;">电源</td>
<td colspan="3" style="text-align: center;">6*3200W，N+N支持冗余热插拔</td>
</tr>
</tbody>
</table>

## 术语解释（可选）

| **缩写、术语** | **解释**                                       |
|----------------|------------------------------------------------|
| openUBMC       | 一款算力设备开源管理软件，适配华为鲲鹏系列主板 |
| BMC            | 基板管理控制器                                 |
| BCU            | 基础板                                         |
| EXU            | 扩展板                                         |
| CLU            | 风扇板                                         |
| Switch         | Switch背板，2(4) Switch表示Switch背板数量      |
| PSU            | 供电单元                                       |

## 参考资料（可选）

*（要求：列出有关资料和文档的名称、版本、链接等）*

比如：

*1、《紫金山XXX服务器_节点BIOS设计规范》*

*2、《紫金山XXX服务器_节点BMC设计规范》*

# 总体设计

## 系统架构

整机核心部件为基于华为鲲鹏平台2S主板，管理功能模块透过DC-SCM运作。相关硬件描述：

- BMC芯片：Hi1711

- 系统CPU： 2\*325W kunpeng 920B

- 系统内存： 最大32条16G/32G/64G/128G DDR5

- GPU：直通支持8张单宽/双宽GPU，2 Switch 支持10张双宽GPU，4 Switch 支持20张单宽GPU

- 存储：前置，最大支持12\*3.5 SAS/SATA/NVMe

- M2：内置，支持2个M.2 SSD

- 电源：6\*3200W CRPS电源，支持N+N冗余

- 网络：板载2个OCP网卡

- 风扇：12\*6056风扇，支持N+1冗余

- Riser：支持2个3\*8 Riser卡

- Switch背板：0 Switch，2 Switch，4 Switch

## BMC软件平台架构

### BMC架构分层

<img src="media/image1.png" style="width:5.76389in;height:3.15958in" />

openUBMC架构分层

BMC是运行在带外独立处理器上的一套嵌入式系统，使用u-boot作为系统引导程序，运行Linux kernel 操作系统，在Linux kernel系统上运行应用程序，对服务器的硬件状态监控；对传感器数据的实时采集，存储，告警；对服务器进行远程控制；对服务器资产管理。同时对外提供工业标准的管理服务，如IPMI、SNMP、Redfish等。BMC 处理器兼具显卡功能。

openUBMC 从用户接口层到硬件调用，采用分层设计，将接口与组件解耦，组件与硬件解耦，避免接口错误调用影响业务功能。

## 总体设计框图和描述

# 详细设计

## 板卡适配

### 扩展板适配

#### 原理说明

<img src="media/image2.png" style="width:5.75556in;height:3.14167in" />

硬件自发现采用层级加载的方式。

- 系统启动，从flash获取root.sr文件，此文件描述了BMC芯片的链路拓扑信息；

- root.sr与扩展板（EXU）直接连接，再由EXU连接基础板（BCU）、风扇板（CLU）、硬盘背板（SEU）、板载网卡（NIC）等对象。

- 硬件自发现加载连接器对象，并根据连接器的识别模式、在位状态等执行下级组件的并发发现，包括读取Eeprom数据、获取sr文件数据、解析对象数据、发布对象组，并重复上述自发现流程。

#### CSR适配

##### 3.1.1.2.1基本结构

<img src="media/image3.png" style="width:2.65625in;height:1.51042in" />

- FormatVersion: CSR数据格式和整体结构。

- DataVersion:CSR版本号，展示在web。

- Type: CSR所属类型，扩展板为EXU。

##### 3.1.1.2.1拓扑结构

ManagementTopology结构主要描述CSR文件中链路逻辑关系，需要对照设计的硬件链路来配置。拓扑包含Anchor、Buses、Chips、 Connectors的层级关系，Anchor是上一级Connector传递链路的入口，是和上级板卡连接的桥梁，传入的Buses上可以挂载Chips和Connectors对象。

<img src="media/image4.png" style="width:3.0625in;height:4.73958in" />

- EXU的Connector对象

<img src="media/image5.png" style="width:2.34375in;height:1.67708in" /> <img src="media/image6.png" style="width:2.48958in;height:1.66667in" />

<img src="media/image7.png" style="width:2.58611in;height:3.65625in" /><img src="media/image8.png" style="width:2.72847in;height:2.82292in" />

<img src="media/image9.png" style="width:2.55486in;height:2.57292in" /><img src="media/image10.png" style="width:2.56736in;height:3.10417in" />

### Switch背板适配

金丝雀Switch背板支持0,2,4Switch三种方案，不同的switch背板，uid不同，bmc根据uid加载不同类型switch板配置文件。

#### 0Switch方案

##### 3.2.3.1.1原理说明

0 Switch背板不带Switch芯片，BMC与bios按照标准PCIe卡加载流程进行信息交互。BMC根据拓扑配置以及提供的资产信息表，计算PCIe丝印信息，与bios同步socketid，slotid，device，bios通过丝印信息完成PCIe与丝印号的对应关系。

<img src="media/image11.png" style="width:5.75139in;height:3.22014in" />

##### 3.2.3.1.2总体拓扑

I2c_7

├─ Pca9545_EA

│ ├─ CH0 Connector_PCIE_SLOT1

│ ├─ CH1 Connector_PCIE_SLOT2

│ ├─ CH2 Connector_PCIE_SLOT3

│ ├─ CH3 Connector_PCIE_SLOT4

│ ├─ CH4 Connector_PCIE_SLOT5

│ ├─ CH5 Connector_PCIE_SLOT8

│ ├─ CH6 Connector_PCIE_SLOT9

│ └─ CH7 Chip_INA226_80

├─ Pca9545_E4

│ ├─ CH0 Connector_PCIE_SLOT11

│ ├─ CH1 Connector_PCIE_SLOT7

│ ├─ CH2 Connector_PCIE_SLOT6

│ ├─ CH3 Chip_EMC1413_98

│ ├─ CH4 Connector_PCIE_SLOT10

│ └─ CH5 Chip_INA226_82

├─ Chip_Cpld

├─ Eeprom_Switch

└─ Pca9555_40

##### 3.2.3.1.3 关键Chip对象

| **芯片名称**    | **类型** | **描述**                                |
|:----------------|:---------|:----------------------------------------|
| Pca9545_EA      | PCA9545  | Mux for Slot 1-5, 8, 9, Power1          |
| Pca9545_E4      | PCA9545  | Mux for Slot 6, 7, 10, 11, Temp, Power2 |
| Chip_Cpld       | Chip     | CPld升级                                |
| Eeprom_Switch   | EEPROM   | FRU 存储                                |
| Pca9555_40      | PCA9555  | GPIO 扩展                               |
| Chip_INA226_80  | Chip     | 功耗监控 1 (Power1)                     |
| Chip_INA226_82  | Chip     | 功耗监控 2 (Power2)                     |
| Chip_EMC1413_98 | Chip     | 温度监控                                |

传感器配置

<img src="media/image12.png" style="width:5.52083in;height:4.375in" />

<img src="media/image13.png" style="width:5.76319in;height:6.1in" />

升级配置

<img src="media/image14.png" style="width:5.72917in;height:5.97917in" />

##### 3.2.3.4 线缆配置

高速线缆检测核心目标是确保服务器或计算节点中高速信号链路(如PCle、网络接口等)的物理连接与逻辑配置一致，避免因线缆错接、漏接导致的功能异常或性能损失。

配置验证:BMC每分钟比对实际线缆信息(SourcePortID、TargetPortID、组件UID)与PSR(持久化存储)中的白名单配置，确保逻辑与物理拓扑一致.。

<img src="media/image15.png" style="width:5.76181in;height:4.02639in" />

如图，按照天池组件标准设计，B2类型的BCU在单板上规划好了高速连接器的位 置，按照标准高速连接器位置分成4个高速Zone，每个Zone空间定义单独对应一个SMC命令字上报端口的拓扑发现信息，连接器在Zone内按位置编号，一个UBC连接器支持接收2条线缆检测数据， 相应的UBCDD支持4条线缆检测数据；在此背景下，天池线缆检测为每个连接器位置设计了4个线缆检测码流资源，命名为a、b、c、d；对于UBC连机器，只用其中ab两条，UBCDD连接器全部使用，码流名与连机器名连起来定位线缆检测码流数据 。

920新型号基础板线缆检测码流位置编码

<img src="media/image16.png" style="width:5.75833in;height:5.01042in" />

线缆白名单配置

<img src="media/image17.png" style="width:5.75556in;height:2.29792in" />

| **Downstream** | **Name** | **Upstream** | **ID** | **Target** | **Source** |
|:---|:---|:---|:---|:---|:---|
| BusinessConnector_Slot1 | Up_6 | BusinessConnector_6 | 11, 12 | 11, 12 | A1c, A1a |
| BusinessConnector_Slot2 | Up_7 | BusinessConnector_7 | 13, 14 | 13, 14 | A2c, A2a |
| BusinessConnector_Slot3 | Up_8 | BusinessConnector_8 | 15, 16 | 15, 16 | C6a, C7a |
| BusinessConnector_Slot4 | Up_9 | BusinessConnector_9 | 17, 18 | 17, 18 | C4a, C5a |
| BusinessConnector_Slot6 | Up_3 | BusinessConnector_3 | 19 | 19 | B2a |
| BusinessConnector_Slot8 | Up_4 | BusinessConnector_4 | 20, 21 | 20, 21 | D5a, D4a |
| BusinessConnector_Slot9 | Up_5 | BusinessConnector_5 | 22, 23 | 22, 23 | D7a, D6a |
| BusinessConnector_Slot10 | Up_2 | BusinessConnector_2 | 24, 25 | 24, 25 | B3c, B3a |
| BusinessConnector_Slot11 | Up_1 | BusinessConnector_1 | 26, 27 | 26, 27 | B4c, B4a |

#### 4Switch方案

##### 3.2.3.2.1 原理说明

4 Switch基础板CPU通过UBCDD与PCIeSwitch端口连接，2个PCIeSwitch挂在CPU0，2个PCIeSwitch挂在CPU1，4个PCIeSwitch芯片在同一个Switch大板上，PCIeSwitch扩展出的多个PCIeSlot连接PCIeDevice。

4 Switch方案通过在PSR以及Switch背板的CSR中定义SerDes、UBCDD、PCIeSwitch之间关系，组织PCIeDevice的PCIeSilk，与bios对应，实现对PCIe管理。

<img src="media/image18.png" style="width:5.75556in;height:3.25486in" />

##### 3.2.3.2.2 总体拓扑

I2c_7

├─ Pca9545_EA

│ ├─ Connector_PCIE_SLOT1

│ ├─ Connector_PCIE_SLOT2

│ ├─ Connector_PCIE_SLOT3

│ ├─ Connector_PCIE_SLOT4

│ ├─ Connector_PCIE_SLOT5

│ ├─ Connector_PCIE_SLOT8

│ ├─ Connector_PCIE_SLOT9

│ └─ Chip_INA226_80

├─ Pca9545_E0

│ ├─ Connector_PCIE_SLOT15

│ └─ Connector_PCIE_SLOT16

├─ Pca9545_E4

│ ├─ Connector_PCIE_SLOT6

│ ├─ Connector_PCIE_SLOT7

│ ├─ Connector_PCIE_SLOT10

│ ├─ Connector_PCIE_SLOT11

│ ├─ Connector_PCIE_SLOT12

│ ├─ Connector_PCIE_SLOT13

│ ├─ Chip_EMC1413_98

│ └─ Chip_INA226_82

├─ Pca9545_E6

│ ├─ Chip_INA226_88

│ └─ Connector_PCIE_SLOT21

├─ Pca9545_E8

│ ├─ Connector_PCIE_SLOT14

│ ├─ Connector_PCIE_SLOT17

│ ├─ Connector_PCIE_SLOT18

│ ├─ Connector_PCIE_SLOT19

│ ├─ Connector_PCIE_SLOT20

│ └─ Chip_INA226_8A

├─ Chip_Cpld

└─ Eeprom_Switch

##### 3.2.3.2.3 关键Chip对象

| **芯片名称**    | **类型** | **描述**                               |
|:----------------|:---------|:---------------------------------------|
| Pca9545_EA      | PCA9545  | Mux for Slot 1-5, 8, 9, Power1         |
| Pca9545_E0      | PCA9545  | Mux for Slot 15, 16                    |
| Pca9545_E4      | PCA9545  | Mux for Slot 6, 7, 10-13, Temp, Power2 |
| Pca9545_E6      | PCA9545  | Mux for Slot 21, Power3                |
| Pca9545_E8      | PCA9545  | Mux for Slot 14, 17-20, Power4         |
| Chip_Cpld       | Chip     | 逻辑控制                               |
| Eeprom_Switch   | EEPROM   | FRU 存储                               |
| Pca9555_42      | PCA9555  | GPIO 扩展                              |
| Pca9555_44      | PCA9555  | GPIO 扩展                              |
| Chip_INA226_80  | Chip     | 功耗监控 1                             |
| Chip_INA226_82  | Chip     | 功耗监控 2                             |
| Chip_INA226_88  | Chip     | 功耗监控 3                             |
| Chip_INA226_8A  | Chip     | 功耗监控 4                             |
| Chip_EMC1413_98 | Chip     | 温度监控                               |

传感器配置

<img src="media/image19.png" style="width:5.77083in;height:4.19792in" />

<img src="media/image20.png" style="width:5.7625in;height:4.76319in" />

升级配置

<img src="media/image21.png" style="width:4.94792in;height:1.57292in" />

<img src="media/image22.png" style="width:4.45833in;height:4.375in" />

##### 3.2.3.2.4线缆配置

高速线缆检测核心目标是确保服务器或计算节点中高速信号链路(如PCle、网络接口等)的物理连接与逻辑配置一致，避免因线缆错接、漏接导致的功能异常或性能损失。

配置验证:BMC每分钟比对实际线缆信息(SourcePortID、TargetPortID、组件UID)与PSR(持久化存储)中的白名单配置，确保逻辑与物理拓扑一致

<img src="media/image15.png" style="width:5.76181in;height:4.02639in" />

如图，按照天池组件标准设计，B2类型的BCU在单板上规划好了高速连接器的位 置，按照标准高速连接器位置分成4个高速Zone，每个Zone空间定义单独对应一个SMC命令字上报端口的拓扑发现信息，连接器在Zone内按位置编号，一个UBC连接器支持接收2条线缆检测数据， 相应的UBCDD支持4条线缆检测数据；在此背景下，天池线缆检测为每个连接器位置设计了4个线缆检测码流资源，命名为a、b、c、d；对于UBC连机器，只用其中ab两条，UBCDD连接器全部使用，码流名与连机器名连起来定位线缆检测码流数据 。

920新型号基础板线缆检测码流位置编码

<img src="media/image16.png" style="width:5.75833in;height:5.01042in" />

线缆白名单配置

<img src="media/image17.png" style="width:5.75556in;height:2.29792in" />

| **Downstream** | **Name** | **Upstream** | **ID** | **Target** | **Source** |
|:---|:---|:---|:---|:---|:---|
| BusinessConnector_Slot1 ~ 4 | Up_1 | BusinessConnector_1 | 11, 12 | 11, 12 | A1a, A1c |
| BusinessConnector_Slot5 ~ 9 | Up_2 | BusinessConnector_2 | 13, 14 | 13, 14 | D7a, D6a |
| BusinessConnector_Slot10 ~ 13 | Up_3 | BusinessConnector_3 | 15, 16 | 15, 16 | B4a, B4c |
| BusinessConnector_Slot14 ~ 21 | Up_4 | BusinessConnector_4 | 17, 18 | 17, 18 | C5a, C4a |

#### 2Switch方案

##### 3.2.3.2.1 原理说明

2switch背板uid相同，通过mux开关切换进一步区分均衡模式和级联模式。BMC通过读取扩展板smc命令字获取当前模式，加载对应模式的背板。BMC可通过web设置switch模式，将value通过smc命令字设置给扩展板cpld。switch模式的切换下电的时候才可以执行，上电执行会提示请先进行OS下电。

<img src="media/image23.png" style="width:5.75139in;height:3.23264in" />

##### 3.2.3.2.2 总体拓扑

I2c_7

├─ Pca9545_EA

│ ├─ Connector_PCIE_SLOT1

│ ├─ Connector_PCIE_SLOT2

│ ├─ Connector_PCIE_SLOT3

│ ├─ Connector_PCIE_SLOT4

│ ├─ Connector_PCIE_SLOT5

│ ├─ Connector_PCIE_SLOT8

│ ├─ Connector_PCIE_SLOT9

│ └─ Chip_INA226_80

├─ Pca9545_E0

│ ├─ Connector_PCIE_SLOT15

│ └─ Connector_PCIE_SLOT16

├─ Pca9545_E4（7-bit 0x72）

│ ├─ Connector_PCIE_SLOT6

│ ├─ Connector_PCIE_SLOT7

│ ├─ Connector_PCIE_SLOT10

│ ├─ Connector_PCIE_SLOT11

│ ├─ Connector_PCIE_SLOT12

│ ├─ Connector_PCIE_SLOT13

│ ├─ Chip_EMC1413_98

│ └─ Chip_INA226_82

├─ Pca9545_E6

│ ├─ Chip_INA226_88

│ └─ Connector_PCIE_SLOT21

├─ Pca9545_E8

│ ├─ Connector_PCIE_SLOT14

│ ├─ Connector_PCIE_SLOT17

│ ├─ Connector_PCIE_SLOT18

│ ├─ Connector_PCIE_SLOT19

│ ├─ Connector_PCIE_SLOT20

│ └─ Chip_INA226_8A

├─ Chip_Cpld

└─ Eeprom_Switch

##### 3.2.3.2.3 关键Chip对象

| **芯片名称**    | **类型** | **描述**                               |
|:----------------|:---------|:---------------------------------------|
| Pca9545_EA      | PCA9545  | Mux for Slot 1-5, 8, 9, Power1         |
| Pca9545_E0      | PCA9545  |                                        |
| Pca9545_E4      | PCA9545  | Mux for Slot 6, 7, 10-13, Temp, Power2 |
| Pca9545_E6      | PCA9545  | Power3                                 |
| Chip_Cpld       | Chip     | 逻辑控制                               |
| Eeprom_Switch   | EEPROM   | FRU 存储                               |
| Pca9555_42      | PCA9555  | GPIO 扩展                              |
| Chip_INA226_80  | Chip     | 功耗监控 1                             |
| Chip_INA226_82  | Chip     | 功耗监控 2                             |
| Chip_INA226_88  | Chip     | 功耗监控 3                             |
| Chip_EMC1413_98 | Chip     | 温度监控                               |

传感器配置

<img src="media/image19.png" style="width:5.77083in;height:4.19792in" />

<img src="media/image20.png" style="width:5.7625in;height:4.76319in" />

升级配置

<img src="media/image24.png" style="width:5.75417in;height:0.90069in" />

<img src="media/image22.png" style="width:4.45833in;height:4.375in" />

##### 3.2.3.2.4线缆配置

高速线缆检测核心目标是确保服务器或计算节点中高速信号链路(如PCle、网络接口等)的物理连接与逻辑配置一致，避免因线缆错接、漏接导致的功能异常或性能损失。

配置验证:BMC每分钟比对实际线缆信息(SourcePortID、TargetPortID、组件UID)与PSR(持久化存储)中的白名单配置，确保逻辑与物理拓扑一致

<img src="media/image15.png" style="width:5.76181in;height:4.02639in" />

如图，按照天池组件标准设计，B2类型的BCU在单板上规划好了高速连接器的位 置，按照标准高速连接器位置分成4个高速Zone，每个Zone空间定义单独对应一个SMC命令字上报端口的拓扑发现信息，连接器在Zone内按位置编号，一个UBC连接器支持接收2条线缆检测数据， 相应的UBCDD支持4条线缆检测数据；在此背景下，天池线缆检测为每个连接器位置设计了4个线缆检测码流资源，命名为a、b、c、d；对于UBC连机器，只用其中ab两条，UBCDD连接器全部使用，码流名与连机器名连起来定位线缆检测码流数据 。

920新型号基础板线缆检测码流位置编码

<img src="media/image16.png" style="width:5.75833in;height:5.01042in" />

线缆白名单配置

<img src="media/image17.png" style="width:5.75556in;height:2.29792in" />

| **Downstream** | **Name** | **Upstream** | **ID** | **Target** | **Source** |
|:---|:---|:---|:---|:---|:---|
| BusinessConnector_Slot1 ~ 4 | Up_1 | BusinessConnector_1 | 11, 12 | 11, 12 | A1a, A1c |
| BusinessConnector_Slot5 ~ 9 | Up_2 | BusinessConnector_2 | 13, 14 | 13, 14 | D7a, D6a |
| BusinessConnector_Slot10 ~ 13 | Up_3 | BusinessConnector_3 | 15, 16 | 15, 16 | B4a, B4c |
| BusinessConnector_Slot14 ~ 21 | Up_4 | BusinessConnector_4 | 17, 18 | 17, 18 | C5a, C4a |

### 电源转接板

#### 功能背景

金丝雀支持电源3+3冗余，原本扩展版电源接口不足以连接3+3数量的电源，需要在扩展板与PSU之间增加扩展电源接口的转接板：RPEB。

RPEB：Redundant Power Expansion Board

功能描述：

- 满足天池规范

- 扩展3个CRPS电源接口

- 透传BMC、CPLD与PSU之间的通信，比如扫描电源在位信息等

- Eeprom存储sr文件，可以进行向下自发现，可以进行sr升级

- 包含一个温度监测点

#### 总体拓扑

I2c_3

├─ Pca9545_psu0

│ ├─ Connector_PSU1

│ ├─ Connector_PSU2

│ └─ Connector_PSU3

└─ Pca9545_psu1

├─ Connector_PSU4

├─ Connector_PSU5

└─ Connector_PSU6

BMC I2C3 总线通过扩展版上PCA9545扩展成两路I2C Mux总线，分别连接两个电源转接板。

硬件自发现流程如下：

<img src="media/image25.png" style="width:5.56319in;height:2.79097in" />

两个电源转接板在自发现时复用同一个CSR文件，通过扩展版传递的SlotId进行区分和计算电源模块的PsuSlot，进行下级自发现。

#### 总线配置

<img src="media/image26.png" style="width:1.675in;height:3.63403in" />

I2cMux：来自扩展板的PCA9545的扩展通道，总线上挂载的实体chip包含Eeprom_RPEB、Lm75_RPEBTemp等。

I2c_2：来自扩展板，提供PSU和扩展板CPLD通信的线路。

#### 关键Chip对象

| **芯片名称**    | **类型** | **描述**                      |
|:----------------|:---------|:------------------------------|
| Eeprom_Rpeb     | Fru      | FRU 存储                      |
| Eeprom_PsuChip1 | Chip     | 软件定义，存储PsuSlot相关信息 |
| Eeprom_PsuChip2 | Chip     | 软件定义，存储PsuSlot相关信息 |
| Eeprom_PsuChip3 | Chip     | 软件定义，存储PsuSlot相关信息 |
| Lm75_Temp       | Lm75     | 电源板上温度检测点            |



- Eeprom_RPEB：存储电源转接板的sr文件，配置如下：

"Eeprom_RPEB": {

"HealthStatus": 0,

"Address": 174,

"AddrWidth": 1,

"OffsetWidth": 2,

"WriteTmout": 100,

"ReadTmout": 100

}

- Lm75_RPEBTemp：电源转接板的温度监测点，配置如下。

"Lm75_RPEBTemp": {

"HealthStatus": 0,

"PowerStatus": 1,

"SelfTestResult": 1,

"Address": 152,

"AddrWidth": 1,

"OffsetWidth": 1,

"WriteTmout": 0,

"ReadTmout": 0

}

"Scanner_Lm75_rpeb": {

"Chip": "#/Lm75_RPEBTemp",

"Mask": 255,

"Offset": 0,

"Type": 0,

"Period": 1000,

"Size": 1,

"Debounce": "#/MidAvg_RPEBTemp"

}

"MidAvg_RPEBTemp": {

"WindowSize": 4,

"DefaultValue": 20,

"IsSigned": true

}

- 用于业务需要的配置Eeprom_PsuChip0、Eeprom_PsuChip1、Eeprom_PsuChip2，关联PsuSlot对象和存储PSU在位信息。

"Eeprom_PsuChip0": {

"HealthStatus": 0,

"Address": 176,

"AddrWidth": 1,

"OffsetWidth": 1,

"WriteTmout": 30,

"ReadTmout": 30,

}

- Smc_ExpBoardSMC：配置Scanner扫描器，读取PSU在位信息，操作Eeprom写保护寄存器。

"Smc_ExpBoardSMC": {

"HealthStatus": 0,

"PowerStatus": 1,

"SelfTestResult": 1,

"Address": 96,

"AddrWidth": 1,

"OffsetWidth": 1,

}

"Scanner_PS0Pres": {

"Chip":"#/Smc_ExpBoardSMC",

"Mask": 1,

"Offset": 603981056,

"Type": 0,

"Period": 2000,

"Size": 3

}

"Accessor_RPEBWP": {

"Chip":"#/Smc_ExpBoardSMC",

"Mask": 255,

"Offset": 117766,

"Type": 0,

"Size": 1,

"Value": 0

}

- 向下提供三个Connector用于电源自发现，下级Slot通过自身Slot计算得出，Slot1对应电源Slot1、2、3，Slot2对应电源Slot4、5、6，Bom、Id、AuxId分别配置为："14191046"、"PSU"、"0"。

"Connector_PSU_0": {

"Buses": \[

"I2c_2",

"I2cMux_0"

\],

"Bom": "14191046",

"Slot": "\${Slot} \|\> expr(((\$1 - 1) \* 3) + 1)",

"Presence": "\<=/Scanner_Smc_ExpBoardSMC_PS1Pres.Value",

"Id": "PSU",

"AuxId": "0",

"SystemId": "\${SystemId}",

"ManagerId": "\${ManagerId}",

"SilkText": "psu1",

"IdentifyMode": 2,

"Type": "Psu",

"Position": 11,

"ChassisId": "\${ChassisId}"

}

业务视图配置如下：

<img src="media/image27.png" style="width:5.76111in;height:1.99792in" />

- PsuSlot：PSU slot配置信息。

"PsuSlot_0": {

"SlotNumber": "#/Connector_PSU_1.Slot",

"SlotI2cAddr": 176,

"Presence": "\<=/Scanner_Smc_ExpBoardSMC_PS1Pres.Value",

"PsuChip": "#/Eeprom_PsuChip1",

"IsSupportPowerOnUpgrade": true

}

- RPEBTemp：ThresholdSensor配置，温度上报。

"DftLm75_1": {

"Id": 1,

"Type": 1,

"DeviceNum": 0,

"ItemName": "LM75 For RPEB Temp",

"PrompteReady": "",

"PrompteFinish": "",

"ProcessPeriod": 65535,

"RefChip": "#/Lm75_RPEBTemp"

}

"Entity_AirRPEB": {

"Id": 55,

"Instance": 96,

"Slot": 255,

"Name": "AirRPEB",

"PowerState": 1,

"Presence": 1,

"BelongsToSystem": false

}

"ThresholdSensor_RPEBTemp": {

"EntityId": "\<=/Entity_AirRPEB.Id",

"EntityInstance": "\<=/Entity_AirRPEB.Instance",

"SensorIdentifier": "RPEB Temp",

"SensorName": "RPEB Temp",

"Reading": "\<=/Scanner_Lm75_RPEBTemp_rpeb.Value",

"ReadingStatus": "\<=/Scanner_Lm75_RPEBTemp_rpeb.Status",

"RBExp": 224,

"Analog": 1,

"NominalReading": 25,

"NormalMaximum": 0,

"NormalMinimum": 0,

"MaximumReading": 127,

"MinimumReading": 128,

}

### 风扇板适配

#### 功能背景

风扇板（CLU - Cooling Unit）作为服务器散热系统的核心组件，需要通过 VPD（Vital Product Data）模块进行配置化适配。

适配硬件：

1.  中风扇板：

> 位置: CLU1（中置风扇板）
>
> 风扇数量: 8 个（Fan 1-8）
>
> BoardID: 00000002052000223001
>
> 型号: FanBoard_Middle
>
> BOM: 14100363

2.  前风扇板：

> 位置: CLU2（前置风扇板）
>
> 风扇数量: 5 个（Fan 9-13）
>
> BoardID: 00000002052000223002
>
> 型号: FanBoard_Front
>
> BOM: 14100363

#### 总体架构

风扇板适配系统采用四层架构：

<img src="media/image28.jpeg" style="width:2.23125in;height:4.60625in" />

1、硬件层：物理风扇（13个）、风扇板 SMC（I2C 0xAE）、扩展板 SMC（I2C 0x60）；

2、HWProxy 层：加载 SR 文件，实例化对象（Fan/Scanner/Accessor），通过 I2C 读写硬件寄存器；

3、应用层：热管理（ThermalMgmt）、电源管理（PowerMgmt）、事件管理（EventMgmt），通过 DBus 通信；

4、北向接口层：对外提供 Redfish/IPMI 接口，映射到 DBus 调用；

数据流：

读取：硬件寄存器 → Scanner → DBus → 应用层 → Redfish API

写入：Redfish API → DBus → Accessor → 硬件寄存器

设计原则：配置驱动（SR 文件）、分层解耦（DBus 通信）、事件驱动（信号订阅）

#### 适配流程

1\. 确定硬件规格

├─ 风扇数量和位置

├─ SMC 芯片型号和通信协议

└─ I2C 总线地址分配

2\. 创建 SR 文件

├─ ManagementTopology（硬件拓扑）

├─ Chip 对象（SMC、EEPROM、CPLD）

└─ Scanner/Accessor（寄存器读写）

3\. 配置风扇对象

├─ FanType（风扇类型定义）

├─ Connector（连接器，支持双转子/单转子）

├─ Fan（风扇基础信息）

└─ CoolingFan（调速系统使用）

4\. 配置异常处理

├─ AbnormalFan（风扇不在位/转速异常）

└─ Event（事件上报）

5\. 更新打包配置

└─ profile.txt（添加 SR 文件路径）

6\. 构建验证

#### 风扇对象管理

风扇对象：

FanBoard（风扇板）

├── FanType（风扇类型）

│ ├── Name: "AVC 8080+"

│ ├── FrontMaxSpeed: 16900

│ ├── RearMaxSpeed: 12800

│ └── IdentifyRange: \[5850, 9350\]

├── Connector（连接器）×16

│ ├── Connector_Fan1DualSensor

│ └── Connector_Fan1SingleSensor

├── Fan（风扇硬件信息）×8/5

│ ├── FanId, Slot, Coefficient

│ ├── FrontPresence, RearPresence

│ ├── FrontSpeed, RearSpeed

│ ├── FrontStatus, RearStatus

│ ├── HardwarePWM

│ └── IdentifySpeedLevel: 50

├── CoolingFan（调速对象）×8/5

│ ├── FanId

│ ├── FrontPresence, RearPresence

│ ├── FrontStatus, RearStatus

│ └── HardwarePWM

└── AbnormalFan（异常调速）×26

├── Id, FanIdx

├── Status: NotInPosition / AbnormalRotation

└── FanGroup: \[1,2,...,13\]

风扇识别算法：

1.  读取 FanType 对象，获取识别范围 \[IdentifyRangeLow, IdentifyRangeHigh\]；

2.  设置 Fan 的 PWM 为 IdentifySpeedLevel（50%）

3.  等待转速稳定（约 2-3 秒）

4.  读取前转子或后转子转速

5.  判断转速是否在识别范围内：

> 在范围内：双转子风扇，IsTwins = true
>
> 不在范围内：单转子风扇，IsTwins = false

6.  更新 Connector 的 Presence：

> 双转子：Connector_Fan1DualSensor.Presence = 1, Connector_Fan1SingleSensor.Presence = 0
>
> 单转子：Connector_Fan1DualSensor.Presence = 0, Connector_Fan1SingleSensor.Presence = 1

#### 风扇对象数据结构

SR 文件数据结构：

{

"FormatVersion": "String", // 格式版本，如 "3.00"

"DataVersion": "String", // 数据版本，如 "5.01"

"Unit": { // 单元信息

"Type": "String", // 类型：CLU/BCU/EXU等

"Name": "String" // 名称：FanBoard_1等

},

"ManagementTopology": { // 硬件拓扑

"Anchor": {}, // 锚点，总线列表

"I2c_X": {}, // I2C 总线定义

"Spi_X": {}, // SPI 总线定义

"JtagOverLocalBus_X": {} // JTAG 总线定义

},

"Objects": {} // 对象集合

}

FanType 对象结构：

{

"Name": "String", // 风扇名称

"Index": "U8", // 索引

"IsDefaultType": "Bool", // 是否默认类型

"IsTwins": "Bool", // 是否双转子

"FrontMaxSpeed": "U16", // 前转子最大转速 RPM

"RearMaxSpeed": "U16", // 后转子最大转速 RPM

"IdentifyRangeLow": "U16", // 识别转速下限

"IdentifyRangeHigh": "U16", // 识别转速上限

"PartNumber": "String", // 部件号

"BOM": "String", // BOM 编码

"SystemId": "U8", // 系统 ID

"SpeedRange": "U16\[\]", // 转速百分比数组

"PowerRange": "U16\[\]", // 功率 mW 数组

"FanDiameterMm": "U16" // 风扇直径 mm

}

Fan 对象结构：

{

"FanId": "U16", // 风扇 ID

"Slot": "U8", // 槽位号

"Coefficient": "U8", // 转速系数

"FrontPresence": "Expression", // 前转子在位

"RearPresence": "Expression", // 后转子在位

"FrontSpeed": "Expression", // 前转子转速

"RearSpeed": "Expression", // 后转子转速

"FrontStatus": "U8", // 前转子状态

"RearStatus": "U8", // 后转子状态

"HardwarePWM": "Expression", // PWM 占空比

"SystemId": "U8", // 系统 ID

"MaxSupportedPWM": "U32", // 最大 PWM 值

"IdentifySpeedLevel": "U8", // 识别转速百分比

"Position": "Expression", // 位置信息

"PowerGood": "Expression" // 电源状态

}

CoolingFan 对象结构：

"CoolingFan_1_1": {

"FanId": 1,

"FrontPresence": "\<=/Fan_1.FrontPresence",

"RearPresence": "\<=/Fan_1.RearPresence",

"FrontStatus": "\<=/Fan_1.FrontStatus",

"RearStatus": "\<=/Fan_1.RearStatus",

"HardwarePWM": "#/Accessor_Smc_FanBoardSMC_Fan1PWM.Value",

"Slot": 1,

"MaxSupportedPWM": 255

}

CoolingFan 与Fan对象的区别：

| 项目     | Fan对象                      | CoolingFan对象 |
|:---------|:-----------------------------|:---------------|
| 用途     | 风扇硬件信息管理             | 调速系统使用   |
| 转速信息 | 包含（FrontSpeed/RearSpeed） | 不包含         |
| 在位信息 | 直接读取 Scanner             | 同步 Fan 对象  |

AbnormalFan 对象不在位结构：

"AbnormalFan_1": {

"Id": 1,

"FanIdx": 1,

"Status": "NotInPosition", //不在位异常配置

"FanGroup": \[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13\]

}

描述：当 Fan1 不在位时，所有风扇（1-13）拉满转（默认 100%）。

AbnormalFan 对象转速异常结构：

"AbnormalFan_1": {

"Id": 1,

"FanIdx": 1,

"Status": "AbnormalRotation", //不在位异常配置

"FanGroup": \[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13\]

}

描述：当 Fan1 转速异常时，所有风扇拉满转。

### 硬盘背板适配

<span id="_Toc521917694" class="anchor"></span>

## Web前端

### 3.2.1电源适配

#### 3.2.1.1 功能背景

金丝雀支持电源3+3冗余，原本扩展版电源接口不足以连接3+3数量的电源，需要与电源转接板更新同步，实现web的展示和手动的配置3+3功能。

功能描述：

- 实现3主用电源配置

- 展示当前电源的在位信息，包括所有电源的主备状态

- 实现友好的使用提示和异常操作阻止和判断

#### 3.2.1.2 数据和字段说明

请求：/UI/Rest/System/PowerSupply

类型： get

返回数据：

DeepSleep: string;

深度睡眠状态

PowerMode: string;

电源模式

NormalAndRedundancy: string;

是否启用主备模式

ExpectedSupplyList: IPowerSupplyItem\[\];

期望电源列表

{

Name: 电源名称;

Mode: 工作模式;

Manufacturer: 厂商

ProductionDate: 生产日期

Model: 型号

OutputVoltage: 输出电压;

FirmwareVersion: 固件版本

SerialNumber: 序列号

LineInputVoltage: 输入电压

InputWatts: 输入功率

PowerCapacityWatts: 额定功率

}

PowerConsumedWatts: number;

当前总功耗 (瓦)

DeepSleepSupported: boolean;

是否支持深度睡眠

ActiveStandbySupported: boolean;

是否支持主备模式

SupplyList: IPowerSupplyItem\[\];

电源列表

{

Manufacturer: 厂商

PartNumber: 部件编号

Model: 类型

ManufactureDate: 生产日期

Mode: 工作模式;

OutputVoltage: 输出电压

FirmwareVersion: 固件版本

InputWatts: 输入功率

SerialNumber: 序列号

Name: 电源名称;

LineInputVoltage: 输入电压

> PowerSupplyChannel: 电源通道

PowerSupplyType: 电源类型

Position: 物理位置

}

RecommendedPowerMode: string;

推荐电源模式

RecommendedActiveSupplies: number\[\];

推荐主用电源列表

核心新增变量（仅用于前端判断）：

IsCRPS: 电源类型是否为CRPS

请求： /UI/Rest/System/PowerSupply

类型：patch

configParam （只有当有变化时该数据才会有对应的值）

{

"SupplyList": \[ // 电源列表。

{

"Name": "PSU1", // 电源名称

"Mode": "Active" // 模式："Active" (主用) 或 "Standby" (备用)

},

\]

}

#### 3.5.1.3 总体流程

<img src="media/image29.png" style="width:3.76667in;height:1.60694in" />

**业务流程图**

## 散热策略

金丝雀服务器是一款 6U AI 服务器，配备 13 个 8080 双转子风扇，需要实现智能散热调速以平衡散热效果、能耗和噪音。

### 整体架构

<img src="media/image30.jpeg" style="width:2.38542in;height:5.1625in" />

CoolingArea用于关联温度点（RequirementIdx）、参与调速的风扇(FanIdxGroup)和调速策略(PolicyIdxGroup)；CoolingArea与CoolingRequirement应一一对应；CoolingArea只能配置到PSR中（区分单电源和双电源）；CoolingRequirement一般跟随单板所在的SR配置。

### 配置对象层次结构

<img src="media/image31.png" style="width:2.62361in;height:3.88889in" />

### CoolingConfig_1（全局配置对象）

{

  "CoolingConfig_1": {

    "SmartCoolingState": "Enabled",           // 智能调速使能状态

    "SmartCoolingMode": "EnergySaving",       // 当前调速模式

    "LevelPercentRange": \[10, 100\],           // 转速百分比范围

    "InitLevelInStartup": 100,                // BMC 启动初始转速

    "FanBoardNum": 2,                         // 风扇板数量（金丝雀双板）

    "DiskRowTemperatureAvailable": false,     // 硬盘行温度是否可用

    "SysHDDsMaxTemperature": 0,               // 系统硬盘最高温度

    "SysSSDsMaxTemperature": 0                // 系统 SSD 最高温度

  }

}

字段说明：

<table>
<colgroup>
<col style="width: 22%" />
<col style="width: 11%" />
<col style="width: 6%" />
<col style="width: 42%" />
<col style="width: 16%" />
</colgroup>
<thead>
<tr>
<th style="text-align: left;">字段</th>
<th style="text-align: left;">类型</th>
<th style="text-align: left;">必填</th>
<th style="text-align: left;">说明</th>
<th style="text-align: left;">默认值</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: left;">SmartCoolingState</td>
<td style="text-align: left;">String</td>
<td style="text-align: left;">是</td>
<td style="text-align: left;">"Enabled"/"Disabled"</td>
<td style="text-align: left;">Enabled</td>
</tr>
<tr>
<td style="text-align: left;">SmartCoolingMode</td>
<td style="text-align: left;">String</td>
<td style="text-align: left;">是</td>
<td style="text-align: left;"><p>当前模式：</p>
<p>EnergySaving</p>
<p>HighPerformance</p>
<p>LowNoise</p>
<p>Custom</p></td>
<td style="text-align: left;">EnergySaving</td>
</tr>
<tr>
<td style="text-align: left;">LevelPercentRange</td>
<td style="text-align: left;">Array[2]</td>
<td style="text-align: left;">是</td>
<td style="text-align: left;">[最小转速%, 最大转速%]</td>
<td style="text-align: left;">[10, 100]</td>
</tr>
<tr>
<td style="text-align: left;">InitLevelInStartup</td>
<td style="text-align: left;">U8</td>
<td style="text-align: left;">是</td>
<td style="text-align: left;">BMC 复位到 PID 接管前的初始转速</td>
<td style="text-align: left;">100</td>
</tr>
<tr>
<td style="text-align: left;">FanBoardNum</td>
<td style="text-align: left;">U8</td>
<td style="text-align: left;">是</td>
<td style="text-align: left;">含调速风扇的风扇板个数</td>
<td style="text-align: left;">1</td>
</tr>
</tbody>
</table>

### Policy 6 - 节能模式（默认）

{

  "CoolingPolicy_1_6": {

    "PolicyIdx": 6,

    "PolicyType": 1,                          // 1=InletCustom（进风口自定义）

    "ExpCondVal": "EnergySaving",

    "ActualCondVal": "\<=/CoolingConfig_1.SmartCoolingMode",

    "Hysteresis": 1,                          // 迟滞量 1℃

    "TemperatureRangeLow": \[

      -127, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30,

      31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45

    \],

    "TemperatureRangeHigh": \[

      20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,

      32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 127

    \],

    "SpeedRangeLow": \[

      35, 35, 35, 35, 35, 35, 36, 37, 38, 39, 40, 42,

      45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 100, 100, 100

    \],

    "SpeedRangeHigh": \[

      35, 35, 35, 35, 35, 35, 36, 37, 38, 39, 40, 42,

      45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 100, 100, 100

    \]

  }

}

字段说明：

| 温度区间 (℃)  | 转速 (%) | 说明                   |
|:--------------|:---------|:-----------------------|
| Ta ≤ 20       | 35       | 基础转速，保持低功耗   |
| 20 \< Ta ≤ 25 | 35       | 维持低速运行           |
| 25 \< Ta ≤ 30 | 36-40    | 开始缓慢提速           |
| 30 \< Ta ≤ 35 | 42-60    | 温度升高，加快提速     |
| 35 \< Ta ≤ 40 | 65-80    | 进入高温区，快速提速   |
| 40 \< Ta ≤ 45 | 85-100   | 接近告警温度，冲刺满转 |
| Ta \> 45      | 100      | 满转保护               |

迟滞控制机制：

温度上升时立即按曲线调整转速

温度下降时需低于 TemperatureRangeLow - Hysteresis 才降速

防止温度临界点附近频繁切换转速

### Policy 7 - 高性能模式

{

  "CoolingPolicy_1_7": {

    "PolicyIdx": 7,

    "PolicyType": 1,

    "ExpCondVal": "HighPerformance",

    "ActualCondVal": "\<=/CoolingConfig_1.SmartCoolingMode",

    "Hysteresis": 1,

    "TemperatureRangeLow": \[...\],  // 同 Policy 6

    "SpeedRangeLow": \[

      35, 35, 36, 36, 37, 37, 38, 39, 40, 42, 44, 47,

      50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 100, 100, 100, 100

    \]

  }

}

与节能模式的差异：

Ta 30℃ 时：节能模式 40% vs 高性能 44%

Ta 35℃ 时：节能模式 60% vs 高性能 65%

更快响应温度变化，散热更积极

### Policy 8 - 低噪音模式

{

  "CoolingPolicy_1_8": {

    "PolicyIdx": 8,

    "PolicyType": 1,

    "ExpCondVal": "LowNoise",

    "ActualCondVal": "\<=/CoolingConfig_1.SmartCoolingMode",

    "Hysteresis": 1,

    "SpeedRangeLow": \[

      30, 31, 32, 33, 34, 35, 35, 35, 36, 36, 37, 40,

      45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 100, 100, 100

    \]

  }

}

特点：

Ta ≤ 20℃ 时仅 30%（比节能模式低 5%）

低温区保持更低转速以降低噪音

高温区（\>35℃）与节能模式一致，保障散热
