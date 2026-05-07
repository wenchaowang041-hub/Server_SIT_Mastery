测试HuaWei MR/iMR卡硬盘点灯（硬盘读写、同步）的功能实现

(如果使用3004imr卡，步骤1~5所创建的RAID10可改为创建RAID1)

1、满配硬盘给服务器上电，进入操作系统，创建RAID10（备注：如果硬盘数量较多，可以创建成2个RAID10组），使用FIO对RAID10进行读写操作，IO请求设置成64Kbyte50%Random50%Read，查看RAID10组中的所有成员盘指示灯状态，预期结果A

(1)创建RAID命令（RAID10 硬盘enclosure id 11; slot id 1-10; 容量20GB; 每个span两块硬盘）：

./hiraidadm c0 create vd raid10 name=vd10 size=100000

drives=0:0,0:1,0:2,0:3,0:10,0:11,0:12,0:12,0:14,0:15

<img src="media/image1.png" style="width:5.76319in;height:2.26042in" alt="caf622f85256a06f32797188d82bfc5b" />

<img src="media/image2.png" style="width:5.75833in;height:1.13194in" alt="1425449b42631cf3447c50e0ccc3230f" />

2)  IO请求设置成64Kbyte50%Random50%Read

    <img src="media/image3.png" style="width:5.76597in;height:1.74375in" alt="aca8d4cd87ff7df62617b68012d2ed36" />

fio --name=init --numjobs=1 --rw=randrw --direct=1 --ioengine=libaio --filename=/dev/sdX --rwmixread=50 --bs=64K --iodepth=8 --group_reporting

<img src="media/image4.png" style="width:5.76667in;height:0.46597in" alt="bf7a54d628e5b09822764aafc0c22075" />

![](media/image5.emf)<img src="media/image6.png" style="width:5.75764in;height:2.99306in" alt="90a5c5b744dafa31b6c62c52d216b217" />

<span class="mark">预期结果A:RAID10逻辑卷成员盘的绿灯闪烁，BMC Web对应Logical Drive状态显示正常且和带内保持一致pass</span>

2.  把一个RAID10组中的1块成员盘拔出，查看该槽位的指示灯状态，预期结果B

    <img src="media/image7.jpeg" style="width:5.82014in;height:1.62917in" alt="97f0e4f39da14de06cadff935e312256" />

    <img src="media/image8.png" style="width:5.76597in;height:1.11319in" alt="0b3bdbd567c30815ef8d0a8eee31bcf1" />

    <span class="mark">预期结果B:RAID10组中的成员盘拔出后，拔出槽位的红灯常亮，BMC Web对应Logical Drive状态显示降级，拔出的物理盘在BMC Web不显示，且有记录相关的拔盘事件pass</span>

3.  更换1块同样的硬盘到服务器并触发重构，查看执行Rebuild进程的成员盘指示灯状态，预期结果C：<span class="mark">执行重构的硬盘绿灯和红灯闪烁</span>

    <img src="media/image9.jpeg" style="width:5.75972in;height:1.93403in" alt="7052f68004cb357281bf8004aa147e11" />

    重构完成绿灯常亮

<img src="media/image10.jpeg" style="width:5.75972in;height:2.12917in" alt="3b41e43d6b5c25adfe2c321ab54dbc71" /><img src="media/image11.png" style="width:5.76736in;height:2.47361in" />disk会显示重构但是逻辑盘不会显示重构状态fail

<img src="media/image12.png" style="width:5.75764in;height:1.10972in" alt="80ac1d4ca444e38dacc1a5bf78e53d7b" /><img src="media/image13.jpeg" style="width:5.20833in;height:5.27083in" alt="2ec3ac0b03023da3179d2619821fc860" />

<span class="mark">预期结果C:执行重构的硬盘绿灯和红灯闪烁，重构的硬盘在BMC Web上的重构状态为开启，重构的DISK状态为重构、但是Logical Drive状态不能显示为重构、原因是logical 的rebuild和disk的state是不同的属性、web页面逻辑盘的详细信息实际不支持查看rebuild state</span>

4.  停止对RAID10的读写，RAID10同步完成后，查看RAID10组所有硬盘的指示灯状态，预期结果D：间隔闪烁、

    <img src="media/image14.png" style="width:5.76042in;height:2.51458in" alt="12e7a22f9f704aa6d3e17edfcf0f2d3a" />

    ![](media/image15.emf)<img src="media/image6.png" style="width:5.75764in;height:2.99306in" alt="90a5c5b744dafa31b6c62c52d216b217" />

    <img src="media/image16.png" style="width:5.76458in;height:2.07917in" alt="073aa23c589afcf4fd486af7f5447a72" />

<span class="mark">预期结果D:RAID10逻辑卷optimal状态下硬盘绿灯常亮，没有红灯亮，BMC Web对应Logical Drive状态显示正常且和带内保持一致pass</span>

5.  把RAID10配置关系删除,把原RAID10组所有硬盘取出，装入空硬盘托架，观察硬盘指示灯状态，预期结果E

    ./hiraidadm c0 show vdlist

    查询虚拟磁盘id

<img src="media/image17.png" style="width:5.76181in;height:1.85556in" alt="0518b8ebfedef3e63f5b0dc867b86762" />

./hiraidadm c0:vd1 delete删除raid10

<img src="media/image18.png" style="width:5.76736in;height:1.73194in" alt="08023bbae505595d2d6dffb4fc3f9fbc" />

<img src="media/image19.jpeg" style="width:5.75694in;height:2.00694in" alt="5c88705122caa33691490bf080b05309" /><img src="media/image20.png" style="width:5.76458in;height:2.61042in" alt="2990e07c696e7f91d5d39e376027ae04" />

<span class="mark">预期结果E:未放置物理硬盘时的槽位状态指示灯熄灭（即红灯、绿灯都熄灭），拔出的物理盘在BMC Web不显示，且有记录相关的拔盘事件pass</span>
