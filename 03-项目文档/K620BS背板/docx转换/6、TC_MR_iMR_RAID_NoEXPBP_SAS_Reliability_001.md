1、BIOS Setup界面设置BIOS的时间，并将BIOS恢复为默认配置。预期结果A

ARM 服务器在Main的界面设置System Data 和System Time

X86 服务器进入Setup界面后，找到时间日期的设置项进行设置

A：<img src="media/image1.png" style="width:5.76597in;height:2.74444in" alt="a44ed3b6da3237af3ef358cb0121b48a" />

<span class="mark">预期结果A：设置成功无报错pass</span>

2.  系统下检查RAID卡的时间是否和当前时间一致，或者和当前时间间隔8个小时，记录好开始测试时间点。预期结果

    B：抓取RAID卡日志查看时间

    <img src="media/image2.png" style="width:5.76458in;height:1.98264in" alt="fda83c856a75d1a85357a1114dfcaafe" />

    <img src="media/image3.png" style="width:5.75972in;height:0.3625in" alt="c37679021a3cbe5fe959e09ced195549" />

<span class="mark">预期结果B：记录好时间点</span>

3、由于盘数的不确定，分为3个步骤设置硬盘状态。预期结果C

a.把除系统盘外的所有硬盘创建成单盘RAID0、双盘RAID1、JBOD（必须）

b.如果a设置完成有更多的盘优先设置RAID5、RAID6。iMR卡跳过该步骤。

c.如果b设置完成还有更多的盘，重复a和b，直到所有硬盘状态都进行了设置

(1)RAID0创建

(2)RAID1创建

(3)JBOD盘创建

(4)RAID5创建

<img src="media/image4.png" style="width:5.76111in;height:2.50764in" alt="9c59cfe3fc8720ac840b18ad8e15462a" />

JBOD：<img src="media/image5.png" style="width:5.76597in;height:0.55347in" alt="8ca3dd521f78b253d287bb7a9def47d2" />

\[root@bogon ~\]# ./hiraidadm c0:rg0 show pdarray

========================================== Hiraidadm Information ===========================================

Name: hiraidadm

Version: 1.2.2.9

Build Time: Jul 4 2025 11:03:05

==============================================================================================================

==============================================================================================================

Status Code = 0

Status = Success

Description = None

==============================================================================================================

Total Member Drive Number is 2

--------------------------------------------------------------------------------------------------------------

Enc Slot DID AssoEnc AssoSlot AssoDid Intf Media Status AssoStatus Capacity SecSz Model

--------------------------------------------------------------------------------------------------------------

0 0 1 NA NA NA SATA SSD online NA 446.632GB 512B HWE74ST3480L007N

0 1 0 NA NA NA SATA SSD online NA 446.632GB 512B HWE74ST3480L007N

--------------------------------------------------------------------------------------------------------------

\[root@bogon ~\]# ./hiraidadm c0:rg1 show pdarray

========================================== Hiraidadm Information ===========================================

Name: hiraidadm

Version: 1.2.2.9

Build Time: Jul 4 2025 11:03:05

==============================================================================================================

==============================================================================================================

Status Code = 0

Status = Success

Description = None

==============================================================================================================

Total Member Drive Number is 1

--------------------------------------------------------------------------------------------------------------

Enc Slot DID AssoEnc AssoSlot AssoDid Intf Media Status AssoStatus Capacity SecSz Model

--------------------------------------------------------------------------------------------------------------

0 4 2 NA NA NA SATA HDD online NA 7.277TB 512B WUS721208BLE604

--------------------------------------------------------------------------------------------------------------

\[root@bogon ~\]# ./hiraidadm c0:rg2 show pdarray

========================================== Hiraidadm Information ===========================================

Name: hiraidadm

Version: 1.2.2.9

Build Time: Jul 4 2025 11:03:05

==============================================================================================================

==============================================================================================================

Status Code = 0

Status = Success

Description = None

==============================================================================================================

Total Member Drive Number is 2

--------------------------------------------------------------------------------------------------------------

Enc Slot DID AssoEnc AssoSlot AssoDid Intf Media Status AssoStatus Capacity SecSz Model

--------------------------------------------------------------------------------------------------------------

0 2 4 NA NA NA SATA HDD online NA 7.277TB 512B WUS721208BLE604

0 9 3 NA NA NA SATA HDD online NA 7.277TB 512B WUS721208BLE604

--------------------------------------------------------------------------------------------------------------

\[root@bogon ~\]# ./hiraidadm c0:rg3 show pdarray

========================================== Hiraidadm Information ===========================================

Name: hiraidadm

Version: 1.2.2.9

Build Time: Jul 4 2025 11:03:05

==============================================================================================================

