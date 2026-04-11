下一步就接 Day10：iodepth、numjobs 对随机性能的影响。
因为你现在已经有了两套基线：

Day8：顺序读写基线


Day9：4K 随机读写基线

再往下最自然的不是换盘型知识，而是继续把 “同一块 NVMe 为什么参数一变，性能就变” 这件事吃透。这个会直接决定你以后会不会设计性能测试。
你 Day10 的核心目标是：
固定盘、固定 4K randread/randwrite，只改变 iodepth 和 numjobs，观察 IOPS、clat、p99、util 怎么变化。
建议这样做最顺：
先测 4K randread，numjobs=1 不变，只改 iodepth：

1


4


8


16


32


64

然后再固定 iodepth=32，改 numjobs：

1


2


4


8

随机写也可以同样来一轮，但先把随机读跑明白就够了。
你最终要得到的不是一堆数字，而是三个结论：

iodepth 增大时，IOPS 怎么升，延迟怎么变


numjobs 增大时，是更容易把盘打满，还是只是把尾延迟拉差


你这块 nvme0n1 的“甜点区”大概在哪个参数组合

最有用的产出是一个表：
如果你同意，我们下一条就直接开始 Day10 实操版，我把第一组命令按你现在这台机的环境直接给你。



好，开始 Day10。
Day10：iodepth、numjobs 对 4K 随机性能的影响
今天不换盘、不换块大小，还是用你已经验证好的测试盘：

目标盘：nvme0n1


测试类型：先做 4K randread


目的：看参数变化怎么影响


IOPS


BW


clat avg


p99


await


%util


### 今天为什么要做这个

Day8、Day9 你已经知道：

顺序读写大概上限是多少


4K 随机读写大概上限是多少

但你现在还不知道一件关键事：
这些性能，是盘本身“天然就这样”，还是你这组参数“喂出来”的？
Day10 就是专门回答这个问题。
因为同一块盘，下面这些一改，结果就会变：

iodepth


numjobs

你以后做性能测试，如果不理解这两个参数，就很容易：

跑出“看起来很高”的数字，但没意义


跑出“很低”的数字，然后误以为盘有问题


不知道该怎么复现别人的结果


### 先把两个参数讲透

1）iodepth
你先把它理解成：
单个 job 同时挂在设备前面的 I/O 深度
比如：

iodepth=1：发一个，等一个


iodepth=32：同时挂 32 个请求在队列里

它主要影响：

设备队列利用率


IOPS 能不能被拉起来


延迟会不会变大

直觉上：

depth 小：更像“一个一个问”


depth 大：更像“先排很多单子一起处理”


2）numjobs
你先把它理解成：
并发发起 I/O 的 job 数量
比如：

numjobs=1：一个线程/作业打盘


numjobs=4：四个并发 job 一起打盘

它更像“并发来源数”。
直觉上：

iodepth 是单路有多深


numjobs 是有多少路同时来


### 你今天最重要的一句理解

总并发压力 ≈ iodepth × numjobs
这不是绝对精确公式，但足够你建立直觉。
比如：

iodepth=32, numjobs=1 → 总体并发大致 32


iodepth=8, numjobs=4 → 总体并发也大致 32

但这两者结果未必一样，因为：

一个是单路深队列


一个是多路并发浅队列

这就是 Day10 要观察的重点。

### 今天的测试设计

为了不把变量搞乱，今天分两段做。
第一段：只改 iodepth
固定：

rw=randread


bs=4K


numjobs=1

只改：

iodepth=1


iodepth=4


iodepth=8


iodepth=16


iodepth=32


iodepth=64

这样你能看出：
单 job 下，队列越深，盘性能怎么变化

第二段：只改 numjobs
固定：

rw=randread


bs=4K


iodepth=32

只改：

numjobs=1


numjobs=2


numjobs=4


numjobs=8

这样你能看出：
固定单路深度后，多路并发再加上去，收益还有多大

### 先开监控窗口

一个终端开着：
iostat -x 1 nvme0n1
今天比 Day9 更要盯：

r/s


rkB/s


await


aqu-sz


%util

尤其是：
aqu-sz
这个基本可以帮助你感受：

实际设备队列是不是堆起来了


你设置的 iodepth 有没有真正形成设备层排队


### 第一段：iodepth 扫描

先统一命令模板：
fio --name=randread_4k_qdX \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=X \
--numjobs=1 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
你把 X 换掉就行。

1）QD=1
fio --name=randread_4k_qd1 \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=1 \
--numjobs=1 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
2）QD=4
fio --name=randread_4k_qd4 \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=4 \
--numjobs=1 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
3）QD=8
fio --name=randread_4k_qd8 \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=8 \
--numjobs=1 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
4）QD=16
fio --name=randread_4k_qd16 \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=16 \
--numjobs=1 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
5）QD=32
fio --name=randread_4k_qd32 \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=32 \
--numjobs=1 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
6）QD=64
fio --name=randread_4k_qd64 \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=64 \
--numjobs=1 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting

### 第二段：numjobs 扫描

这里固定：

iodepth=32

模板：
fio --name=randread_4k_jobsY \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=32 \
--numjobs=Y \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting

jobs=1
fio --name=randread_4k_jobs1 \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=32 \
--numjobs=1 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
jobs=2
fio --name=randread_4k_jobs2 \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=32 \
--numjobs=2 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
jobs=4
fio --name=randread_4k_jobs4 \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=32 \
--numjobs=4 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
jobs=8
fio --name=randread_4k_jobs8 \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=32 \
--numjobs=8 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting

### 今天怎么记表

你可以直接记这两个表。
表1：iodepth 影响
表2：numjobs 影响

### 今天你要观察什么趋势

先别等结果出来才想，先带着问题看。
看 iodepth
通常你会看到：

QD1 时 IOPS 比较低，但延迟很好看


QD 往上加，IOPS 会明显升


到某个点以后，IOPS 增长开始变慢


但延迟、p99、await 会继续变差

也就是说：
队列不是越深越“值”，它会有甜点区。

看 numjobs
通常会看到：

jobs 从 1 到 2、4，可能还有收益


再往上未必线性增长


util 早就接近 100% 后，再加 jobs 主要可能是在抢资源


尾延迟可能比平均延迟恶化得更明显


### 今天最低完成标准

如果你不想一次跑太多，先完成最核心的 4 组也可以：

iodepth=1, numjobs=1


iodepth=8, numjobs=1


iodepth=32, numjobs=1


iodepth=64, numjobs=1

先把 iodepth 曲线做出来，再补 numjobs。

### 最推荐你现在就开始的第一组

先开：
iostat -x 1 nvme0n1
然后跑：
fio --name=randread_4k_qd1 \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=1 \
--numjobs=1 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
你把 QD1 这组 fio + iostat 发我，我先帮你填 Day10 第一行，然后我们继续看 QD8、QD32、QD64 的变化。



>     --iodepth=1 \


```bash
[root@bogon ~]# fio --name=randread_4k_qd1 \
>     --filename=/dev/nvme0n1 \
>     --direct=1 \
>     --ioengine=libaio \
>     --rw=randread \
>     --bs=4K \
>     --iodepth=1 \
>     --numjobs=1 \
>     --offset=4G \
>     --size=20G \
>     --runtime=60 \
>     --time_based \
>     --group_reporting
randread_4k_qd1: (g=0): rw=randread, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=1
fio-3.29
Starting 1 process
Jobs: 1 (f=1): [r(1)][5.0%][r=48.6MiB/s][r=12.4k IOPS][eta 0Jobs: 1 (f=1): [r(1)][6.7%][r=48.5MiB/s][r=12.4k IOPS][eta 0Jobs: 1 (f=1): [r(1)][8.3%][r=48.4MiB/s][r=12.4k IOPS][eta 0Jobs: 1 (f=1): [r(1)][10.0%][r=48.6MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][11.7%][r=48.6MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][13.3%][r=48.5MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][15.0%][r=52.1MiB/s][r=13.3k IOPS][eta Jobs: 1 (f=1): [r(1)][16.7%][r=52.1MiB/s][r=13.3k IOPS][eta Jobs: 1 (f=1): [r(1)][18.3%][r=48.5MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][20.0%][r=48.4MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][21.7%][r=48.3MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][23.3%][r=48.3MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][25.0%][r=48.5MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][26.7%][r=48.4MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][28.3%][r=48.4MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][30.0%][r=48.3MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][31.7%][r=48.6MiB/s][r=12.5k IOPS][eta Jobs: 1 (f=1): [r(1)][33.3%][r=48.4MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][35.0%][r=48.3MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][36.7%][r=48.5MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][38.3%][r=48.6MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][40.0%][r=48.4MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][41.7%][r=48.4MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][43.3%][r=48.5MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][45.0%][r=48.5MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][46.7%][r=48.4MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][48.3%][r=48.5MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][50.0%][r=48.5MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][51.7%][r=48.4MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][53.3%][r=48.4MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][55.0%][r=48.4MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][56.7%][r=48.4MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][58.3%][r=48.5MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][60.0%][r=48.4MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][61.7%][r=48.4MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][63.3%][r=48.6MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][65.0%][r=52.1MiB/s][r=13.3k IOPS][eta Jobs: 1 (f=1): [r(1)][66.7%][r=52.1MiB/s][r=13.3k IOPS][eta Jobs: 1 (f=1): [r(1)][68.3%][r=48.5MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][70.0%][r=48.6MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][71.7%][r=48.4MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][73.3%][r=48.5MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][75.0%][r=48.5MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][76.7%][r=48.7MiB/s][r=12.5k IOPS][eta Jobs: 1 (f=1): [r(1)][78.3%][r=48.4MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][80.0%][r=48.5MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][81.7%][r=48.6MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][83.3%][r=48.4MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][85.0%][r=48.4MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][86.7%][r=48.6MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][88.3%][r=48.6MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][90.0%][r=48.6MiB/s][r=12.5k IOPS][eta Jobs: 1 (f=1): [r(1)][91.7%][r=48.5MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][93.3%][r=48.5MiB/s][r=12.4k IOPS][eta Jobs: 1 (f=1): [r(1)][95.0%][r=48.7MiB/s][r=12.5k IOPS][eta Jobs: 1 (f=1): [r(1)][96.7%][r=48.8MiB/s][r=12.5k IOPS][eta Jobs: 1 (f=1): [r(1)][98.3%][r=52.1MiB/s][r=13.3k IOPS][eta Jobs: 1 (f=1): [r(1)][100.0%][r=52.2MiB/s][r=13.4k IOPS][eta 00m:00s]
randread_4k_qd1: (groupid=0, jobs=1): err= 0: pid=14722: Fri Mar 20 14:00:40 2026
read: IOPS=12.5k, BW=48.8MiB/s (51.2MB/s)(2930MiB/60001msec)
slat (nsec): min=2220, max=368495, avg=2936.05, stdev=962.79
clat (nsec): min=450, max=366356, avg=76407.55, stdev=11639.08
lat (usec): min=21, max=404, avg=79.43, stdev=11.70
clat percentiles (usec):
|  1.00th=[   25],  5.00th=[   68], 10.00th=[   72], 20.00th=[   73],
| 30.00th=[   74], 40.00th=[   74], 50.00th=[   75], 60.00th=[   77],
| 70.00th=[   85], 80.00th=[   87], 90.00th=[   90], 95.00th=[   90],
| 99.00th=[   91], 99.50th=[   92], 99.90th=[  101], 99.95th=[  104],
| 99.99th=[  135]
bw (  KiB/s): min=49296, max=53640, per=100.00%, avg=50040.87, stdev=1059.53, samples=119
iops        : min=12324, max=13410, avg=12510.22, stdev=264.88, samples=119
lat (nsec)   : 500=0.01%, 750=0.01%
lat (usec)   : 10=0.01%, 20=0.30%, 50=2.69%, 100=96.91%, 250=0.11%
lat (usec)   : 500=0.01%
cpu          : usr=1.05%, sys=2.89%, ctx=750098, majf=0, minf=11
IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
issued rwts: total=750108,0,0,0 short=0,0,0,0 dropped=0,0,0,0
latency   : target=0, window=0, percentile=100.00%, depth=1
Run status group 0 (all jobs):
READ: bw=48.8MiB/s (51.2MB/s), 48.8MiB/s-48.8MiB/s (51.2MB/s-51.2MB/s), io=2930MiB (3072MB), run=60001-60001msec
Disk stats (read/write):
nvme0n1: ios=748682/0, merge=0/0, ticks=56545/0, in_queue=56544, util=92.00%
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
```

