Day9
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
好，开始 Day9。
我先按当前节奏接你的计划：
Day9：NVMe 4K 随机读写基线
如果你表里的 Day9 不是这个主题，你把那一行再贴我；
但按 Day8 已经做完“顺序基线”的进度，Day9 最自然就是做 4K randread / randwrite 基线。

Day9 目标
在同一块测试盘 nvme0n1 上，建立 4K 随机读写基线，重点看这几类指标：

IOPS


带宽 BW


平均延迟 / clat


p99 延迟


iostat -x 1 里的：


r/s


w/s


rkB/s


wkB/s


await


%util

和 Day8 不同的是：

Day8 更看 吞吐


Day9 更看 IOPS 和延迟


先把 Day8 和 Day9 的区别想清楚
Day8 顺序基线
重点看：

GiB/s


大块顺序吞吐


盘能跑多快

Day9 随机基线
重点看：

小块 4K


IOPS


延迟


p99 尾延迟

你可以先记一句：
顺序看带宽，随机看 IOPS 和延迟。

为什么 Day9 要继续用 nvme0n1
因为现在：

nvme1n1 是在线系统盘


nvme0n1 是专用测试盘


Day8 已经用它建立了顺序基线


Day9 接着用它，数据最连续


一个关键提醒
如果你 Day8 测完后没有重新 discard，那也没问题。
Day9 随机测试直接继续打 nvme0n1 即可。
因为随机写本来就需要真实进入设备写路径，
而且我们现在做的是“机器当前状态下的随机基线”，不是论文级洁净实验。

Day9 标准参数
先用最基础、最适合建立第一版基线的一组：

bs=4K


iodepth=32


numjobs=1


direct=1


ioengine=libaio


runtime=60


offset=4G


size=20G

这样和 Day8 的测试区域保持一致，方便对照。

先开监控窗口
一个终端执行：
iostat -x 1 nvme0n1
今天你重点盯的是：

r/s / w/s


rkB/s / wkB/s


await


%util

注意这里和 Day8 不一样：

4K 随机时，rkB/s / wkB/s 可能看起来不夸张


但 r/s / w/s 会非常高


所以今天一定要开始把 IOPS = 每秒 I/O 次数 这个感觉建立起来


第一组：4K 随机读
fio --name=nvme_randread_4k \
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
你今天重点记

IOPS


BW


clat avg


clat percentiles 里的 99.00th、99.90th


util


第二组：4K 随机写
fio --name=nvme_randwrite_4k \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randwrite \
--bs=4K \
--iodepth=32 \
--numjobs=1 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
这里你要特别留意
随机写通常比随机读更容易出现：

延迟升高


尾延迟更差


util 很高


IOPS 不如随机读

所以 Day9 的一个正常现象就是：
randread 往往比 randwrite 更好看。

可选第三组：混合随机读写
如果你今天状态还够，做完前两组后可以补一组：
fio --name=nvme_randrw_4k \
--filename=/dev/nvme0n1 \
--direct=1 \
--ioengine=libaio \
--rw=randrw \
--rwmixread=70 \
--bs=4K \
--iodepth=32 \
--numjobs=1 \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
--group_reporting
这组更接近真实业务混合负载，但不是 Day9 必做项。
Day9 最低完成标准是前两组。

你今天该怎么记结果
先用这个表：
如果你再做混合读写，就再加一行。

你今天要学会的一个换算
4K 随机时：

fio IOPS 应该和 iostat 里的 r/s 或 w/s 数量级接近


带宽大致可以用：


IOPS × 4K ≈ BW

比如：

100k IOPS × 4K ≈ 400 MB/s 左右

所以 Day9 你会看到一个很重要的现象：
随机 IOPS 很高，但带宽不一定像顺序那样夸张。
这不是盘变差了，是因为单次 I/O 很小。

Day9 你要开始关注的“延迟三件套”
今天你不能只盯 IOPS。
1）平均延迟
clat avg
2）尾延迟
p99 / p99.9
3）系统侧等待
iostat await
为什么？
因为随机性能里，尾延迟 很重要。
很多盘平均值不差，但 p99 很难看，业务体验照样差。

Day9 完成标准
今天做到这些就算完成：

跑完 4K randread


跑完 4K randwrite


记录 fio IOPS / BW / clat avg / p99


记录 iostat r/s/w/s / await / util


能说出：


随机读比随机写谁更强


这块盘在 4K 下大概能跑到多少 IOPS


延迟大概是什么量级


