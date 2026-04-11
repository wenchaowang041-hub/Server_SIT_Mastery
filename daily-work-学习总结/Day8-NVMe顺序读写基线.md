Day8
Day8 目标
建立这块 NVMe 的顺序读写基线：

fio 跑顺序读/写


iostat -x 1 同时观察


记录：


带宽 BW


bs


iodepth


await


%util


第一步：测试前清理一下盘
先对测试盘做一次清理，尽量让基线更干净。
再次确认别写错盘，只能是 nvme0n1。
wipefs -a /dev/nvme0n1
sgdisk --zap-all /dev/nvme0n1
partprobe /dev/nvme0n1
blkdiscard /dev/nvme0n1
如果 blkdiscard 报不支持，也可以继续，不影响测试进行。
然后确认一下：
lsblk
你应该还是看到：

nvme0n1 整盘


没有 nvme0n1p1/p2/p3


```bash
[root@bogon ~]# wipefs -a /dev/nvme0n1
[root@bogon ~]# sgdisk --zap-all /dev/nvme0
nvme0    nvme0n1
[root@bogon ~]# sgdisk --zap-all /dev/nvme0
nvme0    nvme0n1
[root@bogon ~]# sgdisk --zap-all /dev/nvme0n1
```

-bash: sgdisk：未找到命令
```bash
[root@bogon ~]# partprobe /dev/nvme0n1
[root@bogon ~]# bldiscard /dev/nvme0n1
```

-bash: bldiscard：未找到命令
```bash
[root@bogon ~]# lsblk
NAME               MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda                  8:0    0 447.1G  0 disk
sdb                  8:16   0 447.1G  0 disk
sdc                  8:32   0 446.6G  0 disk
sdd                  8:48   0 446.6G  0 disk
sde                  8:64   0 446.6G  0 disk
sdf                  8:80   0 446.6G  0 disk
sdg                  8:96   0 446.6G  0 disk
sdh                  8:112  0 446.6G  0 disk
sdi                  8:128  0 446.6G  0 disk
sdj                  8:144  0 446.6G  0 disk
nvme0n1            259:0    0   2.9T  0 disk
nvme1n1            259:1    0   2.9T  0 disk
├─nvme1n1p1        259:5    0   600M  0 part /boot/efi
├─nvme1n1p2        259:6    0     1G  0 part /boot
└─nvme1n1p3        259:7    0   2.9T  0 part
├─openeuler-root 253:0    0    70G  0 lvm  /
├─openeuler-swap 253:1    0     4G  0 lvm  [SWAP]
└─openeuler-home 253:5    0   2.8T  0 lvm  /home
```

第二步：开监控窗口
另开一个终端，执行：
iostat -x 1 nvme0n1
等会儿跑 fio 时，你重点记这几列：

rkB/s


wkB/s


r/s


w/s


await


%util

```bash
[root@bogon ~]# iostat -x 1 nvme0n1
Linux 5.10.0-216.0.0.115.oe2203sp4.aarch64 (bogon)      2026年03月20日      _aarch64_       (256 CPU)
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
```

0.00    0.00    0.02    0.00    0.00   99.98

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1          0.01      0.32     0.00   0.00    0.09    27.53    0.00      0.00     0.00   0.00    0.00     4.00    0.01  34801.86     0.00   0.00   41.19 4189835.10    0.00    0.00    0.00   0.00

第三步：跑 Day8 的 4 组基线
先跑你计划表最核心的顺序读写。
1）1M 顺序写
fio --name=nvme_seq_write_1m \
    --filename=/dev/nvme0n1 \
    --direct=1 \
    --ioengine=libaio \
    --rw=write \
    --bs=1M \
    --iodepth=32 \
    --numjobs=1 \
    --offset=4G \
    --size=20G \
    --runtime=60 \
    --time_based \
    --group_reporting