0.01    0.00    0.05    0.00    0.00   99.94

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       12397.33  49589.33     0.00   0.00    0.08     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.94  90.93


avg-cpu:  %user   %nice %system %iowait  %steal   %idle
0.01    0.00    0.07    0.00    0.00   99.92

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       12645.33  50581.33     0.00   0.00    0.07     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.94  92.67


很好，Day10 第一行已经出来了，而且这组数据特别有价值，因为它是 QD1 的“低并发基线”。
Day10 表1，先填第一行

这组结果怎么读
1）QD1 时，性能非常“克制”
你这组核心数字是：

IOPS = 12.5k


BW = 48.8 MiB/s


clat avg = 76.4 us


p99 = 91 us

这说明在 iodepth=1 下，盘几乎是在：
发一个，收一个，再发下一个
所以吞吐和 IOPS 都不会特别高。

2）但延迟很好看
你这里：

clat avg = 76.4 us


p99 = 91 us


await = 0.07 ~ 0.08 ms

这组延迟非常漂亮，说明：

单请求响应很快


尾延迟也不差


设备没有堆很多请求

这正是 QD1 的典型特征：
低并发、低排队、低延迟

3）aqu-sz 很关键，和你的 iodepth=1 对上了
你这里 iostat：

aqu-sz = 0.94

这几乎就是在告诉你：
设备层平均队列深度大约就是 1
这和你设置的 iodepth=1 完全一致。
这一步非常值钱，因为你已经开始看到：

fio 的参数


iostat 的设备排队状态

是能互相印证的。

4）为什么 util 没到 100%
你这里：

util ≈ 91% ~ 93%

没有像 Day9 QD32 那样贴满 100%，很正常。
因为 QD1 下：

每次只有 1 个请求


设备虽然很忙，但还没被高并发彻底喂满

所以可以记一句：
QD1 更接近低延迟单路访问，不是追求设备极限吞吐的参数。

和 Day9 的 QD32 对比，你会一下子看懂 Day10 的意义
你 Day9 的 4K randread 大概是：

326k IOPS


1272 MiB/s


clat avg ≈ 95.7 us

而现在 Day10 的 QD1 是：

12.5k IOPS


48.8 MiB/s


clat avg ≈ 76.4 us

这说明什么？
最重要的观察
IOPS 差距巨大
从 12.5k 到 326k，差了大约 26 倍
但平均延迟没有差 26 倍

QD1：76.4 us


QD32：95.7 us

也就是说：
把队列加深以后，设备能并行处理更多请求，IOPS 飙升；但单次完成延迟只略有增加。
这就是 NVMe 很强的地方。

你现在可以先记一个阶段性结论
在 4K randread, numjobs=1 条件下，iodepth=1 时 nvme0n1 的性能约为 12.5k IOPS / 48.8 MiB/s，平均完成延迟约 76 us，aqu-sz≈1，说明设备基本按单请求低排队模式运行。该参数下延迟表现很好，但无法压出设备的高 IOPS 能力。

下一步怎么跑最有意义
现在不要一个一个慢慢猜，直接跳到几个关键点最容易看出趋势：
下一组建议先跑 QD8
因为：

从 1 到 4 变化会有


但 QD8 开始通常会明显拉高 IOPS

命令：
fio --name=randread_4k_qd8 \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=8 \
--numjobs=1 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
继续保持：
iostat -x 1 nvme0n1
你把 QD8 这组 fio + iostat 发我，我就帮你把 Day10 第二行填上，然后我们再看 QD32 和 QD64。


>     --iodepth=8\

```bash
[root@bogon ~]# fio --name=randread_4k_qd8 \
>     --filename=/dev/nvme0n1 \
>     --direct=1 \
>     --ioengine=libaio \
>     --rw=randread \
>     --bs=4K \
>     --iodepth=8 \
>     --numjobs=1 \
>     --offset=4G \
>     --size=20G \
>     --runtime=60 \
>     --time_based \
>     --group_reporting
randread_4k_qd8: (g=0): rw=randread, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=8
fio-3.29
Starting 1 process
Jobs: 1 (f=1): [r(1)][5.0%][r=424MiB/s][r=109k IOPS][eta 00mJobs: 1 (f=1): [r(1)][6.7%][r=424MiB/s][r=109k IOPS][eta 00mJobs: 1 (f=1): [r(1)][8.3%][r=424MiB/s][r=109k IOPS][eta 00mJobs: 1 (f=1): [r(1)][10.0%][r=424MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][11.7%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][13.3%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][15.0%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][16.7%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][18.3%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][20.0%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][21.7%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][23.3%][r=424MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][25.0%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][26.7%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][28.3%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][30.0%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][31.7%][r=424MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][33.3%][r=424MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][35.0%][r=424MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][36.7%][r=424MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][39.0%][r=424MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][40.0%][r=424MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][41.7%][r=424MiB/s][r=108k IOPS][eta 00Jobs: 1 (f=1): [r(1)][43.3%][r=424MiB/s][r=108k IOPS][eta 00Jobs: 1 (f=1): [r(1)][45.0%][r=424MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][46.7%][r=424MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][48.3%][r=424MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][50.0%][r=424MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][52.5%][r=424MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][53.3%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][55.9%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][56.7%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][59.3%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][60.0%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][61.7%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][63.3%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][65.0%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][66.7%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][68.3%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][70.0%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][71.7%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][73.3%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][75.0%][r=425MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][78.0%][r=424MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][78.3%][r=423MiB/s][r=108k IOPS][eta 00Jobs: 1 (f=1): [r(1)][80.0%][r=424MiB/s][r=109k IOPS][eta 00Jobs: 1 (f=1): [r(1)][81.7%][r=429MiB/s][r=110k IOPS][eta 00Jobs: 1 (f=1): [r(1)][83.3%][r=432MiB/s][r=111k IOPS][eta 00Jobs: 1 (f=1): [r(1)][85.0%][r=432MiB/s][r=110k IOPS][eta 00Jobs: 1 (f=1): [r(1)][86.7%][r=432MiB/s][r=111k IOPS][eta 00Jobs: 1 (f=1): [r(1)][88.3%][r=432MiB/s][r=111k IOPS][eta 00Jobs: 1 (f=1): [r(1)][90.0%][r=432MiB/s][r=111k IOPS][eta 00Jobs: 1 (f=1): [r(1)][91.7%][r=432MiB/s][r=111k IOPS][eta 00Jobs: 1 (f=1): [r(1)][93.3%][r=432MiB/s][r=111k IOPS][eta 00Jobs: 1 (f=1): [r(1)][95.0%][r=432MiB/s][r=111k IOPS][eta 00Jobs: 1 (f=1): [r(1)][96.7%][r=432MiB/s][r=111k IOPS][eta 00Jobs: 1 (f=1): [r(1)][98.3%][r=432MiB/s][r=111k IOPS][eta 00Jobs: 1 (f=1): [r(1)][100.0%][r=432MiB/s][r=111k IOPS][eta 00m:00s]
randread_4k_qd8: (groupid=0, jobs=1): err= 0: pid=14748: Fri Mar 20 14:03:59 2026
read: IOPS=109k, BW=426MiB/s (446MB/s)(24.9GiB/60001msec)
slat (nsec): min=1250, max=80345, avg=1740.82, stdev=538.18
clat (usec): min=7, max=398, avg=71.08, stdev=15.89
lat (usec): min=14, max=399, avg=72.92, stdev=15.88
clat percentiles (usec):
|  1.00th=[   15],  5.00th=[   62], 10.00th=[   62], 20.00th=[   63],
| 30.00th=[   64], 40.00th=[   65], 50.00th=[   67], 60.00th=[   72],
| 70.00th=[   77], 80.00th=[   80], 90.00th=[   83], 95.00th=[   99],
| 99.00th=[  129], 99.50th=[  137], 99.90th=[  155], 99.95th=[  167],
| 99.99th=[  190]
bw (  KiB/s): min=412640, max=443280, per=100.00%, avg=435991.87, stdev=3734.46, samples=119
iops        : min=103160, max=110822, avg=108997.97, stdev=933.62, samples=119
lat (usec)   : 10=0.01%, 20=1.85%, 50=0.78%, 100=92.50%, 250=4.86%
lat (usec)   : 500=0.01%
cpu          : usr=11.15%, sys=18.34%, ctx=3780366, majf=0, minf=22
IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=100.0%, 16=0.0%, 32=0.0%, >=64=0.0%
submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
complete  : 0=0.0%, 4=100.0%, 8=0.1%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
issued rwts: total=6538703,0,0,0 short=0,0,0,0 dropped=0,0,0,0
latency   : target=0, window=0, percentile=100.00%, depth=8
Run status group 0 (all jobs):
READ: bw=426MiB/s (446MB/s), 426MiB/s-426MiB/s (446MB/s-446MB/s), io=24.9GiB (26.8GB), run=60001-60001msec
Disk stats (read/write):
nvme0n1: ios=6525500/0, merge=0/0, ticks=452450/0, in_queue=452450, util=99.85%
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
```

