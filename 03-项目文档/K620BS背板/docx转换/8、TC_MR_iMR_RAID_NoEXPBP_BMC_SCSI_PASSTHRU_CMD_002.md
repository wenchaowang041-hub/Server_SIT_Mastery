验证在当前 SATA 盘环境下：

> RAID/JBOD 形态创建正常
>
> <img src="media/image1.png" style="width:5.76389in;height:3.24028in" alt="e4c3162cf4b4ef9889da57369d4deed0" /><img src="media/image2.png" style="width:5.76806in;height:1.84167in" alt="d5e0e79795ffd928491479df89342fee" /><img src="media/image3.png" style="width:5.76111in;height:2.15347in" alt="7f402ac78b1fbe9bce7cdacbae036135" />
>
> 长时间压力脚本可持续运行![](media/image4.emf)<img src="media/image5.png" style="width:5.76597in;height:0.56736in" alt="7c19556abbb896478544d7177f0e1a3d" />可每 5 秒对每个物理盘下发 SATA 场景 CDB 命令![](media/image6.emf)<img src="media/image7.png" style="width:5.76319in;height:1.38264in" alt="32cf2f0176acde2c17c9f666ffe5be00" /><img src="media/image8.png" style="width:5.76806in;height:2.42083in" alt="c24d0e09ef48f3b67954afb61db84023" /><img src="media/image9.png" style="width:5.76736in;height:3.87431in" alt="b76a5ce98f8e31faa04d1365fae50506" /><img src="media/image10.png" style="width:4.80208in;height:0.53125in" alt="46cfc0e2cf7794c8054703f8b4485091" />
>
> 步骤 2 / 3 / 4 可长期并行执行
>
> BMC 收集一键日志
>
> ![](media/image11.emf)<img src="media/image12.png" style="width:5.76667in;height:0.86875in" alt="7114cba39729c7e4e86d615d42e1b1a1" />
>
> 因为跑测试之前执行ipmitool sel clear和dmesg -c、再检查跑之后并无异常
>
> <span class="mark">整个过程中无 RAID 异常、掉盘、OS 异常、IO 中断等问题pass</span>
