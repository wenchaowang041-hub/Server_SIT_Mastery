## DPU 卡测试（仅针对 PCK典配）

1.  <img src="media/image1.png" style="width:3.83424in;height:3.69299in" />**DPU** 外观、尺寸测试

<table>
<colgroup>
<col style="width: 17%" />
<col style="width: 31%" />
<col style="width: 20%" />
<col style="width: 29%" />
</colgroup>
<tbody>
<tr>
<td><blockquote>
<p>用例编号:</p>
</blockquote></td>
<td><blockquote>
<p>6.7.1</p>
</blockquote></td>
<td><blockquote>
<p>优先级:</p>
</blockquote></td>
<td><blockquote>
<p><img src="media/image2.png" />B</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>测试目的:</p>
</blockquote></td>
<td colspan="3"><blockquote>
<p>检测产品外观和尺寸是否与设计要求保持一致</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>参考组网:</p>
</blockquote></td>
<td colspan="3"><blockquote>
<p>无</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>预置条件:</p>
</blockquote></td>
<td colspan="3"><ol type="1">
<li><p>被测 DPU 卡拆除外包装</p></li>
<li><p>被测 DPU 卡外观完备、形状规整且无磨损</p></li>
</ol></td>
</tr>
<tr>
<td><blockquote>
<p>测试步骤:</p>
</blockquote></td>
<td colspan="3"><ol type="1">
<li><p>查看被测 DPU 卡接口是否符合技术规范书要求的规格</p></li>
<li><p>测量并记录被测产品的尺寸是否满足技术规范书要求</p></li>
</ol></td>
</tr>
<tr>
<td><blockquote>
<p>预期结果:</p>
</blockquote></td>
<td colspan="3"><ol type="1">
<li><p>面板接口包括规格一（4*25GE、2*10GE、1*1GE 接口、1*调试接口</p></li>
</ol>
<blockquote>
<p>（USB TypeC）、复位按键）；规格二（2*1GE + 2*100GE/200GE、 1*调试接口（USB TypeC）、复位按键）</p>
</blockquote>
<ol start="2" type="1">
<li><p>被测 DPU 卡长度不大于 170mm(从支架面板到卡尾部边缘的长度)</p></li>
</ol></td>
</tr>
<tr>
<td><blockquote>
<p>备注:</p>
</blockquote></td>
<td colspan="3"><p><img src="media/image3.png" style="width:4.70538in;height:2.28097in" /></p>
<p><img src="media/image4.png" style="width:4.70231in;height:2.34455in" /></p>
<p>物理尺寸规格：双宽 - 167.64mm(L) x 111.15mm(W) x 39mm(H)</p></td>
</tr>
</tbody>
</table>

1.  服务器上 **DPU** 卡启动测试

<table>
<colgroup>
<col style="width: 17%" />
<col style="width: 31%" />
<col style="width: 20%" />
<col style="width: 29%" />
</colgroup>
<tbody>
<tr>
<td><blockquote>
<p>用例编号:</p>
</blockquote></td>
<td><blockquote>
<p>6.7.2</p>
</blockquote></td>
<td><blockquote>
<p>优先级:</p>
</blockquote></td>
<td><blockquote>
<p>B</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>测试目的:</p>
</blockquote></td>
<td colspan="3"><blockquote>
<p>检测被测DPU卡在服务器上是否可以正常启动</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>参考组网:</p>
</blockquote></td>
<td colspan="3"><blockquote>
<p>参见图4-1</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>预置条件:</p>
</blockquote></td>
<td colspan="3"><ol type="1">
<li><p>被测 DPU 卡正常安装于服务器对应 PCIe 槽位</p></li>
<li><p>被测 DPU 卡自带的电源线缆与服务器对应的电源接口正常连接</p></li>
</ol></td>
</tr>
</tbody>
</table>

<table>
<colgroup>
<col style="width: 17%" />
<col style="width: 82%" />
</colgroup>
<tbody>
<tr>
<td><blockquote>
<p>测试步骤:</p>
</blockquote></td>
<td><ol type="1">
<li><p>被测 DPU 卡安装在服务器对应 PCIe 槽位，将供电线缆正确连接。</p></li>
<li><p>服务器插上 AC 电源线，服务器开机，查看被测 DPU 卡是否可以正常启动并进入操作系统（若被测测试设备无自带操作系统，可以现场安装）。</p></li>
</ol></td>
</tr>
<tr>
<td><blockquote>
<p>预期结果:</p>
</blockquote></td>
<td><ol type="1">
<li><p>被测 DPU 可以在服务器上正常启动并进入自带操作系统登录界面</p></li>
</ol></td>
</tr>
<tr>
<td><blockquote>
<p>预期结果:</p>
</blockquote></td>
<td><img src="media/image5.png" style="width:4.76389in;height:3.87153in" /></td>
</tr>
</tbody>
</table>

