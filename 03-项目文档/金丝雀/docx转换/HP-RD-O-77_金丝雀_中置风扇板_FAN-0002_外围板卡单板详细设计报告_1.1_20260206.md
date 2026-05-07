金丝雀_中置风扇板**\_单板详细设计报告**

> **拟 制： <u>杨超 </u>**
>
> **审 核： <u>周加洋 </u>**
>
> **批 准： <u>王钟一 </u>**

# 目录

[1 概述 [4](#_Toc220494096)](#_Toc220494096)

[1.1 保密说明 [4](#_Toc220494097)](#_Toc220494097)

[1.2 版本历史 [4](#_Toc220494098)](#_Toc220494098)

[1.3 术语 [4](#_Toc220494099)](#_Toc220494099)

[1.4 参考文档 [4](#_Toc220494100)](#_Toc220494100)

[1.5 背景 [5](#_Toc220494101)](#_Toc220494101)

[2 单板总体说明 [5](#_Toc220494102)](#_Toc220494102)

[**2.1** **单板总体框图** [5](#_Toc220494103)](#_Toc220494103)

[**2.2** **CPLD选型** [6](#_Toc220494104)](#_Toc220494104)

[3 单板各模块的详细设计 [6](#_Toc220494105)](#_Toc220494105)

[**3.1** **CPLD模块** [6](#_Toc528257382)](#_Toc528257382)

[**3.1.1** **系统初始化模块** [6](#_Toc220494107)](#_Toc220494107)

[**3.1.2** **信号同步化模块** [6](#_Toc528584796)](#_Toc528584796)

[**3.1.3** **风扇控制** [7](#_Toc220494109)](#_Toc220494109)

[**3.1.4** **CPLD更新** [8](#_Toc528584800)](#_Toc528584800)

[**3.1.5** **点灯模块** [8](#_Toc220494111)](#_Toc220494111)

[**3.1.6** **CPLD与BMC通信模块** [9](#_Toc528584802)](#_Toc528584802)

[**3.2** **EEPROM模块** [10](#_Toc220494113)](#_Toc220494113)

[**3.3** **风扇模块** [11](#_Toc5613896)](#_Toc5613896)

[**3.4** **温度监控模块** [11](#_Toc220494115)](#_Toc220494115)

[**3.5** **各模块之间的总线设计** [11](#_Toc220494116)](#_Toc220494116)

[**3.5.1** **SMBus/I2C拓扑** [11](#_Toc220494117)](#_Toc220494117)

[**3.5.2** **JTAG链路** [12](#_Toc68878248)](#_Toc68878248)

[**3.6** **单板电源设计** [13](#_Toc220494119)](#_Toc220494119)

[**3.7** **单板接口/连接器pin定义** [13](#_Toc68878250)](#_Toc68878250)

[**3.7.1** **内部接口** [13](#_Toc68878251)](#_Toc68878251)

[**3.7.2** **外部接口** [14](#_Toc68878252)](#_Toc68878252)

[**3.7.3** **调试接口** [14](#_Toc220494123)](#_Toc220494123)

[4 单板PCB和信号完整性设计 [15](#_Toc220494124)](#_Toc220494124)

[**4.1** **PCB 叠层设计** [15](#_Toc68878255)](#_Toc68878255)

[**4.2** **PCB 走线设计** [15](#_Toc220494126)](#_Toc220494126)

[**4.3** **高速信号SI仿真和评估** [17](#_Toc68878257)](#_Toc68878257)

[5 单板结构相关设计 [18](#_Toc80364944)](#_Toc80364944)

[**5.1** **定位孔、禁布区和尺寸说明** [18](#_Toc80364945)](#_Toc80364945)

[**5.2** **特殊结构件** [18](#_Toc220494130)](#_Toc220494130)

1.  <span id="_Toc220494096" class="anchor"></span>**概述**

    1.  <span id="_Toc220494097" class="anchor"></span>**保密说明**

> **本技术文档为软通华方公司的机密文件，未经许可，不得复制和传播。**

2.  <span id="_Toc220494098" class="anchor"></span>**版本历史**

<table style="width:90%;">
<colgroup>
<col style="width: 24%" />
<col style="width: 41%" />
<col style="width: 11%" />
<col style="width: 13%" />
</colgroup>
<thead>
<tr>
<th style="text-align: left;"><strong>作者</strong></th>
<th style="text-align: left;"><strong>描述</strong></th>
<th><strong>版本</strong></th>
<th><strong>日期</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: left;">杨超</td>
<td style="text-align: left;">初版发行</td>
<td>V1.0</td>
<td>20251208</td>
</tr>
<tr>
<td style="text-align: left;">杨超</td>
<td style="text-align: left;"><ol type="1">
<li><p>按照模板更新单节5的内容, 删除原DFx部分内容</p></li>
<li><p>S5状态下风扇不转，运行状态下按照散热策略调速</p></li>
</ol></td>
<td>V1.1</td>
<td>20260206</td>
</tr>
<tr>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td></td>
<td></td>
</tr>
<tr>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td></td>
<td></td>
</tr>
<tr>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td></td>
<td></td>
</tr>
<tr>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td></td>
<td></td>
</tr>
<tr>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td></td>
<td></td>
</tr>
<tr>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td></td>
<td></td>
</tr>
<tr>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td></td>
<td></td>
</tr>
<tr>
<td style="text-align: left;"></td>
<td style="text-align: left;"></td>
<td></td>
<td></td>
</tr>
</tbody>
</table>

1.  <span id="_Toc220494099" class="anchor"></span>**术语**

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

2.  <span id="_Toc220494100" class="anchor"></span>**参考文档**

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

3.  <span id="_Toc220494101" class="anchor"></span>**背景**

> 金丝雀服务器是基于新一代高性能AI芯片的算力密集型6U机架式服务器，该服务器面向人工智能训练、深度学习、大规模数据处理、智能推理等前沿领域。该单板是中置风扇板，为后端的CPU及GPU进行散热。

2.  <span id="_Toc220494102" class="anchor"></span>**单板总体说明**

    1.  <span id="_Toc220494103" class="anchor"></span>**单板总体框图**

> 中置风扇板从主板取电，供给板上的风扇，板上eFuse芯片可以实现功耗监控及报警功能。风扇板上能够安装8个8080的风扇，使用安路的EF2L45BG256B型号的CPLD，可以支持8个风扇的转速调控、转速监测及根据服务器上电状态切换风扇调控策略等功能。
>
> 风扇板的板卡拓扑如下图所示：
>
> ![](media/image1.emf)
>
> 图 1 中置风扇板卡拓扑

2.  <span id="_Toc220494104" class="anchor"></span>**CPLD选型**

> 背板选用安路的EF2L45BG256B，资源情况如下表所示。

| **器件**     | **LUTs** | **registers** | **IO pin** |
|--------------|----------|---------------|------------|
| EF2L45BG256B | 4480     | 4480          | 67         |
| 预估资源     | 41.4%    | 35.5%         | 32%        |

表 1 EF2L45BG256B资源

3.  <span id="_Toc220494105" class="anchor"></span>**单板各模块的详细设计**

    1.  <span id="_Toc528257382" class="anchor"></span>**CPLD模块**

        1.  <span id="_Toc220494107" class="anchor"></span>**系统初始化模块**

> 初始化模块主要包括系统时钟和全局复位信号的生成，其中：
>
> ①使用外部晶振产生的25M时钟作为输入，经过内部PLL时钟同步后生成25MHz的时钟信号作为系统时钟；
>
> ②全局复位信号，由外部电路产生的复位经过CPLD延时处理产生。
>
> 下图是初始化模块的逻辑框图。

<figure>
<img src="media/image2.emf" />
<figcaption><p>图 2 初始化模块</p></figcaption>
</figure>

2.  <span id="_Toc528584796" class="anchor"></span>**信号同步化模块**

> 输入信号来自异步时钟域(比如FPGA芯片外部的输入)，一般采用同步器进行同步。最基本的结构是两个紧密相连的触发器，第一拍将输入信号同步化，同步化后的输出可能带来建立/保持时间的冲突，产生亚稳态。需要再寄存一拍，减少(注意是减少)亚稳态带来的影响。下图是同步化模块的示意图。

![](media/image3.emf)

图 3 信号同步化模块

> 该同步化模块可以同时处理十个信号，并且可以根据信号性质设置信号初始值与同步周期。风扇板上主要应用在对风扇在位与电源PG信号的处理

3.  <span id="_Toc220494109" class="anchor"></span>**风扇控制**

> 风扇管理模块主要包含风扇PWM调速及风扇脉冲检测模块构成，风扇管理模块功能框图，如下图所示：
>
> ![](media/image4.emf)

图 4 风扇控制模块

> 首先，在BMC正常工作的前提下，风扇调速的主控为BMC，CPLD发出多大占空比的PWM波对风扇进行调速，是通过与BMC进行IIC通信去解析某些规定地址寄存器的数值得到，然后通过PWM_CTRL模块产生满足风扇和调速要求的对应频率和占空比的PWM波去控制风扇。特殊情况下，比如BMC复位、挂死、未完成初始化等，就需要CPLD全接管调速，至于具体的调速策略，散热工程师会具体给出，例如下图：

<figure>
<img src="media/image5.png" style="width:6.23611in;height:0.28958in" />
<figcaption><p>图5 散热策略</p></figcaption>
</figure>

> 此时根据硬件给出输入到CPLD内部的BMC心跳信号，PWM_CTRL模块会做检测，比如在一定时间内未检测到信号的跳变，即认为BMC挂死，CPLD固定转速80%占空比输出PWM，检测到BMC活跃后，移交调速权力。
>
> CPLD通过tach信号来检测风扇转速，功能框图中风扇有两个转子a和b，因此针对每个风扇，CPLD要给BMC上传两个转子转速信息。CPLD首先需检测tach信号的上升沿，然后在1s时间内对计数有多少个上升沿，即得到每秒转速。

4.  <span id="_Toc528584800" class="anchor"></span>**CPLD更新**

> 扩展板CPLD作为桥梁，路由从BMC过来的JTAG信号。BMC需要刷新后级的哪个单板，首先会通过IIC SMC命令字告诉扩展板CPLD，扩展板CPLD会打开相应的路由通道，然后BMC进行刷新。如下图逻辑框图所示。

<figure>
<img src="media/image6.emf" />
<figcaption><p>图6 CPLD更新框图</p></figcaption>
</figure>

5.  <span id="_Toc220494111" class="anchor"></span>**点灯模块**

> LED指示灯状态信息如下表所示：

<table style="width:81%;">
<caption><p>表 2 LED指示灯状态</p></caption>
<colgroup>
<col style="width: 18%" />
<col style="width: 13%" />
<col style="width: 48%" />
</colgroup>
<thead>
<tr>
<th><strong>LED Name</strong></th>
<th><strong>Color</strong></th>
<th><strong>LED behavior definition</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td rowspan="2">CPLD心跳灯</td>
<td rowspan="2">绿色</td>
<td>绿色1hz闪烁：CPLD工作正常</td>
</tr>
<tr>
<td>熄灭：CPLD未工作</td>
</tr>
</tbody>
</table>

> CPLD心跳指示灯输入输出端口如下图所示，该模块在内部进行计数等处理，产生1Hz占空比50%的方波输出到外部LED进行点灯。

<figure>
<img src="media/image7.emf" />
<figcaption><p>图7 CPLD心跳灯模块</p></figcaption>
</figure>

6.  <span id="_Toc528584802" class="anchor"></span>**CPLD与BMC通信模块**

> CPLD与BMC之间通过I2C进行数据的交互通信，CPLD I2C的地址为0110_000(x). BMC进行数据读写的数据格式如下所示。
>
> 下图是BMC写数据给CPLD的数据格式。

<figure>
<img src="media/image8.emf" />
<figcaption><p>图8 BMC写数据格式</p></figcaption>
</figure>

> 下图是BMC从CPLD读数据格式。

<figure>
<img src="media/image9.emf" />
<figcaption><p>图9 BMC读数据格式</p></figcaption>
</figure>

> 下图是BMC与CPLD的I2C通信模块，BMC会根据不同的command进行数据的读写。
>
> ![](media/image10.emf)

图10 I2C通信模块

> 具体的数据格式如附件所示，CPLD接口文档。
>
> ![](media/image11.emf)

2.  <span id="_Toc220494113" class="anchor"></span>**EEPROM模块**

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
<td>固定填写</td>
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

3.  <span id="_Toc5613896" class="anchor"></span>**风扇模块**

> BMC根据温度信息控制风扇转速，转速信息通过I2C传递风扇转速到主板BMC。为了保证BMC异常时风扇处于可控状态，CPLD监控BMC发出的I2C信号来判断BMC是否正常工作。当BMC正常工作时，该I2C信号会持续操作CPLD的寄存器，当CPLD监测到信号持续异常10s后，CPLD保持80%占空比的PWM输出控制风扇转速。
>
> S5状态下，CPLD控制风扇不转；S0状态下，系统运行时，CPLD按照散热策略控制风扇的转速。
>
> 风扇模块转速调控逻辑框图参考3.1.3节 图4风扇控制逻辑。

4.  <span id="_Toc220494115" class="anchor"></span>**温度监控模块**

> 板卡在机箱中间位置，一般情况下无需采集温度，板上预留设计1片LM75BDP,该芯片支持本体测温点，如有需要可以监测机箱内部的温度，可以将温度通过I2C总线传递到BMC执行散热策略。

5.  <span id="_Toc220494116" class="anchor"></span>**各模块之间的总线设计**

    1.  <span id="_Toc220494117" class="anchor"></span>**SMBus/I2C拓扑**

> Fan Board上I2C链路一共有4路：
>
> 1路来自主板BMC的I2C，主板上的BMC作为MASTER。
>
> 连接中置风扇板的FRU EEPROM和CPLD，FRU EEPROM放置风扇板板的FRU信息；CPLD有两个I2C-SLAVE，分别为在线升级和与BMC通信的I2C CPLD通过该I2C总线与BMC进行通信
>
> 3路CPLD作为MASTER的I2C，控制2个功率检测芯片监测电压电流, 预留1个Temperature Sensor检测温度。
>
> 中置风扇板的总体I2C拓扑如下图所示：

<figure>
<img src="media/image12.emf" />
<figcaption><blockquote>
<p>图 11风扇板I2C拓扑</p>
</blockquote></figcaption>
</figure>

> 如下表为I2C设备的地址表：

|  位号  | I2C器件     | Address   | Function                               |
|:------:|-------------|-----------|----------------------------------------|
| U7,U10 | INA226      | 1000 000X | 监控风扇功耗                           |
|   U4   | TEMP SENSOR | 1001 000X | 测量板卡温度(预留)                     |
|   U2   | FRU EEPROM  | 1010 111X | 存储FRU信息,地址按照华为的要求进行更改 |
|   U1   | CPLD        | 0111 100X | CPLD在线刷新                           |
|   U1   | CPLD        | 0110 000X | CPLD版本等信息                         |

表 4 Fan Board I2C设备地址表

2.  <span id="_Toc68878248" class="anchor"></span>**JTAG链路**

> 板卡上CPLD的JTAG接口可以通过JTAG线缆或者主板进行升级，当插入JTAG烧写器时，MUX开关将JTAG链路切换到插座通路，否则为在线升级通路，JTAG部分的拓扑如下图所示。

<figure>
<img src="media/image13.emf" />
<figcaption><blockquote>
<p>图 12 JTAG拓扑</p>
</blockquote></figcaption>
</figure>

6.  <span id="_Toc220494119" class="anchor"></span>**单板电源设计**

> Fan Board的Power Requirement如下图所示：

<table style="width:95%;">
<caption><p>图 12 Fan Board Power Requirement</p></caption>
<colgroup>
<col style="width: 23%" />
<col style="width: 35%" />
<col style="width: 13%" />
<col style="width: 11%" />
<col style="width: 11%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;"><strong>金丝雀</strong></th>
<th style="text-align: center;"><strong>Net Name</strong></th>
<th style="text-align: center;"><strong>Voltage(V)</strong></th>
<th style="text-align: center;"><strong>Current TDC(A)</strong></th>
<th style="text-align: center;"><strong>Current<br />
IMAX(A)</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: center;"><strong>8*FAN</strong></td>
<td style="text-align: center;"><strong>P12V_FAN</strong></td>
<td style="text-align: center;"><strong>12</strong></td>
<td style="text-align: center;"><strong>136</strong></td>
<td style="text-align: center;"><strong>168</strong></td>
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
<p>图 13 Fan Board DC Topo</p>
</blockquote></figcaption>
</figure>

> 主板为Fan-0002 Board提供P12V_FAN和P3V3_STBY，为FAN和CPLD供电.
>
> P12V_FAN经过SGM2208转换成P5V_STBY，用于风扇的PWM转速控制.

7.  <span id="_Toc68878250" class="anchor"></span>**单板接口/连接器pin定义**

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

表 5 Power Conn Pin定义

表 6 Sideband Connector Pin定义 (12 pin)

| Pin | Net Name       | Function |
|----:|----------------|----------|
|   1 | PG_12V0_FAN_MB | 　       |
|   2 | BMC_FAN_SDA    | 　       |
|   3 | POWER_EN_MB    | 　       |
|   4 | BMC_FAN_SCL    | 　       |
|   5 | GND            | 　       |
|   6 | GND            | 　       |
|   7 | JTAG_MB_TCK_R  | 　       |
|   8 | JTAG_MB_TDO_R  | 　       |
|   9 | JTAG_MB_TMS_R  | 　       |
|  10 | JTAG_MB_TDI_R  | 　       |
|  11 | /FAN_PRSNT     | 　       |
|  12 | V_STBY_3V3     | 　       |

2.  <span id="_Toc68878252" class="anchor"></span>**外部接口**

> 外部接口有Fan Conn，采用连接器型号为AWAFA229-P003A00CC。
>
> Fan Conn(\*8)的Pin定义如下：

| Pin |  Net Name  |     Function      | Pin |  Net Name  |  Function   |
|:---:|:----------:|:-----------------:|:---:|:----------:|:-----------:|
|  1  |  P12V_FAN  |                   |  5  |  P12V_FAN  |             |
|  2  |    GND     |                   |  6  |    GND     |             |
|  3  | FAN_TACH_A |    FAN1 speed     |  7  | FAN_TACH_B | FAN2 speed  |
|  4  |  PWM_FAN   | FAN speed control |  8  | /FAN_PRSNT | FAN present |

表 7 Fan Conn Pin定义

3.  <span id="_Toc220494123" class="anchor"></span>**调试接口**

> 调试接口的Pin定义如下

<table style="width:90%;">
<caption><blockquote>
<p>表8 CPLD JTAG Conn Pin定义</p>
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

4.  <span id="_Toc220494124" class="anchor"></span>**单板PCB和信号完整性设计**

    1.  <span id="_Toc68878255" class="anchor"></span>**PCB 叠层设计**

> PCB板材选用普通FR4
>
> PCB叠层设计详细说明如下，包含板厚，层数，PP和Core类型，铜厚，线宽线距等信息：

<figure>
<img src="media/image15.png" style="width:6.87917in;height:5.10556in" />
<figcaption><blockquote>
<p>图 14板卡叠层信息</p>
</blockquote></figcaption>
</figure>

2.  <span id="_Toc220494126" class="anchor"></span>**PCB 走线设计**

> PCB各层主要信号线及平面分布如下：
>
> TOP/L4/L5层 P12V_FAN1, P12V_FAN, 12V_IN

<img src="media/image16.png" style="width:6.91875in;height:1.63403in" />

<img src="media/image17.png" style="width:6.87153in;height:1.61389in" />

<img src="media/image18.png" style="width:6.875in;height:1.60417in" />

L2/L7层 GND

<img src="media/image19.png" style="width:6.87153in;height:1.61389in" />

<img src="media/image20.png" style="width:6.88125in;height:1.61389in" />

L3 V_STBY_3V3

<img src="media/image21.png" style="width:6.87847in;height:1.61042in" />

L6/BOTTOM层 单端信号及V_STBY_5V0

<img src="media/image22.png" style="width:6.875in;height:1.62431in" />

<figure>
<img src="media/image23.png" style="width:6.87847in;height:1.63472in" />
<figcaption><blockquote>
<p>图 15板卡各层主要信号线及平面分布</p>
</blockquote></figcaption>
</figure>

3.  <span id="_Toc68878257" class="anchor"></span>**高速信号SI仿真和评估**

> 此板无高速走线，不涉及。

5.  <span id="_Toc80364944" class="anchor"></span>**单板结构相关设计**

    1.  <span id="_Toc80364945" class="anchor"></span>**定位孔、禁布区和尺寸说明**

<figure>
<img src="media/image24.png" style="width:5.72441in;height:3.54331in" />
<figcaption><p>图 16 风扇板板卡结构</p></figcaption>
</figure>

2.  <span id="_Toc220494130" class="anchor"></span>**特殊结构件**

> 无