```bash
[root@bogon ~]# fio --name=nvme_seq_write_1m \
>     --filename=/dev/nvme0n1 \
>     --direct=1 \
>     --ioengine=libaio \
>     --rw=write \
>     --bs=1M \
>     --iodepth=32 \
>     --numjobs=1 \
>     --offset=4G \
>     --size=20G \
>     --runtime=60 \
>     --time_based \
>     --group_reporting
nvme_seq_write_1m: (g=0): rw=write, bs=(R) 1024KiB-1024KiB, (W) 1024KiB-1024KiB, (T) 1024KiB-1024KiB, ioengine=libaio, iodepth=32
fio-3.29
Starting 1 process
Jobs: 1 (f=1): [W(1)][5.0%][w=4669MiB/s][w=4668 IOPS][eta 00Jobs: 1 (f=1): [W(1)][6.7%][w=4672MiB/s][w=4672 IOPS][eta 00Jobs: 1 (f=1): [W(1)][8.3%][w=4641MiB/s][w=4641 IOPS][eta 00Jobs: 1 (f=1): [W(1)][10.0%][w=4622MiB/s][w=4621 IOPS][eta 0Jobs: 1 (f=1): [W(1)][11.7%][w=4681MiB/s][w=4681 IOPS][eta 0Jobs: 1 (f=1): [W(1)][13.3%][w=4633MiB/s][w=4633 IOPS][eta 0Jobs: 1 (f=1): [W(1)][15.0%][w=4651MiB/s][w=4650 IOPS][eta 0Jobs: 1 (f=1): [W(1)][16.7%][w=4618MiB/s][w=4618 IOPS][eta 0Jobs: 1 (f=1): [W(1)][18.3%][w=4639MiB/s][w=4639 IOPS][eta 0Jobs: 1 (f=1): [W(1)][20.0%][w=4622MiB/s][w=4621 IOPS][eta 0Jobs: 1 (f=1): [W(1)][21.7%][w=4637MiB/s][w=4637 IOPS][eta 0Jobs: 1 (f=1): [W(1)][23.3%][w=4640MiB/s][w=4640 IOPS][eta 0Jobs: 1 (f=1): [W(1)][25.0%][w=4638MiB/s][w=4637 IOPS][eta 0Jobs: 1 (f=1): [W(1)][26.7%][w=4635MiB/s][w=4635 IOPS][eta 0Jobs: 1 (f=1): [W(1)][28.3%][w=4640MiB/s][w=4640 IOPS][eta 0Jobs: 1 (f=1): [W(1)][30.0%][w=4650MiB/s][w=4650 IOPS][eta 0Jobs: 1 (f=1): [W(1)][31.7%][w=4643MiB/s][w=4642 IOPS][eta 0Jobs: 1 (f=1): [W(1)][33.3%][w=4660MiB/s][w=4660 IOPS][eta 0Jobs: 1 (f=1): [W(1)][35.0%][w=4636MiB/s][w=4636 IOPS][eta 0Jobs: 1 (f=1): [W(1)][36.7%][w=4661MiB/s][w=4660 IOPS][eta 0Jobs: 1 (f=1): [W(1)][39.0%][w=4641MiB/s][w=4641 IOPS][eta 0Jobs: 1 (f=1): [W(1)][40.0%][w=4658MiB/s][w=4658 IOPS][eta 0Jobs: 1 (f=1): [W(1)][41.7%][w=4648MiB/s][w=4648 IOPS][eta 0Jobs: 1 (f=1): [W(1)][43.3%][w=4650MiB/s][w=4649 IOPS][eta 0Jobs: 1 (f=1): [W(1)][45.0%][w=4687MiB/s][w=4687 IOPS][eta 0Jobs: 1 (f=1): [W(1)][46.7%][w=4627MiB/s][w=4627 IOPS][eta 0Jobs: 1 (f=1): [W(1)][48.3%][w=4657MiB/s][w=4656 IOPS][eta 0Jobs: 1 (f=1): [W(1)][50.0%][w=4634MiB/s][w=4634 IOPS][eta 0Jobs: 1 (f=1): [W(1)][52.5%][w=4625MiB/s][w=4625 IOPS][eta 0Jobs: 1 (f=1): [W(1)][53.3%][w=4665MiB/s][w=4664 IOPS][eta 0Jobs: 1 (f=1): [W(1)][55.9%][w=4635MiB/s][w=4635 IOPS][eta 0Jobs: 1 (f=1): [W(1)][56.7%][w=4653MiB/s][w=4653 IOPS][eta 0Jobs: 1 (f=1): [W(1)][59.3%][w=4641MiB/s][w=4641 IOPS][eta 0Jobs: 1 (f=1): [W(1)][60.0%][w=4646MiB/s][w=4645 IOPS][eta 0Jobs: 1 (f=1): [W(1)][61.7%][w=4634MiB/s][w=4634 IOPS][eta 0Jobs: 1 (f=1): [W(1)][63.3%][w=4641MiB/s][w=4641 IOPS][eta 0Jobs: 1 (f=1): [W(1)][65.0%][w=4655MiB/s][w=4654 IOPS][eta 0Jobs: 1 (f=1): [W(1)][66.7%][w=4635MiB/s][w=4635 IOPS][eta 0Jobs: 1 (f=1): [W(1)][68.3%][w=4663MiB/s][w=4663 IOPS][eta 0Jobs: 1 (f=1): [W(1)][70.0%][w=4650MiB/s][w=4649 IOPS][eta 0Jobs: 1 (f=1): [W(1)][71.7%][w=4643MiB/s][w=4643 IOPS][eta 0Jobs: 1 (f=1): [W(1)][73.3%][w=4632MiB/s][w=4632 IOPS][eta 0Jobs: 1 (f=1): [W(1)][75.0%][w=4664MiB/s][w=4664 IOPS][eta 0Jobs: 1 (f=1): [W(1)][78.0%][w=4643MiB/s][w=4642 IOPS][eta 0Jobs: 1 (f=1): [W(1)][78.3%][w=4645MiB/s][w=4645 IOPS][eta 0Jobs: 1 (f=1): [W(1)][80.0%][w=4631MiB/s][w=4631 IOPS][eta 0Jobs: 1 (f=1): [W(1)][81.7%][w=4625MiB/s][w=4624 IOPS][eta 0Jobs: 1 (f=1): [W(1)][83.3%][w=4669MiB/s][w=4669 IOPS][eta 0Jobs: 1 (f=1): [W(1)][85.0%][w=4637MiB/s][w=4637 IOPS][eta 0Jobs: 1 (f=1): [W(1)][86.7%][w=4643MiB/s][w=4642 IOPS][eta 0Jobs: 1 (f=1): [W(1)][88.3%][w=4625MiB/s][w=4625 IOPS][eta 0Jobs: 1 (f=1): [W(1)][90.0%][w=4668MiB/s][w=4668 IOPS][eta 0Jobs: 1 (f=1): [W(1)][91.7%][w=4630MiB/s][w=4629 IOPS][eta 0Jobs: 1 (f=1): [W(1)][93.3%][w=4618MiB/s][w=4618 IOPS][eta 0Jobs: 1 (f=1): [W(1)][95.0%][w=4662MiB/s][w=4662 IOPS][eta 0Jobs: 1 (f=1): [W(1)][96.7%][w=4657MiB/s][w=4657 IOPS][eta 0Jobs: 1 (f=1): [W(1)][98.3%][w=4662MiB/s][w=4661 IOPS][eta 0Jobs: 1 (f=1): [W(1)][100.0%][w=4637MiB/s][w=4637 IOPS][eta 00m:00s]
nvme_seq_write_1m: (groupid=0, jobs=1): err= 0: pid=14540: Fri Mar 20 12:45:10 2026
write: IOPS=4626, BW=4627MiB/s (4852MB/s)(271GiB/60007msec); 0 zone resets
slat (usec): min=12, max=346, avg=20.15, stdev= 4.86
clat (usec): min=3854, max=18596, avg=6894.93, stdev=643.90
lat (usec): min=3989, max=18611, avg=6915.17, stdev=644.29
clat percentiles (usec):
|  1.00th=[ 6325],  5.00th=[ 6456], 10.00th=[ 6521], 20.00th=[ 6652],
| 30.00th=[ 6718], 40.00th=[ 6783], 50.00th=[ 6849], 60.00th=[ 6915],
| 70.00th=[ 6980], 80.00th=[ 7046], 90.00th=[ 7177], 95.00th=[ 7242],
| 99.00th=[10028], 99.50th=[11863], 99.90th=[16188], 99.95th=[17171],
| 99.99th=[17957]
bw (  MiB/s): min= 2684, max= 4714, per=100.00%, avg=4628.34, stdev=181.55, samples=119
iops        : min= 2684, max= 4714, avg=4628.34, stdev=181.55, samples=119
lat (msec)   : 4=0.01%, 10=98.99%, 20=1.01%
cpu          : usr=7.19%, sys=2.59%, ctx=277595, majf=0, minf=55
IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
issued rwts: total=0,277646,0,0 short=0,0,0,0 dropped=0,0,0,0
latency   : target=0, window=0, percentile=100.00%, depth=32
Run status group 0 (all jobs):
WRITE: bw=4627MiB/s (4852MB/s), 4627MiB/s-4627MiB/s (4852MB/s-4852MB/s), io=271GiB (291GB), run=60007-60007msec
Disk stats (read/write):
nvme0n1: ios=46/285481, merge=0/0, ticks=2/1967216, in_queue=1967218, util=99.84%
Iostat -x 1 nvme0n1
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
```

