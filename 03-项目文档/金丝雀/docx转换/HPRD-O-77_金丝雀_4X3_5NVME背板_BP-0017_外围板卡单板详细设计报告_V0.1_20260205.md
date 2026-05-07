金丝雀**\_4X3_5NVME背板_单板详细设计报告**

> **拟 制：<u>\_周加洋 \_ </u>**
>
> **审 核：<u>\_\_云硕 \_\_\_</u>**
>
> **批 准：<u>\_\_王钟一 </u>**

# 目录

[1.概述 [3](#_Toc221259258)](#_Toc221259258)

[**1.1** **保密说明** [3](#_Toc221259259)](#_Toc221259259)

[**1.2** **版本历史** [3](#_Toc221259260)](#_Toc221259260)

[**1.3** **术语** [3](#_Toc221259261)](#_Toc221259261)

[**1.4** **参考文档** [3](#_Toc221259262)](#_Toc221259262)

[**1.5** **背景** [4](#_Toc221259263)](#_Toc221259263)

[2 单板总体说明 [4](#_Toc221259264)](#_Toc221259264)

[**2.1** **单板总体框图** [4](#_Toc221259265)](#_Toc221259265)

[**2.2** **CPLD选型** [5](#_Toc528584792)](#_Toc528584792)

[3 单板各模块的详细设计 [5](#_Toc221259267)](#_Toc221259267)

[**3.1** **时钟模块** [5](#_Toc528257395)](#_Toc528257395)

[**3.2** **CPLD部分** [5](#_Toc221259269)](#_Toc221259269)

[**3.2.1** **初始化模块** [5](#_Toc221259270)](#_Toc221259270)

[**3.2.2** **信号滤波模块** [6](#_Toc528584799)](#_Toc528584799)

[**3.2.3** **点灯模块** [6](#_Toc221259272)](#_Toc221259272)

[**3.2.4** **CPLD更新模块** [7](#_Toc528584800)](#_Toc528584800)

[**3.2.5** **CPLD与BMC通信模块** [8](#_Toc217468051)](#_Toc217468051)

[**3.2.6** **拓扑检测码流上报模块** [9](#_Toc221259275)](#_Toc221259275)

[**3.3** **EEPROM模块** [10](#_Toc221259276)](#_Toc221259276)

[**3.4各模块之间的总线设计** [11](#_Toc221259277)](#_Toc221259277)

[**3.4.1 SMBus/I2C拓扑** [11](#_Toc221259278)](#_Toc221259278)

[**3.4.2 JTAG链路** [12](#_Toc221259279)](#_Toc221259279)

[**3.5 单板电源设计** [12](#_Toc221259280)](#_Toc221259280)

[**3.6** **单板接口/连接器pin定义** [13](#_Toc221259281)](#_Toc221259281)

[**3.6.1** **内部接口** [13](#_Toc221259282)](#_Toc221259282)

[**3.6.2** **调试接口** [14](#_Toc221259283)](#_Toc221259283)

[4 单板PCB设计 [14](#_Toc214026956)](#_Toc214026956)

[**4.1 PCB叠层设计** [14](#_Toc517452102)](#_Toc517452102)

[**4.2 PCB走线设计** [15](#_Toc221259286)](#_Toc221259286)

[**4.3 高速部分** [16](#_Toc221259287)](#_Toc221259287)

<span id="_Toc221259258" class="anchor"></span>**1.概述**

1.  <span id="_Toc221259259" class="anchor"></span>**保密说明**

> **本技术文档为软通华方公司的机密文件，未经许可，不得复制和传播。**

2.  <span id="_Toc221259260" class="anchor"></span>**版本历史**

| **作者** | **描述** | **版本** | **日期** |
|:---------|:---------|----------|----------|
| 周加洋   | 首版     | V0.1     | 2026.2.5 |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |
|          |          |          |          |

3.  <span id="_Toc221259261" class="anchor"></span>**术语**

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

4.  <span id="_Toc221259262" class="anchor"></span>**参考文档**

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

5.  <span id="_Toc221259263" class="anchor"></span>**背景**

NVME背板作为前置背板，最多可以插接4块3.5寸的NVME硬盘，且盘的速率可以支持到PCIE 5.0。

1.  <span id="_Toc221259264" class="anchor"></span>**单板总体说明**

    1.  <span id="_Toc221259265" class="anchor"></span>**单板总体框图**

> 通过UBC连接器引入高速PCIE X8信号，每个UBC连接器支持两块X4的NVME硬盘。
>
> ![](media/image1.emf)
>
> NVME背板的框图
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

> NVME背板选用安路的EF2L45BG256，资源情况如下表所示。

| **器件**    | **LUTs** | **DFFs** | **IO pin** |
|:------------|:---------|:---------|:-----------|
| EF2L45BG256 | 4480     | 4480     | 207        |
| 预估资源    | 73%      | 36%      | 47%        |

表 EF2L45BG256资源

2.  <span id="_Toc221259267" class="anchor"></span>**单板各模块的详细设计**

    1.  <span id="_Toc528257395" class="anchor"></span>**时钟模块**

> NVME背板上用到的100M PCIE差分时钟,是通过UBC连接器引入的，两个UBC连接器各引入1对100M差分时钟，NVME背板上并没有时钟芯片，详见NVME背板框图。
>
> CPLD的时钟是由有源晶振25MHZ产生的。

2.  <span id="_Toc221259269" class="anchor"></span>**CPLD部分**

    1.  <span id="_Toc221259270" class="anchor"></span>**初始化模块**

> 初始化模块主要包括系统时钟和全局复位信号的生成，其中：
>
> ①使用外部晶振产生的25M时钟作为输入，经过内部PLL时钟同步后生成25MHz的时钟信号作为系统时钟；
>
> ②全局复位信号，由外部RC上电延时电路产生的复位经过CPLD延时处理产生。
>
> 下图是初始化模块的逻辑框图。

<figure>
<img src="media/image2.emf" />
<figcaption><p>初始化模块</p></figcaption>
</figure>

2.  <span id="_Toc528584799" class="anchor"></span>**信号滤波模块**

> 系统输入的某些重要信号，一般会作为状态上传到BMC，或者完成相应逻辑判断，但是受到信号干扰等外界影响，造成误上报或逻辑判断失误等后果，因此一般此类重要信号需进行滤波后使用。在硬盘背板应用中，CPLD会上传硬盘在位等信息，因此要做滤波处理。滤波模块输出端口框图框图如下：

<figure>
<img src="media/image3.emf" />
<figcaption><p>信号滤波模块</p></figcaption>
</figure>

> 设计思路：使用连续的三个clk_pulse脉冲信号对输入信号signal_in进行采样，三次采用的值相同，则认为输入信号有效，时序图如下图所示。

![](media/image4.emf)

3.  <span id="_Toc221259272" class="anchor"></span>**点灯模块**

> ⑴ CPLD心跳灯：

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

> ⑵ 硬盘点灯：NVME硬盘点灯逻辑框图如下图。active灯由硬盘pin脚输出的active信号驱动。locate点灯，由bmc写smc命令字驱动点灯。而fault灯比较复杂，CPLD作为IIC Slave，解析CPU 热插拔IIC写的数据来点灯。

![](media/image5.emf)

图 NVME硬盘点灯逻辑框图

| **硬盘状态**             | **绿灯** | **蓝灯** | **红灯** |
|:-------------------------|:---------|:---------|:---------|
| 硬盘不在位               | OFF      | x        | x        |
| 硬盘在位，无动作         | ON       | x        | x        |
| 硬盘在位，动作（Active） | 4Hz      | x        | x        |
| 定位状态（Locate)        | x        | 4Hz      | OFF      |
| 硬盘故障（Fault）        | x        | OFF      | ON       |

4.  <span id="_Toc528584800" class="anchor"></span>**CPLD更新模块**

> 通过JTAG总线可以用来升级4nvme板CPLD，4nvme板上存在一个JTAG header,用于debug阶段的功能调试和升级以及第一次的程序烧录。远程升级CPLD则需要通过扩展板，扩展板CPLD作为桥梁，路由从BMC过来的JTAG信号。BMC需要刷新后级的哪个单板，首先会通过IIC SMC命令字告诉扩展板CPLD，扩展板CPLD会打开相应的路由通道，然后BMC进行刷新。下图是对应的逻辑框图。

![](media/image6.emf)

CPLD更新框图

5.  <span id="_Toc217468051" class="anchor"></span>**CPLD与BMC通信模块**

> CPLD与BMC之间通过I2C进行数据的交互通信，CPLD I2C的地址为0110_000(x). BMC进行数据读写的数据格式如下所示。
>
> 下图是BMC写数据给CPLD的数据格式。

<figure>
<img src="media/image7.emf" />
<figcaption><p>BMC写数据格式</p></figcaption>
</figure>

> 下图是BMC从CPLD读数据格式。

<figure>
<img src="media/image8.emf" />
<figcaption><p>图12 BMC读数据格式</p></figcaption>
</figure>

> 具体的数据格式如下表所示，详见CPLD接口文档。
>
> ![](media/image9.emf)

6.  <span id="_Toc221259275" class="anchor"></span>**拓扑检测码流上报模块**

![](media/image10.emf)

> 拓扑检测码流发送链路层采用Hisport 协议传输，帧长度41字节，各字节具体内容如下图。由4nvme板发送以下信息，经线缆中的单根信号路由到主板CPLD，经过解析后发送给BIOS和BMC，BMC依据解析出来的CableID、Index、UID来判断组件类型以及线缆是否插错，BIOS根据上报的28-32字节，对挂载的端口模式进行配置。

<img src="media/image11.png" style="width:4.59722in;height:2.69931in" />

<img src="media/image12.png" style="width:4.50903in;height:4.85417in" />

3.  <span id="_Toc221259276" class="anchor"></span>**EEPROM模块**

> NVME板上的FRU选用I2C接口的M24128。
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

<span id="_Toc221259277" class="anchor"></span>**3.4各模块之间的总线设计**

<span id="_Toc221259278" class="anchor"></span>**3.4.1 SMBus/I2C拓扑**

<figure>
<img src="media/image13.emf" />
<figcaption><p>NVME背板I2C框图</p></figcaption>
</figure>

BMC的I2C链路下挂的两个从机就是FRU和CPLD，温度sensor的采样由cpld来实现。

<span id="_Toc221259279" class="anchor"></span>**3.4.2 JTAG链路**

NVME背板上有CPLD的JTAG烧写接口,板卡调试过程中使用；NVME背板上CPLD的在线升级是通过BMC端的JTAT信号实现的。

<figure>
<img src="media/image14.emf" />
<figcaption><p>JTAG拓扑</p></figcaption>
</figure>

<span id="_Toc221259280" class="anchor"></span>**3.5 单板电源设计**

硬盘供电的12V，由供电连接器从外部引入，经过EFUSE产生硬盘的12V供电。

![](media/image15.emf)

硬盘供电的3V3通过低速连接器引入。

![](media/image16.emf)

5V由12V_HDD经过降压电路产生。

![](media/image17.emf)

6.  <span id="_Toc221259281" class="anchor"></span>**单板接口/连接器pin定义**

    1.  <span id="_Toc221259282" class="anchor"></span>**内部接口**

内部接口主要包括低速接口、供电接口、两个UBC高速接口

1)低速定义如下：

<figure>
<img src="media/image18.png" style="width:5.51111in;height:3.15347in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\8c61ec80-4b93-4b89-a4d4-518a26a430e8.png" />
<figcaption></figcaption>
</figure>

2)供电接口定义如下：

<img src="media/image19.png" style="width:6.89028in;height:2.73472in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\13880915-dc2f-4083-b816-8f656e8c594a.png" />

3)UBC接口定义如下：

<img src="media/image20.png" style="width:6.89028in;height:2.33194in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\ebf44e3d-8adb-4b1e-bdd7-ea85edc6990b.png" />

2.  <span id="_Toc221259283" class="anchor"></span>**调试接口**

调试接口是指CPLD的JTAG接口，Pin定义如下:

<img src="media/image21.png" style="width:6.89028in;height:2.32153in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\e2e429ff-d1dc-4105-a7c4-2b0dfc43ae74.png" />

3.  <span id="_Toc214026956" class="anchor"></span>**单板PCB设计**

尺寸：427mm\*26.2mm，板厚：2.4MM，层数：10层，板材：NY6300S（支持PCIE5.0）

板卡正反面的placement

<img src="media/image22.png" style="width:6.49236in;height:0.60972in" alt="30692b6f-efea-431d-9819-1df90bae7c5e" />

<img src="media/image23.png" style="width:6.4875in;height:0.48333in" alt="41f3b8b1-1f98-46f3-9093-f901de1084df" />

> <span id="_Toc517452102" class="anchor"></span>**4.1 PCB叠层设计**
>
> <img src="media/image24.png" style="width:5.6786in;height:2.57343in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\74657b39-79db-430c-aaf6-5c03d63885af.png" />
>
> <span id="_Toc221259286" class="anchor"></span>**4.2 PCB走线设计**

TOP<img src="media/image25.png" style="width:6.89028in;height:0.76212in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\c52a27bd-5fe7-4127-8723-b0c49df4b031.png" />

L2

<img src="media/image26.png" style="width:6.89028in;height:0.71966in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\910e210e-879a-493a-9e54-129512cf3358.png" />

L3

<img src="media/image27.png" style="width:6.89028in;height:0.62764in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\92230ece-4505-4a23-8498-f83506727281.png" />

L4

<img src="media/image28.png" style="width:6.89028in;height:0.60846in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\e8e3ec3b-1ec3-415f-a104-54868d78e1a8.png" />

L5

<img src="media/image29.png" style="width:6.89028in;height:0.59495in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\af7e9570-be19-4484-9603-e2a00988cd20.png" />

L6

<img src="media/image30.png" style="width:6.89028in;height:0.57013in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\4c675a67-32a9-4173-abc9-c73a3431fd49.png" />

L7

<img src="media/image31.png" style="width:6.89028in;height:0.62323in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\ef74dc87-3175-4c0e-8b7c-3df5499ed491.png" />

L8

<img src="media/image32.png" style="width:6.89028in;height:0.59078in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\3f4e2c92-3fc4-490a-a6ee-97b81d203175.png" />

L9

<img src="media/image33.png" style="width:6.89028in;height:0.57577in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\ad206dbd-b25b-4165-9b23-3aa063e0fe71.png" />

BOTTOM

<img src="media/image34.png" style="width:6.89028in;height:0.53835in" alt="C:\Users\1\Documents\xwechat_files\wxid_zrwv96booqa921_d79d\temp\InputTemp\e3ad26ad-c265-4977-b451-e40f2434eab4.png" />

> <span id="_Toc221259287" class="anchor"></span>**4.3 高速部分**

选用板材：NY6300S，支持PCIE5.0的NVME盘