0.04    0.00    0.13    0.00    0.00   99.83

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       108452.33 433809.33     0.00   0.00    0.07     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    7.56 100.00


avg-cpu:  %user   %nice %system %iowait  %steal   %idle
0.05    0.00    0.13    0.00    0.00   99.82

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       108524.67 434098.67     0.00   0.00    0.07     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    7.56 100.00


很好，QD8 这组已经把趋势拉出来了。
Day10 表1，补第二行

这组最关键的变化
和 QD1 比，QD8 的变化非常典型：
1）IOPS 直接大幅拉升

QD1：12.5k


QD8：109k

差不多提升了 8.7 倍
这很符合直觉：

队列从 1 变 8


设备并行能力被放出来了


IOPS 明显上升


2）带宽也同步上来了

QD1：48.8 MiB/s


QD8：426 MiB/s

也提升了大约 8.7 倍
因为这里还是：

4K 随机读


IOPS 提升，BW 也会跟着线性放大


3）平均延迟居然没有变差，反而略好

QD1 clat avg：76.4 us


QD8 clat avg：71.1 us

这个结果挺漂亮，说明：

这块 NVMe 在低到中等队列深度区间，调度效率很好


队列加深后，并没有马上把平均延迟拉坏


反而把设备内部并行性利用起来了

这也是 NVMe 和老式设备很不一样的地方。

4）但尾延迟开始变大了

QD1 p99：91 us


QD8 p99：129 us

也就是说：
平均值仍然好看，但尾部已经开始拉长
这正是你 Day10 要学会看的东西：

平均延迟不一定说明全部


深队列以后，p99 往往先变差


5）aqu-sz 和 iodepth=8 对上了
你这里：

aqu-sz = 7.56

几乎就是设备层平均队列深度 ≈ 8
这和你的 fio 设置：

iodepth=8

非常吻合。
这说明：

fio 参数真的压到设备层了


不是“设了 8，结果设备只吃到 2、3”


6）util 已经打满

QD1 util：91%~93%


QD8 util：100%

说明从 QD1 到 QD8，设备已经从“没完全喂饱”进入到“基本打满”的状态了。
这也解释了为什么后面再升 iodepth，IOPS 不一定还能像前面一样线性涨。

你现在可以写一个阶段性观察结论
在 4K randread, numjobs=1 条件下，iodepth 从 1 提升到 8 时，nvme0n1 的 IOPS 从 12.5k 提升到 109k，带宽从 48.8 MiB/s 提升到 426 MiB/s；同时平均完成延迟仍维持在 70us 级别，但 p99 从 91us 增加到 129us。这说明该盘在低到中等队列深度下，能够在不明显恶化平均延迟的前提下显著提升随机读吞吐。

下一步最值得跑哪组
现在不要跑 QD4，直接跳到 QD32 最有价值。
因为你已经有：

QD1


QD8

再拿到 QD32，就能看出：

从 1 到 8 是不是“快速增长区”


到 32 是不是“接近平台上限区”

命令：
fio --name=randread_4k_qd32 \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=32 \
--numjobs=1 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
继续保持：
iostat -x 1 nvme0n1
你把 QD32 这组 fio + iostat 发我，我就帮你把 Day10 第三行填上。

Dq32



```bash
[root@bogon ~]# fio --name=randread_4k_qd32 \
>     --filename=/dev/nvme0n1 \
>     --direct=1 \
>     --ioengine=libaio \
>     --rw=randread \
>     --bs=4K \
>     --iodepth=32 \
>     --numjobs=1 \
>     --offset=4G \
>     --size=20G \
>     --runtime=60 \
>     --time_based \
>     --group_reporting
randread_4k_qd32: (g=0): rw=randread, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=32
fio-3.29
Starting 1 process
Jobs: 1 (f=1): [r(1)][5.0%][r=1293MiB/s][r=331k IOPS][eta 00Jobs: 1 (f=1): [r(1)][6.7%][r=1290MiB/s][r=330k IOPS][eta 00Jobs: 1 (f=1): [r(1)][8.3%][r=1285MiB/s][r=329k IOPS][eta 00Jobs: 1 (f=1): [r(1)][10.0%][r=1280MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][11.7%][r=1280MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][13.3%][r=1278MiB/s][r=327k IOPS][eta 0Jobs: 1 (f=1): [r(1)][15.0%][r=1276MiB/s][r=327k IOPS][eta 0Jobs: 1 (f=1): [r(1)][16.7%][r=1281MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][18.3%][r=1280MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][20.0%][r=1280MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][21.7%][r=1277MiB/s][r=327k IOPS][eta 0Jobs: 1 (f=1): [r(1)][23.3%][r=1278MiB/s][r=327k IOPS][eta 0Jobs: 1 (f=1): [r(1)][25.0%][r=1278MiB/s][r=327k IOPS][eta 0Jobs: 1 (f=1): [r(1)][26.7%][r=1279MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][28.3%][r=1298MiB/s][r=332k IOPS][eta 0Jobs: 1 (f=1): [r(1)][30.0%][r=1299MiB/s][r=332k IOPS][eta 0Jobs: 1 (f=1): [r(1)][31.7%][r=1292MiB/s][r=331k IOPS][eta 0Jobs: 1 (f=1): [r(1)][33.3%][r=1294MiB/s][r=331k IOPS][eta 0Jobs: 1 (f=1): [r(1)][35.0%][r=1294MiB/s][r=331k IOPS][eta 0Jobs: 1 (f=1): [r(1)][36.7%][r=1292MiB/s][r=331k IOPS][eta 0Jobs: 1 (f=1): [r(1)][39.0%][r=1290MiB/s][r=330k IOPS][eta 0Jobs: 1 (f=1): [r(1)][40.0%][r=1287MiB/s][r=330k IOPS][eta 0Jobs: 1 (f=1): [r(1)][41.7%][r=1285MiB/s][r=329k IOPS][eta 0Jobs: 1 (f=1): [r(1)][43.3%][r=1282MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][45.0%][r=1282MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][46.7%][r=1283MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][48.3%][r=1283MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][50.0%][r=1282MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][52.5%][r=1280MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][53.3%][r=1282MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][55.9%][r=1305MiB/s][r=334k IOPS][eta 0Jobs: 1 (f=1): [r(1)][56.7%][r=1304MiB/s][r=334k IOPS][eta 0Jobs: 1 (f=1): [r(1)][59.3%][r=1302MiB/s][r=333k IOPS][eta 0Jobs: 1 (f=1): [r(1)][60.0%][r=1300MiB/s][r=333k IOPS][eta 0Jobs: 1 (f=1): [r(1)][61.7%][r=1293MiB/s][r=331k IOPS][eta 0Jobs: 1 (f=1): [r(1)][63.3%][r=1291MiB/s][r=331k IOPS][eta 0Jobs: 1 (f=1): [r(1)][65.0%][r=1290MiB/s][r=330k IOPS][eta 0Jobs: 1 (f=1): [r(1)][66.7%][r=1287MiB/s][r=330k IOPS][eta 0Jobs: 1 (f=1): [r(1)][68.3%][r=1285MiB/s][r=329k IOPS][eta 0Jobs: 1 (f=1): [r(1)][70.0%][r=1284MiB/s][r=329k IOPS][eta 0Jobs: 1 (f=1): [r(1)][71.7%][r=1284MiB/s][r=329k IOPS][eta 0Jobs: 1 (f=1): [r(1)][73.3%][r=1294MiB/s][r=331k IOPS][eta 0Jobs: 1 (f=1): [r(1)][75.0%][r=1282MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][78.0%][r=1281MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][78.3%][r=1279MiB/s][r=327k IOPS][eta 0Jobs: 1 (f=1): [r(1)][80.0%][r=1284MiB/s][r=329k IOPS][eta 0Jobs: 1 (f=1): [r(1)][81.7%][r=1315MiB/s][r=337k IOPS][eta 0Jobs: 1 (f=1): [r(1)][83.3%][r=1311MiB/s][r=336k IOPS][eta 0Jobs: 1 (f=1): [r(1)][85.0%][r=1310MiB/s][r=335k IOPS][eta 0Jobs: 1 (f=1): [r(1)][86.7%][r=1308MiB/s][r=335k IOPS][eta 0Jobs: 1 (f=1): [r(1)][88.3%][r=1306MiB/s][r=334k IOPS][eta 0Jobs: 1 (f=1): [r(1)][90.0%][r=1304MiB/s][r=334k IOPS][eta 0Jobs: 1 (f=1): [r(1)][91.7%][r=1301MiB/s][r=333k IOPS][eta 0Jobs: 1 (f=1): [r(1)][93.3%][r=1299MiB/s][r=333k IOPS][eta 0Jobs: 1 (f=1): [r(1)][95.0%][r=1298MiB/s][r=332k IOPS][eta 0Jobs: 1 (f=1): [r(1)][96.7%][r=1295MiB/s][r=332k IOPS][eta 0Jobs: 1 (f=1): [r(1)][98.3%][r=1283MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][100.0%][r=1278MiB/s][r=327k IOPS][eta 00m:00s]
randread_4k_qd32: (groupid=0, jobs=1): err= 0: pid=14751: Fri Mar 20 14:07:10 2026
read: IOPS=330k, BW=1288MiB/s (1350MB/s)(75.5GiB/60001msec)
slat (nsec): min=1230, max=175912, avg=1962.73, stdev=901.14
clat (usec): min=11, max=580, avg=94.51, stdev=25.30
lat (usec): min=14, max=757, avg=96.57, stdev=25.31
clat percentiles (usec):
|  1.00th=[   35],  5.00th=[   68], 10.00th=[   74], 20.00th=[   79],
| 30.00th=[   83], 40.00th=[   86], 50.00th=[   90], 60.00th=[   94],
| 70.00th=[   99], 80.00th=[  109], 90.00th=[  130], 95.00th=[  145],
| 99.00th=[  178], 99.50th=[  194], 99.90th=[  225], 99.95th=[  241],
| 99.99th=[  273]
bw (  MiB/s): min= 1139, max= 1315, per=100.00%, avg=1288.39, stdev=17.02, samples=119
iops        : min=291660, max=336846, avg=329827.19, stdev=4358.19, samples=119
lat (usec)   : 20=0.05%, 50=2.92%, 100=69.20%, 250=27.80%, 500=0.03%
lat (usec)   : 750=0.01%
cpu          : usr=22.89%, sys=51.49%, ctx=106388, majf=0, minf=253
IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
issued rwts: total=19782562,0,0,0 short=0,0,0,0 dropped=0,0,0,0
latency   : target=0, window=0, percentile=100.00%, depth=32
Run status group 0 (all jobs):
READ: bw=1288MiB/s (1350MB/s), 1288MiB/s-1288MiB/s (1350MB/s-1350MB/s), io=75.5GiB (81.0GB), run=60001-60001msec
Disk stats (read/write):
nvme0n1: ios=19743250/0, merge=0/0, ticks=1501647/0, in_queue=1501648, util=99.84%
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
```