0.04    0.00    0.03    0.00    0.00   99.93

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1          0.00      0.00     0.00   0.00    0.00     0.00 4765.00 4731904.00     0.00   0.00    6.90   993.05    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   32.88 100.00


avg-cpu:  %user   %nice %system %iowait  %steal   %idle
0.02    0.00    0.02    0.00    0.00   99.96

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1          0.00      0.00     0.00   0.00    0.00     0.00 4791.00 4757504.00     0.00   0.00    6.86   993.01    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   32.88 100.00


在 bs=1M, iodepth=32, numjobs=1, direct=1 条件下，nvme0n1 的顺序写基线约为 4.6 GiB/s，平均写等待时间约 6.9 ms，设备利用率接近 100%。fio 带宽与 iostat wkB/s 基本一致，说明测试结果可信。




你这组最漂亮的地方，不只是带宽高，而是 fio 和 iostat 对得非常准。
1）带宽对得上
fio 给的是：

4627 MiB/s

换算成 KiB/s 大约是：

4627 × 1024 = 4,738,048 KiB/s

而你的 iostat 给的是：

4,731,904 kB/s


4,757,504 kB/s

这个范围和 fio 几乎完全重合。
说明：

你看的盘没看错


测试确实打在 nvme0n1


fio 和 iostat 数据是一致的

这就是你计划表里说的“把 fio 结果和 iostat 对齐”，你这一步已经做对了。

2）延迟也对得上
fio 里：

clat avg = 6894.93 usec


也就是 6.895 ms

iostat 里：

w_await = 6.86 ~ 6.90 ms

这两个也几乎一样。
这说明你现在已经开始能把两个工具的“不同视角”对起来了：

fio 看应用测试视角


iostat 看设备层视角

这一步非常重要。

3）设备已经基本打满
你这里看到：

util = 99.84% / 100%


aqu-sz = 32.88


iodepth = 32

这说明：

队列深度基本跑满


盘忙得很满


这条 1M 顺序写已经接近当前参数下的设备上限


这条结果怎么解读
你现在可以这样写到笔记里：
在 bs=1M, iodepth=32, numjobs=1, direct=1 条件下，nvme0n1 的顺序写基线约为 4.6 GiB/s，平均写等待时间约 6.9 ms，设备利用率接近 100%。fio 带宽与 iostat wkB/s 基本一致，说明测试结果可信。
这就是一条很标准的基线描述。

再看几个细节，你顺手学一下
IOPS 也合理
你这里：

IOPS = 4626


bs = 1M

所以：

4626 IOPS × 1 MiB ≈ 4626 MiB/s

和带宽完全一致。

CPU 压力不大
你这里：

usr=7.19%


sys=2.59%

说明这组测试不是 CPU 打满，而确实主要是盘在扛。

稳定性不错
你进度条里多数时间都在：

4620 ~ 4680 MiB/s

波动不大，说明这条盘的顺序写输出比较稳，不是忽高忽低那种状态。

2）1M 顺序读
fio --name=nvme_seq_read_1m \
    --filename=/dev/nvme0n1 \
    --direct=1 \
    --ioengine=libaio \
    --rw=read \
    --bs=1M \
    --iodepth=32 \
    --numjobs=1 \
    --offset=4G \
    --size=20G \
    --runtime=60 \
    --time_based \
    --group_reporting


