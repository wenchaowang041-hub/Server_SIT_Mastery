测试BMC Web界面下硬盘状态标识是否按照规格实现

1.  给服务器上电，逐个把SATA硬盘插入服务器至服务器满配，登陆BMC Web管理界面查看硬盘状态，预期结果A，

    服务器上电插入10张SATA盘

    <img src="media/image1.png" style="width:5.76389in;height:2.36736in" alt="970aafece57821c42b3a82fd63072fc0" />

    <span class="mark">预期结果A: 硬盘插入之后，BMC Web管理界面下硬盘状态为“正常”pass</span>

    查看“系统事件日志”，预期结果B

    <img src="media/image2.png" style="width:5.75833in;height:2.77778in" alt="061c10af14d6b3e985f48c48683b0823" />

    <span class="mark">预期结果B：系统事件中所有槽位都有“硬盘插入”事件打印pass</span>

2、把除OS盘之外的所有硬盘创建成RAID5，逻辑卷容量设置成10GB，使用FIO对RAID5进行读写操作，IO请求设置成64Kbyte50%Random50%Read，登陆BMC Web管理界面查看所有在位硬盘的状态，预期结果C

(1)RAID5创建，容量10GB

./hiraidadm c0 create vd raid5 name=vd5 size=10240

drives=0:0,0:1,0:2,0:3,0:10,0:11,0:12,0:13

<img src="media/image3.png" style="width:5.76458in;height:1.26597in" alt="05d958bd1470edc0cd6bb82bf3e83deb" />

(2)IO请求设置成64Kbyte50%Random50%Read

fio --name=init --numjobs=1 --rw=randrw --direct=1 --ioengine=libaio --filename=/dev/sdb --rwmixread=50 --bs=64K --iodepth=8 --group_reporting

<img src="media/image4.png" style="width:5.7625in;height:1.42431in" alt="616f49ae6f6c4aa3a661d1aa56739d2f" /><img src="media/image5.png" style="width:5.75764in;height:0.35278in" alt="cafa5b8c9c6da148588634a44f91206b" /><img src="media/image6.png" style="width:5.75417in;height:1.90625in" alt="c7dfbeddecf60b49021f6a23c54db7ad" />

<span class="mark">预期结果C: BMC Web管理界面下硬盘状态为“正常”pass</span>

2.  把RAID5组中的1块成员盘拔出，查看BMC Web管理界面下硬盘状态以及“系统事件日志”，预期结果D

    <img src="media/image7.png" style="width:5.75417in;height:1.08125in" alt="1272df18c81e42696593388a16703ee5" />

    <span class="mark">预期结果D：拔出硬盘的状态变成不在位，系统事件日志中有“硬盘移除”事件打印，并且显示槽位正确。Pass</span>

3.  更换1块同样的硬盘到服务器，查看BMC Web管理界面下新插入的硬盘状态以及“系统事件日志”，预期结果E

    <img src="media/image8.png" style="width:5.76806in;height:2.45417in" alt="f51ea6c9380826637f378210066266ca" /><img src="media/image9.png" style="width:5.75208in;height:2.91944in" alt="36e568f0f20d172d4cf8c7f8b48ecf0b" />

    <span class="mark">预期结果E：系统事件日志中有“RAID组重构”事件打印，并且显示槽位正确。服务器上的物理丝印是否吻合pass</span>

5、把RAID5删除（此步骤在自动化工厂，需要先停FIO，再删除，避免IO error报错）,给服务器下电，把所有硬盘取出，查看未配置硬盘时BMC Web管理界面下硬盘状态以及“系统事件日志”，预期结果F

(1)VD1删除

./hiraidadm c0 show vdlist

查看vd

./hiraidadm c0:vd1 delete

删除

<img src="media/image10.png" style="width:5.76111in;height:3.44167in" alt="e1b47d96877af0a5a356d28f1689152c" />

<img src="media/image11.png" style="width:5.76597in;height:2.49097in" alt="06934eb360f22c999e9526703203e5f4" />

<span class="mark">预期结果F: 管理界面下每个硬盘都显示不在位，系统事件日志每个槽位都有“硬盘移除”事件打印pass</span>

6.  插入2块硬盘，创建双盘RAID1，然后将其中一块硬盘设置为offline状态，查看BMC Web管理界面下新插入的硬盘状态以及“系统事件日志”，预期结果G

    <img src="media/image12.png" style="width:5.75833in;height:0.42986in" alt="84aed2ba32c534018f402f696ad4cd16" />

(1)RAID1创建，容量10GB

./hiraidadm c0 create vd raid1 name=vd1 size=10240

drives=0:0,0:1,0:2,0:3,0:10,0:11,0:12,0:13

<img src="media/image13.png" style="width:5.76458in;height:1.22708in" alt="1a342e9d89a986aa1630947aaf459609" /><img src="media/image14.png" style="width:5.76806in;height:1.20208in" alt="952e89f51fcea93f0f67f42b38f5a4b8" />

(2)设置硬盘一个盘为offline状态

./hiraidadm c0:e0:s11 set offline

<img src="media/image15.png" style="width:5.76042in;height:1.3125in" alt="be17484c77e1dc43b6f2dac7d5f987bd" />

<img src="media/image16.png" style="width:5.75833in;height:0.48542in" alt="057c84ef5c9dc45592b53da0e9785ca7" /><img src="media/image17.png" style="width:5.7625in;height:1.80347in" alt="9a3e202cce7c9b42b499c18ba8f2188e" />

<span class="mark">预期结果G：BMC管理界面下，设置为offline状态的物理硬盘异常，系统事件日志有“硬盘故障”事件打印pass</span>