最推荐你的执行顺序
先执行：
iostat -x 1 nvme0n1
然后跑第一组：
fio --name=nvme_randread_4k \
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
你把 第一组 randread_4k 的 fio 输出 和 对应 iostat 那一分钟 发我，我先帮你填 Day9 第一行。



```bash
[root@bogon ~]# #4k随机读
[root@bogon ~]# fio --name=nvme_randread_4k \
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
nvme_randread_4k: (g=0): rw=randread, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=32
fio-3.29
Starting 1 process
Jobs: 1 (f=1): [r(1)][5.0%][r=1279MiB/s][r=327k IOPS][eta 00Jobs: 1 (f=1): [r(1)][6.7%][r=1278MiB/s][r=327k IOPS][eta 00Jobs: 1 (f=1): [r(1)][8.3%][r=1275MiB/s][r=326k IOPS][eta 00Jobs: 1 (f=1): [r(1)][10.0%][r=1277MiB/s][r=327k IOPS][eta 0Jobs: 1 (f=1): [r(1)][11.7%][r=1275MiB/s][r=326k IOPS][eta 0Jobs: 1 (f=1): [r(1)][13.3%][r=1272MiB/s][r=326k IOPS][eta 0Jobs: 1 (f=1): [r(1)][15.0%][r=1269MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][16.7%][r=1268MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][18.3%][r=1267MiB/s][r=324k IOPS][eta 0Jobs: 1 (f=1): [r(1)][20.0%][r=1266MiB/s][r=324k IOPS][eta 0Jobs: 1 (f=1): [r(1)][21.7%][r=1270MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][23.3%][r=1271MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][25.0%][r=1269MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][26.7%][r=1271MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][28.3%][r=1286MiB/s][r=329k IOPS][eta 0Jobs: 1 (f=1): [r(1)][30.0%][r=1286MiB/s][r=329k IOPS][eta 0Jobs: 1 (f=1): [r(1)][31.7%][r=1283MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][33.3%][r=1282MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][35.0%][r=1278MiB/s][r=327k IOPS][eta 0Jobs: 1 (f=1): [r(1)][36.7%][r=1277MiB/s][r=327k IOPS][eta 0Jobs: 1 (f=1): [r(1)][39.0%][r=1277MiB/s][r=327k IOPS][eta 0Jobs: 1 (f=1): [r(1)][40.0%][r=1275MiB/s][r=326k IOPS][eta 0Jobs: 1 (f=1): [r(1)][41.7%][r=1272MiB/s][r=326k IOPS][eta 0Jobs: 1 (f=1): [r(1)][43.3%][r=1271MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][45.0%][r=1268MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][46.7%][r=1268MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][48.3%][r=1267MiB/s][r=324k IOPS][eta 0Jobs: 1 (f=1): [r(1)][50.0%][r=1269MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][52.5%][r=1270MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][53.3%][r=1272MiB/s][r=326k IOPS][eta 0Jobs: 1 (f=1): [r(1)][55.9%][r=1287MiB/s][r=329k IOPS][eta 0Jobs: 1 (f=1): [r(1)][56.7%][r=1287MiB/s][r=330k IOPS][eta 0Jobs: 1 (f=1): [r(1)][59.3%][r=1285MiB/s][r=329k IOPS][eta 0Jobs: 1 (f=1): [r(1)][60.0%][r=1284MiB/s][r=329k IOPS][eta 0Jobs: 1 (f=1): [r(1)][61.7%][r=1281MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][63.3%][r=1281MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][65.0%][r=1280MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][66.7%][r=1278MiB/s][r=327k IOPS][eta 0Jobs: 1 (f=1): [r(1)][68.3%][r=1276MiB/s][r=327k IOPS][eta 0Jobs: 1 (f=1): [r(1)][70.0%][r=1274MiB/s][r=326k IOPS][eta 0Jobs: 1 (f=1): [r(1)][71.7%][r=1273MiB/s][r=326k IOPS][eta 0Jobs: 1 (f=1): [r(1)][73.3%][r=1272MiB/s][r=326k IOPS][eta 0Jobs: 1 (f=1): [r(1)][75.0%][r=1271MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][78.0%][r=1270MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][78.3%][r=1268MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][80.0%][r=1269MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][81.7%][r=1283MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][83.3%][r=1281MiB/s][r=328k IOPS][eta 0Jobs: 1 (f=1): [r(1)][85.0%][r=1278MiB/s][r=327k IOPS][eta 0Jobs: 1 (f=1): [r(1)][86.7%][r=1277MiB/s][r=327k IOPS][eta 0Jobs: 1 (f=1): [r(1)][88.3%][r=1274MiB/s][r=326k IOPS][eta 0Jobs: 1 (f=1): [r(1)][90.0%][r=1274MiB/s][r=326k IOPS][eta 0Jobs: 1 (f=1): [r(1)][91.7%][r=1273MiB/s][r=326k IOPS][eta 0Jobs: 1 (f=1): [r(1)][93.3%][r=1271MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][95.0%][r=1269MiB/s][r=325k IOPS][eta 0Jobs: 1 (f=1): [r(1)][96.7%][r=1267MiB/s][r=324k IOPS][eta 0Jobs: 1 (f=1): [r(1)][98.3%][r=1267MiB/s][r=324k IOPS][eta 0Jobs: 1 (f=1): [r(1)][100.0%][r=1270MiB/s][r=325k IOPS][eta 00m:00s]
nvme_randread_4k: (groupid=0, jobs=1): err= 0: pid=14703: Fri Mar 20 13:46:24 2026
read: IOPS=326k, BW=1272MiB/s (1334MB/s)(74.6GiB/60001msec)
slat (nsec): min=1241, max=183453, avg=1981.46, stdev=900.82
clat (usec): min=11, max=609, avg=95.68, stdev=24.46
lat (usec): min=14, max=778, avg=97.75, stdev=24.48
clat percentiles (usec):
|  1.00th=[   67],  5.00th=[   72], 10.00th=[   75], 20.00th=[   79],
| 30.00th=[   82], 40.00th=[   85], 50.00th=[   89], 60.00th=[   93],
| 70.00th=[   98], 80.00th=[  111], 90.00th=[  133], 95.00th=[  147],
| 99.00th=[  182], 99.50th=[  196], 99.90th=[  231], 99.95th=[  245],
| 99.99th=[  277]
bw (  MiB/s): min= 1041, max= 1290, per=100.00%, avg=1272.86, stdev=22.23, samples=119
iops        : min=266672, max=330266, avg=325852.82, stdev=5691.06, samples=119
lat (usec)   : 20=0.01%, 50=0.09%, 100=72.76%, 250=27.11%, 500=0.04%
lat (usec)   : 750=0.01%
cpu          : usr=23.35%, sys=51.02%, ctx=150779, majf=0, minf=48
IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
issued rwts: total=19544299,0,0,0 short=0,0,0,0 dropped=0,0,0,0
latency   : target=0, window=0, percentile=100.00%, depth=32
Run status group 0 (all jobs):
READ: bw=1272MiB/s (1334MB/s), 1272MiB/s-1272MiB/s (1334MB/s-1334MB/s), io=74.6GiB (80.1GB), run=60001-60001msec
Disk stats (read/write):
nvme0n1: ios=19504116/0, merge=0/0, ticks=1560254/0, in_queue=1560253, util=99.85%
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
```