0.08    0.00    0.32    0.00    0.00   99.60

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       328729.67 1314917.33     0.00   0.00    0.08     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   25.96 100.00


avg-cpu:  %user   %nice %system %iowait  %steal   %idle
0.09    0.00    0.31    0.00    0.00   99.59

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       327125.00 1308501.33     0.00   0.00    0.08     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   25.80 100.00


很好，QD32 这组把“接近上限区”直接打出来了。
Day10 表1，补第三行

这组怎么读
1）从 QD8 到 QD32，IOPS 还在大涨

QD8：109k


QD32：330k

差不多又涨了 3 倍
说明这块盘在 QD8 时虽然已经打满 util，但并没有到随机读 IOPS 上限，继续加深队列仍然有明显收益。

2）带宽也同步上升

QD8：426 MiB/s


QD32：1288 MiB/s

这也差不多是 3 倍
因为 4K 随机读里：

IOPS 上去


BW 就跟着上去


3）平均延迟开始明显抬头了

QD8 clat avg：71.1 us


QD32 clat avg：94.5 us

这就很典型了：
队列越深，吞吐越高，但平均完成延迟也开始上升
也就是说，从 QD8 到 QD32，这块盘是在用一部分延迟代价，换更高 IOPS。

4）尾延迟继续变差

QD8 p99：129 us


QD32 p99：178 us

所以 Day10 到这里，你已经能看出一个清晰趋势：

平均延迟还能接受


但 p99 已经比浅队列明显变差

这正是性能测试里要盯的点。

5）aqu-sz 没到 32，但已经明显堆起来了
你这里：

aqu-sz ≈ 25.8 ~ 26.0

而 fio 设的是：

iodepth=32

这说明：

设备层实际平均排队深度大约在 26 左右


虽然没满到 32，但已经形成深队列


并且这种排队已经足以把设备能力压出来


6）await 看起来变化不大，但别只盯它
你这里 iostat：

await ≈ 0.08 ms

和前面差不多，看起来不夸张。
但 fio 里你已经看到：

clat avg 在升


p99 在升

所以今天一个重要经验是：
iostat await 很有用，但看 4K 随机时，还是要结合 fio 的 clat 和 p99。

你现在可以写阶段性结论了
在 4K randread, numjobs=1 条件下，iodepth 从 1 → 8 → 32 时，nvme0n1 的随机读 IOPS 从 12.5k 提升到 109k 再提升到 330k，带宽从 48.8 MiB/s 提升到 426 MiB/s 再提升到 1288 MiB/s。同时平均完成延迟从 76 us 到 71 us 再到 95 us，p99 从 91 us 到 129 us 再到 178 us，说明更深的队列显著提升吞吐，但也带来更明显的尾延迟代价。

现在 Day10 最适合再补哪组
最值得直接补的是：
QD64
因为这组能回答最关键的问题：
QD32 之后还有没有明显收益？
命令：
fio --name=randread_4k_qd64 \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=64 \
--numjobs=1 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
继续保持：
iostat -x 1 nvme0n1
你把 QD64 这组发我，我们就能把 Day10 的 iodepth 主结论收出来。
Dq64

```bash
[root@bogon ~]# fio --name=randread_4k_qd64 \
>     --filename=/dev/nvme0n1 \
>     --direct=1 \
>     --ioengine=libaio \
>     --rw=randread \
>     --bs=4K \
>     --iodepth=64 \
>     --numjobs=1 \
>     --offset=4G \
>     --size=20G \
>     --runtime=60 \
>     --time_based \
>     --group_reporting
randread_4k_qd64: (g=0): rw=randread, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64
fio-3.29
Starting 1 process
Jobs: 1 (f=1): [r(1)][5.0%][r=1290MiB/s][r=330k IOPS][eta 00Jobs: 1 (f=1): [r(1)][6.7%][r=1288MiB/s][r=330k IOPS][eta 00Jobs: 1 (f=1): [r(1)][8.3%][r=1286MiB/s][r=329k IOPS][eta 00Jobs: 1 (f=1): [r(1)][10.0%][r=1285MiB/s][r=329k IOPS][eta 0Jobs: 1 (f=1): [r(1)][11.7%][r=1298MiB/s][r=332k IOPS][eta 0Jobs: 1 (f=1): [r(1)][13.3%][r=1290MiB/s][r=330k IOPS][eta 0Jobs: 1 (f=1): [r(1)][15.0%][r=1289MiB/s][r=330k IOPS][eta 0Jobs: 1 (f=1): [r(1)][16.7%][r=1308MiB/s][r=335k IOPS][eta 0Jobs: 1 (f=1): [r(1)][18.3%][r=1374MiB/s][r=352k IOPS][eta 0Jobs: 1 (f=1): [r(1)][20.0%][r=1275MiB/s][r=326k IOPS][eta 0Jobs: 1 (f=1): [r(1)][21.7%][r=1271MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][23.3%][r=1268MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][25.0%][r=1269MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][26.7%][r=1384MiB/s][r=354k IOPS][eta 0Jobs: 1 (f=1): [r(1)][28.3%][r=1411MiB/s][r=361k IOPS][eta 0Jobs: 1 (f=1): [r(1)][30.0%][r=1334MiB/s][r=342k IOPS][eta 0Jobs: 1 (f=1): [r(1)][31.7%][r=1297MiB/s][r=332k IOPS][eta 0Jobs: 1 (f=1): [r(1)][33.3%][r=1303MiB/s][r=333k IOPS][eta 0Jobs: 1 (f=1): [r(1)][35.0%][r=1323MiB/s][r=339k IOPS][eta 0Jobs: 1 (f=1): [r(1)][36.7%][r=1349MiB/s][r=345k IOPS][eta 0Jobs: 1 (f=1): [r(1)][39.0%][r=1371MiB/s][r=351k IOPS][eta 0Jobs: 1 (f=1): [r(1)][40.0%][r=1284MiB/s][r=329k IOPS][eta 0Jobs: 1 (f=1): [r(1)][41.7%][r=1280MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][43.3%][r=1280MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][45.0%][r=1355MiB/s][r=347k IOPS][eta 0Jobs: 1 (f=1): [r(1)][46.7%][r=1316MiB/s][r=337k IOPS][eta 0Jobs: 1 (f=1): [r(1)][48.3%][r=1370MiB/s][r=351k IOPS][eta 0Jobs: 1 (f=1): [r(1)][50.0%][r=1357MiB/s][r=347k IOPS][eta 0Jobs: 1 (f=1): [r(1)][52.5%][r=1317MiB/s][r=337k IOPS][eta 0Jobs: 1 (f=1): [r(1)][53.3%][r=1334MiB/s][r=341k IOPS][eta 0Jobs: 1 (f=1): [r(1)][55.9%][r=1367MiB/s][r=350k IOPS][eta 0Jobs: 1 (f=1): [r(1)][56.7%][r=1367MiB/s][r=350k IOPS][eta 0Jobs: 1 (f=1): [r(1)][59.3%][r=1289MiB/s][r=330k IOPS][eta 0Jobs: 1 (f=1): [r(1)][60.0%][r=1282MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][61.7%][r=1282MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][63.3%][r=1285MiB/s][r=329k IOPS][eta 0Jobs: 1 (f=1): [r(1)][65.0%][r=1282MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][66.7%][r=1274MiB/s][r=326k IOPS][eta 0Jobs: 1 (f=1): [r(1)][68.3%][r=1272MiB/s][r=326k IOPS][eta 0Jobs: 1 (f=1): [r(1)][70.0%][r=1273MiB/s][r=326k IOPS][eta 0Jobs: 1 (f=1): [r(1)][71.7%][r=1272MiB/s][r=326k IOPS][eta 0Jobs: 1 (f=1): [r(1)][73.3%][r=1279MiB/s][r=327k IOPS][eta 0Jobs: 1 (f=1): [r(1)][75.0%][r=1279MiB/s][r=327k IOPS][eta 0Jobs: 1 (f=1): [r(1)][78.0%][r=1277MiB/s][r=327k IOPS][eta 0Jobs: 1 (f=1): [r(1)][78.3%][r=1275MiB/s][r=326k IOPS][eta 0Jobs: 1 (f=1): [r(1)][80.0%][r=1296MiB/s][r=332k IOPS][eta 0Jobs: 1 (f=1): [r(1)][81.7%][r=1393MiB/s][r=357k IOPS][eta 0Jobs: 1 (f=1): [r(1)][83.3%][r=1387MiB/s][r=355k IOPS][eta 0Jobs: 1 (f=1): [r(1)][85.0%][r=1303MiB/s][r=334k IOPS][eta 0Jobs: 1 (f=1): [r(1)][86.7%][r=1340MiB/s][r=343k IOPS][eta 0Jobs: 1 (f=1): [r(1)][88.3%][r=1378MiB/s][r=353k IOPS][eta 0Jobs: 1 (f=1): [r(1)][90.0%][r=1355MiB/s][r=347k IOPS][eta 0Jobs: 1 (f=1): [r(1)][91.7%][r=1296MiB/s][r=332k IOPS][eta 0Jobs: 1 (f=1): [r(1)][93.3%][r=1288MiB/s][r=330k IOPS][eta 0Jobs: 1 (f=1): [r(1)][95.0%][r=1304MiB/s][r=334k IOPS][eta 0Jobs: 1 (f=1): [r(1)][96.7%][r=1363MiB/s][r=349k IOPS][eta 0Jobs: 1 (f=1): [r(1)][98.3%][r=1397MiB/s][r=358k IOPS][eta 0Jobs: 1 (f=1): [r(1)][100.0%][r=1326MiB/s][r=339k IOPS][eta 00m:00s]
randread_4k_qd64: (groupid=0, jobs=1): err= 0: pid=14779: Fri Mar 20 14:11:12 2026
read: IOPS=336k, BW=1312MiB/s (1376MB/s)(76.9GiB/60001msec)
slat (nsec): min=1100, max=283850, avg=1921.24, stdev=891.94
clat (usec): min=68, max=1169, avg=188.03, stdev=27.43
lat (usec): min=70, max=1328, avg=190.05, stdev=27.48
clat percentiles (usec):
|  1.00th=[  127],  5.00th=[  153], 10.00th=[  161], 20.00th=[  169],
| 30.00th=[  176], 40.00th=[  180], 50.00th=[  184], 60.00th=[  190],
| 70.00th=[  194], 80.00th=[  204], 90.00th=[  225], 95.00th=[  241],
| 99.00th=[  277], 99.50th=[  293], 99.90th=[  338], 99.95th=[  355],
| 99.99th=[  400]
bw (  MiB/s): min= 1109, max= 1432, per=99.98%, avg=1311.69, stdev=51.46, samples=119
iops        : min=284098, max=366682, avg=335793.24, stdev=13173.44, samples=119
lat (usec)   : 100=0.01%, 250=96.97%, 500=3.01%, 750=0.01%, 1000=0.01%
lat (msec)   : 2=0.01%
cpu          : usr=25.27%, sys=50.58%, ctx=2380, majf=0, minf=5030
IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
issued rwts: total=20152334,0,0,0 short=0,0,0,0 dropped=0,0,0,0
latency   : target=0, window=0, percentile=100.00%, depth=64
Run status group 0 (all jobs):
READ: bw=1312MiB/s (1376MB/s), 1312MiB/s-1312MiB/s (1376MB/s-1376MB/s), io=76.9GiB (82.5GB), run=60001-60001msec
Disk stats (read/write):
nvme0n1: ios=20109748/0, merge=0/0, ticks=1532509/0, in_queue=1532509, util=99.85%
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
```

