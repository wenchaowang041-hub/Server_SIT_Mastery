金丝雀_4X3.5 SAS板卡详细设计报**告**

> **拟 制：<u>杨 超 </u>**
>
> **审 核：<u>周加洋 </u>**
>
> **批 准：<u>王钟一 </u>**

# 目录

[1 概述 [4](#_Toc6386)](#_Toc6386)

[**1.1** **保密说明** [4](#_Toc16278)](#_Toc16278)

[**1.2** **版本历史** [4](#_Toc19460)](#_Toc19460)

[**1.3** **术语** [4](#_Toc25564)](#_Toc25564)

[**1.4** **参考文档** [4](#_Toc27229)](#_Toc27229)

[**1.5** **背景** [5](#_Toc7281)](#_Toc7281)

[2 单板总体说明 [5](#_Toc26206)](#_Toc26206)

[**2.1** **单板总体框图** [5](#_Toc5449)](#_Toc5449)

[**2.2** **CPLD选型** [6](#_Toc6878)](#_Toc6878)

[3 单板各模块的详细设计 [6](#_Toc27085)](#_Toc27085)

[**3.1** **CPLD模块** [6](#_Toc23015)](#_Toc23015)

[**3.1.1** **系统时钟处理模块** [6](#_Toc16154)](#_Toc16154)

[**3.1.2** **信号同步化模块** [7](#_Toc19057)](#_Toc19057)

[**3.1.3** **信号滤波模块** [8](#_Toc9548)](#_Toc9548)

[**3.1.4** **CPLD与BMC通信模块** [9](#_Toc21769)](#_Toc21769)

[**3.1.5** **SGPIO通信模块** [9](#_Toc8219)](#_Toc8219)

[**3.1.6** **点灯模块** [10](#_Toc7802)](#_Toc7802)

[**3.1.7** **CPLD更新模块** [11](#_Toc528584800)](#_Toc528584800)

[**3.2** **EEPROM模块** [12](#_Toc18676)](#_Toc18676)

[**3.3** **各模块之间的总线设计** [13](#_Toc21451)](#_Toc21451)

[**3.3.1** **SMBus/I2C拓扑** [13](#_Toc14157)](#_Toc14157)

[**3.3.2** **JTAG链路** [13](#_Toc27746)](#_Toc27746)

[**3.3.3** **热拔插线路** [14](#_Toc11076)](#_Toc11076)

[**3.3.4** **SGPIO模块** [14](#_Toc7534)](#_Toc7534)

[**3.4** **单板电源设计** [15](#_Toc7923)](#_Toc7923)

[**3.5** **单板接口/连接器pin定义** [16](#_Toc9477)](#_Toc9477)

[**3.5.1** **内部接口** [16](#_Toc31453)](#_Toc31453)

[**3.5.2** **外部接口** [18](#_Toc26974)](#_Toc26974)

[**3.5.3** **调试接口** [19](#_Toc5420)](#_Toc5420)

[4 单板PCB和信号完整性设计 [19](#_Toc5510)](#_Toc5510)

[**4.1** **PCB叠层设计** [19](#_Toc517452102)](#_Toc517452102)

[**4.2** **PCB走线设计** [20](#_Toc30882)](#_Toc30882)

[**4.3** **高速信号SI仿真和评估** [21](#_Toc23728)](#_Toc23728)

[5 单板结构相关设计 [21](#_Toc9288)](#_Toc9288)

[**5.1** **定位孔、禁布区和尺寸说明** [21](#_Toc24616)](#_Toc24616)

1.  <span id="_Toc6386" class="anchor"></span>**概述**

    1.  <span id="_Toc16278" class="anchor"></span>**保密说明**

> **本技术文档为软通华方公司的机密文件，未经许可，不得复制和传播。**

2.  <span id="_Toc19460" class="anchor"></span>**版本历史**

| **作者** | **描述** | **版本** | **日期**   |
|:---------|:---------|----------|------------|
| 杨超     | 初版     | V1.0     | 2026/02/06 |
|          |          |          |            |
|          |          |          |            |
|          |          |          |            |
|          |          |          |            |
|          |          |          |            |
|          |          |          |            |
|          |          |          |            |
|          |          |          |            |
|          |          |          |            |

3.  <span id="_Toc25564" class="anchor"></span>**术语**

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

4.  <span id="_Toc27229" class="anchor"></span>**参考文档**

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

5.  <span id="_Toc7281" class="anchor"></span>**背景**

> 4x3.5 SATA/SAS前置背板的作用是用于接SAS/SATA协议的硬盘，通过软连接的方式和基础板或者Raid卡互连。

2.  <span id="_Toc26206" class="anchor"></span>**单板总体说明**

    1.  <span id="_Toc5449" class="anchor"></span>**单板总体框图**

> 4x3.5 SATA/SAS前置背板能够支持4个SAS/SATA硬盘配置，该背板使用安路的EF2L45BG256B型号CPLD，支持BMC I2C解析点灯、SATA硬盘上电下电控制、硬盘状态的上报等功能。
>
> Slimline连接器高速信号连接到4个硬盘，低速信号连接到CPLD。
>
> 低速信号有电源状态，电源使能，I2C信号，JTAG信号和在位信号，I2C信号通过4.7K电阻上拉，连接到EEPROM芯片M24128-BWMN6TP和CPLD，EEPROM的I2C地址为0xAE，CPLD地址为0x60。 JTAG连接器连接升级CPLD时，低速连接器不接线，不连接JTAG连接器时，BMC可以通过低速连接器进行在线更新CPLD。 低速连接器上在位信号拉低，PG信号拉高，使能信号悬空。
>
> 4x3.5 SATA/SAS背板的板卡拓扑如下图所示：
>
> ![](media/image1.emf)
>
> 图 1 4x3.5 SATA/SAS背板板卡拓扑

2.  <span id="_Toc6878" class="anchor"></span>**CPLD选型**

> 背板选用安路的EF2L45BG256B，资源情况如下表所示。

| **器件**     | **LUTs** | **registers** | **IO pin** |
|:-------------|:---------|:--------------|:-----------|
| EF2L45BG256B | 4480     | 4480          | 105        |
| 预估资源     | 66%      | 36%           | 50%        |

表 1 EF2L45BG256B资源

3.  <span id="_Toc27085" class="anchor"></span>**单板各模块的详细设计**

    1.  <span id="_Toc23015" class="anchor"></span>**CPLD模块**

        1.  <span id="_Toc16154" class="anchor"></span>**系统时钟处理模块**

> 系统时钟、复位处理模块输入输出端口框图如下图所示：

![](media/image2.emf)

> 图 2 系统时钟、复位处理模块框图
>
> 系统时钟、复位做为整个系统代码正常运行的基础。首先，由于时钟信号在传输中容易因信号衰减、干扰等原因发生相位偏移或漂移，PLL通过引入反馈机制，使输出时钟与输入时钟在相位上保持一致，从而消除了输入时钟信号的相位抖动和漂移问题，提高了时序稳定性和系统性能。另外将时钟引入PLL,通过分频、倍频，也能得到我们代码所需的其他时钟。PLL使用芯片自带硬核资源，根据实际使用情况选择参数，如下图：

<img src="media/image3.png" style="width:2.39514in;height:1.91806in" /><img src="media/image4.png" style="width:2.42639in;height:1.89583in" />

> 图 3 PLL硬核资源使用情况
>
> LOCK信号作为一个重要标志，表示输出时钟已稳定锁定。将该信号作为解系统复位的标志，即当lock信号拉高时刻开始计数，计数一定时钟周期后，计数器不变，系统解复位，从初始化状态开始运行。实现的时序图如下图所示。

![](media/image5.emf)

> 图 4 时钟实现时序图

2.  <span id="_Toc19057" class="anchor"></span>**信号同步化模块**

> 如果输入信号来自异步时钟域(比如FPGA芯片外部的输入)，一般采用同步器进行同步。最基本的结构是两个紧密相连的触发器，第一拍将输入信号同步化，同步化后的输出可能带来建立/保持时间的冲突，产生亚稳态。需要再寄存一拍，减少(注意是减少)亚稳态带来的影响。这种最基本的结构叫做电平同步器。

<img src="media/image6.png" style="width:5.13472in;height:2.37917in" />

> 图 5 信号同步化模块‌

3.  <span id="_Toc9548" class="anchor"></span>**信号滤波模块**

> 系统输入的某些重要信号，一般会作为状态上传到BMC，或者完成相应逻辑判断，但是受到信号干扰等外界影响，造成误上报或逻辑判断失误等后果，因此一般此类重要信号需进行滤波后使用。在4 SAS应用中，硬盘的在位信号、RAID与CPLD之间的SGPIO信号如果有波动会影响到盘的点灯效果，所以需要做滤波处理。滤波模块输出端口框图框图如下：

![](media/image7.emf)

> 图 6 信号滤波模块框图
>
> 设计思路：使用连续的三个clk_pulse脉冲信号对输入信号signal_in进行采样，三次采用的值相同，则认为输入信号有效，时序图如下图所示：

![](media/image8.emf)

> 图 7 信号滤波时序图

4.  <span id="_Toc21769" class="anchor"></span>**CPLD与BMC通信模块**

> CPLD与BMC之间通过I2C进行数据的交互通信，CPLD I2C的地址为0110_000(x). BMC进行数据读写的数据格式如下所示。
>
> 下图是BMC写数据给CPLD的数据格式。

<figure>
<img src="media/image9.emf" />
<figcaption><p>图8 BMC写数据格式</p></figcaption>
</figure>

> 下图是BMC从CPLD读数据格式。

<figure>
<img src="media/image10.emf" />
<figcaption><p>图9 BMC读数据格式</p></figcaption>
</figure>

> 具体的数据格式如下表所示，详见CPLD接口文档。

![](media/image11.emf)

5.  <span id="_Toc8219" class="anchor"></span>**SGPIO通信模块**

> 4 SAS板需要来自RAID发送的硬盘点灯信号完成点灯操作。因此RAID与4 SAS板选择使用SGPIO通信，SGPIO通信模块如下图所示：

![](media/image12.emf)

> 图 10 SGPIO通信模块框图

6.  <span id="_Toc7802" class="anchor"></span>**点灯模块**

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

![](media/image13.emf)

> 图 11 CPLD心跳灯框图
>
> SAS盘点灯逻辑框图如下图。

![](media/image14.emf)

图12 SAS盘点灯逻辑框图

| **硬盘状态**             | **绿灯** | **蓝灯** | **红灯** |
|:-------------------------|:---------|:---------|:---------|
| 硬盘不在位               | OFF      | x        | x        |
| 硬盘在位，无动作         | ON       | x        | x        |
| 硬盘在位，动作（Active） | 4Hz      | x        | x        |
| 定位状态（Locate)        | x        | 4Hz      | OFF      |
| 硬盘故障（Fault）        | x        | OFF      | ON       |

表 3 硬盘点灯状态

7.  <span id="_Toc528584800" class="anchor"></span>**CPLD更新模块**

> 通过JTAG总线可以用来升级4SAS板CPLD，4SAS板上存在一个JTAG header,用于debug阶段的功能调试和升级以及第一次的程序烧录。远程升级CPLD则需要通过扩展板，扩展板CPLD作为桥梁，路由从BMC过来的JTAG信号。BMC需要刷新后级的哪个单板，首先会通过IIC SMC命令字告诉扩展板CPLD，扩展板CPLD会打开相应的路由通道，然后BMC进行刷新。下图是对应的逻辑框图。

![](media/image15.emf)

图13 CPLD更新框图

2.  <span id="_Toc18676" class="anchor"></span>**EEPROM模块**

> 板卡上放置EEPROM芯片M24128-BWMN6TP，用于存储组件静态管理信息，包括：电子标签、CSR信息、用户自定义信息，具体格式如下表所示。

<table style="width:89%;">
<caption><p>表 4 EEPROM内容格式</p></caption>
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
<td style="text-align: left;">固定填写</td>
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

3.  <span id="_Toc21451" class="anchor"></span>**各模块之间的总线设计**

    1.  <span id="_Toc14157" class="anchor"></span>**SMBus/I2C拓扑**

> 4x3.5 SAS背板上I2C设备有Thermal Sensor、EEPROM以及CPLD。其中Thermal Sensor用于读取板卡温度信息；FRU EEPROM放置背板的存储组件静态管理信息；CPLD有1路I2C和BMC通信。

<figure>
<img src="media/image16.emf" />
<figcaption><p>图 14 4x3.5 SAS 背板 I2C拓扑</p></figcaption>
</figure>

> 如下表为I2C设备的地址表：

<table style="width:78%;">
<caption><p>表 5 4x3.5 SAS背板 I2C设备地址表</p></caption>
<colgroup>
<col style="width: 21%" />
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
<td style="text-align: left;"><p>Thermal SENSOR</p>
<p>(LM75BDP)</p></td>
<td style="text-align: left;">1001 000X</td>
<td style="text-align: left;">温度采集</td>
</tr>
<tr>
<td style="text-align: left;"><p>FRU EEPROM</p>
<p>(M24128-BWMN6TP)</p></td>
<td style="text-align: left;">1010 111X</td>
<td style="text-align: left;">存储组件静态管理信息</td>
</tr>
<tr>
<td style="text-align: left;">CPLD</td>
<td style="text-align: left;">0110 000X</td>
<td style="text-align: left;">CPLD版本等信息</td>
</tr>
</tbody>
</table>

2.  <span id="_Toc27746" class="anchor"></span>**JTAG链路**

> 4x3.5 SAS背板上JTAG链路用来升级背板CPLD，分别连接到低速连接器和JTAG调试接口。

<figure>
<img src="media/image17.emf" />
<figcaption><p>图 15 JTAG拓扑</p></figcaption>
</figure>

3.  <span id="_Toc11076" class="anchor"></span>**热拔插线路**

> 1\. 信号隔离：
>
> 为了实现硬盘的热拔插功能，4x3.5 SAS背板上的设计如下：
>
> 1）EF2L45BG256B 的 F8，D9，F7，E8，C9，A9，A8，C8，J12，H13，G13，F14，G12，F15，E16，F12，D15不支持热插拔，HDDx_RST、HDDx_PRSNT_N、HDDx_REY等信号未使用这些引脚，因此这些信号均不需要隔离。
>
> 2）硬盘本身是支持热拔插的，其内部有热拔插保护线路可以实现硬盘端的热拔插。
>
> 2\. 预充电
>
> 对于连接器的供电PIN，由于在插入硬盘过程中P7和P13这2个供电PIN脚最先接触，因此相应PIN脚串接了一个1206封装的10欧姆电阻用作预充电，可以在插入时起到一定的限流作用，防止单供电PIN电流过大。
>
> 3\. Inrush电流
>
> 1）由CPLD来控制E-fuse导通时间，实现硬盘错峰上电，避免所有硬盘inrush电流叠加现象。
>
> 2）E-fuse管脚DV/DT可控制输出电压soft start的时间，通过降低电压斜率减小inrush电流。
>
> 如下图为Efuse设计的具体线路：

<figure>
<img src="media/image18.png" style="width:5.30556in;height:2.3625in" />
<figcaption><p>图 16 EFUSE保护线路</p></figcaption>
</figure>

4.  <span id="_Toc7534" class="anchor"></span>**SGPIO模块**

> 4x3.5 SAS背板连接RAID发出的一组SGPIO信号，用于SAS硬盘LED指示灯控制。

<figure>
<img src="media/image19.emf" />
<figcaption><p>图 17 SGPIO模块</p></figcaption>
</figure>

4.  <span id="_Toc7923" class="anchor"></span>**单板电源设计**

> 下表为4x3.5 SAS背板的主要器件HDD、CPLD等对Power的要求：

表 6 4x3.5 SAS背板 Power Requirement

<table style="width:99%;">
<colgroup>
<col style="width: 24%" />
<col style="width: 16%" />
<col style="width: 12%" />
<col style="width: 12%" />
<col style="width: 33%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;"></th>
<th colspan="4" style="text-align: center;"><strong>4x3.5 SAS 背板 Power Requirement</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align: center;"></td>
<td style="text-align: center;"><strong>电压(V)</strong></td>
<td style="text-align: center;"><strong>电流(A)</strong></td>
<td style="text-align: center;"><strong>数量</strong></td>
<td style="text-align: center;"><strong>功率</strong></td>
</tr>
<tr>
<td style="text-align: center;"><strong>HDD</strong></td>
<td style="text-align: center;"><strong>12</strong></td>
<td style="text-align: center;"><strong>2</strong></td>
<td style="text-align: center;"><strong>4</strong></td>
<td style="text-align: center;"><strong>96.00 W</strong></td>
</tr>
<tr>
<td style="text-align: center;"><strong>HDD</strong></td>
<td style="text-align: center;"><strong>5</strong></td>
<td style="text-align: center;"><strong>1.5</strong></td>
<td style="text-align: center;"><strong>4</strong></td>
<td style="text-align: center;"><strong>30.00 W</strong></td>
</tr>
<tr>
<td style="text-align: center;"><strong>CPLD</strong></td>
<td style="text-align: center;"><strong>3.3</strong></td>
<td style="text-align: center;"><strong>0.5</strong></td>
<td style="text-align: center;"><strong>1</strong></td>
<td style="text-align: center;"><strong>1.65 W</strong></td>
</tr>
<tr>
<td style="text-align: center;"><strong>Misc<br />
(LED, EEPROM, Sensor, Pull up etc)</strong></td>
<td style="text-align: center;"><strong>3.3</strong></td>
<td style="text-align: center;"><strong>1</strong></td>
<td style="text-align: center;"><strong>1</strong></td>
<td style="text-align: center;"><strong>3.30 W</strong></td>
</tr>
<tr>
<td style="text-align: center;"></td>
<td style="text-align: center;"></td>
<td style="text-align: center;"></td>
<td style="text-align: left;">总功率</td>
<td style="text-align: center;"><strong>130.95 W</strong></td>
</tr>
</tbody>
</table>

4x3.5 SAS背板的供电拓扑如下图所示：

<figure>
<img src="media/image20.emf" />
<figcaption><p>图 18 4x3.5 SAS背板 DC Topo</p></figcaption>
</figure>

- 主板为4x3.5 SAS背板提供P12V和P3V3_STBY，为背板上的HDD、LED和CPLD等供电；

- 每个硬盘端子供电端放置E-fuse保护芯片TPS259260、TPS259250，既可实现硬盘错峰启动功能，同时防止单颗硬盘异常对其他硬盘造成的掉电影响。

  1.  <span id="_Toc9477" class="anchor"></span>**单板接口/连接器pin定义**

      1.  <span id="_Toc31453" class="anchor"></span>**内部接口**

> 内部接口包括低速信号连接器、电源连接器Slimline X4连接器
>
> 低速信号连接器定义如下：

| Pin | Net Name     | Function         |
|:---:|:-------------|:-----------------|
|  1  | HDD_12V_PG   | 背板电源正常信号 |
|  3  | HDD_PWR_EN_N | 背板电源使能     |
|  5  | GND          | 信号地           |
|  7  | CPLD_TCK     | JTAG时钟         |
|  9  | CPLD_TMS     | JTAG模式选择     |
| 11  | HDD_PRSNT_N  | 背板在位         |
| 13  | RSV_0        | 背板预留信号0    |
| 15  | RSV_1        | 背板预留信号1    |
|  2  | BMC_I2C_SDA  | BMC I2C数据      |
|  4  | BMC_I2C_SCL  | BMC I2C时钟      |
|  6  | GND          | 信号地           |
|  8  | CPLD_TDO     | JTAG数据输出     |
| 10  | CPLD_TDI     | JTAG数据输入     |
| 12  | V_STBY_3V3   | 3.3V供电         |
| 14  | V_STBY_3V3   | 3.3V供电         |
| 16  | RSV_2        | 背板预留信号2    |

表 7 Sideband Conn Pin定义

> Slimline X4连接器的Pin定义如下：

| Pin | Net Name         | Function       | Pin | Net Name        | Function       |
|:---:|:-----------------|----------------|:---:|:----------------|----------------|
| A1  | GND              | 信号地         | B1  | GND             | 信号地         |
| A2  | SAS_HOST_TX_DP0  | SAS控制器发送  | B2  | SAS_HOST_RX_DP0 | SAS控制器接收  |
| A3  | SAS_HOST_TX_DN0  | SAS控制器发送  | B3  | SAS_HOST_RX_DN0 | SAS控制器接收  |
| A4  | GND              | 信号地         | B4  | GND             | 信号地         |
| A5  | SAS_HOST_TX_DP1  | SAS控制器发送  | B5  | SAS_HOST_RX_DP1 | SAS控制器接收  |
| A6  | SAS_HOST_TX_DN1  | SAS控制器发送  | B6  | SAS_HOST_RX_DN1 | SAS控制器接收  |
| A7  | GND              | 信号地         | B7  | GND             | 信号地         |
| A8  | SGPIO_CLK        | SGPIO 时钟     | B8  | SAS_BP_TYPEA    | 背板类型位A    |
| A9  | SGPIO_LOAD       | SGPIO 负载检测 | B9  | SGPIO_DOUT      | SGPIO 数据输出 |
| A10 | GND              | 信号地         | B10 | GND             | 信号地         |
| A11 | SAS_CABLE0_PRSNT | 线缆在位检测   | B11 | SAS_BP_TYPEC    | 背板类型位C    |
| A12 | SGPIO_DIN        | SGPIO 数据输入 | B12 | HDD_PWR_EN_N    | 背板供电使能   |
| A13 | GND              | 信号地         | B13 | GND             | 信号地         |
| A14 | SAS_HOST_TX_DP2  | SAS控制器发送  | B14 | SAS_HOST_RX_DP2 | SAS控制器接收  |
| A15 | SAS_HOST_TX_DN2  | SAS控制器发送  | B15 | SAS_HOST_RX_DN2 | SAS控制器接收  |
| A16 | GND              | 信号地         | B16 | GND             | 信号地         |
| A17 | SAS_HOST_TX_DP3  | SAS控制器发送  | B17 | SAS_HOST_RX_DP3 | SAS控制器接收  |
| A18 | SAS_HOST_TX_DN3  | SAS控制器发送  | B18 | SAS_HOST_RX_DN3 | SAS控制器接收  |
| A19 | GND              | 信号地         | B19 | GND             | 信号地         |

表 8 Slimline X4连接器 Pin定义

> 电源连接器的Pin定义如下：

| Pin |   Name   | Function | Pin | Name | Function |
|:---:|:--------:|:--------:|:---:|:----:|:--------:|
|  1  | P12V_PSU | 12V 电源 |  4  | GND  |  信号地  |
|  2  | P12V_PSU | 12V 电源 |  5  | GND  |  信号地  |
|  3  | P12V_PSU | 12V 电源 |  6  | GND  |  信号地  |

表 9 电源连接器 Pin定义

- 电源连接器通流要求(per pin)：6.5A

- 推荐搭配线径：AWG#18

<figure>
<img src="media/image21.png" style="width:3.30903in;height:3.14931in" />
<figcaption><p>图 19 电源连接器通流规格</p></figcaption>
</figure>

1.  <span id="_Toc26974" class="anchor"></span>**外部接口**

> 硬盘连接器pin定义如下：

| Pin | Name              | Function              | Mating Sequence |
|:---:|:------------------|:----------------------|:---------------:|
| S1  | GND               | 信号地                |       2nd       |
| S2  | SAS_HOST_TX_DP2   | SAS控制器输出         |       3rd       |
| S3  | SAS_HOST_TX_DN2   | SAS控制器输出         |       3rd       |
| S4  | GND               | GND                   |       2nd       |
| S5  | SAS_HOST_RX_C_DN2 | SAS控制器输入         |       3rd       |
| S6  | SAS_HOST_RX_C_DP2 | SAS控制器输入         |       3rd       |
| S7  | GND               | 信号地                |       2nd       |
| S8  | GND               | 信号地                |       2nd       |
| S9  | NC                |                       |       3rd       |
| S10 | NC                |                       |       3rd       |
| S11 | GND               | 信号地                |       2nd       |
| S12 | NC                |                       |       3rd       |
| S13 | NC                |                       |       3rd       |
| S14 | GND               | 信号地                |       2nd       |
| P1  | NC                |                       |       3rd       |
| P2  | NC                |                       |       3rd       |
| P3  | HDDx_RST          | 硬盘复位信号          |       2nd       |
| P4  | GND               | 信号地                |       1st       |
| P5  | GND               | 信号地                |       2nd       |
| P6  | GND               | 信号地                |       2nd       |
| P7  | P5V_HDDx          | 通过10欧电阻连接到5V  |       2nd       |
| P8  | P5V_HDDx          | 5V 电源               |       3rd       |
| P9  | P5V_HDDx          | 5V 电源               |       3rd       |
| P10 | HDDx_PRSNT_N      | 硬盘在位信号          |       2nd       |
| P11 | HDDx_REY          | HDDx_REY              |       3rd       |
| P12 | GND               | 信号地                |       1st       |
| P13 | P12V_HDDx         | 通过10欧电阻连接到12V |       2nd       |
| P14 | P12V_HDDx         | 12V电源               |       3rd       |
| P15 | P12V_HDDx         | 12V电源               |       3rd       |

表 10 硬盘连接器 Pin定义

备注:上表中的x代表硬盘连接器序号0，1，2，3；

2.  <span id="_Toc5420" class="anchor"></span>**调试接口**

> 调试接口是指CPLD的JTAG接口，Pin定义如下:

| Pin | Name            | Function     |
|:---:|:----------------|:-------------|
|  1  | JTAG_CONN_TCK_R | JTAG时钟     |
|  2  | GND             | 信号地       |
|  3  | JTAG_CONN_TDO_R | JTAG数据输出 |
|  4  | V_STBY_3V3      | 3.3V电源     |
|  5  | JTAG_CONN_TMS_R | JTAG模式选择 |
|  6  | NC              |              |
|  7  | NC              |              |
|  8  | NC              |              |
|  9  | JTAG_CONN_TDI_R | JTAG数据输入 |
| 10  | GND             | 信号地       |

表 11 CPLD JTAG Conn Pin定义

4.  <span id="_Toc5510" class="anchor"></span>**单板PCB和信号完整性设计**

    1.  <span id="_Toc517452102" class="anchor"></span>**PCB叠层设计**

> PCB板材选型IT-170GRA2+RTF，PCB叠层设计详细说明如下，包含板厚，层数，铜厚等信息：

<figure>
<img src="media/image22.png" style="width:6.21329in;height:5.51181in" alt="1651217544(1)" />
<figcaption><p>图 20 板卡叠层信息</p></figcaption>
</figure>

2.  <span id="_Toc30882" class="anchor"></span>**PCB走线设计**

> 此板卡每层主要信号分布如下：
>
> TOP/BOTTOM层：SATA_TX& SATA_RX及单端信号。

<img src="media/image23.png" style="width:6.87083in;height:0.46458in" />

<img src="media/image24.png" style="width:6.88472in;height:0.4625in" />

> L3层：单端信号

<img src="media/image25.png" style="width:6.88472in;height:0.46597in" />

> L4层: 12V电源
>
> <img src="media/image26.png" style="width:6.88472in;height:0.45903in" />
>
> L5层: 上部分为5V电源，下部分为GND
>
> <img src="media/image27.png" style="width:6.87431in;height:0.45069in" />
>
> L6层: SATA_TX& SATA_RX及单端信号，右侧为3.3V电源
>
> <img src="media/image28.png" style="width:6.88472in;height:0.45903in" />
>
> L2层/L7层：GND

<img src="media/image29.png" style="width:6.87083in;height:0.46458in" />

<figure>
<img src="media/image30.png" style="width:6.88472in;height:0.45556in" />
<figcaption><p>图 21 板卡各层高速线分布</p></figcaption>
</figure>

3.  <span id="_Toc23728" class="anchor"></span>**高速信号SI仿真和评估**

> 此板卡主要高速信号为SAS信号，需评估SAS链路风险，高速链路为整体评估，不提供单板仿真，整体链路仿真在主板统一说明。
>
> 由于此背板较厚，为减小via stub对高速信号的影响，对背板L6-L8层的高速信号过孔进行背钻。

5.  <span id="_Toc9288" class="anchor"></span>**单板结构相关设计**

    1.  <span id="_Toc24616" class="anchor"></span>**定位孔、禁布区和尺寸说明**

<figure>
<img src="media/image31.png" style="width:4.74931in;height:3.44097in" alt="1678781002345" />
<figcaption><p>图 22 4x3.5 SAS背板板卡结构</p></figcaption>
</figure>