0.09    0.00    0.32    0.00    0.00   99.59

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       326363.67 1305454.67     0.00   0.00    0.08     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   26.11 100.00


avg-cpu:  %user   %nice %system %iowait  %steal   %idle
0.10    0.00    0.30    0.00    0.00   99.60

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       324840.00 1299360.00     0.00   0.00    0.08     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   25.96 100.00




```bash
[root@bogon ~]# #4k随机写
[root@bogon ~]# fio --name=nvme_randwrite_4k \
>     --filename=/dev/nvme0n1 \
>     --direct=1 \
>     --ioengine=libaio \
>     --rw=randwrite \
>     --bs=4K \
--offset=4G \
--size=20G \
--runtime=60 \
--time_based \
>     --iodepth=32 \
>     --numjobs=1 \
>     --offset=4G \
>     --size=20G \
>     --runtime=60 \
>     --time_based \
>     --group_reporting
nvme_randwrite_4k: (g=0): rw=randwrite, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=32
fio-3.29
Starting 1 process
Jobs: 1 (f=1): [w(1)][5.0%][w=1261MiB/s][w=323k IOPS][eta 00Jobs: 1 (f=1): [w(1)][6.7%][w=1238MiB/s][w=317k IOPS][eta 00Jobs: 1 (f=1): [w(1)][8.3%][w=1279MiB/s][w=328k IOPS][eta 00Jobs: 1 (f=1): [w(1)][10.0%][w=1274MiB/s][w=326k IOPS][eta 0Jobs: 1 (f=1): [w(1)][11.7%][w=1267MiB/s][w=324k IOPS][eta 0Jobs: 1 (f=1): [w(1)][13.3%][w=1237MiB/s][w=317k IOPS][eta 0Jobs: 1 (f=1): [w(1)][15.0%][w=1235MiB/s][w=316k IOPS][eta 0Jobs: 1 (f=1): [w(1)][16.7%][w=1235MiB/s][w=316k IOPS][eta 0Jobs: 1 (f=1): [w(1)][18.3%][w=1237MiB/s][w=317k IOPS][eta 0Jobs: 1 (f=1): [w(1)][20.0%][w=1238MiB/s][w=317k IOPS][eta 0Jobs: 1 (f=1): [w(1)][21.7%][w=1234MiB/s][w=316k IOPS][eta 0Jobs: 1 (f=1): [w(1)][23.3%][w=1235MiB/s][w=316k IOPS][eta 0Jobs: 1 (f=1): [w(1)][25.0%][w=1235MiB/s][w=316k IOPS][eta 0Jobs: 1 (f=1): [w(1)][26.7%][w=1235MiB/s][w=316k IOPS][eta 0Jobs: 1 (f=1): [w(1)][28.3%][w=1252MiB/s][w=321k IOPS][eta 0Jobs: 1 (f=1): [w(1)][30.0%][w=1259MiB/s][w=322k IOPS][eta 0Jobs: 1 (f=1): [w(1)][31.7%][w=1279MiB/s][w=327k IOPS][eta 0Jobs: 1 (f=1): [w(1)][33.3%][w=1288MiB/s][w=330k IOPS][eta 0Jobs: 1 (f=1): [w(1)][35.0%][w=1285MiB/s][w=329k IOPS][eta 0Jobs: 1 (f=1): [w(1)][36.7%][w=1241MiB/s][w=318k IOPS][eta 0Jobs: 1 (f=1): [w(1)][39.0%][w=1237MiB/s][w=317k IOPS][eta 0Jobs: 1 (f=1): [w(1)][40.0%][w=1283MiB/s][w=328k IOPS][eta 0Jobs: 1 (f=1): [w(1)][41.7%][w=1281MiB/s][w=328k IOPS][eta 0Jobs: 1 (f=1): [w(1)][43.3%][w=1223MiB/s][w=313k IOPS][eta 0Jobs: 1 (f=1): [w(1)][45.0%][w=1257MiB/s][w=322k IOPS][eta 0Jobs: 1 (f=1): [w(1)][46.7%][w=1233MiB/s][w=316k IOPS][eta 0Jobs: 1 (f=1): [w(1)][48.3%][w=1239MiB/s][w=317k IOPS][eta 0Jobs: 1 (f=1): [w(1)][50.0%][w=1238MiB/s][w=317k IOPS][eta 0Jobs: 1 (f=1): [w(1)][52.5%][w=1236MiB/s][w=316k IOPS][eta 0Jobs: 1 (f=1): [w(1)][53.3%][w=1233MiB/s][w=316k IOPS][eta 0Jobs: 1 (f=1): [w(1)][55.9%][w=1243MiB/s][w=318k IOPS][eta 0Jobs: 1 (f=1): [w(1)][56.7%][w=1263MiB/s][w=323k IOPS][eta 0Jobs: 1 (f=1): [w(1)][59.3%][w=1256MiB/s][w=321k IOPS][eta 0Jobs: 1 (f=1): [w(1)][60.0%][w=1253MiB/s][w=321k IOPS][eta 0Jobs: 1 (f=1): [w(1)][61.7%][w=1251MiB/s][w=320k IOPS][eta 0Jobs: 1 (f=1): [w(1)][63.3%][w=1248MiB/s][w=319k IOPS][eta 0Jobs: 1 (f=1): [w(1)][65.0%][w=1249MiB/s][w=320k IOPS][eta 0Jobs: 1 (f=1): [w(1)][66.7%][w=1249MiB/s][w=320k IOPS][eta 0Jobs: 1 (f=1): [w(1)][68.3%][w=1246MiB/s][w=319k IOPS][eta 0Jobs: 1 (f=1): [w(1)][70.0%][w=1244MiB/s][w=318k IOPS][eta 0Jobs: 1 (f=1): [w(1)][71.7%][w=1243MiB/s][w=318k IOPS][eta 0Jobs: 1 (f=1): [w(1)][73.3%][w=1239MiB/s][w=317k IOPS][eta 0Jobs: 1 (f=1): [w(1)][75.0%][w=1237MiB/s][w=317k IOPS][eta 0Jobs: 1 (f=1): [w(1)][78.0%][w=1235MiB/s][w=316k IOPS][eta 0Jobs: 1 (f=1): [w(1)][78.3%][w=1235MiB/s][w=316k IOPS][eta 0Jobs: 1 (f=1): [w(1)][80.0%][w=1232MiB/s][w=315k IOPS][eta 0Jobs: 1 (f=1): [w(1)][81.7%][w=1234MiB/s][w=316k IOPS][eta 0Jobs: 1 (f=1): [w(1)][83.3%][w=1254MiB/s][w=321k IOPS][eta 0Jobs: 1 (f=1): [w(1)][85.0%][w=1261MiB/s][w=323k IOPS][eta 0Jobs: 1 (f=1): [w(1)][86.7%][w=1258MiB/s][w=322k IOPS][eta 0Jobs: 1 (f=1): [w(1)][88.3%][w=1255MiB/s][w=321k IOPS][eta 0Jobs: 1 (f=1): [w(1)][90.0%][w=1253MiB/s][w=321k IOPS][eta 0Jobs: 1 (f=1): [w(1)][91.7%][w=1252MiB/s][w=320k IOPS][eta 0Jobs: 1 (f=1): [w(1)][93.3%][w=1245MiB/s][w=319k IOPS][eta 0Jobs: 1 (f=1): [w(1)][95.0%][w=1243MiB/s][w=318k IOPS][eta 0Jobs: 1 (f=1): [w(1)][96.7%][w=1244MiB/s][w=319k IOPS][eta 0Jobs: 1 (f=1): [w(1)][98.3%][w=1240MiB/s][w=317k IOPS][eta 0Jobs: 1 (f=1): [w(1)][100.0%][w=1245MiB/s][w=319k IOPS][eta 00m:00s]
nvme_randwrite_4k: (groupid=0, jobs=1): err= 0: pid=14706: Fri Mar 20 13:48:18 2026
write: IOPS=319k, BW=1247MiB/s (1308MB/s)(73.1GiB/60001msec); 0 zone resets
slat (nsec): min=1140, max=266778, avg=1816.41, stdev=592.14
clat (usec): min=10, max=532, avg=97.64, stdev= 3.63
lat (usec): min=11, max=536, avg=99.56, stdev= 3.70
clat percentiles (usec):
|  1.00th=[   92],  5.00th=[   94], 10.00th=[   95], 20.00th=[   96],
| 30.00th=[   96], 40.00th=[   97], 50.00th=[   98], 60.00th=[   98],
| 70.00th=[   99], 80.00th=[  100], 90.00th=[  101], 95.00th=[  102],
| 99.00th=[  104], 99.50th=[  108], 99.90th=[  147], 99.95th=[  149],
| 99.99th=[  163]
bw (  MiB/s): min= 1128, max= 1300, per=100.00%, avg=1247.87, stdev=20.10, samples=119
iops        : min=288792, max=332984, avg=319454.54, stdev=5144.56, samples=119
lat (usec)   : 20=0.01%, 50=0.01%, 100=83.95%, 250=16.04%, 500=0.01%
lat (usec)   : 750=0.01%
cpu          : usr=29.02%, sys=47.65%, ctx=176, majf=0, minf=1688
IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
issued rwts: total=0,19161007,0,0 short=0,0,0,0 dropped=0,0,0,0
latency   : target=0, window=0, percentile=100.00%, depth=32
Run status group 0 (all jobs):
WRITE: bw=1247MiB/s (1308MB/s), 1247MiB/s-1247MiB/s (1308MB/s-1308MB/s), io=73.1GiB (78.5GB), run=60001-60001msec
Disk stats (read/write):
nvme0n1: ios=46/19113033, merge=0/0, ticks=1/157565, in_queue=157567, util=97.72%
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
```