0.09    0.00    0.31    0.00    0.00   99.60

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       337350.33 1349401.33     0.00   0.00    0.08     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   26.26 100.00


avg-cpu:  %user   %nice %system %iowait  %steal   %idle
0.10    0.00    0.31    0.00    0.00   99.59

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       337512.33 1350050.67     0.00   0.00    0.08     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   26.31 100.00

很好，QD64 把 Day10 的主结论钉死了。
Day10 表1 现在是这样

这组最重要的结论
1）QD32 到 QD64，IOPS 几乎不涨了

QD32：330k


QD64：336k

只涨了大约 1.8%
也就是说：
这块盘在你这组 4K randread, numjobs=1 的条件下，QD32 已经基本到顶。

2）但延迟翻倍了

QD32 clat avg：94.5 us


QD64 clat avg：188.0 us

几乎翻倍。
p99 也明显恶化：

QD32 p99：178 us


QD64 p99：277 us

这说明：
再把队列从 32 加到 64，基本没换来多少吞吐，却明显牺牲了延迟。
这就是 Day10 最想让你看到的东西。

3）aqu-sz 没有跟着涨到 64
你这里：

QD32：aqu-sz ≈ 25.8


QD64：aqu-sz ≈ 26.3

几乎没变。
这非常关键，说明：

设备层实际排队深度没有因为你把 iodepth 设成 64 就有效翻倍


盘已经在自己的能力边界附近


再加深队列，只是让请求在更前面的软件/提交路径里堆着，收益不大

这也是为什么 IOPS 没怎么涨，但延迟明显变差。

Day10 到这里可以得出主结论了
你可以直接记这段：
在 4K randread, numjobs=1 条件下，iodepth 从 1 提升到 8 再到 32 时，nvme0n1 的 IOPS 从 12.5k 显著提升到 109k 再提升到 330k，说明加深队列能够有效释放 NVMe 的并行能力；但从 iodepth=32 继续增加到 iodepth=64 时，IOPS 仅从 330k 提升到 336k，收益很小，而平均完成延迟从 94.5us 增加到 188us，p99 从 178us 增加到 277us。因此对这块盘来说，iodepth=32 已接近随机读甜点区，继续增大队列深度的性价比很低。

你现在已经看到的趋势图，用人话说
QD1

很低延迟


很低 IOPS


更像单请求响应测试

QD8

IOPS 大涨


延迟基本还漂亮


很有性价比

QD32

IOPS 接近上限


延迟开始抬头


很可能就是甜点区

QD64

IOPS 几乎不涨


延迟明显变差


不划算


下一步最自然的就是做 numjobs
因为现在 iodepth 这一半已经够了。
接下来你要回答另一个问题：
固定 QD32 后，多开几个 job，还有没有收益？
建议先跑这三组
jobs=1
你已经有了：

iodepth=32, numjobs=1

jobs=2
fio --name=randread_4k_jobs2 \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=32 \
--numjobs=2 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
jobs=4
fio --name=randread_4k_jobs4 \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=32 \
--numjobs=4 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
jobs=8
fio --name=randread_4k_jobs8 \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=32 \
--numjobs=8 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
继续配合：
iostat -x 1 nvme0n1

你今天如果想先收一半 Day10，也可以
到现在为止，你已经完成了：

iodepth=1


iodepth=8


iodepth=32


iodepth=64

光这 4 组，Day10 的一半内容已经成立了。
差的只是 numjobs 那一半。
你要继续的话，就把 jobs=2 先跑出来，我继续帮你填第二张表。


```bash
[root@bogon ~]# fio --name=randread_4k_jobs2 \
>     --filename=/dev/nvme0n1 \
>     --direct=1 \
>     --ioengine=libaio \
--runtime=60 \
--time_based \
--group_reporting>     --rw=randread \
>     --bs=4K \
>     --iodepth=32 \
>     --numjobs=2 \
>     --offset=4G \
>     --size=20G \
>     --runtime=60 \
>     --time_based \
>     --group_reporting
randread_4k_jobs2: (g=0): rw=randread, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=32
...
fio-3.29
Starting 2 processes
Jobs: 2 (f=2): [r(2)][5.0%][r=2317MiB/s][r=593k IOPS][eta 00Jobs: 2 (f=2): [r(2)][6.7%][r=2317MiB/s][r=593k IOPS][eta 00Jobs: 2 (f=2): [r(2)][8.3%][r=2316MiB/s][r=593k IOPS][eta 00Jobs: 2 (f=2): [r(2)][10.0%][r=2316MiB/s][r=593k IOPS][eta 0Jobs: 2 (f=2): [r(2)][11.7%][r=2312MiB/s][r=592k IOPS][eta 0Jobs: 2 (f=2): [r(2)][13.3%][r=2312MiB/s][r=592k IOPS][eta 0Jobs: 2 (f=2): [r(2)][15.0%][r=2312MiB/s][r=592k IOPS][eta 0Jobs: 2 (f=2): [r(2)][16.7%][r=2311MiB/s][r=592k IOPS][eta 0Jobs: 2 (f=2): [r(2)][18.3%][r=2309MiB/s][r=591k IOPS][eta 0Jobs: 2 (f=2): [r(2)][20.0%][r=2310MiB/s][r=591k IOPS][eta 0Jobs: 2 (f=2): [r(2)][21.7%][r=2311MiB/s][r=592k IOPS][eta 0Jobs: 2 (f=2): [r(2)][23.3%][r=2311MiB/s][r=592k IOPS][eta 0Jobs: 2 (f=2): [r(2)][25.0%][r=2311MiB/s][r=592k IOPS][eta 0Jobs: 2 (f=2): [r(2)][26.7%][r=2311MiB/s][r=592k IOPS][eta 0Jobs: 2 (f=2): [r(2)][28.3%][r=2312MiB/s][r=592k IOPS][eta 0Jobs: 2 (f=2): [r(2)][30.0%][r=2315MiB/s][r=593k IOPS][eta 0Jobs: 2 (f=2): [r(2)][31.7%][r=2326MiB/s][r=596k IOPS][eta 0Jobs: 2 (f=2): [r(2)][33.3%][r=2327MiB/s][r=596k IOPS][eta 0Jobs: 2 (f=2): [r(2)][35.0%][r=2326MiB/s][r=595k IOPS][eta 0Jobs: 2 (f=2): [r(2)][36.7%][r=2327MiB/s][r=596k IOPS][eta 0Jobs: 2 (f=2): [r(2)][39.0%][r=2325MiB/s][r=595k IOPS][eta 0Jobs: 2 (f=2): [r(2)][40.0%][r=2320MiB/s][r=594k IOPS][eta 0Jobs: 2 (f=2): [r(2)][41.7%][r=2327MiB/s][r=596k IOPS][eta 0Jobs: 2 (f=2): [r(2)][43.3%][r=2321MiB/s][r=594k IOPS][eta 0Jobs: 2 (f=2): [r(2)][45.0%][r=2319MiB/s][r=594k IOPS][eta 0Jobs: 2 (f=2): [r(2)][46.7%][r=2321MiB/s][r=594k IOPS][eta 0Jobs: 2 (f=2): [r(2)][48.3%][r=2320MiB/s][r=594k IOPS][eta 0Jobs: 2 (f=2): [r(2)][50.0%][r=2323MiB/s][r=595k IOPS][eta 0Jobs: 2 (f=2): [r(2)][52.5%][r=2320MiB/s][r=594k IOPS][eta 0Jobs: 2 (f=2): [r(2)][53.3%][r=2319MiB/s][r=594k IOPS][eta 0Jobs: 2 (f=2): [r(2)][55.9%][r=2319MiB/s][r=594k IOPS][eta 0Jobs: 2 (f=2): [r(2)][56.7%][r=2319MiB/s][r=594k IOPS][eta 0Jobs: 2 (f=2): [r(2)][59.3%][r=2319MiB/s][r=594k IOPS][eta 0Jobs: 2 (f=2): [r(2)][60.0%][r=2336MiB/s][r=598k IOPS][eta 0Jobs: 2 (f=2): [r(2)][61.7%][r=2346MiB/s][r=601k IOPS][eta 0Jobs: 2 (f=2): [r(2)][63.3%][r=2347MiB/s][r=601k IOPS][eta 0Jobs: 2 (f=2): [r(2)][65.0%][r=2347MiB/s][r=601k IOPS][eta 0Jobs: 2 (f=2): [r(2)][66.7%][r=2348MiB/s][r=601k IOPS][eta 0Jobs: 2 (f=2): [r(2)][68.3%][r=2345MiB/s][r=600k IOPS][eta 0Jobs: 2 (f=2): [r(2)][70.0%][r=2345MiB/s][r=600k IOPS][eta 0Jobs: 2 (f=2): [r(2)][71.7%][r=2348MiB/s][r=601k IOPS][eta 0Jobs: 2 (f=2): [r(2)][73.3%][r=2346MiB/s][r=600k IOPS][eta 0Jobs: 2 (f=2): [r(2)][75.0%][r=2343MiB/s][r=600k IOPS][eta 0Jobs: 2 (f=2): [r(2)][78.0%][r=2344MiB/s][r=600k IOPS][eta 0Jobs: 2 (f=2): [r(2)][78.3%][r=2346MiB/s][r=601k IOPS][eta 0Jobs: 2 (f=2): [r(2)][80.0%][r=2347MiB/s][r=601k IOPS][eta 0Jobs: 2 (f=2): [r(2)][81.7%][r=2342MiB/s][r=599k IOPS][eta 0Jobs: 2 (f=2): [r(2)][83.3%][r=2337MiB/s][r=598k IOPS][eta 0Jobs: 2 (f=2): [r(2)][85.0%][r=2340MiB/s][r=599k IOPS][eta 0Jobs: 2 (f=2): [r(2)][86.7%][r=2348MiB/s][r=601k IOPS][eta 0Jobs: 2 (f=2): [r(2)][88.3%][r=2364MiB/s][r=605k IOPS][eta 0Jobs: 2 (f=2): [r(2)][90.0%][r=2387MiB/s][r=611k IOPS][eta 0Jobs: 2 (f=2): [r(2)][91.7%][r=2374MiB/s][r=608k IOPS][eta 0Jobs: 2 (f=2): [r(2)][93.3%][r=2382MiB/s][r=610k IOPS][eta 0Jobs: 2 (f=2): [r(2)][95.0%][r=2378MiB/s][r=609k IOPS][eta 0Jobs: 2 (f=2): [r(2)][96.7%][r=2381MiB/s][r=609k IOPS][eta 0^[[BJobs: 2 (f=2): [r(2)][98.3%][r=2375MiB/s][r=608k IOPS][eJobs: 2 (f=2): [r(2)][100.0%][r=2376MiB/s][r=608k IOPS][eta 00m:00s]
randread_4k_jobs2: (groupid=0, jobs=2): err= 0: pid=14783: Fri Mar 20 14:13:51 2026
read: IOPS=596k, BW=2330MiB/s (2443MB/s)(137GiB/60001msec)
slat (nsec): min=1120, max=337543, avg=1918.30, stdev=872.09
clat (usec): min=11, max=656, avg=104.80, stdev=38.21
lat (usec): min=13, max=758, avg=106.81, stdev=38.21
clat percentiles (usec):
|  1.00th=[   62],  5.00th=[   68], 10.00th=[   71], 20.00th=[   75],
| 30.00th=[   80], 40.00th=[   86], 50.00th=[   92], 60.00th=[  102],
| 70.00th=[  118], 80.00th=[  133], 90.00th=[  157], 95.00th=[  182],
| 99.00th=[  233], 99.50th=[  253], 99.90th=[  302], 99.95th=[  322],
| 99.99th=[  371]
bw (  MiB/s): min= 2047, max= 2400, per=100.00%, avg=2330.57, stdev=17.47, samples=238
iops        : min=524094, max=614570, avg=596625.55, stdev=4471.71, samples=238
lat (usec)   : 20=0.07%, 50=0.55%, 100=57.73%, 250=41.09%, 500=0.56%
lat (usec)   : 750=0.01%
cpu          : usr=22.25%, sys=47.10%, ctx=2458050, majf=0, minf=1476
IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
issued rwts: total=35790572,0,0,0 short=0,0,0,0 dropped=0,0,0,0
latency   : target=0, window=0, percentile=100.00%, depth=32
Run status group 0 (all jobs):
READ: bw=2330MiB/s (2443MB/s), 2330MiB/s-2330MiB/s (2443MB/s-2443MB/s), io=137GiB (147GB), run=60001-60001msec
Disk stats (read/write):
nvme0n1: ios=35713987/0, merge=0/0, ticks=3414484/0, in_queue=3414483, util=99.84%
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
```

