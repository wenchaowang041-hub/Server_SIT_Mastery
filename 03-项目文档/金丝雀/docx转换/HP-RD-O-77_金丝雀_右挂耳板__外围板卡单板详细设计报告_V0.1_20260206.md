**金丝雀右挂耳板**\_**单板详细设计报告**

> **拟 制：<u>洪刚 </u>**
>
> **审 核：<u>周加洋\_\_</u>**
>
> **批 准：<u>王钟一\_\_</u>**

# 目录

[概述 [3](#_Toc221184034)](#_Toc221184034)

[**1.1** **保密说明** [3](#_Toc221184035)](#_Toc221184035)

[**1.2** **版本历史** [3](#_Toc221184036)](#_Toc221184036)

[**1.3** **术语** [3](#_Toc221184037)](#_Toc221184037)

[**1.4** **参考文档** [3](#_Toc221184038)](#_Toc221184038)

[2 单板总体说明 [3](#_Toc221184039)](#_Toc221184039)

[**2.1** **单板总体框图** [3](#_Toc221184040)](#_Toc221184040)

[**2.2** **单板接口/连接器pin定义** [4](#_Toc68878250)](#_Toc68878250)

[**2.2.1** **外部接口** [4](#_Toc68878252)](#_Toc68878252)

[3 单板PCB和信号完整性设计 [5](#_Toc68878254)](#_Toc68878254)

[**3.1** **PCB 叠层设计** [5](#_Toc28037711)](#_Toc28037711)

[**3.2** **PCB 走线设计** [5](#_Toc68878256)](#_Toc68878256)

[**3.3** **高速信号SI仿真和评估** [5](#_Toc68878257)](#_Toc68878257)

[4 单板结构相关设计 [5](#_Toc193359661)](#_Toc193359661)

[**4.1** **定位孔、禁布区和尺寸说明** [5](#_Toc193359662)](#_Toc193359662)

[**4.2** **特殊结构件** [6](#_Toc193359663)](#_Toc193359663)

<span id="_Toc221184034" class="anchor"></span>**概述**

1.  <span id="_Toc221184035" class="anchor"></span>**保密说明**

> **本技术文档为软通华方公司的机密文件，未经许可，不得复制和传播。**

2.  <span id="_Toc221184036" class="anchor"></span>**版本历史**

| **作者** | **描述** | **版本** | **日期**   |
|:---------|:---------|----------|------------|
| 洪刚     | 首次发布 | V0.1     | 2026/02/06 |
|          |          |          |            |
|          |          |          |            |

3.  <span id="_Toc221184037" class="anchor"></span>**术语**

> **本文档中提到的所有术语、缩写等解释**

| **术语** | **描述**                 |
|:---------|--------------------------|
| I2C      | Inter-Integrated Circuit |
|          |                          |
|          |                          |

4.  <span id="_Toc221184038" class="anchor"></span>**参考文档**

| **文档名**                   | **描述**                   | **版本** | **日期**  |
|------------------------------|----------------------------|----------|-----------|
| 金丝雀6U项目硬件板卡概要设计 | 金丝雀6U项目的总体文档说明 | V0.6     | 2026.1.21 |
|                              |                            |          |           |
|                              |                            |          |           |

1.  <span id="_Toc221184039" class="anchor"></span>**单板总体说明**

    1.  <span id="_Toc221184040" class="anchor"></span>**单板总体框图**

> 金丝雀项目中的右挂耳板主要实现整机的电源按键开机、健康状态指示灯的功能。
>
> 右挂耳板卡的拓扑如下图所示：

<img src="media/image1.png" style="width:6.49583in;height:3.33958in" />

> 图 1右挂耳板卡拓扑

2.  <span id="_Toc68878250" class="anchor"></span>**单板接口/连接器pin定义**

    1.  <span id="_Toc68878252" class="anchor"></span>**外部接口**

> 外部接口为一个2X10的线缆连接器 ，采用连接器型号为1230-201-07-3。
>
> 连接器的Pin定义如下：

表 1 外部接口连接器 Pin定义

| Pin | Net Name | Function | Pin | Net Name | Function |
|:--:|:--:|:--:|:--:|:--:|:--:|
| 1 | 无连接 |  | 2 | UID_LED | UID指示灯，低有效 |
| 3 | 无连接 |  | 4 | LEFT_EAR_PRSNT_LOOP | LEFT_EAR_PRSNT_LOOP |
| 5 | GND | GND | 6 | CPLD_I2C_SCL | CPLD的I2C总线时钟 |
| 7 | 无连接 | FAN speed control | 8 | CPLD_I2C_SDA | CPLD的I2C总线数据 |
| 9 | 无连接 |  | 10 | GND | GND |
| 11 | GND | GND | 12 | PWR_BTN | 开关机按键，低有效 |
| 13 | 无连接 |  | 14 | GND | GND |
| 15 | 无连接 |  | 16 | UID_BTN | UID按键，低有效 |
| 17 | LEFT_EAR_PRSNT_LOOP | LEFT_EAR_PRSNT_LOOP | 18 | STBY_3V3 |  |
| 19 | 无连接 |  | 20 | STBY_3V3 |  |

2.  <span id="_Toc68878254" class="anchor"></span>**单板PCB和信号完整性设计**

    1.  <span id="_Toc28037711" class="anchor"></span>**PCB 叠层设计**

PCB板材选用普通FR4板材，具体为IT-180A

尺寸：16mm\*52mm，板厚：1.6mm，层数：4层，板材：普通FR4

<img src="media/image2.png" style="width:6.89028in;height:2.25278in" />

2.  <span id="_Toc68878256" class="anchor"></span>**PCB 走线设计**

PCB各层主要信号线及平面分布如下：

TOP层：按键开关和I2C扩展芯片

<img src="media/image3.png" style="width:0.84473in;height:2.33005in" />

L2层：GND

<img src="media/image4.png" style="width:0.92617in;height:2.63602in" />

L3层：电源

<img src="media/image5.png" style="width:1.05162in;height:2.39957in" />

BOTTOM层：连接器

<img src="media/image6.png" style="width:1.00596in;height:2.52454in" />

3.  <span id="_Toc68878257" class="anchor"></span>**高速信号SI仿真和评估**

> 此板无高速走线，不涉及。

3.  <span id="_Toc193359661" class="anchor"></span>**单板结构相关设计**

    1.  <span id="_Toc193359662" class="anchor"></span>**定位孔、禁布区和尺寸说明**

注：实际金丝雀板卡不焊接数码管

<img src="media/image7.png" style="width:3.76944in;height:3.43958in" />

<figure>
<img src="media/image8.png" style="width:3.89583in;height:3.93958in" />
<figcaption><p>图3 右挂耳板卡结构</p></figcaption>
</figure>

2.  <span id="_Toc193359663" class="anchor"></span>**特殊结构件**

> 无