0.12    0.00    0.29    0.00    0.00   99.60

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1          0.00      0.00     0.00   0.00    0.00     0.00 316184.33 1264737.33     0.00   0.00    0.01     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    2.63  97.87


avg-cpu:  %user   %nice %system %iowait  %steal   %idle
0.12    0.00    0.28    0.00    0.00   99.59

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1          0.00      0.00     0.00   0.00    0.00     0.00 323956.67 1295826.67     0.00   0.00    0.01     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    2.63  98.67


```bash
[root@bogon ~]# #混合随机读写
[root@bogon ~]# fio --name=nvme_randrw_4k \
>     --filename=/dev/nvme0n1 \
>     --direct=1 \
>     --ioengine=libaio \
>     --rw=randrw \
>     --rwmixread=70 \
>     --bs=4K \
>     --iodepth=32 \
>     --numjobs=1 \
>     --offset=4G \
>     --size=20G \
>     --runtime=60 \
>     --time_based \
>     --group_reporting
nvme_randrw_4k: (g=0): rw=randrw, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=32
fio-3.29
Starting 1 process
Jobs: 1 (f=1): [m(1)][5.0%][r=880MiB/s,w=378MiB/s][r=225k,w=Jobs: 1 (f=1): [m(1)][6.7%][r=879MiB/s,w=375MiB/s][r=225k,w=Jobs: 1 (f=1): [m(1)][8.3%][r=877MiB/s,w=376MiB/s][r=225k,w=Jobs: 1 (f=1): [m(1)][10.0%][r=870MiB/s,w=374MiB/s][r=223k,wJobs: 1 (f=1): [m(1)][11.7%][r=877MiB/s,w=377MiB/s][r=225k,wJobs: 1 (f=1): [m(1)][13.3%][r=872MiB/s,w=372MiB/s][r=223k,wJobs: 1 (f=1): [m(1)][15.0%][r=869MiB/s,w=372MiB/s][r=222k,wJobs: 1 (f=1): [m(1)][16.7%][r=870MiB/s,w=374MiB/s][r=223k,wJobs: 1 (f=1): [m(1)][18.3%][r=867MiB/s,w=371MiB/s][r=222k,wJobs: 1 (f=1): [m(1)][20.0%][r=869MiB/s,w=372MiB/s][r=222k,wJobs: 1 (f=1): [m(1)][21.7%][r=867MiB/s,w=369MiB/s][r=222k,wJobs: 1 (f=1): [m(1)][23.3%][r=862MiB/s,w=372MiB/s][r=221k,wJobs: 1 (f=1): [m(1)][25.0%][r=856MiB/s,w=367MiB/s][r=219k,wJobs: 1 (f=1): [m(1)][26.7%][r=862MiB/s,w=370MiB/s][r=221k,wJobs: 1 (f=1): [m(1)][28.3%][r=870MiB/s,w=373MiB/s][r=223k,wJobs: 1 (f=1): [m(1)][30.0%][r=880MiB/s,w=379MiB/s][r=225k,wJobs: 1 (f=1): [m(1)][31.7%][r=874MiB/s,w=375MiB/s][r=224k,wJobs: 1 (f=1): [m(1)][33.3%][r=873MiB/s,w=375MiB/s][r=223k,wJobs: 1 (f=1): [m(1)][35.0%][r=873MiB/s,w=374MiB/s][r=224k,wJobs: 1 (f=1): [m(1)][36.7%][r=876MiB/s,w=374MiB/s][r=224k,wJobs: 1 (f=1): [m(1)][39.0%][r=876MiB/s,w=374MiB/s][r=224k,wJobs: 1 (f=1): [m(1)][40.0%][r=871MiB/s,w=374MiB/s][r=223k,wJobs: 1 (f=1): [m(1)][41.7%][r=870MiB/s,w=372MiB/s][r=223k,wJobs: 1 (f=1): [m(1)][43.3%][r=868MiB/s,w=371MiB/s][r=222k,wJobs: 1 (f=1): [m(1)][45.0%][r=867MiB/s,w=370MiB/s][r=222k,wJobs: 1 (f=1): [m(1)][46.7%][r=866MiB/s,w=372MiB/s][r=222k,wJobs: 1 (f=1): [m(1)][48.3%][r=868MiB/s,w=372MiB/s][r=222k,wJobs: 1 (f=1): [m(1)][50.0%][r=861MiB/s,w=371MiB/s][r=221k,wJobs: 1 (f=1): [m(1)][52.5%][r=869MiB/s,w=370MiB/s][r=223k,wJobs: 1 (f=1): [m(1)][53.3%][r=869MiB/s,w=371MiB/s][r=222k,wJobs: 1 (f=1): [m(1)][55.9%][r=871MiB/s,w=376MiB/s][r=223k,wJobs: 1 (f=1): [m(1)][56.7%][r=886MiB/s,w=378MiB/s][r=227k,wJobs: 1 (f=1): [m(1)][59.3%][r=885MiB/s,w=377MiB/s][r=227k,wJobs: 1 (f=1): [m(1)][60.0%][r=882MiB/s,w=376MiB/s][r=226k,wJobs: 1 (f=1): [m(1)][61.7%][r=876MiB/s,w=378MiB/s][r=224k,wJobs: 1 (f=1): [m(1)][63.3%][r=877MiB/s,w=375MiB/s][r=225k,wJobs: 1 (f=1): [m(1)][65.0%][r=868MiB/s,w=372MiB/s][r=222k,wJobs: 1 (f=1): [m(1)][66.7%][r=874MiB/s,w=375MiB/s][r=224k,wJobs: 1 (f=1): [m(1)][68.3%][r=873MiB/s,w=373MiB/s][r=224k,wJobs: 1 (f=1): [m(1)][70.0%][r=871MiB/s,w=374MiB/s][r=223k,wJobs: 1 (f=1): [m(1)][71.7%][r=872MiB/s,w=373MiB/s][r=223k,wJobs: 1 (f=1): [m(1)][73.3%][r=872MiB/s,w=374MiB/s][r=223k,wJobs: 1 (f=1): [m(1)][75.0%][r=872MiB/s,w=372MiB/s][r=223k,wJobs: 1 (f=1): [m(1)][78.0%][r=868MiB/s,w=373MiB/s][r=222k,wJobs: 1 (f=1): [m(1)][78.3%][r=868MiB/s,w=373MiB/s][r=222k,wJobs: 1 (f=1): [m(1)][80.0%][r=868MiB/s,w=372MiB/s][r=222k,wJobs: 1 (f=1): [m(1)][81.7%][r=868MiB/s,w=373MiB/s][r=222k,wJobs: 1 (f=1): [m(1)][83.3%][r=878MiB/s,w=376MiB/s][r=225k,wJobs: 1 (f=1): [m(1)][85.0%][r=887MiB/s,w=381MiB/s][r=227k,wJobs: 1 (f=1): [m(1)][86.7%][r=886MiB/s,w=380MiB/s][r=227k,wJobs: 1 (f=1): [m(1)][88.3%][r=885MiB/s,w=380MiB/s][r=227k,wJobs: 1 (f=1): [m(1)][90.0%][r=873MiB/s,w=377MiB/s][r=223k,wJobs: 1 (f=1): [m(1)][91.7%][r=881MiB/s,w=378MiB/s][r=225k,wJobs: 1 (f=1): [m(1)][93.3%][r=875MiB/s,w=373MiB/s][r=224k,wJobs: 1 (f=1): [m(1)][95.0%][r=875MiB/s,w=376MiB/s][r=224k,wJobs: 1 (f=1): [m(1)][96.7%][r=873MiB/s,w=376MiB/s][r=224k,wJobs: 1 (f=1): [m(1)][98.3%][r=873MiB/s,w=375MiB/s][r=223k,wJobs: 1 (f=1): [m(1)][100.0%][r=872MiB/s,w=372MiB/s][r=223k,w=95.3k IOPS][eta 00m:00s]
nvme_randrw_4k: (groupid=0, jobs=1): err= 0: pid=14711: Fri Mar 20 13:50:01 2026
read: IOPS=223k, BW=872MiB/s (914MB/s)(51.1GiB/60001msec)
slat (nsec): min=1230, max=88096, avg=1992.52, stdev=883.27
clat (usec): min=10, max=2216, avg=120.89, stdev=46.01
lat (usec): min=14, max=2217, avg=122.97, stdev=46.01
clat percentiles (usec):
|  1.00th=[   64],  5.00th=[   80], 10.00th=[   87], 20.00th=[   95],
| 30.00th=[  100], 40.00th=[  105], 50.00th=[  111], 60.00th=[  116],
| 70.00th=[  123], 80.00th=[  137], 90.00th=[  161], 95.00th=[  200],
| 99.00th=[  326], 99.50th=[  347], 99.90th=[  404], 99.95th=[  437],
| 99.99th=[  881]
bw (  KiB/s): min=789952, max=911120, per=100.00%, avg=893063.60, stdev=11983.74, samples=119
iops        : min=197488, max=227780, avg=223265.90, stdev=2995.93, samples=119
write: IOPS=95.7k, BW=374MiB/s (392MB/s)(21.9GiB/60001msec); 0 zone resets
slat (nsec): min=1260, max=78145, avg=2044.28, stdev=889.20
clat (usec): min=4, max=153, avg=43.67, stdev=12.70
lat (usec): min=8, max=155, avg=45.81, stdev=12.79
clat percentiles (usec):
|  1.00th=[   13],  5.00th=[   21], 10.00th=[   27], 20.00th=[   33],
| 30.00th=[   38], 40.00th=[   42], 50.00th=[   45], 60.00th=[   48],
| 70.00th=[   52], 80.00th=[   55], 90.00th=[   60], 95.00th=[   63],
| 99.00th=[   69], 99.50th=[   72], 99.90th=[   94], 99.95th=[  101],
| 99.99th=[  111]
bw (  KiB/s): min=337200, max=391184, per=100.00%, avg=382785.41, stdev=5362.23, samples=119
iops        : min=84300, max=97796, avg=95696.35, stdev=1340.57, samples=119
lat (usec)   : 10=0.10%, 20=1.22%, 50=18.86%, 100=30.34%, 250=47.42%
lat (usec)   : 500=2.06%, 750=0.01%, 1000=0.01%
lat (msec)   : 2=0.01%, 4=0.01%
cpu          : usr=24.66%, sys=50.87%, ctx=68991, majf=0, minf=20
IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
issued rwts: total=13391761,5740136,0,0 short=0,0,0,0 dropped=0,0,0,0
latency   : target=0, window=0, percentile=100.00%, depth=32
Run status group 0 (all jobs):
READ: bw=872MiB/s (914MB/s), 872MiB/s-872MiB/s (914MB/s-914MB/s), io=51.1GiB (54.9GB), run=60001-60001msec
WRITE: bw=374MiB/s (392MB/s), 374MiB/s-374MiB/s (392MB/s-392MB/s), io=21.9GiB (23.5GB), run=60001-60001msec
Disk stats (read/write):
nvme0n1: ios=13356665/5724941, merge=0/0, ticks=1169968/49562, in_queue=1219530, util=99.85%
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
```

