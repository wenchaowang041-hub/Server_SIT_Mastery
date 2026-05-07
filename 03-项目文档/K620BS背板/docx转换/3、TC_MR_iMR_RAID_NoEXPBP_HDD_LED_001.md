1.  A：硬盘指示灯在位状态显示正常

    <img src="media/image1.jpeg" style="width:5.75972in;height:1.10903in" alt="43247f6ccf5f4ee237bcdcf64cb75af8" />

    <img src="media/image2.png" style="width:5.75278in;height:1.74931in" alt="203dbdc1d22fea1212a00163e55eff50" /><img src="media/image3.png" style="width:5.75833in;height:1.96667in" alt="de293375e0bea4bd2914bef8439f2904" />

    <span class="mark">结果：每个硬盘插入之后，硬盘active(绿色)指示灯依次亮起，BMC的事件日志能够看出每个盘的插入事件；且BMC Web显示出的硬盘信息与带内保持一致；BMC Web的Disk号码、带内查看的硬盘slot号码、物理硬盘所在的槽位丝印号，三者按照顺序一一匹配。PASS</span>

2.  重启服务器，观察上电过程硬盘指示灯点亮方式，预期结果

    B：

    ![](media/image4.emf)<img src="media/image5.png" style="width:5.76319in;height:0.25625in" alt="b55164c68009455e4da4eb767def7764" /><img src="media/image6.png" style="width:5.75278in;height:0.78264in" alt="5a50e20091861508bb83cd099bc12b82" />

    <span class="mark">结果：上电过程不存在硬盘fault灯（红色）亮，不存在硬盘active指示灯（绿色）不亮的现象PASS</span>

3.  进入OS后，查看物理硬盘在位状态灯，预期结果

    C：全部在位状态灯常亮

    <img src="media/image1.jpeg" style="width:5.75972in;height:1.10903in" alt="43247f6ccf5f4ee237bcdcf64cb75af8" />

    <span class="mark">结果：物理硬盘在位灯（绿灯）常亮，OS盘绿灯偶尔闪烁PASS</span>

4.  物理硬盘Locate功能点灯状态，预期结果

    (1)所有硬盘locate点灯命令

更换hiraidadm工具后命令变更为---\>

./hiraidadm c0:e0:s0 set led type=locate sw=on

/hiraidadm c0:e0:s0 set led type=locate sw=off

D：

查询指定控制卡下所有物理盘列表信息：

<img src="media/image7.png" style="width:5.76667in;height:3.86944in" alt="60101c248c2153db04caea673081efff" />

\# 批量点亮 c0:e0 下 s0 到 s11 的locate灯（type=locate sw=on）

<span class="mark">for slot in {0..11}; do</span>

<span class="mark">./hiraidadm c0:e0:s\${slot} set led type=locate sw=on</span>

<span class="mark">echo "已点亮 c0:e0:s\${slot} 定位灯"</span>

<span class="mark">done</span>

<img src="media/image8.png" style="width:5.76458in;height:3.44583in" alt="be3f783afd9337dc3843ae90fcae87f2" /><img src="media/image9.jpeg" style="width:5.75972in;height:0.80278in" alt="f65c7d6b4632da4aae106e440d68845b" />\# 批量关闭 c0:e0 下 s0 到 s11 的locate灯（type=locate sw=off）

<span class="mark">for slot in {0..11}; do</span>

<span class="mark">./hiraidadm c0:e0:s\${slot} set led type=locate sw=off</span>

<span class="mark">echo "已关闭 c0:e0:s\${slot} 定位灯"</span>

<span class="mark">done</span>

<img src="media/image10.png" style="width:5.75833in;height:3.87292in" alt="6e9a3698c010720738b69ec935cf4c9f" />

<img src="media/image11.jpeg" style="width:5.25208in;height:0.87708in" alt="b4757a948110cc6423c483d7b2990091" />

<span class="mark">结果：执行locate点灯时，硬盘Locate功能状态灯（蓝灯）闪烁，BMC Web页面对应硬盘的定位状态为开启；停止locate点灯时，硬盘Locate功能状态灯（蓝灯）熄灭，BMC Web页面对应硬盘的定位状态为关闭PASS</span>

5.  给服务器下电，查看硬盘点灯状态，预期结果

    E：

    <img src="media/image12.png" style="width:5.76458in;height:0.93125in" alt="989b905524c4c62be71edc705f01bb26" /><img src="media/image13.jpeg" style="width:5.75972in;height:1.01111in" alt="99fc6afa2a7dd78cc1c9c500ab930dc1" />

    <span class="mark">结果：服务器下电硬盘蓝灯、绿灯都熄灭PASS</span>

    预期结果A：每个硬盘插入之后，硬盘active(绿色)指示灯依次亮起，BMC的事件日志能够看出每个盘的插入事件；且BMC Web显示出的硬盘信息与带内保持一致；BMC Web的Disk号码、带内查看的硬盘slot号码、物理硬盘所在的槽位丝印号，三者按照顺序一一匹配。

    预期结果B：上电过程不存在硬盘fault灯（黄色）亮，不存在硬盘active指示灯（绿色）不亮的现象

    预期结果C：物理硬盘在位灯（绿灯）常亮，OS盘绿灯偶尔闪烁

    预期结果D：执行locate点灯时，硬盘Locate功能状态灯（黄灯）闪烁，BMC Web页面对应硬盘的定位状态为开启；停止locate点灯时，硬盘Locate功能状态灯（黄灯）熄灭，BMC Web页面对应硬盘的定位状态为关闭

    预期结果E：服务器下电硬盘黄灯、绿灯都熄灭
