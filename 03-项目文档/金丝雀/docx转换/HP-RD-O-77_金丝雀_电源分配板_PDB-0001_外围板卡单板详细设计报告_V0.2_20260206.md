**金丝雀电源分配板**\_**单板详细设计报告**

> **拟 制：<u>洪刚 </u>**
>
> **审 核：<u>丁雪 \_\_\_</u>**
>
> **批 准：<u>王钟一\_\_</u>**

# 目录

[概述 [3](#_Toc221264307)](#_Toc221264307)

[**1.1** **保密说明** [3](#_Toc221264308)](#_Toc221264308)

[**1.2** **版本历史** [3](#_Toc221264309)](#_Toc221264309)

[**1.3** **术语** [3](#_Toc221264310)](#_Toc221264310)

[**1.4** **参考文档** [3](#_Toc221264311)](#_Toc221264311)

[**1.5** **背景** [3](#_Toc221264312)](#_Toc221264312)

[2 单板总体说明 [3](#_Toc221264313)](#_Toc221264313)

[**2.1** **单板总体框图** [3](#_Toc221264314)](#_Toc221264314)

[**2.2** **连接器选型** [4](#_Toc528584792)](#_Toc528584792)

[**2.3** **单板接口/连接器pin定义** [4](#_Toc68878250)](#_Toc68878250)

[**2.3.1** **内部接口** [4](#_Toc68878251)](#_Toc68878251)

[**2.3.2** **外部接口** [6](#_Toc68878252)](#_Toc68878252)

[**2.3.3** **调试接口** [7](#_Toc68878253)](#_Toc68878253)

[3 单板PCB和信号完整性设计 [7](#_Toc68878254)](#_Toc68878254)

[**3.1** **PCB 叠层设计** [7](#_Toc28037711)](#_Toc28037711)

[**3.2** **PCB 走线设计** [8](#_Toc68878256)](#_Toc68878256)

[**3.3** **高速信号SI仿真和评估** [10](#_Toc68878257)](#_Toc68878257)

[**3.4** **功能接口丝印** [10](#_Toc221264324)](#_Toc221264324)

[4 单板结构相关设计 [10](#_Toc193359661)](#_Toc193359661)

[**4.1** **定位孔、禁布区和尺寸说明** [10](#_Toc193359662)](#_Toc193359662)

[**4.2** **特殊结构件** [11](#_Toc193359663)](#_Toc193359663)

<span id="_Toc221264307" class="anchor"></span>**概述**

1.  <span id="_Toc221264308" class="anchor"></span>**保密说明**

> **本技术文档为软通华方公司的机密文件，未经许可，不得复制和传播。**

2.  <span id="_Toc221264309" class="anchor"></span>**版本历史**

| **作者** | **描述**     | **版本** | **日期**   |
|:---------|:-------------|----------|------------|
| 洪刚     | 首次发布     | V0.1     | 2026/01/21 |
| 洪刚     | 按照模板更新 | V0.2     | 2026/02/06 |
|          |              |          |            |

3.  <span id="_Toc221264310" class="anchor"></span>**术语**

> **本文档中提到的所有术语、缩写等解释**

| **术语** | **描述**                            |
|:---------|:------------------------------------|
| CRPS     | ** Common Redundant Power Supply ** |
|          |                                     |
|          |                                     |

4.  <span id="_Toc221264311" class="anchor"></span>**参考文档**

| **文档名** | **描述** | **版本** | **日期** |
|------------|----------|----------|----------|
|            |          |          |          |
|            |          |          |          |
|            |          |          |          |

5.  <span id="_Toc221264312" class="anchor"></span>**背景**

> 金丝雀电源分配板用于将3个CRPS电源转接到金丝雀扩展卡上，通过扩展卡给各个硬盘背板、GPU背板、风扇板和主板供电。

1.  <span id="_Toc221264313" class="anchor"></span>**单板总体说明**

    1.  <span id="_Toc221264314" class="anchor"></span>**单板总体框图**

> 电源分配板从3个PSU取12V电，供给2个电源连接器，连接到扩展板上。
>
> 电源分配卡的板卡拓扑如下图所示：

![](media/image1.emf)

> 图 1 2 电源分配板卡拓扑

2.  <span id="_Toc528584792" class="anchor"></span>**连接器选型**

> 电源分配板核心连接器有2个:
>
> CRPS电源连接器HPG36P14SVP021T
>
> 主板电源连接器10172012-6003001LF

3.  <span id="_Toc68878250" class="anchor"></span>**单板接口/连接器pin定义**

    1.  <span id="_Toc68878251" class="anchor"></span>**内部接口**

> 内部接口为主板电源连接器。
>
> 主板电源连接器10172012-6003001LF，有2个，分别定义，其定义如下：

连接器1

| Pin      | Net Name                       | Function |
|----------|--------------------------------|----------|
| P1_A_1-6 | GND                            | 　       |
| P1_B_1-6 | GND                            | 　       |
| P2_A_1-6 | GND                            | 　       |
| P2_B_1-6 | GND                            | 　       |
| P3_A_1-6 | GND                            | 　       |
| P3_B_1-6 | GND                            | 　       |
| P4_A_1-6 | P12V_INPUT                     |          |
| P4_B_1-6 | P12V_INPUT                     |          |
| P5_A_1-6 | P12V_INPUT                     |          |
| P5_B_1-6 | P12V_INPUT                     |          |
| P6_A_1-6 | P12V_INPUT                     |          |
| P6_B_1-6 | P12V_INPUT                     |          |
| S1_1     | GND                            |          |
| S1_2     | GND                            |          |
| S1_3     | IRQ_PSU0_ALERT_N               |          |
| S1_4     | IRQ_PSU1_ALERT_N               |          |
| S1_5     | IRQ_PSU2_ALERT_N               |          |
| S2_1     | SMB_BMC_SDA                    | 　       |
| S2_2     | SMB_BMC_SCL                    |          |
| S2_3     | GND                            |          |
| S2_4     | SMB_PMBUS_SML1_STBY_LVC3_SDA_N |          |
| S2_5     | SMB_PMBUS_SML1_STBY_LVC3_SCL_N |          |
| S3_1     | FM_PSU0_PRSNT_J_N              |          |
| S3_2     | FM_PSU1_PRSNT_J_N              |          |
| S3_3     | FM_PSU2_PRSNT_J_N              |          |
| S3_4     | PSU0_PSON_N                    |          |
| S3_5     | GND                            |          |

表 1 主板连接器1 Pin定义

| Pin      | Net Name           | Function |
|----------|--------------------|----------|
| P1_A_1-6 | P12V_INPUT         | 　       |
| P1_B_1-6 | P12V_INPUT         | 　       |
| P2_A_1-6 | P12V_INPUT         | 　       |
| P2_B_1-6 | P12V_INPUT         | 　       |
| P3_A_1-6 | P12V_INPUT         | 　       |
| P3_B_1-6 | P12V_INPUT         | 　       |
| P4_A_1-6 | GND                |          |
| P4_B_1-6 | GND                |          |
| P5_A_1-6 | GND                |          |
| P5_B_1-6 | GND                |          |
| P6_A_1-6 | GND                |          |
| P6_B_1-6 | GND                |          |
| S1_1     | P3V3_STBY          |          |
| S1_2     | P3V3_STBY          |          |
| S1_3     | GND                |          |
| S1_4     | GND                |          |
| S1_5     | GND                |          |
| S2_1     | PSU2_PSON_N        | 　       |
| S2_2     | PSU1_PSON_N        |          |
| S2_3     | PWRGD_PS2_PWROK_J  |          |
| S2_4     | PWRGD_PS1_PWROK_J  |          |
| S2_5     | PWRGD_PS0_PWROK_J  |          |
| S3_1     | PWRGD_PSU2_AC_OK_J |          |
| S3_2     | PWRGD_PSU1_AC_OK_J |          |
| S3_3     | PWRGD_PSU0_AC_OK_J |          |
| S3_4     | GND                |          |
| S3_5     | GND                |          |

表 2 主板连接器2 Pin定义

2.  <span id="_Toc68878252" class="anchor"></span>**外部接口**

> 外部接口为CRPS电源连接器HPG36P14SVP021T。
>
> 对应的CRPS电源连接器Pin定义如下：

| PIN | Net Name          | PIN | Net Name           |
|-----|-------------------|-----|--------------------|
| A1  | GND               | B1  | GND                |
| A2  | GND               | B2  | GND                |
| A3  | GND               | B3  | GND                |
| A4  | GND               | B4  | GND                |
| A5  | GND               | B5  | GND                |
| A6  | GND               | B6  | GND                |
| A7  | GND               | B7  | GND                |
| A8  | GND               | B8  | GND                |
| A9  | GND               | B9  | GND                |
| A10 | +12V              | B10 | +12V               |
| A11 | +12V              | B11 | +12V               |
| A12 | +12V              | B12 | +12V               |
| A13 | +12V              | B13 | +12V               |
| A14 | +12V              | B14 | +12V               |
| A15 | +12V              | B15 | +12V               |
| A16 | +12V              | B16 | +12V               |
| A17 | +12V              | B17 | +12V               |
| A18 | +12V              | B18 | +12V               |
| A19 | PMBus SDA         | B19 | A0 (SMBus address) |
| A20 | PMBus SCL         | B20 | A1 (SMBus address) |
| A21 | PSON              | B21 | 12VSB              |
| A22 | SMBAlert#         | B22 | CR_BUS#            |
| A23 | Return Sense      | B23 | 12V load share Bus |
| A24 | +12V Remote Sense | B24 | NC (Reserved)\*    |
| A25 | PWOK              | B25 | COMBUS\*\*         |

> 表 3 CRPS Conn Pin定义

3.  <span id="_Toc68878253" class="anchor"></span>**调试接口**

> 无

2.  <span id="_Toc68878254" class="anchor"></span>**单板PCB和信号完整性设计**

    1.  <span id="_Toc28037711" class="anchor"></span>**PCB 叠层设计**

> PCB板材选用普通FR4板材，具体为S1000-2M
>
> PCB叠层设计详细说明如下，包含板厚，层数，PP和Core类型，铜厚，线宽线距等信息：

<table>
<colgroup>
<col style="width: 4%" />
<col style="width: 7%" />
<col style="width: 17%" />
<col style="width: 2%" />
<col style="width: 4%" />
<col style="width: 10%" />
<col style="width: 14%" />
<col style="width: 8%" />
<col style="width: 8%" />
<col style="width: 6%" />
<col style="width: 6%" />
<col style="width: 8%" />
</colgroup>
<thead>
<tr>
<th>　</th>
<th style="text-align: center;">　</th>
<th style="text-align: center;">　</th>
<th style="text-align: center;">　</th>
<th style="text-align: center;">　</th>
<th style="text-align: center;">　</th>
<th style="text-align: center;">　</th>
<th style="text-align: center;">　</th>
<th style="text-align: center;">　</th>
<th style="text-align: center;">　</th>
<th style="text-align: center;">　</th>
<th style="text-align: center;">　</th>
</tr>
</thead>
<tbody>
<tr>
<td>　</td>
<td rowspan="2" style="text-align: center;"><strong>层标识</strong></td>
<td colspan="3" style="text-align: center;"><strong>客户设计要求(oz/mil)</strong></td>
<td colspan="4" style="text-align: center;"><strong>PCB厂家设计调整(oz/mil)</strong></td>
<td style="text-align: center;"><strong>是否<br />
假Core</strong></td>
<td style="text-align: center;"><strong>铜箔类型</strong></td>
<td style="text-align: center;">残铜率<br />
(%)</td>
</tr>
<tr>
<td>　</td>
<td colspan="2" style="text-align: center;"><strong>层叠图示</strong></td>
<td style="text-align: center;"><strong>介质厚度</strong></td>
<td style="text-align: center;"><strong>介质厚度</strong></td>
<td colspan="2" style="text-align: center;"><strong>层叠图示</strong></td>
<td style="text-align: center;"><strong>DK值</strong></td>
<td style="text-align: center;"></td>
<td style="text-align: center;"></td>
<td style="text-align: center;"></td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;"><strong>L1</strong></td>
<td colspan="3" style="text-align: center;"><strong>0.5oz+plating</strong></td>
<td colspan="4" style="text-align: center;"><strong>0.5oz+plating</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;">HTE</td>
<td style="text-align: center;">　</td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;">　</td>
<td colspan="2" style="text-align: center;"><strong>PP</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>3.794</strong></td>
<td colspan="2" style="text-align: center;"><strong>PP(106_RC77%*2)</strong></td>
<td style="text-align: center;">3.99</td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;"><strong>L2</strong></td>
<td colspan="3" style="text-align: center;"><strong>2oz</strong></td>
<td colspan="4" style="text-align: center;"><strong>2oz</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;">HTE</td>
<td style="text-align: center;">85.0</td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;">　</td>
<td colspan="2" style="text-align: center;"><strong>Core</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>4</strong></td>
<td colspan="2" style="text-align: center;"><strong>Core(106*2)</strong></td>
<td style="text-align: center;">3.87</td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;"><strong>L3</strong></td>
<td colspan="3" style="text-align: center;"><strong>2oz</strong></td>
<td colspan="4" style="text-align: center;"><strong>2oz</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;">HTE</td>
<td style="text-align: center;">85.0</td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;">　</td>
<td colspan="2" style="text-align: center;"><strong>PP</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>5.087</strong></td>
<td colspan="2" style="text-align: center;"><strong>PP(1080_RC68%*2)</strong></td>
<td style="text-align: center;">3.97</td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;"><strong>L4</strong></td>
<td colspan="3" style="text-align: center;"><strong>2oz</strong></td>
<td colspan="4" style="text-align: center;"><strong>2oz</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;">HTE</td>
<td style="text-align: center;">85.0</td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;">　</td>
<td colspan="2" style="text-align: center;"><strong>Core</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>4</strong></td>
<td colspan="2" style="text-align: center;"><strong>Core(106*2)</strong></td>
<td style="text-align: center;">3.87</td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;"><strong>L5</strong></td>
<td colspan="3" style="text-align: center;"><strong>2oz</strong></td>
<td colspan="4" style="text-align: center;"><strong>2oz</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;">HTE</td>
<td style="text-align: center;">85.0</td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;">　</td>
<td colspan="2" style="text-align: center;"><strong>PP</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>5.087</strong></td>
<td colspan="2" style="text-align: center;"><strong>PP(1080_RC68%*2)</strong></td>
<td style="text-align: center;">3.97</td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;"><strong>L6</strong></td>
<td colspan="3" style="text-align: center;"><strong>2oz</strong></td>
<td colspan="4" style="text-align: center;"><strong>2oz</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;">HTE</td>
<td style="text-align: center;">85.0</td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;">　</td>
<td colspan="2" style="text-align: center;"><strong>Core</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>4</strong></td>
<td colspan="2" style="text-align: center;"><strong>Core(106*2)</strong></td>
<td style="text-align: center;">3.87</td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;"><strong>L7</strong></td>
<td colspan="3" style="text-align: center;"><strong>2oz</strong></td>
<td colspan="4" style="text-align: center;"><strong>2oz</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;">HTE</td>
<td style="text-align: center;">85.0</td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;">　</td>
<td colspan="2" style="text-align: center;"><strong>PP</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>5.087</strong></td>
<td colspan="2" style="text-align: center;"><strong>PP(1080_RC68%*2)</strong></td>
<td style="text-align: center;">3.97</td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;"><strong>L8</strong></td>
<td colspan="3" style="text-align: center;"><strong>2oz</strong></td>
<td colspan="4" style="text-align: center;"><strong>2oz</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;">HTE</td>
<td style="text-align: center;">85.0</td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;">　</td>
<td colspan="2" style="text-align: center;"><strong>Core</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>4</strong></td>
<td colspan="2" style="text-align: center;"><strong>Core(106*2)</strong></td>
<td style="text-align: center;">3.87</td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;"><strong>L9</strong></td>
<td colspan="3" style="text-align: center;"><strong>2oz</strong></td>
<td colspan="4" style="text-align: center;"><strong>2oz</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;">HTE</td>
<td style="text-align: center;">85.0</td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;">　</td>
<td colspan="2" style="text-align: center;"><strong>PP</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>5.087</strong></td>
<td colspan="2" style="text-align: center;"><strong>PP(1080_RC68%*2)</strong></td>
<td style="text-align: center;">3.97</td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;"><strong>L10</strong></td>
<td colspan="3" style="text-align: center;"><strong>2oz</strong></td>
<td colspan="4" style="text-align: center;"><strong>2oz</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;">HTE</td>
<td style="text-align: center;">85.0</td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;">　</td>
<td colspan="2" style="text-align: center;"><strong>Core</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>4</strong></td>
<td colspan="2" style="text-align: center;"><strong>Core(106*2)</strong></td>
<td style="text-align: center;">3.87</td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;"><strong>L11</strong></td>
<td colspan="3" style="text-align: center;"><strong>2oz</strong></td>
<td colspan="4" style="text-align: center;"><strong>2oz</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;">HTE</td>
<td style="text-align: center;">85.0</td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;">　</td>
<td colspan="2" style="text-align: center;"><strong>PP</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>5.087</strong></td>
<td colspan="2" style="text-align: center;"><strong>PP(1080_RC68%*2)</strong></td>
<td style="text-align: center;">3.97</td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;"><strong>L12</strong></td>
<td colspan="3" style="text-align: center;"><strong>2oz</strong></td>
<td colspan="4" style="text-align: center;"><strong>2oz</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;">HTE</td>
<td style="text-align: center;">85.0</td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;">　</td>
<td colspan="2" style="text-align: center;"><strong>Core</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>4</strong></td>
<td colspan="2" style="text-align: center;"><strong>Core(106*2)</strong></td>
<td style="text-align: center;">3.87</td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;"><strong>L13</strong></td>
<td colspan="3" style="text-align: center;"><strong>2oz</strong></td>
<td colspan="4" style="text-align: center;"><strong>2oz</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;">HTE</td>
<td style="text-align: center;">85.0</td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;">　</td>
<td colspan="2" style="text-align: center;"><strong>PP</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>5.087</strong></td>
<td colspan="2" style="text-align: center;"><strong>PP(1080_RC68%*2)</strong></td>
<td style="text-align: center;">3.97</td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;"><strong>L14</strong></td>
<td colspan="3" style="text-align: center;"><strong>2oz</strong></td>
<td colspan="4" style="text-align: center;"><strong>2oz</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;">HTE</td>
<td style="text-align: center;">85.0</td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;">　</td>
<td colspan="2" style="text-align: center;"><strong>Core</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>4</strong></td>
<td colspan="2" style="text-align: center;"><strong>Core(106*2)</strong></td>
<td style="text-align: center;">3.87</td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;"><strong>L15</strong></td>
<td colspan="3" style="text-align: center;"><strong>2oz</strong></td>
<td colspan="4" style="text-align: center;"><strong>2oz</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;">HTE</td>
<td style="text-align: center;">85.0</td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;">　</td>
<td colspan="2" style="text-align: center;"><strong>PP</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>5.087</strong></td>
<td colspan="2" style="text-align: center;"><strong>PP(1080_RC68%*2)</strong></td>
<td style="text-align: center;">3.97</td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;"><strong>L16</strong></td>
<td colspan="3" style="text-align: center;"><strong>2oz</strong></td>
<td colspan="4" style="text-align: center;"><strong>2oz</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;">HTE</td>
<td style="text-align: center;">85.0</td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;">　</td>
<td colspan="2" style="text-align: center;"><strong>Core</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>4</strong></td>
<td colspan="2" style="text-align: center;"><strong>Core(106*2)</strong></td>
<td style="text-align: center;">3.87</td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;"><strong>L17</strong></td>
<td colspan="3" style="text-align: center;"><strong>2oz</strong></td>
<td colspan="4" style="text-align: center;"><strong>2oz</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;">HTE</td>
<td style="text-align: center;">85.0</td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;">　</td>
<td colspan="2" style="text-align: center;"><strong>PP</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>3.794</strong></td>
<td colspan="2" style="text-align: center;"><strong>PP(106_RC77%*2)</strong></td>
<td style="text-align: center;">3.99</td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;"><strong>L18</strong></td>
<td colspan="3" style="text-align: center;"><strong>0.5oz+plating</strong></td>
<td colspan="4" style="text-align: center;"><strong>0.5oz+plating</strong></td>
<td style="text-align: center;"><strong>　</strong></td>
<td style="text-align: center;">HTE</td>
<td style="text-align: center;">　</td>
</tr>
<tr>
<td>　</td>
<td style="text-align: center;">　</td>
<td colspan="3" style="text-align: center;"><strong>客户设计板厚:</strong></td>
<td colspan="2" style="text-align: center;"><strong>3+/-8%mm</strong></td>
<td style="text-align: center;"><strong>含外层绿油厚度</strong></td>
<td style="text-align: center;">　</td>
<td style="text-align: center;">　</td>
<td style="text-align: center;">　</td>
<td style="text-align: center;">　</td>
</tr>
</tbody>
</table>

图 2板卡叠层信息

2.  <span id="_Toc68878256" class="anchor"></span>**PCB 走线设计**

PCB各层主要信号线及平面分布如下：

TOP层/ BOTTOM层：单端信号。

GND和VCC层：电源信号。

TOP层：

<img src="media/image2.png" style="width:3.48169in;height:1.78541in" />

BOTTOM层：

<img src="media/image3.png" style="width:3.90273in;height:2.00604in" />

L2/L4/L6/L8/L11/L13/L15/L17层：GND

<img src="media/image4.png" style="width:4.10708in;height:2.09783in" />

L3/L5/L7/L9/L10/L12/L14/L16层：VCC

<figure>
<img src="media/image5.png" style="width:4.21422in;height:2.18229in" />
<figcaption><blockquote>
<p>图 3板卡各层主要信号线及平面分布</p>
</blockquote></figcaption>
</figure>

3.  <span id="_Toc68878257" class="anchor"></span>**高速信号SI仿真和评估**

> 此板无高速走线，不涉及。

4.  <span id="_Toc221264324" class="anchor"></span>**功能接口丝印**

> 无

3.  <span id="_Toc193359661" class="anchor"></span>**单板结构相关设计**

    1.  <span id="_Toc193359662" class="anchor"></span>**定位孔、禁布区和尺寸说明**

<img src="media/image6.png" style="width:3.66042in;height:2.30208in" /><img src="media/image7.png" style="width:4.49028in;height:3.42431in" />

图 30电源分配板结构

2.  <span id="_Toc193359663" class="anchor"></span>**特殊结构件**

<figure>
<img src="media/image8.png" style="width:1.52195in;height:3.24143in" />
<figcaption><p>图 31 风扇板弹簧销：免工具固定</p></figcaption>
</figure>