0.10    0.00    0.30    0.00    0.00   99.60

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       223077.33 892309.33     0.00   0.00    0.09     4.00 95592.33 382369.33     0.00   0.00    0.01     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   20.45 100.00


avg-cpu:  %user   %nice %system %iowait  %steal   %idle
0.10    0.00    0.31    0.00    0.00   99.60

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
nvme0n1       226052.33 904209.33     0.00   0.00    0.09     4.00 96546.67 386186.67     0.00   0.00    0.01     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   20.63 100.00


Day9 结论
本机 nvme0n1 在 bs=4K、iodepth=32、numjobs=1、direct=1 条件下：

4K 随机读基线约为 326k IOPS / 1272 MiB/s


4K 随机写基线约为 319k IOPS / 1247 MiB/s


4K 70/30 混合基线约为


读：223k IOPS / 872 MiB/s


写：95.7k IOPS / 374 MiB/s

同时，fio 和 iostat 基本能对齐：

randread 的 fio 326k IOPS 对应 iostat 的 324k~326k r/s


randwrite 的 fio 319k IOPS 对应 iostat 的 316k~324k w/s

说明本次 Day9 随机基线结果可信。

这次最值得你记住的观察点
1）这块盘 4K 随机读写都很强
你这次结果很整齐：

随机读：326k IOPS


