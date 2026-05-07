测试下电拔盘后是否会产生告警

1.  给服务器上电，逐个把硬盘硬盘插入服务器至服务器满配，登陆BMC Web管理界面查看硬盘状态，预期结果A

    <img src="media/image1.png" style="width:5.76181in;height:2.875in" alt="ee040a56bf8e29ea5d89d90f5c102764" />

    Bmc下查看健康状态都为正常、系统下查看 也为正常

    <img src="media/image2.png" style="width:5.76389in;height:2.24028in" alt="7cc966cf5c41ba95a3539240b454661f" />

2.  创建两盘RAID1，BIOS Mode设置为ignore error。

    创建RAID1:

    <img src="media/image3.png" style="width:5.7625in;height:4.00694in" alt="85307160001754a099c23e12c27b7e82" />

3、服务器下电后拔出RAID1中的一个硬盘，然后上电。BMC web检查是否有硬盘和RAID组告警。

BMC定位raid1的俩个盘

<img src="media/image4.png" style="width:5.76181in;height:1.76458in" alt="c4f5f35db28e6b3d7d53043d3f12d887" />

<img src="media/image5.jpeg" style="width:5.75972in;height:1.98819in" alt="881c843cabbe0061bd523dc3d44fd023" />

拔掉disk9、BMC有告警

<img src="media/image6.png" style="width:5.76458in;height:0.28403in" alt="b8f81e08570e1fac37c8bed2140c01b5" /><img src="media/image7.png" style="width:5.75764in;height:1.06944in" alt="ad0715ad68c3aa1777f68473193ab3eb" />

再看raid1状态只有一张盘

<img src="media/image8.png" style="width:5.75417in;height:1.99375in" alt="8bf9c3ece0a3633f877aca4f6bd1e669" />

再插回disk9后查看raid1恢复两个盘

<img src="media/image9.png" style="width:5.75833in;height:2.47431in" alt="b249735f3d0a5941941a6473d52fdd38" />

<span class="mark">预期结果A: 硬盘插入之后，BMC Web管理界面下硬盘状态为“正常”</span>

<span class="mark">预期结果B：BMC web有硬盘告警。PASS</span>
