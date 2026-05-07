**青隼_0SW背板_单板详细设计报告**

> **拟 制：<u>­­\_ 丁 雪 \_ </u>**
>
> **审 核：<u>\_\_周加洋\_\_</u>**
>
> **批 准：<u>\_\_王钟一\_\_</u>**

# 目录

[概述 [4](#_Toc221196717)](#_Toc221196717)

[**1.1** **保密说明** [4](#_Toc221196718)](#_Toc221196718)

[**1.2** **版本历史** [4](#_Toc221196719)](#_Toc221196719)

[**1.3** **术语** [4](#_Toc221196720)](#_Toc221196720)

[**1.4** **参考文档** [4](#_Toc221196721)](#_Toc221196721)

[**1.5** **背景** [5](#_Toc221196722)](#_Toc221196722)

[2 单板总体说明 [5](#_Toc221196723)](#_Toc221196723)

[**2.1** **单板总体框图** [5](#_Toc221196724)](#_Toc221196724)

[**2.2** **CPLD选型** [7](#_Toc528584792)](#_Toc528584792)

[3 单板各模块的详细设计 [7](#_Toc221196726)](#_Toc221196726)

[**3.1** **CPLD模块** [7](#_Toc528257395)](#_Toc528257395)

[**3.1.1** **滤波模块** [7](#_Toc528584796)](#_Toc528584796)

[**3.1.2** **LED指示灯控制模块** [8](#_Toc528584797)](#_Toc528584797)

[**3.1.3** **电源控制** [8](#_Toc221196730)](#_Toc221196730)

[**3.1.4** **PCIE RESET** [8](#_Toc221196731)](#_Toc221196731)

[**3.1.5** **CPLD更新** [8](#_Toc221196732)](#_Toc221196732)

[**3.1.6** **CPLD与BMC通信模块** [9](#_Toc221196733)](#_Toc221196733)

[**3.2** **EEPROM模块** [10](#_Toc221196734)](#_Toc221196734)

[**3.3** **各模块之间的总线设计** [10](#_Toc221196735)](#_Toc221196735)

[**3.3.1** **SMBus/I2C拓扑** [10](#_Toc221196736)](#_Toc221196736)

[**3.3.2** **JTAG链路** [12](#_Toc221196737)](#_Toc221196737)

[**3.3.3** **SGPIO模块** [12](#_Toc221196738)](#_Toc221196738)

[**3.4** **单板电源设计** [12](#_Toc221196739)](#_Toc221196739)

[**3.5** **单板接口/连接器pin定义** [12](#_Toc221196740)](#_Toc221196740)

[**3.5.1** **内部接口** [12](#_Toc221196741)](#_Toc221196741)

[**3.5.2** **外部接口** [15](#_Toc221196742)](#_Toc221196742)

[**3.5.3** **调试接口** [17](#_Toc221196743)](#_Toc221196743)

[**3.5.4** **板卡关键器件丝印** [17](#_Toc221196744)](#_Toc221196744)

[4 单板PCB和信号完整性设计 [18](#_Toc221196745)](#_Toc221196745)

[**4.1** **PCB叠层设计** [18](#_Toc517452102)](#_Toc517452102)

[**4.2** **PCB走线设计** [20](#_Toc517452103)](#_Toc517452103)

[**4.3** **高速信号SI仿真和评估** [23](#_Toc221196748)](#_Toc221196748)

[5 单板结构相关设计 [23](#_Toc221196749)](#_Toc221196749)

[**5.1** **定位孔、禁布区和尺寸说明** [23](#_Toc221196750)](#_Toc221196750)

[**5.2** **特殊结构件** [24](#_Toc221196751)](#_Toc221196751)

<span id="_Toc221196717" class="anchor"></span>**概述**

1.  <span id="_Toc221196718" class="anchor"></span>**保密说明**

> **本技术文档为软通华方公司的机密文件，未经许可，不得复制和传播。**

2.  <span id="_Toc221196719" class="anchor"></span>**版本历史**

| **作者** | **描述** | **版本** | **日期** |
|:---------|:---------|----------|----------|
| 丁雪     | 更新模板 | 1.0      | 20260205 |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |

3.  <span id="_Toc221196720" class="anchor"></span>**术语**

> **本文档中提到的所有术语、缩写等解释**

| **术语** | **描述**                          |
|:---------|:----------------------------------|
| CPLD     | Complex Programmable Logic Device |
| JTAG     | Joint Test Action Group           |
| I2C      | Inter-Integrated Circuit          |
|          |                                   |
|          |                                   |
|          |                                   |
|          |                                   |
|          |                                   |
|          |                                   |
|          |                                   |

4.  <span id="_Toc221196721" class="anchor"></span>**参考文档**

| **文档名** | **描述** | **版本** | **日期** |
|------------|----------|----------|----------|
|            |          |          |          |
|            |          |          |          |
|            |          |          |          |
|            |          |          |          |
|            |          |          |          |
|            |          |          |          |
|            |          |          |          |
|            |          |          |          |
|            |          |          |          |

5.  <span id="_Toc221196722" class="anchor"></span>**背景**

> 青隼服务器是软通华方公司自验的4U AI服务器，配置灵活，可广泛适用于大规模模型训练、数据库、云端推理等业务负载。该单板是0SW板卡，用于连接主板，扩展PCIE插槽，支持最大8张双宽GPU直连CPU。

1.  <span id="_Toc221196723" class="anchor"></span>**单板总体说明**

    1.  <span id="_Toc221196724" class="anchor"></span>**单板总体框图**

> 青隼0SW板的作用是扩展CPU的PCIe接口，用于接PCIe标卡形态的RAID卡，网卡等部件，0SW板通过软连接的方式和基础板互连，通过搭配特定的结构件装配到机箱后部。该背板使用安路的EF2L45BG256型号CPLD，支持PCIE信息、在位信息的上报等功能。BMC可以通过I2C进行CPLD升级。
>
> 0SW背板的板卡拓扑如下图所示：
>
> <img src="media/image1.png" style="width:4.61206in;height:5.4643in" />
>
> 图 1 0SW背板板卡拓扑
>
> 上行PCIe资源判定参考下表的MCIO x8连接器的Address信号将低电平传输给主板，上行根据实际使用情况，将对应连接的PCIe带宽分配为X16或者X8，背板通过PCIE_PORT0_ID信号状态上报下行PCIe设备，判断方式如下：

<img src="media/image2.png" style="width:5.25648in;height:2.7146in" />

> 图 2 CPU PCIe地址分配方式

2.  <span id="_Toc528584792" class="anchor"></span>**CPLD选型**

> 背板选用安路的EF2L45BG256，资源情况如下表所示。
>
> 表 1安路 EF2L45BG256资源

| **器件**    | **LUTs** | **registers** | **IO pin** |
|:------------|:---------|:--------------|:-----------|
| EF2L45BG256 | 4480     | 4480          | 206        |
| 预估资源    | 46.43%   | 19.53%        | 59         |

2.  <span id="_Toc221196726" class="anchor"></span>**单板各模块的详细设计**

    1.  <span id="_Toc528257395" class="anchor"></span>**CPLD模块**

> 系统时钟、复位处理模块输入输出端口框图如下图所示：
>
> ![](media/image3.emf)
>
> 系统时钟、复位做为整个系统代码正常运行的基础。首先，由于时钟信号在传输中容易因信号衰减、干扰等原因发生相位偏移或漂移，PLL通过引入反馈机制，使输出时钟与输入时钟在相位上保持一致，从而消除了输入时钟信号的相位抖动和漂移问题，提高了时序稳定性和系统性能。另外将时钟引入PLL,通过分频、倍频，也能得到我们代码所需的其他时钟。PLL使用芯片自带硬核资源，根据实际使用情况选择参数，如下图：
>
> <img src="media/image4.png" style="width:2.39514in;height:1.91806in" /><img src="media/image5.png" style="width:2.42639in;height:1.89583in" />
>
> LOCK信号作为一个重要标志，表示输出时钟已稳定锁定。将该信号作为解系统复位的标志，即当lock信号拉高时刻开始计数，计数一定时钟周期后，计数器不变，系统解复位，从初始化状态开始运行。实现的时序图如下图所示。
>
> ![](media/image6.emf)

1.  <span id="_Toc528584796" class="anchor"></span>**信号同步化模块**

> 如果输入信号来自异步时钟域(比如FPGA芯片外部的输入)，一般采用同步器进行同步。最基本的结构是两个紧密相连的触发器，第一拍将输入信号同步化，同步化后的输出可能带来建立/保持时间的冲突，产生亚稳态。需要再寄存一拍，减少(注意是减少)亚稳态带来的影响。这种最基本的结构叫做电平同步器。

<img src="media/image7.png" style="width:4.17048in;height:1.93239in" />‌

2.  **滤波模块**

> 系统输入的某些重要信号，一般会作为状态上传到BMC，或者完成相应逻辑判断，但是受到信号干扰等外界影响，造成误上报或逻辑判断失误等后果，因此一般此类重要信号需进行滤波后使用。在switch应用中，CPLD会根据电源的PG信号，拉高后级电源的使能信号，因此PG信号要做滤波处理。滤波模块输出端口框图框图如下：
>
> ![](media/image8.emf)
>
> 设计思路：使用连续的三个clk_pulse脉冲信号对输入信号signal_in进行采样，三次采用的值相同，则认为输入信号有效，时序图如下图所示：
>
> ![](media/image9.emf)

3.  <span id="_Toc528584797" class="anchor"></span>**PCIE RESET模块**

> 由于switch板后挂了许多PCIE设备，CPLD负责对这些PCIE设备进行复位解复位逻辑，功能框图：
>
> ![](media/image10.emf)
>
> 后级PCIE设备的解复位，要同时满足主板上电初始化完成，主板发出的PERST解复位及SW板0.8V电POWERGOOD。

4.  **CPLD与BMC通信模块**

> CPLD与BMC之间通过I2C进行数据的交互通信，CPLD I2C的地址为0110_000(x). BMC进行数据读写的数据格式如下所示。
>
> 下图是BMC写数据给CPLD的数据格式。

<figure>
<img src="media/image11.emf" />
<figcaption><p>BMC写数据格式</p></figcaption>
</figure>

> 下图是BMC从CPLD读数据格式。

<figure>
<img src="media/image12.emf" />
<figcaption><p>BMC读数据格式</p></figcaption>
</figure>

> 具体的数据格式如下表所示，详见CPLD接口文档。

![](media/image13.emf)![](media/image14.emf)

5.  **SGPIO通信模块**

> 0 switch板需要来自主板发送的主板上电状态完成信号，用来做后级PCIE设备的PCIE RESET逻辑。因此主板与switch板选择使用SGPIO通信，SGPIO通信模块如下图所示：

![](media/image15.emf)

> 主板发送给switch的数据格式如下表：

| 比特位 | switch卡信号 | 含义                 |
|--------|--------------|----------------------|
| 0      | pwr_but      | 主板上电、初始化完成 |

> **备注：需与主板CPLD开发人员商定bit流按位对应，否则接收与发送不一致。**

6.  **点灯模块**

> LED指示灯状态信息如下表所示：

<table style="width:81%;">
<colgroup>
<col style="width: 18%" />
<col style="width: 13%" />
<col style="width: 48%" />
</colgroup>
<thead>
<tr>
<th style="text-align: left;"><strong>LED Name</strong></th>
<th style="text-align: left;"><strong>Color</strong></th>
<th style="text-align: left;"><strong>LED behavior definition</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td rowspan="2" style="text-align: left;">CPLD心跳灯</td>
<td rowspan="2" style="text-align: left;">绿色</td>
<td style="text-align: left;">绿色1hz闪烁：CPLD工作正常</td>
</tr>
<tr>
<td style="text-align: left;">熄灭：CPLD未工作</td>
</tr>
</tbody>
</table>

> CPLD心跳指示灯输入输出端口如下图所示，该模块在内部进行计数等处理，产生1Hz占空比50%的方波输出到外部LED进行点灯。

![](media/image16.emf)

7.  **CPLD FW刷新模块**

> 通过JTAG和I2C总线可以分别用来升级switch CPLD FW，switch板上存在一个JTAG header,用于debug阶段的功能调试和升级，BMC的I2C总线用于远程在线升级switch板CPLD，下图是对应的逻辑框图：

![](media/image17.emf)

> 为了保证0switch板CPLD的可维护性，BMC可以通过I2C总线进行CPLD的在线升级。0switch板升级只在关机状态下，CPLD的IO口变化不会影响0switch板的功能。BMC通过I2C通道实现CPLD内部flash及SRAM的升级，实现CPLD的功能升级。

8.  **拓扑检测码流上报模块**

> ![](media/image18.emf)
>
> 拓扑检测码流发送链路层采用Hisport 协议传输，帧长度41字节，各字节具体内容如下图。由0switch板发送以下信息，经线缆中的单根信号路由到主板CPLD，经过解析后发送给BIOS和BMC，BMC依据解析出来的CableID、Index、UID来判断组件类型以及线缆是否插错，BIOS根据上报的28-32字节，对挂载的端口模式进行配置。

<img src="media/image19.png" style="width:4.59722in;height:2.69931in" />

<img src="media/image20.png" style="width:3.02264in;height:3.254in" />

2.  <span id="_Toc221196734" class="anchor"></span>**EEPROM模块**

> 板卡上放置EEPROM，用于存储固定资产信息，具体格式如下表所示。

<table style="width:89%;">
<caption><p>表 3 EEPROM内容格式</p></caption>
<colgroup>
<col style="width: 10%" />
<col style="width: 29%" />
<col style="width: 8%" />
<col style="width: 28%" />
<col style="width: 11%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;">域</th>
<th style="text-align: center;">字段</th>
<th style="text-align: center;">填充值</th>
<th style="text-align: center;">说明</th>
<th style="text-align: center;">是否必填</th>
</tr>
</thead>
<tbody>
<tr>
<td rowspan="3" style="text-align: center;">Chassis</td>
<td style="text-align: left;">Chassis Type</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;">可选</td>
</tr>
<tr>
<td style="text-align: left;">Chassis Part Number</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;">可选</td>
</tr>
<tr>
<td style="text-align: left;">Chassis Serial Number</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;">可选</td>
</tr>
<tr>
<td rowspan="5" style="text-align: center;">Board</td>
<td style="text-align: left;">Manufacture Date/Time</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;">必填</td>
</tr>
<tr>
<td style="text-align: left;">Board Manufacturer</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;"></td>
<td style="text-align: left;">必填</td>
</tr>
<tr>
<td style="text-align: left;">Board Product Name</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;"></td>
<td style="text-align: left;">必填</td>
</tr>
<tr>
<td style="text-align: left;">Board Serial Number</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;">可选</td>
</tr>
<tr>
<td style="text-align: left;">Board Part Number</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;"></td>
<td style="text-align: left;">必填</td>
</tr>
<tr>
<td rowspan="6" style="text-align: center;">Product</td>
<td style="text-align: left;">Manufacture Name</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;"></td>
<td style="text-align: left;">必填</td>
</tr>
<tr>
<td style="text-align: left;">Product Name</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;">由客户提供</td>
<td style="text-align: left;">必填</td>
</tr>
<tr>
<td style="text-align: left;">Product Part/Model Name</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;">可选</td>
</tr>
<tr>
<td style="text-align: left;">Product Version</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;">产品版本，如V3，V5等，客户提供</td>
<td style="text-align: left;">可选</td>
</tr>
<tr>
<td style="text-align: left;">Product Serial Number</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;"></td>
<td style="text-align: left;">必填</td>
</tr>
<tr>
<td style="text-align: left;">Asset Tag</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;">可选</td>
</tr>
</tbody>
</table>

3.  <span id="_Toc221196735" class="anchor"></span>**各模块之间的总线设计**

    1.  <span id="_Toc221196736" class="anchor"></span>**SMBus/I2C拓扑**

> 该背板上I2C设备有I2C SW PCA9548、I2C Expander PCA9555、Thermal Sensor、FRU EEPROM以及CPLD。其中PCA9548扩展11路I2C连接11个Slot，PCA9555连接Board ID、BOM ID、PCB ID的上下拉电阻；Thermal Sensor用于读取板卡温度信息；FRU EEPROM放置背板的FRU信息；CPLD有两路I2C，分别为和BMC通信的I2C以及CPLD在线更新。整体I2C框图如下图：

<img src="media/image21.png" style="width:2.81917in;height:4.68974in" />

> 如下表为I2C设备的地址表：

<table style="width:74%;">
<caption><p>背板 I2C设备地址表</p></caption>
<colgroup>
<col style="width: 16%" />
<col style="width: 21%" />
<col style="width: 35%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;">I2C器件</th>
<th style="text-align: center;">Address</th>
<th style="text-align: center;">Function</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: left;"><p>TEMP SENSOR</p>
<p>(EMC1413-A-AIZL-TR)</p></td>
<td style="text-align: left;">1001 100X</td>
<td style="text-align: left;">温度传感器主体和通道1进行温度采集,通道2未使用</td>
</tr>
<tr>
<td style="text-align: left;"><p>I2C Switch</p>
<p>（CA9548MTR）</p></td>
<td style="text-align: left;"><p>1110 101X</p>
<p>1110 010X</p></td>
<td style="text-align: left;">连接Slot</td>
</tr>
<tr>
<td style="text-align: left;"><p>FRU EEPROM</p>
<p>(GT24C02A-2GLI-TR)</p></td>
<td style="text-align: left;">1010 111X</td>
<td style="text-align: left;">存储FRU信息</td>
</tr>
<tr>
<td style="text-align: left;">CA9555MTR</td>
<td style="text-align: left;">0100 000X</td>
<td style="text-align: left;">连接BOARD ID、BOM ID、PCB ID</td>
</tr>
<tr>
<td rowspan="2" style="text-align: left;">CPLD</td>
<td style="text-align: left;">0110 000X</td>
<td style="text-align: left;">CPLD在线刷新I2C地址</td>
</tr>
<tr>
<td style="text-align: left;">0110 001X</td>
<td style="text-align: left;">CPLD版本等信息</td>
</tr>
</tbody>
</table>

2.  <span id="_Toc221196737" class="anchor"></span>**JTAG链路**

> 该背板上只有CPLD的JTAG接口。

![](media/image22.emf)

3.  <span id="_Toc221196738" class="anchor"></span>**SGPIO模块**

> 该背板连接主板CPLD发出的一组SGPIO信号，用于时序交互等功能。

![](media/image23.emf)

4.  <span id="_Toc221196739" class="anchor"></span>**单板电源设计**

> 该背板的主要器件Slot、CPLD、CA9555MTR等电源均来自于主板，仅在板内转换一个3.3V供电给Slot使用：

<img src="media/image24.png" style="width:4.86841in;height:1.77797in" />

5.  <span id="_Toc221196740" class="anchor"></span>**单板接口/连接器pin定义**

    1.  <span id="_Toc221196741" class="anchor"></span>**内部接口**

> 内部接口包括Sideband Conn、Power Conn、MCIO X8 Conn。
>
> MCIO接口定义如下：

| **说明** | **电平** | **方向** | **信号** | **针脚** | **针脚** | **信号** | **方向** | **电平** | **说明** |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| 回流地 | 0V | I | GND | A1 | B1 | GND | I | 0V | 回流地 |
| 差分信号 | / | O | A_CPU_PCIE_TX112_DP | A2 | B2 | A_CPU_PCIE_RX112_DP | I | / | 差分信号 |
| 差分信号 | / | O | A_CPU_PCIE_TX112_DN | A3 | B3 | A_CPU_PCIE_RX112_DN | I | / | 差分信号 |
| 回流地 | 0V | I | GND | A4 | B4 | GND | I | 0V | 回流地 |
| 差分信号 | / | O | A_CPU_PCIE_TX113_DP | A5 | B5 | A_CPU_PCIE_RX113_DP | I | / | 差分信号 |
| 差分信号 | / | O | A_CPU_PCIE_TX113_DN | A6 | B6 | A_CPU_PCIE_RX113_DN | I | / | 差分信号 |
| 回流地 | 0V | I | GND | A7 | B7 | GND | I | 0V | 回流地 |
|  |  |  | MCIO_A_UP_0_0_VPP_ADDR_1 | A8 | B8 | MCIO_A_UP_0_BP_ID0 |  |  |  |
|  |  |  | MCIO_A_UP_0_0_VPP_ADDR_2 | A9 | B9 | A_CPU_PCIE_WAKE_N |  |  |  |
|  |  |  | MCIO_A_UP_0_0_VPP_ADDR_3 | A10 | B10 | GND | I | 0V | 回流地 |
|  |  |  | MCIO_A_UP_0_PERST0_N | A11 | B11 | MCIO_A_UP_0_0_PCIE_100M_DP | I | / | 差分信号 |
|  |  |  | MCIO_A_UP_0_0_VPP_ADDR_0 | A12 | B12 | MCIO_A_UP_0_0_PCIE_100M_DN | I | / | 差分信号 |
| 回流地 | 0V | I | GND | A13 | B13 | GND | I | 0V | 回流地 |
| 差分信号 | / | O | A_CPU_PCIE_TX114_DP | A14 | B14 | A_CPU_PCIE_RX114_DP | I | / | 差分信号 |
| 差分信号 | / | O | A_CPU_PCIE_TX114_DN | A15 | B15 | A_CPU_PCIE_RX114_DN | I | / | 差分信号 |
| 回流地 | 0V | I | GND | A16 | B16 | GND | I | 0V | 回流地 |
| 差分信号 | / | O | A_CPU_PCIE_TX115_DP | A17 | B17 | A_CPU_PCIE_RX115_DP | I | / | 差分信号 |
| 差分信号 | / | O | A_CPU_PCIE_TX115_DN | A18 | B18 | A_CPU_PCIE_RX115_DN | I | / | 差分信号 |
| 回流地 | 0V | I | GND | A19 | B19 | GND | I | 0V | 回流地 |
| 差分信号 | / | O | A_CPU_PCIE_TX116_DP | A20 | B20 | A_CPU_PCIE_RX116_DP | I | / | 差分信号 |
| 差分信号 | / | O | A_CPU_PCIE_TX116_DN | A21 | B21 | A_CPU_PCIE_RX116_DN | I | / | 差分信号 |
| 回流地 | 0V | I | GND | A22 | B22 | GND | I | 0V | 回流地 |
| 差分信号 | / | O | A_CPU_PCIE_TX117_DP | A23 | B23 | A_CPU_PCIE_RX117_DP | I | / | 差分信号 |
| 差分信号 | / | O | A_CPU_PCIE_TX117_DN | A24 | B24 | A_CPU_PCIE_RX117_DN | I | / | 差分信号 |
| 回流地 | 0V | I | GND | A25 | B25 | GND | I | 0V | 回流地 |
|  |  |  | MCIO_A_UP_0_1_CPU_ADDR_0 | A26 | B26 | MCIO_A_UP_0_BP_ID1 |  |  |  |
|  |  |  | MCIO_A_UP_0_1_CPU_ADDR_SCL | A27 | B27 | A_CPU_PCIE_WAKE_N |  |  |  |
|  |  |  | MCIO_A_UP_0_1_CPU_ADDR_SDA | A28 | B28 | GND | I | 0V | 回流地 |
| / | / | / | NC | A29 | B29 | NC | / | / | / |
|  |  |  | MCIO_A_UP_0_1_CPU_ADDR_NC | A30 | B30 | NC | / | / | / |
| 回流地 | 0V | I | GND | A31 | B31 | GND | I | 0V | 回流地 |
| 差分信号 | / | O | A_CPU_PCIE_TX118_DP | A32 | B32 | A_CPU_PCIE_RX118_DP | I | / | 差分信号 |
| 差分信号 | / | O | A_CPU_PCIE_TX118_DN | A33 | B33 | A_CPU_PCIE_RX118_DN | I | / | 差分信号 |
| 回流地 | 0V | I | GND | A34 | B34 | GND | I | 0V | 回流地 |
| 差分信号 | / | O | A_CPU_PCIE_TX119_DP | A35 | B35 | A_CPU_PCIE_RX119_DP | I | / | 差分信号 |
| 差分信号 | / | O | A_CPU_PCIE_TX119_DN | A36 | B36 | A_CPU_PCIE_RX119_DN | I | / | 差分信号 |
| 回流地 | 0V | I | GND | A37 | B37 | GND | I | 0V | 回流地 |

> 青隼0SW板电源连接器（金手指硬连接）针脚定义

| 说明     | 电平 | 方向 |   信号    | 针脚 | 针脚 | 信号 | 方向 | 电平 | 说明   |
|----------|------|------|:---------:|:----:|:----:|:----:|------|------|--------|
| 3.3V电源 | 3.3V | I    | P3V3_STBY |  1   |  9   | GND  | I    | 0V   | 回流地 |
| 12V电源  | 12V  | I    | P12V_PCIE |  2   |  10  | GND  | I    | 0V   | 回流地 |
| 12V电源  | 12V  | I    | P12V_PCIE |  3   |  11  | GND  | I    | 0V   | 回流地 |
| 12V电源  | 12V  | I    | P12V_PCIE |  4   |  12  | GND  | I    | 0V   | 回流地 |
| 12V电源  | 12V  | I    | P12V_PCIE |  5   |  13  | GND  | I    | 0V   | 回流地 |
| 12V电源  | 12V  | I    | P12V_PCIE |  6   |  14  | GND  | I    | 0V   | 回流地 |
| 12V电源  | 12V  | I    | P12V_PCIE |  7   |  15  | GND  | I    | 0V   | 回流地 |
| 12V电源  | 12V  | I    | P12V_PCIE |  8   |  16  | GND  | I    | 0V   | 回流地 |
| GND      | I    | 0V   |  回流地   |  G1  |  G2  | GND  | I    | 0V   | 回流地 |

- 电源连接器通流要求(per pin)：6A

- 推荐搭配线径：如下图

> <img src="media/image25.png" style="width:3.42728in;height:2.2297in" />

- 降额参数：

> <img src="media/image26.png" style="width:4.6501in;height:2.36817in" />
>
> Sideband Conn的Pin定义如下：

| **说明** | **电平** | **方向** | **信号** | **针脚** | **针脚** | **信号** | **方向** | **电平** | **说明** |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| BMC的I2C管理 | 3.3V | O | BMC_I2C_SCL | 1 | 2 | GND | I | 0V | 回流地 |
| BMC的I2C管理 | 3.3V | I/O | BMC_I2C_SDA | 3 | 4 | BP_PRSNT_N | I | 0V | 背板在位信号 |
| PCIe卡节流信号 | 3.3V | O | PCIE_THROTTLE_N | 5 | 6 | GND | I | 0V | 回流地 |
| SGPIO数据输入 | 3.3V | I | SGPIO_DIN | 7 | 8 | SGPIO_DOUT | O | 3.3V | SGPIO数据输出 |
| SGPIO标志位 | 3.3V | O | SGPIO_LOAD | 9 | 10 | SGPIO_CLK | O | 3.3V | SGPIO时钟 |

1.  <span id="_Toc221196742" class="anchor"></span>**外部接口**

> Slot连接器(X16) pin定义如下：

<table>
<colgroup>
<col style="width: 5%" />
<col style="width: 24%" />
<col style="width: 17%" />
<col style="width: 5%" />
<col style="width: 23%" />
<col style="width: 22%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;"><strong>Pin</strong></th>
<th style="text-align: center;"><strong>Net Name</strong></th>
<th style="text-align: center;"><strong>Function</strong></th>
<th style="text-align: center;"><strong>Pin</strong></th>
<th style="text-align: center;"><strong>Net Name</strong></th>
<th style="text-align: center;"><strong>Function</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: center;">A1</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B1</td>
<td style="text-align: center;">P12V_SLOT0</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A2</td>
<td style="text-align: center;">P12V_SLOT0</td>
<td></td>
<td style="text-align: center;">B2</td>
<td style="text-align: center;">P12V_SLOT0</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A3</td>
<td style="text-align: center;">P12V_SLOT0</td>
<td></td>
<td style="text-align: center;">B3</td>
<td style="text-align: center;">P12V_SLOT0</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A4</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B4</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A5</td>
<td style="text-align: center;">JTAG2_TCK_SLOT0</td>
<td></td>
<td style="text-align: center;">B5</td>
<td style="text-align: center;">SMB_SLOT0_R_SCL</td>
<td rowspan="2">SLOT0 I2C</td>
</tr>
<tr>
<td style="text-align: center;">A6</td>
<td style="text-align: center;">JTAG3_TDI_SLOT0</td>
<td></td>
<td style="text-align: center;">B6</td>
<td style="text-align: center;">SMB_SLOT0_R_SDA</td>
</tr>
<tr>
<td style="text-align: center;">A7</td>
<td style="text-align: center;">JTAG4_TDO_SLOT0</td>
<td></td>
<td style="text-align: center;">B7</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A8</td>
<td style="text-align: center;">JTAG5_TMS_SLOT0</td>
<td></td>
<td style="text-align: center;">B8</td>
<td style="text-align: center;">P3V3_SLOT0</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A9</td>
<td style="text-align: center;">P3V3_SLOT0</td>
<td></td>
<td style="text-align: center;">B9</td>
<td style="text-align: center;">JTAG1_TRST_SLOT0</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A10</td>
<td style="text-align: center;">P3V3_SLOT0</td>
<td></td>
<td style="text-align: center;">B10</td>
<td style="text-align: center;">P3V3_STBY</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A11</td>
<td style="text-align: center;">RST_SLOT0_A_PE_RST_N</td>
<td>SLOT0 Reset信号</td>
<td style="text-align: center;">B11</td>
<td style="text-align: center;">SLOT0_WAKE_N</td>
<td>WAKE信号</td>
</tr>
<tr>
<td style="text-align: center;">A12</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B12</td>
<td style="text-align: center;"></td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A13</td>
<td style="text-align: center;">CLK_100M_SLOT0_A_DP</td>
<td rowspan="2">SLOT0的时钟</td>
<td style="text-align: center;">B13</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A14</td>
<td style="text-align: center;">CLK_100M_SLOT0_A_DN</td>
<td style="text-align: center;">B14</td>
<td style="text-align: center;">P5E_SLOT0_TX_DP&lt;0&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A15</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B15</td>
<td style="text-align: center;">P5E_SLOT0_TX_DN&lt;0&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A16</td>
<td style="text-align: center;">P5E_SLOT0_RX_DP&lt;0&gt;</td>
<td></td>
<td style="text-align: center;">B16</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A17</td>
<td style="text-align: center;">P5E_SLOT0_RX_DN&lt;0&gt;</td>
<td></td>
<td style="text-align: center;">B17</td>
<td style="text-align: center;">SLOT0_PRSNT012_N</td>
<td>SLOT0在位信号</td>
</tr>
<tr>
<td style="text-align: center;">A18</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B18</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A19</td>
<td style="text-align: center;"></td>
<td></td>
<td style="text-align: center;">B19</td>
<td style="text-align: center;">P5E_SLOT0_TX_DP&lt;1&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A20</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B20</td>
<td style="text-align: center;">P5E_SLOT0_TX_DN&lt;1&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A21</td>
<td style="text-align: center;">P5E_SLOT0_RX_DP&lt;1&gt;</td>
<td></td>
<td style="text-align: center;">B21</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A22</td>
<td style="text-align: center;">P5E_SLOT0_RX_DN&lt;1&gt;</td>
<td></td>
<td style="text-align: center;">B22</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A23</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B23</td>
<td style="text-align: center;">P5E_SLOT0_TX_DP&lt;2&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A24</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B24</td>
<td style="text-align: center;">P5E_SLOT0_TX_DN&lt;2&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A25</td>
<td style="text-align: center;">P5E_SLOT0_RX_DP&lt;2&gt;</td>
<td></td>
<td style="text-align: center;">B25</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A26</td>
<td style="text-align: center;">P5E_SLOT0_RX_DN&lt;2&gt;</td>
<td></td>
<td style="text-align: center;">B26</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A27</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B27</td>
<td style="text-align: center;">P5E_SLOT0_TX_DP&lt;3&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A28</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B28</td>
<td style="text-align: center;">P5E_SLOT0_TX_DN&lt;3&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A29</td>
<td style="text-align: center;">P5E_SLOT0_RX_DP&lt;3&gt;</td>
<td></td>
<td style="text-align: center;">B29</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A30</td>
<td style="text-align: center;">P5E_SLOT0_RX_DN&lt;3&gt;</td>
<td></td>
<td style="text-align: center;">B30</td>
<td style="text-align: center;">SLOT0_PWR_BRK_N</td>
<td>设备降频信号</td>
</tr>
<tr>
<td style="text-align: center;">A31</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B31</td>
<td style="text-align: center;">SLOT0_PRSNT012_N</td>
<td>SLOT0在位信号</td>
</tr>
<tr>
<td style="text-align: center;">A32</td>
<td style="text-align: center;">CLK_100M_SLOT0_B_DP</td>
<td rowspan="2">SLOT0预留的第二组时钟</td>
<td style="text-align: center;">B32</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A33</td>
<td style="text-align: center;">CLK_100M_SLOT0_B_DN</td>
<td style="text-align: center;">B33</td>
<td style="text-align: center;">P5E_SLOT0_TX_DP&lt;4&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A34</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B34</td>
<td style="text-align: center;">P5E_SLOT0_TX_DN&lt;4&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A35</td>
<td style="text-align: center;">P5E_SLOT0_RX_DP&lt;4&gt;</td>
<td></td>
<td style="text-align: center;">B35</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A36</td>
<td style="text-align: center;">P5E_SLOT0_RX_DN&lt;4&gt;</td>
<td></td>
<td style="text-align: center;">B36</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A37</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B37</td>
<td style="text-align: center;">P5E_SLOT0_TX_DP&lt;5&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A38</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B38</td>
<td style="text-align: center;">P5E_SLOT0_TX_DN&lt;5&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A39</td>
<td style="text-align: center;">P5E_SLOT0_RX_DP&lt;5&gt;</td>
<td></td>
<td style="text-align: center;">B39</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A40</td>
<td style="text-align: center;">P5E_SLOT0_RX_DN&lt;5&gt;</td>
<td></td>
<td style="text-align: center;">B40</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A41</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B41</td>
<td style="text-align: center;">P5E_SLOT0_TX_DP&lt;6&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A42</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B42</td>
<td style="text-align: center;">P5E_SLOT0_TX_DN&lt;6&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A43</td>
<td style="text-align: center;">P5E_SLOT0_RX_DP&lt;6&gt;</td>
<td></td>
<td style="text-align: center;">B43</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A44</td>
<td style="text-align: center;">P5E_SLOT0_RX_DN&lt;6&gt;</td>
<td></td>
<td style="text-align: center;">B44</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A45</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B45</td>
<td style="text-align: center;">P5E_SLOT0_TX_DP&lt;7&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A46</td>
<td style="text-align: center;">GND</td>
<td style="text-align: left;"></td>
<td style="text-align: center;">B46</td>
<td style="text-align: center;">P5E_SLOT0_TX_DN&lt;7&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A47</td>
<td style="text-align: center;">P5E_SLOT0_RX_DP&lt;7&gt;</td>
<td></td>
<td style="text-align: center;">B47</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A48</td>
<td style="text-align: center;">P5E_SLOT0_RX_DN&lt;7&gt;</td>
<td></td>
<td style="text-align: center;">B48</td>
<td style="text-align: center;">SLOT0_PRSNT012_N</td>
<td>SLOT0在位信号</td>
</tr>
<tr>
<td style="text-align: center;">A49</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B49</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A50</td>
<td style="text-align: center;">RST_SLOT0_B_PE_RST_N</td>
<td>SLOT0预留的第二个Reset信号</td>
<td style="text-align: center;">B50</td>
<td style="text-align: center;">P5E_SLOT0_TX_DP&lt;8&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A51</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B51</td>
<td style="text-align: center;">P5E_SLOT0_TX_DN&lt;8&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A52</td>
<td style="text-align: center;">P5E_SLOT0_RX_DP&lt;8&gt;</td>
<td></td>
<td style="text-align: center;">B52</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A53</td>
<td style="text-align: center;">P5E_SLOT0_RX_DN&lt;8&gt;</td>
<td></td>
<td style="text-align: center;">B53</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A54</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B54</td>
<td style="text-align: center;">P5E_SLOT0_TX_DP&lt;9&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A55</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B55</td>
<td style="text-align: center;">P5E_SLOT0_TX_DN&lt;9&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A56</td>
<td style="text-align: center;">P5E_SLOT0_RX_DP&lt;9&gt;</td>
<td></td>
<td style="text-align: center;">B56</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A57</td>
<td style="text-align: center;">P5E_SLOT0_RX_DN&lt;9&gt;</td>
<td></td>
<td style="text-align: center;">B57</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A58</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B58</td>
<td style="text-align: center;">P5E_SLOT0_TX_DP&lt;10&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A59</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B59</td>
<td style="text-align: center;">P5E_SLOT0_TX_DN&lt;10&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A60</td>
<td style="text-align: center;">P5E_SLOT0_RX_DP&lt;10&gt;</td>
<td></td>
<td style="text-align: center;">B60</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A61</td>
<td style="text-align: center;">P5E_SLOT0_RX_DN&lt;10&gt;</td>
<td></td>
<td style="text-align: center;">B61</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A62</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B62</td>
<td style="text-align: center;">P5E_SLOT0_TX_DP&lt;11&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A63</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B63</td>
<td style="text-align: center;">P5E_SLOT0_TX_DN&lt;11&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A64</td>
<td style="text-align: center;">P5E_SLOT0_RX_DP&lt;11&gt;</td>
<td style="text-align: left;"></td>
<td style="text-align: center;">B64</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A65</td>
<td style="text-align: center;">P5E_SLOT0_RX_DN&lt;11&gt;</td>
<td></td>
<td style="text-align: center;">B65</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A66</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B66</td>
<td style="text-align: center;">P5E_SLOT0_TX_DP&lt;12&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A67</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B67</td>
<td style="text-align: center;">P5E_SLOT0_TX_DN&lt;12&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A68</td>
<td style="text-align: center;">P5E_SLOT0_RX_DP&lt;12&gt;</td>
<td></td>
<td style="text-align: center;">B68</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A69</td>
<td style="text-align: center;">P5E_SLOT0_RX_DN&lt;12&gt;</td>
<td></td>
<td style="text-align: center;">B69</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A70</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B70</td>
<td style="text-align: center;">P5E_SLOT0_TX_DP&lt;13&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A71</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B71</td>
<td style="text-align: center;">P5E_SLOT0_TX_DN&lt;13&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A72</td>
<td style="text-align: center;">P5E_SLOT0_RX_DP&lt;13&gt;</td>
<td></td>
<td style="text-align: center;">B72</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A73</td>
<td style="text-align: center;">P5E_SLOT0_RX_DN&lt;13&gt;</td>
<td></td>
<td style="text-align: center;">B73</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A74</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B74</td>
<td style="text-align: center;">P5E_SLOT0_TX_DP&lt;14&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A75</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B75</td>
<td style="text-align: center;">P5E_SLOT0_TX_DN&lt;14&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A76</td>
<td style="text-align: center;">P5E_SLOT0_RX_DP&lt;14&gt;</td>
<td></td>
<td style="text-align: center;">B76</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A77</td>
<td style="text-align: center;">P5E_SLOT0_RX_DN&lt;14&gt;</td>
<td></td>
<td style="text-align: center;">B77</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A78</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B78</td>
<td style="text-align: center;">P5E_SLOT0_TX_DP&lt;15&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A79</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B79</td>
<td style="text-align: center;">P5E_SLOT0_TX_DN&lt;15&gt;</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A80</td>
<td style="text-align: center;">P5E_SLOT0_RX_DP&lt;15&gt;</td>
<td></td>
<td style="text-align: center;">B80</td>
<td style="text-align: center;">GND</td>
<td></td>
</tr>
<tr>
<td style="text-align: center;">A81</td>
<td style="text-align: center;">P5E_SLOT0_RX_DN&lt;15&gt;</td>
<td></td>
<td style="text-align: center;">B81</td>
<td style="text-align: center;">SLOT0_PRSNT3_N</td>
<td>SLOT0在位信号</td>
</tr>
<tr>
<td style="text-align: center;">A82</td>
<td style="text-align: center;">GND</td>
<td></td>
<td style="text-align: center;">B82</td>
<td style="text-align: center;"></td>
<td></td>
</tr>
</tbody>
</table>

2.  <span id="_Toc221196743" class="anchor"></span>**调试接口**

> 调试接口是指CPLD的JTAG接口，Pin定义如下:

| Pin |   Name   |     |                |
|:---:|:--------:|:---:|:--------------:|
|  1  | CPLD_TCK |  2  |      GND       |
|  3  | CPLD_TDO |  4  | P3V3_CPLD_JTAG |
|  5  | CPLD_TMS |  6  |                |
|  7  |          |  8  |                |
|  9  | CPLD_TDI | 10  |      GND       |

3.  <span id="_Toc221196744" class="anchor"></span>**板卡关键器件丝印**

> 关键器件丝印主要涉及关键芯片及连接器，为便于组装调试，单独在PCB增加丝印标识，丝印定义如下:

![](media/image27.emf)

3.  <span id="_Toc221196745" class="anchor"></span>**单板PCB和信号完整性设计**

    1.  <span id="_Toc517452102" class="anchor"></span>**PCB叠层设计**

> PCB板材选型Low-Loss（PCIe5.0）, 推荐型号S30G-A；基本特性如下：
>
> <img src="media/image28.png" style="width:4.33215in;height:5.29446in" />

<img src="media/image29.png" style="width:4.01893in;height:3.7119in" />

> PCB叠层设计详细说明如下，包含板厚，层数，铜厚等信息：

<img src="media/image30.png" style="width:3.63073in;height:5.33073in" />

2.  <span id="_Toc517452103" class="anchor"></span>**PCB走线设计**

> TOP / BOTTOM层：

<img src="media/image31.png" style="width:6.89028in;height:2.99097in" />

<img src="media/image32.png" style="width:6.89028in;height:2.94583in" />

> L3层：

<img src="media/image33.png" style="width:6.89028in;height:2.94444in" />

> L8层：

<img src="media/image34.png" style="width:6.89028in;height:2.95417in" />

> L5/L6层: 电源层
>
> <img src="media/image35.png" style="width:6.89028in;height:2.98125in" />
>
> L2层/ L4层/L7层/L9层：GND

<img src="media/image36.png" style="width:6.89028in;height:2.99722in" />

3.  <span id="_Toc221196748" class="anchor"></span>**高速信号SI仿真和评估**

> 高速链路为整体评估，不提供单板仿真，整体链路仿真在主板统一说明。

4.  <span id="_Toc221196749" class="anchor"></span>**单板结构相关设计**

    1.  <span id="_Toc221196750" class="anchor"></span>**定位孔、禁布区和尺寸说明**

<img src="media/image37.png" style="width:5.51811in;height:3.93142in" />

2.  <span id="_Toc221196751" class="anchor"></span>**特殊结构件**

<img src="media/image38.png" style="width:4.80572in;height:1.79306in" />
