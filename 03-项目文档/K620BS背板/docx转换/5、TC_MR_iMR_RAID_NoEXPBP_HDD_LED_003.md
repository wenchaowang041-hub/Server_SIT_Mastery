(如果使用3004imr卡，步骤2所创建的RAID10可改为创建RAID1)

1、满配硬盘给服务器上电，通过设置硬盘offline命令模拟硬盘故障，观察硬盘点灯，预期结果A；

(1)设置硬盘offline（硬盘enclosure id 11; slot id 1）命令示例：

先组raid10：./hiraidadm c0 create vd raid10 name=vd10 size=100000

drives=0:0,0:1,0:2,0:3,0:10,0:11,0:12,0:13,0:14,0:15

再offline ./hiraidadm c0:e0:s3 set offline

<img src="media/image1.png" style="width:5.76319in;height:1.56458in" alt="9981676bb5f0a19424ddcfa16de648ff" />

<img src="media/image2.jpeg" style="width:5.75972in;height:1.81042in" alt="5ece04effc0c62f8e0b7cb893c2ce284" /><img src="media/image3.png" style="width:5.76597in;height:0.42292in" alt="ca2f68ae274712e95e7819ebcb46f5b2" />

<span class="mark">预期结果A:故障硬盘红灯常亮，BMC Web页面对应硬盘健康状态为一般告警，BMC告警事件里有对应Disk abnormal的告警pass</span>

2.  重启服务器，POST过程中根据提示进入HII，满配硬盘创建RAID10（Device Manager -- 选中RAID卡 -- Create Virtual Drive -- 选中满配硬盘 -- 创建RAID10），locate点灯（Device Manager -- 选中RAID卡 -- Drive Management -- 选中硬盘 -- Select Operation -- Start Locate Locate -- Go）后马上下电，观察硬盘点灯，预期结果B；<img src="media/image4.png" style="width:5.76667in;height:3.09444in" alt="757542960623577eb06951ce1c1e6054" />

    <img src="media/image5.png" style="width:5.75764in;height:3.63958in" alt="78fa1db92ac99ae506239181a6cab9b7" />

    <img src="media/image6.png" style="width:5.75764in;height:1.77778in" alt="a99d8b44ca86c8e5a31bd62fd7481562" />

    <img src="media/image7.jpeg" style="width:5.44514in;height:2.35556in" alt="b4c1c49be79ca787bef2fbefaa02967e" />

    <span class="mark">BiOS下raid卡管理选择start locate、硬盘指示灯亮起、bmcweb端可以点亮locate指示灯pass</span>

    <img src="media/image8.jpeg" style="width:5.75972in;height:1.92083in" alt="b4f86bc5a57615d9680a179ecd54057c" /><img src="media/image9.jpeg" style="width:5.75972in;height:1.475in" alt="759dc7579c3ac3dc384e5b7b881cac85" />

<span class="mark">预期结果B:locate点灯后硬盘蓝灯闪烁，BMC Web页面对应硬盘的定位状态为开启；下电后硬盘灯灭（即黄灯、绿灯都熄灭）pass</span>

3、重启服务器，StorCLI使用间隔硬盘创建RAID1，拔出一块硬盘，观察点灯状态，预期结果C

<img src="media/image10.png" style="width:5.75833in;height:3.15in" alt="c25806c20e077badbe841da574dc0cac" /><img src="media/image11.png" style="width:5.75972in;height:2.03611in" alt="af265ceaedc564aa202b8ce7046d6c08" />点亮disk7定位灯、然后拔出、红灯亮起

<img src="media/image12.jpeg" style="width:5.75972in;height:3.24028in" alt="77328bf07df0d08c5d37ba43eb4bb734" /><img src="media/image13.png" style="width:5.75625in;height:0.80556in" alt="7567d0fa60aee8f7496ff3b6c0b41702" /><img src="media/image14.png" style="width:5.76597in;height:1.27847in" alt="a359c631fdbfb5dadbce3c2f1269a9a1" /><span class="mark">预期结果C:拔出硬盘槽位红灯常亮，BMC有对应硬盘被拔出的事件记录，BMC Web界面同步刷新，不再显示不在位的硬盘，且RAID1显示降级pass</span>

3.  更换1块同样的硬盘到服务器并触发重构，查看执行Rebuild进程的成员盘指示灯状态，预期结果D

    ![](media/image15.emf)<img src="media/image16.png" style="width:5.7625in;height:1.92847in" />

    <img src="media/image17.png" style="width:5.75417in;height:0.65694in" alt="9df5d6479db78ce655065e8f90b470f2" />

<span class="mark">预期结果D:执行重构的硬盘绿灯和红灯闪烁，BMC Web页面对应硬盘的重构状态为开启</span>

<span class="mark">PASS</span>

5、删除RAID1，查看硬盘点灯状态，预期结果E

<img src="media/image18.png" style="width:5.75764in;height:2.97361in" alt="71462cece932793adbf763a24d03391d" />

<img src="media/image19.png" style="width:5.75417in;height:2.01806in" alt="3c3346c06014cf78b7b2a840b5714e48" />

<img src="media/image20.png" style="width:5.76319in;height:2.22708in" alt="f48e0efd75a1ff72cde09a3feba3af52" />

<span class="mark">预期结果E:删除raid1组，原本RAID1的成员盘状态都变为UGood且只有绿灯常亮，且BMC Web页面的显示结果与带内保持一致。Pass</span>