0.17    0.00    0.56    0.00    0.00   99.27

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       593856.67 2375426.67     0.00   0.00    0.10     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   57.24 100.00


avg-cpu:  %user   %nice %system %iowait  %steal   %idle
0.17    0.00    0.55    0.00    0.00   99.28

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       594020.33 2376081.33     0.00   0.00    0.10     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   57.18 100.00

很好，Day10 的 numjobs 这一半也开始出来了。
表2：numjobs 影响，先填前两行

这组怎么读
1）numjobs 从 1 到 2，收益很大

jobs=1：330k IOPS


jobs=2：596k IOPS

提升了大约 80%
说明这块盘在：

iodepth=32


单 job

时还没把多路并发能力完全吃满。
增加到两个并发 job 后，吞吐还能明显上去。

2）带宽也同步增长

jobs=1：1288 MiB/s


jobs=2：2330 MiB/s

也差不多提升了 80%
这说明这里不是“虚高 IOPS”，而是真实读吞吐也一起上来了。

3）延迟变差了，但没有失控

jobs=1：clat avg = 94.5 us


jobs=2：clat avg = 104.8 us

平均延迟只增加了一点点。
但尾延迟更明显：

jobs=1：p99 = 178 us


jobs=2：p99 = 233 us

所以这里已经能看出 Day10 的第二个核心规律：
多加 job，吞吐还能涨，但尾延迟会先变差。

4）aqu-sz 接近翻倍

jobs=1：aqu-sz ≈ 26


jobs=2：aqu-sz ≈ 57

这和你的总并发压力很一致：

jobs=1, qd=32 → 总并发大约 32


jobs=2, qd=32 → 总并发大约 64

设备层看到的平均排队深度也明显上去了。

你现在已经能写一个阶段性结论
在 4K randread, iodepth=32 条件下，numjobs 从 1 增加到 2 时，nvme0n1 的 IOPS 从 330k 提升到 596k，带宽从 1288 MiB/s 提升到 2330 MiB/s，说明增加并发 job 仍能显著提升随机读吞吐；但同时平均完成延迟从 94.5us 增加到 104.8us，p99 从 178us 增加到 233us，说明并发度上升会带来更明显的尾延迟代价。

Day10 到现在，两个趋势都已经开始清楚了
iodepth 这条线

QD1 → QD8 → QD32：收益很明显


QD32 → QD64：几乎没收益，但延迟恶化

numjobs 这条线

jobs1 → jobs2：收益还很明显


后面 jobs4 / jobs8 很值得看，因为它会告诉你：


还有没有继续翻倍的空间


还是已经快到平台瓶颈了


下一步就跑 jobs=4
fio --name=randread_4k_jobs4 \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=32 \
--numjobs=4 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
继续看：
iostat -x 1 nvme0n1
你把 jobs=4 这组贴上来，我就把 Day10 的第三行填掉。



