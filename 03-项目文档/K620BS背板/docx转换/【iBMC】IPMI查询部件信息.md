[1. 查询CPU/内存/PCIe卡/电源/风扇在位状态 [1](#查询cpu内存pcie卡电源风扇在位状态)](#查询cpu内存pcie卡电源风扇在位状态)

[2. 查询CPU/内存/PCIe卡/电源/风扇健康状态 [2](#查询cpu内存pcie卡电源风扇健康状态)](#查询cpu内存pcie卡电源风扇健康状态)

[3. 获取系统的健康状态 [3](#获取系统的健康状态)](#获取系统的健康状态)

[4. 查询CPU详细信息 [3](#查询cpu详细信息)](#查询cpu详细信息)

[5. 查询内存详细信息 [5](#查询内存详细信息)](#查询内存详细信息)

[6. 获取所有RAID控制器ID列表 [6](#获取所有raid控制器id列表)](#获取所有raid控制器id列表)

[7. 获取指定RAID控制器信息 [7](#获取指定raid控制器信息)](#获取指定raid控制器信息)

[8. 获取指定RAID控制器firmware版本 [9](#获取指定raid控制器firmware版本)](#获取指定raid控制器firmware版本)

[9. 获取指定RAID控制器类型 [9](#获取指定raid控制器类型)](#获取指定raid控制器类型)

[10. 获取指定RAID控制器管理的物理盘ID列表 [10](#获取指定raid控制器管理的物理盘id列表)](#获取指定raid控制器管理的物理盘id列表)

[11. 查询硬盘详细信息 [10](#查询硬盘详细信息)](#查询硬盘详细信息)

[12. 获取板载网卡厂商 [14](#获取板载网卡厂商)](#获取板载网卡厂商)

[13. 获取板载网口MAC地址 [15](#获取板载网口mac地址)](#获取板载网口mac地址)

[14. 获取电源个数及槽位号（只适用于机架服务器） [16](#获取电源个数及槽位号只适用于机架服务器)](#获取电源个数及槽位号只适用于机架服务器)

[15. 获取电源厂商（只适用于机架服务器） [16](#获取电源厂商只适用于机架服务器)](#获取电源厂商只适用于机架服务器)

[16. 获取电源类型（只适用于机架服务器） [17](#获取电源类型只适用于机架服务器)](#获取电源类型只适用于机架服务器)

[17. 获取电源固件版本（只适用于机架服务器） [18](#获取电源固件版本只适用于机架服务器)](#获取电源固件版本只适用于机架服务器)

[18. 获取电源SN（只适用于机架服务器） [18](#获取电源sn只适用于机架服务器)](#获取电源sn只适用于机架服务器)

[19. 获取电源额定功率（只适用于机架服务器） [19](#获取电源额定功率只适用于机架服务器)](#获取电源额定功率只适用于机架服务器)

[20. 获取电源温度（只适用于机架服务器） [19](#获取电源温度只适用于机架服务器)](#获取电源温度只适用于机架服务器)

[21. 获取风扇型号（只适用于机架服务器） [20](#获取风扇型号只适用于机架服务器)](#获取风扇型号只适用于机架服务器)

[22. 获取风扇转速比（只适用于机架服务器） [20](#获取风扇转速比只适用于机架服务器)](#获取风扇转速比只适用于机架服务器)

[23. 获取固件版本 [21](#获取固件版本)](#获取固件版本)

[24. 获取机框电子标签信息 [22](#获取机框电子标签信息)](#获取机框电子标签信息)

[25. 设置单板电子标签信息 [23](#设置单板电子标签信息)](#设置单板电子标签信息)

[26. 获取单板电子标签信息 [24](#获取单板电子标签信息)](#获取单板电子标签信息)

[27. 获取SEL时间 [25](#获取sel时间)](#获取sel时间)

[28. 获取系统重启原因 [25](#获取系统重启原因)](#获取系统重启原因)

## 查询CPU/内存/PCIe卡/电源/风扇在位状态

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x27 0x00 0x01 0x02 0x00 0x00

0x00： 0x00表示 CPU，0x01表示内存，0x03表示电源，0x04表示风扇，0x08表示PCIe卡。（仅机架服务器支持查询风扇和电源）

0x01： 表示部件槽位号，从1开始计数

0x02： 表示查询在位状态

### 【响应示例】

db 07 00 00 01

### 【响应格式】

<table>
<colgroup>
<col style="width: 35%" />
<col style="width: 32%" />
<col style="width: 31%" />
</colgroup>
<thead>
<tr>
<th>字节</th>
<th>含义</th>
<th>示例</th>
</tr>
</thead>
<tbody>
<tr>
<td>byte[0]~byte[2]</td>
<td>获取成功时固定为db 07 00</td>
<td></td>
</tr>
<tr>
<td>byte[3]</td>
<td>获取成功时固定为00</td>
<td></td>
</tr>
<tr>
<td>byte[4]</td>
<td><p>0x00：不在位</p>
<p>0x01：在位</p></td>
<td>0x01，即在位</td>
</tr>
</tbody>
</table>

## 查询CPU/内存/PCIe卡/电源/风扇健康状态

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x27 0x00 0x01 0x03 0x00 0x00

0x00： 0x00表示 CPU，0x01表示内存，0x03表示电源，0x04表示风扇，0x08表示PCIe卡。（仅机架服务器支持查询风扇和电源）

0x01： 表示部件槽位号，从1开始计数

0x03： 表示查询健康状态

### 【响应示例】

db 07 00 00 01

### 【响应格式】

<table>
<colgroup>
<col style="width: 35%" />
<col style="width: 32%" />
<col style="width: 31%" />
</colgroup>
<thead>
<tr>
<th>字节</th>
<th>含义</th>
<th>示例</th>
</tr>
</thead>
<tbody>
<tr>
<td>byte[0]~byte[2]</td>
<td>获取成功时固定为db 07 00</td>
<td></td>
</tr>
<tr>
<td>byte[3]</td>
<td>获取成功时固定为00</td>
<td></td>
</tr>
<tr>
<td>byte[4]</td>
<td><p>0x00：正常</p>
<p>0x01：轻微告警</p>
<p>0x02：严重告警</p>
<p>0x03：紧急告警</p>
<p>0x04：不在位</p></td>
<td>0x01，即健康状态为轻微告警状态</td>
</tr>
</tbody>
</table>

## 获取系统的健康状态

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U *UserName* -P *Password* raw 0x30 0x91 0xdb 0x07 0x00 0x08 0x00

0x00：表示FRU Device ID，默认00

### 【响应示例】

db 07 00 06 02 00

### 【响应格式】

<table>
<colgroup>
<col style="width: 35%" />
<col style="width: 32%" />
<col style="width: 31%" />
</colgroup>
<thead>
<tr>
<th>字节</th>
<th>含义</th>
<th>示例</th>
</tr>
</thead>
<tbody>
<tr>
<td>byte[0]~byte[2]</td>
<td>0xdb0x070x00</td>
<td></td>
</tr>
<tr>
<td>byte[3]~byte[5]</td>
<td><p>3: Minor Event count</p>
<p>4: Major Event count</p>
<p>5: Critical Event count</p></td>
<td>06 02 00，表示6个一般告警，2个重要告警。</td>
</tr>
</tbody>
</table>

## 查询CPU详细信息

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x27 0x00 0x01 0x63 0x00 0xF0

0x00： 0x00表示 CPU

0x01： 表示部件槽位号，从1开始计数

0x63： 表示查询CPU详细信息

0x00： 表示offset偏移

0xF0： 表示读取字节长度

### 【响应示例】

第一帧命令

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x27 0x00 0x01 0x63 0x00 0xF0

第一帧响应

db 07 00 01 49 6e 74 65 6c 28 52 29 20 43 6f 72

70 6f 72 61 74 69 6f 6e 2c 49 6e 74 65 6c 28 52

29 20 58 65 6f 6e 28 52 29 20 47 6f 6c 64 20 36

31 34 38 20 43 50 55 20 40 20 32 2e 34 30 47 48

7a 2c 32 34 30 30 20 4d 48 7a 2c 35 34 2d 30 36

2d 30 35 2d 30 30 2d 46 46 2d 46 42 2d 45 42 2d

42 46 2c 32 30 20 63 6f 72 65 73 2c 34 30 20 74

68 72 65 61 64 73 2c 36 34 2d 62 69 74 20 43 61

70 61 62 6c 65 7c 20 4d 75 6c 74 69 2d 43 6f 72

65 7c 20 48 61 72 64 77 61 72 65 20 54 68 72 65

61 64 7c 20 45 78 65 63 75 74 65 20 50 72 6f 74

65 63 74 69 6f 6e 7c 20 45 6e 68 61 6e 63 65 64

20 56 69 72 74 75 61 6c 69 7a 61 74 69 6f 6e 7c

20 50 6f 77 65 72 2f 50 65 72 66 6f 72 6d 61 6e

63 65 20 43 6f 6e 74 72 6f 6c 2c 31 32 38 30 20

4b 2c 32 30

Intel(R) Corporation,Intel(R) Xeon(R) Gold 6148 CPU @ 2.40GHz,2400 MHz,54-06-05-00-FF-FB-EB-BF,20 cores,40 threads,64-bit Capable\| Multi-Core\| Hardware Thread\| Execute Protection\| Enhanced Virtualization\| Power/Performance Control,1280 K,20

第二帧命令

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x27 0x00 0x01 0x63 0xF0 0xF0

第二帧响应

db 07 00 00 34 38 30 20 4b 2c 32 38 31 36 30 20

4b

480 K,28160 K

### 【响应格式】

<table>
<colgroup>
<col style="width: 35%" />
<col style="width: 32%" />
<col style="width: 31%" />
</colgroup>
<thead>
<tr>
<th>字节</th>
<th>含义</th>
<th>示例</th>
</tr>
</thead>
<tbody>
<tr>
<td>byte[0]~byte[2]</td>
<td>获取成功时固定为db 07 00</td>
<td></td>
</tr>
<tr>
<td>byte[3]</td>
<td><p>0x00：信息已全部获取</p>
<p>0x01：表示信息尚未全部获取需要下一帧继续查询</p></td>
<td></td>
</tr>
<tr>
<td>byte[4]~第一个0x2c（逗号）</td>
<td>cpu厂商</td>
<td>Intel(R) Corporation</td>
</tr>
<tr>
<td>第一个0x2c（逗号）~第二个0x2c（逗号）</td>
<td>cpu型号</td>
<td>Intel(R) Xeon(R) Gold 6148 CPU @ 2.40GHz</td>
</tr>
<tr>
<td>第二个0x2c（逗号）~第三个0x2c（逗号）</td>
<td>cpu主频</td>
<td>2400 MHz</td>
</tr>
<tr>
<td>第三个0x2c（逗号）~第四个0x2c（逗号）</td>
<td>cpu处理器ID</td>
<td>54-06-05-00-FF-FB-EB-BF</td>
</tr>
<tr>
<td>第四个0x2c（逗号）~第五个0x2c（逗号）</td>
<td>cpu核数</td>
<td>20 cores</td>
</tr>
<tr>
<td>第五个0x2c（逗号）~第六个0x2c（逗号）</td>
<td>cpu线程数</td>
<td>40 threads</td>
</tr>
<tr>
<td>第六个0x2c（逗号）~第七个0x2c（逗号）</td>
<td>cpu内存技术</td>
<td>64-bit Capable| Multi-Core| Hardware Thread| Execute Protection| Enhanced Virtualization| Power/Performance Control</td>
</tr>
<tr>
<td>第七个0x2c（逗号）~第八个0x2c（逗号）</td>
<td>cpu一级缓存</td>
<td>1280 K</td>
</tr>
<tr>
<td>第八个0x2c（逗号）~第九个0x2c（逗号）</td>
<td>cpu二级缓存</td>
<td>20480K</td>
</tr>
<tr>
<td>第九个0x2c（逗号）~结束</td>
<td>cpu三级缓存</td>
<td>28160K</td>
</tr>
</tbody>
</table>

## 查询内存详细信息

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x27 0x01 0x01 0x63 0x00 0xF0

0x01： 0x01表示内存

0x01： 表示内存槽位号，从1开始计数

0x63： 表示查询内存详细信息

0x00： 表示offset偏移

0xF0： 表示读取字节长度

### 【响应示例】

第一帧命令

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x27 0x01 0x01 0x63 0x00 0xF0

第一帧响应

db 07 00 00 4d 69 63 72 6f 6e 2c 20 32 34 30 30

20 4d 48 7a 2c 20 38 31 39 32 20 4d 42 2c 44 44

52 34 2c 31 37 36 35 39 33 45 36 2c 31 32 30 30

20 6d 56 2c 32 20 72 61 6e 6b 2c 37 32 20 62 69

74 2c 53 79 6e 63 68 72 6f 6e 6f 75 73 7c 20 52

65 67 69 73 74 65 72 65 64 20 28 42 75 66 66 65

72 65 64 29

Micron, 2400 MHz, 8192 MB,DDR4,176593E6,1200 mV,2 rank,72 bit,Synchronous\| Registered (Buffered)

### 【响应格式】

<table>
<colgroup>
<col style="width: 35%" />
<col style="width: 32%" />
<col style="width: 31%" />
</colgroup>
<thead>
<tr>
<th>字节</th>
<th>含义</th>
<th>示例</th>
</tr>
</thead>
<tbody>
<tr>
<td>byte[0]~byte[2]</td>
<td>获取成功时固定为db 07 00</td>
<td></td>
</tr>
<tr>
<td>byte[3]</td>
<td><p>0x00：信息已全部获取</p>
<p>0x01：表示信息尚未全部获取需要下一帧继续查询</p></td>
<td></td>
</tr>
<tr>
<td>byte[4]~第一个0x2c（逗号）</td>
<td>内存厂商</td>
<td>Micron</td>
</tr>
<tr>
<td>第一个0x2c（逗号）~第二个0x2c（逗号）</td>
<td>内存主频</td>
<td>2400 MHz</td>
</tr>
<tr>
<td>第二个0x2c（逗号）~第三个0x2c（逗号）</td>
<td>内存容量</td>
<td>8192 MB</td>
</tr>
<tr>
<td>第三个0x2c（逗号）~第四个0x2c（逗号）</td>
<td>内存类型</td>
<td>DDR4</td>
</tr>
<tr>
<td>第四个0x2c（逗号）~第五个0x2c（逗号）</td>
<td>内存SN</td>
<td>176593E6</td>
</tr>
<tr>
<td>第五个0x2c（逗号）~第六个0x2c（逗号）</td>
<td>内存最小电压</td>
<td>1200 mV</td>
</tr>
<tr>
<td>第六个0x2c（逗号）~第七个0x2c（逗号）</td>
<td>内存RANK（列）</td>
<td>2 rank</td>
</tr>
<tr>
<td>第七个0x2c（逗号）~第八个0x2c（逗号）</td>
<td>内存位宽</td>
<td>72 bit</td>
</tr>
<tr>
<td>第八个0x2c（逗号）~结束</td>
<td>内存技术</td>
<td>Synchronous| Registered (Buffered)</td>
</tr>
</tbody>
</table>

## 获取所有RAID控制器ID列表

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x3d 0x00 0x00 0xFF 0xFF 0xFF 0x00 0x00 0xF0

0xF0： 表示读取字节长度

### 【响应示例】

db 07 00 00 00 01

### 【响应格式】

| 字节 | 含义 | 示例 |
|----|----|----|
| byte\[0\]~byte\[2\] | 获取成功时固定为db 07 00 |  |
| byte\[3\] | 获取成功时固定为00 |  |
| byte\[4\]~结束 | 获取到的RAID控制器ID列表 | 00 01，2个RAID控制器，ID分别为0,1 |

## 获取指定RAID控制器信息

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x3d 0x00 0x03 0x01 0x00 0x00 0x00 0x00 0xF0

0x01： 表示RAID控制器ID，从0开始计数

0x00 0x00： 表示offset偏移

0xF0： 表示读取字节长度

### 【响应示例】

第一帧命令

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x3d 0x00 0x03 0x00 <span class="mark">0xff 0xff</span> 0x00 0x00 0xF0

第一帧响应

db 07 00 00 01 00 08 05 35 34 34 38 32 65 35 30

30 35 34 33 37 30 30 30 00 01 01 01 00 07 0b 00

00 00 00 00 07 53 41 53 33 35 30 38

### 【响应格式】

<table>
<colgroup>
<col style="width: 35%" />
<col style="width: 32%" />
<col style="width: 31%" />
</colgroup>
<thead>
<tr>
<th>字节</th>
<th>含义</th>
<th>示例</th>
</tr>
</thead>
<tbody>
<tr>
<td>byte[0]~byte[2]</td>
<td>获取成功时固定为db 07 00</td>
<td></td>
</tr>
<tr>
<td>byte[3]</td>
<td><p>0x00：信息已全部获取</p>
<p>0x01：表示信息尚未全部获取需要下一帧继续查询</p></td>
<td></td>
</tr>
<tr>
<td>byte[4]</td>
<td><p>RAID控制器是否支持带外管理</p>
<p>0x00：不支持</p>
<p>0x01：支持</p></td>
<td>0x01，即支持</td>
</tr>
<tr>
<td>byte[5]~byte[6]</td>
<td><p>RAID控制器内存大小，单位MB小端序</p>
<p>0xFF 0xFF：UNKNOWN</p></td>
<td>0x00 0x08，即0x0800，即2048MB</td>
</tr>
<tr>
<td>byte[7]</td>
<td><p>RAID控制器接口速率</p>
<p>0x00：SPI</p>
<p>0x01：SAS 3G</p>
<p>0x02：SATA 1.5G</p>
<p>0x03：SATA 3G</p>
<p>0x04：SAS 6G</p>
<p>0x05：SAS 12G</p>
<p>0xFF：UNKNOWN</p></td>
<td>0x05，即SAS 12G</td>
</tr>
<tr>
<td>byte[8]~byte[23]</td>
<td>RAID控制器SAS地址</td>
<td>54482e5005437000</td>
</tr>
<tr>
<td>byte[24]</td>
<td><p>Cache pinned状态</p>
<p>0x00：关闭</p>
<p>0x01：开启</p>
<p>0xFF：UNKNOWN</p></td>
<td>0x00，即关闭</td>
</tr>
<tr>
<td>byte[25]</td>
<td><p>物理盘故障记忆：</p>
<p>0x00：禁用</p>
<p>0x01：启用</p>
<p>0xFF：UNKNOWN</p></td>
<td>0x01，即启用</td>
</tr>
<tr>
<td>byte[26]</td>
<td><p>回拷</p>
<p>0x00：禁用</p>
<p>0x01：启用</p>
<p>0xFF：UNKNOWN</p></td>
<td>0x01：即启用</td>
</tr>
<tr>
<td>byte[27]</td>
<td><p>SMART错误时回拷：</p>
<p>0x00：禁用</p>
<p>0x01：启用</p>
<p>0xFF：UNKNOWN</p></td>
<td>0x01：即启用</td>
</tr>
<tr>
<td>byte[28]</td>
<td><p>JBOD模式</p>
<p>0x00：禁用</p>
<p>0x01：启用</p>
<p>0xFF：UNKNOWN</p></td>
<td>0x00，即禁用</td>
</tr>
<tr>
<td>byte[29]</td>
<td><p>标记为MIN，支持的最小条带大小为2^(MIN-1) KB</p>
<p>0xFF：UNKNOWN</p></td>
<td>0x07，即2^(7-1) KB = 64KB</td>
</tr>
<tr>
<td>byte[30]</td>
<td><p>标记为MAX，支持的最大条带大小为2^(MAX-1) KB</p>
<p>0xFF：UNKNOWN</p></td>
<td>0x0b，即2^(11-1)KB = 1024KB = 1MB</td>
</tr>
<tr>
<td>byte[31]~byte[35]</td>
<td>预留，无含义</td>
<td></td>
</tr>
<tr>
<td>byte[36]</td>
<td>RAID控制器名称长度，标记为L</td>
<td>0x07</td>
</tr>
<tr>
<td>byte[37]~byte[L+36]</td>
<td>RAID控制器名称，如果L为0，则无这一段数据</td>
<td>SAS3508</td>
</tr>
</tbody>
</table>

## 获取指定RAID控制器firmware版本

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x3d 0x00 0x01 0x01 0x00 0x00 0x00 0x00 0xF0

0x01： 表示RAID控制器ID，从0开始计数

0xF0： 表示读取字节长度

### 【响应示例】

第一帧命令

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x3d 0x00 0x01 0x00 <span class="mark">0xff 0x</span>ff 0x00 0x00 0xF0

第一帧响应

db 07 00 00 0d 35 2e 30 36 30 2e 30 30 2d 32 32

36 32

### 【响应格式】

| 字节                  | 含义                      | 示例          |
|-----------------------|---------------------------|---------------|
| byte\[0\]~byte\[2\]   | 获取成功时固定为db 07 00  |               |
| byte\[3\]             | 获取成功时固定为00        |               |
| byte\[4\]             | Firmware版本长度，标记为L | 0x0d          |
| byte\[5\]~byte\[L+4\] | Firmware版本              | 5.060.00-2262 |

## 获取指定RAID控制器类型

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x36 0x4e 0x00 0x01 0xff 0x00 0x00 0x01 0x00 0x79 0x01 0x01 0x03 0x00

0x01： 表示RAID控制器ID，从0开始计数

### 【响应示例】

db 07 00 00 03 00 73 0b 4c 53 49 20 53 41 53 33

35 30 38

### 【响应格式】

| 字节                  | 含义                        | 示例        |
|-----------------------|-----------------------------|-------------|
| byte\[0\]~byte\[2\]   | 获取成功时固定为db 07 00    |             |
| byte\[3\]~byte\[6\]   | 获取成功时固定为00 03 00 73 |             |
| byte\[7\]             | RAID控制器类型长度，标记为L | 0x0b        |
| byte\[8\]~byte\[L+7\] | RAID控制器类型              | LSI SAS3508 |

## 获取指定RAID控制器管理的物理盘ID列表

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x3d 0x00 0x08 0x01 0x00 0x00 0x00 0x00 0xF0

0x01： 表示RAID控制器ID，从0开始计数，0xFF表示获取所有RAID控制器管理的所有物理盘ID列表

0xF0： 表示读取字节长度

### 【响应示例】

ipmitool raw 0x30 0x93 0xdb 0x07 0x00 0x3d 0x00 0x08 0x00 <span class="mark">0xff 0xff</span> 0x00 0x00 0xF0

db 07 00 00 00 01 02 03 05 06 07

### 【响应格式】

| 字节 | 含义 | 示例 |
|----|----|----|
| byte\[0\]~byte\[2\] | 获取成功时固定为db 07 00 |  |
| byte\[3\] | 获取成功时固定为00 |  |
| byte\[4\]~结束 | 获取到的物理盘ID列表 | 00 01 02 03 05 06 07，8个硬盘，ID分别为0,1,2,3,4,5,6,7 |

## 查询硬盘详细信息

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x3d 0x00 0x0A 0x00 0x01 0x00 0x00 0x00 0xF0

0x01： 表示硬盘槽位号，从0开始计数

0x00 0x00： 表示offset偏移

0xF0： 表示读取字节长度

### 【响应示例】

ipmitool raw 0x30 0x93 0xdb 0x07 0x00 0x3d 0x00 0x0A <span class="mark">0xff</span> 0x01 <span class="mark">0xff</span> 0x00 0x00 0xF0

第一帧命令

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x3d 0x00 0x0A 0x00 0x01 0x00 0x00 0x00 0xF0

第一帧响应

db 07 00 00 07 54 4f 53 48 49 42 41 0c 59 36 4e

30 41 30 56 34 46 34 53 44 0b 41 4c 31 34 53 45

42 30 36 30 4e 04 30 38 30 35 00 06 00 00 02 04

04 1f 72 b7 08 00 00 00 00 00 00 00 00 00 00 00

00 ff 00 00 00 00 00 00 00 00 00 00 00 00 00 dd

25

### 【响应格式】

<table>
<colgroup>
<col style="width: 36%" />
<col style="width: 33%" />
<col style="width: 30%" />
</colgroup>
<thead>
<tr>
<th>字节</th>
<th>含义</th>
<th>示例</th>
</tr>
</thead>
<tbody>
<tr>
<td>byte[0]~byte[2]</td>
<td>获取成功时固定为db 07 00</td>
<td></td>
</tr>
<tr>
<td>byte[3]</td>
<td><p>0x00：信息已全部获取</p>
<p>0x01：表示信息尚未全部获取需要下一帧继续查询</p></td>
<td></td>
</tr>
<tr>
<td>byte[4]</td>
<td>硬盘厂商名称长度，标记为L1</td>
<td>0x07</td>
</tr>
<tr>
<td>byte[5]~byte[L1+4]</td>
<td>硬盘厂商名称</td>
<td>TOSHIBA</td>
</tr>
<tr>
<td>byte[L1+5]</td>
<td>硬盘序列号长度，标记为L2</td>
<td>0x0c</td>
</tr>
<tr>
<td>byte[L1+6]~byte[L1+L2+5]</td>
<td>硬盘序列号</td>
<td>Y6N0A0V4F4SD</td>
</tr>
<tr>
<td>byte[L1+L2+6]</td>
<td>硬盘型号长度</td>
<td>0x0b</td>
</tr>
<tr>
<td>byte[L1+L2+7]~byte[L1+L2+L3+6]</td>
<td>硬盘型号</td>
<td>AL14SEB060N</td>
</tr>
<tr>
<td>byte[L1+L2+L3+7]</td>
<td>硬盘firmware版本长度</td>
<td>0x04</td>
</tr>
<tr>
<td><p>byte[L1+L2+L3+8]~</p>
<p>byte[L1+L2+L3+L4+7]</p></td>
<td>硬盘firmware版本</td>
<td>0805</td>
</tr>
<tr>
<td>byte[L1+L2+L3+L4+8]</td>
<td><p>硬盘健康状态</p>
<p>0x00：正常</p>
<p>0x01：轻微告警</p>
<p>0x02：严重告警</p>
<p>0x03：致命告警</p>
<p>0xFF：UNKNOWN</p></td>
<td>0x00，即正常</td>
</tr>
<tr>
<td>byte[L1+L2+L3+L4+9]</td>
<td><p>硬盘运行状态</p>
<p>0x00：UNCONFIGURED GOOD</p>
<p>0x01：UNCONFIGURED BAD</p>
<p>0x02：HOT SPARE</p>
<p>0x03：OFFLINE</p>
<p>0x04：FAILED</p>
<p>0x05：REBUILD</p>
<p>0x06：ONLINE</p>
<p>0x07：COPYBACK</p>
<p>0x08：JBOD</p>
<p>0x09：</p>
<p>UNCONFIGURED (Shielded)</p>
<p>0x0A:HOT SPARE (Shielded)</p>
<p>0x0B： CONFIGURED (Shielded)</p>
<p>0x0C：FOREIGN</p>
<p>0x0D：Active：</p>
<p>0x0E：Stand-by</p>
<p>0x0F：Sleep</p>
<p>0x10：</p>
<p>DST executing in background</p>
<p>0x11：</p>
<p>SMART Off-line Data Collection executing in background</p>
<p>0x12：</p>
<p>SCT command executing in background</p>
<p>0xFF表示UNKNOWN</p></td>
<td>0x06，即ONLINE</td>
</tr>
<tr>
<td>byte[L1+L2+L3+L4+10]</td>
<td><p>电源状态：</p>
<p>0x00：Spun Up</p>
<p>0x01：Spun Down</p>
<p>0x02：Spun Transition</p>
<p>0xFF表示UNKNOWN</p></td>
<td>0x00，即Spun Up</td>
</tr>
<tr>
<td>byte[L1+L2+L3+L4+11]</td>
<td><p>介质类型</p>
<p>0x00：HDD</p>
<p>0x01：SSD</p>
<p>0x02：SSM</p>
<p>0xFF表示UNKNOWN</p></td>
<td>0x00，即HDD</td>
</tr>
<tr>
<td>byte[L1+L2+L3+L4+12]</td>
<td><p>接口类型</p>
<p>0x00：UNKNOWN</p>
<p>0x01：Parallel SCSI</p>
<p>0x02：SAS</p>
<p>0x03：SATA</p>
<p>0x04：Fiber Channel</p>
<p>0x05：SATA/SAS</p>
<p>0x06：PCIe</p></td>
<td>0x02，即SAS</td>
</tr>
<tr>
<td>byte[L1+L2+L3+L4+13]</td>
<td><p>硬盘支持的最大速率</p>
<p>0x01：1.5 Gpbs</p>
<p>0x02：3.0 Gpbs</p>
<p>0x03：6.0 Gpbs</p>
<p>0x04：12.0 Gpbs</p>
<p>0x05：2.5 Gpbs</p>
<p>0x06：5.0 Gpbs</p>
<p>0x07：8.0 Gpbs</p>
<p>0x08：10.0 Gpbs</p>
<p>0x09：16.0 Gpbs</p>
<p>0x0A：20.0 Gpbs</p>
<p>0x0B：30.0 Gpbs</p>
<p>0x0C：32.0 Gpbs</p>
<p>0x0D：40.0 Gpbs</p>
<p>0x0E：64.0 Gpbs</p>
<p>0x0F：80.0 Gpbs</p>
<p>0x10：96.0 Gpbs</p>
<p>0x11：128.0 Gpbs</p>
<p>0x12：160.0 Gpbs</p>
<p>0x13：256.0 Gpbs</p>
<p>0xFF：UNKNOWN</p></td>
<td>0x04，即12.0 Gpbs</td>
</tr>
<tr>
<td>byte[L1+L2+L3+L4+14]</td>
<td><p>硬盘协商速率</p>
<p>0x01：1.5 Gpbs</p>
<p>0x02：3.0 Gpbs</p>
<p>0x03：6.0 Gpbs</p>
<p>0x04：12.0 Gpbs</p>
<p>0x05：2.5 Gpbs</p>
<p>0x06：5.0 Gpbs</p>
<p>0x07：8.0 Gpbs</p>
<p>0x08：10.0 Gpbs</p>
<p>0x09：16.0 Gpbs</p>
<p>0x0A：20.0 Gpbs</p>
<p>0x0B：30.0 Gpbs</p>
<p>0x0C：32.0 Gpbs</p>
<p>0x0D：40.0 Gpbs</p>
<p>0x0E：64.0 Gpbs</p>
<p>0x0F：80.0 Gpbs</p>
<p>0x10：96.0 Gpbs</p>
<p>0x11：128.0 Gpbs</p>
<p>0x12：160.0 Gpbs</p>
<p>0x13：256.0 Gpbs</p>
<p>0xFF：UNKNOWN</p></td>
<td>0x04，即12.0 Gpbs</td>
</tr>
<tr>
<td>byte[L1+L2+L3+L4+15]</td>
<td><p>硬盘温度，单位摄氏度</p>
<p>0xFF：UNKNOWN</p></td>
<td>0x1f，即31°C</td>
</tr>
<tr>
<td><p>byte[L1+L2+L3+L4+16]~</p>
<p>byte[L1+L2+L3+L4+19]</p></td>
<td><p>硬盘容量，单位MB，小端序</p>
<p>0xFF 0xFF 0xFF 0xFF：UNKNOWN</p></td>
<td>0x72 0xb7 0x08 0x00，即0x0008b772，即571250MB</td>
</tr>
<tr>
<td><p>byte[L1+L2+L3+L4+20]~</p>
<p>byte[L1+L2+L3+L4+23]</p></td>
<td>预留，无含义</td>
<td></td>
</tr>
<tr>
<td>byte[L1+L2+L3+L4+24]</td>
<td><p>热备类型</p>
<p>0x00：NONE</p>
<p>0x01：GLOBAL</p>
<p>0x02：DEDICATED</p>
<p>0x03：COMMISSIONED</p>
<p>0x04：EMERGENCY</p>
<p>0xFF：UNKNOWN</p></td>
<td>0x00，即NONE</td>
</tr>
<tr>
<td>byte[L1+L2+L3+L4+25]</td>
<td><p>重构状态</p>
<p>0x00：重构已停止或已结束</p>
<p>0x01：正在重构</p>
<p>0xFF：UNKNOWN</p></td>
<td>0x00，即重构已停止或已结束</td>
</tr>
<tr>
<td>byte[L1+L2+L3+L4+26]</td>
<td><p>重构进度，百分比数值</p>
<p>0xFF：UNKNOWN</p></td>
<td>0x00，即进度0%</td>
</tr>
<tr>
<td>byte[L1+L2+L3+L4+27]</td>
<td><p>巡检状态</p>
<p>0x00：巡检已停止或已结束</p>
<p>0x01：正在巡检</p>
<p>0xFF：UNKNOWN</p></td>
<td>0x00，即巡检已停止或已结束</td>
</tr>
<tr>
<td><p>byte[L1+L2+L3+L4+28]~</p>
<p>byte[L1+L2+L3+L4+30]</p></td>
<td>预留，无含义</td>
<td></td>
</tr>
<tr>
<td>byte[L1+L2+L3+L4+31]</td>
<td><p>SSD硬盘剩余磨损率，百分比数值，HDD硬盘固1定为0xFF</p>
<p>0xFF：UNKNOWN</p></td>
<td>0xFF，UNKNOWN</td>
</tr>
<tr>
<td><p>byte[L1+L2+L3+L4+32]~</p>
<p>byte[L1+L2+L3+L4+35]</p></td>
<td><p>媒介类型错误统计，小端序</p>
<p>0xFF 0xFF 0xFF 0xFF：UNKNOWN</p></td>
<td>0x00 0x00 0x00 0x00，即0个</td>
</tr>
<tr>
<td><p>byte[L1+L2+L3+L4+36]~</p>
<p>byte[L1+L2+L3+L4+39]</p></td>
<td><p>prefail错误统计，小端序</p>
<p>0xFF 0xFF 0xFF 0xFF：UNKNOWN</p></td>
<td>0x00 0x00 0x00 0x00，即0个</td>
</tr>
<tr>
<td><p>byte[L1+L2+L3+L4+40]~</p>
<p>byte[L1+L2+L3+L4+43]</p></td>
<td><p>其它错误统计，小端序</p>
<p>0xFF 0xFF 0xFF 0xFF：UNKNOWN</p></td>
<td>0x00 0x00 0x00 0x00，即0个</td>
</tr>
<tr>
<td>byte[L1+L2+L3+L4+44]</td>
<td><p>定位状态</p>
<p>0x00：定位关闭</p>
<p>0x01：定位开启</p>
<p>0xFF：UNKNOWN</p></td>
<td>0x00，即定位关闭</td>
</tr>
<tr>
<td><p>byte[L1+L2+L3+L4+45]~</p>
<p>byte[L1+L2+L3+L4+46]</p></td>
<td>通电时长，单位小时，小端序</td>
<td>0xdd 0x25，即0x25dd，即9693小时</td>
</tr>
</tbody>
</table>

## 获取板载网卡厂商

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x36 0x1f 0x00 0x01 0xff 0x00 0x00 0x01 0x00 0x73 0x03 0x4c 0x4f 0x4d 0x02 0x00

### 【响应示例】

db 07 00 00 02 00 73 06 48 75 61 77 65 69

### 【响应格式】

| 字节                  | 含义                        | 示例   |
|-----------------------|-----------------------------|--------|
| byte\[0\]~byte\[2\]   | 获取成功时固定为db 07 00    |        |
| byte\[3\]~byte\[6\]   | 获取成功时固定为00 03 00 73 |        |
| byte\[7\]             | 板载网卡厂商长度，标记为L   | 0x06   |
| byte\[8\]~byte\[L+7\] | 板载网卡厂商                | Huawei |

## 获取板载网口MAC地址

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x90 0x01 0x00 0x01

0x01： 表示板载网口槽位号，从1开始计数

### 【响应示例】

00 01 01 9c 7d a3 1a 3d 61

### 【响应格式】

<table>
<colgroup>
<col style="width: 35%" />
<col style="width: 32%" />
<col style="width: 31%" />
</colgroup>
<thead>
<tr>
<th>字节</th>
<th>含义</th>
<th>示例</th>
</tr>
</thead>
<tbody>
<tr>
<td>byte[0]</td>
<td>获取成功时固定为00</td>
<td></td>
</tr>
<tr>
<td>byte[1]</td>
<td>板载网口槽位号</td>
<td></td>
</tr>
<tr>
<td>byte[2]</td>
<td>获取成功时固定为01</td>
<td></td>
</tr>
<tr>
<td>byte[3]~byte[8]</td>
<td><p>板载网口MAC地址。</p>
<p>如果没有byte[3]~byte[8]，表示该槽位号的板载网口不存在</p></td>
<td>9C:7D:A3:1A:3D:61</td>
</tr>
</tbody>
</table>

## 获取电源个数及槽位号（只适用于机架服务器）

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x38 0x27 0x00 0x01 0xff 0x00 0x00 0x01 0x00

### 【响应示例】

db 07 00 00 01 00 79 01 01 01 00 79 01 02 01 00

79 01 04

### 【响应格式】

<table>
<colgroup>
<col style="width: 35%" />
<col style="width: 32%" />
<col style="width: 31%" />
</colgroup>
<thead>
<tr>
<th>字节</th>
<th>含义</th>
<th>示例</th>
</tr>
</thead>
<tbody>
<tr>
<td>byte[0]~byte[2]</td>
<td>获取成功时固定为db 07 00</td>
<td></td>
</tr>
<tr>
<td>byte[3]</td>
<td>获取成功时固定为00</td>
<td></td>
</tr>
<tr>
<td>byte[4]~byte[8]</td>
<td><p>第一个电源</p>
<p>byte[4]~byte[7]固定为01 00 79 01，byte[8]表示第一个电源槽位号</p></td>
<td>第一个电源槽位号为0x01</td>
</tr>
<tr>
<td>byte[9]~byte[13]</td>
<td><p>第二个电源（如果有）</p>
<p>byte[9]~byte[12]固定为01 00 79 01，byte[13]表示第二个电源槽位号</p></td>
<td>第二个电源槽位号为0x02</td>
</tr>
<tr>
<td>byte[14]~byte[18]</td>
<td><p>第三个电源（如果有）</p>
<p>byte[14]~byte[17]固定为01 00 79 01，byte[18]表示第三个电源槽位号</p></td>
<td>第三个电源槽位号为0x04</td>
</tr>
<tr>
<td>byte[19]~byte[23]</td>
<td><p>第四个电源（如果有）</p>
<p>byte[19]~byte[22]固定为01 00 79 01，byte[23]表示第四个电源槽位号</p></td>
<td>无第四个电源</td>
</tr>
</tbody>
</table>

## 获取电源厂商（只适用于机架服务器）

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xDB 0x07 0x00 0x1E 0x01 0x01 0x00 0xF0

0x01： 表示电源槽位号

### 【响应示例】

db 07 00 00 48 55 41 57 45 49 00

### 【响应格式】

| 字节                | 含义                     | 示例   |
|---------------------|--------------------------|--------|
| byte\[0\]~byte\[2\] | 获取成功时固定为db 07 00 |        |
| byte\[3\]           | 获取成功时固定为00       |        |
| byte\[4\]~00字节    | 电源厂商                 | HUAWEI |

## 获取电源类型（只适用于机架服务器）

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xDB 0x07 0x00 0x1E 0x01 0x03 0x00 0xF0

0x01： 表示电源槽位号

### 【响应示例】

db 07 00 00 50 41 43 31 35 30 30 53 31 32 2d 42

45 00

### 【响应格式】

| 字节                | 含义                     | 示例          |
|---------------------|--------------------------|---------------|
| byte\[0\]~byte\[2\] | 获取成功时固定为db 07 00 |               |
| byte\[3\]           | 获取成功时固定为00       |               |
| byte\[4\]~00字节    | 电源类型                 | PAC1500S12-BE |

## 获取电源固件版本（只适用于机架服务器）

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xDB 0x07 0x00 0x1E 0x01 0x04 0x00 0xF0

0x01： 表示电源槽位号

### 【响应示例】

db 07 00 00 44 43 3a 31 30 39 20 50 46 43 3a 31

30 39 00

### 【响应格式】

| 字节                | 含义                     | 示例           |
|---------------------|--------------------------|----------------|
| byte\[0\]~byte\[2\] | 获取成功时固定为db 07 00 |                |
| byte\[3\]           | 获取成功时固定为00       |                |
| byte\[4\]~00字节    | 电源固件版本             | DC:109 PFC:109 |

## 获取电源SN（只适用于机架服务器）

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xDB 0x07 0x00 0x1E 0x01 0x0c 0x00 0xF0

0x01： 表示电源槽位号

### 【响应示例】

db 07 00 00 32 31 30 32 33 31 32 44 41 45 57 30

4b 31 30 30 30 31 38 31 00

### 【响应格式】

| 字节                | 含义                     | 示例                 |
|---------------------|--------------------------|----------------------|
| byte\[0\]~byte\[2\] | 获取成功时固定为db 07 00 |                      |
| byte\[3\]           | 获取成功时固定为00       |                      |
| byte\[4\]~00字节    | 电源SN                   | 2102312DAEW0K1000181 |

## 获取电源额定功率（只适用于机架服务器）

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xDB 0x07 0x00 0x1E 0x01 0x06 0x00 0xF0

0x01： 表示电源槽位号

### 【响应示例】

db 07 00 00 dc 05

### 【响应格式】

| 字节 | 含义 | 示例 |
|----|----|----|
| byte\[0\]~byte\[2\] | 获取成功时固定为db 07 00 |  |
| byte\[3\] | 获取成功时固定为00 |  |
| byte\[4\]~byte\[5\] | 电源额定功率，单位W，小端序 | 0xdc 0x05，即0x05dc，即1500W |

## 获取电源温度（只适用于机架服务器）

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xDB 0x07 0x00 0x1E 0x01 0x0d 0x00 0xF0

0x01： 表示电源槽位号

### 【响应示例】

db 07 00 00 00 00 00 00 00 80 43 40

### 【响应格式】

| 字节 | 含义 | 示例 |
|----|----|----|
| byte\[0\]~byte\[2\] | 获取成功时固定为db 07 00 |  |
| byte\[3\] | 获取成功时固定为00 |  |
| byte\[4\]~byte\[11\] | 电源温度，单位摄氏度，小端序，double类型在内存中的64bit表示 | 00 00 00 00 00 80 43 40，即0x4043800000000000，即39°C |

## 获取风扇型号（只适用于机架服务器）

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x36 0x26 0x00 0x01 0xff 0x00 0x00 0x09 0x00 0x79 0x01 0x01 0x04 0x00

0x01： 表示风扇槽位号

### 【响应示例】

db 07 00 00 04 00 73 0e 30 32 33 31 32 42 41 45

20 38 30 33 38 2b

### 【响应格式】

| 字节                  | 含义                        | 示例           |
|-----------------------|-----------------------------|----------------|
| byte\[0\]~byte\[2\]   | 获取成功时固定为db 07 00    |                |
| byte\[3\]~byte\[6\]   | 获取成功时固定为00 04 00 73 |                |
| byte\[7\]             | 风扇型号长度，标记为L       | 0x0e           |
| byte\[8\]~byte\[L+7\] | 风扇型号                    | 02312BAE 8038+ |

## 获取风扇转速比（只适用于机架服务器）

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x93 0xdb 0x07 0x00 0x36 0x26 0x00 0x01 0xff 0x00 0x00 0x09 0x00 0x79 0x01 0x01 0x07 0x00

0x01： 表示风扇槽位号

### 【响应示例】

db 07 00 00 07 00 79 01 30

### 【响应格式】

| 字节                | 含义                           | 示例        |
|---------------------|--------------------------------|-------------|
| byte\[0\]~byte\[2\] | 获取成功时固定为db 07 00       |             |
| byte\[3\]~byte\[7\] | 获取成功时固定为00 07 00 79 01 |             |
| byte\[8\]           | 风扇转速比                     | 0x30，即48% |

## 获取固件版本

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U UserName -P Password raw 0x30 0x90 0x08 0x00 0x01 0x00 0x0f

0x00：表示FRU Device ID，默认00

0x01 ：表示读取BMC版本

<sup>\###</sup>

0x00：PCB版本

0x02：CPLD版本

0x03：FPGA版本

0x04：FRU data版本

0x05：SDR版本

0x06：BIOS固件版本

0x07：硬件版本

0x08：bootloader/uboot/bootrom版本

0x09：hpm镜像版本

0x0a：USB闪存设备固件版本

0x0b：其他固件版本（如852T扣卡）

0x0c：备区BMC版本

0x0d：SYS CPLD（OSCA SPU板使用）

0x0e：电容管理器固件版本（OSCA SOD使用）

0x0f：MMC版本

0x10：备区bootloader/uboot/bootrom版本

0x11：SWITCH1固件版本

0x12：SWITCH2固件版本

<sup>\###</sup>

0x00：偏移量，默认00

0x0f：读取信息长度为15字节

### 【响应示例】

80 36 2e 33 32

### 【响应格式】

<table>
<colgroup>
<col style="width: 35%" />
<col style="width: 32%" />
<col style="width: 31%" />
</colgroup>
<thead>
<tr>
<th>字节</th>
<th>含义</th>
<th>示例</th>
</tr>
</thead>
<tbody>
<tr>
<td>byte[0]</td>
<td><p>End of List，表示当前数据是否结束。</p>
<p>说明</p>
<p>当版本数据比较长的时候，可能需要分多次读取，通过此字段可以判断数据是否读完。</p>
<p>[7]: End of list</p>
<p>1 = last data</p>
<p>0 = middle data</p>
<p>[6:0]: reserved</p></td>
<td><p>80，即第7字节为1，表示读取结束；</p>
<p>00，即第7字节为0，表示未读取结束，需要增加读取长度。</p></td>
</tr>
<tr>
<td>byte[1]~byte[N]</td>
<td><p>Data，实际返回的数据可能小于等于Read length</p>
<p>说明</p>
<p>当指定的FRU ID和Version Type有多个实例时，返回的数据中包含全部实例的版本信息，以分号分隔。</p></td>
<td>36 2e 33 32，表示6.32</td>
</tr>
</tbody>
</table>

## 获取机框电子标签信息

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U *UserName* -P *Password* raw 0x30 0x90 0x05 0x00 0x01 0x02 0x00 0x1f

0x00：表示FRU Device ID，默认00

0x01 ：表示机框

0x02：获取机框序列号(Chassis Serial Number)

<sup>\###</sup>

0x00：获取机框类型

0x01：获取机框部件编码(Chassis Part Number)

<sup>\###</sup>

0x00：偏移量，默认00

0x0f：读取信息长度为31字节

### 【响应示例】

80

### 【响应格式】

<table>
<colgroup>
<col style="width: 35%" />
<col style="width: 32%" />
<col style="width: 31%" />
</colgroup>
<thead>
<tr>
<th>字节</th>
<th>含义</th>
<th>示例</th>
</tr>
</thead>
<tbody>
<tr>
<td>byte[0]</td>
<td><p>End of List，表示当前数据是否结束。</p>
<p>说明</p>
<p>当版本数据比较长的时候，可能需要分多次读取，通过此字段可以判断数据是否读完。</p>
<p>[7]: End of list</p>
<p>1 = last data</p>
<p>0 = middle data</p>
<p>[6:0]: reserved</p></td>
<td><p>80，即第7字节为1，表示读取结束；</p>
<p>00，即第7字节为0，表示未读取结束，需要增加读取长度。</p></td>
</tr>
<tr>
<td>byte[1]~byte[N]</td>
<td>Data，实际返回的数据可能小于等于Read length</td>
<td>返回空表示无此信息（部分机器）。</td>
</tr>
</tbody>
</table>

## 设置单板电子标签信息

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U *UserName* -P *Password* raw 0x30 0x90 0x04 0x00 0x02 0x02 0x00 0x07 0x32 0x32 0x38 0x38 0x68 0x76 0x35

0x00：表示FRU Device ID，默认00

0x02 ：表示单板

0x03：获取单板名称(Board Product Name)

<sup>\###</sup>

0x00：获取单板生产日期和时间

0x01：获取单板生产商

0x02：获取单板名称

0x04：获取单板物料编码

0x05：获取FRU File ID

<sup>\###</sup>

0x00：偏移量，默认00

0x07：写入信息长度为7字节

0x32 0x32 0x38 0x38 0x68 0x76 0x35：写入的数据"2288hv5"

### 【响应示例】

00

### 【响应格式】

| 字节      | 含义     | 示例 |
|-----------|----------|------|
| byte\[0\] | 完成码。 |      |

## 获取单板电子标签信息

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U *UserName* -P *Password* raw 0x30 0x90 0x05 0x00 0x02 0x03 0x00 0x1f

0x00：表示FRU Device ID，默认00

0x02 ：表示单板

0x03：获取单板序列号(Board Serial Number)

<sup>\###</sup>

0x00：获取单板生产日期和时间

0x01：获取单板生产商

0x02：获取单板名称

0x04：获取单板物料编码

0x05：获取FRU File ID

<sup>\###</sup>

0x00：偏移量，默认00

0x0f：读取信息长度为31字节

### 【响应示例】

80 30 33 33 45 46 54 31 30 4b 36 30 30 30 36 32 30 31

### 【响应格式】

<table>
<colgroup>
<col style="width: 35%" />
<col style="width: 32%" />
<col style="width: 31%" />
</colgroup>
<thead>
<tr>
<th>字节</th>
<th>含义</th>
<th>示例</th>
</tr>
</thead>
<tbody>
<tr>
<td>byte[0]</td>
<td><p>End of List，表示当前数据是否结束。</p>
<p>说明</p>
<p>当版本数据比较长的时候，可能需要分多次读取，通过此字段可以判断数据是否读完。</p>
<p>[7]: End of list</p>
<p>1 = last data</p>
<p>0 = middle data</p>
<p>[6:0]: reserved</p></td>
<td><p>80，即第7字节为1，表示读取结束；</p>
<p>00，即第7字节为0，表示未读取结束，需要增加读取长度。</p></td>
</tr>
<tr>
<td>byte[1]~byte[N]</td>
<td>Data，实际返回的数据可能小于等于Read length</td>
<td>30 33 33 45 46 54 31 30 4b 36 30 30 30 36 32 30 31，即序列号为033EFT10K60006201</td>
</tr>
</tbody>
</table>

## 获取SEL时间

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U *UserName* -P *Password* raw 0xa 0x48

### 【响应示例】

9f 7f 6d 61

### 【响应格式】

| 字节 | 含义 | 示例 |
|----|----|----|
| byte\[0\]~ byte\[3\] | 当前时间戳 | 9f 7f 6d 61**，时间戳为1634566047（16进制61 6d 7f 9f）秒，即2021-10-18 22:07:27** |

## 获取系统重启原因

### 【命令格式】

ipmitool -I lanplus -H xxx.xxx.xxx.xxx -U *UserName* -P *Password* raw 0x00 0x07

### 【响应示例】

00 00

### 【响应格式】

<table>
<colgroup>
<col style="width: 35%" />
<col style="width: 32%" />
<col style="width: 31%" />
</colgroup>
<thead>
<tr>
<th>字节</th>
<th>含义</th>
<th>示例</th>
</tr>
</thead>
<tbody>
<tr>
<td>byte[0]</td>
<td>完成码。</td>
<td></td>
</tr>
<tr>
<td>byte[1]</td>
<td>重启原因</td>
<td><p>重启原因</p>
<p>[7:4] - 保留</p>
<p>[3:0] - 0h = 未知原因重启 (检测到重启但原因未知)</p>
<p>1h = 命令重启</p>
<p>2h = 按压电源按钮重启</p>
<p>3h = 按压电源按钮启动</p>
<p>4h = 看门狗超时重启</p>
<p>5h = OEM</p>
<p>6h = automatic power-up on AC being applied due to 'always restore' power restore policy (see 28.8, Set Power Restore Policy Command) [optional]</p>
<p>7h = automatic power-up on AC being applied due to 'restore previous</p>
<p>power state' power restore policy (see 28.8, Set Power Restore Policy Command) [optional]</p>
<p>8h = reset via PEF [required if PEF reset supported]</p>
<p>9h = power-cycle via PEF [required if PEF power-cycle supported]</p>
<p>Ah = soft reset (e.g. CTRL-ALT-DEL) [optional]</p>
<p>Bh = power-up via RTC (system real time clock) wakeup [optional]</p>
<p>all other = reserved</p></td>
</tr>
</tbody>
</table>