1.  <img src="media/image2.png" style="width:1.80943in;height:1.77585in" />**DPU** 卡 **FRU** 信息检查

<table>
<colgroup>
<col style="width: 17%" />
<col style="width: 31%" />
<col style="width: 20%" />
<col style="width: 29%" />
</colgroup>
<tbody>
<tr>
<td><blockquote>
<p>用例编号</p>
</blockquote></td>
<td><blockquote>
<p>6.7.3</p>
</blockquote></td>
<td><blockquote>
<p>优先级</p>
</blockquote></td>
<td><blockquote>
<p>B</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>测试目的</p>
</blockquote></td>
<td colspan="3"><blockquote>
<p>检测被测DPU卡FRU信息是否可以正常显示。显示正常且与实际一致</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p><img src="media/image1.png" />参考组网</p>
</blockquote></td>
<td colspan="3"><blockquote>
<p>参见图4-1</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>预置条件</p>
</blockquote></td>
<td colspan="3"><ol type="1">
<li><p>被测 DPU 卡正常安装于服务器对应 PCIe 槽位</p></li>
<li><p>被测 DPU 卡自带的电源线缆与服务器对应的电源接口正常连接</p></li>
</ol></td>
</tr>
<tr>
<td><blockquote>
<p>测试步骤</p>
</blockquote></td>
<td colspan="3"><ol type="1">
<li><p>记录被测 DPU 卡的信息，包括生产厂商、型号、序列号信息</p></li>
<li><p>将被测 DPU 卡安装在服务器对应 PCIe 槽位，将供电线缆正确连接</p></li>
<li><p>服务器插上 AC 电源线，等待被测 DPU 卡启动到系统，通过笔记本连接被测 DPU 卡 IPMI 接口</p></li>
<li><p>使用 ipmitool 工具执行命令： ipmitool -H BMCIP -I lanplus -U BMCuser -P BMCpassword fru 查看板卡 FRU 信息，记录生产厂商、型号、序列号信息</p></li>
</ol></td>
</tr>
<tr>
<td><blockquote>
<p>预期结果</p>
</blockquote></td>
<td colspan="3"><ol type="1">
<li><p>步骤 4 可以获取 DPU 卡 FRU 信息，包括生产厂商、型号、序列号信息</p></li>
<li><p>步骤 4 获取信息与步骤 1 拍照记录一致。</p></li>
</ol></td>
</tr>
<tr>
<td><blockquote>
<p>备注</p>
</blockquote></td>
<td colspan="3"><p><img src="media/image6.png" style="width:3.25in;height:3.125in" /></p>
<p>root@S10E316-612DR10:~# ipmitool fru list</p>
<p>FRU Device Description : Builtin FRU Device (ID 0)</p>
<p>Board Mfg Date : Fri Aug 9 15:43:00 2024 UTC</p>
<p>Board Mfg : CMCC</p>
<p>Board Product : <mark>HyperCard4-200G</mark></p>
<p>Board Serial : 02K14B624BV0007P</p>
<p>Board Part Number : 22200202</p>
<p>Product Manufacturer : CMCC</p>
<p>Product Name : HyperCard4-200G</p>
<p>Product Part Number : S10E316-612DR10</p>
<p>Product Version : 4.1</p>
<p>Product Serial : S10E31661YD2014BN00T</p>
<p>Product Extra : 84:30:CE:01:11:B4</p>
<p>Product Extra : 42</p>
<p>Product Extra : Panshi_ASIC_DPU-16-32GB-240GB</p></td>
</tr>
</tbody>
</table>

1.  **DPU** 卡规格检查