```bash
[root@bogon ~]# fio --name=nvme_seq_read_1m \
>     --filename=/dev/nvme0n1 \
>     --direct=1 \
>     --ioengine=libaio \
>     --rw=read \
>     --bs=1M \
>     --iodepth=32 \
>     --numjobs=1 \
>     --offset=4G \
>     --size=20G \
>     --runtime=60 \
>     --time_based \
>     --group_reporting
nvme_seq_read_1m: (g=0): rw=read, bs=(R) 1024KiB-1024KiB, (W) 1024KiB-1024KiB, (T) 1024KiB-1024KiB, ioengine=libaio, iodepth=32
fio-3.29
Starting 1 process
Jobs: 1 (f=1): [R(1)][5.0%][r=6831MiB/s][r=6830 IOPS][eta 00Jobs: 1 (f=1): [R(1)][6.7%][r=6832MiB/s][r=6832 IOPS][eta 00Jobs: 1 (f=1): [R(1)][8.3%][r=6830MiB/s][r=6830 IOPS][eta 00Jobs: 1 (f=1): [R(1)][10.0%][r=6832MiB/s][r=6831 IOPS][eta 0Jobs: 1 (f=1): [R(1)][11.7%][r=6831MiB/s][r=6831 IOPS][eta 0Jobs: 1 (f=1): [R(1)][13.3%][r=6831MiB/s][r=6831 IOPS][eta 0Jobs: 1 (f=1): [R(1)][15.0%][r=6832MiB/s][r=6831 IOPS][eta 0Jobs: 1 (f=1): [R(1)][16.7%][r=6831MiB/s][r=6831 IOPS][eta 0Jobs: 1 (f=1): [R(1)][18.3%][r=6832MiB/s][r=6832 IOPS][eta 0Jobs: 1 (f=1): [R(1)][20.0%][r=6831MiB/s][r=6830 IOPS][eta 0Jobs: 1 (f=1): [R(1)][21.7%][r=6832MiB/s][r=6832 IOPS][eta 0Jobs: 1 (f=1): [R(1)][23.3%][r=6832MiB/s][r=6832 IOPS][eta 0Jobs: 1 (f=1): [R(1)][25.0%][r=6831MiB/s][r=6830 IOPS][eta 0Jobs: 1 (f=1): [R(1)][26.7%][r=6831MiB/s][r=6831 IOPS][eta 0Jobs: 1 (f=1): [R(1)][28.3%][r=6833MiB/s][r=6833 IOPS][eta 0Jobs: 1 (f=1): [R(1)][30.0%][r=6830MiB/s][r=6829 IOPS][eta 0Jobs: 1 (f=1): [R(1)][31.7%][r=6832MiB/s][r=6832 IOPS][eta 0Jobs: 1 (f=1): [R(1)][33.3%][r=6829MiB/s][r=6829 IOPS][eta 0Jobs: 1 (f=1): [R(1)][35.0%][r=6831MiB/s][r=6830 IOPS][eta 0Jobs: 1 (f=1): [R(1)][36.7%][r=6831MiB/s][r=6831 IOPS][eta 0Jobs: 1 (f=1): [R(1)][39.0%][r=6832MiB/s][r=6832 IOPS][eta 0Jobs: 1 (f=1): [R(1)][40.0%][r=6831MiB/s][r=6830 IOPS][eta 0Jobs: 1 (f=1): [R(1)][41.7%][r=6832MiB/s][r=6832 IOPS][eta 0Jobs: 1 (f=1): [R(1)][43.3%][r=6831MiB/s][r=6831 IOPS][eta 0Jobs: 1 (f=1): [R(1)][45.0%][r=6832MiB/s][r=6831 IOPS][eta 0Jobs: 1 (f=1): [R(1)][46.7%][r=6831MiB/s][r=6831 IOPS][eta 0Jobs: 1 (f=1): [R(1)][48.3%][r=6829MiB/s][r=6829 IOPS][eta 0Jobs: 1 (f=1): [R(1)][50.0%][r=6831MiB/s][r=6830 IOPS][eta 0Jobs: 1 (f=1): [R(1)][52.5%][r=6832MiB/s][r=6832 IOPS][eta 0Jobs: 1 (f=1): [R(1)][53.3%][r=6832MiB/s][r=6832 IOPS][eta 0Jobs: 1 (f=1): [R(1)][55.9%][r=6831MiB/s][r=6830 IOPS][eta 0Jobs: 1 (f=1): [R(1)][56.7%][r=6832MiB/s][r=6832 IOPS][eta 0Jobs: 1 (f=1): [R(1)][59.3%][r=6832MiB/s][r=6832 IOPS][eta 0Jobs: 1 (f=1): [R(1)][60.0%][r=6831MiB/s][r=6830 IOPS][eta 0Jobs: 1 (f=1): [R(1)][61.7%][r=6831MiB/s][r=6831 IOPS][eta 0Jobs: 1 (f=1): [R(1)][63.3%][r=6831MiB/s][r=6831 IOPS][eta 0Jobs: 1 (f=1): [R(1)][65.0%][r=6832MiB/s][r=6831 IOPS][eta 0Jobs: 1 (f=1): [R(1)][66.7%][r=6832MiB/s][r=6832 IOPS][eta 0Jobs: 1 (f=1): [R(1)][68.3%][r=6830MiB/s][r=6830 IOPS][eta 0Jobs: 1 (f=1): [R(1)][70.0%][r=6831MiB/s][r=6830 IOPS][eta 0Jobs: 1 (f=1): [R(1)][71.7%][r=6830MiB/s][r=6830 IOPS][eta 0Jobs: 1 (f=1): [R(1)][73.3%][r=6830MiB/s][r=6830 IOPS][eta 0Jobs: 1 (f=1): [R(1)][75.0%][r=6831MiB/s][r=6830 IOPS][eta 0Jobs: 1 (f=1): [R(1)][78.0%][r=6832MiB/s][r=6832 IOPS][eta 0Jobs: 1 (f=1): [R(1)][78.3%][r=6830MiB/s][r=6830 IOPS][eta 0Jobs: 1 (f=1): [R(1)][80.0%][r=6831MiB/s][r=6830 IOPS][eta 0Jobs: 1 (f=1): [R(1)][81.7%][r=6832MiB/s][r=6832 IOPS][eta 0Jobs: 1 (f=1): [R(1)][83.3%][r=6831MiB/s][r=6831 IOPS][eta 0Jobs: 1 (f=1): [R(1)][85.0%][r=6832MiB/s][r=6831 IOPS][eta 0Jobs: 1 (f=1): [R(1)][86.7%][r=6832MiB/s][r=6832 IOPS][eta 0Jobs: 1 (f=1): [R(1)][88.3%][r=6830MiB/s][r=6829 IOPS][eta 0Jobs: 1 (f=1): [R(1)][90.0%][r=6832MiB/s][r=6832 IOPS][eta 0Jobs: 1 (f=1): [R(1)][91.7%][r=6832MiB/s][r=6832 IOPS][eta 0Jobs: 1 (f=1): [R(1)][93.3%][r=6828MiB/s][r=6827 IOPS][eta 0Jobs: 1 (f=1): [R(1)][95.0%][r=6831MiB/s][r=6831 IOPS][eta 0Jobs: 1 (f=1): [R(1)][96.7%][r=6832MiB/s][r=6832 IOPS][eta 0Jobs: 1 (f=1): [R(1)][98.3%][r=6831MiB/s][r=6830 IOPS][eta 0Jobs: 1 (f=1): [R(1)][100.0%][r=6832MiB/s][r=6832 IOPS][eta 00m:00s]
nvme_seq_read_1m: (groupid=0, jobs=1): err= 0: pid=14552: Fri Mar 20 12:47:23 2026
read: IOPS=6818, BW=6818MiB/s (7149MB/s)(400GiB/60003msec)
slat (usec): min=4, max=190, avg= 5.84, stdev= 4.10
clat (usec): min=1425, max=12244, avg=4686.91, stdev=258.10
lat (usec): min=1575, max=12250, avg=4692.84, stdev=258.17
clat percentiles (usec):
|  1.00th=[ 4490],  5.00th=[ 4490], 10.00th=[ 4555], 20.00th=[ 4555],
| 30.00th=[ 4555], 40.00th=[ 4621], 50.00th=[ 4686], 60.00th=[ 4752],
| 70.00th=[ 4752], 80.00th=[ 4817], 90.00th=[ 4817], 95.00th=[ 4883],
| 99.00th=[ 4883], 99.50th=[ 4948], 99.90th=[11076], 99.95th=[11600],
| 99.99th=[11994]
bw (  MiB/s): min= 5518, max= 6836, per=100.00%, avg=6820.13, stdev=120.40, samples=119
iops        : min= 5518, max= 6836, avg=6820.13, stdev=120.40, samples=119
lat (msec)   : 2=0.01%, 4=0.05%, 10=99.85%, 20=0.10%
cpu          : usr=1.06%, sys=3.62%, ctx=403002, majf=0, minf=551
IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
issued rwts: total=409101,0,0,0 short=0,0,0,0 dropped=0,0,0,0
latency   : target=0, window=0, percentile=100.00%, depth=32
Run status group 0 (all jobs):
READ: bw=6818MiB/s (7149MB/s), 6818MiB/s-6818MiB/s (7149MB/s-7149MB/s), io=400GiB (429GB), run=60003-60003msec
Disk stats (read/write):
nvme0n1: ios=420996/0, merge=0/0, ticks=1971061/0, in_queue=1971060, util=99.85%
Iostat -x 1 nvme0n1
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
```

