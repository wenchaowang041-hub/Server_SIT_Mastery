**金丝雀_2SW GPU背板单板详细设计报告**

> **拟 制：<u>洪 刚\_ </u>**
>
> **审 核：<u>丁 雪\_\_\_</u>**
>
> **批 准：<u>王钟一\_\_</u>**

# 目录 

[**1.1** **保密说明** [3](#_Toc220499546)](#_Toc220499546)

[**1.2** **版本历史** [3](#_Toc220499547)](#_Toc220499547)

[**1.3** **术语** [3](#_Toc220499548)](#_Toc220499548)

[**1.4** **参考文档** [3](#_Toc220499549)](#_Toc220499549)

[**1.5** **背景** [3](#_Toc220499550)](#_Toc220499550)

[2 单板总体说明 [3](#_Toc220499551)](#_Toc220499551)

[**2.1** **单板总体框图** [3](#_Toc220499552)](#_Toc220499552)

[2.2 MUX选型 [5](#_Toc220499553)](#_Toc220499553)

[2.3 MUX部分信号切换说明 [7](#_Toc220499554)](#_Toc220499554)

[**2.4** **CPLD选型** [8](#_Toc528584792)](#_Toc528584792)

[3 单板各模块的详细设计 [9](#_Toc220499556)](#_Toc220499556)

[**3.1** **交换芯片模块** [9](#_Toc528257382)](#_Toc528257382)

[**3.2** **时钟模块** [9](#_Toc220499558)](#_Toc220499558)

[**3.3** **CPLD模块** [9](#_Toc220499559)](#_Toc220499559)

[**3.3.1** **PCIE 复位模块** [9](#_Toc528584799)](#_Toc528584799)

[**3.3.2** **CPLD更新模块** [9](#_Toc528584800)](#_Toc528584800)

[**3.3.3** **CPLD与BMC通信模块** [10](#_Toc528584802)](#_Toc528584802)

[**3.3.4** **SGPIO通信模块** [11](#_Toc220499563)](#_Toc220499563)

[**3.3.5** **MUX芯片配置模块** [11](#_Toc220499564)](#_Toc220499564)

[**3.3.6** **拓扑检测码流上报模块** [12](#_Toc220499565)](#_Toc220499565)

[**3.4** **EEPROM模块** [14](#_Toc220499566)](#_Toc220499566)

[**3.5** **单板电源设计** [15](#_Toc220499567)](#_Toc220499567)

[**3.6** **单板接口/连接器pin定义** [15](#_Toc220499568)](#_Toc220499568)

[4 单板PCB和信号完整性设计 [18](#_Toc220499569)](#_Toc220499569)

[**4.1** **PCB叠层设计** [18](#_Toc517452102)](#_Toc517452102)

[**4.2** **PCB走线设计** [19](#_Toc220499571)](#_Toc220499571)

[**4.3** **高速信号SI仿真和评估—信号完整性** [25](#_Toc220499572)](#_Toc220499572)

[5 单板结构相关设计 [26](#_Toc220499573)](#_Toc220499573)

[**5.1** **定位孔、禁布区和尺寸说明** [26](#_Toc220499574)](#_Toc220499574)

**概述**

1.  <span id="_Toc220499546" class="anchor"></span>**保密说明**

> **本技术文档为软通华方公司的机密文件，未经许可，不得复制和传播。**

2.  <span id="_Toc220499547" class="anchor"></span>**版本历史**

| **作者** | **描述**         | **版本** | **日期**   |
|:---------|:-----------------|----------|------------|
| 洪刚     | 初稿编写         | 0.1      | 2025.12.25 |
| 洪刚     | 更新CPLD部分内容 | 0.2      | 2026.01.28 |
|          |                  |          |            |
|          |                  |          |            |
|          |                  |          |            |

3.  <span id="_Toc220499548" class="anchor"></span>**术语**

> **本文档中提到的所有术语、缩写等解释**

| **术语** | **描述**                          |
|:---------|:----------------------------------|
| CPLD     | Complex Programmable Logic Device |
| JTAG     | Joint Test Action Group           |
| I2C      | Inter-Integrated Circuit          |
|          |                                   |

4.  <span id="_Toc220499549" class="anchor"></span>**参考文档**

| **文档名**     | **描述**                            | **版本** | **日期** |
|----------------|-------------------------------------|----------|----------|
| PEX89104-DS108 | PEX89104 PCIE 5.0 Switch Data Sheet | 1.3      | 02/2023  |
|                |                                     |          |          |
|                |                                     |          |          |
|                |                                     |          |          |

5.  <span id="_Toc220499550" class="anchor"></span>**背景**

> 2SW GPU背板的作用是用于连接GPU，通过软连接的方式与主板和其它板卡互连，搭配结构支架装配到机箱后部。

1.  <span id="_Toc220499551" class="anchor"></span>**单板总体说明**

    1.  <span id="_Toc220499552" class="anchor"></span>**单板总体框图**

> 金丝雀2SW卡主要是在青隼的2SW卡BP-0011卡基础上增加PCIE MUX功能，可实现均衡模式和级联模式，2个SW芯片的STACK的MASTER/SLAVE状态始终不发生变化。MUX采用PARADE公司的PS8580。MUX控制功能由CPLD操作I2C实现（不采用BMC控制主要是因为地址冲突且采用了非标准地址），相应增加MUX电源（之前的板卡1.8V电源为博通交换芯片IO电源，总共只有1A，不能满足要求。）
>
> 板卡总体的结构和在整机中的逻辑关系如下图所示：

![](media/image1.emf)

> MUX部分连接示意图
>
> ![](media/image2.emf)

2.  <span id="_Toc220499553" class="anchor"></span>MUX选型

> 方案阶段有3款芯片备选，分为2种类型

- 类型1 简单MUX,PERICOM公司

> PI2DBS32212：
>
> 2个通道切换，总共需要使用32颗芯片
>
> PI2DBS32412：
>
> 4个通道切换，总共需要使用16颗芯片,单价28元@100pcs，力创价格。
>
> 简单MUX的缺点是业内没有进行级联的应用。
>
> 简单MUX的方案见下图：
>
> ![](media/image3.emf)

- 类型2，REDRIVER+MUX

> TI SN75LVPE5421/5412或者PS8580

![](media/image4.emf)

> TI SN75LVPE5421/5412支持4个通道切换，总共需要使用16颗芯片,单价54元@100pcs，立创上的价格，PS8580为3.1美金一片，需要用到16片，一种芯片用8片。
>
> 存在的问题：
>
> 硬件上看我们的应用比较合适，但是TI没有技术支持，相对简单MUX来说控制比较复杂，需要调EQ和GAIN，如果不用BMC参与的情况下需要占用CPLD管脚和资源，需要将换CPLD为400pin的。
>
> 鉴于信号完整性和器件供货及技术支持角度的考虑，选用PS8580。
>
> 下图是PS8580的逻辑功能框图

<img src="media/image5.png" style="width:2.76809in;height:1.87553in" />

1.  <span id="_Toc220499554" class="anchor"></span>MUX部分信号切换说明

![](media/image6.emf)

![](media/image7.emf)

> **单板运行环境说明：**
>
> 按照同方服务器设计标准支持常温运行、贮藏：

- 工作温度：5~35℃（散热需明确35℃/40℃/45℃下各有哪些配置支持）

- 工作湿度：20%~80% R.H.

- 贮存温度（不带包装）：-40~+55℃

- 贮存湿度（不带包装）：10%~93%R.H.

- 贮存温度（带包装）：-40~+70℃

- 贮存湿度（带包装）：10%~93% R.H.

- 海拔要求：海拔高度：0 到 914 米（3000英尺）时工作温度5 到 35 摄氏度；海拔高度：914 到 2133 米7000 英尺）时工作温度10 到 32 摄氏度

> 另外，产品需求中新增：

- 存储及运输环境：相对湿度5%-93%，气压范围20-108kPa。

  1.  <span id="_Toc528584792" class="anchor"></span>**CPLD选型**

> 主板选用安路的EF3L90CG400B，资源情况如下表所示。

<table style="width:79%;">
<caption><p>表 1 EF3L90CG400B资源</p></caption>
<colgroup>
<col style="width: 28%" />
<col style="width: 11%" />
<col style="width: 14%" />
<col style="width: 12%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr>
<th style="text-align: left;"><strong>器件</strong></th>
<th style="text-align: left;"><strong>LUTs</strong></th>
<th style="text-align: left;">Distributed RAM (kb)</th>
<th style="text-align: left;"><strong>EBR SRAM (kb)</strong></th>
<th style="text-align: left;"><strong>IO pin</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: left;">EF3L90CG400B</td>
<td style="text-align: left;">9280</td>
<td style="text-align: left;">74</td>
<td style="text-align: left;">270</td>
<td style="text-align: left;">222</td>
</tr>
<tr>
<td style="text-align: left;">预估资源</td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td style="text-align: left;"><p>66.3%</p>
<p>IO占用</p></td>
</tr>
</tbody>
</table>

2.  <span id="_Toc220499556" class="anchor"></span>**单板各模块的详细设计**

    1.  <span id="_Toc528257382" class="anchor"></span>**交换芯片模块**

> 交换芯片沿用之前的博通的PEX89104 Gen5 PCIe交换芯片，具备以下特性：支持多达 104条通道；最大52个端口均支持热插拔；具备先进的错误隔离功能；拥有全面的诊断与调试能力；提供丰富的 I/O 接口；支持安全启动；并搭载高性能 DMA（直接内存访问）控制器。
>
> 支持动态端口拆分
>
> 支持 SPI（串行外设接口）用于读取固件信息
>
> 支持调试 UART（通用异步收发传输器）
>
> 支持 PCIe Gen5（第五代 PCIe），传输速率达 32 GT/s

2.  <span id="_Toc220499558" class="anchor"></span>**时钟模块**

> 金丝雀2SW卡内部的时钟方案和之前比的变化是将GPU4插槽的时钟由MCIO线缆提供转为板上时钟芯片输出直接连接（因为整个系统中的时钟源是一个）。
>
> 依据时钟需求，2SW板采用了时钟FANOUT-BUFFER芯片，9QXL2001BNHGI8，提供20路时钟输出。时钟芯片为LP-HCSL输出，芯片上提供端接，减少PCB端接电阻，阻抗85欧姆，3.3V单电源供电，增加抖动较低，支持输出阻抗微调。

3.  <span id="_Toc220499559" class="anchor"></span>**CPLD模块**

> CPLD主要包括以下功能模块：
>
> PCIE复位模块
>
> CPLD更新模块
>
> CPLD与BMC通信模块

1.  <span id="_Toc528584799" class="anchor"></span>**PCIE 复位模块**

> 由于switch板后挂了许多PCIE设备，CPLD负责对这些PCIE设备进行复位解复位逻辑，功能框图：

![](media/image8.emf)

> 后级PCIE设备的解复位，要同时满足基础板上电初始化完成，基础板发出的PERST解复位及SW板0.8V电POWERGOOD。

2.  <span id="_Toc528584800" class="anchor"></span>**CPLD更新模块**

> 通过JTAG总线可以用来升级2SW板CPLD，2SW板上存在一个JTAG header,用于debug阶段的功能调试和升级以及第一次的程序烧录，下图是对应的逻辑框图。

<figure>
<img src="media/image9.emf" />
<figcaption><p>图10 CPLD更新框图</p></figcaption>
</figure>

3.  <span id="_Toc528584802" class="anchor"></span>**CPLD与BMC通信模块**

> CPLD与BMC之间通过I2C进行数据的交互通信，CPLD I2C的地址为0010_001(x). BMC进行数据读写的数据格式如下所示。
>
> 下图是BMC写数据给CPLD的数据格式。

<figure>
<img src="media/image10.emf" />
<figcaption><p>图11 BMC写数据格式</p></figcaption>
</figure>

> 下图是BMC从CPLD读数据格式。

<figure>
<img src="media/image11.emf" />
<figcaption><p>图12 BMC读数据格式</p></figcaption>
</figure>

> 具体的数据格式如下表所示，详见CPLD接口文档。
>
> ![](media/image12.emf)

4.  <span id="_Toc220499563" class="anchor"></span>**SGPIO通信模块**

> 2switch板需要来自扩展板发送的主板上电状态完成信号，用来做后级PCIE设备的PCIE RESET逻辑。还需要BMC发送给扩展板的sw_mode去配置MUX芯片工作模式的命令，因此扩展板与switch板选择使用SGPIO通信，SGPIO通信模块如下图所示：

![](media/image13.emf)

扩展板发送给switch的数据格式如下表：

| 比特位 | switch卡信号 | 含义                 |
|--------|--------------|----------------------|
| 0      | pwr_but      | 主板上电、初始化完成 |
| 1      | sw_mode\[0\] | MUX芯片工作模式bit0  |
| 2      | sw_mode\[1\] | MUX芯片工作模式bit1  |
| 3      | sw_mode\[2\] | MUX芯片工作模式bit2  |
| 4      | sw_mode\[3\] | MUX芯片工作模式bit3  |

5.  <span id="_Toc220499564" class="anchor"></span>**MUX芯片配置模块**

![](media/image14.emf)

> MUX芯片需要配置的寄存器如下图，CPLD作为master，要对下列寄存器进行配置后，MUX芯片可正常工作，0x5a寄存器的配置值由BMC配置给扩展板CPLD，通过SGPIO传给2switch，其他寄存器配置值由硬件实测后决定。

<img src="media/image15.png" style="width:2.84375in;height:2.96042in" /><img src="media/image16.png" style="width:2.84167in;height:2.96389in" />

6.  <span id="_Toc220499565" class="anchor"></span>**拓扑检测码流上报模块**

![](media/image17.emf)

> 拓扑检测码流发送链路层采用Hisport 协议传输，帧长度41字节，各字节具体内容如下图。由2switch板发送以下信息，经线缆中的单根信号路由到主板CPLD，经过解析后发送给BIOS和BMC，BMC依据解析出来的CableID、Index、UID来判断组件类型以及线缆是否插错，BIOS根据上报的28-32字节，对挂载的端口模式进行配置。

<img src="media/image18.png" style="width:4.59722in;height:2.69931in" />

<img src="media/image19.png" style="width:4.50903in;height:4.85417in" />

4.  <span id="_Toc220499566" class="anchor"></span>**EEPROM模块**

> 金丝雀2SW卡上放置一个EEPROM，用于存储固定资产信息，下挂在BMC总线下，EEPROM型号为M24128-BWMN6TP，器件地址为0xAE。具体格式如下表所示。

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
<td style="text-align: left;">填写ODM厂商名称</td>
<td style="text-align: left;">必填</td>
</tr>
<tr>
<td style="text-align: left;">Board Product Name</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;">由ODM厂商定义</td>
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
<td style="text-align: left;">由ODM厂商按规则生成</td>
<td style="text-align: left;">必填</td>
</tr>
<tr>
<td rowspan="6" style="text-align: center;">Product</td>
<td style="text-align: left;">Manufacture Name</td>
<td style="text-align: left;">　</td>
<td style="text-align: left;">由ODM厂商定义</td>
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
<td style="text-align: left;">由ODM厂商按规则生成</td>
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

5.  <span id="_Toc220499567" class="anchor"></span>**单板电源设计**

> 2SW GPU背板需要外部提供12V输入，由3个2x8Pin电源连接器进行供电P12V_SW_A@42A、P12V_SW_B@42A、P12V_SW_C@42A 。

6.  <span id="_Toc220499568" class="anchor"></span>**单板接口/连接器pin定义**

> 接口说明

<table style="width:86%;">
<colgroup>
<col style="width: 4%" />
<col style="width: 35%" />
<col style="width: 4%" />
<col style="width: 41%" />
</colgroup>
<thead>
<tr>
<th><blockquote>
<p>1</p>
</blockquote></th>
<th><blockquote>
<p>2x8 Pin电源连接器</p>
</blockquote></th>
<th><blockquote>
<p>2</p>
</blockquote></th>
<th><blockquote>
<p>2x5 Pin低速连接器(与主板连接)</p>
</blockquote></th>
</tr>
</thead>
<tbody>
<tr>
<td><blockquote>
<p>3</p>
</blockquote></td>
<td><blockquote>
<p>MCIO x8高速连接器</p>
</blockquote></td>
<td><blockquote>
<p>4</p>
</blockquote></td>
<td><blockquote>
<p>2x5 Pin低速连接器(与级联背板连接)</p>
</blockquote></td>
</tr>
</tbody>
</table>

> 2x8 Pin电源连接器针脚定义

| **说明** | **电平** | **方向** | **信号** | **针脚** | **针脚** | **信号** | **方向** | **电平** | **说明** |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| P3V3_STBY电源 | 3.3V | I | P3V3_STBY | 1 | 9 | GND | I | 0V | 回流地 |
| 12V电源 | 12V | I | P12V_IN_SW_A | 2 | 10 | GND | I | 0V | 回流地 |
| 12V电源 | 12V | I | P12V_IN_SW_A | 3 | 11 | GND | I | 0V | 回流地 |
| 12V电源 | 12V | I | P12V_IN_SW_A | 4 | 12 | GND | I | 0V | 回流地 |
| 12V电源 | 12V | I | P12V_IN_SW_A | 5 | 13 | GND | I | 0V | 回流地 |
| 12V电源 | 12V | I | P12V_IN_SW_A | 6 | 14 | GND | I | 0V | 回流地 |
| 12V电源 | 12V | I | P12V_IN_SW_A | 7 | 15 | GND | I | 0V | 回流地 |
| 12V电源 | 12V | I | P12V_IN_SW_A | 8 | 16 | GND | I | 0V | 回流地 |

2x5 Pin低速连接器(与主板连接)针脚定义

| **说明** | **电平** | **方向** | **信号** | **针脚** | **针脚** | **信号** | **方向** | **电平** | **说明** |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| BMC的I2C管理 | 3.3V | O | BMC_I2C_SCL | 1 | 2 | GND | I | 0V | 回流地 |
| BMC的I2C管理 | 3.3V | I/O | BMC_I2C_SDA | 3 | 4 | BP_PRSNT_N | I | 0V | 背板在位信号 |
| PCIe卡节流信号 | 3.3V | O | PCIE_THROTTLE_N | 5 | 6 | GND | I | 0V | 回流地 |
| SGPIO数据输入 | 3.3V | I | SGPIO_DIN | 7 | 8 | SGPIO_DOUT | O | 3.3V | SGPIO数据输出 |
| SGPIO标志位 | 3.3V | O | SGPIO_LOAD | 9 | 10 | SGPIO_CLK | O | 3.3V | SGPIO时钟 |

2x5 Pin低速连接器(与级联背板连接)针脚定义

| **说明** | **电平** | **方向** | **信号** | **针脚** | **针脚** | **信号** | **方向** | **电平** | **说明** |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| I2C时钟 | 3.3V | O | A_SHPC_I2C_3V3_SCL | 1 | 2 | B_SHPC_I2C_3V3_SCL | O | 3.3V | I2C时钟 |
| I2C数据 | 3.3V | I/O | A_SHPC_I2C_3V3_SDA | 3 | 4 | B_SHPC_I2C_3V3_SDA | I/O | 3.3V | I2C数据 |
| 中断信号 | 3.3V | O | A_SHPC_INT_3V3_N | 5 | 6 | B_SHPC_INT_3V3_N | O | 0V | 中断信号 |
| SW ID | 3.3V | I | SW_ID0 | 7 | 8 | SW_ID1 | I | 3.3V | SW ID |
| 回流地 | 0V | I | GND | 9 | 10 | GND | I | 0V | 回流地 |

MCIO x8高速连接器针脚定义

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

> 调试CPLD的JTAG接口，Pin定义如下:

| **Pin** | **Name** | **Pin** |    **Name**    |
|:-------:|:--------:|:-------:|:--------------:|
|    1    | CPLD_TCK |    2    |      GND       |
|    3    | CPLD_TDO |    4    | P3V3_CPLD_JTAG |
|    5    | CPLD_TMS |    6    |                |
|    7    |          |    8    |                |
|    9    | CPLD_TDI |   10    |      GND       |

3.  <span id="_Toc220499569" class="anchor"></span>**单板PCB和信号完整性设计**

    1.  <span id="_Toc517452102" class="anchor"></span>**PCB叠层设计**

> PCB板材选型Low-Loss（PCIe5.0）, 型号Gallop 7D，其插损参数如下：

<table style="width:97%;">
<colgroup>
<col style="width: 11%" />
<col style="width: 14%" />
<col style="width: 23%" />
<col style="width: 10%" />
<col style="width: 18%" />
<col style="width: 18%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;">阻抗</th>
<th style="text-align: center;">Trace Type</th>
<th style="text-align: center;">Trace Layer</th>
<th style="text-align: center;">Pitch</th>
<th style="text-align: center;">8GHz</th>
<th style="text-align: center;">16GHz</th>
</tr>
</thead>
<tbody>
<tr>
<td rowspan="6" style="text-align: center;">85omh</td>
<td style="text-align: center;">MS</td>
<td style="text-align: center;">L1&amp;L18</td>
<td style="text-align: center;">12.00</td>
<td style="text-align: center;">0.75</td>
<td style="text-align: center;">1.30</td>
</tr>
<tr>
<td style="text-align: center;">MS</td>
<td style="text-align: center;">L1&amp;L18</td>
<td style="text-align: center;">16.00</td>
<td style="text-align: center;">0.73</td>
<td style="text-align: center;">1.28</td>
</tr>
<tr>
<td style="text-align: center;">SL</td>
<td style="text-align: center;">L3&amp;L5&amp;&amp;L14&amp;L16</td>
<td style="text-align: center;">12.00</td>
<td style="text-align: center;">0.38(-0.432)</td>
<td style="text-align: center;">0.65(-0.712)</td>
</tr>
<tr>
<td style="text-align: center;">SL</td>
<td style="text-align: center;">L3&amp;L5&amp;&amp;L14&amp;L16</td>
<td style="text-align: center;">16.00</td>
<td style="text-align: center;">0.36(-0.415)</td>
<td style="text-align: center;">0.63(-0.684)</td>
</tr>
<tr>
<td style="text-align: center;">SL</td>
<td style="text-align: center;">L7&amp;L12</td>
<td style="text-align: center;">12.00</td>
<td style="text-align: center;">0.38(-0.452)</td>
<td style="text-align: center;">0.65(-0.732)</td>
</tr>
<tr>
<td style="text-align: center;">SL</td>
<td style="text-align: center;">L7&amp;L12</td>
<td style="text-align: center;">16.00</td>
<td style="text-align: center;">0.36(-0.435)</td>
<td style="text-align: center;">0.63(-0.704)</td>
</tr>
</tbody>
</table>

图 23 PCB材料特性

> PCB叠层设计详细说明如下，包含板厚，层数，铜厚等信息：

<figure>
<img src="media/image20.png" style="width:6.89028in;height:5.28958in" />
<figcaption><p>图 24 板卡叠层信息</p></figcaption>
</figure>

2.  <span id="_Toc220499571" class="anchor"></span>**PCB走线设计**

> TOP / BOTTOM层：CLK&DB2001及单端信号。

<img src="media/image21.png" style="width:6.88472in;height:3.64653in" />

<img src="media/image22.png" style="width:6.88472in;height:3.64653in" />

L3层：PCIE_RX&PCIE_TX&MUX_SW_RX及单端信号。

<img src="media/image23.png" style="width:6.88472in;height:3.64653in" />

L5层：PCIE_RX&PCIE_TX&MUX_SW_TX及单端信号。

<img src="media/image24.png" style="width:6.88472in;height:3.64653in" />

L7层：PCIE_RX&MUX_SW_RX&DB2001&100M时钟及单端信号。

<img src="media/image25.png" style="width:6.88472in;height:3.64653in" />

L12层：PCIE_TX&MUX_SW_TX及单端信号。

<img src="media/image26.png" style="width:6.88472in;height:3.64653in" />

L14层：PCIE_TX&PCIE_RX及单端信号。

<img src="media/image27.png" style="width:6.88472in;height:3.64653in" />

L16层：PCIE_TX&PCIE_RX&MUX_TX及单端信号。

<img src="media/image28.png" style="width:6.88472in;height:3.64653in" />

L9/L10层: 电源层，左侧为P1V25_SW2_SERDES_VDDPLL&P0V8_SW2，右侧为P0V8_SW&P1V25_SW1_SERDES_VDDPLL,中间3路P12V_PCIE

> <img src="media/image29.png" style="width:6.88472in;height:3.64653in" />

L10层: 电源层，左侧为P1V25_SW2_SERDES_VDDPLL&P0V8_SW2_SERDES_VDDA，右侧为P0V8_SW1_SERDES_VDDA&P1V25_SW1_SERDES_VDDPLL，中间P12V_PCIE&P3V3_STBY&P12V_IN

<img src="media/image30.png" style="width:6.88472in;height:3.64653in" />

> L2层/ L4层/L6层/L8层/L11层/L13层/L15层/L17层：GND

<figure>
<img src="media/image31.png" style="width:6.88472in;height:3.64653in" />
<figcaption><p>图 25 板卡各层高速线分布</p></figcaption>
</figure>

3.  <span id="_Toc220499572" class="anchor"></span>**高速信号SI仿真和评估—信号完整性**

> 此板卡主要高速信号为PCIE信号，需评估PCIE Gen5链路风险。由于MUX的模拟芯片特性，需要综合考虑其前后的线路损耗，尤其在MUX芯片的接收侧，必须有大于5dB 的损耗，因此进行了仿真

<figure>
<img src="media/image32.emf" />
<figcaption><p>图 26 PCIe链路拓扑</p></figcaption>
</figure>

链路评估如下：

<figure>
<img src="media/image33.png" style="width:4.84028in;height:3.51736in" alt="D:\new-2sw\doc\仿真.png" />
<figcaption><p>图 27 PCIe5.0链路评估</p></figcaption>
</figure>

> 基于上述仿真结果分析，当前设计PCIE Gen5链路为低风险，需持续跟进板卡对应的CPU仿真模型及PDG更新，进一步评估链路风险，若有必要可通过升级cable 选型、走线长度、板材选型等进行优化。
>
> 备注：
>
> （1）上述评估结果是基于华为920主板进行评估，包括链路拓扑结构，各部分线长、损耗等信息。
>
> （2）当前华为920芯片、封装等仿真模型持续更新，需要根据华为920芯片及模型更新进一步评估链路风险。

4.  <span id="_Toc220499573" class="anchor"></span>**单板结构相关设计**

    1.  <span id="_Toc220499574" class="anchor"></span>**定位孔、禁布区和尺寸说明**

<img src="media/image34.png" style="width:6.89028in;height:3.52083in" />

<img src="media/image35.png" style="width:6.89028in;height:0.47083in" />

<figure>
<img src="media/image36.png" style="width:6.89028in;height:4.34722in" />
<figcaption><p>图 30 2SW板卡结构</p></figcaption>
</figure>
