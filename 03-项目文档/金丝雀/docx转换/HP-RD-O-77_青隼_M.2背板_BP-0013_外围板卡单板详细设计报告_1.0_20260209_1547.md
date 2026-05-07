**青隼\_**M.2背板**\_单板详细设计报告**

> **拟 制：<u>­­\_ 杨 超 \_ </u>**
>
> **审 核：<u>\_\_ \_\_\_</u>**
>
> **批 准：<u>\_\_ \_\_</u>**

# 目录

[1概述 [4](#_Toc221520131)](#_Toc221520131)

[**1.1** **保密说明** [4](#_Toc221520132)](#_Toc221520132)

[**1.2** **版本历史** [4](#_Toc221520133)](#_Toc221520133)

[**1.3** **术语** [4](#_Toc221520134)](#_Toc221520134)

[**1.4** **参考文档** [4](#_Toc221520135)](#_Toc221520135)

[**1.5** **背景** [5](#_Toc221520136)](#_Toc221520136)

[2 单板总体说明 [5](#_Toc221520137)](#_Toc221520137)

[**2.1** **单板总体框图** [5](#_Toc221520138)](#_Toc221520138)

[**2.2** **MCU选型** [6](#_Toc528584792)](#_Toc528584792)

[3 单板各模块的详细设计 [6](#_Toc221520140)](#_Toc221520140)

[**3.1** **MCU模块** [6](#_Toc221520141)](#_Toc221520141)

[**3.2** **EEPROM模块** [6](#_Toc528257395)](#_Toc528257395)

[**3.3** **各模块之间的总线设计** [7](#_Toc221520143)](#_Toc221520143)

[**3.3.1** **SMBus/I2C拓扑** [7](#_Toc221520144)](#_Toc221520144)

[**3.3.2** **SWD链路** [8](#_Toc221520145)](#_Toc221520145)

[**3.3.3** **M2 类型识别设计** [8](#_Toc221520146)](#_Toc221520146)

[**3.4** **单板电源设计** [8](#_Toc221520147)](#_Toc221520147)

[**3.5** **单板接口/连接器pin定义** [9](#_Toc221520148)](#_Toc221520148)

[**3.5.1** **内部接口** [9](#_Toc221520149)](#_Toc221520149)

[**3.5.2** **调试接口** [12](#_Toc221520150)](#_Toc221520150)

[**3.5.3** **板卡关键器件丝印** [12](#_Toc221520151)](#_Toc221520151)

[4 单板PCB和信号完整性设计 [13](#_Toc221520152)](#_Toc221520152)

[**4.1** **PCB叠层设计** [13](#_Toc517452102)](#_Toc517452102)

[**4.2** **PCB走线设计** [13](#_Toc517452103)](#_Toc517452103)

[**4.3** **高速信号SI仿真和评估** [16](#_Toc221520155)](#_Toc221520155)

[5 单板结构相关设计 [16](#_Toc221520156)](#_Toc221520156)

[**5.1** **定位孔、禁布区和尺寸说明** [16](#_Toc221520157)](#_Toc221520157)

<span id="_Toc221520131" class="anchor"></span>**1概述**

1.  <span id="_Toc221520132" class="anchor"></span>**保密说明**

> **本技术文档为软通华方公司的机密文件，未经许可，不得复制和传播。**

2.  <span id="_Toc221520133" class="anchor"></span>**版本历史**

| **作者** | **描述** | **版本** | **日期** |
|:---------|:---------|----------|----------|
| 杨超     | 初版     | V1.0     | 20260209 |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |

3.  <span id="_Toc221520134" class="anchor"></span>**术语**

> **本文档中提到的所有术语、缩写等解释**

| **术语** | **描述**                 |
|:---------|:-------------------------|
| MCU      | Microcontroller Unit     |
| SWD      | Serial Wire Debug        |
| I2C      | Inter-Integrated Circuit |
|          |                          |
|          |                          |
|          |                          |
|          |                          |
|          |                          |
|          |                          |
|          |                          |

4.  <span id="_Toc221520135" class="anchor"></span>**参考文档**

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

5.  <span id="_Toc221520136" class="anchor"></span>**背景**

> 青隼服务器是软通华方公司自研的4U AI服务器，配置灵活，可广泛适用于大规模模型训练、数据库、云端推理等业务负载。该单板是M.2背板，用于扩展2个M.2接口，背板通过软连接的方式和主板互连，通过搭配特定的结构支架装配到机箱内。

1.  <span id="_Toc221520137" class="anchor"></span>**单板总体说明**

    1.  <span id="_Toc221520138" class="anchor"></span>**单板总体框图**

> M.2背板能够支持2xM.2接口硬盘配置，支持NVME/SATA协议。该背板支持BMC通过I2C switch芯片扩展后，配置模拟开关通道读取EEPROM信息存储，同时可以读取温度传感器进行温度监测。
>
> Slimline X8连接器接入高速信号，包括2路PCIe X2，PCIe X2中有1路支持SATA信号，连接器提供2路100M PCIe时钟。连接器上还有12V供电和I2C管理等低速信号。
>
> Slimline的2路PCIe x2数据与时钟分别连接到2个M.2连接器。
>
> M.2连接器的I2C信号为1.8V电平，需要转为3.3V电平才能与外部连接器的电平匹配，用PCB9617ADP芯片进行电平转换，可以使外部接口与M.2硬盘进行通信。
>
> MCU预留I2C通信通道。
>
> M.2背板的板卡拓扑如下图所示：
>
> ![](media/image1.emf)
>
> 图 1 M.2背板板卡拓扑

2.  <span id="_Toc528584792" class="anchor"></span>**MCU选型**

> 背板选用兆易创新的的GD32F303CET6。

2.  <span id="_Toc221520140" class="anchor"></span>**单板各模块的详细设计**

    1.  <span id="_Toc528257395" class="anchor"></span>**EEPROM模块**

> 板卡上放置EEPROM，用于存储固定资产信息，具体格式如下表所示。

<table style="width:89%;">
<caption><p>表 1 EEPROM内容格式</p></caption>
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
<td style="text-align: left;"></td>
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

2.  <span id="_Toc221520143" class="anchor"></span>**各模块之间的总线设计**

    1.  <span id="_Toc221520144" class="anchor"></span>**SMBus/I2C拓扑**

> M.2背板上I2C设备有I2C Switch PCA9548APWR、I2C Expander PCA9555PW、Thermal Sensor、EEPROM以及MCU。高速连接器的BMC I2C通过模拟开关可以更新EEPROM中背板的FRU信息，同时通过PCA9548APWR扩展5路I2C，其中两路通过电平转换后连接两个M.2硬盘，1路连接到PCA9555扩展IO读取Board ID、BOM ID、PCB ID的上下拉电阻状态，1路连接Thermal Sensor用于读取板卡温度信息；1路I2C连接到MCU。

<figure>
<img src="media/image2.emf" />
<figcaption><p>图 2 M.2 背板 I2C拓扑</p></figcaption>
</figure>

> 如下表为I2C设备的地址表：

<table style="width:74%;">
<caption><p>表 2 M.2背板 I2C设备地址表</p></caption>
<colgroup>
<col style="width: 21%" />
<col style="width: 20%" />
<col style="width: 32%" />
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
<td style="text-align: left;"><p>I2C Switch</p>
<p>（PCA9548APWR）</p></td>
<td style="text-align: left;">1110 001X</td>
<td style="text-align: left;">扩展5路I2C</td>
</tr>
<tr>
<td style="text-align: left;">M.2硬盘0</td>
<td style="text-align: left;"></td>
<td style="text-align: left;">硬盘</td>
</tr>
<tr>
<td style="text-align: left;">M.2硬盘1</td>
<td style="text-align: left;"></td>
<td style="text-align: left;">硬盘</td>
</tr>
<tr>
<td style="text-align: left;"><p>TEMP SENSOR</p>
<p>(LM75BDP)</p></td>
<td style="text-align: left;">1001 000X</td>
<td style="text-align: left;">温度传感器</td>
</tr>
<tr>
<td style="text-align: left;"><p>I2C expander</p>
<p>(PCA9555PW)</p></td>
<td style="text-align: left;">0100 000X</td>
<td style="text-align: left;">连接BOARD ID、BOM ID、PCB ID</td>
</tr>
<tr>
<td style="text-align: left;"><p>EEPROM</p>
<p>(M24128-BWMN6TP)</p></td>
<td style="text-align: left;">1010 111X</td>
<td style="text-align: left;">存储FRU信息</td>
</tr>
</tbody>
</table>

2.  <span id="_Toc221520145" class="anchor"></span>**SWD链路**

> M.2背板上只有MCU的SWD接口。

<figure>
<img src="media/image3.emf" />
<figcaption><p>图 3 SWD拓扑</p></figcaption>
</figure>

3.  <span id="_Toc221520146" class="anchor"></span>**M2 类型识别设计**

> 系统识别M2硬盘类型，通过M2连接器BP_TYPEA的电平上报的来实现识别，高电平为NVME,低电平为SATA

3.  <span id="_Toc221520147" class="anchor"></span>**单板电源设计**

> M.2背板的供电由Slimline连接器提供，包括P12V与V_STBY_3V3，其中P12V通过电源芯片MPQ8633转换P3V3为M.2硬盘供电，V_STBY_3V3通过芯片MUM3CAD01转换V_STBY_1V8为电平转换芯片提供1.8V电压。
>
> M.2背板的供电拓扑如下图所示：

<figure>
<img src="media/image4.png" style="width:4.43307in;height:2.3622in" />
<figcaption><p>图 4 M.2背板供电拓扑</p></figcaption>
</figure>

4.  <span id="_Toc221520148" class="anchor"></span>**单板接口/连接器pin定义**

    1.  <span id="_Toc221520149" class="anchor"></span>**内部接口**

> 内部接口包括Slimline Conn、M.2 Conn
>
> Slimline Conn Pin定义如下：

<table>
<caption><p>表 3 Slimline Conn Pin定义</p></caption>
<colgroup>
<col style="width: 11%" />
<col style="width: 9%" />
<col style="width: 7%" />
<col style="width: 14%" />
<col style="width: 7%" />
<col style="width: 8%" />
<col style="width: 17%" />
<col style="width: 8%" />
<col style="width: 5%" />
<col style="width: 10%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;"><strong>说明</strong></th>
<th style="text-align: center;"><strong>电平</strong></th>
<th style="text-align: center;"><strong>方向</strong></th>
<th style="text-align: center;"><strong>信号</strong></th>
<th style="text-align: center;"><strong>针脚</strong></th>
<th style="text-align: center;"><strong>针脚</strong></th>
<th style="text-align: center;"><strong>信号</strong></th>
<th style="text-align: center;"><strong>方向</strong></th>
<th style="text-align: center;"><strong>电平</strong></th>
<th style="text-align: center;"><strong>说明</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">A1</td>
<td style="text-align: center;">B1</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">GND</td>
</tr>
<tr>
<td style="text-align: center;">差分信号</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">I</td>
<td style="text-align: center;">PCIE_M2_TX0_DP</td>
<td style="text-align: center;">A2</td>
<td style="text-align: center;">B2</td>
<td style="text-align: center;">PCIE_M2_RX0_DP</td>
<td style="text-align: center;">O</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">差分信号</td>
</tr>
<tr>
<td style="text-align: center;">差分信号</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">I</td>
<td style="text-align: center;">PCIE_M2_TX0_DN</td>
<td style="text-align: center;">A3</td>
<td style="text-align: center;">B3</td>
<td style="text-align: center;">PCIE_M2_RX0_DN</td>
<td style="text-align: center;">O</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">差分信号</td>
</tr>
<tr>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">A4</td>
<td style="text-align: center;">B4</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">GND</td>
</tr>
<tr>
<td style="text-align: center;">差分信号</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">I</td>
<td style="text-align: center;">PCIE_M2_TX1_DP</td>
<td style="text-align: center;">A5</td>
<td style="text-align: center;">B5</td>
<td style="text-align: center;">PCIE_M2_RX1_DP</td>
<td style="text-align: center;">O</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">差分信号</td>
</tr>
<tr>
<td style="text-align: center;">差分信号</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">I</td>
<td style="text-align: center;">PCIE_M2_TX1_DN</td>
<td style="text-align: center;">A6</td>
<td style="text-align: center;">B6</td>
<td style="text-align: center;">PCIE_M2_RX1_DN</td>
<td style="text-align: center;">O</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">差分信号</td>
</tr>
<tr>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">A7</td>
<td style="text-align: center;">B7</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">GND</td>
</tr>
<tr>
<td style="text-align: center;">电源</td>
<td style="text-align: center;">3V3</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">V_STBY_3V3</td>
<td style="text-align: center;">A8</td>
<td style="text-align: center;">B8</td>
<td style="text-align: center;">M2_BP_TYPEA_N</td>
<td style="text-align: center;">O</td>
<td style="text-align: center;">3V3</td>
<td style="text-align: center;">BP_TYPE_A</td>
</tr>
<tr>
<td style="text-align: center;">电源</td>
<td style="text-align: center;">3V3</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">V_STBY_3V3</td>
<td style="text-align: center;">A9</td>
<td style="text-align: center;">B9</td>
<td style="text-align: center;">I2C_M2_ALERT</td>
<td style="text-align: center;">O</td>
<td style="text-align: center;">3V3</td>
<td style="text-align: center;">M2_ALERT</td>
</tr>
<tr>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">O</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">A10</td>
<td style="text-align: center;">B10</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">GND</td>
</tr>
<tr>
<td style="text-align: center;">PCIE复位信 号</td>
<td style="text-align: center;">3V3</td>
<td style="text-align: center;">I</td>
<td style="text-align: center;">PCIE_M2_RST_N</td>
<td style="text-align: center;">A11</td>
<td style="text-align: center;">B11</td>
<td style="text-align: center;">CLK_100M_M2_0_DP</td>
<td style="text-align: center;">I</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">100M时钟输 入</td>
</tr>
<tr>
<td style="text-align: center;">M2板卡在位信号</td>
<td style="text-align: center;">3V3</td>
<td style="text-align: center;">I</td>
<td style="text-align: center;">M2_BBU_PRSNT_N</td>
<td style="text-align: center;">A12</td>
<td style="text-align: center;">B12</td>
<td style="text-align: center;">CLK_100M_M2_0_DN</td>
<td style="text-align: center;">I</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">100M时钟输 入</td>
</tr>
<tr>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">A13</td>
<td style="text-align: center;">B13</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">GND</td>
</tr>
<tr>
<td style="text-align: center;">电源</td>
<td style="text-align: center;">3V3</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">V_STBY_3V3</td>
<td style="text-align: center;">A14</td>
<td style="text-align: center;">B14</td>
<td style="text-align: center;">I2C_M2_SCL</td>
<td style="text-align: center;">I</td>
<td style="text-align: center;">3V3</td>
<td style="text-align: center;">I2C时钟</td>
</tr>
<tr>
<td style="text-align: center;">电源</td>
<td style="text-align: center;">12V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">P12V</td>
<td style="text-align: center;">A15</td>
<td style="text-align: center;">B15</td>
<td style="text-align: center;">I2C_M2_SDA</td>
<td style="text-align: center;">IO</td>
<td style="text-align: center;">3V3</td>
<td style="text-align: center;">I2C数据</td>
</tr>
<tr>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">A16</td>
<td style="text-align: center;">B16</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">GND</td>
</tr>
<tr>
<td style="text-align: center;">电源</td>
<td style="text-align: center;">12V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">P12V</td>
<td style="text-align: center;">A17</td>
<td style="text-align: center;">B17</td>
<td style="text-align: center;">M2_0_PRSNT_N</td>
<td style="text-align: center;">O</td>
<td style="text-align: center;">3V3</td>
<td style="text-align: center;">在位信号</td>
</tr>
<tr>
<td style="text-align: center;">电源</td>
<td style="text-align: center;">12V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">P12V</td>
<td style="text-align: center;">A18</td>
<td style="text-align: center;">B18</td>
<td style="text-align: center;">M2_1_PRSNT_N</td>
<td style="text-align: center;">O</td>
<td style="text-align: center;">3V3</td>
<td style="text-align: center;">在位信号</td>
</tr>
<tr>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">A19</td>
<td style="text-align: center;">B19</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">GND</td>
</tr>
<tr>
<td style="text-align: center;">差分信号</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">I</td>
<td style="text-align: center;">PCIE_M2_TX2_DP</td>
<td style="text-align: center;">A20</td>
<td style="text-align: center;">B20</td>
<td style="text-align: center;">PCIE_M2_RX2_DP</td>
<td style="text-align: center;">O</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">差分信号</td>
</tr>
<tr>
<td style="text-align: center;">差分信号</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">I</td>
<td style="text-align: center;">PCIE_M2_TX2_DN</td>
<td style="text-align: center;">A21</td>
<td style="text-align: center;">B21</td>
<td style="text-align: center;">PCIE_M2_RX2_DN</td>
<td style="text-align: center;">O</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">差分信号</td>
</tr>
<tr>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">A22</td>
<td style="text-align: center;">B22</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">GND</td>
</tr>
<tr>
<td style="text-align: center;">差分信号</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">I</td>
<td style="text-align: center;">PCIE_M2_TX3_DP</td>
<td style="text-align: center;">A23</td>
<td style="text-align: center;">B23</td>
<td style="text-align: center;">PCIE_M2_RX3_DP</td>
<td style="text-align: center;">O</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">差分信号</td>
</tr>
<tr>
<td style="text-align: center;">差分信号</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">I</td>
<td style="text-align: center;">PCIE_M2_TX3_DN</td>
<td style="text-align: center;">A24</td>
<td style="text-align: center;">B24</td>
<td style="text-align: center;">PCIE_M2_RX3_DN</td>
<td style="text-align: center;">O</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">差分信号</td>
</tr>
<tr>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">A25</td>
<td style="text-align: center;">B25</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">GND</td>
</tr>
<tr>
<td style="text-align: center;">电源</td>
<td style="text-align: center;">12V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">P12V</td>
<td style="text-align: center;">A26</td>
<td style="text-align: center;">B26</td>
<td style="text-align: center;">M2_BP_TYPEB_N</td>
<td style="text-align: center;">O</td>
<td style="text-align: center;">3V3</td>
<td style="text-align: center;">BP_TYPE_B</td>
</tr>
<tr>
<td style="text-align: center;">电源</td>
<td style="text-align: center;">12V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">P12V</td>
<td style="text-align: center;">A27</td>
<td style="text-align: center;">B27</td>
<td style="text-align: center;">M2_POWER_PRSNT</td>
<td style="text-align: center;">O</td>
<td style="text-align: center;">3V3</td>
<td style="text-align: center;">电源正常</td>
</tr>
<tr>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">A28</td>
<td style="text-align: center;">B28</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">GND</td>
</tr>
<tr>
<td style="text-align: center;">M2复位</td>
<td style="text-align: center;"><blockquote>
<p>3V3</p>
</blockquote></td>
<td style="text-align: center;">O</td>
<td style="text-align: center;">PCIE_M2_RST_N</td>
<td style="text-align: center;">A29</td>
<td style="text-align: center;">B29</td>
<td style="text-align: center;">CLK_100M_M2_1_DP</td>
<td style="text-align: center;">I</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">差分时钟</td>
</tr>
<tr>
<td style="text-align: center;">拓扑上报信号</td>
<td style="text-align: center;"><blockquote>
<p>3V3</p>
</blockquote></td>
<td style="text-align: center;">O</td>
<td style="text-align: center;">BBU_M2_TOPO_DET_R</td>
<td style="text-align: center;">A30</td>
<td style="text-align: center;">B30</td>
<td style="text-align: center;">CLK_100M_M2_1_DN</td>
<td style="text-align: center;">I</td>
<td style="text-align: center;">/</td>
<td style="text-align: center;">差分时钟</td>
</tr>
<tr>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">A31</td>
<td style="text-align: center;">B31</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">GND</td>
</tr>
<tr>
<td style="text-align: center;">电源</td>
<td style="text-align: center;">12V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">P12V</td>
<td style="text-align: center;">A32</td>
<td style="text-align: center;">B32</td>
<td style="text-align: center;">P12V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">12V</td>
<td style="text-align: center;">电源</td>
</tr>
<tr>
<td style="text-align: center;">电源</td>
<td style="text-align: center;">12V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">P12V</td>
<td style="text-align: center;">A33</td>
<td style="text-align: center;">B33</td>
<td style="text-align: center;">P12V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">12V</td>
<td style="text-align: center;">电源</td>
</tr>
<tr>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">A34</td>
<td style="text-align: center;">B34</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">GND</td>
</tr>
<tr>
<td style="text-align: center;">电源</td>
<td style="text-align: center;">12V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">P12V</td>
<td style="text-align: center;">A35</td>
<td style="text-align: center;">B35</td>
<td style="text-align: center;">P12V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">12V</td>
<td style="text-align: center;">电源</td>
</tr>
<tr>
<td style="text-align: center;">电源</td>
<td style="text-align: center;">12V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">P12V</td>
<td style="text-align: center;">A36</td>
<td style="text-align: center;">B36</td>
<td style="text-align: center;">P12V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">12V</td>
<td style="text-align: center;">电源</td>
</tr>
<tr>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">A37</td>
<td style="text-align: center;">B37</td>
<td style="text-align: center;">GND</td>
<td style="text-align: center;">POWER</td>
<td style="text-align: center;">0V</td>
<td style="text-align: center;">GND</td>
</tr>
</tbody>
</table>

> M.2_0 连接器的Pin定义如下：

| **说明** | **电平** | **方向** | **信号** | **针脚** | **针脚** | **信号** | **方向** | **电平** | **说明** |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| M2卡在位检测 | 3V3 | O | M2_0_PRENT_N | 1 | 2 | 3V3 | GND | 3V3 | 电源 |
| GND | 0V | POWER | GND | 3 | 4 | 3V3 | GND | 3V3 | 电源 |
|  |  |  | NC | 5 | 6 | NC |  |  |  |
|  |  |  | NC | 7 | 8 | NC |  |  |  |
| GND | 0V | POWER | GND | 9 | 10 | NC |  |  |  |
|  |  |  | NC | 11 | 12 | 3V3 | GND | 3V3 | 电源 |
|  |  |  | NC | 13 | 14 | 3V3 | GND | 3V3 | 电源 |
| GND | 0V | POWER | GND | 15 | 16 | 3V3 | GND | 3V3 | 电源 |
|  |  |  | NC | 17 | 18 | 3V3 | GND | 3V3 | 电源 |
|  |  |  | NC | 19 | 20 | NC |  |  |  |
| GND | 0V | POWER | GND | 21 | 22 | NC |  |  |  |
|  |  |  | NC | 23 | 24 | NC |  |  |  |
|  |  |  | NC | 25 | 26 | NC |  |  |  |
| GND | 0V | POWER | GND | 27 | 28 | NC |  |  |  |
| 差分信号 |  | O | PCIE_M2_RX1_DN | 29 | 30 | NC |  |  |  |
| 差分信号 |  | O | PCIE_M2_RX1_DP | 31 | 32 | NC |  |  |  |
| GND | 0V | POWER | GND | 33 | 34 | NC |  |  |  |
| 差分信号 |  | I | PCIE_M2_TX1_DN | 35 | 36 | NC |  |  |  |
| 差分信号 |  | I | PCIE_M2_TX1_DP | 37 | 38 | PEDET_M2_0 | O | 3V3 |  |
| GND | 0V | POWER | GND | 39 | 40 | M2_0_I2C_SCL | O | 3V3 |  |
| 差分信号 |  | O | PCIE_M2_C_RX0_DP | 41 | 42 | M2_0_I2C_SDA | IO | 3V3 |  |
| 差分信号 |  | O | PCIE_M2_C_RX0_DP | 43 | 44 | M2_0_I2C_ALEAT_N | I | 3V3 |  |
| GND | 0V | POWER | GND | 45 | 46 | NC |  |  |  |
| 差分信号 |  | I | PCIE_M2_TX0_DN | 47 | 48 | NC |  |  |  |
| 差分信号 |  | I | PCIE_M2_TX0_DP | 49 | 50 | PCIE_M2_1_RST_R_N | I | 3V3 | 复位信号 |
| GND | 0V | POWER | GND | 51 | 52 | NC |  |  |  |
| 差分时钟 |  | I | CLK_100M_M2_0_DN | 53 | 54 | NC |  |  |  |
| 差分时钟 |  | I | CLK_100M_M2_0_DP | 55 | 56 | NC |  |  |  |
| GND | 0V | POWER | GND | 57 | 58 | NC |  |  |  |
|  |  |  | NC | 67 | 68 | NC |  |  |  |
|  |  |  | PEDET_M2_1 | 69 | 70 | 3V3 | GND | 3V3 | 电源 |
| GND | 0V | POWER | GND | 71 | 72 | 3V3 | GND | 3V3 | 电源 |
| GND | 0V | POWER | GND | 73 | 74 | 3V3 | GND | 3V3 | 电源 |
| GND | 0V | POWER | GND | 75 |  |  |  |  |  |

表 4 M.2_0 连接器的Pin定义

> M.2_1 连接器的Pin定义如下：

| **说明** | **电平** | **方向** | **信号** | **针脚** | **针脚** | **信号** | **方向** | **电平** | **说明** |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| M2卡在位检测 | 3V3 | O | M2_1_PRENT_N | 1 | 2 | 3V3 | GND | 3V3 | 电源 |
| GND | 0V | POWER | GND | 3 | 4 | 3V3 | GND | 3V3 | 电源 |
|  |  |  | NC | 5 | 6 | NC |  |  |  |
|  |  |  | NC | 7 | 8 | NC |  |  |  |
| GND | 0V | POWER | GND | 9 | 10 | NC |  |  |  |
|  |  |  | NC | 11 | 12 | 3V3 | GND | 3V3 | 电源 |
|  |  |  | NC | 13 | 14 | 3V3 | GND | 3V3 | 电源 |
| GND | 0V | POWER | GND | 15 | 16 | 3V3 | GND | 3V3 | 电源 |
|  |  |  | NC | 17 | 18 | 3V3 | GND | 3V3 | 电源 |
|  |  |  | NC | 19 | 20 | NC |  |  |  |
| GND | 0V | POWER | GND | 21 | 22 | NC |  |  |  |
|  |  |  | NC | 23 | 24 | NC |  |  |  |
|  |  |  | NC | 25 | 26 | NC |  |  |  |
| GND | 0V | POWER | GND | 27 | 28 | NC |  |  |  |
| 差分信号 |  | O | PCIE_M2_RX3_DN | 29 | 30 | NC |  |  |  |
| 差分信号 |  | O | PCIE_M2_RX3_DP | 31 | 32 | NC |  |  |  |
| GND | 0V | POWER | GND | 33 | 34 | NC |  |  |  |
| 差分信号 |  | I | PCIE_M2_TX3_DN | 35 | 36 | NC |  |  |  |
| 差分信号 |  | I | PCIE_M2_TX3_DP | 37 | 38 | PEDET_M2_1 | O | 3V3 |  |
| GND | 0V | POWER | GND | 39 | 40 | M2_1_I2C_SCL | O | 3V3 |  |
| 差分信号 |  | O | PCIE_M2_C_RX2_DP | 41 | 42 | M2_1_I2C_SDA | IO | 3V3 |  |
| 差分信号 |  | O | PCIE_M2_C_RX2_DP | 43 | 44 | M2_1_I2C_ALEAT_N | I | 3V3 |  |
| GND | 0V | POWER | GND | 45 | 46 | NC |  |  |  |
| 差分信号 |  | I | PCIE_M2_TX2_DN | 47 | 48 | NC |  |  |  |
| 差分信号 |  | I | PCIE_M2_TX2_DP | 49 | 50 | PCIE_M2_1_RST_R_N | I | 3V3 | 复位信号 |
| GND | 0V | POWER | GND | 51 | 52 | NC |  |  |  |
| 差分时钟 |  | I | CLK_100M_M2_1_DN | 53 | 54 | NC |  |  |  |
| 差分时钟 |  | I | CLK_100M_M2_1_DP | 55 | 56 | NC |  |  |  |
| GND | 0V | POWER | GND | 57 | 58 | NC |  |  |  |
|  |  |  | NC | 67 | 68 | NC |  |  |  |
|  |  |  | PEDET_M2_1 | 69 | 70 | 3V3 | GND | 3V3 | 电源 |
| GND | 0V | POWER | GND | 71 | 72 | 3V3 | GND | 3V3 | 电源 |
| GND | 0V | POWER | GND | 73 | 74 | 3V3 | GND | 3V3 | 电源 |
| GND | 0V | POWER | GND | 75 |  |  |  |  |  |
| M2卡在位检测 | 3V3 | O | M2_1_PRENT_N | 1 | 2 | 3V3 | GND | 3V3 | 电源 |
| GND | 0V | POWER | GND | 3 | 4 | 3V3 | GND | 3V3 | 电源 |

表 5 M.2_1 连接器的Pin定义

2.  <span id="_Toc221520150" class="anchor"></span>**调试接口**

> 调试接口是指MCU的SWD接口，使用4个测试点，定义如下:

| Pin |    Name     |
|:---:|:-----------:|
| TP1 | V_STBY_3V3. |
| TP2 |    SWDIO    |
| TP3 |    SWCLK    |
| TP4 |     GND     |

表 6 MCU SWD Conn Pin定义

3.  <span id="_Toc221520151" class="anchor"></span>**板卡关键器件丝印**

> 关键器件丝印主要涉及关键芯片及连接器，为便于组装调试，单独在PCB增加丝印标识，丝印定义如下:

![](media/image5.emf)

3.  <span id="_Toc221520152" class="anchor"></span>**单板PCB和信号完整性设计**

    1.  <span id="_Toc517452102" class="anchor"></span>**PCB叠层设计**

> PCB板材选型IT-170GRA2+RTF。
>
> PCB叠层设计详细说明如下，包含板厚，层数，铜厚等信息：

<figure>
<img src="media/image6.png" style="width:6.42569in;height:6.16389in" alt="1709885825681" />
<figcaption><p>图 5 板卡叠层信息</p></figcaption>
</figure>

2.  <span id="_Toc517452103" class="anchor"></span>**PCB走线设计**

> 此板卡各层信号分布如下：
>
> TOP层：P3V3及P12V电源

<img src="media/image7.png" style="width:4.24803in;height:2.3622in" />

> L3层：V_STBY_3V3电源

<img src="media/image8.png" style="width:4.24803in;height:2.3622in" />

> L6层: 高速信号线
>
> <img src="media/image9.png" style="width:4.24803in;height:2.3622in" />
>
> L2层/L4层/L5层/L7层：GND
>
> <img src="media/image10.png" style="width:4.24803in;height:2.3622in" />
>
> <img src="media/image11.png" style="width:4.24803in;height:2.3622in" />
>
> <img src="media/image12.png" style="width:4.24803in;height:2.3622in" />
>
> <img src="media/image13.png" style="width:4.24803in;height:2.3622in" />
>
> Bottom层：单端低速信号及P12V，V_STBY_3V3电源

<figure>
<img src="media/image14.png" style="width:4.24803in;height:2.3622in" />
<figcaption><p>图 6 板卡各层高速线分布</p></figcaption>
</figure>

3.  <span id="_Toc221520155" class="anchor"></span>**高速信号SI仿真和评估**

> 高速链路为整体评估，不提供单板仿真，整体链路仿真在主板统一说明。

4.  <span id="_Toc221520156" class="anchor"></span>**单板结构相关设计**

    1.  <span id="_Toc221520157" class="anchor"></span>**定位孔、禁布区和尺寸说明**

<figure>
<img src="media/image15.png" style="width:6.89028in;height:3.70347in" />
<figcaption><p>图 7 M.2背板板卡结构</p></figcaption>
</figure>
