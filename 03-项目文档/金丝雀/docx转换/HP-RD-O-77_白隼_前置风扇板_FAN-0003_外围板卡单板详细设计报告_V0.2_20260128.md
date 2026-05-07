**白隼前置风扇板**\_**单板详细设计报告**

> **拟 制：<u>­­\_ 洪刚 </u>**
>
> **审 核：<u>\_\_丁雪 \_\_\_</u>**
>
> **批 准：<u>\_\_王钟一\_\_</u>**

# 目录

[概述 [4](#_Toc221265157)](#_Toc221265157)

[**1.1** **保密说明** [4](#_Toc221265158)](#_Toc221265158)

[**1.2** **版本历史** [4](#_Toc221265159)](#_Toc221265159)

[**1.3** **术语** [4](#_Toc221265160)](#_Toc221265160)

[**1.4** **参考文档** [4](#_Toc221265161)](#_Toc221265161)

[**1.5** **背景** [4](#_Toc221265162)](#_Toc221265162)

[2 单板总体说明 [4](#_Toc221265163)](#_Toc221265163)

[**2.1** **单板总体框图** [4](#_Toc221265164)](#_Toc221265164)

[**2.2** **CPLD选型** [5](#_Toc528584792)](#_Toc528584792)

[3 单板各模块的详细设计 [5](#_Toc221265166)](#_Toc221265166)

[**3.1** **CPLD模块** [5](#_Toc528257382)](#_Toc528257382)

[**3.1.1** **滤波模块** [6](#_Toc528584796)](#_Toc528584796)

[**3.1.2** **风扇控制** [6](#_Toc221265169)](#_Toc221265169)

[**3.1.3** **CPLD更新** [7](#_Toc528584800)](#_Toc528584800)

[**3.1.4** **CPLD与BMC通信模块** [8](#_Toc528584802)](#_Toc528584802)

[**3.2** **EEPROM模块** [9](#_Toc221265172)](#_Toc221265172)

[**3.3** **风扇模块** [10](#_Toc528479120)](#_Toc528479120)

[**3.4** **温度监控模块** [10](#_Toc221265174)](#_Toc221265174)

[**3.5** **各模块之间的总线设计** [10](#_Toc68878246)](#_Toc68878246)

[**3.5.1** **SMBus/I2C拓扑** [10](#_Toc68878247)](#_Toc68878247)

[**3.5.2** **JTAG链路** [11](#_Toc68878248)](#_Toc68878248)

[**3.6** **单板电源设计** [11](#_Toc68878249)](#_Toc68878249)

[**3.6.1** **电源总体** [11](#_Toc221265179)](#_Toc221265179)

[**3.6.2** **风扇电源部分电路** [12](#_Toc221265180)](#_Toc221265180)

[**3.7** **单板接口/连接器pin定义** [12](#_Toc68878250)](#_Toc68878250)

[**3.7.1** **内部接口** [12](#_Toc68878251)](#_Toc68878251)

[**3.7.2** **外部接口** [13](#_Toc68878252)](#_Toc68878252)

[**3.7.3** **调试接口** [13](#_Toc68878253)](#_Toc68878253)

[4 单板PCB和信号完整性设计 [14](#_Toc68878254)](#_Toc68878254)

[**4.1** **PCB 叠层设计** [14](#_Toc28037711)](#_Toc28037711)

[**4.2** **PCB 走线设计** [14](#_Toc68878256)](#_Toc68878256)

[**4.3** **高速信号SI仿真和评估** [16](#_Toc68878257)](#_Toc68878257)

[**4.4** **功能接口丝印** [16](#_Toc221265189)](#_Toc221265189)

[5 单板结构相关设计 [18](#_Toc193359661)](#_Toc193359661)

[**5.1** **定位孔、禁布区和尺寸说明** [18](#_Toc193359662)](#_Toc193359662)

[**5.2** **特殊结构件** [18](#_Toc193359663)](#_Toc193359663)

<span id="_Toc221265157" class="anchor"></span>**概述**

1.  <span id="_Toc221265158" class="anchor"></span>**保密说明**

> **本技术文档为软通华方公司的机密文件，未经许可，不得复制和传播。**

2.  <span id="_Toc221265159" class="anchor"></span>**版本历史**

| **作者** | **描述**             | **版本** | **日期**   |
|:---------|:---------------------|----------|------------|
| 洪刚     | 首次发布             | V0.1     | 2025/11/21 |
| 洪刚     | 按照公司模板更新章节 | V0.2     | 2026/01/28 |
|          |                      |          |            |

3.  <span id="_Toc221265160" class="anchor"></span>**术语**

> **本文档中提到的所有术语、缩写等解释**

| **术语** | **描述**                          |
|:---------|:----------------------------------|
| CPLD     | Complex Programmable Logic Device |
| JTAG     | Joint Test Action Group           |
| I2C      | Inter-Integrated Circuit          |
|          |                                   |
|          |                                   |

4.  <span id="_Toc221265161" class="anchor"></span>**参考文档**

| **文档名** | **描述** | **版本** | **日期** |
|------------|----------|----------|----------|
|            |          |          |          |
|            |          |          |          |
|            |          |          |          |

5.  <span id="_Toc221265162" class="anchor"></span>**背景**

> 白隼服务器是软通华方公司自研的6U AI服务器，可广泛适用于大规模模型训练、数据库、云端推理等业务负载。前置风扇板安装在服务器机箱前方，支持5个8080热插拔风扇，为后端的主板及GPU进行散热。

1.  <span id="_Toc221265163" class="anchor"></span>**单板总体说明**

    1.  <span id="_Toc221265164" class="anchor"></span>**单板总体框图**

> 前置风扇板从主板取12V电，供给5个8080风扇，板上eFuse芯片可以实现功耗监控及报警功能。风扇板上能够支持5个8080的风扇，使用安路的EF2L45BG256型号的CPLD，可以支持5个风扇的转速调控、转速监控、指示灯功能（红或绿）及根据服务器上电状态切换风扇调控策略等功能。
>
> 风扇板的板卡拓扑如下图所示：

![](media/image1.emf)

> 图 1 2 前置风扇板卡拓扑

2.  <span id="_Toc528584792" class="anchor"></span>**CPLD选型**

> 前置风扇板核心控制选用安路的EF2L45BG256，资源情况如下表所示。

| **器件**    | **LUTs** | **registers** | **IO pin** |
|-------------|----------|---------------|------------|
| EF2L45BG256 | 2698     | 1617          | 92         |
| 预估资源    | 60.22%   | 36.09%        | 44%        |

表 1 EF2L45BG256资源

2.  <span id="_Toc221265166" class="anchor"></span>**单板各模块的详细设计**

    1.  <span id="_Toc528257382" class="anchor"></span>**CPLD模块**

> 初始化模块主要包括系统时钟和全局复位信号的生成，其中：

1.  提供外部25M时钟，连接到CPLD全局时钟管脚；

2.  CPLD内部晶振生成24.18MHz的时钟信号作为系统时钟备选；

3.  计数器计时1us作为全局复位信号，提高系统工作的稳定性；

下图是初始化模块的逻辑框图。

![](media/image2.emf)

图 3 初始化模块

1.  <span id="_Toc528584796" class="anchor"></span>**滤波模块**

> 通过滤波处理，去除风扇板上进入CPLD的信号抖动，下图是滤波模块的示意图。

![](media/image3.emf)

> 滤波效果如下图所示，有效地滤波可以提高风扇转速解析的正确性，避免误触发。![](media/image4.emf)
>
> 图 4 滤波效果图

2.  <span id="_Toc221265169" class="anchor"></span>**风扇控制**

> 如下图所示，主板BMC与风扇板CPLD之间通过I2C总线实现PWM和TACH信号的控制，发送PWM信号并接收TACH信号，实现风扇的转速控制和回传。同时点亮外部风扇指示灯，当风扇正常工作时，LED为绿色，异常时为红色，目前EVT不支持指示灯功能，DVT增加。

<figure>
<img src="media/image5.emf" />
<figcaption><blockquote>
<p>图 5 风扇控制逻辑</p>
</blockquote></figcaption>
</figure>

3.  <span id="_Toc528584800" class="anchor"></span>**CPLD更新**

> 由于前置5风扇板在白隼和金丝雀项目上均要使用，但CPLD更新方案不同，以下分别对白隼、金丝雀进行方案说明。
>
> 白隼：通过JTAG和I2C总线可以用来升级前置风扇板上的CPLD，前置风扇板上存在一个JTAG header,用于debug阶段的功能调试和升级，BMC的I2C总线用于远程在线升级前置风扇板CPLD，下图是对应的逻辑框图。 ![](media/image6.emf)

图10 白隼前置风扇板CPLD更新框图

> 为了保证前置风扇板CPLD的可维护性，BMC可以通过I2C总线进行CPLD的在线升级。前置风扇板升级只在关机状态下，CPLD的IO口变化不会影响前置风扇板的功能。BMC通过I2C通道实现CPLD内部flash及SRAM的升级，实现CPLD的功能升级。
>
> 金丝雀：首先，前置风扇板上存在一个JTAG header,用于debug阶段的功能调试和升级。其次，扩展板CPLD作为桥梁，路由从BMC过来的JTAG信号，BMC若想升级前置风扇板，会通过IIC SMC命令字告诉扩展板CPLD，扩展板CPLD会打开相应的路由通道，然后BMC进行刷新。如下图逻辑框图所示。

<figure>
<img src="media/image7.emf" />
<figcaption><p>图11 金丝雀前置风扇板CPLD更新框图</p></figcaption>
</figure>

4.  <span id="_Toc528584802" class="anchor"></span>**CPLD与BMC通信模块**

> CPLD与BMC之间通过I2C进行数据的交互通信，CPLD I2C的地址为0010_000(x). BMC进行数据读写的数据格式如下所示。
>
> 下图是BMC写数据给CPLD的数据格式。![](media/image8.emf)

图12 BMC写数据格式

> 下图是BMC从CPLD读数据格式。![](media/image9.emf)

图13 BMC读数据格式

> 下图是BMC与CPLD的I2C通信模块，BMC会根据不同的command进行数据的读写。

<figure>
<img src="media/image10.emf" />
<figcaption><p>图14 I2C通信模块</p></figcaption>
</figure>

> 具体的数据格式如下表所示，详见下方白隼前置风扇板SMC命令字定义文档。
>
> ![](media/image11.emf)

1.  <span id="_Toc221265172" class="anchor"></span>**EEPROM模块**

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
<td>Chassis Type</td>
<td>　</td>
<td>　</td>
<td>可选</td>
</tr>
<tr>
<td>Chassis Part Number</td>
<td>　</td>
<td>　</td>
<td>可选</td>
</tr>
<tr>
<td>Chassis Serial Number</td>
<td>　</td>
<td>　</td>
<td>可选</td>
</tr>
<tr>
<td rowspan="5" style="text-align: center;">Board</td>
<td>Manufacture Date/Time</td>
<td>　</td>
<td>　</td>
<td>必填</td>
</tr>
<tr>
<td>Board Manufacturer</td>
<td>　</td>
<td>填写ODM厂商名称</td>
<td>必填</td>
</tr>
<tr>
<td>Board Product Name</td>
<td>　</td>
<td>由ODM厂商定义</td>
<td>必填</td>
</tr>
<tr>
<td>Board Serial Number</td>
<td>　</td>
<td>　</td>
<td>可选</td>
</tr>
<tr>
<td>Board Part Number</td>
<td>　</td>
<td>由ODM厂商按规则生成</td>
<td>必填</td>
</tr>
<tr>
<td rowspan="6" style="text-align: center;">Product</td>
<td>Manufacture Name</td>
<td>　</td>
<td>固定填写“Tencent”</td>
<td>必填</td>
</tr>
<tr>
<td>Product Name</td>
<td>　</td>
<td>由客户提供</td>
<td>必填</td>
</tr>
<tr>
<td>Product Part/Model Name</td>
<td>　</td>
<td>　</td>
<td>可选</td>
</tr>
<tr>
<td>Product Version</td>
<td>　</td>
<td>产品版本，如V3，V5等，客户提供</td>
<td>可选</td>
</tr>
<tr>
<td>Product Serial Number</td>
<td>　</td>
<td>由ODM厂商按规则生成</td>
<td>必填</td>
</tr>
<tr>
<td>Asset Tag</td>
<td>　</td>
<td>　</td>
<td>可选</td>
</tr>
</tbody>
</table>

2.  <span id="_Toc528479120" class="anchor"></span>**风扇模块**

> BMC根据温度信息控制风扇转速，转速信息通过I2C传递风扇转速到主板BMC。为了保证BMC异常时风扇处于可控状态，CPLD监控BMC发出的I2C信号来判断BMC是否正常工作。当BMC正常工作时，该I2C信号会持续操作CPLD的寄存器，当CPLD监测到信号持续异常10s后，CPLD控制风扇保持固定的转速。
>
> S0状态下，若BMC持续挂死10s后，CPLD控制风扇转速为80%。
>
> 风扇模块转速调控逻辑框图参考3.1.3节 图5风扇控制逻辑。

3.  <span id="_Toc221265174" class="anchor"></span>**温度监控模块**

> 板上温度sensor使用1片LM75BDP,该芯片支持本体测温点，用于监测整机进风口的温度，并将温度通过I2C总线传递到BMC执行散热策略。

4.  <span id="_Toc68878246" class="anchor"></span>**各模块之间的总线设计**

    1.  <span id="_Toc68878247" class="anchor"></span>**SMBus/I2C拓扑**

> Fan Board上I2C链路一共有5路：

- 1路来自主板BMC的I2C，主板上的BMC作为MASTER。

> 连接前置风扇板的FRU EEPROM和CPLD，FRU EEPROM放置风扇板板的FRU信息；CPLD有两个I2C-SLAVE，分别为在线升级和与BMC通信的I2C CPLD通过该I2C总线与BMC进行通信

- 3路CPLD作为MASTER的I2C，分别控制1个Temperature Sensor、以及2个功率检测芯片。

> 前置风扇板的总体I2C拓扑如下图所示：

![](media/image12.emf)

图 9风扇板I2C拓扑

如下表为I2C设备的地址表：

<table>
<caption><blockquote>
<p>表 3 Fan Board I2C设备地址表</p>
</blockquote></caption>
<colgroup>
<col style="width: 11%" />
<col style="width: 22%" />
<col style="width: 14%" />
<col style="width: 51%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;">位号</th>
<th style="text-align: center;">I2C器件</th>
<th style="text-align: center;">Address</th>
<th style="text-align: center;">Function</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: center;"><p>U7</p>
<p>U9</p></td>
<td>INA226</td>
<td>1000 000X</td>
<td>监控风扇功耗</td>
</tr>
<tr>
<td style="text-align: center;">U15</td>
<td>TEMP SENSOR</td>
<td>1001 000X</td>
<td>测量板卡温度</td>
</tr>
<tr>
<td style="text-align: center;">U14</td>
<td>FRU EEPROM</td>
<td>1010 111X</td>
<td>存储FRU信息,地址按照华为的要求进行更改</td>
</tr>
<tr>
<td style="text-align: center;">U1</td>
<td>CPLD</td>
<td>0111 100X</td>
<td>CPLD在线刷新</td>
</tr>
<tr>
<td style="text-align: center;">U1</td>
<td>CPLD</td>
<td>0110 000X</td>
<td>CPLD版本等信息</td>
</tr>
</tbody>
</table>

1.  <span id="_Toc68878248" class="anchor"></span>**JTAG链路**

> 板卡上CPLD的JTAG接口可以通过JTAG线缆或者主板进行升级，当插入JTAG烧写器时，MUX开关将JTAG链路切换到插座通路，否则为在线升级通路，JTAG部分的拓扑如下图所示。

<figure>
<img src="media/image13.emf" />
<figcaption><blockquote>
<p>图 10 JTAG拓扑</p>
</blockquote></figcaption>
</figure>

1.  <span id="_Toc68878249" class="anchor"></span>**单板电源设计**

    1.  <span id="_Toc221265179" class="anchor"></span>**电源总体**

> Fan Board的Power Requirement如下图所示：

<table style="width:100%;">
<caption><p>图 11 Fan Board Power Requirement</p></caption>
<colgroup>
<col style="width: 24%" />
<col style="width: 37%" />
<col style="width: 13%" />
<col style="width: 12%" />
<col style="width: 12%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;"><strong>Signal</strong></th>
<th style="text-align: center;"><strong>Net Name</strong></th>
<th style="text-align: center;"><strong>Voltage(V)</strong></th>
<th style="text-align: center;"><strong>Current TDC(A)</strong></th>
<th style="text-align: center;"><strong>Current<br />
IMAX(A)</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: center;"><strong>5*FAN</strong></td>
<td style="text-align: center;"><strong>P12V_FAN</strong></td>
<td style="text-align: center;"><strong>12</strong></td>
<td style="text-align: center;"><strong>85</strong></td>
<td style="text-align: center;"><strong>105</strong></td>
</tr>
<tr>
<td style="text-align: center;"><strong>FAN PWM</strong></td>
<td style="text-align: center;"><strong>P5V_STBY</strong></td>
<td style="text-align: center;"><strong>5</strong></td>
<td style="text-align: center;"><strong>0.1</strong></td>
<td style="text-align: center;"><strong>0.1</strong></td>
</tr>
<tr>
<td style="text-align: center;"><strong>CPLD</strong></td>
<td style="text-align: center;"><strong>P3V3_STBY</strong></td>
<td style="text-align: center;"><strong>3.3</strong></td>
<td style="text-align: center;"><strong>0.5</strong></td>
<td style="text-align: center;"><strong>0.5</strong></td>
</tr>
</tbody>
</table>

> Fan-0003 Board的供电拓扑如下图所示：

<figure>
<img src="media/image14.emf" />
<figcaption><blockquote>
<p>图 12 Fan Board DC Topo</p>
</blockquote></figcaption>
</figure>

> 主板为Fan-0003 Board提供P12V_FAN和P3V3_STBY，为FAN和CPLD供电.
>
> P12V_FAN经过SGM2208转换成P5V_STBY，用于风扇的PWM转速控制.

2.  <span id="_Toc221265180" class="anchor"></span>**风扇电源部分电路**

![](media/image15.emf)

2.  <span id="_Toc68878250" class="anchor"></span>**单板接口/连接器pin定义**

    1.  <span id="_Toc68878251" class="anchor"></span>**内部接口**

> 内部接口包括Power & Sideband Conn。
>
> Power连接器采用型号为ZX-DY-4LA301，其定义如下：

| Pin    | Net Name   | Function |
|--------|------------|----------|
| P1_1_6 | P12V_INPUT | 　       |
| P2_1_6 | P12V_INPUT | 　       |
| P3_1_6 | P12V_INPUT | 　       |
| P4_1_6 | P12V_INPUT | 　       |
| P5_1_6 | GND        | 　       |
| P6_1_6 | GND        | 　       |
| P7_1_6 | GND        | 　       |
| P8_1_6 | GND        | 　       |

表 5 Power Conn Pin定义 (24 pin)

| Pin | Net Name         | Function |
|----:|------------------|----------|
|   1 | FAN_POWER_PG_R   | 　       |
|   2 | BMC_I2C_SDA_CONN | 　       |
|   3 | FAN_POWER_EN_R   | 　       |
|   4 | BMC_I2C_SCL_CONN | 　       |
|   5 | GND              | 　       |
|   6 | GND              | 　       |
|   7 | JTAG_MB_TCK_R    | 　       |
|   8 | JTAG_MB_TDO_R    | 　       |
|   9 | JTAG_MB_TMS_R    | 　       |
|  10 | JTAG_MB_TDI_R    | 　       |
|  11 | PRSNT_FAN_R      | 　       |
|  12 | P3V3_STBY        | 　       |

表 6 Sideband Conn1 Pin定义 (12 pin)

2.  <span id="_Toc68878252" class="anchor"></span>**外部接口**

> 外部接口有Fan Conn，采用连接器型号为AWAFA348-P021A00CC。
>
> Fan Conn(\*5)的Pin定义如下：

| Pin |  Net Name  |     Function      | Pin |  Net Name  |  Function   |
|:---:|:----------:|:-----------------:|:---:|:----------:|:-----------:|
|  1  | V_12V0_FAN |                   |  5  | V_12V0_FAN |             |
|  2  |    GND     |                   |  6  |    GND     |             |
|  3  | FAN_TACH_A |    FAN1 speed     |  7  | FAN_TACH_B | FAN2 speed  |
|  4  |  PWM_FAN   | FAN speed control |  8  | /FAN_PRSNT | FAN present |

表 8 Fan Conn Pin定义

3.  <span id="_Toc68878253" class="anchor"></span>**调试接口**

> 调试接口的Pin定义如下

<table style="width:90%;">
<caption><blockquote>
<p>表11 CPLD JTAG Conn Pin定义</p>
</blockquote></caption>
<colgroup>
<col style="width: 20%" />
<col style="width: 45%" />
<col style="width: 24%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;">Pin</th>
<th style="text-align: center;">Name</th>
<th style="text-align: center;">Function</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: center;">1</td>
<td style="text-align: center;">JTAG_CPLD_TCK</td>
<td rowspan="10" style="text-align: center;">JTAG</td>
</tr>
<tr>
<td style="text-align: center;">3</td>
<td style="text-align: center;">JTAG_CPLD_TDO</td>
</tr>
<tr>
<td style="text-align: center;">5</td>
<td style="text-align: center;">JTAG_CPLD_TMS</td>
</tr>
<tr>
<td style="text-align: center;">7</td>
<td style="text-align: center;">NA</td>
</tr>
<tr>
<td style="text-align: center;">9</td>
<td style="text-align: center;">JTAG_CPLD_TDI</td>
</tr>
<tr>
<td style="text-align: center;">2</td>
<td style="text-align: center;">GND</td>
</tr>
<tr>
<td style="text-align: center;">4</td>
<td style="text-align: center;">V_STBY_3V3</td>
</tr>
<tr>
<td style="text-align: center;">6</td>
<td style="text-align: center;">NA</td>
</tr>
<tr>
<td style="text-align: center;">8</td>
<td style="text-align: center;">NA</td>
</tr>
<tr>
<td style="text-align: center;">10</td>
<td style="text-align: center;">线缆在线检测</td>
</tr>
</tbody>
</table>

3.  <span id="_Toc68878254" class="anchor"></span>**单板PCB和信号完整性设计**

    1.  <span id="_Toc28037711" class="anchor"></span>**PCB 叠层设计**

> PCB板材选用普通FR4板材，具体为IT-180A
>
> PCB叠层设计详细说明如下，包含板厚，层数，PP和Core类型，铜厚，线宽线距等信息：

<img src="media/image16.png" style="width:5.4357in;height:3.91817in" />

图 15板卡叠层信息

2.  <span id="_Toc68878256" class="anchor"></span>**PCB 走线设计**

PCB各层主要信号线及平面分布如下：

TOP层/ BOTTOM层：单端信号及V_STBY_5V0,P12V_FAN1_IN, P12V_FAN_IN,GND,由于板卡上内层需要走风扇12V大电流，因此将以下重要信号尽量走在表底层，保证完整的参考地。

| 序号 | 信号名              |
|-----:|---------------------|
|    1 | CLK_FAN_CPLD_25M    |
|    2 | CPLD_SMB_LM75_R_SCL |
|    3 | CPLD_SMB_LM75_R_SDA |
|    4 | BMC_I2C_SCL         |
|    5 | BMC_I2C_SDA         |
|    6 | CPLD_I2C_UPDATE_SCL |
|    7 | CPLD_I2C_UPDATE_SDA |
|    8 | RST_CPLD_N          |
|    9 | PG_STBY_5V0_N       |
|   10 | CPLD_PWR_I2C_2_SDA  |
|   11 | CPLD_PWR_I2C_2_SCL  |
|   12 | CPLD_PWR_I2C_1_SDA  |
|   13 | CPLD_PWR_I2C_1_SCL  |

TOP层：

<img src="media/image17.png" style="width:6.89028in;height:1.27431in" />

BOTTOM层：

<img src="media/image18.png" style="width:6.89028in;height:0.99514in" />

L2层：GND

<img src="media/image19.png" style="width:6.89028in;height:0.95486in" />

L3层：风扇控制信号及P12V_FAN，P3V3_STBY

<img src="media/image20.png" style="width:6.89028in;height:0.96875in" />

L4层：P12V_FAN和P12V_FAN1

<img src="media/image21.png" style="width:6.89028in;height:0.93125in" />

L5层：P12V_FAN和P12V_FAN1

<img src="media/image22.png" style="width:6.89028in;height:0.92639in" />

L6层：低速信号和GND

<img src="media/image23.png" style="width:6.89028in;height:0.92847in" />

L7层：GND

<figure>
<img src="media/image24.png" style="width:6.89028in;height:0.99722in" />
<figcaption><blockquote>
<p>图 16板卡各层主要信号线及平面分布</p>
</blockquote></figcaption>
</figure>

3.  <span id="_Toc68878257" class="anchor"></span>**高速信号SI仿真和评估**

> 此板无高速走线，不涉及。

4.  <span id="_Toc221265189" class="anchor"></span>**功能接口丝印**

> 低速信号接口

<img src="media/image25.png" style="width:4.23195in;height:2.18081in" />

> 风扇连接器接口

<img src="media/image26.png" style="width:4.28389in;height:2.56766in" />

> CPLD指示灯接口

<img src="media/image27.png" style="width:4.25147in;height:3.19096in" />

> 静电标识及条码框

<img src="media/image28.png" style="width:4.22277in;height:2.36674in" />

4.  <span id="_Toc193359661" class="anchor"></span>**单板结构相关设计**

    1.  <span id="_Toc193359662" class="anchor"></span>**定位孔、禁布区和尺寸说明**

<figure>
<img src="media/image29.png" style="width:6.6156in;height:4.03457in" />
<figcaption><p>图 30风扇板卡结构</p></figcaption>
</figure>

2.  <span id="_Toc193359663" class="anchor"></span>**特殊结构件**

<figure>
<img src="media/image30.png" style="width:1.52195in;height:3.24143in" />
<figcaption><p>图 31 风扇板弹簧销：免工具固定</p></figcaption>
</figure>