0.01    0.00    0.03    0.00    0.00   99.96

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       7044.00 6990848.00     0.00   0.00    4.67   992.45    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   32.92 100.00


avg-cpu:  %user   %nice %system %iowait  %steal   %idle
0.01    0.00    0.03    0.00    0.00   99.96

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       7041.00 6992896.00     0.00   0.00    4.67   993.17    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   32.92 100.00



3）128K 顺序写
fio --name=nvme_seq_write_128k \
    --filename=/dev/nvme0n1 \
    --direct=1 \
    --ioengine=libaio \
    --rw=write \
    --bs=128K \
    --iodepth=32 \
    --numjobs=1 \
    --offset=4G \
    --size=20G \
    --runtime=60 \
    --time_based \
    --group_reporting


```bash
[root@bogon ~]# fio --name=nvme_seq_write_128k \
>     --filename=/dev/nvme0n1 \
>     --direct=1 \
>     --ioengine=libaio \
>     --rw=write \
>     --bs=128K \
>     --iodepth=32 \
>     --numjobs=1 \
>     --offset=4G \
>     --size=20G \
>     --runtime=60 \
>     --time_based \
>     --group_reporting
nvme_seq_write_128k: (g=0): rw=write, bs=(R) 128KiB-128KiB, (W) 128KiB-128KiB, (T) 128KiB-128KiB, ioengine=libaio, iodepth=32
fio-3.29
Starting 1 process
Jobs: 1 (f=1): [W(1)][5.0%][w=4640MiB/s][w=37.1k IOPS][eta 0Jobs: 1 (f=1): [W(1)][6.7%][w=4633MiB/s][w=37.1k IOPS][eta 0Jobs: 1 (f=1): [W(1)][8.3%][w=4653MiB/s][w=37.2k IOPS][eta 0Jobs: 1 (f=1): [W(1)][10.0%][w=4662MiB/s][w=37.3k IOPS][eta Jobs: 1 (f=1): [W(1)][11.7%][w=4641MiB/s][w=37.1k IOPS][eta Jobs: 1 (f=1): [W(1)][13.3%][w=4668MiB/s][w=37.3k IOPS][eta Jobs: 1 (f=1): [W(1)][15.0%][w=4626MiB/s][w=37.0k IOPS][eta Jobs: 1 (f=1): [W(1)][16.7%][w=4662MiB/s][w=37.3k IOPS][eta Jobs: 1 (f=1): [W(1)][18.3%][w=4647MiB/s][w=37.2k IOPS][eta Jobs: 1 (f=1): [W(1)][20.0%][w=4656MiB/s][w=37.3k IOPS][eta Jobs: 1 (f=1): [W(1)][21.7%][w=4635MiB/s][w=37.1k IOPS][eta Jobs: 1 (f=1): [W(1)][23.3%][w=4653MiB/s][w=37.2k IOPS][eta Jobs: 1 (f=1): [W(1)][25.0%][w=4656MiB/s][w=37.2k IOPS][eta Jobs: 1 (f=1): [W(1)][26.7%][w=4636MiB/s][w=37.1k IOPS][eta Jobs: 1 (f=1): [W(1)][28.3%][w=4617MiB/s][w=36.9k IOPS][eta Jobs: 1 (f=1): [W(1)][30.0%][w=4640MiB/s][w=37.1k IOPS][eta Jobs: 1 (f=1): [W(1)][31.7%][w=4637MiB/s][w=37.1k IOPS][eta Jobs: 1 (f=1): [W(1)][33.3%][w=4636MiB/s][w=37.1k IOPS][eta Jobs: 1 (f=1): [W(1)][35.0%][w=4658MiB/s][w=37.3k IOPS][eta Jobs: 1 (f=1): [W(1)][36.7%][w=4651MiB/s][w=37.2k IOPS][eta Jobs: 1 (f=1): [W(1)][39.0%][w=4667MiB/s][w=37.3k IOPS][eta Jobs: 1 (f=1): [W(1)][40.0%][w=4634MiB/s][w=37.1k IOPS][eta Jobs: 1 (f=1): [W(1)][41.7%][w=4651MiB/s][w=37.2k IOPS][eta Jobs: 1 (f=1): [W(1)][43.3%][w=4656MiB/s][w=37.2k IOPS][eta Jobs: 1 (f=1): [W(1)][45.0%][w=4664MiB/s][w=37.3k IOPS][eta Jobs: 1 (f=1): [W(1)][46.7%][w=4665MiB/s][w=37.3k IOPS][eta Jobs: 1 (f=1): [W(1)][48.3%][w=4658MiB/s][w=37.3k IOPS][eta Jobs: 1 (f=1): [W(1)][50.0%][w=4655MiB/s][w=37.2k IOPS][eta Jobs: 1 (f=1): [W(1)][52.5%][w=4661MiB/s][w=37.3k IOPS][eta Jobs: 1 (f=1): [W(1)][53.3%][w=4653MiB/s][w=37.2k IOPS][eta Jobs: 1 (f=1): [W(1)][55.9%][w=4635MiB/s][w=37.1k IOPS][eta Jobs: 1 (f=1): [W(1)][56.7%][w=4632MiB/s][w=37.1k IOPS][eta Jobs: 1 (f=1): [W(1)][59.3%][w=4674MiB/s][w=37.4k IOPS][eta Jobs: 1 (f=1): [W(1)][60.0%][w=4625MiB/s][w=37.0k IOPS][eta Jobs: 1 (f=1): [W(1)][61.7%][w=4632MiB/s][w=37.1k IOPS][eta Jobs: 1 (f=1): [W(1)][63.3%][w=4647MiB/s][w=37.2k IOPS][eta Jobs: 1 (f=1): [W(1)][65.0%][w=4645MiB/s][w=37.2k IOPS][eta Jobs: 1 (f=1): [W(1)][66.7%][w=4635MiB/s][w=37.1k IOPS][eta Jobs: 1 (f=1): [W(1)][68.3%][w=4659MiB/s][w=37.3k IOPS][eta Jobs: 1 (f=1): [W(1)][70.0%][w=4602MiB/s][w=36.8k IOPS][eta Jobs: 1 (f=1): [W(1)][71.7%][w=4653MiB/s][w=37.2k IOPS][eta Jobs: 1 (f=1): [W(1)][73.3%][w=4638MiB/s][w=37.1k IOPS][eta Jobs: 1 (f=1): [W(1)][75.0%][w=4639MiB/s][w=37.1k IOPS][eta Jobs: 1 (f=1): [W(1)][78.0%][w=4640MiB/s][w=37.1k IOPS][eta Jobs: 1 (f=1): [W(1)][78.3%][w=4639MiB/s][w=37.1k IOPS][eta Jobs: 1 (f=1): [W(1)][80.0%][w=4671MiB/s][w=37.4k IOPS][eta Jobs: 1 (f=1): [W(1)][81.7%][w=4626MiB/s][w=37.0k IOPS][eta Jobs: 1 (f=1): [W(1)][83.3%][w=4665MiB/s][w=37.3k IOPS][eta Jobs: 1 (f=1): [W(1)][85.0%][w=4652MiB/s][w=37.2k IOPS][eta Jobs: 1 (f=1): [W(1)][86.7%][w=4649MiB/s][w=37.2k IOPS][eta Jobs: 1 (f=1): [W(1)][88.3%][w=4667MiB/s][w=37.3k IOPS][eta Jobs: 1 (f=1): [W(1)][90.0%][w=4635MiB/s][w=37.1k IOPS][eta Jobs: 1 (f=1): [W(1)][91.7%][w=4643MiB/s][w=37.1k IOPS][eta Jobs: 1 (f=1): [W(1)][93.3%][w=4667MiB/s][w=37.3k IOPS][eta Jobs: 1 (f=1): [W(1)][95.0%][w=4634MiB/s][w=37.1k IOPS][eta Jobs: 1 (f=1): [W(1)][96.7%][w=4650MiB/s][w=37.2k IOPS][eta Jobs: 1 (f=1): [W(1)][98.3%][w=4622MiB/s][w=37.0k IOPS][eta Jobs: 1 (f=1): [W(1)][100.0%][w=4663MiB/s][w=37.3k IOPS][eta 00m:00s]
nvme_seq_write_128k: (groupid=0, jobs=1): err= 0: pid=14555: Fri Mar 20 12:48:46 2026
write: IOPS=37.0k, BW=4630MiB/s (4855MB/s)(271GiB/60001msec); 0 zone resets
slat (nsec): min=3400, max=178993, avg=4628.10, stdev=729.49
clat (usec): min=442, max=5069, avg=858.64, stdev=195.18
lat (usec): min=446, max=5073, avg=863.36, stdev=195.22
clat percentiles (usec):
|  1.00th=[  586],  5.00th=[  603], 10.00th=[  635], 20.00th=[  693],
| 30.00th=[  750], 40.00th=[  799], 50.00th=[  840], 60.00th=[  889],
| 70.00th=[  947], 80.00th=[ 1020], 90.00th=[ 1090], 95.00th=[ 1123],
| 99.00th=[ 1205], 99.50th=[ 1352], 99.90th=[ 2900], 99.95th=[ 3294],
| 99.99th=[ 3884]
bw (  MiB/s): min= 2956, max= 4699, per=100.00%, avg=4631.31, stdev=157.03, samples=119
iops        : min=23652, max=37594, avg=37050.45, stdev=1256.25, samples=119
lat (usec)   : 500=0.01%, 750=30.76%, 1000=46.86%
lat (msec)   : 2=22.12%, 4=0.26%, 10=0.01%
cpu          : usr=11.54%, sys=10.54%, ctx=2221134, majf=0, minf=16
IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
issued rwts: total=0,2222602,0,0 short=0,0,0,0 dropped=0,0,0,0
latency   : target=0, window=0, percentile=100.00%, depth=32
Run status group 0 (all jobs):
WRITE: bw=4630MiB/s (4855MB/s), 4630MiB/s-4630MiB/s (4855MB/s-4855MB/s), io=271GiB (291GB), run=60001-60001msec
Disk stats (read/write):
nvme0n1: ios=46/2216768, merge=0/0, ticks=2/1902348, in_queue=1902350, util=99.85%
Iostat -x 1 nvme0n1
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
```

