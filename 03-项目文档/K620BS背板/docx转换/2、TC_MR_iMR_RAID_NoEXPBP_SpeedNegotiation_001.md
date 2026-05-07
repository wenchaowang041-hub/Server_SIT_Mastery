1.  服务器启动，进入系统，安装好RAID卡驱动和hiraidadm工具。将除系统盘外的所有硬盘设置为Ugood状态，<span class="mark">清除termlog：我找到清除termlog的指令</span>

    <img src="media/image1.png" style="width:5.76389in;height:3.04514in" alt="d28694f5e538d45fe20aa31550bc3704" />

    <img src="media/image2.png" style="width:5.7625in;height:3.07083in" alt="9e45d8db7ea760a9642a21de28a9db72" />

    查询指定控制卡下所有物理盘列表信息./hiraidadm c0 show pdlist

    <img src="media/image3.png" style="width:5.76181in;height:5.66458in" alt="a1201829a41aebf34cabd4bef65b80b1" />

2、查询RAID卡各个phy的连接速率，记录测试结果，预期结果A

看link_speed是否符合预期

<img src="media/image4.png" style="width:5.76389in;height:2.24028in" alt="6c9410919b0b548f2dc82545ec752635" />

./hiraidadm c0 show pdlist

查看linkspd符合sata接口硬盘的协商速率6GB/S

<img src="media/image5.png" style="width:5.76181in;height:1.95208in" alt="e624e18cf25a12259143eb3e9cd0fe16" />**BMC web界面下协商速率6gb/s**

<span class="mark">预期结果A:SATA接口硬盘，速率协商至6Gb/s，BMC Web界面对应硬盘的协商速率显示6.OGbps PASS</span>

SAS接口硬盘，速率协商至12Gb/s，BMC Web界面对应硬盘的协商速率显示12.Ogbps