==============================================================================================================

Status Code = 0

Status = Success

Description = None

==============================================================================================================

Total Member Drive Number is 3

--------------------------------------------------------------------------------------------------------------

Enc Slot DID AssoEnc AssoSlot AssoDid Intf Media Status AssoStatus Capacity SecSz Model

--------------------------------------------------------------------------------------------------------------

0 3 5 NA NA NA SATA HDD online NA 7.277TB 512B WUS721208BLE604

0 5 7 NA NA NA SATA HDD online NA 7.277TB 512B WUS721208BLE604

0 10 6 NA NA NA SATA HDD online NA 7.277TB 512B WUS721208BLE604

--------------------------------------------------------------------------------------------------------------

\[root@bogon ~\]# ./hiraidadm c0:rg4 show pdarray

========================================== Hiraidadm Information ===========================================

Name: hiraidadm

Version: 1.2.2.9

Build Time: Jul 4 2025 11:03:05

==============================================================================================================

==============================================================================================================

Status Code = 0

Status = Success

Description = None

==============================================================================================================

Total Member Drive Number is 1

--------------------------------------------------------------------------------------------------------------

Enc Slot DID AssoEnc AssoSlot AssoDid Intf Media Status AssoStatus Capacity SecSz Model

--------------------------------------------------------------------------------------------------------------

0 6 8 NA NA NA SATA HDD online NA 7.277TB 512B WUS721208BLE604

--------------------------------------------------------------------------------------------------------------

\[root@bogon ~\]# ./hiraidadm c0:rg5 show pdarray

========================================== Hiraidadm Information ===========================================

Name: hiraidadm

Version: 1.2.2.9

Build Time: Jul 4 2025 11:03:05

==============================================================================================================

==============================================================================================================

Status Code = 0

Status = Success

Description = None

==============================================================================================================

Total Member Drive Number is 2

--------------------------------------------------------------------------------------------------------------

Enc Slot DID AssoEnc AssoSlot AssoDid Intf Media Status AssoStatus Capacity SecSz Model

--------------------------------------------------------------------------------------------------------------

0 8 9 NA NA NA SATA HDD online NA 7.277TB 512B WUS721208BLE604

0 11 10 NA NA NA SATA HDD online NA 7.277TB 512B WUS721208BLE604

--------------------------------------------------------------------------------------------------------------

\[root@bogon ~\]#

<span class="mark">预期结果C：RAID组创建成功，JBOD设置成功，无报错</span>

3.  检查RAID组VD的写策略必须为WB，如不满足，需要报错退出，对于iMR卡跳过该检查项。预期结果D

    <span class="mark">./hiraidadm c0:vd0 set wcache mode=WT修改为写策略WB</span>

    <img src="media/image6.png" style="width:5.76667in;height:1.10347in" alt="78a7b6a461346359800945ec0fcc1388" />

<span class="mark">预期结果D：写策略为WB</span>

备注：如下共计40小时的性能测试，需要连续执行。

<img src="media/image7.png" style="width:5.76597in;height:1.71111in" alt="1e5a8f3f2918ee0894c73c4b5494f31d" />

备注：如下共计40小时的性能测试，需要连续执行。

脚本![](media/image8.emf)

5、对系统盘外的所有硬盘进行8小时的4K顺序读测试，每个盘符独立下发一条fio，使用iostat记录io下发情况。fio测试完成后停止iostat监控。预期结果E

fio --name=fio_4K_Seq_read --ioengine=libaio --direct=1 --rw=read --bs=4K --runtime=28800 --time_based --filename=/dev/sdX

iostat -x -t 10 \>\>4K_Seq_read_result.txt

停止iostat监控

ps -ef \|grep -i iostat

kill XXX

6、对系统盘外的所有硬盘进行8小时的4K顺序写测试，使用iostat记录io下发情况。fio测试完成后停止iostat监控。预期结果E

fio --name=fio_4K_Seq_read --ioengine=libaio --direct=1 --rw=write --bs=4K --runtime=28800 --time_based --filename=/dev/sdX

iostat -x -t 10 \>\>4K_Seq_write_result.txt

停止iostat监控

ps -ef \|grep -i iostat

kill XXX

7、对系统盘外的所有硬盘进行8小时的4K随机读写测试，使用iostat记录io下发情况。fio测试完成后停止iostat监控。预期结果E

fio --name=fio_4k_Seq_50read --ioengine=libaio --direct=1 --rw=rw --rwmixread=50 --bs=4K --runtime=28800 --time_based --filename=/dev/sdX

iostat -x -t 10 \>\>4k_Seq_50read_result.txt

停止iostat监控

ps -ef \|grep -i iostat

kill XXX

