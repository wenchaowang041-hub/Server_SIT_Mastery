**金丝雀左挂耳板**\_**单板详细设计报告**

> **拟 制： <u>洪刚 </u>**
>
> **审 核：<u>\_周加洋\_\_</u>**
>
> **批 准：<u>\_王钟一\_\_</u>**

# 目录

[概述 [3](#_Toc221183920)](#_Toc221183920)

[**1.1** **保密说明** [3](#_Toc221183921)](#_Toc221183921)

[**1.2** **版本历史** [3](#_Toc221183922)](#_Toc221183922)

[**1.3** **术语** [3](#_Toc221183923)](#_Toc221183923)

[**1.4** **参考文档** [3](#_Toc221183924)](#_Toc221183924)

[2 单板总体说明 [3](#_Toc221183925)](#_Toc221183925)

[**2.1** **单板总体框图** [3](#_Toc221183926)](#_Toc221183926)

[**2.2** **单板接口/连接器pin定义** [4](#_Toc68878250)](#_Toc68878250)

[**2.2.1** **外部接口** [4](#_Toc68878252)](#_Toc68878252)

[3 单板PCB和信号完整性设计 [5](#_Toc68878254)](#_Toc68878254)

[**3.1** **PCB 叠层设计** [5](#_Toc28037711)](#_Toc28037711)

[**3.2** **PCB 走线设计** [6](#_Toc68878256)](#_Toc68878256)

[**3.3** **高速信号SI仿真和评估** [7](#_Toc68878257)](#_Toc68878257)

[4 单板结构相关设计 [7](#_Toc193359661)](#_Toc193359661)

[**4.1** **定位孔、禁布区和尺寸说明** [7](#_Toc193359662)](#_Toc193359662)

[**4.2** **特殊结构件** [8](#_Toc193359663)](#_Toc193359663)

<span id="_Toc221183920" class="anchor"></span>**概述**

1.  <span id="_Toc221183921" class="anchor"></span>**保密说明**

> **本技术文档为软通华方公司的机密文件，未经许可，不得复制和传播。**

2.  <span id="_Toc221183922" class="anchor"></span>**版本历史**

| **作者** | **描述** | **版本** | **日期**   |
|:---------|:---------|----------|------------|
| 洪刚     | 首次发布 | V0.1     | 2026/02/05 |
|          |          |          |            |
|          |          |          |            |

3.  <span id="_Toc221183923" class="anchor"></span>**术语**

> **本文档中提到的所有术语、缩写等解释**

| **术语** | **描述**                 |
|:---------|--------------------------|
| I2C      | Inter-Integrated Circuit |
|          |                          |
|          |                          |

4.  <span id="_Toc221183924" class="anchor"></span>**参考文档**

| **文档名**                   | **描述**                   | **版本** | **日期**  |
|------------------------------|----------------------------|----------|-----------|
| 金丝雀6U项目硬件板卡概要设计 | 金丝雀6U项目的总体文档说明 | V0.6     | 2026.1.21 |
|                              |                            |          |           |
|                              |                            |          |           |

1.  <span id="_Toc221183925" class="anchor"></span>**单板总体说明**

    1.  <span id="_Toc221183926" class="anchor"></span>**单板总体框图**

> 金丝雀项目中的左挂耳板主要实现前面板VGA接口、USB接口功能，同时提供可访问的FRU及温度sensor。
>
> 左挂耳板卡的拓扑如下图所示：

<img src="media/image1.png" style="width:6.49931in;height:3.38819in" alt="0cd48db9-5cdf-4028-8b33-64d33ee76279" />

> 图 1 2 左挂耳板卡拓扑

2.  <span id="_Toc68878250" class="anchor"></span>**单板接口/连接器pin定义**

    1.  <span id="_Toc68878252" class="anchor"></span>**外部接口**

> 外部接口为一个2X25的线缆连接器 ，采用连接器型号为1338-501-8Q-P。
>
> 连接器的Pin定义如下：

表 1 外部接口连接器 Pin定义

| Pin | Net Name | Function | Pin | Net Name | Function |
|:--:|:--:|:--:|:--:|:--:|:--:|
| 1 | FP_LCD_PRESENT |  | 2 | VGA_SEL |  |
| 3 | PRSNT_RCI_N |  | 4 | BMC_VGA_RED_FRONT | BMC_VGA_RED_FRONT |
| 5 | FP_LCD_RESET_N | FP_LCD_RESET_N | 6 | GND | GND |
| 7 | FP_LCD_CS | FP_LCD_CS | 8 | BMC_VGA_GREEN_FRONT | BMC_VGA_GREEN_FRONT |
| 9 | P3V3_STBY |  | 10 | GND | GND |
| 11 | GND | GND | 12 | BMC_VGA_BLUE_FRONT |  |
| 13 | P5V_USB0_REAR |  | 14 | GND | GND |
| 15 | P5V_USB0_REAR |  | 16 | BMC_VGA_HS_FRONT |  |
| 17 | P5V_USB0_REAR |  | 18 | BMC_VGA_VS_FRONT |  |
| 19 | P5V_USB1_REAR |  | 20 | GND | GND |
| 21 | P5V_USB1_REAR |  | 22 | BMC_SMBUS_SCL |  |
| 23 | P5V_USB1_REAR |  | 24 | BMC_SMBUS_SDA |  |
| 25 | GND | GND | 26 | GND | GND |
| 27 | USB3_HUB_REAR_TX0_DN |  | 28 | USB3_REAR_HUB_RX0_DN |  |
| 29 | USB3_HUB_REAR_TX0_DP |  | 30 | USB3_REAR_HUB_RX0_DP |  |
| 31 | GND | GND | 32 | GND | GND |
| 33 | USB3_HUB_REAR_TX1_DN |  | 34 | USB3_REAR_HUB_RX1_DN |  |
| 35 | USB3_HUB_REAR_TX1_DP |  | 36 | USB3_REAR_HUB_RX1_DP |  |
| 37 | GND | GND | 38 | GND | GND |
| 39 | USB2_REAR_0_DP |  | 40 | USB2_REAR_1_DP |  |
| 41 | USB2_REAR_0_DN |  | 42 | USB2_REAR_1_DN |  |
| 43 | GND | GND | 44 | PRSNT_RCI_N |  |
| 45 | FP_LCD_SDA |  | 46 | SMB_BMC_VGA_DDC_SCL |  |
| 47 | FP_LCD_SCL |  | 48 | SMB_BMC_VGA_DDC_SDA |  |
| 49 | GND | GND | 50 | P5V0_VCC |  |

2.  <span id="_Toc68878254" class="anchor"></span>**单板PCB和信号完整性设计**

    1.  <span id="_Toc28037711" class="anchor"></span>**PCB 叠层设计**

PCB板材选用普通FR4板材，具体为IT-180A

尺寸：25.67mm\*52.06mm，板厚：1.6mm，层数：6层，板材：普通FR4

<img src="media/image2.png" style="width:6.89028in;height:2.675in" />

2.  <span id="_Toc68878256" class="anchor"></span>**PCB 走线设计**

PCB各层主要信号线及平面分布如下：

TOP层/L3层/ BOTTOM层：单端信号及重要信号,由于L2和L5层为完整的参考地，因此重要信号需要走在TOP和BOTTOM层。

TOP层：主要连接器放置层

<img src="media/image3.png" style="width:1.34653in;height:1.87357in" />

L2/L5层：GND

<img src="media/image4.png" style="width:1.34962in;height:2.07484in" />

L3层：内部走线层，主要走USB的差分线

<img src="media/image5.png" style="width:1.33877in;height:1.98336in" />

L4层：电源层

<img src="media/image6.png" style="width:1.61647in;height:2.49013in" />

BOTTOM层：USB走线及FRU和温度传感器放置层

<img src="media/image7.png" style="width:1.72248in;height:3.06949in" />

3.  <span id="_Toc68878257" class="anchor"></span>**高速信号SI仿真和评估**

> 此板无高速走线，不涉及。

3.  <span id="_Toc193359661" class="anchor"></span>**单板结构相关设计**

    1.  <span id="_Toc193359662" class="anchor"></span>**定位孔、禁布区和尺寸说明**

<img src="media/image8.png" style="width:3.62637in;height:3.52778in" />

<figure>
<img src="media/image9.png" style="width:6.12637in;height:4.52222in" />
<figcaption><p>图3 左挂耳板卡结构</p></figcaption>
</figure>

2.  <span id="_Toc193359663" class="anchor"></span>**特殊结构件**

> 无
