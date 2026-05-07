金丝雀**\_扩展板单板详细设计报告**

> **拟 制：<u>\_周加洋 \_ </u>**
>
> **审 核：<u>\_\_云硕 \_\_\_</u>**
>
> **批 准：<u>\_\_王钟一 </u>**

# 目录

[概述 [4](#_Toc214441817)](#_Toc214441817)

[**1.1** **保密说明** [4](#_Toc214441818)](#_Toc214441818)

[**1.2** **版本历史** [4](#_Toc214441819)](#_Toc214441819)

[**1.3** **术语** [4](#_Toc214441820)](#_Toc214441820)

[**1.4** **参考文档** [4](#_Toc214441821)](#_Toc214441821)

[**1.5** **背景** [5](#_Toc214441822)](#_Toc214441822)

[2 单板总体说明 [5](#_Toc214441823)](#_Toc214441823)

[**2.1** **单板总体框图** [5](#_Toc214441824)](#_Toc214441824)

[**2.2** **CPLD选型** [6](#_Toc528584792)](#_Toc528584792)

[3 单板各模块的详细设计 [6](#_Toc214441826)](#_Toc214441826)

[**3.1** **时钟模块** [6](#_Toc214441827)](#_Toc214441827)

[**3.1.1** **PCIE时钟** [6](#_Toc214441828)](#_Toc214441828)

[**3.1.2** **50Mhz时钟** [7](#_Toc214441829)](#_Toc214441829)

[**3.2** **USB模块** [7](#_Toc214441830)](#_Toc214441830)

[**3.3 CPLD模块** [8](#_Toc214441831)](#_Toc214441831)

[**3.3.1 系统初始化模块** [8](#_Toc214441832)](#_Toc214441832)

[**3.3.2 信号同步化模块** [8](#_Toc214441833)](#_Toc214441833)

[**3.3.3 按键处理模块（POWER BTN/UID BTN）** [9](#_Toc214441834)](#_Toc214441834)

[**3.3.4 LED指示灯控制模块** [10](#_Toc528584797)](#_Toc528584797)

[**3.3.5电源管理模块** [11](#_Toc528584798)](#_Toc528584798)

[**3.3.6电源告警码产生模块** [12](#_Toc214441837)](#_Toc214441837)

[**3.3.7传感器信息读取模块** [13](#_Toc214441838)](#_Toc214441838)

[**3.3.8设备RESET** [13](#_Toc214441839)](#_Toc214441839)

[**3.3.9 9555驱动模块** [13](#_Toc214441840)](#_Toc214441840)

[**3.3.10 SGPIO通信模块** [14](#_Toc214441841)](#_Toc214441841)

[**3.3.11 CPLD更新** [14](#_Toc528584800)](#_Toc528584800)

[**3.3.12 HISPORT接口通信模块** [15](#_Toc214441843)](#_Toc214441843)

[**3.3.13 CPLD与BMC通信模块** [16](#_Toc214441844)](#_Toc214441844)

[**3.4** **EEPROM模块** [18](#_Toc214441845)](#_Toc214441845)

[**3.5各模块之间的总线设计** [18](#_Toc214441846)](#_Toc214441846)

[**3.5.1 SMBus/I2C拓扑** [18](#_Toc214441847)](#_Toc214441847)

[**3.5.2 JTAG链路** [19](#_Toc214441848)](#_Toc214441848)

[**3.5.3 扩展板CPLD与主板CPLD之间的通信** [20](#_Toc214441849)](#_Toc214441849)

[**3.5.4扩展板CPLD与SWITCH板CPLD之间的通信** [20](#_Toc214441850)](#_Toc214441850)

[**3.6** **单板电源设计** [20](#_Toc214441851)](#_Toc214441851)

[**3.6.1** **电源分配板** [21](#_Toc214441852)](#_Toc214441852)

[**3.6.2** **风扇板部分电路** [22](#_Toc214441853)](#_Toc214441853)

[**3.6.3** **板卡剩余电源部分电路** [23](#_Toc214441854)](#_Toc214441854)

[**3.7** **单板接口/连接器pin定义** [23](#_Toc214441855)](#_Toc214441855)

[**3.7.1** **内部接口** [23](#_Toc214441856)](#_Toc214441856)

[**3.7.2** **调试接口** [28](#_Toc214441857)](#_Toc214441857)

[4 单板PCB和信号完整性设计 [28](#_Toc214026956)](#_Toc214026956)

[**4.1** **PCB叠层设计** [28](#_Toc517452102)](#_Toc517452102)

[**4.2** **PCB走线设计** [31](#_Toc214026958)](#_Toc214026958)

[**4.3** **高速信号SI仿真和评估—信号完整性** [34](#_Toc214026959)](#_Toc214026959)

[5 单板结构相关设计 [37](#_Toc214441862)](#_Toc214441862)

[**5.1** **定位孔、禁布区和尺寸说明** [37](#_Toc214441863)](#_Toc214441863)

[**5.2** **特殊结构件** [37](#_Toc214441864)](#_Toc214441864)

<span id="_Toc214441817" class="anchor"></span>**概述**

1.  <span id="_Toc214441818" class="anchor"></span>**保密说明**

> **本技术文档为软通华方公司的机密文件，未经许可，不得复制和传播。**

2.  <span id="_Toc214441819" class="anchor"></span>**版本历史**

| **作者** | **描述** | **版本** | **日期**   |
|:---------|:---------|----------|------------|
| 周加洋   | 首版     | V0.1     | 2025.11.19 |
|          |          |          |            |
|          |          |          |            |
|          |          |          |            |
|          |          |          |            |
|          |          |          |            |
|          |          |          |            |
|          |          |          |            |
|          |          |          |            |
|          |          |          |            |

3.  <span id="_Toc214441820" class="anchor"></span>**术语**

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

4.  <span id="_Toc214441821" class="anchor"></span>**参考文档**

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

5.  <span id="_Toc214441822" class="anchor"></span>**背景**

> 金丝雀服务器是软通华方公司自研的6U AI服务器，配置灵活，可广泛适用于大规模模型训练、数据库、云端推理等业务负载。该单板是扩展板，作为系统扩展组件，扩展提供到其他组件的管理接口。

1.  <span id="_Toc214441823" class="anchor"></span>**单板总体说明**

    1.  <span id="_Toc214441824" class="anchor"></span>**单板总体框图**

> 扩展板作为与基础板、BMC板和各组件的沟通桥梁，整体框图如下
>
> 扩展板整体框图如下图所示：
>
> <img src="media/image1.png" style="width:6.89028in;height:4.55in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\5090c3e6-f460-4f03-bd7c-ad8c68600d77.png" />
>
> 扩展板框图
>
> **单板运行环境说明：**
>
> 按照软通华方服务器设计标准支持常温运行、贮藏：

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

> 扩展板选用安路的EF3LA0CG484B，资源情况如下表所示。

| **器件**     | **LUTs** | **DFFs** | **IO pin** |
|:-------------|:---------|:---------|:-----------|
| EF3LA0CG484B | 11776    | 11776    | 383        |
| 预估资源     | 66%      | 36%      | 80%        |

表 EF3LA0CG484B资源

2.  <span id="_Toc214441826" class="anchor"></span>**单板各模块的详细设计**

    1.  <span id="_Toc214441827" class="anchor"></span>**时钟模块**

扩展板上的时钟主要有100Mhz的PCIE时钟，50Mhz的时钟给NCSI使用。

有源晶振产生25Mhz时钟给CPLD使用，USB_hub使用无源晶体25Mhz。

1.  <span id="_Toc214441828" class="anchor"></span>**PCIE时钟**

> 100MHZ时钟来自基础板，扩展板上经过时钟buffer 产生5路100Mhz时钟。

![](media/image2.emf)

2.  <span id="_Toc214441829" class="anchor"></span>**50Mhz时钟**

> 有源晶振产生50Mhz时钟，使用PI6C49X0210时钟buffer芯片产生5路50Mhz时钟。

![](media/image3.emf)

2.  <span id="_Toc214441830" class="anchor"></span>**USB模块**

1路USB 2.0信号和1路USB 3.0信号均来自基础板，通过USB_HUB芯片VL817Q7各产生4路USB2.0和USB3.0信号如下

![](media/image4.emf)

<span id="_Toc214441831" class="anchor"></span>**3.3 CPLD模块**

<span id="_Toc214441832" class="anchor"></span>**3.3.1 系统初始化模块**

初始化模块主要包括系统时钟和全局复位信号的生成，其中：

①使用外部晶振产生的25M时钟作为输入，经过内部PLL时钟同步后生成25MHz的时钟信号作为系统时钟；

②全局复位信号，由外部RC上电延时电路产生的复位经过CPLD延时处理产生。

下图是初始化模块的逻辑框图。

<figure>
<img src="media/image5.emf" />
<figcaption><p>初始化模块</p></figcaption>
</figure>

<span id="_Toc214441833" class="anchor"></span>**3.3.2 信号同步化模块**

输入信号来自异步时钟域(比如FPGA芯片外部的输入)，一般采用同步器进行同步。最基本的结构是两个紧密相连的触发器，第一拍将输入信号同步化，同步化后的输出可能带来建立/保持时间的冲突，产生亚稳态。需要再寄存一拍，减少(注意是减少)亚稳态带来的影响。下图是同步化模块的示意图。

![](media/image6.emf)

信号同步化模块

该同步化模块可以同时处理十个信号，并且可以根据信号性质设置信号初始值与同步周期。

<span id="_Toc214441834" class="anchor"></span>**3.3.3 按键处理模块（POWER BTN/UID BTN）**

1.UID BTN

UID按键处理模块功能框图如下图所示：![](media/image7.emf)

UID按键处理模块

UID按键处理模块，主要是对外部输入的BTN信号进行检测，判断是长按事件还是短按事件，并且将短按事件上报给BMC（pulse_short_btn），BMC也可清楚该短按事件。另外通过长按UID BTN 5s钟以上，产生一个50ms低脉冲，对服务器的iBMC管理系统进行复位。UID灯的控制，根据IIC解析出的相应地址的寄存器内容，来驱动LED的常亮、熄灭或闪烁。

2.POWER BTN

POWER按键处理模块功能框图如下图所示：

![](media/image8.emf)

POWER按键处理模块

POWER按键处理模块，主要是对来自右挂耳输入的BTN信号进行检测，判断是长按事件还是短按事件，与来自BMC的pwrbtn短按事件与长按事件共同组成POWER BTN长按事件与短按事件，输出给电源管理模块进行系统上下电。且将发生的按键事件上报给BMC，BMC也可清除该按键事件。

<span id="_Toc528584797" class="anchor"></span>**3.3.4 LED指示灯控制模块**

扩展板CPLD控制的LED众多，在不同状态下LED的表现形态如下表所示。

<table style="width:78%;">
<caption><p> LED指示灯状态信息</p></caption>
<colgroup>
<col style="width: 17%" />
<col style="width: 11%" />
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
<td style="text-align: left;">1hz闪烁：基础板整体电源OK</td>
</tr>
<tr>
<td style="text-align: left;">4hz闪烁：基础板整体电源未就绪</td>
</tr>
<tr>
<td style="text-align: left;">Debug灯</td>
<td style="text-align: left;">绿色</td>
<td style="text-align: left;">1hz闪烁</td>
</tr>
<tr>
<td rowspan="5" style="text-align: left;"><p>扩展板状态指示灯</p>
<p>{vcc_led，stby_led}</p></td>
<td rowspan="5" style="text-align: left;"><p>绿色，</p>
<p>绿色</p></td>
<td style="text-align: left;">{灭，1hz闪烁}：电源处于STBY状态</td>
</tr>
<tr>
<td style="text-align: left;">{常亮，灭}：BMC正在加载CPLD固件</td>
</tr>
<tr>
<td style="text-align: left;">{常亮，常亮}：服务器处于业务电源/BBU work状态</td>
</tr>
<tr>
<td style="text-align: left;">{4hz闪烁，4hz闪烁}：上电超时或异常掉电</td>
</tr>
<tr>
<td style="text-align: left;">{1hz闪烁，常亮}：其他</td>
</tr>
<tr>
<td rowspan="3" style="text-align: left;">右挂耳UID定位灯</td>
<td rowspan="3" style="text-align: left;">蓝色</td>
<td style="text-align: left;">常亮：定位</td>
</tr>
<tr>
<td style="text-align: left;">灭：未定位</td>
</tr>
<tr>
<td style="text-align: left;">1hz闪烁：装备测试</td>
</tr>
</tbody>
</table>

1.CPLD心跳灯

CPLD心跳灯因基础板整体电源是否OK状态不同，逻辑会判断来自基础板的mb_pwrok做出不同驱动。

2.Debug灯

预留的调试LED灯，CPLD上电后，一直1hz闪烁。

3.扩展板状态指示灯

扩展板状态由vcc_led与stby_led共同指示，主要由电源管理模块输出的上电状态机与CPLD更新标志等控制驱动。

4.右挂耳UID定位灯

UID灯的控制，根据与BMC之间IIC解析出的相应地址的寄存器内容，来驱动LED的常亮、熄灭。

<span id="_Toc528584798" class="anchor"></span>**3.3.5电源管理模块**

扩展板作为基础板与其他背板的桥梁，信号众多，上电复杂，这些动作均由CPLD以状态机的形式完成,如下图为扩展板上下电状态机转换图：

![](media/image9.emf)扩展板上下电状态机转换图

针对扩展板电源时序控制如下图所示。

![](media/image10.emf)

> 扩展板电源时序

<span id="_Toc214441837" class="anchor"></span>**3.3.6电源告警码产生模块**

当服务器系统出现业务电上电超时或业务电异常掉电等情况时，一般排查会比较麻烦。电源告警码产生模块，根据外部输入的各种电PG、电源管理模块输出的各种电EN与电源FAIL标志位，进行逻辑判断，生成告警码，并上报给BMC。BMC即可查询到问题电，从而进一步定位。电源告警码产生逻辑框图如下图所示。

![](media/image11.emf)

> 电源告警码产生模块

<span id="_Toc214441838" class="anchor"></span>**3.3.7传感器信息读取模块**

传感器信息读取模块，主要是作为IIC主控器，遵循IIC时序，读ADS7828寄存器，获取ADC监测值，然后上报BMC。传感器信息读取逻辑框图如下图所示。

![](media/image12.emf)

传感器信息读取模块

<span id="_Toc214441839" class="anchor"></span>**3.3.8设备RESET**

设备复位包含PCIE复位、USBHUB复位、9545复位及OCP卡的SMBUS总线复位。其中9545与OCP卡的SMBUS总线复位都是CPLD上电后即拉高。PCIE复位，CPLD接收到来自基础板的PCIE RESET后，再分别控制OCP、M.2的PCIE RESET信号。USBHUB复位来自于逻辑 内部电源管理模块输出的V_VCC_5V0电源的PG信号，该电源给USBHUB和USB端口供电，电源管理模块输出该使能后，经过延时去抖控制USBHUB复位。下图是各个设备RESET的逻辑框图。

<figure>
<img src="media/image13.emf" />
<figcaption><p>设备RESET控制逻辑</p></figcaption>
</figure>

<span id="_Toc214441840" class="anchor"></span>**3.3.9 9555驱动模块**

右挂耳板上的NIC在位灯、健康灯、PWR灯及PORT80灯都挂在9555下，而9555由扩展板CPLD通过IIC驱动。9555驱动模块作为 I2C主控制器，用于驱动 9555 芯片。模块完成对9555芯片的读写操作，包含完整的 I2C 时序控制，使用状态机实现整个通信过程。下图是9555驱动控制逻辑框图。

<figure>
<img src="media/image14.emf" />
<figcaption><p>9555驱动控制模块</p></figcaption>
</figure>

<span id="_Toc214441841" class="anchor"></span>**3.3.10 SGPIO通信模块**

扩展板上存在一路与SWITCH板通信的SGPIO总线。下图是SGPIO通信逻辑框图。

<figure>
<img src="media/image15.emf" />
<figcaption><p>SGPIO通信模块</p></figcaption>
</figure>

主板发送给switch板的数据格式如下表：

| 比特位 | 信号名  | 含义                   |
|--------|---------|------------------------|
| 0      | pwr_but | 基础板上电、初始化完成 |

<span id="_Toc528584800" class="anchor"></span>**3.3.11 CPLD更新**

扩展板CPLD作为桥梁，路由从BMC过来的JTAG信号。BMC需要刷新后级的哪个单板，首先会通过IIC SMC命令字告诉扩展板CPLD，扩展板CPLD会打开相应的路由通道，然后BMC进行刷新。扩展板CPLD FW由BMC直接通过JTAG总线更新，扩展板上还存在一个JTAG header,用于debug阶段的功能调试和升级，下图是对应的逻辑框图。

<figure>
<img src="media/image16.emf" />
<figcaption><p>CPLD更新框图</p></figcaption>
</figure>

<span id="_Toc214441843" class="anchor"></span>**3.3.12 HISPORT接口通信模块**

HISPORT是一种高速异步串行通信接口，以“帧”的方式传送数据，物理接口分为发送和接收两根线。发送侧采用本地时钟发送，接收侧通过4倍速率采样帧头。基础板与扩展板之间的通信主要由HISPORT接口实现。如下图所示。

<figure>
<img src="media/image17.emf" />
<figcaption><p>Hisport接口通信模块</p></figcaption>
</figure>

<span id="_Toc214441844" class="anchor"></span>**3.3.13 CPLD与BMC通信模块**

CPLD与BMC之间通过I2C进行数据的交互通信，CPLD I2C的地址为0010_001(x). BMC进行数据读写的数据格式如下所示。

下图是BMC写数据给CPLD的数据格式。

<figure>
<img src="media/image18.emf" />
<figcaption><p>图14 BMC写数据格式</p></figcaption>
</figure>

下图是BMC从CPLD读数据格式。

<figure>
<img src="media/image19.emf" />
<figcaption><p>BMC读数据格式</p></figcaption>
</figure>

下图是BMC与CPLD的I2C通信模块，BMC会根据不同的command进行数据的读写。

. ![](media/image20.emf)

I2C通信模块

具体的数据格式如下表所示，CPLD接口文档。

> ![](media/image21.emf)

4.  <span id="_Toc214441845" class="anchor"></span>**EEPROM模块**

> 扩展板上的FRU选用I2C接口的M24128。
>
> 板卡上放置EEPROM，用于存储固定资产信息，具体格式如下表所示。

<table style="width:89%;">
<caption><p> EEPROM内容格式</p></caption>
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
<td style="text-align: left;">固定填写“Tencent”</td>
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

<span id="_Toc214441846" class="anchor"></span>**3.5各模块之间的总线设计**

<span id="_Toc214441847" class="anchor"></span>**3.5.1 SMBus/I2C拓扑**

<figure>
<img src="media/image22.emf" />
<figcaption><p>扩展板 I2C拓扑</p></figcaption>
</figure>

> 如下为I2C从机设备的地址：

![](media/image23.emf)

<span id="_Toc214441848" class="anchor"></span>**3.5.2 JTAG链路**

扩展板上有CPLD的JTAG调试接口，其中扩展板上CPLD的在线升级是通过BMC端实现的。

<figure>
<img src="media/image24.emf" />
<figcaption><p>JTAG拓扑</p></figcaption>
</figure>

<span id="_Toc214441849" class="anchor"></span>**3.5.3 扩展板CPLD与主板CPLD之间的通信**

> ![](media/image25.emf)

<span id="_Toc214441850" class="anchor"></span>**3.5.4扩展板CPLD与SWITCH板CPLD之间的通信**

![](media/image26.emf)

6.  <span id="_Toc214441851" class="anchor"></span>**单板电源设计**

> 板卡电源主要分为以下3个部分：

- 电源分配板功能电路。

> 主板左右各有2组连接器，可以连接2个互为备份的电源分配板，每个电源分配板最大可以插3个3200W CPRS电源，通过连接器的方式将12V电源引到主板上。

- 风扇板部分电路。

> 分为中置、前置两个风扇板，每个风扇板均通过连接器从扩展板取电，后在风扇板上经过带有热插拔功能的EFUSE保护后供给风扇用电。

- 板卡剩余电源部分电路。

> 主要是各个GPU以及硬盘背板的12V热插拔电路及板卡电源检测电路等。
>
> 主板的Power budget如下图所示：

![](media/image27.emf)

主板power budget

1.  <span id="_Toc214441852" class="anchor"></span>**电源分配板**

电源分配板，支持3\*3200W PSU，用于电源和扩展板中转，支持进风温度监测。

<img src="media/image28.png" style="width:3.25in;height:2.31528in" />

> 金丝雀扩展板采用10172549-6003001LF连接器和电源分配板进行连接，每个电源分配板对应2个连接器。
>
> 连接上除主12V和GND信号外，有以下信号用于电源管理：

| 信号名称 | 信号说明 | 数量（2个电源转接板总数量） |
|----|----|----|
| IRQ_PSU_ALERT_N | 电源模块告警信号 | 6 |
| FM_PSU_PRSNT_J_N | 电源模块在位信号 | 6 |
| PSU_PSON_N | 电源模块开机信号，默认上电就开机，不使用电源模块的12VStandby电源 | 6 |
| PWRGD_PS_PWROK_J | 电源模块POWER-OK信号 | 6 |
| PWRGD_PSU_AC_OK_J | 电源模块交流输入正常信号 | 6 |
| 电源模块PMBUS信号 | 主板BMC读取电源模块信息，地址0x58，0x59，0x5A | 2 |
| 电源分配板BMC-I2C信号 | 主板BMC读取电源分配板的FRU信息（M24128，地址0xAE）以及温度信息（EMC1413-A-AIZL-TR，地址0x98） | 2 |

2.  <span id="_Toc214441853" class="anchor"></span>**风扇板部分电路**

> 金丝雀项目共有两个风扇板：中置风扇板支持8个8080风扇，前置风扇板支持5个8080风扇。两个风扇板通过电源连接器与线缆的搭配从扩展板上取电，两个风扇板的Power budget如下图所示：
>
> ![](media/image29.emf)

3.  <span id="_Toc214441854" class="anchor"></span>**板卡剩余电源部分电路**

> PSU采用功率3200W电源，直接输出P12V_INPUT，实现3+3冗余设计。
>
> P12V_INPUT经电源连接器与线缆的搭配组合供给主板12V电压，用于支持主板CPU及DDR的用电需求。
>
> P12V_INPUT经MPQ5991输出P12V_HDD，供给硬盘背板12V电压，同时实现监控硬盘功耗和过流保护功能。
>
> P12V_INPUT经4路MPQ5991\*2输出P12V_SW1/2/3/4，给Switch板供电。
>
> P12V_INPUT经10路MPQ5991\*2输出P12V_GPU0-9，给GPU卡供电，单个GPU功率575W，通过P12V_GPU0-7供电525W。
>
> P12V_INPUT经MPQ5991输出P12V_NCSI，供给网卡12V电压。
>
> P12V_STBY经MPQ8633B输出P3V3_STBY，供给SW、PCIE插槽OCP及主板。
>
> P12V_STBY经MPQ8633B输出P5V_STBY，直供BMC，同时通过3路load switch供给USB。

6.  <span id="_Toc214441855" class="anchor"></span>**单板接口/连接器pin定义**

    1.  <span id="_Toc214441856" class="anchor"></span>**内部接口**

> 内部接口包括UBC连接器接口、OCP供电接口、OCP相关的低速接口、与前置硬盘背板连接的低速接口和供电接口、与switch板连接的低速接口和供电接口、与风扇板连接的低速接口和供电接口、与BMC板连接的接口
>
> UBC接口定义如下：

<figure>
<img src="media/image30.png" style="width:5.77083in;height:3.41458in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\f8ddcb3a-7011-417b-b2f1-d15df153ed9a.png" />
<figcaption></figcaption>
</figure>

<figure>
<img src="media/image31.png" style="width:6.89028in;height:3.24514in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\e948c048-eb97-46c8-b981-afef7043d42a.png" />
</figure>

> BMC接口定义如下：

<figure>
<img src="media/image32.png" style="width:6.89028in;height:6.80347in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\dffb6336-a498-4a22-a96d-2d93d86b9a83.png" />
</figure>

M2接口定义

<figure>
<img src="media/image33.png" style="width:6.89028in;height:4.27292in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\7fb9d21a-c7fb-4a27-ad6e-fe8ae778e1d2.png" />
</figure>

OCPX8连接器定义

<img src="media/image34.png" style="width:6.89028in;height:4.05694in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\aa7ab985-5501-41fb-8986-77ebedd4f579.png" />

OCPX16连接器定义

<figure>
<img src="media/image35.png" style="width:6.89028in;height:6.25625in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\0566a489-c705-409b-a9d3-0bb5acf932da.png" />
</figure>

风扇板的接口定义

<img src="media/image36.png" style="width:6.89028in;height:1.66528in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\183aedbb-51af-461e-9b04-fbe4aecf1292.png" />

Switch板的接口定义

<img src="media/image37.png" style="width:6.89028in;height:1.85417in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\f44529ea-51f3-4599-8c94-66deafa22f91.png" />

前置硬盘背板接口定义

<img src="media/image38.png" style="width:6.89028in;height:1.77778in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\0395467a-e6c0-461c-9f14-d65156209c7b.png" />

2.  <span id="_Toc214441857" class="anchor"></span>**调试接口**

> 调试接口是指CPLD的JTAG接口，Pin定义如下:

<img src="media/image39.png" style="width:6.89028in;height:1.86875in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\02345cb5-ce62-4b0c-9d47-2a77bbd21fa7.png" />

3.  <span id="_Toc214026956" class="anchor"></span>**单板PCB和信号完整性设计**

    1.  <span id="_Toc517452102" class="anchor"></span>**PCB叠层设计**

PCB板材选型Low-Loss（PCIe5.0）, 推荐型号甬强公司S30G-A；

基本特性如下：

<img src="media/image40.png" style="width:6.88333in;height:8.2375in" /><img src="media/image41.png" style="width:6.88056in;height:6.30347in" />

PCB材料特性

PCB叠层设计详细说明如下，包含板厚，层数，铜厚等信息：

<figure>
<img src="media/image42.png" style="width:6.81319in;height:4.23889in" />
<figcaption><p>板卡叠层信息</p></figcaption>
</figure>

2.  <span id="_Toc214026958" class="anchor"></span>**PCB走线设计**

每个信号层主要高速信号分布如下：

TOP / BOTTOM层：CLK&IIC及单端信号

<img src="media/image43.png" style="width:6.67222in;height:3.28681in" /><img src="media/image44.png" style="width:6.67222in;height:3.28681in" />

L3层：USB3.0/USB2.0以及单端信号

<img src="media/image45.png" style="width:6.67222in;height:3.28681in" />

L12层：PCIE_TX/PCIE_RX、USB3.0/USB2.0以及单端信号

<figure>
<img src="media/image46.png" style="width:6.67222in;height:3.28681in" />
<figcaption><p>板卡各层高速线分布</p></figcaption>
</figure>

3.  <span id="_Toc214026959" class="anchor"></span>**高速信号SI仿真和评估—信号完整性**

> 此板卡主要高速信号为PCIE信号/USB3.0信号，需评估PCIE Gen3及USB3.0链路风险。由于此背板较厚，结合华为鲲鹏PDG参考拓扑中via stub要求，为减小via stub对高速信号的影响，对背板L12_L14层的高速信号过孔进行背钻：

<img src="media/image47.png" style="width:6.8875in;height:1.45in" />

<figure>
<img src="media/image48.png" style="width:6in;height:3.58333in" />
<figcaption><p>PCIe链路拓扑</p></figcaption>
</figure>

链路评估如下：

<figure>
<img src="media/image49.png" style="width:6.8875in;height:3.94236in" />
<figcaption><p>USB3.0链路评估</p></figcaption>
</figure>

<figure>
<img src="media/image50.png" style="width:6.88819in;height:3.90347in" />
<figcaption><p>PCIe3.0链路评估</p></figcaption>
</figure>

<img src="media/image51.png" style="width:6.88264in;height:4.11875in" />

PCIe4.0链路评估

<img src="media/image52.png" style="width:6.88611in;height:3.85417in" />

PCIe5.0链路评估

基于上述仿真结果分析，当前设计PCIE Gen5/Gen4链路为高风险，PCIE Gen3链路、USB3.0链路为低风险，需持续跟进华为鲲鹏仿真模型及PDG更新，进一步评估链路风险。

4.  <span id="_Toc214441862" class="anchor"></span>**单板结构相关设计**

    1.  <span id="_Toc214441863" class="anchor"></span>**定位孔、禁布区和尺寸说明**

<figure>
<img src="media/image53.png" style="width:6.89028in;height:4.34722in" />
<figcaption><p>主板板卡结构</p></figcaption>
</figure>

2.  <span id="_Toc214441864" class="anchor"></span>**特殊结构件**

<figure>
<img src="media/image54.png" style="width:3.84056in;height:3.37202in" />
<figcaption><p>主板手转螺丝：免工具固定</p></figcaption>
</figure>