随机写：319k IOPS

说明这块 NVMe 在当前平台、当前参数下，小块随机性能非常强，而且读写差距不大。
2）随机性能看 IOPS，不要只看带宽
虽然带宽只有 1.2 GiB/s 左右，看起来比 Day8 的顺序 6.8 GiB/s 小很多，但这是正常的，因为：

Day8：大块顺序


Day9：4K 小块随机

Day9 真正的核心指标是 IOPS 和延迟，不是单纯 GiB/s。
3）尾延迟很漂亮
你的 4K 随机单读单写：

randread p99 = 182 us


randwrite p99 = 104 us

这个结果很干净，说明不仅平均值不错，尾延迟也控制得比较好。
4）混合负载下读写分流很明显
70/30 混合时：

读 IOPS 降到 223k


写 IOPS 降到 95.7k

这是正常的，因为混合负载下：

控制器和盘内部资源要同时处理读写


总体延迟模型会变复杂


读性能和写性能都不再等于单项极限

这组数据更接近真实业务场景。

你可以直接抄进笔记的 Day9 总结
在 bs=4K、iodepth=32、numjobs=1、direct=1 条件下，nvme0n1 的随机读基线约为 326k IOPS / 1272 MiB/s，随机写基线约为 319k IOPS / 1247 MiB/s；fio 输出与 iostat -x 1 中的 r/s、w/s、await 基本一致，说明本次 4K 随机基线结果可信。混合 70/30 读写负载下，读约 223k IOPS、写约 95.7k IOPS，可作为更接近业务场景的补充基线。

Day9 完成标准回看
你现在已经完成了：

4K randread


4K randwrite


4K randrw 70/30


记录了 IOPS / BW / clat avg / p99 / await / util


也完成了 fio 和 iostat 对齐

所以 Day9 已完成。
下一步最自然就是进 Day10：iodepth、numjobs 对随机性能的影响。


## 硬件对照表

| 测试项 | 目标盘 |
|---|---|
| randread_4k | nvme0n1 |
|---|---|
| randwrite_4k | nvme0n1 |
|---|---|


## 硬件对照表

| 测试项 | 目标盘 |
|---|---|
| randread_4k | nvme0n1 |
|---|---|
| randwrite_4k | nvme0n1 |
|---|---|
| randrw_4k_70r30w | nvme0n1 |
|---|---|