```bash
[root@bogon ~]# fio --name=randread_4k_jobs4 \
>     --filename=/dev/nvme0n1 \
>     --direct=1 \
>     --ioengine=libaio \
>     --rw=randread \
>     --bs=4K \
>     --iodepth=32 \
>     --numjobs=4 \
>     --offset=4G \
>     --size=20G \
>     --runtime=60 \
>     --time_based \
>     --group_reporting
randread_4k_jobs4: (g=0): rw=randread, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=32
...
fio-3.29
Starting 4 processes
Jobs: 4 (f=4): [r(4)][5.0%][r=3515MiB/s][r=900k IOPS][eta 00Jobs: 4 (f=4): [r(4)][6.7%][r=3519MiB/s][r=901k IOPS][eta 00Jobs: 4 (f=4): [r(4)][8.3%][r=3516MiB/s][r=900k IOPS][eta 00Jobs: 4 (f=4): [r(4)][10.0%][r=3511MiB/s][r=899k IOPS][eta 0Jobs: 4 (f=4): [r(4)][11.7%][r=3511MiB/s][r=899k IOPS][eta 0Jobs: 4 (f=4): [r(4)][13.3%][r=3512MiB/s][r=899k IOPS][eta 0Jobs: 4 (f=4): [r(4)][15.0%][r=3513MiB/s][r=899k IOPS][eta 0Jobs: 4 (f=4): [r(4)][16.7%][r=3512MiB/s][r=899k IOPS][eta 0Jobs: 4 (f=4): [r(4)][18.3%][r=3515MiB/s][r=900k IOPS][eta 0Jobs: 4 (f=4): [r(4)][20.0%][r=3518MiB/s][r=901k IOPS][eta 0Jobs: 4 (f=4): [r(4)][21.7%][r=3511MiB/s][r=899k IOPS][eta 0Jobs: 4 (f=4): [r(4)][23.3%][r=3517MiB/s][r=900k IOPS][eta 0Jobs: 4 (f=4): [r(4)][25.0%][r=3515MiB/s][r=900k IOPS][eta 0Jobs: 4 (f=4): [r(4)][26.7%][r=3525MiB/s][r=902k IOPS][eta 0Jobs: 4 (f=4): [r(4)][28.3%][r=3525MiB/s][r=902k IOPS][eta 0Jobs: 4 (f=4): [r(4)][30.0%][r=3520MiB/s][r=901k IOPS][eta 0Jobs: 4 (f=4): [r(4)][31.7%][r=3521MiB/s][r=901k IOPS][eta 0Jobs: 4 (f=4): [r(4)][33.3%][r=3520MiB/s][r=901k IOPS][eta 0Jobs: 4 (f=4): [r(4)][35.0%][r=3517MiB/s][r=900k IOPS][eta 0Jobs: 4 (f=4): [r(4)][36.7%][r=3519MiB/s][r=901k IOPS][eta 0Jobs: 4 (f=4): [r(4)][39.0%][r=3519MiB/s][r=901k IOPS][eta 0Jobs: 4 (f=4): [r(4)][40.0%][r=3529MiB/s][r=903k IOPS][eta 0Jobs: 4 (f=4): [r(4)][41.7%][r=3533MiB/s][r=904k IOPS][eta 0Jobs: 4 (f=4): [r(4)][43.3%][r=3531MiB/s][r=904k IOPS][eta 0Jobs: 4 (f=4): [r(4)][45.0%][r=3533MiB/s][r=904k IOPS][eta 0Jobs: 4 (f=4): [r(4)][46.7%][r=3530MiB/s][r=904k IOPS][eta 0Jobs: 4 (f=4): [r(4)][48.3%][r=3532MiB/s][r=904k IOPS][eta 0Jobs: 4 (f=4): [r(4)][50.0%][r=3533MiB/s][r=904k IOPS][eta 0Jobs: 4 (f=4): [r(4)][52.5%][r=3531MiB/s][r=904k IOPS][eta 0Jobs: 4 (f=4): [r(4)][53.3%][r=3532MiB/s][r=904k IOPS][eta 0Jobs: 4 (f=4): [r(4)][55.9%][r=3530MiB/s][r=904k IOPS][eta 0Jobs: 4 (f=4): [r(4)][56.7%][r=3530MiB/s][r=904k IOPS][eta 0Jobs: 4 (f=4): [r(4)][59.3%][r=3535MiB/s][r=905k IOPS][eta 0Jobs: 4 (f=4): [r(4)][60.0%][r=3531MiB/s][r=904k IOPS][eta 0Jobs: 4 (f=4): [r(4)][61.7%][r=3541MiB/s][r=907k IOPS][eta 0Jobs: 4 (f=4): [r(4)][63.3%][r=3543MiB/s][r=907k IOPS][eta 0Jobs: 4 (f=4): [r(4)][65.0%][r=3510MiB/s][r=899k IOPS][eta 0Jobs: 4 (f=4): [r(4)][66.7%][r=3535MiB/s][r=905k IOPS][eta 0Jobs: 4 (f=4): [r(4)][68.3%][r=3536MiB/s][r=905k IOPS][eta 0Jobs: 4 (f=4): [r(4)][70.0%][r=3528MiB/s][r=903k IOPS][eta 0Jobs: 4 (f=4): [r(4)][71.7%][r=3530MiB/s][r=904k IOPS][eta 0Jobs: 4 (f=4): [r(4)][73.3%][r=3537MiB/s][r=905k IOPS][eta 0Jobs: 4 (f=4): [r(4)][75.0%][r=3527MiB/s][r=903k IOPS][eta 0Jobs: 4 (f=4): [r(4)][78.0%][r=3533MiB/s][r=905k IOPS][eta 0Jobs: 4 (f=4): [r(4)][78.3%][r=3547MiB/s][r=908k IOPS][eta 0Jobs: 4 (f=4): [r(4)][80.0%][r=3553MiB/s][r=909k IOPS][eta 0Jobs: 4 (f=4): [r(4)][81.7%][r=3555MiB/s][r=910k IOPS][eta 0Jobs: 4 (f=4): [r(4)][83.3%][r=3560MiB/s][r=911k IOPS][eta 0Jobs: 4 (f=4): [r(4)][85.0%][r=3553MiB/s][r=910k IOPS][eta 0Jobs: 4 (f=4): [r(4)][86.7%][r=3557MiB/s][r=910k IOPS][eta 0Jobs: 4 (f=4): [r(4)][88.3%][r=3561MiB/s][r=912k IOPS][eta 0Jobs: 4 (f=4): [r(4)][90.0%][r=3562MiB/s][r=912k IOPS][eta 0Jobs: 4 (f=4): [r(4)][91.7%][r=3556MiB/s][r=910k IOPS][eta 0Jobs: 4 (f=4): [r(4)][93.3%][r=3558MiB/s][r=911k IOPS][eta 0Jobs: 4 (f=4): [r(4)][95.0%][r=3561MiB/s][r=912k IOPS][eta 0Jobs: 4 (f=4): [r(4)][96.7%][r=3561MiB/s][r=912k IOPS][eta 0Jobs: 4 (f=4): [r(4)][98.3%][r=3557MiB/s][r=911k IOPS][eta 0Jobs: 4 (f=4): [r(4)][100.0%][r=3558MiB/s][r=911k IOPS][eta 00m:00s]
randread_4k_jobs4: (groupid=0, jobs=4): err= 0: pid=14794: Fri Mar 20 14:16:38 2026
read: IOPS=903k, BW=3525MiB/s (3697MB/s)(207GiB/60001msec)
slat (nsec): min=1090, max=392687, avg=1804.72, stdev=750.90
clat (usec): min=11, max=2155, avg=139.40, stdev=63.02
lat (usec): min=13, max=2157, avg=141.30, stdev=63.03
clat percentiles (usec):
|  1.00th=[   65],  5.00th=[   70], 10.00th=[   74], 20.00th=[   84],
| 30.00th=[   95], 40.00th=[  112], 50.00th=[  127], 60.00th=[  143],
| 70.00th=[  161], 80.00th=[  188], 90.00th=[  225], 95.00th=[  260],
| 99.00th=[  338], 99.50th=[  371], 99.90th=[  449], 99.95th=[  486],
| 99.99th=[  570]
bw (  MiB/s): min= 2971, max= 3581, per=100.00%, avg=3526.89, stdev=13.98, samples=476
iops        : min=760766, max=916840, avg=902885.03, stdev=3578.03, samples=476
lat (usec)   : 20=0.01%, 50=0.09%, 100=33.18%, 250=60.64%, 500=6.04%
lat (usec)   : 750=0.03%, 1000=0.01%
lat (msec)   : 2=0.01%, 4=0.01%
cpu          : usr=18.99%, sys=37.01%, ctx=12241744, majf=0, minf=4726
IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
issued rwts: total=54151280,0,0,0 short=0,0,0,0 dropped=0,0,0,0
latency   : target=0, window=0, percentile=100.00%, depth=32
Run status group 0 (all jobs):
READ: bw=3525MiB/s (3697MB/s), 3525MiB/s-3525MiB/s (3697MB/s-3697MB/s), io=207GiB (222GB), run=60001-60001msec
Disk stats (read/write):
nvme0n1: ios=54028130/0, merge=0/0, ticks=7278257/0, in_queue=7278257, util=99.84%
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
```

0.31    0.00    0.87    0.00    0.00   98.82

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       905452.00 3621808.00     0.00   0.00    0.13     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00  121.53 100.00


avg-cpu:  %user   %nice %system %iowait  %steal   %idle
0.28    0.00    0.90    0.00    0.00   98.82

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       909869.00 3639476.00     0.00   0.00    0.13     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00  121.56 100.00


很好，jobs=4 这组把趋势继续拉出来了。
表2：numjobs 影响，更新到前三行
这组怎么读
最关键的点有三个。
第一，吞吐还在涨，但已经不是线性翻倍了。

jobs 1 → 2：330k → 596k，增幅很大


jobs 2 → 4：596k → 903k，继续涨，但没有再接近翻倍

这说明盘还有并发收益，但已经越来越接近平台瓶颈。
第二，延迟代价开始明显了。

clat avg：94.5 us → 104.8 us → 139.4 us


p99：178 us → 233 us → 338 us

也就是：
多开 job 能继续换来 IOPS，但尾延迟恶化越来越明显。
第三，设备层排队已经堆得很深。

jobs=4、qd=32，总并发大约是 128


aqu-sz ≈ 121.5

这和你的总并发压力非常接近，说明这组参数已经把设备队列几乎堆满了。
到这里可以写的阶段性结论
在 4K randread, iodepth=32 条件下，numjobs 从 1 提升到 2 再到 4 时，nvme0n1 的 IOPS 从 330k 提升到 596k 再提升到 903k，带宽从 1288 MiB/s 提升到 2330 MiB/s 再提升到 3525 MiB/s。但同时平均完成延迟从 94.5us 增加到 104.8us 再增加到 139.4us，p99 从 178us 增加到 233us 再增加到 338us。说明增加并发 job 仍能提升吞吐，但收益递减，尾延迟恶化更明显。
Day10 现在差最后一组
最自然就是补 jobs=8，这样 Day10 的 numjobs 曲线就完整了。
fio --name=randread_4k_jobs8 \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randread \
--bs=4K \
--iodepth=32 \
--numjobs=8 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
配合：
iostat -x 1 nvme0n1
你把 jobs=8 贴上来，我就把 Day10 完整收官。