<table>
<colgroup>
<col style="width: 17%" />
<col style="width: 31%" />
<col style="width: 20%" />
<col style="width: 29%" />
</colgroup>
<tbody>
<tr>
<td><blockquote>
<p>用例编号:</p>
</blockquote></td>
<td><blockquote>
<p>6.7.4</p>
</blockquote></td>
<td><blockquote>
<p>优先级:</p>
</blockquote></td>
<td><blockquote>
<p><img src="media/image2.png" />B</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>测试目的:</p>
</blockquote></td>
<td colspan="3"><blockquote>
<p>检测被测DPU卡处理器、内存、存储规格是否与描述一致</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>参考组网:</p>
</blockquote></td>
<td colspan="3"><blockquote>
<p>参见图4-1</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>预置条件:</p>
</blockquote></td>
<td colspan="3"><ol type="1">
<li><p>被测 DPU 卡正常安装于服务器对应 PCIE 槽位</p></li>
<li><p>被测 DPU 卡自带的电源线缆与服务器对应的电源接口正常连接</p></li>
</ol></td>
</tr>
<tr>
<td><blockquote>
<p>测试步骤:</p>
</blockquote></td>
<td colspan="3"><ol type="1">
<li><p>被测 DPU 卡安装在服务器对应 PCIE 槽位，将供电线缆正确连接。</p></li>
<li><p>服务器插上 AC 电源线，等待被测 DPU 卡启动到系统，通过笔记本连接被测 DPU 卡 IPMI 接口。</p></li>
<li><p>使用 lscpu 命令查看 CPU 核心数量，使用 dmidecode 命令查看内存规格，使用 fdisk -l 命令查看硬盘容量</p></li>
</ol></td>
</tr>
<tr>
<td><blockquote>
<p>预期结果:</p>
</blockquote></td>
<td colspan="3"><ol type="1">
<li><p>被测 DPU 卡 CPU 核心数量&gt;=16；</p></li>
<li><p>内存为 DDR5，频率不低于 4800Mhz，容量&gt;=32GB</p></li>
<li><p>SATA SSD 容量&gt;=200GB</p></li>
</ol></td>
</tr>
<tr>
<td><blockquote>
<p>备注</p>
</blockquote></td>
<td colspan="3"><p><img src="media/image7.png" style="width:4.76389in;height:3.32847in" /></p>
<p><img src="media/image8.png" style="width:4.76389in;height:3.23958in" /></p>
<p><img src="media/image9.png" style="width:4.76389in;height:3.31736in" /></p>
<p><img src="media/image10.png" style="width:4.76389in;height:1.88958in" /></p></td>
</tr>
</tbody>
</table>

1.  <img src="media/image1.png" style="width:3.83424in;height:3.69299in" />**DPU** 卡温度、功耗监控

<table>
<colgroup>
<col style="width: 17%" />
<col style="width: 31%" />
<col style="width: 20%" />
<col style="width: 29%" />
</colgroup>
<tbody>
<tr>
<td><blockquote>
<p>用例编号:</p>
</blockquote></td>
<td><blockquote>
<p>6.7.5</p>
</blockquote></td>
<td><blockquote>
<p>优先级:</p>
</blockquote></td>
<td><blockquote>
<p>B</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>测试目的:</p>
</blockquote></td>
<td colspan="3"><blockquote>
<p>检测服务器是否可监控被测DPU卡温度、功耗</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>参考组网:</p>
</blockquote></td>
<td colspan="3"><blockquote>
<p>参见图4-1</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>预置条件:</p>
</blockquote></td>
<td colspan="3"><ol type="1">
<li><p>被测 DPU 卡正常安装于服务器对应 PCIE 槽位</p></li>
<li><p>被测 DPU 卡自带的电源线缆与服务器对应的电源接口正常连接</p></li>
</ol></td>
</tr>
</tbody>
</table>