0.05    0.00    0.07    0.00    0.00   99.87

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1          0.00      0.00     0.00   0.00    0.00     0.00 36939.00 4728192.00     0.00   0.00    0.86   128.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   31.79 100.00


avg-cpu:  %user   %nice %system %iowait  %steal   %idle
0.04    0.00    0.07    0.00    0.00   99.89

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1          0.00      0.00     0.00   0.00    0.00     0.00 37106.00 4749568.00     0.00   0.00    0.86   128.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   31.80 100.00



4）128K 顺序读
fio --name=nvme_seq_read_128k \
    --filename=/dev/nvme0n1 \
    --direct=1 \
    --ioengine=libaio \
    --rw=read \
    --bs=128K \
    --iodepth=32 \
    --numjobs=1 \
    --offset=4G \
    --size=20G \
    --runtime=60 \
    --time_based \
    --group_reporting

```bash
[root@bogon ~]# fio --name=nvme_seq_read_128k \
>     --filename=/dev/nvme0n1 \
>     --direct=1 \
>     --ioengine=libaio \
>     --rw=read \
>     --bs=128K \
>     --iodepth=32 \
>     --numjobs=1 \
>     --offset=4G \
>     --size=20G \
>     --runtime=60 \
>     --time_based \
>     --group_reporting
nvme_seq_read_128k: (g=0): rw=read, bs=(R) 128KiB-128KiB, (W) 128KiB-128KiB, (T) 128KiB-128KiB, ioengine=libaio, iodepth=32
fio-3.29
Starting 1 process
Jobs: 1 (f=1): [R(1)][5.0%][r=6824MiB/s][r=54.6k IOPS][eta 00m:57s]
Jobs: 1 (f=1): [R(1)][6.7%][r=6824MiB/s][r=54.6k IOPS][eta 0Jobs: 1 (f=1): [R(1)][8.3%][r=6824MiB/s][r=54.6k IOPS][eta 0Jobs: 1 (f=1): [R(1)][10.0%][r=6823MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][11.7%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][13.3%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][15.0%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][16.7%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][18.3%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][20.0%][r=6823MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][21.7%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][23.3%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][25.0%][r=6823MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][26.7%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][28.3%][r=6823MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][30.0%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][31.7%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][33.3%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][35.0%][r=6823MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][36.7%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][39.0%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][40.0%][r=6823MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][41.7%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][43.3%][r=6823MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][45.0%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][46.7%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][48.3%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][50.0%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][52.5%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][53.3%][r=6823MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][55.9%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][56.7%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][59.3%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][60.0%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][61.7%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][63.3%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][65.0%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][66.7%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][68.3%][r=6823MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][70.0%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][71.7%][r=6823MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][73.3%][r=6796MiB/s][r=54.4k IOPS][eta Jobs: 1 (f=1): [R(1)][75.0%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][78.0%][r=6799MiB/s][r=54.4k IOPS][eta Jobs: 1 (f=1): [R(1)][78.3%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][80.0%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][81.7%][r=6823MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][83.3%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][85.0%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][86.7%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][88.3%][r=6823MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][90.0%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][91.7%][r=6823MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][93.3%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][95.0%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][96.7%][r=6824MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][98.3%][r=6823MiB/s][r=54.6k IOPS][eta Jobs: 1 (f=1): [R(1)][100.0%][r=6824MiB/s][r=54.6k IOPS][eta 00m:00s]
nvme_seq_read_128k: (groupid=0, jobs=1): err= 0: pid=14561: Fri Mar 20 12:50:15 2026
read: IOPS=54.5k, BW=6811MiB/s (7141MB/s)(399GiB/60001msec)
slat (nsec): min=1730, max=291009, avg=3577.02, stdev=1442.43
clat (usec): min=38, max=3143, avg=583.19, stdev=130.97
lat (usec): min=41, max=3146, avg=586.86, stdev=130.95
clat percentiles (usec):
|  1.00th=[  355],  5.00th=[  392], 10.00th=[  424], 20.00th=[  461],
| 30.00th=[  494], 40.00th=[  537], 50.00th=[  570], 60.00th=[  611],
| 70.00th=[  660], 80.00th=[  709], 90.00th=[  758], 95.00th=[  791],
| 99.00th=[  865], 99.50th=[  898], 99.90th=[ 1106], 99.95th=[ 1467],
| 99.99th=[ 2057]
bw (  MiB/s): min= 5623, max= 6825, per=100.00%, avg=6812.69, stdev=110.15, samples=119
iops        : min=44988, max=54604, avg=54501.51, stdev=881.16, samples=119
lat (usec)   : 50=0.01%, 100=0.01%, 250=0.01%, 500=31.21%, 750=57.05%
lat (usec)   : 1000=11.59%
lat (msec)   : 2=0.13%, 4=0.01%
cpu          : usr=6.28%, sys=17.78%, ctx=2232630, majf=0, minf=531
IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
issued rwts: total=3269155,0,0,0 short=0,0,0,0 dropped=0,0,0,0
latency   : target=0, window=0, percentile=100.00%, depth=32
Run status group 0 (all jobs):
READ: bw=6811MiB/s (7141MB/s), 6811MiB/s-6811MiB/s (7141MB/s-7141MB/s), io=399GiB (428GB), run=60001-60001msec
Disk stats (read/write):
nvme0n1: ios=3262600/0, merge=0/0, ticks=1896955/0, in_queue=1896955, util=99.85%
Iostat -x 1 nvme0n1
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
```