8、对系统盘外的所有硬盘进行8小时的128K顺序读测试，使用iostat记录io下发情况。fio测试完成后停止iostat监控。预期结果E

fio --name=fio_128K_Seq_read --ioengine=libaio --direct=1 --rw=read --bs=128K --runtime=28800 --time_based --filename=/dev/sdX

iostat -x -t 10 \>\>128K_Seq_read_result.txt

停止iostat监控

ps -ef \|grep -i iostat

kill XXX

9、对系统盘外的所有硬盘进行8小时的128K顺序写测试，使用iostat记录io下发情况。fio测试完成后停止iostat监控。预期结果E

fio --name=fio_128K_Seq_write --ioengine=libaio --direct=1 --rw=write --bs=128K --runtime=28800 --time_based --filename=/dev/sdX

iostat -x -t 10 \>\>128K_Seq_write_result.txt

停止iostat监控

ps -ef \|grep -i iostat

kill XXX

5、6、7、8、9、

<img src="media/image9.png" style="width:4.68333in;height:3.83889in" alt="faa3a059ffa35ca903fd7e668411c67c" /><img src="media/image10.png" style="width:5.76597in;height:5.06736in" alt="b07af542b72b3b811da06205e7990bff" /><span class="mark">预期结果E：fio下发成功，无报错</span>

log文件![](media/image11.emf)

10. io检查，检查各个result文件，做出每个盘符的性能带宽-时间曲线，关注带宽是否有跌零。预期结果F

![](media/image12.emf)

<span class="mark">预期结果F：测试期间fio无跌零。</span>

11. io检查，针对HDD：检查128K_Seq_read_result.txt和128K_Seq_write_result.txt，每个盘符数据分开统计。从600秒后分析稳态数据；每一段数据每200个点为一组，每一组数据单独评判平稳性；低于70%平均值的点视为波动点，波动点的数量占比不超过3%，或者整体不大于3%。预期结果G

    <img src="media/image13.png" style="width:5.76042in;height:2.13611in" alt="9524a00d92ae64ab529de509fbca888b" />

<span class="mark">预期结果G：测试期间的性能符合波动的要求</span>

12. io检查，针对SSD：检查128K_Seq_read_result.txt和128K_Seq_write_result.txt，每个盘符数据分开统计。低于80%平均值的点视为波动点，波动点的数量占比不超过1%。预期结果G

<span class="mark">预期结果G：测试期间的性能符合波动的要求</span>

对于10、11、12利用python脚本自动检测对照fio_result_analysis.zip![](media/image12.emf)

先装依赖：

yum install -y python3 python3-pip\
pip3 install matplotlib

然后再跑：![](media/image14.emf)

python3 analyze_iostat.py \\\
--input-dir ./fio_40h_logs_2026-03-11_175518 \\\
--output-dir ./fio_result_analysis \\\
--interval 10 \\\
--device-types "sda:HDD,sdc:HDD,sdd:HDD,sde:HDD,sdf:HDD,sdg:HDD"

13、测试完成后需要收集RAID卡日志，检查日志，预期结果H

检查sasraidlog里面对应测试执行时间段里面是否有"Command timeout"、"Fatal firmware error"、"CRITICAL"、"06/29/00"、"PL Fault"、"reset (Type"、"missing"、"cache discarded"等关键字样，不区分大小写。

<img src="media/image15.png" style="width:5.76458in;height:4.39167in" alt="8d68dfbaf8a71e2ebe1a7b58ba659039" />

![](media/image16.emf)<span class="mark">raid卡日志</span>

<span class="mark">预期结果H：测试时间段内的日志无这些关键字的打印。</span>

14、测试完成后需要收集BMC一键收集日志，检查日志，预期结果I

在dump_info\AppDump\sensor_alarm的路径下sel.tar的文件进行解压检查，筛选Event Type为RAID Card 和 Disk的事件，检查事件的Severity类型，无Miner、Major、Critical状态。

在dump_info\LogDump的路径下fdm_log进行检查，根据VID、DID（举例字样：VID_0X19E5,DID_0XD100）进行搜索查询，确认是否有RAID卡的相关报错。

![](media/image17.emf)<span class="mark">BMC一键日志</span>![](media/image18.emf)

预期结果I：测试时间段内的sel日志无用例描述的相关事件，fdm日志无RAID卡的相关报错

### RAID 卡日志结论

> <span class="mark">检查 raidcardlog 中测试时间段日志，未发现 Command timeout、Fatal firmware error、CRITICAL、06/29/00、PL Fault、cache discarded 等关键故障字样。</span>

### BMC 日志结论

> 检查 BMC 一键日志中的 SEL / event / fault diagnosis 数据，未发现明确的 RAID Card Critical 告警。