<table>
<colgroup>
<col style="width: 17%" />
<col style="width: 82%" />
</colgroup>
<tbody>
<tr>
<td><blockquote>
<p>测试步骤:</p>
</blockquote></td>
<td><ol type="1">
<li><p>被测 DPU 卡安装在服务器对应 PCIE 槽位，将供电线缆正确连接。</p></li>
<li><p>服务器插上 AC 电源线，等待被测 DPU 卡启动到系统，通过笔记本连接被测 DPU 卡 BMC 接口</p></li>
<li><p>使用 ipmitool 工具执行命令： ipmitool -H BMCIP -I lanplus -U BMCuser -P BMCpassword sdr，查看设备温度、功耗信息。</p></li>
</ol></td>
</tr>
<tr>
<td><blockquote>
<p>预期结果:</p>
</blockquote></td>
<td><ol type="1">
<li><p>在步骤 3 显示的设备温度、功耗等信息需包括但不限于以下 6 点（具体温度和功耗值以现场测试为准）：</p></li>
</ol>
<blockquote>
<p><img src="media/image2.png" />P_BOARD (单板功耗） | 32 Watts | ok</p>
<p>P_DPU （DPU 芯片功耗） | 16 Watts | ok T_INLET （DPU 入风口温度） | 30 degrees C | ok T_OUTLET（DPU 出封口温度） | 32 degrees C | ok T_BOARD （DPU 单板温度） | 33 degrees C | ok</p>
<p>T_DPU （DPU 核心温度） | 34 degrees C | ok</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>备注</p>
</blockquote></td>
<td><p><img src="media/image11.png" style="width:4.76389in;height:4.43819in" /></p>
<p><img src="media/image12.png" style="width:4.76389in;height:4.85139in" /></p></td>
</tr>
</tbody>
</table>

1.  **DPU** 卡虚拟镜像挂载功能测试

<table>
<colgroup>
<col style="width: 17%" />
<col style="width: 31%" />
<col style="width: 20%" />
<col style="width: 29%" />
</colgroup>
<tbody>
<tr>
<td><blockquote>
<p>用例编号:</p>
</blockquote></td>
<td><blockquote>
<p>6.7.6</p>
</blockquote></td>
<td><blockquote>
<p>优先级:</p>
</blockquote></td>
<td><blockquote>
<p>B</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>测试目的:</p>
</blockquote></td>
<td colspan="3"><blockquote>
<p>检测被测DPU卡运行的功能完备性</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>参考组网:</p>
</blockquote></td>
<td colspan="3"><blockquote>
<p>参见图4-1</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>预置条件:</p>
</blockquote></td>
<td colspan="3"><ol type="1">
<li><p>被测 DPU 卡正常安装于服务器对应 PCIE 槽位</p></li>
<li><p>被测 DPU 卡自带的电源线缆与服务器对应的电源接口正常连接</p></li>
</ol></td>
</tr>
<tr>
<td><blockquote>
<p>测试步骤:</p>
</blockquote></td>
<td colspan="3"><ol type="1">
<li><p>被测 DPU 卡安装在服务器对应 PCIE 槽位，将供电线缆正确连接。</p></li>
<li><p>服务器插上 AC 电源线，启动服务器。</p></li>
<li><p>通过笔记本连接被测 DPU 卡 BMC 接口，登录 DPU BMC web 界面，挂载虚拟 iso 镜像文件，打开 KVM，安装受支持的 DPU 系统。</p></li>
</ol></td>
</tr>
<tr>
<td><blockquote>
<p>预期结果:</p>
</blockquote></td>
<td colspan="3"><ol type="1">
<li><p>被测 DPU 卡可以成功安装测试系统</p></li>
</ol></td>
</tr>
</tbody>
</table>

<table>
<colgroup>
<col style="width: 17%" />
<col style="width: 82%" />
</colgroup>
<tbody>
<tr>
<td><blockquote>
<p>备注</p>
</blockquote></td>
<td><blockquote>
<p>操作系统版本为BCLinux-for-DPU-V2.0-aarch64-241010.iso（研究院统一提供）</p>
</blockquote></td>
</tr>
</tbody>
</table>

1.  <img src="media/image1.png" style="width:3.83424in;height:3.69299in" />**DPU** 卡业务固件兼容性测试

<table>
<colgroup>
<col style="width: 17%" />
<col style="width: 31%" />
<col style="width: 20%" />
<col style="width: 29%" />
</colgroup>
<tbody>
<tr>
<td><blockquote>
<p>用例编号:</p>
</blockquote></td>
<td><blockquote>
<p>6.7.7</p>
</blockquote></td>
<td><blockquote>
<p>优先级:</p>
</blockquote></td>
<td><blockquote>
<p><img src="media/image2.png" />B</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>测试目的:</p>
</blockquote></td>
<td colspan="3"><ol type="1">
<li><p>检测被测 DPU 卡与移动云业务固件兼容性</p></li>
</ol></td>
</tr>
<tr>
<td><blockquote>
<p>参考组网:</p>
</blockquote></td>
<td colspan="3"><blockquote>
<p>参见图 4-1</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>预置条件:</p>
</blockquote></td>
<td colspan="3"><ol type="1">
<li><p>被测 DPU 卡正常安装于服务器对应 PCIE 槽位</p></li>
<li><p>被测 DPU 卡自带的电源线缆与服务器对应的电源接口正常连接</p></li>
</ol></td>
</tr>
<tr>
<td><blockquote>
<p>测试步骤:</p>
</blockquote></td>
<td colspan="3"><ol type="1">
<li><p>被测 DPU 卡安装在服务器对应 PCIE 槽位，将供电线缆正确连接。</p></li>
<li><p>服务器插上 AC 电源线，启动服务器。</p></li>
<li><p>在 DPU BMC 界面烧录业务固件。</p></li>
<li><p>等待 DPU 进入操作系统。</p></li>
</ol></td>
</tr>
<tr>
<td><blockquote>
<p>预期结果:</p>
</blockquote></td>
<td colspan="3"><ol type="1">
<li><p>步骤 3 的固件可以烧录成功，无报错</p></li>
<li><p>步骤 4 中可以正常进入操作系统</p></li>
</ol>
<blockquote>
<p><img src="media/image13.png" style="width:4.76389in;height:2.10347in" /></p>
<p><img src="media/image14.png" style="width:4.76389in;height:1.70417in" /></p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>备注</p>
</blockquote></td>
<td colspan="3"><blockquote>
<p>上述业务固件包由研究院提供</p>
</blockquote></td>
</tr>
</tbody>
</table>

1.  业务软件兼容性测试

<table>
<colgroup>
<col style="width: 17%" />
<col style="width: 31%" />
<col style="width: 20%" />
<col style="width: 29%" />
</colgroup>
<tbody>
<tr>
<td><blockquote>
<p>用例编号:</p>
</blockquote></td>
<td><blockquote>
<p>6.7.8</p>
</blockquote></td>
<td><blockquote>
<p>优先级:</p>
</blockquote></td>
<td><blockquote>
<p>B</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>测试目的:</p>
</blockquote></td>
<td colspan="3"><blockquote>
<p>检测被测DPU卡与移动云业务软件兼容性</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>参考组网:</p>
</blockquote></td>
<td colspan="3"><blockquote>
<p>参见图4-1</p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>预置条件:</p>
</blockquote></td>
<td colspan="3"><ol type="1">
<li><p>被测 DPU 卡正常安装于服务器对应 PCIE 槽位</p></li>
<li><p>被测 DPU 卡自带的电源线缆与服务器对应的电源接口正常连接</p></li>
</ol></td>
</tr>
</tbody>
</table>

<table>
<colgroup>
<col style="width: 17%" />
<col style="width: 82%" />
</colgroup>
<tbody>
<tr>
<td><blockquote>
<p>测试步骤:</p>
</blockquote></td>
<td><ol type="1">
<li><p>被测 DPU 卡安装在服务器对应 PCIE 槽位，将供电线缆正确连接。</p></li>
<li><p>服务器插上 AC 电源线，启动服务器。</p></li>
<li><p>等待 DPU 进入操作系统。</p></li>
<li><p>安装业务基础软件包。</p></li>
<li><p>设置业务自启动，重启 DPU OS 后，使用如下命令查看启动状态</p>
<ol type="1">
<li><p>systemctl status libvirtd | grep "active (running)"</p></li>
<li><p>systemctl status hyper_commander | grep "active (running)"</p></li>
<li><p>systemctl status ovs | grep "active (running)"</p></li>
<li><p>systemctl status ovsdb | grep "active (running)"</p></li>
<li><p>systemctl status jmnd_agent | grep "active (running)"</p></li>
<li><p>systemctl status vhost| grep "active (running)"</p></li>
<li><p>systemctl status vdev| grep "active (running)"</p></li>
</ol></li>
</ol></td>
</tr>
<tr>
<td><blockquote>
<p>预期结果:</p>
</blockquote></td>
<td><blockquote>
<p>步骤 5 的 7 个服务均正常运行，显示 active</p>
<p><img src="media/image15.png" style="width:4.76389in;height:1.08403in" /></p>
<p><img src="media/image16.png" style="width:4.76389in;height:2.02847in" /></p>
</blockquote></td>
</tr>
<tr>
<td><blockquote>
<p>备注</p>
</blockquote></td>
<td><blockquote>
<p>上述业务软件包由研究院提供</p>
</blockquote></td>
</tr>
</tbody>
</table>