0.04    0.00    0.14    0.00    0.00   99.83

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       54568.00 6984704.00     0.00   0.00    0.58   128.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   31.68 100.00


avg-cpu:  %user   %nice %system %iowait  %steal   %idle
0.02    0.00    0.13    0.00    0.00   99.85

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       54575.00 6985600.00     0.00   0.00    0.58   128.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   31.66 100.00







本机 nvme0n1 在 bs=1M/128K、iodepth=32 条件下的顺序读写带宽基线是多少；对应 iostat 中的 rkB/s、wkB/s、await、%util 分别是多少。

Day8 结论
本机 nvme0n1 在 iodepth=32 条件下：

顺序写基线大约是 4.63 GiB/s


顺序读基线大约是 6.81 GiB/s


fio 和 iostat 的带宽、等待时间基本都能对齐


%util 接近 100%，说明在这组参数下盘已经基本跑满

你可以直接记到笔记里的总结
在 bs=1M/128K、iodepth=32、numjobs=1、direct=1 条件下，nvme0n1 的顺序写带宽稳定在 4.6 GiB/s 左右，顺序读带宽稳定在 6.8 GiB/s 左右；fio 输出与 iostat -x 1 中的 rkB/s / wkB/s、await 基本一致，说明本次 NVMe 顺序性能基线结果可信。
顺手帮你提炼一个观察点
这 4 组里最值得你记住的是：

读带宽明显高于写带宽


1M 和 128K 两组带宽上限差别不大


块更小以后，IOPS 明显升高，await 明显降低


这说明这块盘在当前平台下，顺序吞吐上限大致已经被摸出来了

这样 Day8 就算完整结束了。
下一步最自然就是进 Day9：随机读写基线（4K randread/randwrite


## 硬件对照表

| 测试项 | 目标盘 |
|---|---|
| seq_write_1m | nvme0n1 |
|---|---|


## 硬件对照表

| 测试项 | 目标盘 |
|---|---|
| seq_write_1m | nvme0n1 |
|---|---|
| seq_read_1m | nvme0n1 |
|---|---|
| seq_write_128k | nvme0n1 |
|---|---|
| seq_read_128k | nvme0n1 |
|---|---|


## 硬件对照表

| 测试项 | 目标盘 |
|---|---|
| seq_write_1m | nvme0n1 |
|---|---|
| seq_read_1m | nvme0n1 |
|---|---|
| seq_write_128k | nvme0n1 |
|---|---|
| seq_read_128k | nvme0n1 |
|---|---|