```bash
[root@bogon ~]# fio --name=randread_4k_jobs8 \
>     --filename=/dev/nvme0n1 \
>     --direct=1 \
>     --ioengine=libaio \
>     --rw=randread \
>     --bs=4K \
>     --iodepth=32 \
>     --numjobs=8 \
>     --offset=4G \
>     --size=20G \
>     --runtime=60 \
>     --time_based \
>     --group_reporting
randread_4k_jobs8: (g=0): rw=randread, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=32
...
fio-3.29
Starting 8 processes
Jobs: 8 (f=8): [r(8)][5.0%][r=4679MiB/s][r=1198k IOPS][eta 0Jobs: 8 (f=8): [r(8)][6.7%][r=4681MiB/s][r=1198k IOPS][eta 0Jobs: 8 (f=8): [r(8)][8.3%][r=4681MiB/s][r=1198k IOPS][eta 0Jobs: 8 (f=8): [r(8)][10.0%][r=4681MiB/s][r=1198k IOPS][eta Jobs: 8 (f=8): [r(8)][11.7%][r=4683MiB/s][r=1199k IOPS][eta Jobs: 8 (f=8): [r(8)][13.3%][r=4684MiB/s][r=1199k IOPS][eta Jobs: 8 (f=8): [r(8)][15.0%][r=4683MiB/s][r=1199k IOPS][eta Jobs: 8 (f=8): [r(8)][16.7%][r=4687MiB/s][r=1200k IOPS][eta Jobs: 8 (f=8): [r(8)][18.3%][r=4691MiB/s][r=1201k IOPS][eta Jobs: 8 (f=8): [r(8)][20.0%][r=4694MiB/s][r=1202k IOPS][eta Jobs: 8 (f=8): [r(8)][21.7%][r=4692MiB/s][r=1201k IOPS][eta Jobs: 8 (f=8): [r(8)][23.3%][r=4687MiB/s][r=1200k IOPS][eta Jobs: 8 (f=8): [r(8)][25.0%][r=4682MiB/s][r=1199k IOPS][eta Jobs: 8 (f=8): [r(8)][26.7%][r=4691MiB/s][r=1201k IOPS][eta Jobs: 8 (f=8): [r(8)][28.3%][r=4685MiB/s][r=1199k IOPS][eta Jobs: 8 (f=8): [r(8)][30.0%][r=4693MiB/s][r=1202k IOPS][eta Jobs: 8 (f=8): [r(8)][31.7%][r=4694MiB/s][r=1202k IOPS][eta Jobs: 8 (f=8): [r(8)][33.3%][r=4689MiB/s][r=1201k IOPS][eta Jobs: 8 (f=8): [r(8)][35.0%][r=4695MiB/s][r=1202k IOPS][eta Jobs: 8 (f=8): [r(8)][36.7%][r=4693MiB/s][r=1201k IOPS][eta Jobs: 8 (f=8): [r(8)][39.0%][r=4694MiB/s][r=1202k IOPS][eta Jobs: 8 (f=8): [r(8)][40.0%][r=4697MiB/s][r=1202k IOPS][eta Jobs: 8 (f=8): [r(8)][41.7%][r=4697MiB/s][r=1202k IOPS][eta Jobs: 8 (f=8): [r(8)][43.3%][r=4692MiB/s][r=1201k IOPS][eta Jobs: 8 (f=8): [r(8)][45.0%][r=4692MiB/s][r=1201k IOPS][eta Jobs: 8 (f=8): [r(8)][46.7%][r=4695MiB/s][r=1202k IOPS][eta Jobs: 8 (f=8): [r(8)][48.3%][r=4698MiB/s][r=1203k IOPS][eta Jobs: 8 (f=8): [r(8)][50.0%][r=4697MiB/s][r=1202k IOPS][eta Jobs: 8 (f=8): [r(8)][52.5%][r=4703MiB/s][r=1204k IOPS][eta Jobs: 8 (f=8): [r(8)][53.3%][r=4700MiB/s][r=1203k IOPS][eta Jobs: 8 (f=8): [r(8)][55.9%][r=4698MiB/s][r=1203k IOPS][eta Jobs: 8 (f=8): [r(8)][56.7%][r=4699MiB/s][r=1203k IOPS][eta Jobs: 8 (f=8): [r(8)][59.3%][r=4696MiB/s][r=1202k IOPS][eta Jobs: 8 (f=8): [r(8)][60.0%][r=4700MiB/s][r=1203k IOPS][eta Jobs: 8 (f=8): [r(8)][61.7%][r=4703MiB/s][r=1204k IOPS][eta Jobs: 8 (f=8): [r(8)][63.3%][r=4702MiB/s][r=1204k IOPS][eta Jobs: 8 (f=8): [r(8)][65.0%][r=4706MiB/s][r=1205k IOPS][eta Jobs: 8 (f=8): [r(8)][66.7%][r=4701MiB/s][r=1203k IOPS][eta Jobs: 8 (f=8): [r(8)][68.3%][r=4701MiB/s][r=1203k IOPS][eta Jobs: 8 (f=8): [r(8)][70.0%][r=4708MiB/s][r=1205k IOPS][eta Jobs: 8 (f=8): [r(8)][71.7%][r=4707MiB/s][r=1205k IOPS][eta Jobs: 8 (f=8): [r(8)][73.3%][r=4703MiB/s][r=1204k IOPS][eta Jobs: 8 (f=8): [r(8)][75.0%][r=4705MiB/s][r=1204k IOPS][eta Jobs: 8 (f=8): [r(8)][78.0%][r=4702MiB/s][r=1204k IOPS][eta Jobs: 8 (f=8): [r(8)][78.3%][r=4706MiB/s][r=1205k IOPS][eta Jobs: 8 (f=8): [r(8)][80.0%][r=4703MiB/s][r=1204k IOPS][eta Jobs: 8 (f=8): [r(8)][81.7%][r=4705MiB/s][r=1204k IOPS][eta Jobs: 8 (f=8): [r(8)][83.3%][r=4701MiB/s][r=1203k IOPS][eta Jobs: 8 (f=8): [r(8)][85.0%][r=4701MiB/s][r=1203k IOPS][eta Jobs: 8 (f=8): [r(8)][86.7%][r=4704MiB/s][r=1204k IOPS][eta Jobs: 8 (f=8): [r(8)][88.3%][r=4663MiB/s][r=1194k IOPS][eta Jobs: 8 (f=8): [r(8)][90.0%][r=4703MiB/s][r=1204k IOPS][eta Jobs: 8 (f=8): [r(8)][91.7%][r=4702MiB/s][r=1204k IOPS][eta Jobs: 8 (f=8): [r(8)][93.3%][r=4699MiB/s][r=1203k IOPS][eta Jobs: 8 (f=8): [r(8)][95.0%][r=4707MiB/s][r=1205k IOPS][eta Jobs: 8 (f=8): [r(8)][96.7%][r=4708MiB/s][r=1205k IOPS][eta Jobs: 8 (f=8): [r(8)][98.3%][r=4703MiB/s][r=1204k IOPS][eta Jobs: 8 (f=8): [r(8)][100.0%][r=4701MiB/s][r=1203k IOPS][eta 00m:00s]
randread_4k_jobs8: (groupid=0, jobs=8): err= 0: pid=14800: Fri Mar 20 14:18:53 2026
read: IOPS=1199k, BW=4683MiB/s (4911MB/s)(274GiB/60001msec)
slat (nsec): min=1090, max=247237, avg=1686.33, stdev=591.76
clat (usec): min=13, max=2640, avg=211.27, stdev=101.44
lat (usec): min=15, max=2641, avg=213.04, stdev=101.45
clat percentiles (usec):
|  1.00th=[   70],  5.00th=[   82], 10.00th=[   96], 20.00th=[  127],
| 30.00th=[  151], 40.00th=[  174], 50.00th=[  196], 60.00th=[  219],
| 70.00th=[  245], 80.00th=[  281], 90.00th=[  343], 95.00th=[  400],
| 99.00th=[  545], 99.50th=[  603], 99.90th=[  742], 99.95th=[  807],
| 99.99th=[  971]
bw (  MiB/s): min= 3716, max= 4728, per=100.00%, avg=4686.98, stdev=11.34, samples=952
iops        : min=951372, max=1210608, avg=1199866.25, stdev=2902.28, samples=952
lat (usec)   : 20=0.01%, 50=0.01%, 100=11.35%, 250=60.27%, 500=26.75%
lat (usec)   : 750=1.52%, 1000=0.09%
lat (msec)   : 2=0.01%, 4=0.01%
cpu          : usr=14.05%, sys=24.72%, ctx=31382792, majf=0, minf=20578
IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
issued rwts: total=71935670,0,0,0 short=0,0,0,0 dropped=0,0,0,0
latency   : target=0, window=0, percentile=100.00%, depth=32
Run status group 0 (all jobs):
READ: bw=4683MiB/s (4911MB/s), 4683MiB/s-4683MiB/s (4911MB/s-4911MB/s), io=274GiB (295GB), run=60001-60001msec
Disk stats (read/write):
nvme0n1: ios=71741835/0, merge=0/0, ticks=14965190/0, in_queue=14965190, util=100.00%
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
```

0.42    0.00    1.24    0.00    0.00   98.34

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       1198804.33 4795214.67     0.00   0.00    0.21     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00  250.02 100.00


avg-cpu:  %user   %nice %system %iowait  %steal   %idle
0.44    0.00    1.21    0.00    0.00   98.34

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       1200131.33 4800525.33     0.00   0.00    0.21     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00  250.18 100.13

很好，Day10 现在可以正式收官了。
表2：numjobs 影响（完整）

Day10 最终结论
### iodepth 影响结论

你这块 nvme0n1 在 4K randread, numjobs=1 下：

QD1：12.5k IOPS，48.8 MiB/s，p99=91us


QD8：109k IOPS，426 MiB/s，p99=129us


QD32：330k IOPS，1288 MiB/s，p99=178us


QD64：336k IOPS，1312 MiB/s，p99=277us

这说明：
QD1→QD8→QD32 收益很明显，QD32→QD64 收益极小，但延迟显著变差。
也就是：

随机读甜点区大致在 QD32


再往上堆深度，性价比很低


### numjobs 影响结论

在 4K randread, iodepth=32 下：

jobs=1：330k IOPS，p99=178us


jobs=2：596k IOPS，p99=233us


jobs=4：903k IOPS，p99=338us


jobs=8：1199k IOPS，p99=545us

这说明：
多开 job 还能继续提升吞吐，但收益递减，尾延迟恶化非常明显。
尤其是：

jobs=4 -> jobs=8 仍然有收益


但 p99 已经从 338us 拉到 545us


clat avg 也涨到 211us

所以如果目标是：

极限吞吐：jobs=8 很强


更均衡的吞吐/延迟：jobs=2~4 更像可用区间


### 你现在可以直接记的 Day10 总结

在 4K randread 条件下，iodepth 决定单路队列深度，numjobs 决定并发来源数。对 nvme0n1 来说，iodepth 从 1 提升到 32 时，随机读 IOPS 从 12.5k 提升到 330k，收益显著；继续提升到 64 时，IOPS 仅小幅增加到 336k，但平均延迟和 p99 明显恶化，说明 iodepth=32 已接近甜点区。固定 iodepth=32 后，numjobs 从 1 增加到 8 时，IOPS 从 330k 提升到 1199k，但 p99 从 178us 增加到 545us，说明更高并发可以换来更高吞吐，但要付出明显的尾延迟代价。

你这一天最该学会的 3 句话
第一句：
顺序性能更看带宽，随机性能更看 IOPS 和延迟。
第二句：
iodepth 不是越大越好，它有甜点区。
第三句：
numjobs 能继续抬高吞吐，但尾延迟通常会更快变差。

我帮你把 Day10 两张表合起来
表1：iodepth 影响
表2：numjobs 影响



## 硬件对照表

| rw | bs |
|---|---|


## 硬件对照表

| rw | bs |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|


## 硬件对照表

| rw | bs |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|


## 硬件对照表

| rw | bs |
|---|---|
| randread | 4K |
|---|---|


## 硬件对照表

| rw | bs |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|


## 硬件对照表

| rw | bs |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|


## 硬件对照表

| rw | bs |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|


## 硬件对照表

| rw | bs |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|


## 硬件对照表

| rw | bs |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|


## 硬件对照表

| rw | bs |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|


## 硬件对照表

| rw | bs |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|


## 硬件对照表

| rw | bs |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|
| randread | 4K |
|---|---|

